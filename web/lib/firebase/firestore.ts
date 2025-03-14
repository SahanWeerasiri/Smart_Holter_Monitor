import {
  collection,
  doc,
  getDoc,
  getDocs,
  addDoc,
  updateDoc,
  deleteDoc,
  query,
  where,
  serverTimestamp,
  Timestamp,
  orderBy,
  limit,
} from "firebase/firestore"
import { db } from "./config"
import { getCurrentUser } from "./auth"
import {
  createUserWithEmailAndPassword,
  getAuth,
  updatePassword as firebaseUpdatePassword,
  EmailAuthProvider,
  reauthenticateWithCredential,
} from "firebase/auth"
import { generateText } from "ai"
import { openai } from "@ai-sdk/openai"

// User roles
export const getUserRole = async (userId?: string) => {
  try {
    const user = userId ? { uid: userId } : await getCurrentUser()
    if (!user) return null

    const userDoc = await getDoc(doc(db, "users", user.uid))
    if (userDoc.exists()) {
      return userDoc.data().role
    }
    return null
  } catch (error) {
    console.error("Error getting user role:", error)
    throw error
  }
}

// Dashboard stats
export const getDashboardStats = async () => {
  try {
    // This would normally fetch real data from Firestore
    // For demo purposes, we're returning mock data
    return {
      totalPatients: 124,
      activeMonitors: 45,
      availableMonitors: 15,
      pendingReports: 8,
    }
  } catch (error) {
    console.error("Error getting dashboard stats:", error)
    throw error
  }
}

// Holter monitors
export const getHolterMonitors = async () => {
  try {
    const monitorsSnapshot = await getDocs(collection(db, "holterMonitors"))
    const monitors = []

    for (const monitorDoc of monitorsSnapshot.docs) {
      const monitorData = monitorDoc.data()

      // If monitor is assigned to a patient, get patient details
      let assignedTo = undefined
      if (monitorData.patientId) {
        const patientDoc = await getDoc(doc(db, "patients", monitorData.patientId))
        if (patientDoc.exists()) {
          assignedTo = {
            patientId: patientDoc.id,
            patientName: patientDoc.data().name,
            deadline: monitorData.deadline,
          }
        }
      }

      monitors.push({
        id: monitorDoc.id,
        deviceCode: monitorData.deviceCode,
        description: monitorData.description,
        status: monitorData.status,
        assignedTo,
      })
    }

    return monitors
  } catch (error) {
    console.error("Error getting holter monitors:", error)
    throw error
  }
}

export const getAvailableHolterMonitors = async () => {
  try {
    const monitorsQuery = query(collection(db, "holterMonitors"), where("status", "==", "available"))

    const monitorsSnapshot = await getDocs(monitorsQuery)

    return monitorsSnapshot.docs.map((doc) => ({
      id: doc.id,
      deviceCode: doc.data().deviceCode,
      description: doc.data().description,
    }))
  } catch (error) {
    console.error("Error getting available holter monitors:", error)
    throw error
  }
}

export const addHolterMonitor = async (monitorData: any) => {
  try {
    const docRef = await addDoc(collection(db, "holterMonitors"), {
      ...monitorData,
      createdAt: serverTimestamp(),
    })
    return docRef.id
  } catch (error) {
    console.error("Error adding holter monitor:", error)
    throw error
  }
}

export const deleteHolterMonitor = async (monitorId: string) => {
  try {
    await deleteDoc(doc(db, "holterMonitors", monitorId))
  } catch (error) {
    console.error("Error deleting holter monitor:", error)
    throw error
  }
}

// Patients
export const getPatients = async () => {
  try {
    const user = await getCurrentUser()
    if (!user) throw new Error("User not authenticated")

    const userDoc = await getDoc(doc(db, "users", user.uid))
    const userData = userDoc.data()

    let patientsQuery

    if (userData?.role === "admin") {
      // Admin can see all patients
      patientsQuery = query(collection(db, "patients"))
    } else {
      // Doctors can only see their patients
      patientsQuery = query(collection(db, "patients"), where("doctorId", "==", user.uid))
    }

    const patientsSnapshot = await getDocs(patientsQuery)
    const patients = []

    for (const patientDoc of patientsSnapshot.docs) {
      const patientData = patientDoc.data()

      // If patient has a monitor, get monitor details
      let monitorCode = undefined
      if (patientData.monitorId) {
        const monitorDoc = await getDoc(doc(db, "holterMonitors", patientData.monitorId))
        if (monitorDoc.exists()) {
          monitorCode = monitorDoc.data().deviceCode
        }
      }

      patients.push({
        id: patientDoc.id,
        name: patientData.name,
        age: patientData.age,
        gender: patientData.gender,
        contactNumber: patientData.contactNumber,
        medicalHistory: patientData.medicalHistory,
        status: patientData.status,
        monitorId: patientData.monitorId,
        monitorCode,
        assignedDate: patientData.assignedDate,
        doctorId: patientData.doctorId,
      })
    }

    return patients
  } catch (error) {
    console.error("Error getting patients:", error)
    throw error
  }
}

