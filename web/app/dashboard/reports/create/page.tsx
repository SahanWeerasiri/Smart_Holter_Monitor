"use client"

import { useState, useEffect } from "react"
import { useRouter, useSearchParams } from "next/navigation"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { Label } from "@/components/ui/label"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Separator } from "@/components/ui/separator"
import { AlertCircle, Save, FileText, ArrowLeft, Sparkles } from "lucide-react"
import { Alert, AlertDescription } from "@/components/ui/alert"
import { getPatientById, getDoctorDetails, createReport, generateAIReportSuggestion } from "@/lib/firebase/firestore"
import HeartRateChart from "@/components/heart-rate-chart"

interface Patient {
  id: string
  name: string
  age: number
  gender: string
  contactNumber: string
  medicalHistory: string
}

interface Doctor {
  id: string
  name: string
  email: string
  specialization: string
  hospitalName: string
}

export default function CreateReportPage() {
  const [patient, setPatient] = useState<Patient | null>(null)
  const [doctor, setDoctor] = useState<Doctor | null>(null)
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState("")
  const [activeTab, setActiveTab] = useState("editor")
  const [timeRange, setTimeRange] = useState({ start: 0, end: 24 })
  const [generatingAI, setGeneratingAI] = useState(false)

  const [reportData, setReportData] = useState({
    title: "",
    summary: "",
    anomalyDetection: "",
    doctorSuggestion: "",
    aiSuggestion: "",
  })

  const router = useRouter()
  const searchParams = useSearchParams()
  const patientId = searchParams.get("patientId")

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true)

        // Get doctor details
        const doctorData = await getDoctorDetails()
        setDoctor(doctorData)

        // If patientId is provided, fetch patient details
        if (patientId) {
          const patientData = await getPatientById(patientId)
          setPatient(patientData)
          setReportData((prev) => ({
            ...prev,
            title: `Holter Monitor Report - ${patientData.name}`,
          }))
        }
      } catch (error) {
        console.error("Error fetching data:", error)
        setError("Failed to load data. Please try again.")
      } finally {
        setLoading(false)
      }
    }

    fetchData()
  }, [patientId])

  const handleSaveReport = async (isDraft = true) => {
    try {
      setSaving(true)

      if (!reportData.title) {
        setError("Report title is required")
        return
      }

      if (!patient) {
        setError("Patient information is required")
        return
      }

      const reportId = await createReport({
        title: reportData.title,
        patientId: patient.id,
        doctorId: doctor?.id,
        summary: reportData.summary,
        anomalyDetection: reportData.anomalyDetection,
        doctorSuggestion: reportData.doctorSuggestion,
        aiSuggestion: reportData.aiSuggestion,
        status: isDraft ? "draft" : "completed",
        timeRange,
      })

      router.push(`/dashboard/reports/${reportId}`)
    } catch (error) {
      console.error("Error saving report:", error)
      setError("Failed to save report. Please try again.")
    } finally {
      setSaving(false)
    }
  }

  const handleGenerateAISuggestion = async () => {
    try {
      setGeneratingAI(true)

      if (!patient) {
        setError("Patient information is required for AI suggestion")
        return
      }

      const aiSuggestion = await generateAIReportSuggestion({
        patientData: patient,
        reportSummary: reportData.summary,
        anomalyDetection: reportData.anomalyDetection,
      })

      setReportData((prev) => ({
        ...prev,
        aiSuggestion,
      }))
    } catch (error) {
      console.error("Error generating AI suggestion:", error)
      setError("Failed to generate AI suggestion. Please try again.")
    } finally {
      setGeneratingAI(false)
    }
  }

  if (loading) {
    return (
      <div className="flex h-[calc(100vh-4rem)] items-center justify-center">
        <div className="h-8 w-8 animate-spin rounded-full border-4 border-primary border-t-transparent"></div>
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
            <h1 className="text-3xl font-bold tracking-tight">Create Report</h1>
            <p className="text-muted-foreground">Create a detailed patient report with AI assistance</p>
          </div>
        </div>
        <div className="flex gap-2">
          <Button variant="outline" onClick={() => handleSaveReport(true)} disabled={saving}>
            <Save className="mr-2 h-4 w-4" />
            Save Draft
          </Button>
          <Button onClick={() => handleSaveReport(false)} disabled={saving}>
            <FileText className="mr-2 h-4 w-4" />
            Complete Report
          </Button>
        </div>
      </div>

      {error && (
        <Alert variant="destructive">
          <AlertCircle className="h-4 w-4" />
          <AlertDescription>{error}</AlertDescription>
        </Alert>
      )}

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2 space-y-6">
          <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
            <TabsList className="grid w-full grid-cols-2">
              <TabsTrigger value="editor">Report Editor</TabsTrigger>
              <TabsTrigger value="preview">Preview</TabsTrigger>
            </TabsList>
            <TabsContent value="editor" className="space-y-4 pt-4">
              <div className="space-y-2">
                <Label htmlFor="title">Report Title</Label>
                <Input
                  id="title"
                  value={reportData.title}
                  onChange={(e) => setReportData({ ...reportData, title: e.target.value })}
                  placeholder="Enter report title"
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="summary">Summary</Label>
                <Textarea
                  id="summary"
                  value={reportData.summary}
                  onChange={(e) => setReportData({ ...reportData, summary: e.target.value })}
                  placeholder="Provide a summary of the patient's condition and monitoring results"
                  className="min-h-[100px]"
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="anomalyDetection">Anomaly Detection</Label>
                <Textarea
                  id="anomalyDetection"
                  value={reportData.anomalyDetection}
                  onChange={(e) => setReportData({ ...reportData, anomalyDetection: e.target.value })}
                  placeholder="Describe any anomalies detected during the monitoring period"
                  className="min-h-[100px]"
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="doctorSuggestion">Doctor's Suggestion</Label>
                <Textarea
                  id="doctorSuggestion"
                  value={reportData.doctorSuggestion}
                  onChange={(e) => setReportData({ ...reportData, doctorSuggestion: e.target.value })}
                  placeholder="Provide your professional recommendation for the patient"
                  className="min-h-[100px]"
                />
              </div>

              <div className="space-y-2">
                <div className="flex items-center justify-between">
                  <Label htmlFor="aiSuggestion">AI Suggestion</Label>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={handleGenerateAISuggestion}
                    disabled={generatingAI}
                    className="flex items-center gap-1"
                  >
                    <Sparkles className="h-3.5 w-3.5" />
                    <span>{generatingAI ? "Generating..." : "Generate"}</span>
                  </Button>
                </div>
                <Textarea
                  id="aiSuggestion"
                  value={reportData.aiSuggestion}
                  onChange={(e) => setReportData({ ...reportData, aiSuggestion: e.target.value })}
                  placeholder="AI-generated suggestions will appear here"
                  className="min-h-[100px]"
                />
              </div>
            </TabsContent>
            <TabsContent value="preview" className="pt-4">
              <div className="border rounded-lg p-6 space-y-6">
                <div className="text-center space-y-2">
                  <h2 className="text-2xl font-bold">{reportData.title || "Report Title"}</h2>
                  <p className="text-muted-foreground">
                    {new Date().toLocaleDateString()} | Dr. {doctor?.name || "Doctor Name"}
                  </p>
                </div>

                <Separator />

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <h3 className="font-semibold mb-2">Patient Information</h3>
                    <p>
                      <span className="font-medium">Name:</span> {patient?.name || "Patient Name"}
                    </p>
                    <p>
                      <span className="font-medium">Age/Gender:</span> {patient?.age || "--"} /{" "}
                      {patient?.gender || "--"}
                    </p>
                    <p>
                      <span className="font-medium">Contact:</span> {patient?.contactNumber || "--"}
                    </p>
                  </div>
                  <div>
                    <h3 className="font-semibold mb-2">Doctor Information</h3>
                    <p>
                      <span className="font-medium">Name:</span> Dr. {doctor?.name || "Doctor Name"}
                    </p>
                    <p>
                      <span className="font-medium">Specialization:</span> {doctor?.specialization || "--"}
                    </p>
                    <p>
                      <span className="font-medium">Hospital:</span> {doctor?.hospitalName || "--"}
                    </p>
                  </div>
                </div>

                <div>
                  <h3 className="font-semibold mb-2">Summary</h3>
                  <p className="text-sm">{reportData.summary || "No summary provided."}</p>
                </div>

                <div>
                  <h3 className="font-semibold mb-2">Anomaly Detection</h3>
                  <p className="text-sm">{reportData.anomalyDetection || "No anomalies detected."}</p>
                </div>

                <div>
                  <h3 className="font-semibold mb-2">Doctor's Suggestion</h3>
                  <p className="text-sm">{reportData.doctorSuggestion || "No doctor suggestions provided."}</p>
                </div>

                <div>
                  <h3 className="font-semibold mb-2">AI Suggestion</h3>
                  <p className="text-sm">{reportData.aiSuggestion || "No AI suggestions generated."}</p>
                </div>

                <div>
                  <h3 className="font-semibold mb-2">Heart Rate Data</h3>
                  <div className="h-[300px] w-full">
                    <HeartRateChart timeRange={timeRange} />
                  </div>
                </div>
              </div>
            </TabsContent>
          </Tabs>
        </div>

        <div className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle>Patient Information</CardTitle>
              <CardDescription>Details of the patient for this report</CardDescription>
            </CardHeader>
            <CardContent>
              {patient ? (
                <div className="space-y-2">
                  <p>
                    <span className="font-medium">Name:</span> {patient.name}
                  </p>
                  <p>
                    <span className="font-medium">Age/Gender:</span> {patient.age} / {patient.gender}
                  </p>
                  <p>
                    <span className="font-medium">Contact:</span> {patient.contactNumber}
                  </p>
                  <p>
                    <span className="font-medium">Medical History:</span>
                  </p>
                  <p className="text-sm">{patient.medicalHistory || "No medical history recorded."}</p>
                </div>
              ) : (
                <div className="text-center py-4">
                  <p className="text-muted-foreground">No patient selected</p>
                  <Button variant="outline" className="mt-2" onClick={() => router.push("/dashboard/patients")}>
                    Select Patient
                  </Button>
                </div>
              )}
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Heart Rate Data</CardTitle>
              <CardDescription>Interactive visualization of patient's heart rate</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <div>
                    <Label>Time Range (hours)</Label>
                    <div className="flex items-center gap-2 mt-1">
                      <Input
                        type="number"
                        min="0"
                        max="24"
                        value={timeRange.start}
                        onChange={(e) => setTimeRange({ ...timeRange, start: Number.parseInt(e.target.value) || 0 })}
                        className="w-20"
                      />
                      <span>to</span>
                      <Input
                        type="number"
                        min="0"
                        max="24"
                        value={timeRange.end}
                        onChange={(e) => setTimeRange({ ...timeRange, end: Number.parseInt(e.target.value) || 24 })}
                        className="w-20"
                      />
                    </div>
                  </div>
                  <div>
                    <Button variant="outline" size="sm" onClick={() => setTimeRange({ start: 0, end: 24 })}>
                      Reset
                    </Button>
                  </div>
                </div>

                <div className="h-[200px] w-full">
                  <HeartRateChart timeRange={timeRange} />
                </div>

                <div className="text-xs text-muted-foreground">
                  <p>* Drag to zoom, double-click to reset</p>
                  <p>* Click on the legend to toggle channels</p>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  )
}

