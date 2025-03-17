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
import { Badge } from "@/components/ui/badge"
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Plus, Search, FileText, Stethoscope, AlertTriangle } from "lucide-react"
import { useRouter } from "next/navigation"
import {
  getPatients,
  addPatient,
  getPatientAll,
  getAvailableHolterMonitors,
  assignHolterMonitor,
  removeHolterMonitor,
} from "@/lib/firebase/firestore"
import { Command, CommandEmpty, CommandGroup, CommandItem, CommandList } from "@/components/ui/command"
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover"

interface Patient {
  id: string
  name: string
  age: number
  gender: string
  contactNumber: string
  medicalHistory: string
  status: string
  monitorId?: string
  monitorCode?: string
  assignedDate?: string
  doctorId: string
}

interface HolterMonitor {
  id: string
  deviceCode: string
  description: string
}

interface allPatients {
  value: string
  label: string
}

export default function PatientsPage() {
  const [patients, setPatients] = useState<Patient[]>([])
  const [patientsAll, setPatientsAll] = useState<allPatients[]>([])
  const [loading, setLoading] = useState(true)
  const [searchQuery, setSearchQuery] = useState("")
  const [activeTab, setActiveTab] = useState("all")
  const [isAddPatientDialogOpen, setIsAddPatientDialogOpen] = useState(false)
  const [isAssignDeviceDialogOpen, setIsAssignDeviceDialogOpen] = useState(false)
  const [selectedPatient, setSelectedPatient] = useState<Patient | null>(null)
  const [availableMonitors, setAvailableMonitors] = useState<HolterMonitor[]>([])
  const [selectedMonitorId, setSelectedMonitorId] = useState("")
  const [newPatient, setNewPatient] = useState("")
  const router = useRouter()
  const [isPopoverOpen, setIsPopoverOpen] = useState(false)

  // Example patient options - replace with your actual data
  // const patientOptions = [
  //   { value: "1|John Doe", label: "John Doe" },
  //   { value: "2|Jane Smith", label: "Jane Smith" },
  //   { value: "3|Robert Johnson", label: "Robert Johnson" },
  //   { value: "4|Emily Davis", label: "Emily Davis" },
  // ]

  // Filter patients based on search query
  const filteredPatientsAdd = patientsAll.filter((patient) =>
    patient.label.toLowerCase().includes(searchQuery.toLowerCase()),
  )

  // Reset search when dialog closes
  useEffect(() => {
    if (!isAddPatientDialogOpen) {
      setSearchQuery("")
      setIsPopoverOpen(false)
    }
  }, [isAddPatientDialogOpen])

  useEffect(() => {
    fetchPatients()
    fetchAllPatients()
  }, [])

  const fetchPatients = async () => {
    try {
      const patientsData = await getPatients()
      setPatients(patientsData)
    } catch (error) {
      console.error("Error fetching patients:", error)
    } finally {
      setLoading(false)
    }
  }

  const fetchAllPatients = async () => {
    try {
      const patientsData = await getPatientAll()
      setPatientsAll(patientsData)
    } catch (error) {
      console.error("Error fetching patients:", error)
    } finally {
      setLoading(false)
    }
  }

  const fetchAvailableMonitors = async () => {
    try {
      const monitors = await getAvailableHolterMonitors()
      setAvailableMonitors(monitors)
    } catch (error) {
      console.error("Error fetching available monitors:", error)
    }
  }

  const handleAddPatient = async () => {
    try {
      if (newPatient.length === 0) {
        alert("Please select a patient")
        return
      }
      await addPatient(newPatient)
      setIsAddPatientDialogOpen(false)
      fetchPatients()
    } catch (error) {
      console.error("Error adding patient:", error)
      alert("Failed to add patient")
    }
  }

  // const handleAddPatient = async () => {
  //   try {
  //     if (!newPatient.name || !newPatient.age || !newPatient.gender || !newPatient.contactNumber) {
  //       alert("Please fill in all required fields")
  //       return
  //     }

  //     await addPatient({
  //       name: newPatient.name,
  //       age: Number.parseInt(newPatient.age),
  //       gender: newPatient.gender,
  //       contactNumber: newPatient.contactNumber,
  //       medicalHistory: newPatient.medicalHistory,
  //       status: "not_attached",
  //     })

  //     setNewPatient({
  //       name: "",
  //       age: "",
  //       gender: "male",
  //       contactNumber: "",
  //       medicalHistory: "",
  //     })
  //     setIsAddPatientDialogOpen(false)
  //     fetchPatients()
  //   } catch (error) {
  //     console.error("Error adding patient:", error)
  //     alert("Failed to add patient")
  //   }
  // }

  const handleAssignDevice = async () => {
    try {
      if (!selectedPatient || !selectedMonitorId) {
        alert("Please select a monitor to assign")
        return
      }

      await assignHolterMonitor(selectedPatient.id, selectedMonitorId)
      setIsAssignDeviceDialogOpen(false)
      fetchPatients()
    } catch (error) {
      console.error("Error assigning device:", error)
      alert("Failed to assign device")
    }
  }

  const handleRemoveDevice = async (patientId: string) => {
    try {
      if (window.confirm("Are you sure you want to remove the device from this patient?")) {
        await removeHolterMonitor(patientId)
        fetchPatients()
      }
    } catch (error) {
      console.error("Error removing device:", error)
      alert("Failed to remove device")
    }
  }

  const handleCreateReport = (patientId: string) => {
    router.push(`/dashboard/reports/create?patientId=${patientId}`)
  }

  const openAssignDeviceDialog = (patient: Patient) => {
    setSelectedPatient(patient)
    fetchAvailableMonitors()
    setIsAssignDeviceDialogOpen(true)
  }

  const filteredPatients = patients.filter(
    (patient) =>
      (activeTab === "all" ||
        (activeTab === "not_attached" && patient.status === "not_attached") ||
        (activeTab === "monitoring" && patient.status === "monitoring") ||
        (activeTab === "finished" && patient.status === "finished")) &&
      (patient.name.toLowerCase().includes(searchQuery.toLowerCase()) || patient.contactNumber.includes(searchQuery)),
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
          <h1 className="text-3xl font-bold tracking-tight">Patients</h1>
          <p className="text-muted-foreground">Manage your patients and their monitoring status</p>
        </div>
        <Dialog open={isAddPatientDialogOpen} onOpenChange={setIsAddPatientDialogOpen}>
          <DialogTrigger asChild>
            <Button className="flex items-center gap-2">
              <Plus className="h-4 w-4" />
              Add Patient
            </Button>
          </DialogTrigger>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>Add New Patient</DialogTitle>
            </DialogHeader>
            <div className="grid gap-4 py-4">
              <div className="relative w-full">
                <Input
                  placeholder="Search or select a patient"
                  value={searchQuery}
                  onChange={(e) => {
                    setSearchQuery(e.target.value)
                    if (!isPopoverOpen) {
                      setIsPopoverOpen(true)
                    }
                  }}
                  className="w-full"
                  onFocus={() => setIsPopoverOpen(true)}
                  onKeyDown={(e) => {
                    if (e.key === "ArrowDown") {
                      e.preventDefault()
                      setIsPopoverOpen(true)
                      // Focus the first command item
                      const firstItem = document.querySelector("[cmdk-item]") as HTMLElement
                      if (firstItem) firstItem.focus()
                    }
                  }}
                />
                {isPopoverOpen && (
                  <div className="absolute top-full left-0 w-full z-50 mt-1 rounded-md border bg-popover shadow-md">
                    <Command>
                      <CommandList>
                        <CommandEmpty>No patients found</CommandEmpty>
                        <CommandGroup>
                          {filteredPatientsAdd.map((patient) => (
                            <CommandItem
                              key={patient.value}
                              onSelect={() => {
                                setNewPatient(patient.value)
                                setSearchQuery(patient.label)
                                setIsPopoverOpen(false)
                              }}
                            >
                              {patient.label}
                            </CommandItem>
                          ))}
                        </CommandGroup>
                      </CommandList>
                    </Command>
                  </div>
                )}
              </div>
            </div>
            <DialogFooter>
              <Button variant="outline" onClick={() => setIsAddPatientDialogOpen(false)}>
                Cancel
              </Button>
              <Button onClick={handleAddPatient}>Add Patient</Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      </div>

      <div className="space-y-4">
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
          <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full sm:w-auto">
            <TabsList className="grid w-full grid-cols-4">
              <TabsTrigger value="all">All</TabsTrigger>
              <TabsTrigger value="not_attached">Not Attached</TabsTrigger>
              <TabsTrigger value="monitoring">Monitoring</TabsTrigger>
              <TabsTrigger value="finished">Finished</TabsTrigger>
            </TabsList>
          </Tabs>
          <div className="flex items-center gap-2">
            <Search className="h-4 w-4 text-muted-foreground" />
            <Input
              placeholder="Search patients..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="max-w-sm"
            />
          </div>
        </div>

        <div className="rounded-md border">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Name</TableHead>
                <TableHead>Age/Gender</TableHead>
                <TableHead>Contact</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Device</TableHead>
                <TableHead className="text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {filteredPatients.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={6} className="h-24 text-center">
                    No patients found.
                  </TableCell>
                </TableRow>
              ) : (
                filteredPatients.map((patient) => (
                  <TableRow key={patient.id}>
                    <TableCell className="font-medium">{patient.name}</TableCell>
                    <TableCell>
                      {patient.age} / {patient.gender.charAt(0).toUpperCase() + patient.gender.slice(1)}
                    </TableCell>
                    <TableCell>{patient.contactNumber}</TableCell>
                    <TableCell>
                      <Badge
                        variant={
                          patient.status === "monitoring"
                            ? "default"
                            : patient.status === "finished"
                              ? "outline"
                              : "secondary"
                        }
                      >
                        {patient.status === "not_attached"
                          ? "Not Attached"
                          : patient.status === "monitoring"
                            ? "Monitoring"
                            : "Finished"}
                      </Badge>
                    </TableCell>
                    <TableCell>{patient.monitorCode ? patient.monitorCode : "Not assigned"}</TableCell>
                    <TableCell className="text-right">
                      <div className="flex justify-end gap-2">
                        {/* {patient.status === "not_attached" && (
                          <Button
                            variant="outline"
                            size="sm"
                            className="flex items-center gap-1"
                            onClick={() => openAssignDeviceDialog(patient)}
                          >
                            <Stethoscope className="h-3.5 w-3.5" />
                            <span>Assign Device</span>
                          </Button>
                        )} */}
                        {/* {patient.status === "monitoring" && (
                          <Button
                            variant="outline"
                            size="sm"
                            className="flex items-center gap-1"
                            onClick={() => handleRemoveDevice(patient.id)}
                          >
                            <Stethoscope className="h-3.5 w-3.5" />
                            <span>Remove Device</span>
                          </Button>
                        )} */}
                        {patient.status === "finished" && (
                          <Button
                            variant="outline"
                            size="sm"
                            className="flex items-center gap-1"
                            onClick={() => handleCreateReport(patient.id)}
                          >
                            <FileText className="h-3.5 w-3.5" />
                            <span>Create Report</span>
                          </Button>
                        )}
                      </div>
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </div>
      </div>

      {/* Assign Device Dialog */}
      <Dialog open={isAssignDeviceDialogOpen} onOpenChange={setIsAssignDeviceDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Assign Holter Monitor</DialogTitle>
            <DialogDescription>Select a holter monitor to assign to {selectedPatient?.name}</DialogDescription>
          </DialogHeader>
          <div className="grid gap-4 py-4">
            {availableMonitors.length === 0 ? (
              <div className="flex items-center justify-center p-4 text-center">
                <div className="space-y-2">
                  <AlertTriangle className="mx-auto h-8 w-8 text-yellow-500" />
                  <p>No available holter monitors found.</p>
                  <p className="text-sm text-muted-foreground">
                    Please add new monitors or wait for currently used monitors to become available.
                  </p>
                </div>
              </div>
            ) : (
              <div className="grid gap-2">
                <Label htmlFor="monitor">Select Monitor</Label>
                <select
                  id="monitor"
                  value={selectedMonitorId}
                  onChange={(e) => setSelectedMonitorId(e.target.value)}
                  className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
                >
                  <option value="">Select a monitor</option>
                  {availableMonitors.map((monitor) => (
                    <option key={monitor.id} value={monitor.id}>
                      {monitor.deviceCode} - {monitor.description}
                    </option>
                  ))}
                </select>
              </div>
            )}
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setIsAssignDeviceDialogOpen(false)}>
              Cancel
            </Button>
            <Button onClick={handleAssignDevice} disabled={!selectedMonitorId || availableMonitors.length === 0}>
              Assign Device
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  )
}

