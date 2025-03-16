"use client"

import { useState } from "react"
import { useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import * as z from "zod"
import { useToast } from "@/hooks/use-toast"
import { addDoctor, getHospitals } from "@/lib/firebase/firestore"
import { useEffect } from "react"
import { Loader2, CheckCircle2, AlertCircle } from "lucide-react"

import { Form, FormControl, FormDescription, FormField, FormItem, FormLabel, FormMessage } from "@/components/ui/form"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Input } from "@/components/ui/input"
import { Button } from "@/components/ui/button"
import { Textarea } from "@/components/ui/textarea"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert"

// Define the form schema with validation
const formSchema = z.object({
    name: z.string().min(3, { message: "Name must be at least 3 characters" }),
    email: z.string().email({ message: "Please enter a valid email address" }),
    password: z
        .string()
        .min(8, { message: "Password must be at least 8 characters" })
        .regex(/[A-Z]/, { message: "Password must contain at least one uppercase letter" })
        .regex(/[a-z]/, { message: "Password must contain at least one lowercase letter" })
        .regex(/[0-9]/, { message: "Password must contain at least one number" }),
    specialization: z.string().min(2, { message: "Please enter a specialization" }),
    hospitalId: z.string().optional(),
    contactNumber: z.string().optional(),
    bio: z.string().optional(),
})

type FormValues = z.infer<typeof formSchema>

