import {
  collection,
  doc,
  getDoc,
  getDocs,
  addDoc,
  updateDoc,
  query,
  where,
  orderBy,
  limit,
  setDoc,
  collectionGroup,
  deleteDoc,
} from "firebase/firestore"
import { ref, get, set, update, remove } from "firebase/database"
import { db, rtdb, logOperation } from "./config"
import { getCurrentUser } from "./auth"
import { getAuth } from "firebase/auth"
import { generateText } from "ai"
import { openai } from "@ai-sdk/openai"
import {
  createUserWithEmailAndPassword,
  EmailAuthProvider,
  reauthenticateWithCredential,
  updatePassword as firebaseUpdatePassword,
} from "firebase/auth"

// User roles
export const getUserRole = async (userId?: string) => {
  try {
    const user = userId ? { uid: userId } : await getCurrentUser()
    if (!user) return null

    // Check users collection first (admin, doctor, hospital)
    let userDoc = await getDoc(doc(db, "users", user.uid))

    if (userDoc.exists()) {
      logOperation("User role retrieved from users collection", { role: userDoc.data().role })
      return userDoc.data().role
    }

    // Check user_accounts collection for patients
    userDoc = await getDoc(doc(db, "user_accounts", user.uid))

    if (userDoc.exists()) {
      logOperation("User role retrieved from user_accounts collection", { role: "patient" })
      return "patient"
    }

    logOperation("No user role found", { uid: user.uid })
    return null
  } catch (error) {
    logOperation("Error getting user role", error)
    throw error
  }
}

// Dashboard stats
export const getDashboardStats = async () => {
  try {
    logOperation("Getting dashboard stats", {})

    // Get actual counts from Firestore
    const patientsQuery = query(collection(db, "user_accounts"))
    const patientsSnapshot = await getDocs(patientsQuery)

    // Get devices from Realtime Database
    const devicesRef = ref(rtdb, "devices")
    const devicesSnapshot = await get(devicesRef)
    const devices = devicesSnapshot.val() || {}

    // Count active and available monitors
    let activeMonitors = 0
    let availableMonitors = 0

    Object.values(devices).forEach((device: any) => {
      if (device.assigned) {
        activeMonitors++
      } else {
        availableMonitors++
      }
    })

    // Count pending reports
    const pendingReportsQuery = query(collectionGroup(db, "data"), where("isDone", "==", false))
    const pendingReportsSnapshot = await getDocs(pendingReportsQuery)

    const stats = {
      totalPatients: patientsSnapshot.size,
      activeMonitors,
      availableMonitors,
      pendingReports: pendingReportsSnapshot.size,
    }

    logOperation("Dashboard stats retrieved", stats)
    return stats
  } catch (error) {
    logOperation("Error getting dashboard stats", error)
    throw error
  }
}

// Doctor stats
export const getDoctorStats = async () => {
  try {
    const user = await getCurrentUser()
    if (!user) throw new Error("User not authenticated")

    logOperation("Getting doctor stats", { doctorId: user.uid })

    // Get patients for this doctor
    const patientsQuery = query(collection(db, "user_accounts"), where("doctorId", "==", user.uid))
    const patientsSnapshot = await getDocs(patientsQuery)

    // Count active monitors
    let activeMonitors = 0
    let finishedMonitors = 0
    let notAttached = 0
    let monitoring = 0
    let finished = 0

    patientsSnapshot.forEach((patientDoc) => {
      const patientData = patientDoc.data()
      if (patientData.monitorId) {
        activeMonitors++
      }

      if (!patientData.monitorId) {
        notAttached++
      } else {
        const deviceRef = ref(rtdb, `devices/${patientData.monitorId}`)
        get(deviceRef).then((snapshot) => {
          if (snapshot.exists()) {
            const deviceData = snapshot.val()
            if (deviceData.isDone) {
              finishedMonitors++
              finished++
            } else {
              monitoring++
            }
          }
        })
      }
    })

    // Count completed reports
    const reportsQuery = query(
      collectionGroup(db, "data"),
      where("isDone", "==", true),
      where("doctorId", "==", user.uid),
    )
    const reportsSnapshot = await getDocs(reportsQuery)

    // Count pending reports
    const pendingReportsQuery = query(
      collectionGroup(db, "data"),
      where("isDone", "==", false),
      where("doctorId", "==", user.uid),
    )
    const pendingReportsSnapshot = await getDocs(pendingReportsQuery)

    // Get recent patients
    const recentPatientsQuery = query(
      collection(db, "user_accounts"),
      where("doctorId", "==", user.uid),
      orderBy("createdAt", "desc"),
      limit(5),
    )
    const recentPatientsSnapshot = await getDocs(recentPatientsQuery)

    const recentPatients = recentPatientsSnapshot.docs.map((doc) => ({
      id: doc.id,
      name: doc.data().name,
      age: doc.data().age,
      gender: doc.data().gender,
      status: doc.data().status,
      lastActivity: doc.data().createdAt ? doc.data().createdAt.toDate().toISOString() : new Date().toISOString(),
      photoURL: doc.data().photoURL || null,
    }))

    // Get upcoming appointments (mock data for now)
    const upcomingAppointments: never[] = []

    const stats = {
      totalPatients: patientsSnapshot.size,
      activeMonitors,
      completedReports: reportsSnapshot.size,
      pendingReports: pendingReportsSnapshot.size,
      recentPatients,
      upcomingAppointments,
      patientsByStatus: {
        notAttached: notAttached,
        monitoring: monitoring,
        finished: finished,
      },
    }

    logOperation("Doctor stats retrieved", stats)
    return stats
  } catch (error) {
    logOperation("Error getting doctor stats", error)
    throw error
  }
}

