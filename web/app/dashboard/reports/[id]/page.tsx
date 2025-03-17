"use client"

import { useState, useEffect } from "react"
import { useRouter, useParams, useSearchParams } from "next/navigation"
import { format } from "date-fns"
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
  ReferenceLine,
} from "recharts"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Separator } from "@/components/ui/separator"
import { getReportById } from "@/lib/firebase/firestore"
import { Loader2, Printer, ArrowLeft, Download } from "lucide-react"

export default function ViewReportPage() {
  const router = useRouter()
  const params = useParams()
  const searchParams = useSearchParams()
  const reportId = params.reportId as string
  const patientId = searchParams.get("patientId")

  const [loading, setLoading] = useState(true)
  const [report, setReport] = useState<Report>()

  interface Report {
    id: string
    title: string
    patientName: string
    patientAge: number
    patientGender: string
    doctorName: string
    doctorSpecialization: string
    hospitalName: string
    timeRange: {
      start: number
      end: number
    }
    data: {
      time: number
      value: number
      isAnomaly: boolean
    }[]
    summary: string
    anomalyDetection: string
    doctorSuggestion: string
    aiSuggestion: string
    createdAt: string
  }


  useEffect(() => {
    const fetchReport = async () => {
      if (!reportId || !patientId) {
        toast.error("Report ID and Patient ID are required")
        router.push("/dashboard/doctor/reports")
        return
      }

      try {
        const reportData = await getReportById(patientId, reportId)
        setReport(reportData)
        setLoading(false)
      } catch (error) {
        console.error("Error fetching report:", error)
        toast.error("Failed to fetch report")
        setLoading(false)
      }
    }

    fetchReport()
  }, [reportId, patientId, router])

  const handlePrint = () => {
    window.print()
  }

  if (loading) {
    return (
      <div className="flex h-[calc(100vh-4rem)] items-center justify-center">
        <Loader2 className="h-8 w-8 animate-spin text-primary" />
      </div>
    )
  }

  if (!report) {
    return (
      <div className="container mx-auto py-6">
        <div className="flex flex-col items-center justify-center h-[calc(100vh-8rem)]">
          <h2 className="text-xl font-semibold mb-2">Report Not Found</h2>
          <p className="text-muted-foreground mb-4">The requested report could not be found.</p>
          <Button onClick={() => router.push("/dashboard/doctor/reports")}>Back to Reports</Button>
        </div>
      </div>
    )
  }

  // Format the created date
  const formattedDate = format(new Date(report.createdAt), "PPP")

  return (
    <div className="container mx-auto py-6 space-y-6 print:py-2 print:space-y-4">
      <div className="flex items-center justify-between print:hidden">
        <div className="flex items-center gap-2">
          <Button variant="outline" size="icon" onClick={() => router.back()}>
            <ArrowLeft className="h-4 w-4" />
          </Button>
          <h1 className="text-2xl font-bold tracking-tight">View Report</h1>
        </div>
        <div className="flex gap-2">
          <Button variant="outline" onClick={handlePrint}>
            <Printer className="mr-2 h-4 w-4" />
            Print Report
          </Button>
          <Button>
            <Download className="mr-2 h-4 w-4" />
            Download PDF
          </Button>
        </div>
      </div>

      <div className="print:hidden hidden md:block">
        <Separator />
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 print:gap-4 print:grid-cols-3">
        <Card className="md:col-span-3 print:shadow-none">
          <CardHeader className="print:py-2">
            <div className="flex flex-col md:flex-row md:justify-between md:items-center gap-2">
              <div>
                <CardTitle className="text-2xl print:text-xl">{report.title}</CardTitle>
                <CardDescription>Generated on {formattedDate}</CardDescription>
              </div>
              <div className="print:hidden">
                <Button variant="outline" size="sm">
                  Edit Report
                </Button>
              </div>
            </div>
          </CardHeader>
        </Card>

        <Card className="print:shadow-none">
          <CardHeader className="print:py-2">
            <CardTitle className="text-lg print:text-base">Patient Information</CardTitle>
          </CardHeader>
          <CardContent className="print:pt-0">
            <dl className="space-y-2 print:space-y-1">
              <div className="flex justify-between">
                <dt className="font-medium text-muted-foreground">Name:</dt>
                <dd>{report.patientName}</dd>
              </div>
              <div className="flex justify-between">
                <dt className="font-medium text-muted-foreground">Age:</dt>
                <dd>{report.patientAge} years</dd>
              </div>
              <div className="flex justify-between">
                <dt className="font-medium text-muted-foreground">Gender:</dt>
                <dd>{report.patientGender}</dd>
              </div>
            </dl>
          </CardContent>
        </Card>

        <Card className="print:shadow-none">
          <CardHeader className="print:py-2">
            <CardTitle className="text-lg print:text-base">Doctor Information</CardTitle>
          </CardHeader>
          <CardContent className="print:pt-0">
            <dl className="space-y-2 print:space-y-1">
              <div className="flex justify-between">
                <dt className="font-medium text-muted-foreground">Name:</dt>
                <dd>{report.doctorName}</dd>
              </div>
              <div className="flex justify-between">
                <dt className="font-medium text-muted-foreground">Specialization:</dt>
                <dd>{report.doctorSpecialization || "Cardiology"}</dd>
              </div>
              <div className="flex justify-between">
                <dt className="font-medium text-muted-foreground">Hospital:</dt>
                <dd>{report.hospitalName}</dd>
              </div>
            </dl>
          </CardContent>
        </Card>

        <Card className="print:shadow-none">
          <CardHeader className="print:py-2">
            <CardTitle className="text-lg print:text-base">Report Details</CardTitle>
          </CardHeader>
          <CardContent className="print:pt-0">
            <dl className="space-y-2 print:space-y-1">
              <div className="flex justify-between">
                <dt className="font-medium text-muted-foreground">Report ID:</dt>
                <dd className="font-mono">{report.id.substring(0, 8)}</dd>
              </div>
              <div className="flex justify-between">
                <dt className="font-medium text-muted-foreground">Created:</dt>
                <dd>{formattedDate}</dd>
              </div>
              <div className="flex justify-between">
                <dt className="font-medium text-muted-foreground">Time Range:</dt>
                <dd>
                  {report.timeRange.start} - {report.timeRange.end} hours
                </dd>
              </div>
            </dl>
          </CardContent>
        </Card>

        <Card className="md:col-span-3 print:shadow-none">
          <CardHeader className="print:py-2">
            <CardTitle className="text-lg print:text-base">ECG Data Visualization</CardTitle>
          </CardHeader>
          <CardContent className="print:pt-0">
            <div className="h-[300px] print:h-[200px]">
              {report.data && report.data.length > 0 ? (
                <ResponsiveContainer width="100%" height="100%">
                  <LineChart data={report.data} margin={{ top: 5, right: 30, left: 20, bottom: 5 }}>
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis
                      dataKey="time"
                      label={{ value: "Time (hours)", position: "insideBottomRight", offset: -10 }}
                    />
                    <YAxis label={{ value: "Heart Rate (bpm)", angle: -90, position: "insideLeft" }} />
                    <Tooltip
                      formatter={(value, name) => [`${value} bpm`, "Heart Rate"]}
                      labelFormatter={(label) => `Time: ${label} hours`}
                    />
                    <Legend />
                    <Line type="monotone" dataKey="value" stroke="#8884d8" dot={false} name="Heart Rate" />
                    {report.data
                      .filter((point) => point.isAnomaly)
                      .map((point, index) => (
                        <ReferenceLine key={index} x={point.time} stroke="red" strokeDasharray="3 3" />
                      ))}
                  </LineChart>
                </ResponsiveContainer>
              ) : (
                <div className="flex items-center justify-center h-full">
                  <p className="text-muted-foreground">No ECG data available</p>
                </div>
              )}
            </div>
          </CardContent>
        </Card>

        <Card className="md:col-span-3 print:shadow-none">
          <CardHeader className="print:py-2">
            <CardTitle className="text-lg print:text-base">Report Summary</CardTitle>
          </CardHeader>
          <CardContent className="print:pt-0">
            <p className="whitespace-pre-line">{report.summary}</p>
          </CardContent>
        </Card>

        <Card className="md:col-span-3 print:shadow-none">
          <CardHeader className="print:py-2">
            <CardTitle className="text-lg print:text-base">Anomaly Detection</CardTitle>
          </CardHeader>
          <CardContent className="print:pt-0">
            <p className="whitespace-pre-line">{report.anomalyDetection}</p>
          </CardContent>
        </Card>

        <Card className="md:col-span-3 print:shadow-none">
          <CardHeader className="print:py-2">
            <CardTitle className="text-lg print:text-base">Medical Suggestions</CardTitle>
          </CardHeader>
          <CardContent className="print:pt-0">
            <Tabs defaultValue="doctor" className="print:hidden">
              <TabsList className="grid w-full grid-cols-2">
                <TabsTrigger value="doctor">Doctor's Suggestion</TabsTrigger>
                <TabsTrigger value="ai">AI Suggestion</TabsTrigger>
              </TabsList>
              <TabsContent value="doctor" className="pt-4">
                <p className="whitespace-pre-line">{report.doctorSuggestion}</p>
              </TabsContent>
              <TabsContent value="ai" className="pt-4">
                <p className="whitespace-pre-line">{report.aiSuggestion || "No AI suggestion available."}</p>
                <p className="text-sm text-muted-foreground mt-4">
                  Note: AI suggestions are for reference only and should be reviewed by a medical professional.
                </p>
              </TabsContent>
            </Tabs>

            <div className="hidden print:block space-y-4">
              <div>
                <h3 className="font-semibold mb-2">Doctor's Suggestion</h3>
                <p className="whitespace-pre-line">{report.doctorSuggestion}</p>
              </div>

              {report.aiSuggestion && (
                <div>
                  <h3 className="font-semibold mb-2">AI Suggestion</h3>
                  <p className="whitespace-pre-line">{report.aiSuggestion}</p>
                  <p className="text-sm text-muted-foreground mt-2">
                    Note: AI suggestions are for reference only and should be reviewed by a medical professional.
                  </p>
                </div>
              )}
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}

