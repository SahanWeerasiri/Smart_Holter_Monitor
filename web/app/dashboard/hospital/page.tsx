"use client"

import { useEffect, useState } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { UserCog, Users, Stethoscope, Clock } from "lucide-react"
import { getHospitalStats } from "@/lib/firebase/firestore"
import { onValue, ref } from "firebase/database"
import { auth, rtdb } from "@/lib/firebase/config"

export default function HospitalDashboardPage() {
  const [stats, setStats] = useState({
    totalDoctors: 0,
    totalPatients: 0,
  })
  const [stats2, setStats2] = useState({
    activeMonitors: 0,
    availableMonitors: 0,
  })
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const hospitalStats = await getHospitalStats()
        setStats(hospitalStats)
        onValue(ref(rtdb, "devices"), (snapshot) => {
          let available = 0
          for (const key in snapshot.val()) {
            if (snapshot.val()[key].assigned === 0 && snapshot.val()[key].hospitalId === auth.currentUser?.uid) {
              available++
            }
          }
          setStats2({
            activeMonitors: snapshot.size - available,
            availableMonitors: available,
          })
        })
      } catch (error) {
        console.error("Error fetching hospital stats:", error)
      } finally {
        setLoading(false)
      }
    }

    fetchStats()
  }, [])

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
        <h1 className="text-3xl font-bold tracking-tight">Hospital Dashboard</h1>
        <p className="text-muted-foreground">Overview of your hospital's SmartCare system</p>
      </div>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Doctors</CardTitle>
            <UserCog className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.totalDoctors}</div>
            <p className="text-xs text-muted-foreground">Registered in your hospital</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Patients</CardTitle>
            <Users className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.totalPatients}</div>
            <p className="text-xs text-muted-foreground">Under your hospital's care</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Active Monitors</CardTitle>
            <Stethoscope className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats2.activeMonitors}</div>
            <p className="text-xs text-muted-foreground">Currently in use</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Available Monitors</CardTitle>
            <Clock className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats2.availableMonitors}</div>
            <p className="text-xs text-muted-foreground">Ready for assignment</p>
          </CardContent>
        </Card>
      </div>

      <Tabs defaultValue="overview" className="space-y-4">
        <TabsList>
          <TabsTrigger value="overview">Overview</TabsTrigger>
          {/* <TabsTrigger value="doctors">Doctors</TabsTrigger>
          <TabsTrigger value="patients">Patients</TabsTrigger> */}
          <TabsTrigger value="monitors">Monitors</TabsTrigger>
        </TabsList>
        <TabsContent value="overview" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>Hospital Activity</CardTitle>
              <CardDescription>Monitor the latest activities in your hospital</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                <div className="flex items-center">
                  <div className="mr-4 rounded-full bg-primary/10 p-2">
                    <Stethoscope className="h-4 w-4 text-primary" />
                  </div>
                  <div className="flex-1 space-y-1">
                    <p className="text-sm font-medium leading-none">New holter monitor assigned</p>
                    <p className="text-sm text-muted-foreground">
                      Device HM-2023-45 assigned to patient John Doe by Dr. Smith
                    </p>
                  </div>
                  <div className="text-sm text-muted-foreground">2h ago</div>
                </div>
                <div className="flex items-center">
                  <div className="mr-4 rounded-full bg-primary/10 p-2">
                    <Users className="h-4 w-4 text-primary" />
                  </div>
                  <div className="flex-1 space-y-1">
                    <p className="text-sm font-medium leading-none">New patient registered</p>
                    <p className="text-sm text-muted-foreground">Jane Smith was added to the system by Dr. Johnson</p>
                  </div>
                  <div className="text-sm text-muted-foreground">5h ago</div>
                </div>
                <div className="flex items-center">
                  <div className="mr-4 rounded-full bg-primary/10 p-2">
                    <UserCog className="h-4 w-4 text-primary" />
                  </div>
                  <div className="flex-1 space-y-1">
                    <p className="text-sm font-medium leading-none">New doctor onboarded</p>
                    <p className="text-sm text-muted-foreground">Dr. Michael Brown joined the cardiology department</p>
                  </div>
                  <div className="text-sm text-muted-foreground">1d ago</div>
                </div>
              </div>
            </CardContent>
          </Card>
        </TabsContent>
        <TabsContent value="doctors" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>Doctors Overview</CardTitle>
              <CardDescription>View detailed information about your hospital's doctors</CardDescription>
            </CardHeader>
            <CardContent className="h-[300px] flex items-center justify-center">
              <p className="text-muted-foreground">Doctors information will be displayed here</p>
            </CardContent>
          </Card>
        </TabsContent>
        <TabsContent value="patients" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>Patients Overview</CardTitle>
              <CardDescription>View detailed information about your hospital's patients</CardDescription>
            </CardHeader>
            <CardContent className="h-[300px] flex items-center justify-center">
              <p className="text-muted-foreground">Patients information will be displayed here</p>
            </CardContent>
          </Card>
        </TabsContent>
        <TabsContent value="monitors" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>Monitors Overview</CardTitle>
              <CardDescription>View detailed information about Holter monitors</CardDescription>
            </CardHeader>
            <CardContent className="h-[400px] flex-column items-center justify-center">
              <p className="mb-4">A Holter monitor is a portable device used for continuous heart activity monitoring, typically for 24 to 48 hours. It records electrical signals from the heart to detect irregularities that may not be captured during a standard ECG.</p>
              <h2 className="text-xl font-semibold text-gray-800 mb-2">Key Features</h2>
              <ul className="list-disc pl-5 mb-4">
                <li>Continuous heart rhythm recording</li>
                <li>Compact and wearable design</li>
                <li>Detects arrhythmias and other cardiac anomalies</li>
                <li>Used for diagnosing heart conditions</li>
              </ul>
              <h2 className="text-xl font-semibold text-gray-800 mb-2">Usage</h2>
              <p>The Holter monitor is attached to the patient’s chest using electrodes. It records the heart's electrical activity while the patient goes about daily activities. After the monitoring period, the recorded data is analyzed by a doctor.</p>
            </CardContent>
          </Card>
        </TabsContent>

      </Tabs>
    </div>
  )
}

