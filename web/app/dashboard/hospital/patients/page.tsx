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
import { Plus, Search, AlertTriangle, RefreshCw } from "lucide-react"
import { useRouter } from "next/navigation"
import { getPatients, addPatient, getDoctors } from "@/lib/firebase/firestore"
import { Card, CardContent, CardDescription, CardHeader } from "@/components/ui/card"

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
    doctorName?: string
}

interface Doctor {
    id: string
    name: string
    specialization: string
}

export default function HospitalPatientsPage() {
    const [patients, setPatients] = useState<Patient[]>([])
    const [doctors, setDoctors] = useState<Doctor[]>([])
    const [loading, setLoading] = useState(true)
    const [searchQuery, setSearchQuery] = useState("")
    const [activeTab, setActiveTab] = useState("all")
    const [isAddPatientDialogOpen, setIsAddPatientDialogOpen] = useState(false)
    const [newPatient, setNewPatient] = useState({
        name: "",
        age: "",
        gender: "male",
        contactNumber: "",
        medicalHistory: "",
        doctorId: "",
    })
    const router = useRouter()

    useEffect(() => {
        fetchData()
    }, [])

    const fetchData = async () => {
        try {
            setLoading(true)
            const [patientsData, doctorsData] = await Promise.all([getPatients(), getDoctors()])
            setPatients(patientsData)
            setDoctors(doctorsData)
        } catch (error) {
            console.error("Error fetching data:", error)
        } finally {
            setLoading(false)
        }
    }

    // const handleAddPatient = async () => {
    //     try {
    //         if (!newPatient.name || !newPatient.age || !newPatient.gender || !newPatient.contactNumber) {
    //             alert("Please fill in all required fields")
    //             return
    //         }

    //         await addPatient({
    //             name: newPatient.name,
    //             age: Number.parseInt(newPatient.age),
    //             gender: newPatient.gender,
    //             contactNumber: newPatient.contactNumber,
    //             medicalHistory: newPatient.medicalHistory,
    //             doctorId: newPatient.doctorId,
    //             status: "not_attached",
    //         })

    //         setNewPatient({
    //             name: "",
    //             age: "",
    //             gender: "male",
    //             contactNumber: "",
    //             medicalHistory: "",
    //             doctorId: "",
    //         })
    //         setIsAddPatientDialogOpen(false)
    //         fetchData()
    //     } catch (error) {
    //         console.error("Error adding patient:", error)
    //         alert("Failed to add patient")
    //     }
    // }

    const filteredPatients = patients.filter(
        (patient) =>
            (activeTab === "all" ||
                (activeTab === "not_attached" && patient.status === "not_attached") ||
                (activeTab === "monitoring" && patient.status === "monitoring") ||
                (activeTab === "finished" && patient.status === "finished")) &&
            (patient.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
                patient.contactNumber.includes(searchQuery) ||
                (patient.doctorName && patient.doctorName.toLowerCase().includes(searchQuery.toLowerCase()))),
    )

    return (
        <div className="space-y-6">
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight">Hospital Patients</h1>
                    <p className="text-muted-foreground">Manage patients in your hospital</p>
                </div>
                {/* <Dialog open={isAddPatientDialogOpen} onOpenChange={setIsAddPatientDialogOpen}>
                    <DialogTrigger asChild>
                        <Button className="flex items-center gap-2">
                            <Plus className="h-4 w-4" />
                            Add Patient
                        </Button>
                    </DialogTrigger>
                    <DialogContent>
                        <DialogHeader>
                            <DialogTitle>Add New Patient</DialogTitle>
                            <DialogDescription>Enter the details for the new patient.</DialogDescription>
                        </DialogHeader>
                        <div className="grid gap-4 py-4">
                            <div className="grid gap-2">
                                <Label htmlFor="name">Full Name</Label>
                                <Input
                                    id="name"
                                    value={newPatient.name}
                                    onChange={(e) => setNewPatient({ ...newPatient, name: e.target.value })}
                                    placeholder="John Doe"
                                />
                            </div>
                            <div className="grid grid-cols-2 gap-4">
                                <div className="grid gap-2">
                                    <Label htmlFor="age">Age</Label>
                                    <Input
                                        id="age"
                                        type="number"
                                        value={newPatient.age}
                                        onChange={(e) => setNewPatient({ ...newPatient, age: e.target.value })}
                                        placeholder="45"
                                    />
                                </div>
                                <div className="grid gap-2">
                                    <Label htmlFor="gender">Gender</Label>
                                    <select
                                        id="gender"
                                        value={newPatient.gender}
                                        onChange={(e) => setNewPatient({ ...newPatient, gender: e.target.value })}
                                        className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
                                    >
                                        <option value="male">Male</option>
                                        <option value="female">Female</option>
                                        <option value="other">Other</option>
                                    </select>
                                </div>
                            </div>
                            <div className="grid gap-2">
                                <Label htmlFor="contactNumber">Contact Number</Label>
                                <Input
                                    id="contactNumber"
                                    value={newPatient.contactNumber}
                                    onChange={(e) => setNewPatient({ ...newPatient, contactNumber: e.target.value })}
                                    placeholder="+1 (555) 123-4567"
                                />
                            </div>
                            <div className="grid gap-2">
                                <Label htmlFor="doctor">Assign Doctor</Label>
                                <select
                                    id="doctor"
                                    value={newPatient.doctorId}
                                    onChange={(e) => setNewPatient({ ...newPatient, doctorId: e.target.value })}
                                    className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
                                >
                                    <option value="">Select a doctor (optional)</option>
                                    {doctors.map((doctor) => (
                                        <option key={doctor.id} value={doctor.id}>
                                            {doctor.name} - {doctor.specialization}
                                        </option>
                                    ))}
                                </select>
                            </div>
                            <div className="grid gap-2">
                                <Label htmlFor="medicalHistory">Medical History</Label>
                                <textarea
                                    id="medicalHistory"
                                    value={newPatient.medicalHistory}
                                    onChange={(e) => setNewPatient({ ...newPatient, medicalHistory: e.target.value })}
                                    placeholder="Previous conditions, medications, etc."
                                    className="flex min-h-[80px] w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
                                />
                            </div>
                        </div>
                        <DialogFooter>
                            <Button variant="outline" onClick={() => setIsAddPatientDialogOpen(false)}>
                                Cancel
                            </Button>
                            <Button onClick={handleAddPatient}>Add Patient</Button>
                        </DialogFooter>
                    </DialogContent>
                </Dialog> */}
            </div>

            <Card>
                <CardHeader className="pb-3">
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
                            <Button variant="outline" size="icon" onClick={fetchData} title="Refresh">
                                <RefreshCw className="h-4 w-4" />
                            </Button>
                        </div>
                    </div>
                    <CardDescription>
                        {filteredPatients.length} {filteredPatients.length === 1 ? "patient" : "patients"} found
                    </CardDescription>
                </CardHeader>
                <CardContent>
                    {loading ? (
                        <div className="flex justify-center items-center py-8">
                            <RefreshCw className="h-8 w-8 animate-spin text-primary" />
                        </div>
                    ) : filteredPatients.length === 0 ? (
                        <div className="flex flex-col items-center justify-center py-8 text-center">
                            <div className="rounded-full bg-muted p-3 mb-3">
                                <AlertTriangle className="h-6 w-6 text-muted-foreground" />
                            </div>
                            <h3 className="text-lg font-semibold">No patients found</h3>
                            <p className="text-muted-foreground mb-4 max-w-sm">
                                {searchQuery || activeTab !== "all"
                                    ? "No patients match your search criteria. Try different filters."
                                    : "There are no patients in your hospital yet."}
                            </p>
                            {/* {!searchQuery && activeTab === "all" && (
                                <Button onClick={() => setIsAddPatientDialogOpen(true)}>
                                    <Plus className="mr-2 h-4 w-4" />
                                    Add Your First Patient
                                </Button>
                            )} */}
                        </div>
                    ) : (
                        <div className="rounded-md border">
                            <Table>
                                <TableHeader>
                                    <TableRow>
                                        <TableHead>Name</TableHead>
                                        <TableHead>Age/Gender</TableHead>
                                        <TableHead>Contact</TableHead>
                                        <TableHead>Doctor</TableHead>
                                        <TableHead>Status</TableHead>
                                        <TableHead>Device</TableHead>
                                        {/* <TableHead className="text-right">Actions</TableHead> */}
                                    </TableRow>
                                </TableHeader>
                                <TableBody>
                                    {filteredPatients.map((patient) => (
                                        <TableRow key={patient.id} className="group">
                                            <TableCell className="font-medium">{patient.name}</TableCell>
                                            <TableCell>
                                                {patient.age} / {patient.gender.charAt(0).toUpperCase() + patient.gender.slice(1)}
                                            </TableCell>
                                            <TableCell>{patient.contactNumber}</TableCell>
                                            <TableCell>{patient.doctorName || "Not assigned"}</TableCell>
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
                                            {/* <TableCell className="text-right">
                                                <div className="flex justify-end gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                                                    
                                                    <Button variant="ghost" size="sm" className="h-8 px-2">
                                                        View
                                                    </Button>
                                                    <Button variant="ghost" size="sm" className="h-8 px-2">
                                                        Edit
                                                    </Button>
                                                </div>
                                            </TableCell> */}
                                        </TableRow>
                                    ))}
                                </TableBody>
                            </Table>
                        </div>
                    )}
                </CardContent>
            </Card>
        </div>
    )
}

