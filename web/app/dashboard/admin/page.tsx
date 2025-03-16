"use client"

import { useState, useEffect } from "react"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
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
import { Plus, Search, Trash2, Edit } from 'lucide-react'
import { getUserRole, getDoctors, getHospitals, addDoctor, addHospital } from "@/lib/firebase/firestore"
import { useRouter } from "next/navigation"

interface Doctor {
  id: string
  name: string
  email: string
  specialization: string
  hospitalId: string
  hospitalName: string
}

interface Hospital {
  id: string
  name: string
  address: string
  contactNumber: string
}

export default function AdminPage() {
  const [activeTab, setActiveTab] = useState("doctors")
  const [doctors, setDoctors] = useState<Doctor[]>([])
  const [hospitals, setHospitals] = useState<Hospital[]>([])
  const [loading, setLoading] = useState(true)
  const [isAdmin, setIsAdmin] = useState(false)
  const [searchQuery, setSearchQuery] = useState("")
  const [isAddDoctorDialogOpen, setIsAddDoctorDialogOpen] = useState(false)
  const [isAddHospitalDialogOpen, setIsAddHospitalDialogOpen] = useState(false)
  const [newDoctor, setNewDoctor] = useState({
    name: "",
    email: "",
    password: "",
    specialization: "",
    hospitalId: "",
  })
  const [newHospital, setNewHospital] = useState({
    name: "",
    address: "",
    contactNumber: "",
  })
  const router = useRouter()

  useEffect(() => {
    const checkAdminAccess = async () => {
      try {
        const role = await getUserRole()
        if (role !== "admin") {
          router.push("/dashboard")
          return
        }
        setIsAdmin(true)
        await fetchData()
      } catch (error) {
        console.error("Error checking admin access:", error)
        router.push("/dashboard")
      } finally {
        setLoading(false)
      }
    }

    const fetchData = async () => {
      try {
        const [doctorsData, hospitalsData] = await Promise.all([getDoctors(), getHospitals()])
        setDoctors(doctorsData)
        setHospitals(hospitalsData)
      } catch (error) {
        console.error("Error fetching data:", error)
      }
    }

    checkAdminAccess()
  }, [router])

  const handleAddDoctor = async () => {
    try {
      if (!newDoctor.name || !newDoctor.email || !newDoctor.password) {
        alert("Please fill in all required fields (name, email, password)")
        return
      }

      // Create a new doctor with default values if fields are empty
      const doctorData = {
        name: newDoctor.name,
        email: newDoctor.email,
        password: newDoctor.password,
        specialization: newDoctor.specialization || "General Medicine",
        hospitalId: newDoctor.hospitalId || "",
        role: "doctor",
      }

      console.log("[ADMIN] Adding new doctor:", doctorData)
      const doctorId = await addDoctor(doctorData)
      console.log("[ADMIN] Doctor added with ID:", doctorId)

      // Find hospital name if hospitalId is provided
      let hospitalName = ""
      if (newDoctor.hospitalId) {
        const hospital = hospitals.find((h) => h.id === newDoctor.hospitalId)
        hospitalName = hospital?.name || ""
      }

      // Add the new doctor to the local state
      setDoctors([
        ...doctors,
        {
          id: doctorId,
          name: newDoctor.name,
          email: newDoctor.email,
          specialization: newDoctor.specialization || "General Medicine",
          hospitalId: newDoctor.hospitalId || "",
          hospitalName: hospitalName,
        },
      ])

      // Reset the form
      setNewDoctor({
        name: "",
        email: "",
        password: "",
        specialization: "",
        hospitalId: "",
      })
      setIsAddDoctorDialogOpen(false)
    } catch (error) {
      console.error("Error adding doctor:", error)
      alert("Failed to add doctor: " + (error instanceof Error ? error.message : String(error)))
    }
  }

  const handleAddHospital = async () => {
    try {
      if (!newHospital.name || !newHospital.address) {
        alert("Please fill in all required fields")
        return
      }

      const hospitalId = await addHospital({
        name: newHospital.name,
        address: newHospital.address,
        contactNumber: newHospital.contactNumber,
      })

      setHospitals([
        ...hospitals,
        {
          id: hospitalId,
          name: newHospital.name,
          address: newHospital.address,
          contactNumber: newHospital.contactNumber,
        },
      ])

      setNewHospital({
        name: "",
        address: "",
        contactNumber: "",
      })
      setIsAddHospitalDialogOpen(false)
    } catch (error) {
      console.error("Error adding hospital:", error)
      alert("Failed to add hospital")
    }
  }

  const filteredDoctors = doctors.filter(
    (doctor) =>
      doctor.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      doctor.email.toLowerCase().includes(searchQuery.toLowerCase()) ||
      doctor.specialization.toLowerCase().includes(searchQuery.toLowerCase()) ||
      doctor.hospitalName.toLowerCase().includes(searchQuery.toLowerCase()),
  )

  const filteredHospitals = hospitals.filter(
    (hospital) =>
      hospital.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      hospital.address.toLowerCase().includes(searchQuery.toLowerCase()) ||
      hospital.contactNumber.includes(searchQuery),
  )

  if (loading) {
    return (
      <div className="flex h-[calc(100vh-4rem)] items-center justify-center">
        <div className="h-8 w-8 animate-spin rounded-full border-4 border-primary border-t-transparent"></div>
      </div>
    )
  }

  if (!isAdmin) {
    return null
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold tracking-tight">Admin Dashboard</h1>
        <p className="text-muted-foreground">Manage doctors and hospitals in your system</p>
      </div>

      <Tabs value={activeTab} onValueChange={setActiveTab} className="space-y-4">
        <TabsList>
          <TabsTrigger value="doctors">Doctors</TabsTrigger>
          <TabsTrigger value="hospitals">Hospitals</TabsTrigger>
        </TabsList>

        <TabsContent value="doctors" className="space-y-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <Search className="h-4 w-4 text-muted-foreground" />
              <Input
                placeholder="Search doctors..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="max-w-sm"
              />
            </div>
            <Dialog open={isAddDoctorDialogOpen} onOpenChange={setIsAddDoctorDialogOpen}>
              <DialogTrigger asChild>
                <Button className="flex items-center gap-2">
                  <Plus className="h-4 w-4" />
                  Add Doctor
                </Button>
              </DialogTrigger>
              <DialogContent>
                <DialogHeader>
                  <DialogTitle>Add New Doctor</DialogTitle>
                  <DialogDescription>Enter the details for the new doctor account.</DialogDescription>
                </DialogHeader>
                <div className="grid gap-4 py-4">
                  <div className="grid gap-2">
                    <Label htmlFor="name">Full Name</Label>
                    <Input
                      id="name"
                      value={newDoctor.name}
                      onChange={(e) => setNewDoctor({ ...newDoctor, name: e.target.value })}
                      placeholder="Dr. John Doe"
                    />
                  </div>
                  <div className="grid gap-2">
                    <Label htmlFor="email">Email</Label>
                    <Input
                      id="email"
                      type="email"
                      value={newDoctor.email}
                      onChange={(e) => setNewDoctor({ ...newDoctor, email: e.target.value })}
                      placeholder="john.doe@example.com"
                    />
                  </div>
                  <div className="grid gap-2">
                    <Label htmlFor="password">Password</Label>
                    <Input
                      id="password"
                      type="password"
                      value={newDoctor.password}
                      onChange={(e) => setNewDoctor({ ...newDoctor, password: e.target.value })}
                      placeholder="••••••••"
                    />
                  </div>
                  <div className="grid gap-2">
                    <Label htmlFor="specialization">Specialization</Label>
                    <Input
                      id="specialization"
                      value={newDoctor.specialization}
                      onChange={(e) => setNewDoctor({ ...newDoctor, specialization: e.target.value })}
                      placeholder="Cardiology"
                    />
                  </div>
                  <div className="grid gap-2">
                    <Label htmlFor="hospital">Hospital</Label>
                    <select
                      id="hospital"
                      value={newDoctor.hospitalId}
                      onChange={(e) => setNewDoctor({ ...newDoctor, hospitalId: e.target.value })}
                      className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
                    >
                      <option value="">Select a hospital</option>
                      {hospitals.map((hospital) => (
                        <option key={hospital.id} value={hospital.id}>
                          {hospital.name}
                        </option>
                      ))}
                    </select>
                  </div>
                </div>
                <DialogFooter>
                  <Button variant="outline" onClick={() => setIsAddDoctorDialogOpen(false)}>
                    Cancel
                  </Button>
                  <Button onClick={handleAddDoctor}>Add Doctor</Button>
                </DialogFooter>
              </DialogContent>
            </Dialog>
          </div>

          <div className="rounded-md border">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Name</TableHead>
                  <TableHead>Email</TableHead>
                  <TableHead>Specialization</TableHead>
                  <TableHead>Hospital</TableHead>
                  <TableHead className="text-right">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filteredDoctors.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={5} className="h-24 text-center">
                      <div className="flex flex-col items-center justify-center py-4">
                        <p className="mb-2 text-muted-foreground">No doctors found</p>
                        <Button
                          variant="outline"
                          size="sm"
                          onClick={() => setIsAddDoctorDialogOpen(true)}
                          className="mt-2"
                        >
                          <Plus className="mr-2 h-4 w-4" />
                          Add Your First Doctor
                        </Button>
                      </div>
                    </TableCell>
                  </TableRow>
                ) : (
                  filteredDoctors.map((doctor) => (
                    <TableRow key={doctor.id}>
                      <TableCell className="font-medium">{doctor.name}</TableCell>
                      <TableCell>{doctor.email}</TableCell>
                      <TableCell>{doctor.specialization || "Not specified"}</TableCell>
                      <TableCell>{doctor.hospitalName || "Not assigned"}</TableCell>
                      <TableCell className="text-right">
                        <div className="flex justify-end gap-2">
                          {/* <Button variant="ghost" size="icon">
                            <Edit className="h-4 w-4" />
                          </Button> */}
                          <Button variant="ghost" size="icon">
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
        </TabsContent>

        <TabsContent value="hospitals" className="space-y-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <Search className="h-4 w-4 text-muted-foreground" />
              <Input
                placeholder="Search hospitals..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="max-w-sm"
              />
            </div>
            <Dialog open={isAddHospitalDialogOpen} onOpenChange={setIsAddHospitalDialogOpen}>
              <DialogTrigger asChild>
                <Button className="flex items-center gap-2">
                  <Plus className="h-4 w-4" />
                  Add Hospital
                </Button>
              </DialogTrigger>
              <DialogContent>
                <DialogHeader>
                  <DialogTitle>Add New Hospital</DialogTitle>
                  <DialogDescription>Enter the details for the new hospital.</DialogDescription>
                </DialogHeader>
                <div className="grid gap-4 py-4">
                  <div className="grid gap-2">
                    <Label htmlFor="hospitalName">Hospital Name</Label>
                    <Input
                      id="hospitalName"
                      value={newHospital.name}
                      onChange={(e) => setNewHospital({ ...newHospital, name: e.target.value })}
                      placeholder="General Hospital"
                    />
                  </div>
                  <div className="grid gap-2">
                    <Label htmlFor="address">Address</Label>
                    <Input
                      id="address"
                      value={newHospital.address}
                      onChange={(e) => setNewHospital({ ...newHospital, address: e.target.value })}
                      placeholder="123 Main St, City, Country"
                    />
                  </div>
                  <div className="grid gap-2">
                    <Label htmlFor="contactNumber">Contact Number</Label>
                    <Input
                      id="contactNumber"
                      value={newHospital.contactNumber}
                      onChange={(e) => setNewHospital({ ...newHospital, contactNumber: e.target.value })}
                      placeholder="+1 (555) 123-4567"
                    />
                  </div>
                </div>
                <DialogFooter>
                  <Button variant="outline" onClick={() => setIsAddHospitalDialogOpen(false)}>
                    Cancel
                  </Button>
                  <Button onClick={handleAddHospital}>Add Hospital</Button>
                </DialogFooter>
              </DialogContent>
            </Dialog>
          </div>

          <div className="rounded-md border">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Name</TableHead>
                  <TableHead>Address</TableHead>
                  <TableHead>Contact Number</TableHead>
                  <TableHead className="text-right">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filteredHospitals.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={4} className="h-24 text-center">
                      <div className="flex flex-col items-center justify-center py-4">
                        <p className="mb-2 text-muted-foreground">No hospitals found</p>
                        <Button
                          variant="outline"
                          size="sm"
                          onClick={() => setIsAddHospitalDialogOpen(true)}
                          className="mt-2"
                        >
                          <Plus className="mr-2 h-4 w-4" />
                          Add Your First Hospital
                        </Button>
                      </div>
                    </TableCell>
                  </TableRow>
                ) : (
                  filteredHospitals.map((hospital) => (
                    <TableRow key={hospital.id}>
                      <TableCell className="font-medium">{hospital.name}</TableCell>
                      <TableCell>{hospital.address}</TableCell>
                      <TableCell>{hospital.contactNumber}</TableCell>
                      <TableCell className="text-right">
                        {/* <div className="flex justify-end gap-2"> */}
                        {/* <Button variant="ghost" size="icon">
                            <Edit className="h-4 w-4" />
                          </Button> */}
                        <Button variant="ghost" size="icon">
                          <Trash2 className="h-4 w-4" />
                        </Button>
                        {/* </div> */}
                      </TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          </div>
        </TabsContent>
      </Tabs>
    </div>
  )
}