// Hospital stats
export const getHospitalStats = async () => {
  try {
    const user = await getCurrentUser()
    if (!user) throw new Error("User not authenticated")

    logOperation("Getting hospital stats", { hospitalId: user.uid })

    // Get doctors for this hospital
    const doctorsQuery = query(
      collection(db, "users"),
      where("role", "==", "doctor"),
      where("hospitalId", "==", user.uid),
    )
    const doctorsSnapshot = await getDocs(doctorsQuery)

    // Get patients for this hospital
    const patientsQuery = query(collection(db, "user_accounts"), where("hospitalId", "==", user.uid))
    const patientsSnapshot = await getDocs(patientsQuery)

    // Get devices from Realtime Database for this hospital
    const devicesRef = ref(rtdb, "devices")
    const devicesSnapshot = await get(devicesRef)
    const devices = devicesSnapshot.val() || {}

    // Count active and available monitors
    let activeMonitors = 0
    let availableMonitors = 0

    Object.entries(devices).forEach(([_, device]: [string, any]) => {
      if (device.hospitalId === user.uid) {
        if (device.assigned) {
          activeMonitors++
        } else {
          availableMonitors++
        }
      }
    })

    const stats = {
      totalDoctors: doctorsSnapshot.size,
      totalPatients: patientsSnapshot.size,
      activeMonitors,
      availableMonitors,
      recentActivities: [],
      patientsByStatus: {
        notAttached: 0,
        monitoring: 0,
        finished: 0,
      },
      monitorUsage: 0,
    }

    logOperation("Hospital stats retrieved", stats)
    return stats
  } catch (error) {
    logOperation("Error getting hospital stats", error)
    throw error
  }
}

// Hospital doctors
export const getHospitalDoctors = async () => {
  try {
    const user = await getCurrentUser()
    if (!user) throw new Error("User not authenticated")

    logOperation("Getting hospital doctors", { hospitalId: user.uid })

    // Get doctors for this hospital
    const doctorsQuery = query(
      collection(db, "users"),
      where("role", "==", "doctor"),
      where("hospitalId", "==", user.uid),
    )
    const doctorsSnapshot = await getDocs(doctorsQuery)

    const doctors = doctorsSnapshot.docs.map((doc) => ({
      id: doc.id,
      name: doc.data().name,
      email: doc.data().email,
      specialization: doc.data().specialization || "",
      contactNumber: doc.data().mobile || "",
      pic: doc.data().pic || "",
    }))

    logOperation("Hospital doctors retrieved", { count: doctors.length })
    return doctors
  } catch (error) {
    logOperation("Error getting hospital doctors", error)
    throw error
  }
}

// Holter monitors - using Realtime Database
export const getHolterMonitors = async () => {
  try {
    logOperation("Getting holter monitors", {})

    // Get devices from Realtime Database
    const devicesRef = ref(rtdb, "devices")
    const devicesSnapshot = await get(devicesRef)
    const devices = devicesSnapshot.val() || {}

    const monitors = []

    for (const [deviceId, device] of Object.entries(devices)) {
      const deviceData = device as any

      // If monitor is assigned to a patient, get patient details
      let assignedTo = undefined
      if (deviceData.assigned) {
        try {
          const patientDoc = await getDoc(doc(db, "user_accounts", deviceData.assigned))
          if (patientDoc.exists()) {
            assignedTo = {
              patientId: patientDoc.id,
              patientName: patientDoc.data().name,
              deadline: deviceData.deadline,
            }
          }
        } catch (error) {
          logOperation("Error getting patient details for monitor", { deviceId, error })
        }
      }

      monitors.push({
        id: deviceId,
        deviceCode: deviceId,
        description: deviceData.use || "",
        status: deviceData.assigned ? "in-use" : "available",
        assignedTo,
        hospitalId: deviceData.hospitalId || "",
        isDone: deviceData.isDone || false,
      })
    }

    logOperation("Holter monitors retrieved", { count: monitors.length })
    return monitors
  } catch (error) {
    logOperation("Error getting holter monitors", error)
    throw error
  }
}

export const getAvailableHolterMonitors = async () => {
  try {
    logOperation("Getting available holter monitors", {})

    // Get devices from Realtime Database
    const devicesRef = ref(rtdb, "devices")
    const devicesSnapshot = await get(devicesRef)
    const devices = devicesSnapshot.val() || {}

    const availableMonitors = []

    for (const [deviceId, device] of Object.entries(devices)) {
      const deviceData = device as any

      if (!deviceData.assigned) {
        availableMonitors.push({
          id: deviceId,
          deviceCode: deviceId,
          description: deviceData.use || "",
        })
      }
    }

    logOperation("Available holter monitors retrieved", { count: availableMonitors.length })
    return availableMonitors
  } catch (error) {
    logOperation("Error getting available holter monitors", error)
    throw error
  }
}

export const addHolterMonitor = async (monitorData: any) => {
  try {
    const user = await getCurrentUser()
    if (!user) throw new Error("User not authenticated")

    logOperation("Adding holter monitor", { deviceCode: monitorData.deviceCode })

    // Add device to Realtime Database
    const deviceId = monitorData.deviceCode
    const deviceRef = ref(rtdb, `devices/${deviceId}`)

    await set(deviceRef, {
      use: monitorData.description,
      assigned: null,
      isDone: false,
      hospitalId: user.role === "hospital" ? user.uid : monitorData.hospitalId,
      deadline: null,
      data: [],
      other: monitorData.other || "",
    })

    logOperation("Holter monitor added", { deviceId })
    return deviceId
  } catch (error) {
    logOperation("Error adding holter monitor", error)
    throw error
  }
}

