"use client"

import { useState, useEffect, SetStateAction } from "react"
import { useRouter } from "next/navigation"
import { format, parseISO } from "date-fns"
import { toast } from "sonner"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { getReports } from "@/lib/firebase/firestore"
import { Loader2, Search, FileText, Plus } from "lucide-react"

export default function ReportsPage() {
  const router = useRouter()

  const [loading, setLoading] = useState(true)
  const [reports, setReports] = useState<Report[]>([])
  const [searchQuery, setSearchQuery] = useState("")
  const [activeTab, setActiveTab] = useState("all")

  interface Report {
    id: string
    title: string
    patientName: string
    createdAt: string
    status: string
    patientId: string
  }


  useEffect(() => {
    const fetchReports = async () => {
      try {
        const reportsData = await getReports()
        setReports(reportsData)
        setLoading(false)
      } catch (error) {
        console.error("Error fetching reports:", error)
        toast.error("Failed to fetch reports")
        setLoading(false)
      }
    }

    fetchReports()
  }, [])

  const handleSearch = (e: { target: { value: SetStateAction<string> } }) => {
    setSearchQuery(e.target.value)
  }

  const filteredReports = reports.filter((report) => {
    const matchesSearch =
      report.patientName.toLowerCase().includes(searchQuery.toLowerCase()) ||
      report.title.toLowerCase().includes(searchQuery.toLowerCase())

    if (activeTab === "all") return matchesSearch
    if (activeTab === "recent") {
      const reportDate = new Date(report.createdAt)
      const thirtyDaysAgo = new Date()
      thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30)
      return matchesSearch && reportDate >= thirtyDaysAgo
    }

    return matchesSearch
  })

  const handleViewReport = (reportId: string, patientId: any) => {
    router.push(`/dashboard/doctor/reports/${reportId}?patientId=${patientId}`)
  }

  return (
    <div className="container mx-auto py-6 space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold tracking-tight">Reports</h1>
        <Button onClick={() => router.push("/dashboard/doctor/patients")}>
          <Plus className="mr-2 h-4 w-4" />
          Create New Report
        </Button>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Reports Management</CardTitle>
          <CardDescription>View and manage patient reports</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            <div className="flex items-center gap-4">
              <div className="relative flex-1">
                <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
                <Input
                  type="search"
                  placeholder="Search reports..."
                  className="pl-8"
                  value={searchQuery}
                  onChange={handleSearch}
                />
              </div>
              <Tabs defaultValue="all" className="w-[400px]" onValueChange={setActiveTab}>
                <TabsList>
                  <TabsTrigger value="all">All Reports</TabsTrigger>
                  <TabsTrigger value="recent">Recent (30 days)</TabsTrigger>
                </TabsList>
              </Tabs>
            </div>

            {loading ? (
              <div className="flex justify-center py-8">
                <Loader2 className="h-8 w-8 animate-spin text-primary" />
              </div>
            ) : filteredReports.length > 0 ? (
              <div className="rounded-md border">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Report Title</TableHead>
                      <TableHead>Patient Name</TableHead>
                      <TableHead>Created Date</TableHead>
                      <TableHead>Status</TableHead>
                      <TableHead className="text-right">Actions</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {filteredReports.map((report) => (
                      <TableRow key={report.id}>
                        <TableCell className="font-medium">{report.title}</TableCell>
                        <TableCell>{report.patientName}</TableCell>
                        <TableCell>{format(parseISO(report.createdAt), "MMM d, yyyy")}</TableCell>
                        <TableCell>
                          <span className="inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium bg-green-100 text-green-800">
                            {report.status}
                          </span>
                        </TableCell>
                        <TableCell className="text-right">
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => handleViewReport(report.id, report.patientId)}
                          >
                            <FileText className="mr-2 h-4 w-4" />
                            View
                          </Button>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </div>
            ) : (
              <div className="flex flex-col items-center justify-center py-8">
                <FileText className="h-12 w-12 text-muted-foreground mb-4" />
                <h3 className="text-lg font-medium">No reports found</h3>
                <p className="text-muted-foreground">
                  {searchQuery ? "No reports match your search criteria" : "You haven't created any reports yet"}
                </p>
                {!searchQuery && (
                  <Button className="mt-4" onClick={() => router.push("/dashboard/doctor/patients")}>
                    <Plus className="mr-2 h-4 w-4" />
                    Create New Report
                  </Button>
                )}
              </div>
            )}
          </div>
        </CardContent>
      </Card>
    </div>
  )
}

