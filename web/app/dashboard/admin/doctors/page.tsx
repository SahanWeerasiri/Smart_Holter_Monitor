"use client"

import { useState, useEffect } from "react"
import { getDoctors } from "@/lib/firebase/firestore"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { Plus, Search, Trash2, Edit, UserPlus, RefreshCw } from "lucide-react"
import Link from "next/link"
import { useToast } from "@/hooks/use-toast"

interface Doctor {
    id: string
    name: string
    email: string
    specialization: string
    hospitalId: string
    hospitalName: string
    contactNumber: string
    pic: string
}

export default function DoctorsPage() {
    const [doctors, setDoctors] = useState<Doctor[]>([])
    const [filteredDoctors, setFilteredDoctors] = useState<Doctor[]>([])
    const [searchQuery, setSearchQuery] = useState("")
    const [isLoading, setIsLoading] = useState(true)
    const { toast } = useToast()

    useEffect(() => {
        fetchDoctors()
    }, [])

    useEffect(() => {
        if (searchQuery) {
            const filtered = doctors.filter(
                (doctor) =>
                    doctor.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
                    doctor.email.toLowerCase().includes(searchQuery.toLowerCase()) ||
                    doctor.specialization.toLowerCase().includes(searchQuery.toLowerCase()) ||
                    (doctor.hospitalName && doctor.hospitalName.toLowerCase().includes(searchQuery.toLowerCase())),
            )
            setFilteredDoctors(filtered)
        } else {
            setFilteredDoctors(doctors)
        }
    }, [searchQuery, doctors])

    const fetchDoctors = async () => {
        setIsLoading(true)
        try {
            console.log("[ADMIN] Fetching doctors")
            const doctorsData = await getDoctors()
            console.log("[ADMIN] Doctors fetched:", doctorsData.length)
            setDoctors(doctorsData)
            setFilteredDoctors(doctorsData)
        } catch (error) {
            console.error("[ADMIN] Error fetching doctors:", error)
            toast({
                title: "Error",
                description: "Failed to load doctors. Please try again.",
                variant: "destructive",
            })
        } finally {
            setIsLoading(false)
        }
    }

    const getInitials = (name: string) => {
        return name
            .split(" ")
            .map((n) => n[0])
            .join("")
            .toUpperCase()
    }

    return (
        <div className="space-y-6">
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight">Doctors</h1>
                    <p className="text-muted-foreground">Manage doctors in your system</p>
                </div>
                <Button asChild>
                    <Link href="/dashboard/admin/doctors/add">
                        <UserPlus className="mr-2 h-4 w-4" />
                        Add Doctor
                    </Link>
                </Button>
            </div>

            <Card>
                <CardHeader className="pb-3">
                    <div className="flex items-center justify-between">
                        <CardTitle>All Doctors</CardTitle>
                        <div className="flex items-center gap-2">
                            <div className="relative">
                                <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
                                <Input
                                    type="search"
                                    placeholder="Search doctors..."
                                    className="w-64 pl-8"
                                    value={searchQuery}
                                    onChange={(e) => setSearchQuery(e.target.value)}
                                />
                            </div>
                            <Button variant="outline" size="icon" onClick={fetchDoctors} title="Refresh">
                                <RefreshCw className="h-4 w-4" />
                            </Button>
                        </div>
                    </div>
                    <CardDescription>
                        {filteredDoctors.length} {filteredDoctors.length === 1 ? "doctor" : "doctors"} in the system
                    </CardDescription>
                </CardHeader>
                <CardContent>
                    {isLoading ? (
                        <div className="flex justify-center items-center py-8">
                            <RefreshCw className="h-8 w-8 animate-spin text-primary" />
                        </div>
                    ) : filteredDoctors.length === 0 ? (
                        <div className="flex flex-col items-center justify-center py-8 text-center">
                            <div className="rounded-full bg-muted p-3 mb-3">
                                <UserPlus className="h-6 w-6 text-muted-foreground" />
                            </div>
                            <h3 className="text-lg font-semibold">No doctors found</h3>
                            <p className="text-muted-foreground mb-4 max-w-sm">
                                {searchQuery
                                    ? "No doctors match your search criteria. Try a different search term."
                                    : "There are no doctors in the system yet. Add your first doctor to get started."}
                            </p>
                            {!searchQuery && (
                                <Button asChild>
                                    <Link href="/dashboard/admin/doctors/add">
                                        <Plus className="mr-2 h-4 w-4" />
                                        Add Your First Doctor
                                    </Link>
                                </Button>
                            )}
                        </div>
                    ) : (
                        <div className="rounded-md border">
                            <Table>
                                <TableHeader>
                                    <TableRow>
                                        <TableHead>Doctor</TableHead>
                                        <TableHead>Specialization</TableHead>
                                        <TableHead>Hospital</TableHead>
                                        <TableHead>Contact</TableHead>
                                        {/* <TableHead className="text-right">Actions</TableHead> */}
                                    </TableRow>
                                </TableHeader>
                                <TableBody>
                                    {filteredDoctors.map((doctor) => (
                                        <TableRow key={doctor.id} className="group">
                                            <TableCell>
                                                <div className="flex items-center gap-3">
                                                    <Avatar>
                                                        <AvatarImage src={doctor.pic} alt={doctor.name} />
                                                        <AvatarFallback>{getInitials(doctor.name)}</AvatarFallback>
                                                    </Avatar>
                                                    <div>
                                                        <div className="font-medium">{doctor.name}</div>
                                                        <div className="text-sm text-muted-foreground">{doctor.email}</div>
                                                    </div>
                                                </div>
                                            </TableCell>
                                            <TableCell>
                                                {doctor.specialization ? (
                                                    <Badge variant="outline" className="bg-primary/5">
                                                        {doctor.specialization}
                                                    </Badge>
                                                ) : (
                                                    <span className="text-muted-foreground text-sm">Not specified</span>
                                                )}
                                            </TableCell>
                                            <TableCell>
                                                {doctor.hospitalName ? (
                                                    doctor.hospitalName
                                                ) : (
                                                    <span className="text-muted-foreground text-sm">Not assigned</span>
                                                )}
                                            </TableCell>
                                            <TableCell>
                                                {doctor.contactNumber ? (
                                                    doctor.contactNumber
                                                ) : (
                                                    <span className="text-muted-foreground text-sm">Not provided</span>
                                                )}
                                            </TableCell>
                                            {/* <TableCell className="text-right">
                                                <div className="flex justify-end gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                                                    <Button variant="ghost" size="icon" asChild>
                                                        <Link href={`/dashboard/admin/doctors/edit/${doctor.id}`}>
                                                            <Edit className="h-4 w-4" />
                                                            <span className="sr-only">Edit</span>
                                                        </Link>
                                                    </Button>
                                                    <Button variant="ghost" size="icon" className="text-destructive">
                                                        <Trash2 className="h-4 w-4" />
                                                        <span className="sr-only">Delete</span>
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