export const deleteHolterMonitor = async (monitorId: string) => {
  try {
    logOperation("Deleting holter monitor", { monitorId })

    // Delete device from Realtime Database
    const deviceRef = ref(rtdb, `devices/${monitorId}`)
    await remove(deviceRef)

    logOperation("Holter monitor deleted", { monitorId })
  } catch (error) {
    logOperation("Error deleting holter monitor", error)
    throw error
  }
}

// Patients
export const getPatients = async () => {
  try {
    const user = await getCurrentUser()
    if (!user) throw new Error("User not authenticated")

    logOperation("Getting patients", { userRole: user.role })

    let patientsQuery

    if (user.role === "admin") {
      // Admin can see all patients
      patientsQuery = query(collection(db, "user_accounts"))
    } else if (user.role === "doctor") {
      // Doctors can only see their patients
      patientsQuery = query(collection(db, "user_accounts"), where("doctorId", "==", user.uid))
    } else if (user.role === "hospital") {
      // Hospital can see all patients in their hospital
      patientsQuery = query(collection(db, "user_accounts"), where("hospitalId", "==", user.uid))
    } else {
      throw new Error("Unauthorized access")
    }

    const patientsSnapshot = await getDocs(patientsQuery)
    const patients = []

    for (const patientDoc of patientsSnapshot.docs) {
      const patientData = patientDoc.data()

      // Skip non-patient records
      if (patientData.role && patientData.role !== "patient") {
        continue
      }

      // Get monitor details if assigned
      let monitorCode = undefined
      let monitorStatus = "not_attached"

      if (patientData.monitorId) {
        // Get device from Realtime Database
        const deviceRef = ref(rtdb, `devices/${patientData.monitorId}`)
        const deviceSnapshot = await get(deviceRef)

        if (deviceSnapshot.exists()) {
          const deviceData = deviceSnapshot.val()
          monitorCode = patientData.monitorId
          monitorStatus = deviceData.isDone ? "finished" : "monitoring"
        }
      }

      // Get emergency contact
      let emergencyContact = { name: "", mobile: "" }
      const emergencySnapshot = await getDocs(collection(db, "user_accounts", patientDoc.id, "emergency"))

      if (!emergencySnapshot.empty) {
        const emergencyData = emergencySnapshot.docs[0].data()
        emergencyContact = {
          name: emergencyData.name || "",
          mobile: emergencyData.mobile || "",
        }
      }

      patients.push({
        id: patientDoc.id,
        name: patientData.name || "",
        age: patientData.age || 0,
        gender: patientData.gender || "",
        contactNumber: patientData.mobile || "",
        medicalHistory: patientData.medicalHistory || "",
        status: monitorStatus,
        monitorId: patientData.monitorId || null,
        monitorCode,
        assignedDate: patientData.assignedDate || null,
        doctorId: patientData.doctorId || null,
        emergencyContact,
      })
    }

    logOperation("Patients retrieved", { count: patients.length })
    return patients
  } catch (error) {
    logOperation("Error getting patients", error)
    throw error
  }
}

export const getPatientById = async (patientId: string) => {
  try {
    logOperation("Getting patient by ID", { patientId })

    const patientDoc = await getDoc(doc(db, "user_accounts", patientId))

    if (!patientDoc.exists()) {
      logOperation("Patient not found", { patientId })
      throw new Error("Patient not found")
    }

    const patientData = patientDoc.data()

    // Get emergency contact
    let emergencyContact = { name: "", mobile: "" }
    const emergencySnapshot = await getDocs(collection(db, "user_accounts", patientId, "emergency"))

    if (!emergencySnapshot.empty) {
      const emergencyData = emergencySnapshot.docs[0].data()
      emergencyContact = {
        name: emergencyData.name || "",
        mobile: emergencyData.mobile || "",
      }
    }

    // Get monitor status
    let status = "not_attached"

    if (patientData.monitorId) {
      // Get device from Realtime Database
      const deviceRef = ref(rtdb, `devices/${patientData.monitorId}`)
      const deviceSnapshot = await get(deviceRef)

      if (deviceSnapshot.exists()) {
        const deviceData = deviceSnapshot.val()
        status = deviceData.isDone ? "finished" : "monitoring"
      }
    }

    const patient = {
      id: patientDoc.id,
      name: patientData.name || "",
      age: patientData.age || 0,
      gender: patientData.gender || "",
      contactNumber: patientData.mobile || "",
      medicalHistory: patientData.medicalHistory || "",
      status,
      emergencyContact,
    }

    logOperation("Patient retrieved", { patientId })
    return patient
  } catch (error) {
    logOperation("Error getting patient", error)
    throw error
  }
}