export const getPatientById = async (patientId: string) => {
  try {
    const patientDoc = await getDoc(doc(db, "patients", patientId))

    if (!patientDoc.exists()) {
      throw new Error("Patient not found")
    }

    const patientData = patientDoc.data()

    return {
      id: patientDoc.id,
      name: patientData.name,
      age: patientData.age,
      gender: patientData.gender,
      contactNumber: patientData.contactNumber,
      medicalHistory: patientData.medicalHistory,
      status: patientData.status,
    }
  } catch (error) {
    console.error("Error getting patient:", error)
    throw error
  }
}

export const addPatient = async (patientData: any) => {
  try {
    const user = await getCurrentUser()
    if (!user) throw new Error("User not authenticated")

    const docRef = await addDoc(collection(db, "patients"), {
      ...patientData,
      doctorId: user.uid,
      createdAt: serverTimestamp(),
    })

    return docRef.id
  } catch (error) {
    console.error("Error adding patient:", error)
    throw error
  }
}

export const assignHolterMonitor = async (patientId: string, monitorId: string) => {
  try {
    // Get the monitor
    const monitorDoc = await getDoc(doc(db, "holterMonitors", monitorId))
    if (!monitorDoc.exists()) {
      throw new Error("Monitor not found")
    }

    if (monitorDoc.data().status !== "available") {
      throw new Error("Monitor is not available")
    }

    // Set deadline to 7 days from now
    const deadline = new Date()
    deadline.setDate(deadline.getDate() + 7)

    // Update monitor status
    await updateDoc(doc(db, "holterMonitors", monitorId), {
      status: "in-use",
      patientId,
      assignedDate: serverTimestamp(),
      deadline: Timestamp.fromDate(deadline),
    })

    // Update patient status
    await updateDoc(doc(db, "patients", patientId), {
      status: "monitoring",
      monitorId,
      assignedDate: serverTimestamp(),
    })

    return true
  } catch (error) {
    console.error("Error assigning holter monitor:", error)
    throw error
  }
}

export const removeHolterMonitor = async (patientId: string) => {
  try {
    // Get the patient
    const patientDoc = await getDoc(doc(db, "patients", patientId))
    if (!patientDoc.exists()) {
      throw new Error("Patient not found")
    }

    const patientData = patientDoc.data()
    if (!patientData.monitorId) {
      throw new Error("Patient does not have a monitor assigned")
    }

    // Update monitor status
    await updateDoc(doc(db, "holterMonitors", patientData.monitorId), {
      status: "available",
      patientId: null,
      assignedDate: null,
      deadline: null,
    })

    // Update patient status
    await updateDoc(doc(db, "patients", patientId), {
      status: "finished",
      monitorId: null,
      assignedDate: null,
    })

    return true
  } catch (error) {
    console.error("Error removing holter monitor:", error)
    throw error
  }
}

export const updatePatientStatus = async (patientId: string, status: string) => {
  try {
    await updateDoc(doc(db, "patients", patientId), {
      status: status,
    })
    return true
  } catch (error) {
    console.error("Error updating patient status:", error)
    throw error
  }
}

// Reports
export const getReports = async () => {
  try {
    const user = await getCurrentUser()
    if (!user) throw new Error("User not authenticated")

    const userDoc = await getDoc(doc(db, "users", user.uid))
    const userData = userDoc.data()

    let reportsQuery

    if (userData?.role === "admin") {
      // Admin can see all reports
      reportsQuery = query(collection(db, "reports"), orderBy("createdAt", "desc"))
    } else {
      // Doctors can only see their reports
      reportsQuery = query(collection(db, "reports"), where("doctorId", "==", user.uid), orderBy("createdAt", "desc"))
    }

    const reportsSnapshot = await getDocs(reportsQuery)
    const reports = []

    for (const reportDoc of reportsSnapshot.docs) {
      const reportData = reportDoc.data()

      reports.push({
        id: reportDoc.id,
        title: reportData.title,
        patientName: reportData.patientName,
        doctorName: reportData.doctorName,
        createdAt: reportData.createdAt.toDate().toISOString(),
        status: reportData.status,
      })
    }

    return reports
  } catch (error) {
    console.error("Error getting reports:", error)
    throw error
  }
}

