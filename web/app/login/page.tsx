"use client"

import type React from "react"

import { useState, useCallback } from "react"
import { useRouter } from "next/navigation"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card"
import { AlertCircle, Info } from "lucide-react"
import { Alert, AlertDescription } from "@/components/ui/alert"
import Link from "next/link"
import { signIn } from "@/lib/firebase/auth"

export default function LoginPage() {
  const [email, setEmail] = useState("")
  const [password, setPassword] = useState("")
  const [error, setError] = useState("")
  const [loading, setLoading] = useState(false)
  const [showDevCredentials, setShowDevCredentials] = useState(false)
  const router = useRouter()

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError("")
    setLoading(true)
    console.log(`[LOGIN] Login attempt for email: ${email}`)

    try {
      const userWithRole = await signIn(email, password)
      console.log(`[LOGIN] Login successful, user role: ${userWithRole.role}`)

      // Redirect based on user role
      if (userWithRole.role === "admin") {
        console.log(`[LOGIN] Redirecting admin to admin dashboard`)
        router.push("/dashboard/admin")
      } else if (userWithRole.role === "doctor") {
        console.log(`[LOGIN] Redirecting doctor to doctor dashboard`)
        router.push("/dashboard")
      } else if (userWithRole.role === "hospital") {
        console.log(`[LOGIN] Redirecting hospital to hospital dashboard`)
        router.push("/dashboard/hospital")
      } else {
        // Default fallback
        console.log(`[LOGIN] Role not recognized, using default redirect`)
        router.push("/dashboard")
      }
    } catch (err: any) {
      console.error(`[LOGIN] Login error:`, err)
      setError(err.message || "Failed to login")
    } finally {
      setLoading(false)
    }
  }

  const useDevCredentials = useCallback(
    (type: "admin" | "doctor" | "hospital") => {
      if (type === "admin") {
        setEmail("admin@smartcare.com")
        setPassword("admin123")
      } else if (type === "doctor") {
        setEmail("doctor@smartcare.com")
        setPassword("doctor123")
      } else if (type === "hospital") {
        setEmail("hospital@smartcare.com")
        setPassword("hospital123")
      }
    },
    [setEmail, setPassword],
  )

  return (
    <div className="flex min-h-screen items-center justify-center bg-muted/40 p-4">
      <Card className="w-full max-w-md">
        <CardHeader className="space-y-1">
          <div className="flex items-center justify-between">
            <CardTitle className="text-2xl font-bold">Login</CardTitle>
            <Button
              variant="ghost"
              size="icon"
              onClick={() => setShowDevCredentials(!showDevCredentials)}
              title="Show development credentials"
            >
              <Info className="h-4 w-4" />
            </Button>
          </div>
          <CardDescription>Enter your credentials to access your account</CardDescription>
        </CardHeader>
        <form onSubmit={handleSubmit}>
          <CardContent className="space-y-4">
            {showDevCredentials && (
              <Alert className="bg-blue-50 border-blue-200">
                <div className="mb-2 font-medium">Development Credentials:</div>
                <div className="space-y-2 text-sm">
                  <div className="flex gap-2">
                    <Button size="sm" variant="outline" onClick={() => useDevCredentials("admin")}>
                      Use Admin
                    </Button>
                    <span className="flex items-center">admin@smartcare.com / admin123</span>
                  </div>
                  <div className="flex gap-2">
                    <Button size="sm" variant="outline" onClick={() => useDevCredentials("hospital")}>
                      Use Hospital
                    </Button>
                    <span className="flex items-center">hospital@smartcare.com / hospital123</span>
                  </div>
                  <div className="flex gap-2">
                    <Button size="sm" variant="outline" onClick={() => useDevCredentials("doctor")}>
                      Use Doctor
                    </Button>
                    <span className="flex items-center">doctor@smartcare.com / doctor123</span>
                  </div>
                </div>
              </Alert>
            )}

            {error && (
              <Alert variant="destructive">
                <AlertCircle className="h-4 w-4" />
                <AlertDescription>{error}</AlertDescription>
              </Alert>
            )}
            <div className="space-y-2">
              <Label htmlFor="email">Email</Label>
              <Input
                id="email"
                type="email"
                placeholder="m.edwards@example.com"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
            </div>
            <div className="space-y-2">
              <div className="flex items-center justify-between">
                <Label htmlFor="password">Password</Label>
                <Link href="/forgot-password" className="text-xs text-primary hover:underline">
                  Forgot password?
                </Link>
              </div>
              <Input
                id="password"
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
            </div>
          </CardContent>
          <CardFooter>
            <Button type="submit" className="w-full" disabled={loading}>
              {loading ? "Logging in..." : "Login"}
            </Button>
          </CardFooter>
        </form>
      </Card>
    </div>
  )
}