export const addPatient = async (patientData: any) => {
  try {
    const user = await getCurrentUser()
    if (!user) throw new Error("User not authenticated")

    logOperation("Adding patient", { name: patientData.name })

    // Create patient document in user_accounts collection
    const patientRef = await addDoc(collection(db, "user_accounts"), {
      name: patientData.name,
      age: patientData.age,
      gender: patientData.gender,
      mobile: patientData.contactNumber,
      medicalHistory: patientData.medicalHistory || "",
      role: "patient",
      doctorId: user.role === "doctor" ? user.uid : patientData.doctorId,
      hospitalId: user.role === "hospital" ? user.uid : patientData.hospitalId,
      createdAt: new Date(),
    })

    // Add emergency contact if provided
    if (patientData.emergencyContact) {
      await addDoc(collection(db, "user_accounts", patientRef.id, "emergency"), {
        name: patientData.emergencyContact.name,
        mobile: patientData.emergencyContact.mobile,
      })
      logOperation("Emergency contact added", { patientId: patientRef.id })
    }

    logOperation("Patient added", { patientId: patientRef.id })
    return patientRef.id
  } catch (error) {
    logOperation("Error adding patient", error)
    throw error
  }
}

export const assignHolterMonitor = async (patientId: string, monitorId: string) => {
  try {
    logOperation("Assigning holter monitor", { patientId, monitorId })

    // Get device from Realtime Database
    const deviceRef = ref(rtdb, `devices/${monitorId}`)
    const deviceSnapshot = await get(deviceRef)

    if (!deviceSnapshot.exists()) {
      logOperation("Monitor not found", { monitorId })
      throw new Error("Monitor not found")
    }

    const deviceData = deviceSnapshot.val()

    if (deviceData.assigned) {
      logOperation("Monitor is already assigned", { monitorId })
      throw new Error("Monitor is not available")
    }

    // Set deadline to 7 days from now
    const deadline = new Date()
    deadline.setDate(deadline.getDate() + 7)

    // Update device in Realtime Database
    await update(deviceRef, {
      assigned: patientId,
      deadline: deadline.getTime(),
      isDone: false,
    })

    // Update patient in Firestore
    await updateDoc(doc(db, "user_accounts", patientId), {
      monitorId,
      assignedDate: new Date(),
    })

    logOperation("Holter monitor assigned", { patientId, monitorId })
    return true
  } catch (error) {
    logOperation("Error assigning holter monitor", error)
    throw error
  }
}

export const removeHolterMonitor = async (patientId: string) => {
  try {
    logOperation("Removing holter monitor", { patientId })

    // Get the patient
    const patientDoc = await getDoc(doc(db, "user_accounts", patientId))
    if (!patientDoc.exists()) {
      logOperation("Patient not found", { patientId })
      throw new Error("Patient not found")
    }

    const patientData = patientDoc.data()
    if (!patientData.monitorId) {
      logOperation("Patient does not have a monitor assigned", { patientId })
      throw new Error("Patient does not have a monitor assigned")
    }

    // Update device in Realtime Database
    const deviceRef = ref(rtdb, `devices/${patientData.monitorId}`)
    await update(deviceRef, {
      assigned: null,
      deadline: null,
      isDone: true,
    })

    // Update patient in Firestore
    await updateDoc(doc(db, "user_accounts", patientId), {
      monitorId: null,
      assignedDate: null,
    })

    logOperation("Holter monitor removed", { patientId, monitorId: patientData.monitorId })
    return true
  } catch (error) {
    logOperation("Error removing holter monitor", error)
    throw error
  }
}

export const updatePatientStatus = async (patientId: string, status: string) => {
  try {
    logOperation("Updating patient status", { patientId, status })

    await updateDoc(doc(db, "user_accounts", patientId), {
      status: status,
    })

    logOperation("Patient status updated", { patientId, status })
    return true
  } catch (error) {
    logOperation("Error updating patient status", error)
    throw error
  }
}

// Get patient monitoring data
export const getPatientData = async (patientId: string) => {
  try {
    logOperation("Getting patient data", { patientId })

    const dataQuery = query(collection(db, "user_accounts", patientId, "data"), orderBy("timestamp", "desc"))

    const dataSnapshot = await getDocs(dataQuery)
    const patientData = dataSnapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }))

    logOperation("Patient data retrieved", { patientId, count: patientData.length })
    return patientData
  } catch (error) {
    logOperation("Error getting patient data", error)
    throw error
  }
}

// Add patient monitoring data
export const addPatientData = async (patientId: string, data: any) => {
  try {
    logOperation("Adding patient data", { patientId })

    const dataRef = await addDoc(collection(db, "user_accounts", patientId, "data"), {
      ...data,
      timestamp: new Date(),
      isDone: false,
    })

    logOperation("Patient data added", { patientId, dataId: dataRef.id })
    return dataRef.id
  } catch (error) {
    logOperation("Error adding patient data", error)
    throw error
  }
}

// Update patient monitoring data
export const updatePatientData = async (patientId: string, dataId: string, data: any) => {
  try {
    logOperation("Updating patient data", { patientId, dataId })

    await updateDoc(doc(db, "user_accounts", patientId, "data", dataId), {
      ...data,
      updatedAt: new Date(),
    })

    logOperation("Patient data updated", { patientId, dataId })
    return true
  } catch (error) {
    logOperation("Error updating patient data", error)
    throw error
  }
}

// Add or update emergency contact
export const updateEmergencyContact = async (patientId: string, contactData: { name: string; mobile: string }) => {
  try {
    logOperation("Updating emergency contact", { patientId })

    // Check if emergency contact exists
    const emergencySnapshot = await getDocs(collection(db, "user_accounts", patientId, "emergency"))

    if (emergencySnapshot.empty) {
      // Add new emergency contact
      await addDoc(collection(db, "user_accounts", patientId, "emergency"), {
        name: contactData.name,
        mobile: contactData.mobile,
      })
      logOperation("Emergency contact added", { patientId })
    } else {
      // Update existing emergency contact
      await updateDoc(doc(db, "user_accounts", patientId, "emergency", emergencySnapshot.docs[0].id), {
        name: contactData.name,
        mobile: contactData.mobile,
      })
      logOperation("Emergency contact updated", { patientId })
    }

    return true
  } catch (error) {
    logOperation("Error updating emergency contact", error)
    throw error
  }
}

