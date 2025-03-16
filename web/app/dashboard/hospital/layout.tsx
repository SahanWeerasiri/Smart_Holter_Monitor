"use client"

import type React from "react"

import Link from "next/link"
import { usePathname } from "next/navigation"
import { Activity, LayoutDashboard, Settings, Users } from "lucide-react"

interface DashboardLayoutProps {
    children: React.ReactNode
}

export default function DashboardLayout({ children }: DashboardLayoutProps) {
    return (
        <div className="flex min-h-screen">
            <aside className="border-r hidden w-60 flex-none border-gray-200 bg-white py-10 px-4 lg:block">
                <nav className="space-y-1">
                    <NavItem href="/dashboard/hospital" icon={<LayoutDashboard className="h-5 w-5" />}>
                        Dashboard
                    </NavItem>
                    <NavItem href="/dashboard/hospital/doctors" icon={<Users className="h-5 w-5" />}>
                        Doctors
                    </NavItem>
                    <NavItem href="/dashboard/hospital/monitors" icon={<Activity className="h-5 w-5" />}>
                        Monitors
                    </NavItem>
                    <NavItem href="/dashboard/hospital/settings" icon={<Settings className="h-5 w-5" />}>
                        Settings
                    </NavItem>
                </nav>
            </aside>
            <div className="flex-1">
                <main className="container py-10">{children}</main>
            </div>
        </div>
    )
}

function NavItem({
    href,
    icon,
    children,
}: {
    href: string
    icon: React.ReactNode
    children: React.ReactNode
}) {
    const pathname = usePathname()
    const isActive = pathname === href || pathname?.startsWith(`${href}/`)

    return (
        <Link
            href={href}
            className={`group flex items-center rounded-md px-3 py-2 text-sm font-medium ${isActive ? "bg-gray-100 text-gray-900" : "text-gray-600 hover:bg-gray-50 hover:text-gray-900"
                }`}
        >
            <span className={`mr-3 ${isActive ? "text-gray-900" : "text-gray-400 group-hover:text-gray-900"}`}>{icon}</span>
            {children}
        </Link>
    )
}

