"use client"

import { useState, useEffect } from "react"
import { useRouter, useParams } from "next/navigation"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Badge } from "@/components/ui/badge"
import { ArrowLeft, Download, Printer, Share, Calendar, User, Building, AlertCircle, Loader2 } from "lucide-react"
import { getReportById } from "@/lib/firebase/firestore"
import DateTimePicker from "react-datetime-picker";
import "react-datetime-picker/dist/DateTimePicker.css";
import "react-calendar/dist/Calendar.css";
import "react-clock/dist/Clock.css";
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
  ReferenceLine,
} from "recharts"
import { db, logOperation } from "@/lib/firebase/config"
import { collection, doc, getDoc, getDocs } from "firebase/firestore"

export default function ReportDetailPage() {
  const [report, setReport] = useState<ReportData>()
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState("")
  const [activeTab, setActiveTab] = useState("report")
  const router = useRouter()
  const params = useParams()
  const reportId = params.id
  const patientId = params.patientId

  type Value = Date | null;
  const [selectedDateTime, setSelectedDateTime] = useState<Value>(new Date());
  const [endDateTime, setEndDateTime] = useState<Value>(new Date);

  const handleDateTimeChange = (value: Value) => {
    // Only update the state if the value is not null
    if (value) {
      setSelectedDateTime(value);
    }
  };


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
    data: {
      key: string,
      value: number
    }[][]
  }



  useEffect(() => {
    const fetchReport = async () => {
      try {
        setLoading(true)
        console.log(reportId, patientId)

        if (typeof reportId !== 'string' || typeof patientId !== 'string') {
          setLoading(false);
          return;
        }
        console.log(reportId, patientId)
        const reportData = await getReportById(patientId, reportId)
        setReport(reportData)
        setSelectedDateTime(new Date(reportData.data[0][0].key));
        const startDateTime = new Date(reportData.data[0][0].key);

        // Add 10 seconds to the start date and time
        const endDateTime = new Date(startDateTime.getTime() + 10 * 1000); // 10 seconds in milliseconds

        // Set the end date and time in state
        setEndDateTime(endDateTime); console.log("Report", report)
      } catch (error) {
        console.error("Error fetching report:", error)
        setError("Failed to load report data. Please try again.")
      } finally {
        setLoading(false)
      }
    }


    fetchReport()

  }, [reportId, patientId])

  async function getReportById(patientId: string, reportId: string): Promise<ReportData> {
    try {
      logOperation("Getting report by ID", { patientId, reportId })

      const test = await getDocs(collection(db, "user_accounts"))

      logOperation("Report retrieved", { patientId, reportId })
      const reportDoc = await getDoc(doc(db, "user_accounts", patientId, "data", reportId))

      if (!reportDoc.exists()) {
        logOperation("Report not found", { patientId, reportId })
        throw new Error("Report not found")
      }

      const reportData = reportDoc.data()

      // Get patient details
      const patientDoc = await getDoc(doc(db, "user_accounts", patientId))
      if (!patientDoc.exists()) {
        logOperation("Patient not found", { patientId })
        throw new Error("Patient not found")
      }
      const patientData = patientDoc.data()

      // Get doctor details
      let doctorName = "Unknown Doctor"
      let doctorSpecialization = ""
      let hospitalName = "Unknown Hospital"

      if (patientData.docId) {
        const doctorDoc = await getDoc(doc(db, "users", patientData.docId))
        if (doctorDoc.exists()) {
          const doctorData = doctorDoc.data()
          doctorName = doctorData.name
          doctorSpecialization = doctorData.specialization || ""

          // Get hospital details
          if (doctorData.hospitalId) {
            const hospitalDoc = await getDoc(doc(db, "users", doctorData.hospitalId))
            if (hospitalDoc.exists()) {
              hospitalName = hospitalDoc.data().name
            }
          }
        }
      }
      const data = [];
      let count = 0;
      const channels = [reportData.data.c1, reportData.data.c2, reportData.data.c3];
      console.log(channels);
      for (const channel of channels) {
        const keys = channel.key as Array<string>;
        const values = channel.value as Array<number>;
        const temp = [];
        for (let i = 0; i < keys.length; i++) {
          const key = keys[i];
          let value = (values[i]) / 4095 * 5;

          if (count == 2) {
            value = -value + 5;
          }
          // console.log(`Key: ${key}, Value: ${value}`);
          temp.push({ key, value })
        }
        data.push(temp);
        count++;
      }


      const report = {
        id: reportDoc.id,
        title: reportData.title || "Holter Monitor Report",
        patientId: patientId,
        patientName: patientData.name,
        patientAge: reportData.age,
        patientGender: patientData.gender,
        doctorId: patientData.docId,
        doctorName: doctorName,
        doctorSpecialization: doctorSpecialization,
        hospitalName: hospitalName,
        summary: reportData.brief || "",
        anomalyDetection: reportData.anomalies || "",
        doctorSuggestion: reportData.docSuggestions || "",
        aiSuggestion: reportData.aiSuggestions || "",
        createdAt: reportData.timestamp.toDate().toISOString(),
        status: "completed",
        timeRange: reportData.timeRange || { start: 0, end: 24 },
        data: data || []
      }

      logOperation("Report retrieved", { patientId, reportId })
      return report
    } catch (error) {
      logOperation("Error getting report", error)
      throw error
    }
  }

  const handlePrintReport = () => {
    window.print()
  }

  const handleShareReport = () => {
    // In a real app, this would open a sharing dialog
    alert("Sharing functionality would be implemented here")
  }

  const handleDownloadPDF = () => {
    // In a real app, this would generate and download a PDF
    alert("PDF download functionality would be implemented here")
  }

  if (loading) {
    return (
      <div className="flex h-[calc(100vh-4rem)] items-center justify-center">
        <Loader2 className="h-8 w-8 animate-spin text-primary" />
      </div>
    )
  }

  if (error) {
    return (
      <div className="flex h-[calc(100vh-4rem)] flex-col items-center justify-center gap-4">
        <AlertCircle className="h-12 w-12 text-destructive" />
        <h2 className="text-xl font-semibold">Error Loading Report</h2>
        <p className="text-muted-foreground">{error}</p>
        <Button onClick={() => router.push("/dashboard/reports")}>Back to Reports</Button>
      </div>
    )
  }

  if (!report) {
    return (
      <div className="flex h-[calc(100vh-4rem)] flex-col items-center justify-center gap-4">
        <AlertCircle className="h-12 w-12 text-muted-foreground" />
        <h2 className="text-xl font-semibold">Report Not Found</h2>
        <p className="text-muted-foreground">
          The report you're looking for doesn't exist or you don't have permission to view it.
        </p>
        <Button onClick={() => router.push("/dashboard/reports")}>Back to Reports</Button>
      </div>
    )
  }

  // Format the created date
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

  return (
    <div className="space-y-6 print:space-y-4">
      <div className="flex items-center justify-between print:hidden">
        <div className="flex items-center gap-2">
          <Button variant="ghost" size="icon" onClick={() => router.back()}>
            <ArrowLeft className="h-4 w-4" />
          </Button>
          <div>
            <h1 className="text-3xl font-bold tracking-tight">{report.title}</h1>
            <p className="text-muted-foreground">Created on {formatDate(report.createdAt)}</p>
          </div>
        </div>
        <div className="flex gap-2">
          <Button variant="outline" onClick={handlePrintReport}>
            <Printer className="mr-2 h-4 w-4" />
            Print
          </Button>
          <Button variant="outline" onClick={handleDownloadPDF}>
            <Download className="mr-2 h-4 w-4" />
            Download PDF
          </Button>
          <Button variant="outline" onClick={handleShareReport}>
            <Share className="mr-2 h-4 w-4" />
            Share
          </Button>
        </div>
      </div>

      <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full print:hidden">
        {/* <TabsList className="grid w-full max-w-md grid-cols-2">
          <TabsTrigger value="report">Report</TabsTrigger>
          {/* <TabsTrigger value="data">Heart Rate Data</TabsTrigger> 
        </TabsList> */}

        <TabsContent value="report" className="pt-4 space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 print:gap-4">
            <Card className="print:shadow-none">
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <User className="h-5 w-5 text-primary" />
                  Patient Information
                </CardTitle>
              </CardHeader>
              <CardContent>
                <dl className="space-y-2">
                  <div>
                    <dt className="font-medium text-muted-foreground">Name</dt>
                    <dd className="text-lg">{report.patientName}</dd>
                  </div>
                  <div className="grid grid-cols-2 gap-2">
                    <div>
                      <dt className="font-medium text-muted-foreground">Age</dt>
                      <dd>{report.patientAge} years</dd>
                    </div>
                    <div>
                      <dt className="font-medium text-muted-foreground">Gender</dt>
                      <dd>{report.patientGender}</dd>
                    </div>
                  </div>
                </dl>
              </CardContent>
            </Card>

            <Card className="print:shadow-none">
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Building className="h-5 w-5 text-primary" />
                  Doctor Information
                </CardTitle>
              </CardHeader>
              <CardContent>
                <dl className="space-y-2">
                  <div>
                    <dt className="font-medium text-muted-foreground">Name</dt>
                    <dd className="text-lg">Dr. {report.doctorName}</dd>
                  </div>
                  <div>
                    <dt className="font-medium text-muted-foreground">Specialization</dt>
                    <dd>{report.doctorSpecialization}</dd>
                  </div>
                  <div>
                    <dt className="font-medium text-muted-foreground">Hospital</dt>
                    <dd>{report.hospitalName}</dd>
                  </div>
                </dl>
              </CardContent>
            </Card>

            <Card className="print:shadow-none">
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Calendar className="h-5 w-5 text-primary" />
                  Report Details
                </CardTitle>
              </CardHeader>
              <CardContent>
                <dl className="space-y-2">
                  <div>
                    <dt className="font-medium text-muted-foreground">Created</dt>
                    <dd>{formatDate(report.createdAt)}</dd>
                  </div>
                  <div>
                    <dt className="font-medium text-muted-foreground">Status</dt>
                    <dd>
                      <Badge variant="outline" className="bg-green-50 text-green-700">
                        {report.status}
                      </Badge>
                    </dd>
                  </div>
                  <div>
                    <dt className="font-medium text-muted-foreground">Time Range</dt>
                    <dd>
                      {report.timeRange.start} - {report.timeRange.end} hours
                    </dd>
                  </div>
                </dl>
              </CardContent>
            </Card>
          </div>

          <Card className="print:shadow-none">
            <CardHeader>
              <CardTitle>Heart Rate Overview</CardTitle>
              {/* <CardDescription>
                Selected time period: {report.timeRange.start} - {report.timeRange.end} hours
              </CardDescription> */}
              <Card className="print:shadow-none">
                <CardHeader>
                  <CardTitle>Select the start time</CardTitle>
                </CardHeader>
                <CardContent>
                  {/*Add a date time picker. the picker should be able to select the time until the second */}
                  <DateTimePicker
                    onChange={setSelectedDateTime} // Update the selected date and time
                    value={selectedDateTime} // Set the current value
                    format="y-MM-dd HH:mm:ss" // Display format with seconds
                    clearIcon={null} // Remove the clear icon (optional)
                    disableClock={false} // Enable the clock for time selection
                    className="w-full" // Make the picker take full width
                  />
                </CardContent>
              </Card>
            </CardHeader>
            <CardContent>
              <div className="h-[900px] w-full">
                {/* <ResponsiveContainer width="100%" height="33%">
                  <LineChart data={report.data[0] || []} margin={{ top: 5, right: 30, left: 20, bottom: 5 }}>
                    <CartesianGrid strokeDasharray="3 3" stroke="#ff0000" />
                    <XAxis
                      dataKey="time"
                      label={{ value: "Time (seconds)", position: "insideBottomRight", offset: -10 }}
                    />
                    <YAxis label={{ value: "Voltage (V)", angle: -90, position: "insideLeft" }} />
                    <Tooltip
                      formatter={(value) => [`${value}`, "Heart Rate (Channel 01)"]}
                      labelFormatter={(label) => `Time: ${label} hours`}
                    />
                    <Legend />
                    <Line
                      type="monotone"
                      dataKey="value"
                      stroke="#000000"
                      dot={false}
                      activeDot={{ r: 8 }}
                      name="Heart Rate (Channel 01)"
                    />
                    {report.data &&
                      report.data
                        .map((point, index) => (
                          <ReferenceLine key={index} x={point[0].key} stroke="#000000" strokeDasharray="3 3" />
                        ))}
                  </LineChart>
                </ResponsiveContainer> */}
                <ResponsiveContainer width="100%" height="33%">
                  <LineChart
                    data={
                      report.data[0]
                        ? report.data[0].filter((point) => {
                          const pointTime = new Date(point.key).getTime(); // Convert point time to timestamp
                          return (
                            pointTime >= selectedDateTime!.getTime() && // Check if point is after or equal to startTime
                            pointTime <= endDateTime!.getTime() // Check if point is before or equal to endTime
                          );
                        })
                        : []
                    }
                    margin={{ top: 5, right: 30, left: 20, bottom: 5 }}
                  >
                    <CartesianGrid strokeDasharray="3 3" stroke="#ff0000" />
                    <XAxis
                      dataKey="time"
                      label={{ value: "Time (seconds)", position: "insideBottomRight", offset: -10 }}
                    />
                    <YAxis label={{ value: "Voltage (V)", angle: -90, position: "insideLeft" }} />
                    <Tooltip
                      formatter={(value) => [`${value}`, "Heart Rate (Channel 01)"]}
                      labelFormatter={(label) => `Time: ${label} hours`}
                    />
                    <Legend />
                    <Line
                      type="monotone"
                      dataKey="value"
                      stroke="#000000"
                      dot={false}
                      activeDot={{ r: 8 }}
                      name="Heart Rate (Channel 01)"
                    />
                    {report.data &&
                      report.data
                        .filter((point) => {
                          const pointTime = new Date(point[0].key).getTime(); // Convert point time to timestamp
                          return (
                            pointTime >= selectedDateTime!.getTime() && // Check if point is after or equal to startTime
                            pointTime <= endDateTime!.getTime() // Check if point is before or equal to endTime
                          );
                        })
                        .map((point, index) => (
                          <ReferenceLine key={index} x={point[0].key} stroke="#000000" strokeDasharray="3 3" />
                        ))}
                  </LineChart>
                </ResponsiveContainer>
                <ResponsiveContainer width="100%" height="33%">
                  <LineChart data={report.data[1] || []} margin={{ top: 5, right: 30, left: 20, bottom: 5 }}>
                    <CartesianGrid strokeDasharray="3 3" stroke="#ff0000" />
                    <XAxis
                      dataKey="time"
                      label={{ value: "Time (seconds)", position: "insideBottomRight", offset: -10 }}
                    />
                    <YAxis label={{ value: "Voltage (V)", angle: -90, position: "insideLeft" }} />
                    <Tooltip
                      formatter={(value) => [`${value}`, "Heart Rate (Channel 02)"]}
                      labelFormatter={(label) => `Time: ${label} hours`}
                    />
                    <Legend />
                    <Line
                      type="monotone"
                      dataKey="value"
                      stroke="#000000"
                      dot={false}
                      activeDot={{ r: 8 }}
                      name="Heart Rate (Channel 02)"
                    />
                    {report.data &&
                      report.data
                        .map((point, index) => (
                          <ReferenceLine key={index} x={point[0].key} stroke="#000000" strokeDasharray="3 3" />
                        ))}
                  </LineChart>
                </ResponsiveContainer>
                <ResponsiveContainer width="100%" height="33%">
                  <LineChart data={report.data[2] || []} margin={{ top: 5, right: 30, left: 20, bottom: 5 }}>
                    <CartesianGrid strokeDasharray="3 3" stroke="#ff0000" />
                    <XAxis
                      dataKey="time"
                      label={{ value: "Time (seconds)", position: "insideBottomRight", offset: -10 }}
                    />
                    <YAxis label={{ value: "Voltage(V)", angle: -90, position: "insideLeft" }} />
                    <Tooltip
                      formatter={(value) => [`${value}`, "Heart Rate (Channel 03)"]}
                      labelFormatter={(label) => `Time: ${label} hours`}
                    />
                    <Legend />
                    <Line
                      type="monotone"
                      dataKey="value"
                      stroke="#000000"
                      dot={false}
                      activeDot={{ r: 8 }}
                      name="Heart Rate (Channel 03)"
                    />
                    {report.data &&
                      report.data
                        .map((point, index) => (
                          <ReferenceLine key={index} x={point[0].key} stroke="#000000" strokeDasharray="3 3" />
                        ))}
                  </LineChart>
                </ResponsiveContainer>
              </div>
            </CardContent>
          </Card>

          <div className="grid grid-cols-1 gap-6">
            <Card className="print:shadow-none">
              <CardHeader>
                <CardTitle>Report Summary</CardTitle>
              </CardHeader>
              <CardContent>
                <p className="whitespace-pre-line">{report.summary}</p>
              </CardContent>
            </Card>

            <Card className="print:shadow-none">
              <CardHeader>
                <CardTitle>Anomaly Detection</CardTitle>
              </CardHeader>
              <CardContent>
                <p className="whitespace-pre-line">{report.anomalyDetection}</p>
              </CardContent>
            </Card>

            <Card className="print:shadow-none">
              <CardHeader>
                <CardTitle>Doctor's Suggestion</CardTitle>
              </CardHeader>
              <CardContent>
                <p className="whitespace-pre-line">{report.doctorSuggestion}</p>
              </CardContent>
            </Card>

            {report.aiSuggestion && (
              <Card className="print:shadow-none">
                <CardHeader>
                  <CardTitle>AI Suggestion</CardTitle>
                  <CardDescription>AI-generated recommendations based on the report data</CardDescription>
                </CardHeader>
                <CardContent>
                  <p className="whitespace-pre-line">{report.aiSuggestion}</p>
                  <p className="mt-4 text-sm text-muted-foreground">
                    Note: AI suggestions are for reference only and should be reviewed by a medical professional.
                  </p>
                </CardContent>
              </Card>
            )}
          </div>
        </TabsContent>

        {/* <TabsContent value="data" className="pt-4 space-y-6">
          <Card className="print:shadow-none">
            <CardHeader>
              <CardTitle>Interactive Heart Rate Data</CardTitle>
              <CardDescription>Explore the patient's heart rate data across the monitoring period</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="h-[500px] w-full">
                <ResponsiveContainer width="100%" height="100%">
                  <LineChart data={report.data || []} margin={{ top: 5, right: 30, left: 20, bottom: 5 }}>
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis
                      dataKey="time"
                      label={{ value: "Time (hours)", position: "insideBottomRight", offset: -10 }}
                    />
                    <YAxis
                      label={{ value: "Heart Rate", angle: -90, position: "insideLeft" }}
                      domain={["dataMin - 10", "dataMax + 10"]}
                    />
                    <Tooltip
                      formatter={(value, name, props) => {
                        if (props.payload.isAnomaly) {
                          return [`${value} (Anomaly)`, "Heart Rate"]
                        }
                        return [`${value}`, "Heart Rate"]
                      }}
                      labelFormatter={(label) => `Time: ${label} hours`}
                    />
                    <Legend />
                    <Line
                      type="monotone"
                      dataKey="value"
                      stroke="#8884d8"
                      dot={(props) => {
                        if (props.payload.isAnomaly) {
                          return <circle cx={props.cx} cy={props.cy} r={4} fill="red" stroke="none" />
                        }
                        return <circle cx={props.cx} cy={props.cy} r={4} fill="#8884d8" stroke="none" />
                      }}
                      activeDot={{ r: 8 }}
                      name="Heart Rate"
                    />
                    {report.data &&
                      report.data
                        .map((point, index) => (
                          <ReferenceLine key={index} x={point[0].key} stroke="red" strokeDasharray="3 3" />
                        ))}
                  </LineChart>
                </ResponsiveContainer>
              </div>

              <div className="mt-8 grid grid-cols-1 md:grid-cols-3 gap-4">
                <Card>
                  <CardHeader className="pb-2">
                    <CardTitle className="text-sm">Understanding the Data</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <p className="text-sm">
                      This chart shows the patient's heart rate over time. Red dots and lines indicate potential
                      anomalies that were detected during monitoring.
                    </p>
                  </CardContent>
                </Card>

                <Card>
                  <CardHeader className="pb-2">
                    <CardTitle className="text-sm">Normal Range</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <p className="text-sm">
                      For adults, a normal resting heart rate typically ranges from 60 to 100 beats per minute. Athletes
                      may have lower resting heart rates.
                    </p>
                  </CardContent>
                </Card>

                <Card>
                  <CardHeader className="pb-2">
                    <CardTitle className="text-sm">Interaction Tips</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <p className="text-sm">
                      Hover over the chart to see detailed values. Click and drag to zoom into specific time periods.
                      Double-click to reset the zoom.
                    </p>
                  </CardContent>
                </Card>
              </div>
            </CardContent>
          </Card>

          <Card className="print:shadow-none">
            <CardHeader>
              <CardTitle>Statistical Analysis</CardTitle>
              <CardDescription>Key metrics derived from the heart rate data</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
                <Card>
                  <CardContent className="pt-6">
                    <div className="text-center">
                      <div className="text-2xl font-bold">
                        {report.data
                          ? Math.round(report.data.reduce((sum, point) => sum + point[0].value, 0) / report.data.length)
                          : 0}
                      </div>
                      <p className="text-sm text-muted-foreground">Average Heart Rate (bpm)</p>
                    </div>
                  </CardContent>
                </Card>

                <Card>
                  <CardContent className="pt-6">
                    <div className="text-center">
                      <div className="text-2xl font-bold">
                        {report.data ? Math.max(...report.data.map((point) => point[0].value)) : 0}
                      </div>
                      <p className="text-sm text-muted-foreground">Maximum Heart Rate (bpm)</p>
                    </div>
                  </CardContent>
                </Card>

                <Card>
                  <CardContent className="pt-6">
                    <div className="text-center">
                      <div className="text-2xl font-bold">
                        {report.data ? Math.min(...report.data.map((point) => point[0].value)) : 0}
                      </div>
                      <p className="text-sm text-muted-foreground">Minimum Heart Rate (bpm)</p>
                    </div>
                  </CardContent>
                </Card>

                {/* <Card>
                  <CardContent className="pt-6">
                    <div className="text-center">
                      <div className="text-2xl font-bold">
                        {report.data ? report.data.filter((point) => point.).length : 0}
                      </div>
                      <p className="text-sm text-muted-foreground">Anomalies Detected</p>
                    </div>
                  </CardContent>
                </Card> 
              </div>
            </CardContent>
          </Card>
        </TabsContent> */}
      </Tabs>
    </div>
  )
}