// Reports
export const getReports = async () => {
  try {
    const user = await getCurrentUser()
    if (!user) throw new Error("User not authenticated")

    logOperation("Getting reports", { userRole: user.role })

    // Get all patient data documents that are marked as done
    const reports = []

    if (user.role === "admin") {
      // Admin can see all reports
      const reportsQuery = query(collectionGroup(db, "data"), where("isDone", "==", true), orderBy("timestamp", "desc"))
      const reportsSnapshot = await getDocs(reportsQuery)

      for (const reportDoc of reportsSnapshot.docs) {
        const reportData = reportDoc.data()

        // Get the patient ID from the report path
        const pathSegments = reportDoc.ref.path.split("/")
        const patientId = pathSegments[1] // user_accounts/{patientId}/data/{reportId}

        // Get patient details
        const patientDoc = await getDoc(doc(db, "user_accounts", patientId))
        const patientData = patientDoc.exists() ? patientDoc.data() : { name: "Unknown Patient" }

        // Get doctor details
        let doctorName = "Unknown Doctor"
        if (patientData.doctorId) {
          const doctorDoc = await getDoc(doc(db, "users", patientData.doctorId))
          if (doctorDoc.exists()) {
            doctorName = doctorDoc.data().name
          }
        }

        reports.push({
          id: reportDoc.id,
          patientId: patientId,
          title: reportData.title || "Holter Monitor Report",
          patientName: patientData.name,
          doctorName: doctorName,
          createdAt: reportData.timestamp.toDate().toISOString(),
          status: "completed",
        })
      }
    } else if (user.role === "doctor") {
      // Get all patients for this doctor
      const patientsQuery = query(collection(db, "user_accounts"), where("doctorId", "==", user.uid))
      const patientsSnapshot = await getDocs(patientsQuery)

      // If no patients, return empty array
      if (!patientsSnapshot.empty) {
        // Get reports for all patients of this doctor
        const patientIds = patientsSnapshot.docs.map((doc) => doc.id)

        // We need to query each patient's data collection
        for (const patientId of patientIds) {
          const patientReportsQuery = query(
            collection(db, "user_accounts", patientId, "data"),
            where("isDone", "==", true),
            orderBy("timestamp", "desc"),
          )

          const patientReportsSnapshot = await getDocs(patientReportsQuery)

          for (const reportDoc of patientReportsSnapshot.docs) {
            const reportData = reportDoc.data()
            const patientDoc = await getDoc(doc(db, "user_accounts", patientId))
            const patientData = patientDoc.exists() ? patientDoc.data() : { name: "Unknown Patient" }

            reports.push({
              id: reportDoc.id,
              patientId: patientId,
              title: reportData.title || "Holter Monitor Report",
              patientName: patientData.name,
              doctorName: user.displayName || "Doctor",
              createdAt: reportData.timestamp.toDate().toISOString(),
              status: "completed",
            })
          }
        }
      }
    } else if (user.role === "hospital") {
      // Get all patients for this hospital
      const patientsQuery = query(collection(db, "user_accounts"), where("hospitalId", "==", user.uid))
      const patientsSnapshot = await getDocs(patientsQuery)

      // If no patients, return empty array
      if (!patientsSnapshot.empty) {
        // Get reports for all patients of this hospital
        const patientIds = patientsSnapshot.docs.map((doc) => doc.id)

        // We need to query each patient's data collection
        for (const patientId of patientIds) {
          const patientReportsQuery = query(
            collection(db, "user_accounts", patientId, "data"),
            where("isDone", "==", true),
            orderBy("timestamp", "desc"),
          )

          const patientReportsSnapshot = await getDocs(patientReportsQuery)

          for (const reportDoc of patientReportsSnapshot.docs) {
            const reportData = reportDoc.data()
            const patientDoc = await getDoc(doc(db, "user_accounts", patientId))
            const patientData = patientDoc.exists() ? patientDoc.data() : { name: "Unknown Patient" }

            // Get doctor details
            let doctorName = "Unknown Doctor"
            if (patientData.doctorId) {
              const doctorDoc = await getDoc(doc(db, "users", patientData.doctorId))
              if (doctorDoc.exists()) {
                doctorName = doctorDoc.data().name
              }
            }

            reports.push({
              id: reportDoc.id,
              patientId: patientId,
              title: reportData.title || "Holter Monitor Report",
              patientName: patientData.name,
              doctorName: doctorName,
              createdAt: reportData.timestamp.toDate().toISOString(),
              status: "completed",
            })
          }
        }
      }
    }

    logOperation("Reports retrieved", { count: reports.length })
    return reports
  } catch (error) {
    logOperation("Error getting reports", error)
    throw error
  }
}

