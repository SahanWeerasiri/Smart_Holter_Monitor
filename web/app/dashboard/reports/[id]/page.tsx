"use client"

import { useState, useEffect } from "react"
import { useRouter, useParams } from "next/navigation"
import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"
import { Separator } from "@/components/ui/separator"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { ArrowLeft, Download, Printer, Edit, Share } from "lucide-react"
import { getReportById } from "@/lib/firebase/firestore"
import HeartRateChart from "@/components/heart-rate-chart"

interface Report {
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
  status: "draft" | "completed"
  timeRange: { start: number; end: number }
}

export default function ReportDetailPage() {
  const [report, setReport] = useState<Report | null>(null)
  const [loading, setLoading] = useState(true)
  const [activeTab, setActiveTab] = useState("report")
  const router = useRouter()
  const params = useParams()
  const reportId = params.id as string

  useEffect(() => {
    const fetchReport = async () => {
      try {
        const reportData = await getReportById(reportId)
        setReport(reportData)
      } catch (error) {
        console.error("Error fetching report:", error)
      } finally {
        setLoading(false)
      }
    }

    if (reportId) {
      fetchReport()
    }
  }, [reportId])

  const handleEditReport = () => {
    router.push(`/dashboard/reports/edit/${reportId}`)
  }

  const handlePrintReport = () => {
    window.print()
  }

  if (loading) {
    return (
      <div className="flex h-[calc(100vh-4rem)] items-center justify-center">
        <div className="h-8 w-8 animate-spin rounded-full border-4 border-primary border-t-transparent"></div>
      </div>
    )
  }

  if (!report) {
    return (
      <div className="flex h-[calc(100vh-4rem)] items-center justify-center">
        <div className="text-center">
          <h2 className="text-xl font-semibold">Report Not Found</h2>
          <p className="text-muted-foreground">
            The report you're looking for doesn't exist or you don't have permission to view it.
          </p>
          <Button className="mt-4" onClick={() => router.push("/dashboard/reports")}>
            Back to Reports
          </Button>
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2">
          <Button variant="ghost" size="icon" onClick={() => router.back()}>
            <ArrowLeft className="h-4 w-4" />
          </Button>
          <div>
            <h1 className="text-3xl font-bold tracking-tight">{report.title}</h1>
            <p className="text-muted-foreground">Created on {new Date(report.createdAt).toLocaleDateString()}</p>
          </div>
        </div>
        <div className="flex gap-2">
          {report.status === "draft" && (
            <Button variant="outline" onClick={handleEditReport}>
              <Edit className="mr-2 h-4 w-4" />
              Edit Report
            </Button>
          )}
          <Button variant="outline" onClick={handlePrintReport}>
            <Printer className="mr-2 h-4 w-4" />
            Print
          </Button>
          <Button variant="outline">
            <Download className="mr-2 h-4 w-4" />
            Download PDF
          </Button>
          <Button>
            <Share className="mr-2 h-4 w-4" />
            Share
          </Button>
        </div>
      </div>

      <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
        <TabsList className="grid w-full max-w-md grid-cols-2">
          <TabsTrigger value="report">Report</TabsTrigger>
          <TabsTrigger value="data">Heart Rate Data</TabsTrigger>
        </TabsList>
        <TabsContent value="report" className="pt-4">
          <Card>
            <CardContent className="p-6">
              <div className="text-center space-y-2 mb-6">
                <h2 className="text-2xl font-bold">{report.title}</h2>
                <p className="text-muted-foreground">
                  {new Date(report.createdAt).toLocaleDateString()} | Dr. {report.doctorName}
                </p>
              </div>

              <Separator className="my-6" />

              <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
                <div>
                  <h3 className="font-semibold mb-2">Patient Information</h3>
                  <p>
                    <span className="font-medium">Name:</span> {report.patientName}
                  </p>
                  <p>
                    <span className="font-medium">Age/Gender:</span> {report.patientAge} / {report.patientGender}
                  </p>
                </div>
                <div>
                  <h3 className="font-semibold mb-2">Doctor Information</h3>
                  <p>
                    <span className="font-medium">Name:</span> Dr. {report.doctorName}
                  </p>
                  <p>
                    <span className="font-medium">Specialization:</span> {report.doctorSpecialization}
                  </p>
                  <p>
                    <span className="font-medium">Hospital:</span> {report.hospitalName}
                  </p>
                </div>
              </div>

              <div className="space-y-6">
                <div>
                  <h3 className="font-semibold mb-2">Summary</h3>
                  <p>{report.summary || "No summary provided."}</p>
                </div>

                <Separator />

                <div>
                  <h3 className="font-semibold mb-2">Anomaly Detection</h3>
                  <p>{report.anomalyDetection || "No anomalies detected."}</p>
                </div>

                <Separator />

                <div>
                  <h3 className="font-semibold mb-2">Doctor's Suggestion</h3>
                  <p>{report.doctorSuggestion || "No doctor suggestions provided."}</p>
                </div>

                <Separator />

                <div>
                  <h3 className="font-semibold mb-2">AI Suggestion</h3>
                  <p>{report.aiSuggestion || "No AI suggestions generated."}</p>
                </div>

                <Separator />

                <div>
                  <h3 className="font-semibold mb-2">Heart Rate Overview</h3>
                  <div className="h-[300px] w-full">
                    <HeartRateChart timeRange={report.timeRange} />
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </TabsContent>
        <TabsContent value="data" className="pt-4">
          <Card>
            <CardContent className="p-6">
              <div className="space-y-6">
                <div>
                  <h3 className="text-xl font-semibold mb-4">Interactive Heart Rate Data</h3>
                  <p className="text-muted-foreground mb-6">
                    Explore the patient's heart rate data across three channels. You can zoom in on specific time
                    periods by dragging on the chart.
                  </p>
                </div>

                <div className="h-[500px] w-full">
                  <HeartRateChart timeRange={report.timeRange} interactive={true} />
                </div>

                <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mt-6">
                  <div className="p-4 border rounded-lg">
                    <h4 className="font-medium mb-2">Channel 1 - Lead I</h4>
                    <p className="text-sm text-muted-foreground">
                      Records the voltage between the left arm electrode and right arm electrode.
                    </p>
                  </div>
                  <div className="p-4 border rounded-lg">
                    <h4 className="font-medium mb-2">Channel 2 - Lead II</h4>
                    <p className="text-sm text-muted-foreground">
                      Records the voltage between the left leg electrode and right arm electrode.
                    </p>
                  </div>
                  <div className="p-4 border rounded-lg">
                    <h4 className="font-medium mb-2">Channel 3 - Lead III</h4>
                    <p className="text-sm text-muted-foreground">
                      Records the voltage between the left leg electrode and left arm electrode.
                    </p>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  )
}

