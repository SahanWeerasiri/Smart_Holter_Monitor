import {
  getAuth,
  signInWithEmailAndPassword,
  signOut as firebaseSignOut,
  onAuthStateChanged,
  type User,
} from "firebase/auth"
import { app } from "./config"

const auth = getAuth(app)

export const signIn = async (email: string, password: string) => {
  try {
    const userCredential = await signInWithEmailAndPassword(auth, email, password)
    return userCredential.user
  } catch (error: any) {
    throw new Error(error.message || "Failed to sign in")
  }
}

export const signOut = async () => {
  try {
    await firebaseSignOut(auth)
  } catch (error: any) {
    throw new Error(error.message || "Failed to sign out")
  }
}

export const getCurrentUser = (): Promise<User | null> => {
  return new Promise((resolve, reject) => {
    const unsubscribe = onAuthStateChanged(
      auth,
      (user) => {
        unsubscribe()
        resolve(user)
      },
      (error) => {
        unsubscribe()
        reject(error)
      },
    )
  })
}