export const getReportById = async (patientId: string, reportId: string) => {
  try {
    logOperation("Getting report by ID", { patientId, reportId })

    const reportDoc = await getDoc(doc(db, "user_accounts", patientId, "data", reportId))

    if (!reportDoc.exists()) {
      logOperation("Report not found", { patientId, reportId })
      throw new Error("Report not found")
    }

    const reportData = reportDoc.data()

    // Get patient details
    const patientDoc = await getDoc(doc(db, "user_accounts", patientId))
    if (!patientDoc.exists()) {
      logOperation("Patient not found", { patientId })
      throw new Error("Patient not found")
    }
    const patientData = patientDoc.data()

    // Get doctor details
    let doctorName = "Unknown Doctor"
    let doctorSpecialization = ""
    let hospitalName = "Unknown Hospital"

    if (patientData.doctorId) {
      const doctorDoc = await getDoc(doc(db, "users", patientData.doctorId))
      if (doctorDoc.exists()) {
        const doctorData = doctorDoc.data()
        doctorName = doctorData.name
        doctorSpecialization = doctorData.specialization || ""

        // Get hospital details
        if (doctorData.hospitalId) {
          const hospitalDoc = await getDoc(doc(db, "users", doctorData.hospitalId))
          if (hospitalDoc.exists()) {
            hospitalName = hospitalDoc.data().name
          }
        }
      }
    }

    const report = {
      id: reportDoc.id,
      title: reportData.title || "Holter Monitor Report",
      patientId: patientId,
      patientName: patientData.name,
      patientAge: patientData.age,
      patientGender: patientData.gender,
      doctorId: patientData.doctorId,
      doctorName: doctorName,
      doctorSpecialization: doctorSpecialization,
      hospitalName: hospitalName,
      summary: reportData.brief || "",
      anomalyDetection: reportData.description || "",
      doctorSuggestion: reportData.docSuggestions || "",
      aiSuggestion: reportData.aiSuggestions || "",
      createdAt: reportData.timestamp.toDate().toISOString(),
      status: "completed",
      timeRange: reportData.timeRange || { start: 0, end: 24 },
      data: reportData.data || [],
    }

    logOperation("Report retrieved", { patientId, reportId })
    return report
  } catch (error) {
    logOperation("Error getting report", error)
    throw error
  }
}

export const createReport = async (reportData: any) => {
  try {
    const user = await getCurrentUser()
    if (!user) throw new Error("User not authenticated")

    logOperation("Creating report", { patientId: reportData.patientId })

    // Add data document to patient's data collection
    const docRef = await addDoc(collection(db, "user_accounts", reportData.patientId, "data"), {
      title: reportData.title,
      brief: reportData.summary,
      description: reportData.anomalyDetection,
      docSuggestions: reportData.doctorSuggestion,
      aiSuggestions: reportData.aiSuggestion,
      timestamp: new Date(),
      isDone: true,
      timeRange: reportData.timeRange || { start: 0, end: 24 },
      data: reportData.data || [],
    })

    // If patient has a monitor, mark it as done
    const patientDoc = await getDoc(doc(db, "user_accounts", reportData.patientId))
    if (patientDoc.exists()) {
      const patientData = patientDoc.data()
      if (patientData.monitorId) {
        const deviceRef = ref(rtdb, `devices/${patientData.monitorId}`)
        await update(deviceRef, {
          isDone: true,
        })
      }
    }

    logOperation("Report created", { patientId: reportData.patientId, reportId: docRef.id })
    return docRef.id
  } catch (error) {
    logOperation("Error creating report", error)
    throw error
  }
}

// AI Report Suggestion
export const generateAIReportSuggestion = async (data: any) => {
  try {
    logOperation("Generating AI report suggestion", {})

    const prompt = `
      Generate a medical suggestion for a patient with the following information:
      
      Patient Information:
      - Name: ${data.patientData.name}
      - Age: ${data.patientData.age}
      - Gender: ${data.patientData.gender}
      - Medical History: ${data.patientData.medicalHistory || "None provided"}
      
      Report Summary:
      ${data.reportSummary}
      
      Anomaly Detection:
      ${data.anomalyDetection}
      
      Based on this information, provide a detailed medical suggestion including:
      1. Interpretation of the holter monitor findings
      2. Potential diagnoses to consider
      3. Recommended follow-up tests or procedures
      4. Treatment recommendations
      5. Lifestyle modifications
    `

    // Use the AI SDK to generate a response
    const { text } = await generateText({
      model: openai("gpt-4o"),
      prompt: prompt,
      system:
        "You are a cardiologist AI assistant. Provide detailed, evidence-based medical suggestions for patients based on holter monitor data and clinical information. Include specific recommendations and potential diagnoses.",
    })

    logOperation("AI report suggestion generated", {})
    return text
  } catch (error) {
    logOperation("Error generating AI report suggestion", error)
    throw new Error("Failed to generate AI suggestion. Please try again.")
  }
}

// Doctor Profile
export const getDoctorProfile = async () => {
  try {
    const user = await getCurrentUser()
    if (!user) throw new Error("User not authenticated")

    logOperation("Getting doctor profile", { uid: user.uid })

    const userDoc = await getDoc(doc(db, "users", user.uid))
    if (!userDoc.exists()) {
      logOperation("Doctor profile not found", { uid: user.uid })
      throw new Error("Doctor profile not found")
    }

    const userData = userDoc.data()

    // Get hospital name
    let hospitalName = ""
    if (userData.hospitalId) {
      const hospitalDoc = await getDoc(doc(db, "users", userData.hospitalId))
      if (hospitalDoc.exists()) {
        hospitalName = hospitalDoc.data().name
      }
    }

    const profile = {
      id: user.uid,
      name: userData.name,
      email: user.email,
      specialization: userData.specialization || "",
      hospitalName,
      contactNumber: userData.mobile || "",
      bio: userData.bio || "",
      photoURL: userData.pic || "",
    }

    logOperation("Doctor profile retrieved", { uid: user.uid })
    return profile
  } catch (error) {
    logOperation("Error getting doctor profile", error)
    throw error
  }
}

