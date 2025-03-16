import {
  signInWithEmailAndPassword,
  signOut as firebaseSignOut,
  onAuthStateChanged,
  type User,
  createUserWithEmailAndPassword,
  EmailAuthProvider,
  reauthenticateWithCredential,
  updatePassword as firebaseUpdatePassword,
} from "firebase/auth"
import { doc, getDoc, setDoc } from "firebase/firestore"
import { auth, db, logOperation } from "./config"
import { SignJWT } from "jose"

// Hardcoded credentials for development
const DEV_CREDENTIALS = {
  admin: {
    email: "admin@smartcare.com",
    password: "admin123",
    role: "admin",
    name: "Admin User",
    uid: "admin-dev-uid",
  },
  hospital: {
    email: "hospital@smartcare.com",
    password: "hospital123",
    role: "hospital",
    name: "Hospital User",
    uid: "hospital-dev-uid",
  },
  doctor: {
    email: "doctor@smartcare.com",
    password: "doctor123",
    role: "doctor",
    name: "Doctor User",
    specialization: "Cardiology",
    hospitalId: "hospital-dev-uid",
    hospitalName: "Dev Hospital",
    uid: "doctor-dev-uid",
  },
}

export interface UserWithRole extends User {
  role?: "admin" | "doctor" | "hospital" | "patient"
}

export const signIn = async (email: string, password: string): Promise<UserWithRole> => {
  try {
    logOperation("Sign in attempt", { email })

    // Check for hardcoded development credentials
    const isDev = Object.values(DEV_CREDENTIALS).some((cred) => cred.email === email && cred.password === password)

    let user: User
    let userData: any

    if (isDev) {
      logOperation("Using development credentials", { email })
      // Use hardcoded credentials
      const devUser = Object.values(DEV_CREDENTIALS).find((cred) => cred.email === email && cred.password === password)

      if (!devUser) {
        throw new Error("Invalid development credentials")
      }

      logOperation("Development user found", { role: devUser.role })

      // Create a mock user object
      user = {
        uid: devUser.uid,
        email: devUser.email,
        emailVerified: true,
        isAnonymous: false,
        metadata: {},
        providerData: [],
        refreshToken: "",
        tenantId: null,
        delete: async () => { },
        getIdToken: async () => "",
        getIdTokenResult: async () => ({
          token: "",
          claims: {},
          expirationTime: "",
          authTime: "",
          issuedAtTime: "",
          signInProvider: null,
          signInSecondFactor: null,
        }),
        reload: async () => { },
        toJSON: () => ({}),
        displayName: devUser.name,
        phoneNumber: null,
        photoURL: null,
        providerId: "password",
      } as User

      userData = {
        ...devUser,
      }
    } else {
      logOperation("Using Firebase authentication", { email })
      // Use actual Firebase authentication
      const userCredential = await signInWithEmailAndPassword(auth, email, password)
      user = userCredential.user
      logOperation("Firebase user authenticated", { uid: user.uid })

      // Get user role from Firestore - check users collection first
      let userDoc = await getDoc(doc(db, "users", user.uid))

      if (userDoc.exists()) {
        userData = userDoc.data()
        logOperation("User data retrieved from users collection", { role: userData.role })
      } else {
        // Check user_accounts collection for patients
        userDoc = await getDoc(doc(db, "user_accounts", user.uid))

        if (userDoc.exists()) {
          userData = userDoc.data()
          userData.role = "patient" // Ensure role is set for patients
          logOperation("User data retrieved from user_accounts collection", { role: "patient" })
        } else {
          logOperation("User data not found", { uid: user.uid })
          throw new Error("User data not found")
        }
      }
    }

    const role = userData.role

    if (!role) {
      logOperation("User role not defined", { email })
      throw new Error("User role not defined")
    }

    logOperation("Creating JWT token", { role })

    // Create JWT token
    const secret = new TextEncoder().encode(process.env.JWT_SECRET || "default_secret")
    const token = await new SignJWT({
      uid: user.uid,
      email: user.email,
      role,
    })
      .setProtectedHeader({ alg: "HS256" })
      .setIssuedAt()
      .setExpirationTime("24h")
      .sign(secret)

    logOperation("JWT token created successfully", {})

    // Set cookie
    document.cookie = `authToken=${token}; path=/; max-age=${60 * 60 * 24}; SameSite=Strict; Secure`
    logOperation("Auth cookie set successfully", {})

    // Return user with role
    return {
      ...user,
      role: role as "admin" | "doctor" | "hospital" | "patient",
    }
  } catch (error: any) {
    logOperation("Sign in error", error.message)
    throw new Error(error.message || "Failed to sign in")
  }
}

