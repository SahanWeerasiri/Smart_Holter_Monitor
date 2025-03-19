"use client"

import { useState, useEffect } from "react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { Badge } from "@/components/ui/badge"
import { Plus, Search, Trash2, Edit } from "lucide-react"
import { getHolterMonitors, addHolterMonitor, deleteHolterMonitor } from "@/lib/firebase/firestore"

interface MonitorData {
  id: string;
  deviceCode: string;
  deadline: any;
  description: any;
  status: string;
  assignedTo: {
    patientId: string;
    patientName: any;
    deadline: any;
  } | undefined;
  hospitalId: any;
  isDone: any;
}

export default function MonitorsPage() {
  const [monitors, setMonitors] = useState<MonitorData[]>([])
  const [loading, setLoading] = useState(true)
  const [searchQuery, setSearchQuery] = useState("")
  const [isAddDialogOpen, setIsAddDialogOpen] = useState(false)
  const [newMonitor, setNewMonitor] = useState<MonitorData>({
    deviceCode: "",
    description: "",
    status: "available",
    assignedTo: {
      patientId: "",
      patientName: "",
      deadline: "",
    },
    hospitalId: "",
    isDone: false,
    deadline: "",
    id: "",
  })



  useEffect(() => {
    const fetchMonitors = async () => {
      try {
        const monitorsData = await getHolterMonitors()
        setMonitors(monitorsData)
      } catch (error) {
        console.error("Error fetching holter monitors:", error)
      } finally {
        setLoading(false)
      }
    }

    fetchMonitors()
  }, [])

  const handleAddMonitor = async () => {
    try {
      if (!newMonitor.deviceCode) {
        alert("Device code is required")
        return
      }

      const monitorId = await addHolterMonitor({
        deviceCode: newMonitor.deviceCode,
        description: newMonitor.description,
        status: "available",
      })

      setMonitors([
        ...monitors,
        {
          id: monitorId,
          deviceCode: newMonitor.deviceCode,
          description: newMonitor.description,
          status: "available",
          assignedTo: {
            patientId: "",
            patientName: "",
            deadline: "",
          },
          hospitalId: "",
          isDone: false,
          deadline: "",
        },
      ])

      setNewMonitor({ deviceCode: "", description: "", status: "available", assignedTo: { patientId: "", patientName: "", deadline: "" }, hospitalId: "", isDone: false, deadline: "", id: "" })
      setIsAddDialogOpen(false)
    } catch (error) {
      console.error("Error adding holter monitor:", error)
      alert("Failed to add holter monitor")
    }
  }

  const handleDeleteMonitor = async (id: string) => {
    if (window.confirm("Are you sure you want to delete this holter monitor?")) {
      try {
        await deleteHolterMonitor(id)
        setMonitors(monitors.filter((monitor) => monitor.id !== id))
      } catch (error) {
        console.error("Error deleting holter monitor:", error)
        alert("Failed to delete holter monitor")
      }
    }
  }

  const filteredMonitors = monitors.filter(
    (monitor) =>
      monitor.deviceCode.toLowerCase().includes(searchQuery.toLowerCase()) ||
      monitor.description.toLowerCase().includes(searchQuery.toLowerCase()) ||
      (monitor.assignedTo?.patientName || "").toLowerCase().includes(searchQuery.toLowerCase()),
  )

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
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Holter Monitors</h1>
          <p className="text-muted-foreground">Manage your holter monitoring devices</p>
        </div>
        <Dialog open={isAddDialogOpen} onOpenChange={setIsAddDialogOpen}>
          <DialogTrigger asChild>
            <Button className="flex items-center gap-2">
              <Plus className="h-4 w-4" />
              Add Monitor
            </Button>
          </DialogTrigger>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>Add New Holter Monitor</DialogTitle>
              <DialogDescription>Enter the details for the new holter monitor device.</DialogDescription>
            </DialogHeader>
            <div className="grid gap-4 py-4">
              <div className="grid gap-2">
                <Label htmlFor="deviceCode">Device Code</Label>
                <Input
                  id="deviceCode"
                  value={newMonitor.deviceCode}
                  onChange={(e) => setNewMonitor({ ...newMonitor, deviceCode: e.target.value })}
                  placeholder="HM-2023-XX"
                />
              </div>
              <div className="grid gap-2">
                <Label htmlFor="description">Description</Label>
                <Textarea
                  id="description"
                  value={newMonitor.description}
                  onChange={(e) => setNewMonitor({ ...newMonitor, description: e.target.value })}
                  placeholder="Enter device details, model, etc."
                />
              </div>
            </div>
            <DialogFooter>
              <Button variant="outline" onClick={() => setIsAddDialogOpen(false)}>
                Cancel
              </Button>
              <Button onClick={handleAddMonitor}>Add Device</Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      </div>

      <div className="flex items-center gap-2">
        <Search className="h-4 w-4 text-muted-foreground" />
        <Input
          placeholder="Search monitors by code, description or patient..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          className="max-w-sm"
        />
      </div>

      <div className="rounded-md border">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Device Code</TableHead>
              <TableHead>Description</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Assigned To</TableHead>
              <TableHead>Deadline</TableHead>
              <TableHead className="text-right">Actions</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {filteredMonitors.length === 0 ? (
              <TableRow>
                <TableCell colSpan={6} className="h-24 text-center">
                  No holter monitors found.
                </TableCell>
              </TableRow>
            ) : (
              filteredMonitors.map((monitor) => (
                <TableRow key={monitor.id}>
                  <TableCell className="font-medium">{monitor.deviceCode}</TableCell>
                  <TableCell>{monitor.description}</TableCell>
                  <TableCell>
                    <Badge variant={monitor.status === "available" ? "outline" : "default"}>
                      {monitor.status === "available" ? "Available" : "In Use"}
                    </Badge>
                  </TableCell>
                  <TableCell>{monitor.assignedTo ? monitor.assignedTo.patientName : "Not assigned"}</TableCell>
                  <TableCell>
                    {monitor.assignedTo ? new Date(monitor.assignedTo.deadline).toLocaleDateString() : "-"}
                  </TableCell>
                  <TableCell className="text-right">
                    <div className="flex justify-end gap-2">
                      <Button variant="ghost" size="icon">
                        <Edit className="h-4 w-4" />
                      </Button>
                      <Button
                        variant="ghost"
                        size="icon"
                        onClick={() => handleDeleteMonitor(monitor.id)}
                        disabled={monitor.status === "in-use"}
                      >
                        <Trash2 className="h-4 w-4" />
                      </Button>
                    </div>
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </div>
    </div>
  )
}

