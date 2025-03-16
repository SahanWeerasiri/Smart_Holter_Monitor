import { HospitalSignupForm } from "@/components/admin/hospital-signup-form"
import { Button } from "@/components/ui/button"
import Link from "next/link"
import { ArrowLeft } from "lucide-react"

export default function AddHospitalPage() {
    return (
        <div className="space-y-6">
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight">Add New Hospital</h1>
                    <p className="text-muted-foreground">Create a new hospital account in the system</p>
                </div>
                <Button variant="outline" asChild>
                    <Link href="/dashboard/admin/hospitals">
                        <ArrowLeft className="mr-2 h-4 w-4" />
                        Back to Hospitals
                    </Link>
                </Button>
            </div>

            <HospitalSignupForm />
        </div>
    )
}

