import { DoctorSignupForm } from "@/components/admin/doctor-signup-form"
import { Button } from "@/components/ui/button"
import Link from "next/link"
import { ArrowLeft } from "lucide-react"

export default function AddDoctorPage() {
    return (
        <div className="space-y-6">
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight">Add New Doctor</h1>
                    <p className="text-muted-foreground">Create a new doctor account in the system</p>
                </div>
                <Button variant="outline" asChild>
                    <Link href="/dashboard/admin/doctors">
                        <ArrowLeft className="mr-2 h-4 w-4" />
                        Back to Doctors
                    </Link>
                </Button>
            </div>

            <DoctorSignupForm />
        </div>
    )
}

