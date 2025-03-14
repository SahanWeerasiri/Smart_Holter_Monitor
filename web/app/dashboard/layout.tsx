"use client"

import type React from "react"

import { useEffect, useState } from "react"
import { useRouter, usePathname } from "next/navigation"
import Link from "next/link"
import { Button } from "@/components/ui/button"
import { LayoutDashboard, Users, Building2, Stethoscope, FileText, Settings, LogOut, Menu, X } from "lucide-react"
import { cn } from "@/lib/utils"
import { getCurrentUser, signOut } from "@/lib/firebase/auth"
import { getUserRole } from "@/lib/firebase/firestore"

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<any>(null)
  const [role, setRole] = useState<string | null>(null)
  const [loading, setLoading] = useState(true)
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false)
  const router = useRouter()
  const pathname = usePathname()

  useEffect(() => {
    const checkAuth = async () => {
      try {
        const currentUser = await getCurrentUser()
        if (!currentUser) {
          router.push("/login")
          return
        }

        setUser(currentUser)
        const userRole = await getUserRole(currentUser.uid)
        setRole(userRole)
      } catch (error) {
        console.error("Authentication error:", error)
        router.push("/login")
      } finally {
        setLoading(false)
      }
    }

    checkAuth()
  }, [router])

  const handleSignOut = async () => {
    try {
      await signOut()
      router.push("/login")
    } catch (error) {
      console.error("Sign out error:", error)
    }
  }

  if (loading) {
    return (
      <div className="flex h-screen items-center justify-center">
        <div className="h-8 w-8 animate-spin rounded-full border-4 border-primary border-t-transparent"></div>
      </div>
    )
  }

  const isAdmin = role === "admin"

  const navItems = [
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
    {
      name: "Holter Monitors",
      href: "/dashboard/monitors",
      icon: Stethoscope,
      active: pathname.startsWith("/dashboard/monitors"),
    },
    {
      name: "Reports",
      href: "/dashboard/reports",
      icon: FileText,
      active: pathname.startsWith("/dashboard/reports"),
    },
  ]

  // Admin-only navigation items
  if (isAdmin) {
    navItems.push(
      {
        name: "Doctors",
        href: "/dashboard/doctors",
        icon: Users,
        active: pathname.startsWith("/dashboard/doctors"),
      },
      {
        name: "Hospitals",
        href: "/dashboard/hospitals",
        icon: Building2,
        active: pathname.startsWith("/dashboard/hospitals"),
      },
    )
  }

  return (
    <div className="flex min-h-screen flex-col md:flex-row">
      {/* Mobile menu button */}
      <div className="flex h-16 items-center border-b px-4 md:hidden">
        <Button variant="ghost" size="icon" onClick={() => setMobileMenuOpen(!mobileMenuOpen)}>
          {mobileMenuOpen ? <X className="h-6 w-6" /> : <Menu className="h-6 w-6" />}
        </Button>
        <span className="ml-2 font-bold">SmartCare</span>
      </div>

      {/* Sidebar */}
      <aside
        className={cn(
          "fixed inset-y-0 left-0 z-50 w-64 transform border-r bg-background transition-transform duration-300 ease-in-out md:relative md:translate-x-0",
          mobileMenuOpen ? "translate-x-0" : "-translate-x-full",
        )}
      >
        <div className="flex h-16 items-center border-b px-6">
          <Link href="/dashboard" className="flex items-center">
            <span className="font-bold">SmartCare</span>
          </Link>
        </div>
        <div className="flex flex-col justify-between h-[calc(100%-4rem)]">
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
                onClick={() => setMobileMenuOpen(false)}
              >
                <item.icon className="mr-3 h-5 w-5" />
                {item.name}
              </Link>
            ))}
          </nav>
          <div className="p-4 space-y-1">
            <Link
              href="/dashboard/settings"
              className={cn(
                "flex items-center rounded-md px-3 py-2 text-sm font-medium",
                pathname === "/dashboard/settings"
                  ? "bg-primary text-primary-foreground"
                  : "text-muted-foreground hover:bg-muted hover:text-foreground",
              )}
              onClick={() => setMobileMenuOpen(false)}
            >
              <Settings className="mr-3 h-5 w-5" />
              Settings
            </Link>
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
      </aside>

      {/* Main content */}
      <div className="flex-1">
        <main className="p-4 md:p-6">{children}</main>
      </div>
    </div>
  )
}

