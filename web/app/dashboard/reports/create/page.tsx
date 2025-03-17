"use client"

import { useState, useEffect, SetStateAction } from "react"
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
import { Slider } from "@/components/ui/slider"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { getPatientById, createReport, generateAIReportSuggestion, saveReport, getLatestReport } from "@/lib/firebase/firestore"
import { Loader2 } from "lucide-react"

// Sample ECG data generator function
const generateSampleECGData = (hours = 24, anomalyPoints: number[] = []) => {
  const data = []
  const pointsPerHour = 60 // One point per minute

  for (let h = 0; h < hours; h++) {
    for (let m = 0; m < pointsPerHour; m++) {
      const time = h + m / pointsPerHour
      const isAnomaly = anomalyPoints.some((point) => Math.abs(point - time) < 0.05)

      // Base value with some natural variation
      let value = 70 + Math.sin(time * 0.5) * 5 + (Math.random() * 10 - 5)

      // Add anomaly if this is an anomaly point
      if (isAnomaly) {
        value = value + (Math.random() > 0.5 ? 40 : -30)
      }

      data.push({
        time: time.toFixed(2),
        value: Math.round(value),
        isAnomaly,
      })
    }
  }

  return data
}

export default function CreateReportPage() {
  const router = useRouter()
  const searchParams = useSearchParams()
  const patientId = searchParams.get("patientId")

  const [loading, setLoading] = useState(true)
  const [submitting, setSubmitting] = useState(false)
  const [generatingAI, setGeneratingAI] = useState(false)
  const [patient, setPatient] = useState<Patient>()
  const [reportData, setReportData] = useState<ReportData>(
    {
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
    }

  )
  const [timeRange, setTimeRange] = useState([0, 24])
  const [ecgData, setEcgData] = useState<Data[]>([])
  const [anomalyPoints, setAnomalyPoints] = useState<number[]>([4, 9, 15, 20])

  // const [report/Data, setReportData] = useState<>()

  interface ReportData {
    id: string,
    title: string,
    patientId: string,
    patientName: string,
    patientAge: number,
    patientGender: string,
    doctorId: string,
    doctorName: string,
    doctorSpecialization: string,
    hospitalName: string,
    summary: string,
    anomalyDetection: string,
    doctorSuggestion: string,
    aiSuggestion: string
    createdAt: string,
    status: string,
    timeRange: { start: number, end: number },
    data: Data[]
  }
  interface Patient {
    id: string;
    name: any;
    age: any;
    gender: any;
    contactNumber: any;
    medicalHistory: any;
    status: string;
    emergencyContact: {
      name: string;
      mobile: string;
    };
  }

  interface Data {
    time: string;
    value: number;
  }[]

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



        // Generate sample ECG data
        // const data = generateSampleECGData(24, anomalyPoints)
        // setEcgData(data)
        setEcgData(reportData.data)

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

  const handleTimeRangeChange = (values: SetStateAction<number[]>) => {
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
      // Filter ECG data based on selected time range
      const filteredData = ecgData.filter(
        (point) => Number.parseFloat(point.time) >= timeRange[0] && Number.parseFloat(point.time) <= timeRange[1],
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
        isDone: true
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
      // Filter ECG data based on selected time range
      const filteredData = ecgData.filter(
        (point) => Number.parseFloat(point.time) >= timeRange[0] && Number.parseFloat(point.time) <= timeRange[1],
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

  // Filter data based on selected time range for display
  const displayData = ecgData.filter(
    (point) => Number.parseFloat(point.time) >= timeRange[0] && Number.parseFloat(point.time) <= timeRange[1],
  )

  // Count anomalies in the selected range
  // const anomaliesInRange = displayData.filter((point) => point.isAnomaly).length

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
              <div>
                <Label>Gender</Label>
                <div className="font-medium">{patient.gender}</div>
              </div>
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
              <LineChart data={ecgData} margin={{ top: 5, right: 30, left: 20, bottom: 5 }}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="time" label={{ value: "Time (hours)", position: "insideBottomRight", offset: -10 }} />
                <YAxis label={{ value: "Heart Rate (bpm)", angle: -90, position: "insideLeft" }} />
                <Tooltip
                  formatter={(value, name) => [`${value} bpm`, "Heart Rate"]}
                  labelFormatter={(label) => `Time: ${label} hours`}
                />
                <Legend />
                <Line type="monotone" dataKey="value" stroke="#8884d8" dot={false} name="Heart Rate" />
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

          <div className="space-y-2">
            <div className="flex justify-between">
              <Label>Time Range Selection</Label>
              <span className="text-sm text-muted-foreground">
                {timeRange[0]} - {timeRange[1]} hours
              </span>
            </div>
            <Slider
              defaultValue={[0, 24]}
              max={24}
              step={0.5}
              value={timeRange}
              onValueChange={handleTimeRangeChange}
            />
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <Card>
              <CardHeader className="p-4">
                <CardTitle className="text-base">Selected Duration</CardTitle>
              </CardHeader>
              <CardContent className="p-4 pt-0">
                <div className="text-2xl font-bold">{timeRange[1] - timeRange[0]} hours</div>
              </CardContent>
            </Card>

            {/* <Card>
              <CardHeader className="p-4">
                <CardTitle className="text-base">Anomalies Detected</CardTitle>
              </CardHeader>
              <CardContent className="p-4 pt-0">
                <div className="text-2xl font-bold">{anomaliesInRange}</div>
              </CardContent>
            </Card> */}

            <Card>
              <CardHeader className="p-4">
                <CardTitle className="text-base">Average Heart Rate</CardTitle>
              </CardHeader>
              <CardContent className="p-4 pt-0">
                <div className="text-2xl font-bold">
                  {displayData.length > 0
                    ? Math.round(displayData.reduce((sum, point) => sum + point.value, 0) / displayData.length)
                    : 0}{" "}
                  bpm
                </div>
              </CardContent>
            </Card>
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

