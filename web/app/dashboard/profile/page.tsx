"use client"

import { useState, useEffect } from "react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card"
import { AlertCircle, Save, Lock, User, Mail, Building, Phone } from "lucide-react"
import { Alert, AlertDescription } from "@/components/ui/alert"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { getDoctorProfile, updateDoctorProfile, updatePassword } from "@/lib/firebase/firestore"
import { Camera, Upload, Trash2, Loader2 } from "lucide-react"

interface DoctorProfile {
  id: string
  name: string
  email: string | null
  specialization: string
  hospitalName: string
  contactNumber: string
  bio: string
  photoURL: string
}

export default function ProfilePage() {
  const [profile, setProfile] = useState<DoctorProfile | null>(null)
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState("")
  const [success, setSuccess] = useState("")
  const [activeTab, setActiveTab] = useState("profile")
  const [newImage, setNewImage] = useState<string | null>(null)
  const [imageFile, setImageFile] = useState<File | null>(null)

  const [profileForm, setProfileForm] = useState({
    name: "",
    specialization: "",
    contactNumber: "",
    bio: "",
  })

  const [passwordForm, setPasswordForm] = useState({
    currentPassword: "",
    newPassword: "",
    confirmPassword: "",
  })

  useEffect(() => {
    const fetchProfile = async () => {
      try {
        const profileData = await getDoctorProfile()
        setProfile(profileData)
        setProfileForm({
          name: profileData.name,
          specialization: profileData.specialization,
          contactNumber: profileData.contactNumber || "",
          bio: profileData.bio || "",
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

  const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (!file) return

    // Check if the file is an image
    if (!file.type.match('image.*')) {
      setError('Please select an image file')
      return
    }

    // Check file size (e.g., 2MB limit)
    if (file.size > 2 * 1024 * 1024) {
      setError('Image size should be less than 2MB')
      return
    }

    setImageFile(file)

    const reader = new FileReader()
    reader.onload = (event) => {
      if (event.target?.result) {
        setNewImage(event.target.result as string)
      }
    }
    reader.readAsDataURL(file)
  }

  const handleUpdateProfile = async () => {
    try {
      setError("")
      setSuccess("")
      setSaving(true)

      if (!profileForm.name) {
        setError("Name is required")
        return
      }

      // Prepare update data
      const updateData: Partial<DoctorProfile> = {
        name: profileForm.name,
        specialization: profileForm.specialization,
        contactNumber: profileForm.contactNumber,
        bio: profileForm.bio,
      }

      // If new image was selected, include it in the update
      if (newImage) {
        updateData.photoURL = "data:image/jpeg;base64," + newImage
      }

      await updateDoctorProfile(updateData)

      setSuccess("Profile updated successfully")

      // Update local state
      setProfile((prev) => {
        if (!prev) return null
        return {
          ...prev,
          ...updateData,
          photoURL: newImage || prev.photoURL,
        }
      })

      // Reset image state after successful update
      setNewImage(null)
      setImageFile(null)
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
        <h1 className="text-3xl font-bold tracking-tight">Profile</h1>
        <p className="text-muted-foreground">Manage your account settings and preferences</p>
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
                <AvatarImage src={profile?.photoURL || ""} alt={profile?.name || "Doctor"} />
                <AvatarFallback className="text-2xl">{profile?.name?.charAt(0) || "D"}</AvatarFallback>
              </Avatar>
              <div className="text-center">
                <CardTitle>{profile?.name}</CardTitle>
                <CardDescription>{profile?.specialization}</CardDescription>
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
                <Building className="mr-2 h-4 w-4 text-muted-foreground" />
                <span>{profile?.hospitalName}</span>
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
                <User className="mr-2 h-4 w-4" />
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
                  <CardTitle>Profile Information</CardTitle>
                  <CardDescription>Update your personal information and profile picture</CardDescription>
                </CardHeader>
                <CardContent className="space-y-6">
                  {/* Profile Picture Section */}
                  <div className="flex flex-col items-center gap-4">
                    <div className="relative group">
                      <Avatar className="h-32 w-32">
                        <AvatarImage src={newImage || profile?.photoURL || ""} alt={profile?.name || "Doctor"} />
                        <AvatarFallback className="text-4xl">
                          {profile?.name?.split(' ').map(n => n[0]).join('') || "DR"}
                        </AvatarFallback>
                      </Avatar>
                      <label
                        htmlFor="profile-image"
                        className="absolute inset-0 bg-black/50 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity rounded-full cursor-pointer"
                      >
                        <Camera className="h-6 w-6 text-white" />
                      </label>
                    </div>
                    <div className="flex gap-2">
                      <label htmlFor="profile-image">
                        <Button variant="outline" size="sm" type="button">
                          <Upload className="mr-2 h-4 w-4" />
                          {newImage ? "Change Photo" : "Upload Photo"}
                        </Button>
                      </label>
                      {newImage && (
                        <Button
                          variant="outline"
                          size="sm"
                          type="button"
                          onClick={() => {
                            setNewImage(null);
                            setImageFile(null);
                          }}
                        >
                          <Trash2 className="mr-2 h-4 w-4" />
                          Remove
                        </Button>
                      )}
                    </div>
                    <input
                      id="profile-image"
                      type="file"
                      accept="image/*"
                      className="hidden"
                      onChange={handleImageChange}
                    />
                    {imageFile && (
                      <p className="text-sm text-muted-foreground">
                        Selected: {imageFile.name} ({(imageFile.size / 1024).toFixed(2)} KB)
                      </p>
                    )}
                  </div>

                  {/* Profile Form Section */}
                  <div className="space-y-4">
                    <div className="space-y-2">
                      <Label htmlFor="name">Full Name</Label>
                      <Input
                        id="name"
                        value={profileForm.name}
                        onChange={(e) => setProfileForm({ ...profileForm, name: e.target.value })}
                      />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="specialization">Specialization</Label>
                      <Input
                        id="specialization"
                        value={profileForm.specialization}
                        onChange={(e) => setProfileForm({ ...profileForm, specialization: e.target.value })}
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
                      <Label htmlFor="bio">Professional Bio</Label>
                      <textarea
                        id="bio"
                        value={profileForm.bio}
                        onChange={(e) => setProfileForm({ ...profileForm, bio: e.target.value })}
                        className="flex min-h-[120px] w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
                        placeholder="Tell us about your professional background and expertise..."
                      />
                    </div>
                  </div>
                </CardContent>
                <CardFooter className="flex justify-end">
                  <Button onClick={handleUpdateProfile} disabled={saving}>
                    {saving ? (
                      <>
                        <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                        Saving...
                      </>
                    ) : (
                      <>
                        <Save className="mr-2 h-4 w-4" />
                        Save Changes
                      </>
                    )}
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

