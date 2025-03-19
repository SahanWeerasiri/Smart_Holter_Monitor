"use client"

import { useState, useEffect } from "react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card"
import { AlertCircle, Save, Lock, Building, Mail, Phone, MapPin } from "lucide-react"
import { Alert, AlertDescription } from "@/components/ui/alert"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { getHospitalProfile, updateHospitalProfile, updatePassword } from "@/lib/firebase/firestore"

interface HospitalProfile {
  id: string
  name: string
  email: string
  address: string
  contactNumber: string
  description: string
  photoURL: string
}

export default function HospitalSettingsPage() {
  const [profile, setProfile] = useState<HospitalProfile | null>(null)
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState("")
  const [success, setSuccess] = useState("")
  const [activeTab, setActiveTab] = useState("profile")

  const [profileForm, setProfileForm] = useState({
    name: "",
    address: "",
    contactNumber: "",
    description: "",
  })

  const [passwordForm, setPasswordForm] = useState({
    currentPassword: "",
    newPassword: "",
    confirmPassword: "",
  })

  useEffect(() => {
    const fetchProfile = async () => {
      try {
        const profileData = await getHospitalProfile()
        setProfile(profileData)
        setProfileForm({
          name: profileData.name,
          address: profileData.address || "",
          contactNumber: profileData.contactNumber || "",
          description: profileData.description || "",
        })
      } catch (error) {
        console.error("Error fetching profile:", error)
        setError("Failed to load profile data. Please try again.")
      } finally {
        setLoading(false)
      }
    }

    fetchProfile()
  }, [])

  const handleUpdateProfile = async () => {
    try {
      setError("")
      setSuccess("")
      setSaving(true)

      if (!profileForm.name) {
        setError("Hospital name is required")
        return
      }

      await updateHospitalProfile({
        name: profileForm.name,
        address: profileForm.address,
        contactNumber: profileForm.contactNumber,
        description: profileForm.description,
      })

      setSuccess("Profile updated successfully")

      // Update local state
      setProfile((prev) => {
        if (!prev) return null
        return {
          ...prev,
          name: profileForm.name,
          address: profileForm.address,
          contactNumber: profileForm.contactNumber,
          description: profileForm.description,
        }
      })
    } catch (error) {
      console.error("Error updating profile:", error)
      setError("Failed to update profile. Please try again.")
    } finally {
      setSaving(false)
    }
  }

  const handleUpdatePassword = async () => {
    try {
      setError("")
      setSuccess("")
      setSaving(true)

      if (!passwordForm.currentPassword || !passwordForm.newPassword || !passwordForm.confirmPassword) {
        setError("All password fields are required")
        return
      }

      if (passwordForm.newPassword !== passwordForm.confirmPassword) {
        setError("New passwords do not match")
        return
      }

      if (passwordForm.newPassword.length < 8) {
        setError("New password must be at least 8 characters long")
        return
      }

      await updatePassword(passwordForm.currentPassword, passwordForm.newPassword)

      setSuccess("Password updated successfully")
      setPasswordForm({
        currentPassword: "",
        newPassword: "",
        confirmPassword: "",
      })
    } catch (error) {
      console.error("Error updating password:", error)
      setError("Failed to update password. Please ensure your current password is correct.")
    } finally {
      setSaving(false)
    }
  }

  if (loading) {
    return (
      <div className="flex h-[calc(100vh-4rem)] items-center justify-center">
        <div className="h-8 w-8 animate-spin rounded-full border-4 border-primary border-t-transparent"></div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold tracking-tight">Hospital Settings</h1>
        <p className="text-muted-foreground">Manage your hospital settings and preferences</p>
      </div>

      {error && (
        <Alert variant="destructive">
          <AlertCircle className="h-4 w-4" />
          <AlertDescription>{error}</AlertDescription>
        </Alert>
      )}

      {success && (
        <Alert>
          <AlertCircle className="h-4 w-4" />
          <AlertDescription>{success}</AlertDescription>
        </Alert>
      )}

      <div className="flex flex-col md:flex-row gap-6">
        <Card className="md:w-80">
          <CardHeader>
            <div className="flex flex-col items-center space-y-2">
              <Avatar className="h-24 w-24">
                <AvatarImage src={profile?.photoURL || ""} alt={profile?.name || "Hospital"} />
                <AvatarFallback className="text-2xl">{profile?.name?.charAt(0) || "H"}</AvatarFallback>
              </Avatar>
              <div className="text-center">
                <CardTitle>{profile?.name}</CardTitle>
                <CardDescription>{profile?.address}</CardDescription>
              </div>
            </div>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              <div className="flex items-center">
                <Mail className="mr-2 h-4 w-4 text-muted-foreground" />
                <span>{profile?.email}</span>
              </div>
              <div className="flex items-center">
                <MapPin className="mr-2 h-4 w-4 text-muted-foreground" />
                <span>{profile?.address || "No address provided"}</span>
              </div>
              {profile?.contactNumber && (
                <div className="flex items-center">
                  <Phone className="mr-2 h-4 w-4 text-muted-foreground" />
                  <span>{profile.contactNumber}</span>
                </div>
              )}
            </div>
          </CardContent>
        </Card>

        <div className="flex-1">
          <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
            <TabsList className="grid w-full max-w-md grid-cols-2">
              <TabsTrigger value="profile">
                <Building className="mr-2 h-4 w-4" />
                Profile
              </TabsTrigger>
              <TabsTrigger value="security">
                <Lock className="mr-2 h-4 w-4" />
                Security
              </TabsTrigger>
            </TabsList>
            <TabsContent value="profile" className="space-y-4 pt-4">
              <Card>
                <CardHeader>
                  <CardTitle>Hospital Information</CardTitle>
                  <CardDescription>Update your hospital information</CardDescription>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="space-y-2">
                    <Label htmlFor="name">Hospital Name</Label>
                    <Input
                      id="name"
                      value={profileForm.name}
                      onChange={(e) => setProfileForm({ ...profileForm, name: e.target.value })}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="address">Address</Label>
                    <Input
                      id="address"
                      value={profileForm.address}
                      onChange={(e) => setProfileForm({ ...profileForm, address: e.target.value })}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="contactNumber">Contact Number</Label>
                    <Input
                      id="contactNumber"
                      value={profileForm.contactNumber}
                      onChange={(e) => setProfileForm({ ...profileForm, contactNumber: e.target.value })}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="description">Description</Label>
                    <textarea
                      id="description"
                      value={profileForm.description}
                      onChange={(e) => setProfileForm({ ...profileForm, description: e.target.value })}
                      className="flex min-h-[120px] w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
                    />
                  </div>
                </CardContent>
                <CardFooter>
                  <Button onClick={handleUpdateProfile} disabled={saving}>
                    <Save className="mr-2 h-4 w-4" />
                    {saving ? "Saving..." : "Save Changes"}
                  </Button>
                </CardFooter>
              </Card>
            </TabsContent>
            <TabsContent value="security" className="space-y-4 pt-4">
              <Card>
                <CardHeader>
                  <CardTitle>Change Password</CardTitle>
                  <CardDescription>Update your password to keep your account secure</CardDescription>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="space-y-2">
                    <Label htmlFor="currentPassword">Current Password</Label>
                    <Input
                      id="currentPassword"
                      type="password"
                      value={passwordForm.currentPassword}
                      onChange={(e) => setPasswordForm({ ...passwordForm, currentPassword: e.target.value })}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="newPassword">New Password</Label>
                    <Input
                      id="newPassword"
                      type="password"
                      value={passwordForm.newPassword}
                      onChange={(e) => setPasswordForm({ ...passwordForm, newPassword: e.target.value })}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="confirmPassword">Confirm New Password</Label>
                    <Input
                      id="confirmPassword"
                      type="password"
                      value={passwordForm.confirmPassword}
                      onChange={(e) => setPasswordForm({ ...passwordForm, confirmPassword: e.target.value })}
                    />
                  </div>
                </CardContent>
                <CardFooter>
                  <Button onClick={handleUpdatePassword} disabled={saving}>
                    <Lock className="mr-2 h-4 w-4" />
                    {saving ? "Updating..." : "Update Password"}
                  </Button>
                </CardFooter>
              </Card>
            </TabsContent>
          </Tabs>
        </div>
      </div>
    </div>
  )
}

