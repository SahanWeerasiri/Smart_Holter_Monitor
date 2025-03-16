import { Skeleton } from "@/components/ui/skeleton"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Separator } from "@/components/ui/separator"

export default function HospitalMonitorsLoading() {
    return (
        <div className="space-y-6">
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-2xl font-bold tracking-tight">Holter Monitors</h1>
                    <p className="text-muted-foreground">Manage your hospital's holter monitors</p>
                </div>
                <Skeleton className="h-10 w-32" />
            </div>
            <Separator />
            <Card>
                <CardHeader>
                    <CardTitle>Holter Monitors</CardTitle>
                    <CardDescription>View and manage all holter monitors in your hospital</CardDescription>
                </CardHeader>
                <CardContent>
                    <div className="space-y-4">
                        <div className="flex justify-between items-center">
                            <Skeleton className="h-5 w-32" />
                            <Skeleton className="h-5 w-32" />
                            <Skeleton className="h-5 w-24" />
                            <Skeleton className="h-5 w-32" />
                            <Skeleton className="h-5 w-16" />
                        </div>
                        <Separator />
                        {Array(5)
                            .fill(0)
                            .map((_, i) => (
                                <div key={i} className="flex justify-between items-center py-2">
                                    <Skeleton className="h-5 w-24" />
                                    <Skeleton className="h-5 w-40" />
                                    <Skeleton className="h-5 w-20" />
                                    <Skeleton className="h-5 w-32" />
                                    <Skeleton className="h-8 w-8 rounded-full" />
                                </div>
                            ))}
                    </div>
                </CardContent>
            </Card>
        </div>
    )
}