export function DoctorSignupForm() {
    const { toast } = useToast()
    const [isSubmitting, setIsSubmitting] = useState(false)
    const [hospitals, setHospitals] = useState<{ id: string; name: string }[]>([])
    const [isLoadingHospitals, setIsLoadingHospitals] = useState(true)
    const [submissionStatus, setSubmissionStatus] = useState<"idle" | "success" | "error">("idle")
    const [errorMessage, setErrorMessage] = useState("")

    // Initialize the form
    const form = useForm<FormValues>({
        resolver: zodResolver(formSchema),
        defaultValues: {
            name: "",
            email: "",
            password: "",
            specialization: "",
            hospitalId: "",
            contactNumber: "",
            bio: "",
        },
    })

    // Fetch hospitals on component mount
    useEffect(() => {
        const fetchHospitals = async () => {
            try {
                const hospitalsData = await getHospitals()
                setHospitals(hospitalsData.map((hospital) => ({ id: hospital.id, name: hospital.name })))
            } catch (error) {
                console.error("Error fetching hospitals:", error)
                toast({
                    title: "Error",
                    description: "Failed to load hospitals. Please try again.",
                    variant: "destructive",
                })
            } finally {
                setIsLoadingHospitals(false)
            }
        }

        fetchHospitals()
    }, [toast])

    // Handle form submission
    const onSubmit = async (data: FormValues) => {
        setIsSubmitting(true)
        setSubmissionStatus("idle")
        setErrorMessage("")

        try {
            console.log("[ADMIN] Submitting doctor signup form:", data)

            // Add the doctor to the system
            const doctorId = await addDoctor({
                name: data.name,
                email: data.email,
                password: data.password,
                specialization: data.specialization,
                hospitalId: data.hospitalId || null,
                mobile: data.contactNumber || "",
                bio: data.bio || "",
                role: "doctor",
            })

            console.log("[ADMIN] Doctor added successfully with ID:", doctorId)

            // Show success message
            setSubmissionStatus("success")
            toast({
                title: "Success",
                description: "Doctor account created successfully",
            })

            // Reset the form
            form.reset()
        } catch (error: any) {
            console.error("[ADMIN] Error adding doctor:", error)
            setSubmissionStatus("error")
            setErrorMessage(error.message || "Failed to create doctor account")
            toast({
                title: "Error",
                description: error.message || "Failed to create doctor account",
                variant: "destructive",
            })
        } finally {
            setIsSubmitting(false)
        }
    }

    return (
        <Card className="w-full max-w-2xl mx-auto">
            <CardHeader>
                <CardTitle className="text-2xl">Add New Doctor</CardTitle>
                <CardDescription>
                    Create a new doctor account in the system. The doctor will receive an email with login instructions.
                </CardDescription>
            </CardHeader>
            <CardContent>
                {submissionStatus === "success" && (
                    <Alert className="mb-6 bg-green-50 border-green-200">
                        <CheckCircle2 className="h-4 w-4 text-green-600" />
                        <AlertTitle className="text-green-800">Success</AlertTitle>
                        <AlertDescription className="text-green-700">
                            Doctor account has been created successfully.
                        </AlertDescription>
                    </Alert>
                )}

                {submissionStatus === "error" && (
                    <Alert className="mb-6 bg-red-50 border-red-200">
                        <AlertCircle className="h-4 w-4 text-red-600" />
                        <AlertTitle className="text-red-800">Error</AlertTitle>
                        <AlertDescription className="text-red-700">{errorMessage}</AlertDescription>
                    </Alert>
                )}

                <Form {...form}>
                    <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <FormField
                                control={form.control}
                                name="name"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>Full Name</FormLabel>
                                        <FormControl>
                                            <Input placeholder="Dr. John Doe" {...field} />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />

                            <FormField
                                control={form.control}
                                name="email"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>Email</FormLabel>
                                        <FormControl>
                                            <Input type="email" placeholder="doctor@example.com" {...field} />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />

                            <FormField
                                control={form.control}
                                name="password"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>Password</FormLabel>
                                        <FormControl>
                                            <Input type="password" placeholder="••••••••" {...field} />
                                        </FormControl>
                                        <FormDescription>
                                            Must be at least 8 characters with uppercase, lowercase, and number.
                                        </FormDescription>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />

                            <FormField
                                control={form.control}
                                name="specialization"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>Specialization</FormLabel>
                                        <FormControl>
                                            <Input placeholder="Cardiology" {...field} />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />

                            <FormField
                                control={form.control}
                                name="hospitalId"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>Hospital</FormLabel>
                                        <Select onValueChange={field.onChange} value={field.value}>
                                            <FormControl>
                                                <SelectTrigger>
                                                    <SelectValue placeholder="Select a hospital" />
                                                </SelectTrigger>
                                            </FormControl>
                                            <SelectContent>
                                                <SelectItem value="none">None</SelectItem>
                                                {isLoadingHospitals ? (
                                                    <div className="flex items-center justify-center py-2">
                                                        <Loader2 className="h-4 w-4 animate-spin mr-2" />
                                                        <span>Loading hospitals...</span>
                                                    </div>
                                                ) : hospitals.length === 0 ? (
                                                    <div className="p-2 text-center text-muted-foreground">No hospitals found</div>
                                                ) : (
                                                    hospitals.map((hospital) => (
                                                        <SelectItem key={hospital.id} value={hospital.id}>
                                                            {hospital.name}
                                                        </SelectItem>
                                                    ))
                                                )}
                                            </SelectContent>
                                        </Select>
                                        <FormDescription>Optional. You can assign the doctor to a hospital later.</FormDescription>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />

                            <FormField
                                control={form.control}
                                name="contactNumber"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>Contact Number</FormLabel>
                                        <FormControl>
                                            <Input placeholder="+1 (555) 123-4567" {...field} />
                                        </FormControl>
                                        <FormDescription>Optional</FormDescription>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                        </div>

                        <FormField
                            control={form.control}
                            name="bio"
                            render={({ field }) => (
                                <FormItem>
                                    <FormLabel>Bio</FormLabel>
                                    <FormControl>
                                        <Textarea
                                            placeholder="Brief professional background and expertise..."
                                            className="min-h-[100px]"
                                            {...field}
                                        />
                                    </FormControl>
                                    <FormDescription>Optional. Professional background and expertise.</FormDescription>
                                    <FormMessage />
                                </FormItem>
                            )}
                        />

                        <div className="flex justify-end">
                            <Button type="submit" disabled={isSubmitting}>
                                {isSubmitting && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                                {isSubmitting ? "Creating Account..." : "Create Doctor Account"}
                            </Button>
                        </div>
                    </form>
                </Form>
            </CardContent>
        </Card>
    )
}

