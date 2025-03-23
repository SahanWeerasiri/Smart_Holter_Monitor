"use client"

import { useState, useEffect } from "react"
import { getHospitals, removeHospital } from "@/lib/firebase/firestore"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Plus, Search, Trash2, Edit, Building2, RefreshCw, MapPin, Phone } from "lucide-react"
import Link from "next/link"
import { useToast } from "@/hooks/use-toast"
import { set } from "date-fns"

interface Hospital {
    id: string
    name: string
    email: string
    address: string
    contactNumber: string
    description: string
    createdAt: Date
    doctorCount: number
}

export default function HospitalsPage() {
    const [hospitals, setHospitals] = useState<Hospital[]>([])
    const [filteredHospitals, setFilteredHospitals] = useState<Hospital[]>([])
    const [searchQuery, setSearchQuery] = useState("")
    const [isLoading, setIsLoading] = useState(true)
    const { toast } = useToast()

    useEffect(() => {
        fetchHospitals()
    }, [])

    useEffect(() => {
        if (searchQuery) {
            const filtered = hospitals.filter(
                (hospital) =>
                    hospital.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
                    hospital.email.toLowerCase().includes(searchQuery.toLowerCase()) ||
                    hospital.address.toLowerCase().includes(searchQuery.toLowerCase()) ||
                    hospital.contactNumber.includes(searchQuery),
            )
            setFilteredHospitals(filtered)
        } else {
            setFilteredHospitals(hospitals)
        }
    }, [searchQuery, hospitals])

    const fetchHospitals = async () => {
        setIsLoading(true)
        try {
            console.log("[ADMIN] Fetching hospitals")
            const hospitalsData = await getHospitals()
            console.log("[ADMIN] Hospitals fetched:", hospitalsData.length)
            setHospitals(hospitalsData)
            setFilteredHospitals(hospitalsData)
        } catch (error) {
            console.error("[ADMIN] Error fetching hospitals:", error)
            toast({
                title: "Error",
                description: "Failed to load hospitals. Please try again.",
                variant: "destructive",
            })
        } finally {
            setIsLoading(false)
        }
    }

    const deleteHospital = (hospitalId: string) => async () => {
        setIsLoading(true)
        try {
            await removeHospital(hospitalId)
            toast({
                title: "Success",
                description: "Hospital deleted successfully.",
                variant: "destructive",
            })
            fetchHospitals()
        } catch (error) {
            console.error("[ADMIN] Error deleting hospital:", error)
            toast({
                title: "Error",
                description: "Failed to delete hospital." + (error instanceof Error ? error.message : String(error)),
                variant: "destructive",
            })
        } finally {
            setIsLoading(false)
        }
    }


    return (
        <div className="space-y-6">
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight">Hospitals</h1>
                    <p className="text-muted-foreground">Manage hospitals in your system</p>
                </div>
                <Button asChild>
                    <Link href="/dashboard/admin/hospitals/add">
                        <Building2 className="mr-2 h-4 w-4" />
                        Add Hospital
                    </Link>
                </Button>
            </div>

            <Card>
                <CardHeader className="pb-3">
                    <div className="flex items-center justify-between">
                        <CardTitle>All Hospitals</CardTitle>
                        <div className="flex items-center gap-2">
                            <div className="relative">
                                <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
                                <Input
                                    type="search"
                                    placeholder="Search hospitals..."
                                    className="w-64 pl-8"
                                    value={searchQuery}
                                    onChange={(e) => setSearchQuery(e.target.value)}
                                />
                            </div>
                            <Button variant="outline" size="icon" onClick={fetchHospitals} title="Refresh">
                                <RefreshCw className="h-4 w-4" />
                            </Button>
                        </div>
                    </div>
                    <CardDescription>
                        {filteredHospitals.length} {filteredHospitals.length === 1 ? "hospital" : "hospitals"} in the system
                    </CardDescription>
                </CardHeader>
                <CardContent>
                    {isLoading ? (
                        <div className="flex justify-center items-center py-8">
                            <RefreshCw className="h-8 w-8 animate-spin text-primary" />
                        </div>
                    ) : filteredHospitals.length === 0 ? (
                        <div className="flex flex-col items-center justify-center py-8 text-center">
                            <div className="rounded-full bg-muted p-3 mb-3">
                                <Building2 className="h-6 w-6 text-muted-foreground" />
                            </div>
                            <h3 className="text-lg font-semibold">No hospitals found</h3>
                            <p className="text-muted-foreground mb-4 max-w-sm">
                                {searchQuery
                                    ? "No hospitals match your search criteria. Try a different search term."
                                    : "There are no hospitals in the system yet. Add your first hospital to get started."}
                            </p>
                            {!searchQuery && (
                                <Button asChild>
                                    <Link href="/dashboard/admin/hospitals/add">
                                        <Plus className="mr-2 h-4 w-4" />
                                        Add Your First Hospital
                                    </Link>
                                </Button>
                            )}
                        </div>
                    ) : (
                        <div className="rounded-md border">
                            <Table>
                                <TableHeader>
                                    <TableRow>
                                        <TableHead>Hospital</TableHead>
                                        <TableHead>Address</TableHead>
                                        <TableHead>Contact</TableHead>
                                        <TableHead>Doctors</TableHead>
                                        <TableHead className="text-right">Actions</TableHead>
                                    </TableRow>
                                </TableHeader>
                                <TableBody>
                                    {filteredHospitals.map((hospital) => (
                                        <TableRow key={hospital.id} className="group">
                                            <TableCell>
                                                <div className="font-medium">{hospital.name}</div>
                                                <div className="text-sm text-muted-foreground">{hospital.email}</div>
                                            </TableCell>
                                            <TableCell>
                                                <div className="flex items-center">
                                                    <MapPin className="h-4 w-4 mr-1 text-muted-foreground" />
                                                    <span>{hospital.address || "Not specified"}</span>
                                                </div>
                                            </TableCell>
                                            <TableCell>
                                                <div className="flex items-center">
                                                    <Phone className="h-4 w-4 mr-1 text-muted-foreground" />
                                                    <span>{hospital.contactNumber || "Not specified"}</span>
                                                </div>
                                            </TableCell>
                                            <TableCell>
                                                <Badge variant="outline" className="bg-primary/5">
                                                    {hospital.doctorCount} Doctors
                                                </Badge>
                                            </TableCell>
                                            <TableCell className="text-right">
                                                <div className="flex justify-end gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                                                    {/* <Button variant="ghost" size="icon" asChild>
                                                        <Link href={`/dashboard/admin/hospitals/edit/${hospital.id}`}>
                                                            <Edit className="h-4 w-4" />
                                                            <span className="sr-only">Edit</span>
                                                        </Link>
                                                    </Button> */}
                                                    <Button variant="ghost" size="icon" className="text-destructive" onClick={deleteHospital(hospital.id)}>
                                                        <Trash2 className="h-4 w-4" />
                                                        <span className="sr-only">Delete</span>
                                                    </Button>
                                                </div>
                                            </TableCell>
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