export const updateDoctorProfile = async (profileData: any) => {
  try {
    const user = await getCurrentUser()
    if (!user) throw new Error("User not authenticated")

    logOperation("Updating doctor profile", { uid: user.uid })

    await updateDoc(doc(db, "users", user.uid), {
      name: profileData.name,
      specialization: profileData.specialization,
      mobile: profileData.contactNumber,
      bio: profileData.bio,
      updatedAt: new Date(),
    })

    logOperation("Doctor profile updated", { uid: user.uid })
    return true
  } catch (error) {
    logOperation("Error updating doctor profile", error)
    throw error
  }
}

// Doctors
export const getDoctors = async () => {
  try {
    logOperation("Getting doctors", {})

    const doctorsQuery = query(collection(db, "users"), where("role", "==", "doctor"))
    const doctorsSnapshot = await getDocs(doctorsQuery)
    const doctors = []

    for (const doctorDoc of doctorsSnapshot.docs) {
      const doctorData = doctorDoc.data()
      let hospitalName = ""

      if (doctorData.hospitalId) {
        const hospitalDoc = await getDoc(doc(db, "users", doctorData.hospitalId))
        if (hospitalDoc.exists()) {
          hospitalName = hospitalDoc.data().name
        }
      }

      doctors.push({
        id: doctorDoc.id,
        name: doctorData.name,
        email: doctorData.email,
        specialization: doctorData.specialization || "",
        hospitalId: doctorData.hospitalId || "",
        hospitalName,
        contactNumber: doctorData.mobile || "",
        pic: doctorData.pic || "",
      })
    }

    logOperation("Doctors retrieved", { count: doctors.length })
    return doctors
  } catch (error) {
    logOperation("Error getting doctors", error)
    throw error
  }
}

export const getDoctorDetails = async () => {
  try {
    const user = await getCurrentUser()
    if (!user) throw new Error("User not authenticated")

    logOperation("Getting doctor details", { uid: user.uid })

    const userDoc = await getDoc(doc(db, "users", user.uid))
    if (!userDoc.exists()) {
      logOperation("Doctor not found", { uid: user.uid })
      throw new Error("Doctor not found")
    }

    const userData = userDoc.data()

    // Get hospital name
    let hospitalName = ""
    if (userData.hospitalId) {
      const hospitalDoc = await getDoc(doc(db, "users", userData.hospitalId))
      if (hospitalDoc.exists()) {
        hospitalName = hospitalDoc.data().name
      }
    }

    const doctorDetails = {
      id: user.uid,
      name: userData.name,
      email: user.email,
      specialization: userData.specialization || "",
      hospitalName,
    }

    logOperation("Doctor details retrieved", { uid: user.uid })
    return doctorDetails
  } catch (error) {
    logOperation("Error getting doctor details", error)
    throw error
  }
}

export const addDoctor = async (doctorData: any) => {
  try {
    logOperation("Adding doctor", { email: doctorData.email })

    const auth = getAuth()
    const { email, password, ...userData } = doctorData

    // Create user in Firebase Auth
    const userCredential = await createUserWithEmailAndPassword(auth, email, password)
    const userId = userCredential.user.uid
    logOperation("Created auth user", { uid: userId })

    // Add user data to Firestore
    await setDoc(doc(db, "users", userId), {
      ...userData,
      email,
      role: "doctor",
      createdAt: new Date(),
    })
    logOperation("Added user data to Firestore", { uid: userId })

    return userId
  } catch (error) {
    logOperation("Error adding doctor", error)
    throw error
  }
}

// Hospitals
export const getHospitals = async () => {
  try {
    logOperation("Getting hospitals", {})

    const hospitalsQuery = query(collection(db, "users"), where("role", "==", "hospital"))
    const hospitalsSnapshot = await getDocs(hospitalsQuery)
    const hospitals = []
    for (const hospitalDoc of hospitalsSnapshot.docs) {
      const doc = hospitalDoc.data()
      const doctors = query(collection(db, "users"), where("role", "==", "doctor"))
      const hospitalDoctorsSnapshot = await getDocs(doctors)
      let count = 0
      for (const doctorDoc of hospitalDoctorsSnapshot.docs) {
        if (doctorDoc.get("hospitalId") === hospitalDoc.id) {
          count++
        }
      }

      logOperation("Hospital doctors retrieved", { count: count })
      hospitals.push({
        id: doc.id,
        name: doc.name,
        address: doc.address || "",
        contactNumber: doc.mobile || "",
        email: doc.email || "",
        description: doc.description || "",
        createdAt: doc.createdAt ? new Date(doc.createdAt) : new Date(),
        pic: doc.pic || "",
        doctorCount: hospitalDoctorsSnapshot.size,
      })
    }
    // const hospitals = hospitalsSnapshot.docs.map((doc) => ({
    //   id: doc.id,
    //   name: doc.data().name,
    //   address: doc.data().address || "",
    //   contactNumber: doc.data().mobile || "",
    //   email: doc.data().email || "",
    //   description: doc.data().description || "",
    //   createdAt: doc.data().createdAt ? new Date(doc.data().createdAt) : new Date(),
    //   pic: doc.data().pic || "",
    // }))

    logOperation("Hospitals retrieved", { count: hospitals.length })
    return hospitals
  } catch (error) {
    logOperation("Error getting hospitals", error)
    throw error
  }
}