export const signUp = async (email: string, password: string, userData: any) => {
  try {
    logOperation("Sign up attempt", { email, role: userData.role })
    const userCredential = await createUserWithEmailAndPassword(auth, email, password)
    const user = userCredential.user
    logOperation("User created", { uid: user.uid })

    // Save user data to appropriate Firestore collection based on role
    if (userData.role === "patient") {
      await setDoc(doc(db, "user_accounts", user.uid), {
        ...userData,
        email,
        createdAt: new Date(),
      })
      logOperation("Patient data saved to user_accounts collection", {})
    } else {
      await setDoc(doc(db, "users", user.uid), {
        ...userData,
        email,
        createdAt: new Date(),
      })
      logOperation("User data saved to users collection", { role: userData.role })
    }

    return user
  } catch (error: any) {
    logOperation("Sign up error", error.message)
    throw new Error(error.message || "Failed to sign up")
  }
}

export const signOut = async () => {
  try {
    logOperation("Sign out attempt", {})
    await firebaseSignOut(auth)
    logOperation("Firebase sign out successful", {})

    // Clear auth cookie
    document.cookie = "authToken=; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT; SameSite=Strict; Secure"
    logOperation("Auth cookie cleared", {})
  } catch (error: any) {
    logOperation("Sign out error", error.message)
    throw new Error(error.message || "Failed to sign out")
  }
}

// Update the getCurrentUser function to be more reliable
export const getCurrentUser = (): Promise<UserWithRole | null> => {
  logOperation("Getting current user", {})

  return new Promise((resolve, reject) => {
    // First check if there's a current user in Firebase Auth
    const currentUser = auth.currentUser

    if (currentUser) {
      // If we have a current user, get their role
      handleUserWithRole(currentUser, resolve, reject)
    } else {
      // If no current user, set up a one-time auth state listener
      const unsubscribe = onAuthStateChanged(
        auth,
        async (user) => {
          unsubscribe() // Unsubscribe immediately after first callback

          if (user) {
            logOperation("Current user found", { uid: user.uid })
            handleUserWithRole(user, resolve, reject)
          } else {
            // For development purposes, check if we have dev credentials in cookies
            try {
              const authCookie = document.cookie.split("; ").find((row) => row.startsWith("authToken="))

              if (authCookie) {
                logOperation("Auth cookie found, but no Firebase user", {})
                // Return a minimal user object for development
                resolve({
                  uid: "temp-user-id",
                  email: "temp@example.com",
                  role: "admin", // Default to admin for testing
                } as UserWithRole)
              } else {
                logOperation("No current user found", {})
                resolve(null)
              }
            } catch (error) {
              logOperation("No current user found", {})
              resolve(null)
            }
          }
        },
        (error) => {
          logOperation("Error in onAuthStateChanged", error)
          unsubscribe()
          reject(error)
        },
      )
    }
  })
}

// Helper function to get user role and resolve the promise
const handleUserWithRole = async (
  user: User,
  resolve: (user: UserWithRole | null) => void,
  reject: (error: any) => void,
) => {
  try {
    // Check users collection first (for admin, doctor, hospital)
    let userDoc = await getDoc(doc(db, "users", user.uid))

    if (userDoc.exists()) {
      const userData = userDoc.data()
      logOperation("User data retrieved from users collection", { role: userData.role })
      resolve({
        ...user,
        role: userData.role as "admin" | "doctor" | "hospital",
      })
    } else {
      // Check user_accounts collection for patients
      userDoc = await getDoc(doc(db, "user_accounts", user.uid))

      if (userDoc.exists()) {
        logOperation("User data retrieved from user_accounts collection", { role: "patient" })
        resolve({
          ...user,
          role: "patient",
        })
      } else {
        logOperation("No user data found in Firestore", {})
        resolve(user as UserWithRole)
      }
    }
  } catch (error) {
    logOperation("Error getting user role", error)
    resolve(user as UserWithRole)
  }
}

export const updateUserPassword = async (currentPassword: string, newPassword: string) => {
  try {
    logOperation("Update password attempt", {})
    const user = auth.currentUser
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

