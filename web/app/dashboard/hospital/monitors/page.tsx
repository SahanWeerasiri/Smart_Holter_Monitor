"use client"

import type React from "react"

import { useState, useEffect } from "react"
import { useRouter } from "next/navigation"
import { PlusCircle, Trash2, Search, Info, CheckCircle2, Clock, AlertTriangle, Loader2 } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle, CardFooter } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { Badge } from "@/components/ui/badge"
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
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from "@/components/ui/tooltip"
import { useToast } from "@/components/ui/use-toast"
import { getHolterMonitors, addHolterMonitor, deleteHolterMonitor } from "@/lib/firebase/firestore"

export default function HospitalMonitorsPage() {
    const [monitors, setMonitors] = useState<any[]>([])
    const [loading, setLoading] = useState(true)
    const [open, setOpen] = useState(false)
    const [deviceCode, setDeviceCode] = useState("")
    const [description, setDescription] = useState("")
    const [searchQuery, setSearchQuery] = useState("")
    const [submitting, setSubmitting] = useState(false)
    const { toast } = useToast()
    const router = useRouter()

    useEffect(() => {
        fetchMonitors()
    }, [])

    const fetchMonitors = async () => {
        try {
            setLoading(true)
            const monitorsData = await getHolterMonitors()
            setMonitors(monitorsData)
        } catch (error) {
            console.error("Error fetching monitors:", error)
            toast({
                title: "Error",
                description: "Failed to load holter monitors. Please try again.",
                variant: "destructive",
            })
        } finally {
            setLoading(false)
        }
    }

    const handleAddMonitor = async (e: React.FormEvent) => {
        e.preventDefault()

        if (!deviceCode.trim()) {
            toast({
                title: "Error",
                description: "Device code is required",
                variant: "destructive",
            })
            return
        }

        try {
            setSubmitting(true)

            await addHolterMonitor({
                deviceCode,
                description,
                status: "available",
            })

            toast({
                title: "Success",
                description: "Holter monitor added successfully",
            })

            setDeviceCode("")
            setDescription("")
            setOpen(false)
            fetchMonitors()
        } catch (error) {
            console.error("Error adding monitor:", error)
            toast({
                title: "Error",
                description: "Failed to add holter monitor. Please try again.",
                variant: "destructive",
            })
        } finally {
            setSubmitting(false)
        }
    }

    const handleDeleteMonitor = async (monitorId: string) => {
        if (!confirm("Are you sure you want to delete this monitor?")) {
            return
        }

        try {
            await deleteHolterMonitor(monitorId)
            toast({
                title: "Success",
                description: "Holter monitor deleted successfully",
            })
            fetchMonitors()
        } catch (error) {
            console.error("Error deleting monitor:", error)
            toast({
                title: "Error",
                description: "Failed to delete holter monitor. Please try again.",
                variant: "destructive",
            })
        }
    }

    const filteredMonitors = monitors.filter(
        (monitor) =>
            monitor.deviceCode.toLowerCase().includes(searchQuery.toLowerCase()) ||
            (monitor.description && monitor.description.toLowerCase().includes(searchQuery.toLowerCase())) ||
            (monitor.assignedTo && monitor.assignedTo.patientName.toLowerCase().includes(searchQuery.toLowerCase())),
    )

    // Calculate statistics
    const totalMonitors = monitors.length
    const availableMonitors = monitors.filter((m) => m.status === "available").length
    const inUseMonitors = monitors.filter((m) => m.status === "in-use").length
    const completedMonitors = monitors.filter((m) => m.isDone).length

    return (
        <div className="space-y-6">
            <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight">Holter Monitors</h1>
                    <p className="text-muted-foreground">Manage your hospital's holter monitoring devices</p>
                </div>
                <Dialog open={open} onOpenChange={setOpen}>
                    <DialogTrigger asChild>
                        <Button className="bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700">
                            <PlusCircle className="mr-2 h-4 w-4" />
                            Add Monitor
                        </Button>
                    </DialogTrigger>
                    <DialogContent>
                        <DialogHeader>
                            <DialogTitle>Add New Holter Monitor</DialogTitle>
                            <DialogDescription>Add a new holter monitor to your hospital's inventory</DialogDescription>
                        </DialogHeader>
                        <form onSubmit={handleAddMonitor}>
                            <div className="grid gap-4 py-4">
                                <div className="grid gap-2">
                                    <Label htmlFor="deviceCode">Device Code *</Label>
                                    <Input
                                        id="deviceCode"
                                        value={deviceCode}
                                        onChange={(e) => setDeviceCode(e.target.value)}
                                        placeholder="Enter device code"
                                        required
                                    />
                                </div>
                                <div className="grid gap-2">
                                    <Label htmlFor="description">Description</Label>
                                    <Textarea
                                        id="description"
                                        value={description}
                                        onChange={(e) => setDescription(e.target.value)}
                                        placeholder="Enter device description"
                                        rows={3}
                                    />
                                </div>
                            </div>
                            <DialogFooter>
                                <Button type="button" variant="outline" onClick={() => setOpen(false)}>
                                    Cancel
                                </Button>
                                <Button type="submit" disabled={submitting}>
                                    {submitting ? (
                                        <>
                                            <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                                            Adding...
                                        </>
                                    ) : (
                                        "Add Monitor"
                                    )}
                                </Button>
                            </DialogFooter>
                        </form>
                    </DialogContent>
                </Dialog>
            </div>

            <div className="grid gap-4 md:grid-cols-4">
                <Card>
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium">Total Monitors</CardTitle>
                        <Info className="h-4 w-4 text-muted-foreground" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold">{totalMonitors}</div>
                        <p className="text-xs text-muted-foreground">Devices in your inventory</p>
                    </CardContent>
                </Card>
                <Card>
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium">Available</CardTitle>
                        <CheckCircle2 className="h-4 w-4 text-green-500" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold">{availableMonitors}</div>
                        <p className="text-xs text-muted-foreground">Ready for assignment</p>
                    </CardContent>
                </Card>
                <Card>
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium">In Use</CardTitle>
                        <Clock className="h-4 w-4 text-blue-500" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold">{inUseMonitors}</div>
                        <p className="text-xs text-muted-foreground">Currently assigned</p>
                    </CardContent>
                </Card>
                <Card>
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium">Completed</CardTitle>
                        <AlertTriangle className="h-4 w-4 text-yellow-500" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold">{completedMonitors}</div>
                        <p className="text-xs text-muted-foreground">Monitoring completed</p>
                    </CardContent>
                </Card>
            </div>

            <div className="flex items-center space-x-2">
                <Search className="h-5 w-5 text-muted-foreground" />
                <Input
                    placeholder="Search by device code, description or patient name..."
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                    className="max-w-sm"
                />
            </div>

            <Card className="overflow-hidden">
                <CardHeader>
                    <CardTitle>Holter Monitors</CardTitle>
                    <CardDescription>View and manage all holter monitors in your hospital</CardDescription>
                </CardHeader>
                <CardContent className="p-0">
                    {loading ? (
                        <div className="flex justify-center items-center h-64">
                            <Loader2 className="h-8 w-8 animate-spin text-primary" />
                            <span className="ml-2 text-muted-foreground">Loading monitors...</span>
                        </div>
                    ) : filteredMonitors.length === 0 ? (
                        <div className="flex flex-col items-center justify-center h-64 space-y-4">
                            <div className="rounded-full bg-muted p-3">
                                <AlertTriangle className="h-6 w-6 text-muted-foreground" />
                            </div>
                            <p className="text-muted-foreground">No holter monitors found</p>
                            <Button onClick={() => setOpen(true)}>
                                <PlusCircle className="mr-2 h-4 w-4" />
                                Add Your First Monitor
                            </Button>
                        </div>
                    ) : (
                        <div className="overflow-x-auto">
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
                                    {filteredMonitors.map((monitor) => (
                                        <TableRow key={monitor.id} className="group hover:bg-muted/50">
                                            <TableCell className="font-medium">{monitor.deviceCode}</TableCell>
                                            <TableCell>{monitor.description || "—"}</TableCell>
                                            <TableCell>
                                                <Badge
                                                    variant={monitor.status === "available" ? "outline" : "default"}
                                                    className={
                                                        monitor.status === "available"
                                                            ? "bg-green-50 text-green-700 hover:bg-green-50 hover:text-green-700"
                                                            : "bg-blue-100 text-blue-800 hover:bg-blue-100 hover:text-blue-800"
                                                    }
                                                >
                                                    {monitor.status === "available" ? "Available" : "In Use"}
                                                </Badge>
                                            </TableCell>
                                            <TableCell>
                                                {monitor.assignedTo ? (
                                                    <span className="text-sm font-medium">{monitor.assignedTo.patientName}</span>
                                                ) : (
                                                    "—"
                                                )}
                                            </TableCell>
                                            <TableCell>
                                                {monitor.assignedTo && monitor.assignedTo.deadline ? (
                                                    <span className="text-sm">{new Date(monitor.assignedTo.deadline).toLocaleDateString()}</span>
                                                ) : (
                                                    "—"
                                                )}
                                            </TableCell>
                                            <TableCell className="text-right">
                                                <TooltipProvider>
                                                    <Tooltip>
                                                        <TooltipTrigger asChild>
                                                            <Button
                                                                variant="ghost"
                                                                size="icon"
                                                                onClick={() => handleDeleteMonitor(monitor.id)}
                                                                disabled={monitor.status !== "available"}
                                                                className={
                                                                    monitor.status === "available"
                                                                        ? "opacity-0 group-hover:opacity-100 transition-opacity"
                                                                        : "opacity-50 cursor-not-allowed"
                                                                }
                                                            >
                                                                <Trash2 className="h-4 w-4 text-red-500" />
                                                            </Button>
                                                        </TooltipTrigger>
                                                        <TooltipContent>
                                                            {monitor.status === "available"
                                                                ? "Delete monitor"
                                                                : "Cannot delete a monitor that is in use"}
                                                        </TooltipContent>
                                                    </Tooltip>
                                                </TooltipProvider>
                                            </TableCell>
                                        </TableRow>
                                    ))}
                                </TableBody>
                            </Table>
                        </div>
                    )}
                </CardContent>
                <CardFooter className="bg-muted/50 p-3 text-xs text-muted-foreground">
                    Showing {filteredMonitors.length} of {monitors.length} monitors
                </CardFooter>
            </Card>
        </div>
    )
}