export const getReportById = async (reportId: string) => {
  try {
    const reportDoc = await getDoc(doc(db, "reports", reportId))

    if (!reportDoc.exists()) {
      throw new Error("Report not found")
    }

    const reportData = reportDoc.data()

    return {
      id: reportDoc.id,
      title: reportData.title,
      patientId: reportData.patientId,
      patientName: reportData.patientName,
      patientAge: reportData.patientAge,
      patientGender: reportData.patientGender,
      doctorId: reportData.doctorId,
      doctorName: reportData.doctorName,
      doctorSpecialization: reportData.doctorSpecialization,
      hospitalName: reportData.hospitalName,
      summary: reportData.summary,
      anomalyDetection: reportData.anomalyDetection,
      doctorSuggestion: reportData.doctorSuggestion,
      aiSuggestion: reportData.aiSuggestion,
      createdAt: reportData.createdAt.toDate().toISOString(),
      status: reportData.status,
      timeRange: reportData.timeRange || { start: 0, end: 24 },
    }
  } catch (error) {
    console.error("Error getting report:", error)
    throw error
  }
}

export const createReport = async (reportData: any) => {
  try {
    const user = await getCurrentUser()
    if (!user) throw new Error("User not authenticated")

    // Get patient details
    const patientDoc = await getDoc(doc(db, "patients", reportData.patientId))
    if (!patientDoc.exists()) {
      throw new Error("Patient not found")
    }
    const patientData = patientDoc.data()

    // Get doctor details
    const doctorDoc = await getDoc(doc(db, "users", user.uid))
    if (!doctorDoc.exists()) {
      throw new Error("Doctor not found")
    }
    const doctorData = doctorDoc.data()

    // Get hospital details
    const hospitalDoc = await getDoc(doc(db, "hospitals", doctorData.hospitalId))
    const hospitalName = hospitalDoc.exists() ? hospitalDoc.data().name : "Unknown Hospital"

    const docRef = await addDoc(collection(db, "reports"), {
      ...reportData,
      patientName: patientData.name,
      patientAge: patientData.age,
      patientGender: patientData.gender,
      doctorId: user.uid,
      doctorName: doctorData.name,
      doctorSpecialization: doctorData.specialization,
      hospitalName,
      createdAt: serverTimestamp(),
    })

    return docRef.id
  } catch (error) {
    console.error("Error creating report:", error)
    throw error
  }
}

// AI Report Suggestion
export const generateAIReportSuggestion = async (data: any) => {
  try {
    // In a real application, you would use the AI SDK to generate a suggestion
    // For demo purposes, we'll return a mock response

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

    // In a real application, you would use the AI SDK like this:
    const { text } = await generateText({
      model: openai("gpt-4o"),
      prompt: prompt,
      system:
        "You are a cardiologist AI assistant. Provide detailed, evidence-based medical suggestions for patients based on holter monitor data and clinical information. Include specific recommendations and potential diagnoses.",
    })

    return text
  } catch (error) {
    console.error("Error generating AI report suggestion:", error)
    throw new Error("Failed to generate AI suggestion. Please try again.")
  }
}

// Doctor Profile
export const getDoctorProfile = async () => {
  try {
    const user = await getCurrentUser()
    if (!user) throw new Error("User not authenticated")

    const userDoc = await getDoc(doc(db, "users", user.uid))
    if (!userDoc.exists()) {
      throw new Error("Doctor profile not found")
    }

    const userData = userDoc.data()

    // Get hospital name
    let hospitalName = ""
    if (userData.hospitalId) {
      const hospitalDoc = await getDoc(doc(db, "hospitals", userData.hospitalId))
      if (hospitalDoc.exists()) {
        hospitalName = hospitalDoc.data().name
      }
    }

    return {
      id: user.uid,
      name: userData.name,
      email: user.email,
      specialization: userData.specialization || "",
      hospitalName,
      contactNumber: userData.contactNumber || "",
      bio: userData.bio || "",
      photoURL: user.photoURL || "",
    }
  } catch (error) {
    console.error("Error getting doctor profile:", error)
    throw error
  }
}

export const updateDoctorProfile = async (profileData: any) => {
  try {
    const user = await getCurrentUser()
    if (!user) throw new Error("User not authenticated")

    await updateDoc(doc(db, "users", user.uid), {
      name: profileData.name,
      specialization: profileData.specialization,
      contactNumber: profileData.contactNumber,
      bio: profileData.bio,
      updatedAt: serverTimestamp(),
    })

    return true
  } catch (error) {
    console.error("Error updating doctor profile:", error)
    throw error
  }
}