export const addHospital = async (hospitalData: any) => {
  try {
    logOperation("Adding hospital", { email: hospitalData.email })

    const auth = getAuth()
    const { email, password, ...userData } = hospitalData

    // Create user in Firebase Auth
    const userCredential = await createUserWithEmailAndPassword(auth, email, password)
    const userId = userCredential.user.uid
    logOperation("Created auth user", { uid: userId })

    // Add user data to Firestore
    await setDoc(doc(db, "users", userId), {
      ...userData,
      email,
      role: "hospital",
      createdAt: new Date(),
    })
    logOperation("Added user data to Firestore", { uid: userId })

    return userId
  } catch (error) {
    logOperation("Error adding hospital", error)
    throw error
  }
}

// Hospital profile
export const getHospitalProfile = async () => {
  try {
    const user = await getCurrentUser()
    if (!user) throw new Error("User not authenticated")

    logOperation("Getting hospital profile", { uid: user.uid })

    const userDoc = await getDoc(doc(db, "users", user.uid))
    if (!userDoc.exists()) {
      logOperation("Hospital profile not found", { uid: user.uid })
      throw new Error("Hospital profile not found")
    }

    const userData = userDoc.data()

    const profile = {
      id: user.uid,
      name: userData.name,
      email: userData.email,
      address: userData.address || "",
      contactNumber: userData.mobile || "",
      description: userData.description || "",
      photoURL: userData.pic || "",
    }

    logOperation("Hospital profile retrieved", { uid: user.uid })
    return profile
  } catch (error) {
    logOperation("Error getting hospital profile", error)
    throw error
  }
}

export const updateHospitalProfile = async (profileData: any) => {
  try {
    const user = await getCurrentUser()
    if (!user) throw new Error("User not authenticated")

    logOperation("Updating hospital profile", { uid: user.uid })

    await updateDoc(doc(db, "users", user.uid), {
      name: profileData.name,
      address: profileData.address,
      mobile: profileData.contactNumber,
      description: profileData.description,
      updatedAt: new Date(),
    })

    logOperation("Hospital profile updated", { uid: user.uid })
    return true
  } catch (error) {
    logOperation("Error updating hospital profile", error)
    throw error
  }
}

// AI Chat
export const getChatHistory = async () => {
  try {
    const user = await getCurrentUser()
    if (!user) throw new Error("User not authenticated")

    logOperation("Getting chat history", { uid: user.uid })

    const chatQuery = query(
      collection(db, "chatMessages"),
      where("userId", "==", user.uid),
      orderBy("timestamp", "asc"),
      limit(100),
    )

    const chatSnapshot = await getDocs(chatQuery)
    const chatHistory = chatSnapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }))

    logOperation("Chat history retrieved", { uid: user.uid, count: chatHistory.length })
    return chatHistory
  } catch (error) {
    logOperation("Error getting chat history", error)
    throw error
  }
}

export const sendChatMessage = async (message: string) => {
  try {
    const user = await getCurrentUser()
    if (!user) throw new Error("User not authenticated")

    logOperation("Sending chat message", { uid: user.uid })

    // Add user message to database
    await addDoc(collection(db, "chatMessages"), {
      content: message,
      sender: "user",
      userId: user.uid,
      timestamp: Date.now(),
    })
    logOperation("User message added to database", { uid: user.uid })

    // Use the AI SDK to generate a response
    const { text } = await generateText({
      model: openai("gpt-4o"),
      prompt: message,
      system:
        "You are a medical AI assistant for doctors using a holter monitoring system. Provide helpful, accurate, and concise responses to medical questions. Focus on cardiology topics, patient care, and holter monitor data interpretation. Always clarify that your advice is not a substitute for professional medical judgment.",
    })
    logOperation("AI response generated", { uid: user.uid })

    // Add AI response to database
    await addDoc(collection(db, "chatMessages"), {
      content: text,
      sender: "ai",
      userId: user.uid,
      timestamp: Date.now(),
    })
    logOperation("AI message added to database", { uid: user.uid })

    return text
  } catch (error) {
    logOperation("Error sending chat message", error)
    throw new Error("Failed to send message. Please try again.")
  }
}

export const updatePassword = async (currentPassword: string, newPassword: string) => {
  try {
    logOperation("Update password attempt", {})
    const user = getAuth().currentUser
    if (!user || !user.email) {
      logOperation("No authenticated user found", {})
      throw new Error("User not authenticated")
    }

    // Re-authenticate user
    const credential = EmailAuthProvider.credential(user.email, currentPassword)
    await reauthenticateWithCredential(user, credential)
    logOperation("User re-authenticated successfully", {})

    // Update password
    await firebaseUpdatePassword(user, newPassword)
    logOperation("Password updated successfully", {})

    return true
  } catch (error: any) {
    logOperation("Update password error", error.message)
    throw new Error(error.message || "Failed to update password")
  }
}

export const removeHospital = async (hospitalId: string) => {
  try {
    logOperation("Removing hospital", {
      uid: hospitalId,
    })
    const hospitalDoc = await getDoc(doc(db, "users", hospitalId))
    if (!hospitalDoc.exists()) {
      logOperation("Hospital not found", {
        uid: hospitalId,
      })
      throw new Error("Hospital not found")
    }
    const hospitalData = deleteDoc(doc(db, "users", hospitalId))
    logOperation("Hospital removed", {
      uid: hospitalId,
    })

    return hospitalData;
  } catch (error) {
    logOperation("Error removing hospital", error)
    throw error
  }
}
