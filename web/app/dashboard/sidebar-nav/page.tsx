"use client"

import { useState, useEffect } from "react"
import Link from "next/link"
import { usePathname } from "next/navigation"
import { cn } from "@/lib/utils"
import {
    LayoutDashboard,
    Users,
    Stethoscope,
    FileText,
    Settings,
    LogOut,
    UserCog,
    Building2,
    MessageSquare,
    Activity,
} from "lucide-react"
import { getCurrentUser, signOut, type UserWithRole } from "@/lib/firebase/auth"
import { Button } from "@/components/ui/button"

interface SidebarNavProps {
    className?: string
    closeMobileMenu?: () => void
}

export function SidebarNav({ className, closeMobileMenu }: SidebarNavProps) {
    const [user, setUser] = useState<UserWithRole | null>(null)
    const [role, setRole] = useState<string | null>(null)
    const pathname = usePathname()

    useEffect(() => {
        const checkAuth = async () => {
            try {
                const currentUser = await getCurrentUser()

                // For development purposes, if we don't have a user but have a role in localStorage, use that
                if (!currentUser) {
                    const storedRole = localStorage.getItem("userRole")
                    if (storedRole) {
                        setRole(storedRole)
                        console.log("Using stored role from localStorage:", storedRole)
                        return
                    }
                }

                setUser(currentUser)
                setRole(currentUser?.role || null)

                // Store role in localStorage for development fallback
                if (currentUser?.role) {
                    localStorage.setItem("userRole", currentUser.role)
                }
            } catch (error) {
                console.error("Authentication error in sidebar:", error)

                // Fallback to localStorage for development
                const storedRole = localStorage.getItem("userRole")
                if (storedRole) {
                    setRole(storedRole)
                    console.log("Fallback: Using stored role from localStorage:", storedRole)
                }
            }
        }

        checkAuth()
    }, [])

    // Define navigation items based on user role
    let navItems: any[] = []

    if (role === "admin") {
        navItems = [
            // {
            //     name: "Dashboard",
            //     href: "/dashboard/admin",
            //     icon: LayoutDashboard,
            //     active: pathname === "/dashboard/admin",
            // },
            {
                name: "Doctors",
                href: "/dashboard/admin/doctors",
                icon: UserCog,
                active: pathname.startsWith("/dashboard/admin/doctors"),
            },
            {
                name: "Hospitals",
                href: "/dashboard/admin/hospitals",
                icon: Building2,
                active: pathname.startsWith("/dashboard/admin/hospitals"),
            },
            // {
            //     name: "Patients",
            //     href: "/dashboard/admin/patients",
            //     icon: Users,
            //     active: pathname.startsWith("/dashboard/admin/patients"),
            // },
            // {
            //     name: "Holter Monitors",
            //     href: "/dashboard/admin/monitors",
            //     icon: Stethoscope,
            //     active: pathname.startsWith("/dashboard/admin/monitors"),
            // },
            // {
            //     name: "Reports",
            //     href: "/dashboard/admin/reports",
            //     icon: FileText,
            //     active: pathname.startsWith("/dashboard/admin/reports"),
            // },
            // {
            //     name: "Settings",
            //     href: "/dashboard/admin/settings",
            //     icon: Settings,
            //     active: pathname === "/dashboard/admin/settings",
            // },
        ]
    } else if (role === "doctor") {
        navItems = [
            {
                name: "Dashboard",
                href: "/dashboard",
                icon: LayoutDashboard,
                active: pathname === "/dashboard",
            },
            {
                name: "Patients",
                href: "/dashboard/patients",
                icon: Users,
                active: pathname.startsWith("/dashboard/patients"),
            },
            // {
            //     name: "Holter Monitors",
            //     href: "/dashboard/monitors",
            //     icon: Stethoscope,
            //     active: pathname.startsWith("/dashboard/monitors"),
            // },
            {
                name: "Reports",
                href: "/dashboard/reports",
                icon: FileText,
                active: pathname.startsWith("/dashboard/reports"),
            },
            {
                name: "AI Assistant",
                href: "/dashboard/chat",
                icon: MessageSquare,
                active: pathname.startsWith("/dashboard/chat"),
            },
            {
                name: "Profile",
                href: "/dashboard/profile",
                icon: Settings,
                active: pathname === "/dashboard/profile",
            },
        ]
    } else if (role === "hospital") {
        navItems = [
            {
                name: "Dashboard",
                href: "/dashboard/hospital",
                icon: LayoutDashboard,
                active: pathname === "/dashboard/hospital",
            },
            // {
            //     name: "Doctors",
            //     href: "/dashboard/hospital/doctors",
            //     icon: UserCog,
            //     active: pathname.startsWith("/dashboard/hospital/doctors"),
            // },
            {
                name: "Patients",
                href: "/dashboard/hospital/patients",
                icon: Users,
                active: pathname.startsWith("/dashboard/hospital/patients"),
            },
            {
                name: "Holter Monitors",
                href: "/dashboard/hospital/monitors",
                icon: Activity,
                active: pathname.startsWith("/dashboard/hospital/monitors"),
            },
            // {
            //     name: "Settings",
            //     href: "/dashboard/hospital/settings",
            //     icon: Settings,
            //     active: pathname === "/dashboard/hospital/settings",
            // },
        ]
    }

    const handleSignOut = async () => {
        try {
            await signOut()
            window.location.href = "/"
        } catch (error) {
            console.error("Sign out error:", error)
        }
    }

    return (
        <div className={cn("flex flex-col justify-between h-full", className)}>
            <nav className="space-y-1 p-4">
                {navItems.map((item) => (
                    <Link
                        key={item.href}
                        href={item.href}
                        className={cn(
                            "flex items-center rounded-md px-3 py-2 text-sm font-medium",
                            item.active
                                ? "bg-primary text-primary-foreground"
                                : "text-muted-foreground hover:bg-muted hover:text-foreground",
                        )}
                        onClick={closeMobileMenu}
                    >
                        <item.icon className="mr-3 h-5 w-5" />
                        {item.name}
                    </Link>
                ))}
            </nav>
            <div className="p-4">
                <Button
                    variant="ghost"
                    className="w-full justify-start px-3 py-2 text-sm font-medium text-muted-foreground hover:bg-muted hover:text-foreground"
                    onClick={handleSignOut}
                >
                    <LogOut className="mr-3 h-5 w-5" />
                    Sign out
                </Button>
            </div>
        </div>
    )
}