export const updatePassword = async (currentPassword: string, newPassword: string) => {
  try {
    const user = await getCurrentUser()
    if (!user || !user.email) throw new Error("User not authenticated")

    const auth = getAuth()
    const credential = EmailAuthProvider.credential(user.email, currentPassword)

    // Re-authenticate user
    await reauthenticateWithCredential(user, credential)

    // Update password
    await firebaseUpdatePassword(user, newPassword)

    return true
  } catch (error) {
    console.error("Error updating password:", error)
    throw error
  }
}

// Doctors
export const getDoctors = async () => {
  try {
    const doctorsSnapshot = await getDocs(collection(db, "users"))
    const doctors = []

    for (const doctorDoc of doctorsSnapshot.docs) {
      const doctorData = doctorDoc.data()
      if (doctorData.role === "doctor") {
        let hospitalName = ""
        if (doctorData.hospitalId) {
          const hospitalDoc = await getDoc(doc(db, "hospitals", doctorData.hospitalId))
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
        })
      }
    }

    return doctors
  } catch (error) {
    console.error("Error getting doctors:", error)
    throw error
  }
}

export const getDoctorDetails = async () => {
  try {
    const user = await getCurrentUser()
    if (!user) throw new Error("User not authenticated")

    const userDoc = await getDoc(doc(db, "users", user.uid))
    if (!userDoc.exists()) {
      throw new Error("Doctor not found")
    }

    const userData = userDoc.data()

    // Get hospital name
    let hospitalName = ""
    if (userData.hospitalId) {
      const hospitalDoc = await getDoc(doc(db, "hospitals", userData.hospitalId))
      if (hospitalDoc.exists()) {
        hospitalName = hospitalDoc.data().name
      }
    }

    return {
      id: user.uid,
      name: userData.name,
      email: user.email,
      specialization: userData.specialization || "",
      hospitalName,
    }
  } catch (error) {
    console.error("Error getting doctor details:", error)
    throw error
  }
}

export const addDoctor = async (doctorData: any) => {
  try {
    const auth = getAuth()
    const { email, password, ...userData } = doctorData

    // Create user in Firebase Auth
    const userCredential = await createUserWithEmailAndPassword(auth, email, password)
    const userId = userCredential.user.uid

    // Add user data to Firestore
    await updateDoc(doc(db, "users", userId), {
      ...userData,
      email,
      createdAt: serverTimestamp(),
    })

    return userId
  } catch (error) {
    console.error("Error adding doctor:", error)
    throw error
  }
}

// Hospitals
export const getHospitals = async () => {
  try {
    const hospitalsSnapshot = await getDocs(collection(db, "hospitals"))
    return hospitalsSnapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    })) as any[]
  } catch (error) {
    console.error("Error getting hospitals:", error)
    throw error
  }
}

export const addHospital = async (hospitalData: any) => {
  try {
    const docRef = await addDoc(collection(db, "hospitals"), {
      ...hospitalData,
      createdAt: serverTimestamp(),
    })
    return docRef.id
  } catch (error) {
    console.error("Error adding hospital:", error)
    throw error
  }
}

// AI Chat
export const getChatHistory = async () => {
  try {
    const user = await getCurrentUser()
    if (!user) throw new Error("User not authenticated")

    const chatQuery = query(
      collection(db, "chatMessages"),
      where("userId", "==", user.uid),
      orderBy("timestamp", "asc"),
      limit(100),
    )

    const chatSnapshot = await getDocs(chatQuery)

    return chatSnapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    })) as any[]
  } catch (error) {
    console.error("Error getting chat history:", error)
    throw error
  }
}

export const sendChatMessage = async (message: string) => {
  try {
    const user = await getCurrentUser()
    if (!user) throw new Error("User not authenticated")

    // Add user message to database
    await addDoc(collection(db, "chatMessages"), {
      content: message,
      sender: "user",
      userId: user.uid,
      timestamp: Date.now(),
    })

    // In a real application, you would use the AI SDK to generate a response
    // For demo purposes, we'll generate a simple response

    const { text } = await generateText({
      model: openai("gpt-4o"),
      prompt: message,
      system:
        "You are a medical AI assistant for doctors using a holter monitoring system. Provide helpful, accurate, and concise responses to medical questions. Focus on cardiology topics, patient care, and holter monitor data interpretation. Always clarify that your advice is not a substitute for professional medical judgment.",
    })

    // Add AI response to database
    await addDoc(collection(db, "chatMessages"), {
      content: text,
      sender: "ai",
      userId: user.uid,
      timestamp: Date.now(),
    })

    return text
  } catch (error) {
    console.error("Error sending chat message:", error)
    throw new Error("Failed to send message. Please try again.")
  }
}

