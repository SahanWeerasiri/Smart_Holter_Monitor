"use client"

import { useState, useEffect } from "react"
import { useRouter, useSearchParams } from "next/navigation"
import { toast } from "sonner"
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
  ReferenceArea,
} from "recharts"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import {
  getPatientById,
  createReport,
  generateAIReportSuggestion,
  saveReport,
  getLatestReport,
} from "@/lib/firebase/firestore"
import { Loader2 } from "lucide-react"
import { Calendar } from "@/components/ui/calendar"
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover"
import { CalendarIcon } from "lucide-react"
import { format } from "date-fns"

export default function CreateReportPage() {
  const router = useRouter()
  const searchParams = useSearchParams()
  const patientId = searchParams.get("patientId")

  const [loading, setLoading] = useState(true)
  const [submitting, setSubmitting] = useState(false)
  const [generatingAI, setGeneratingAI] = useState(false)
  const [patient, setPatient] = useState<Patient>()
  const [displayData, setDisplayData] = useState<ChannelData[]>([])
  const [reportData, setReportData] = useState<ReportData>({
    id: "",
    title: "Holter Monitor Report",
    patientId: "",
    patientName: "",
    patientAge: 0,
    patientGender: "",
    doctorId: "",
    doctorName: "",
    doctorSpecialization: "",
    hospitalName: "",
    summary: "",
    anomalyDetection: "",
    doctorSuggestion: "",
    aiSuggestion: "",
    createdAt: "",
    status: "completed",
    timeRange: { start: 0, end: 24 },
    data: [],
  })
  const [timeRange, setTimeRange] = useState([0, 48])
  const [ecgData, setEcgData] = useState<ChannelData>()
  const [startDate, setStartDate] = useState<Date | undefined>(new Date())
  const [endDate, setEndDate] = useState<Date | undefined>(new Date())
  const [filteredChartData, setFilteredChartData] = useState<any[]>([])

  interface ReportData {
    id: string
    title: string
    patientId: string
    patientName: string
    patientAge: number
    patientGender: string
    doctorId: string
    doctorName: string
    doctorSpecialization: string
    hospitalName: string
    summary: string
    anomalyDetection: string
    doctorSuggestion: string
    aiSuggestion: string
    createdAt: string
    status: string
    timeRange: { start: number; end: number }
    data: ChannelData[]
  }

  interface Patient {
    id: string
    name: string
    age: number
    gender: string
    contactNumber: string
    medicalHistory: string
    status: string
    emergencyContact: {
      name: string
      mobile: string
    }
  }

  interface Point {
    key: string | number
    value: number
  }

  interface ChannelData {
    c1: Point[]
    c2: Point[]
    c3: Point[]
  }
  interface Entry {
    time: string | number | Date
    c1?: number
    c2?: number
    c3?: number
  }

  interface TransformedData {
    timestamp: string
    time: number
    c1: number
    c2: number
    c3: number
  }

  const transformedData: TransformedData[] = []

  const formatDate = (dateString: string | number | Date) => {
    const date = new Date(dateString)
    return new Intl.DateTimeFormat("en-US", {
      year: "numeric",
      month: "long",
      day: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    }).format(date)
  }

  const transformReportData = (reportData: any) => {
    if (!reportData || !reportData.data) return []

    // const transformedData: { timestamp: string; time: number | Date; c1: number; c2: number; c3: number }[] = []

    if (Array.isArray(reportData.data)) {
      reportData.data.forEach((entry: { time: string | number | Date; c1: any; c2: any; c3: any }) => {
        // Convert entry.time to a number
        let time: number

        if (typeof entry.time === "string") {
          if (entry.time.includes(":")) {
            // If it's a timestamp string (e.g., "2023:10:01 12:00:00:000")
            const [datePart, timePart] = entry.time.split(" ")
            const [year, month, day] = datePart.split(":")
            const [hour, minute, secondMs] = timePart.split(":")
            const [second, ms] = secondMs ? secondMs.split(".") : ["0", "0"]

            const date = new Date(
              Number.parseInt(year),
              Number.parseInt(month) - 1, // Month is 0-indexed in JavaScript
              Number.parseInt(day),
              Number.parseInt(hour),
              Number.parseInt(minute),
              Number.parseInt(second),
              Number.parseInt(ms),
            )

            time = date.getTime()
          } else {
            // If it's a numeric string (e.g., "1234567890")
            time = Number.parseFloat(entry.time)
          }
        } else if (entry.time instanceof Date) {
          // If it's a Date object, get the timestamp directly
          time = entry.time.getTime()
        } else {
          // If it's already a number, use it directly
          time = entry.time
        }

        // Push the transformed data
        transformedData.push({
          timestamp: typeof entry.time === "string" ? entry.time : new Date(entry.time).toISOString(),
          time: time,
          c1: entry.c1 || 0, // Fallback to 0 if undefined
          c2: entry.c2 || 0, // Fallback to 0 if undefined
          c3: entry.c3 || 0, // Fallback to 0 if undefined
        })
      })
    } else if (reportData.data.c1 && typeof reportData.data.c1 === "object" && !Array.isArray(reportData.data.c1)) {
      const timestamps = Object.keys(reportData.data.c1)

      timestamps.forEach((timestamp) => {
        let time: number

        if (!isNaN(Number(timestamp))) {
          time = Number(timestamp)
        } else {
          const [datePart, timePart] = timestamp.split(" ")
          const [year, month, day] = datePart.split(":")
          const [hour, minute, secondMs] = timePart.split(":")
          const [second, ms] = secondMs ? secondMs.split(".") : [0, 0]

          const date = new Date(
            Number.parseInt(year),
            Number.parseInt(month) - 1,
            Number.parseInt(day),
            Number.parseInt(hour),
            Number.parseInt(minute),
            Number.parseInt(second.toString()),
            ms ? Number.parseInt(ms.toString()) : 0,
          )

          time = date.getTime()
        }

        transformedData.push({
          timestamp,
          time,
          c1: reportData.data.c1[timestamp] || 0,
          c2: reportData.data.c2[timestamp] || 0,
          c3: reportData.data.c3[timestamp] || 0,
        })
      })
    }

    transformedData.sort((a, b) => a.time - b.time)
    return transformedData
  }

  useEffect(() => {
    const fetchPatientData = async () => {
      if (!patientId) {
        toast.error("Patient ID is required")
        router.push("/dashboard/doctor/patients")
        return
      }

      try {
        const patientData = await getPatientById(patientId)
        setPatient(patientData)

        const reportData = await getLatestReport(patientId)
        setReportData(reportData)
        console.log("Report data", reportData.data)

        const data: ChannelData = {
          c1: reportData.data[0],
          c2: reportData.data[1],
          c3: reportData.data[2],
        }

        console.log("final", data)

        // for (let i = 0; i < reportData.data[0].length; i++) {
        //   const entry = reportData.data[0]
        //   // console.log("Entry", entry)
        //   for (let key in entry.keys) {
        //     console.log("Key", key)
        //     const point1: Point = { key: key, value: entry[key] || 0 }
        //     const point2: Point = { key: key, value: entry[key] || 0 }
        //     const point3: Point = { key: key, value: entry[key] || 0 }
        //     data.c1.push(point1)
        //     data.c2.push(point2)
        //     data.c3.push(point3)
        //   }

        // }
        setEcgData(data)

        console.log("ECG data", data)

        setLoading(false)
      } catch (error) {
        console.error("Error fetching patient data:", error)
        toast.error("Failed to fetch patient data")
        setLoading(false)
      }
    }

    fetchPatientData()
  }, [patientId, router])

  const handleInputChange = (e: { target: { name: any; value: any } }) => {
    const { name, value } = e.target
    setReportData((prev) => ({
      ...prev,
      [name]: value,
    }))
  }

  const handleTimeRangeChange = (values: number[]) => {
    setTimeRange(values)
  }

  const handleGenerateAISuggestion = async () => {
    if (!patient) return

    setGeneratingAI(true)
    try {
      const aiSuggestion = await generateAIReportSuggestion({
        patientData: patient,
        reportSummary: reportData.summary,
        anomalyDetection: reportData.anomalyDetection,
      })

      setReportData((prev) => ({
        ...prev,
        aiSuggestion,
      }))

      toast.success("AI suggestion generated successfully")
    } catch (error) {
      console.error("Error generating AI suggestion:", error)
      toast.error("Failed to generate AI suggestion")
    } finally {
      setGeneratingAI(false)
    }
  }

  const handleSubmit = async (e: { preventDefault: () => void }) => {
    e.preventDefault()

    if (!patient) {
      toast.error("Patient data is required")
      return
    }

    if (!reportData.summary || !reportData.anomalyDetection || !reportData.doctorSuggestion) {
      toast.error("Please fill in all required fields")
      return
    }

    setSubmitting(true)
    try {
      if (!ecgData) {
        throw new Error("ECG data is not available")
      }
      const filteredData =
        filteredChartData.length > 0
          ? filteredChartData.map((point) => ({ key: point.time, value: point.value }))
          : ecgData.c1.filter(
            (point) =>
              Number.parseFloat(point.key as string) >= timeRange[0] &&
              Number.parseFloat(point.key as string) <= timeRange[1],
          )

      const reportId = await createReport({
        patientId,
        title: reportData.title,
        summary: reportData.summary,
        anomalyDetection: reportData.anomalyDetection,
        doctorSuggestion: reportData.doctorSuggestion,
        aiSuggestion: reportData.aiSuggestion,
        timeRange: {
          start: timeRange[0],
          end: timeRange[1],
        },
        data: filteredData,
        isDone: true,
      })

      toast.success("Report created successfully")
      router.push(`/dashboard/doctor/reports/${reportId}?patientId=${patientId}`)
    } catch (error) {
      console.error("Error creating report:", error)
      toast.error("Failed to create report")
    } finally {
      setSubmitting(false)
    }
  }

  const handleSaveDraft = async (e: { preventDefault: () => void }) => {
    e.preventDefault()

    if (!patient) {
      toast.error("Patient data is required")
      return
    }

    try {
      if (!ecgData) {
        throw new Error("ECG data is not available")
      }

      const filteredData =
        filteredChartData.length > 0
          ? filteredChartData.map((point) => ({ key: point.time, value: point.value }))
          : ecgData.c1.filter(
            (point) =>
              Number.parseFloat(point.key as string) >= timeRange[0] &&
              Number.parseFloat(point.key as string) <= timeRange[1],
          )
      const reportId = await saveReport({
        patientId,
        title: reportData.title,
        summary: reportData.summary,
        anomalyDetection: reportData.anomalyDetection,
        doctorSuggestion: reportData.doctorSuggestion,
        aiSuggestion: reportData.aiSuggestion,
        timeRange: {
          start: timeRange[0],
          end: timeRange[1],
        },
        data: filteredData,
      })

      toast.success("Report saved as a draft successfully")
      router.push(`/dashboard/reports/`)
    } catch (error) {
      console.error("Error creating report:", error)
      toast.error("Failed to create report")
    } finally {
    }
  }

  if (loading) {
    return (
      <div className="flex h-[calc(100vh-4rem)] items-center justify-center">
        <Loader2 className="h-8 w-8 animate-spin text-primary" />
      </div>
    )
  }

  if (!ecgData) {
    throw new Error("ECG data is not available")
  }

  // Step 1: Get the starting time (first datetime in the `key` array)
  const startingTime = new Date(ecgData.c1[0].key).getTime()

  const processedData = ecgData.c1.map((point: Point) => {
    const timestamp = new Date(point.key).getTime()
    const hoursFromStart = (timestamp - startingTime) / (1000 * 60 * 60) // Convert to hours
    return {
      time: hoursFromStart,
      value: point.value,
    }
  })

  // Step 3: Filter the data based on the time range
  const filteredData = processedData.filter(
    (point: { time: number }) => point.time >= timeRange[0] && point.time <= timeRange[1],
  )

  return (
    <div className="container mx-auto py-6 space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold tracking-tight">Create Report</h1>
        <Button variant="outline" onClick={() => router.back()}>
          Back
        </Button>
      </div>

      {patient && (
        <Card>
          <CardHeader>
            <CardTitle>Patient Information</CardTitle>
            <CardDescription>Review patient information before creating the report</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <Label>Name</Label>
                <div className="font-medium">{patient.name}</div>
              </div>
              <div>
                <Label>Age</Label>
                <div className="font-medium">{patient.age} years</div>
              </div>
              {/* <div>
                <Label>Gender</Label>
                <div className="font-medium">{patient.gender}</div>
              </div> */}
              <div>
                <Label>Contact Number</Label>
                <div className="font-medium">{patient.contactNumber || "N/A"}</div>
              </div>
              {patient.medicalHistory && (
                <div className="col-span-2">
                  <Label>Medical History</Label>
                  <div className="font-medium">{patient.medicalHistory}</div>
                </div>
              )}
            </div>
          </CardContent>
        </Card>
      )}

      <Card>
        <CardHeader>
          <CardTitle>ECG Data Visualization</CardTitle>
          <CardDescription>Select a time range to analyze the ECG data</CardDescription>
        </CardHeader>
        <CardContent className="space-y-6">
          <div className="h-[300px]">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={ecgData.c1} margin={{ top: 5, right: 30, left: 20, bottom: 5 }}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="time" label={{ value: "Time (hours)", position: "insideBottomRight", offset: -10 }} />
                <YAxis label={{ value: "Heart Rate (bpm)", angle: -90, position: "insideLeft" }} />
                <Tooltip
                  formatter={(value, name) => [`${value} bpm`, name]}
                  labelFormatter={(label) => `Time: ${label} hours`}
                />
                <Legend />
                {/* Line for the first dataset (c1) */}
                <Line
                  type="monotone"
                  dataKey="value"
                  data={ecgData.c1}
                  stroke="#8884d8"
                  dot={false}
                  name="Heart Rate (C1)"
                />
                {/* Line for the second dataset (c2) */}
                <Line
                  type="monotone"
                  dataKey="value"
                  data={ecgData.c2}
                  stroke="#82ca9d"
                  dot={false}
                  name="Heart Rate (C2)"
                />
                {/* Line for the third dataset (c3) */}
                <Line
                  type="monotone"
                  dataKey="value"
                  data={ecgData.c3}
                  stroke="#ff8042"
                  dot={false}
                  name="Heart Rate (C3)"
                />
                <ReferenceArea
                  x1={timeRange[0]}
                  x2={timeRange[1]}
                  strokeOpacity={0.3}
                  fill="#8884d8"
                  fillOpacity={0.1}
                />
              </LineChart>
            </ResponsiveContainer>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label>Start Date & Time</Label>
              <div className="flex flex-col space-y-2">
                <Popover>
                  <PopoverTrigger asChild>
                    <Button variant={"outline"} className="w-full justify-start text-left font-normal">
                      <CalendarIcon className="mr-2 h-4 w-4" />
                      {startDate ? format(startDate, "PPP HH:mm") : <span>Pick a date</span>}
                    </Button>
                  </PopoverTrigger>
                  <PopoverContent className="w-auto p-0">
                    <Calendar mode="single" selected={startDate} onSelect={setStartDate} initialFocus />
                    <div className="p-3 border-t border-border">
                      <Input
                        type="time"
                        value={startDate ? format(startDate, "HH:mm") : ""}
                        onChange={(e) => {
                          if (startDate && e.target.value) {
                            const [hours, minutes] = e.target.value.split(":")
                            const newDate = new Date(startDate)
                            newDate.setHours(Number.parseInt(hours, 10), Number.parseInt(minutes, 10))
                            setStartDate(newDate)
                          }
                        }}
                      />
                    </div>
                  </PopoverContent>
                </Popover>
              </div>
            </div>

            <div className="space-y-2">
              <Label>End Date & Time</Label>
              <div className="flex flex-col space-y-2">
                <Popover>
                  <PopoverTrigger asChild>
                    <Button variant={"outline"} className="w-full justify-start text-left font-normal">
                      <CalendarIcon className="mr-2 h-4 w-4" />
                      {endDate ? format(endDate, "PPP HH:mm") : <span>Pick a date</span>}
                    </Button>
                  </PopoverTrigger>
                  <PopoverContent className="w-auto p-0">
                    <Calendar mode="single" selected={endDate} onSelect={setEndDate} initialFocus />
                    <div className="p-3 border-t border-border">
                      <Input
                        type="time"
                        value={endDate ? format(endDate, "HH:mm") : ""}
                        onChange={(e) => {
                          if (endDate && e.target.value) {
                            const [hours, minutes] = e.target.value.split(":")
                            const newDate = new Date(endDate)
                            newDate.setHours(Number.parseInt(hours, 10), Number.parseInt(minutes, 10))
                            setEndDate(newDate)
                          }
                        }}
                      />
                    </div>
                  </PopoverContent>
                </Popover>
              </div>
            </div>
          </div>

          <div className="flex justify-end">
            <Button
              onClick={() => {
                if (!startDate || !endDate || !ecgData) return

                const startTime = startDate.getTime()
                const endTime = endDate.getTime()

                // Convert to hours from start for filtering
                const startingTime = new Date(ecgData.c1[0].key).getTime()
                const startHours = (startTime - startingTime) / (1000 * 60 * 60)
                const endHours = (endTime - startingTime) / (1000 * 60 * 60)

                // Update timeRange for use in report creation
                setTimeRange([startHours, endHours])

                // Filter data for chart display
                const filtered = processedData.filter(
                  (point: { time: number }) => point.time >= startHours && point.time <= endHours,
                )

                setFilteredChartData(filtered)
                toast.success("Time range filter applied")
              }}
            >
              Apply Filter
            </Button>
          </div>
        </CardContent>
      </Card>

      <form onSubmit={handleSubmit}>
        <Card>
          <CardHeader>
            <CardTitle>Report Details</CardTitle>
            <CardDescription>Fill in the details for the patient's report</CardDescription>
          </CardHeader>
          <CardContent className="space-y-6">
            <div className="space-y-2">
              <Label htmlFor="title">Report Title</Label>
              <Input id="title" name="title" value={reportData.title} onChange={handleInputChange} required />
            </div>

            <div className="space-y-2">
              <Label htmlFor="summary">Report Summary</Label>
              <Textarea
                id="summary"
                name="summary"
                placeholder="Provide a summary of the holter monitor findings"
                value={reportData.summary}
                onChange={handleInputChange}
                rows={4}
                required
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="anomalyDetection">Anomaly Detection</Label>
              <Textarea
                id="anomalyDetection"
                name="anomalyDetection"
                placeholder="Describe any anomalies detected in the ECG data"
                value={reportData.anomalyDetection}
                onChange={handleInputChange}
                rows={4}
                required
              />
            </div>

            <Tabs defaultValue="doctor">
              <TabsList className="grid w-full grid-cols-2">
                <TabsTrigger value="doctor">Doctor Suggestion</TabsTrigger>
                <TabsTrigger value="ai">AI Suggestion</TabsTrigger>
              </TabsList>
              <TabsContent value="doctor" className="space-y-4">
                <div className="space-y-2">
                  <Label htmlFor="doctorSuggestion">Doctor's Suggestion</Label>
                  <Textarea
                    id="doctorSuggestion"
                    name="doctorSuggestion"
                    placeholder="Provide your medical suggestion based on the findings"
                    value={reportData.doctorSuggestion}
                    onChange={handleInputChange}
                    rows={6}
                    required
                  />
                </div>
              </TabsContent>
              <TabsContent value="ai" className="space-y-4">
                <div className="space-y-2">
                  <div className="flex items-center justify-between">
                    <Label htmlFor="aiSuggestion">AI Suggestion</Label>
                    <Button
                      type="button"
                      variant="outline"
                      size="sm"
                      onClick={handleGenerateAISuggestion}
                      disabled={generatingAI || !reportData.summary || !reportData.anomalyDetection}
                    >
                      {generatingAI && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                      {generatingAI ? "Generating..." : "Generate AI Suggestion"}
                    </Button>
                  </div>
                  <Textarea
                    id="aiSuggestion"
                    name="aiSuggestion"
                    placeholder="AI-generated medical suggestion will appear here"
                    value={reportData.aiSuggestion}
                    onChange={handleInputChange}
                    rows={6}
                  />
                  <p className="text-sm text-muted-foreground">
                    Note: AI suggestions are for reference only and should be reviewed by a medical professional.
                  </p>
                </div>
              </TabsContent>
            </Tabs>
          </CardContent>
          <CardFooter className="flex justify-between">
            <Button variant="outline" type="button" onClick={() => router.back()}>
              Cancel
            </Button>
            <Button type="submit" disabled={submitting}>
              {submitting && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
              {submitting ? "Creating Report..." : "Create Report"}
            </Button>
            <Button disabled={submitting} onClick={handleSaveDraft}>
              {submitting && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
              {submitting ? "Saving the draft..." : "Save Draft"}
            </Button>
          </CardFooter>
        </Card>
      </form>
    </div>
  )
}

