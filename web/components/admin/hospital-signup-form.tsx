"use client"

import { useState } from "react"
import { useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import * as z from "zod"
import { useToast } from "@/hooks/use-toast"
import { addHospital } from "@/lib/firebase/firestore"
import { Loader2, CheckCircle2, AlertCircle } from "lucide-react"

import { Form, FormControl, FormDescription, FormField, FormItem, FormLabel, FormMessage } from "@/components/ui/form"
import { Input } from "@/components/ui/input"
import { Button } from "@/components/ui/button"
import { Textarea } from "@/components/ui/textarea"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert"

// Define the form schema with validation
const formSchema = z.object({
    name: z.string().min(3, { message: "Hospital name must be at least 3 characters" }),
    email: z.string().email({ message: "Please enter a valid email address" }),
    password: z
        .string()
        .min(8, { message: "Password must be at least 8 characters" })
        .regex(/[A-Z]/, { message: "Password must contain at least one uppercase letter" })
        .regex(/[a-z]/, { message: "Password must contain at least one lowercase letter" })
        .regex(/[0-9]/, { message: "Password must contain at least one number" }),
    address: z.string().min(5, { message: "Please enter a valid address" }),
    contactNumber: z.string().min(5, { message: "Please enter a valid contact number" }),
    description: z.string().optional(),
})

type FormValues = z.infer<typeof formSchema>

export function HospitalSignupForm() {
    const { toast } = useToast()
    const [isSubmitting, setIsSubmitting] = useState(false)
    const [submissionStatus, setSubmissionStatus] = useState<"idle" | "success" | "error">("idle")
    const [errorMessage, setErrorMessage] = useState("")

    // Initialize the form
    const form = useForm<FormValues>({
        resolver: zodResolver(formSchema),
        defaultValues: {
            name: "",
            email: "",
            password: "",
            address: "",
            contactNumber: "",
            description: "",
        },
    })

    // Handle form submission
    const onSubmit = async (data: FormValues) => {
        setIsSubmitting(true)
        setSubmissionStatus("idle")
        setErrorMessage("")

        try {
            console.log("[ADMIN] Submitting hospital signup form:", data)

            // Add the hospital to the system
            const hospitalId = await addHospital({
                name: data.name,
                email: data.email,
                password: data.password,
                address: data.address,
                mobile: data.contactNumber,
                description: data.description || "",
                role: "hospital",
            })

            console.log("[ADMIN] Hospital added successfully with ID:", hospitalId)

            // Show success message
            setSubmissionStatus("success")
            toast({
                title: "Success",
                description: "Hospital account created successfully",
            })

            // Reset the form
            form.reset()
        } catch (error: any) {
            console.error("[ADMIN] Error adding hospital:", error)
            setSubmissionStatus("error")
            setErrorMessage(error.message || "Failed to create hospital account")
            toast({
                title: "Error",
                description: error.message || "Failed to create hospital account",
                variant: "destructive",
            })
        } finally {
            setIsSubmitting(false)
        }
    }

    return (
        <Card className="w-full max-w-2xl mx-auto">
            <CardHeader>
                <CardTitle className="text-2xl">Add New Hospital</CardTitle>
                <CardDescription>
                    Create a new hospital account in the system. The hospital administrator will receive an email with login
                    instructions.
                </CardDescription>
            </CardHeader>
            <CardContent>
                {submissionStatus === "success" && (
                    <Alert className="mb-6 bg-green-50 border-green-200">
                        <CheckCircle2 className="h-4 w-4 text-green-600" />
                        <AlertTitle className="text-green-800">Success</AlertTitle>
                        <AlertDescription className="text-green-700">
                            Hospital account has been created successfully.
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
                                        <FormLabel>Hospital Name</FormLabel>
                                        <FormControl>
                                            <Input placeholder="General Hospital" {...field} />
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
                                            <Input type="email" placeholder="admin@hospital.com" {...field} />
                                        </FormControl>
                                        <FormDescription>This will be used for the administrator account</FormDescription>
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
                                name="contactNumber"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>Contact Number</FormLabel>
                                        <FormControl>
                                            <Input placeholder="+1 (555) 123-4567" {...field} />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                        </div>

                        <FormField
                            control={form.control}
                            name="address"
                            render={({ field }) => (
                                <FormItem>
                                    <FormLabel>Address</FormLabel>
                                    <FormControl>
                                        <Input placeholder="123 Main St, City, State, ZIP" {...field} />
                                    </FormControl>
                                    <FormMessage />
                                </FormItem>
                            )}
                        />

                        <FormField
                            control={form.control}
                            name="description"
                            render={({ field }) => (
                                <FormItem>
                                    <FormLabel>Description</FormLabel>
                                    <FormControl>
                                        <Textarea
                                            placeholder="Brief description of the hospital, specialties, etc."
                                            className="min-h-[100px]"
                                            {...field}
                                        />
                                    </FormControl>
                                    <FormDescription>Optional. Information about the hospital.</FormDescription>
                                    <FormMessage />
                                </FormItem>
                            )}
                        />

                        <div className="flex justify-end">
                            <Button type="submit" disabled={isSubmitting}>
                                {isSubmitting && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                                {isSubmitting ? "Creating Account..." : "Create Hospital Account"}
                            </Button>
                        </div>
                    </form>
                </Form>
            </CardContent>
        </Card>
    )
}

