/**
 * Development helper functions
 * These functions are only for development and testing purposes
 */

export const setDevelopmentRole = (role: "admin" | "doctor" | "hospital" | "patient") => {
    if (process.env.NODE_ENV !== "production") {
        localStorage.setItem("userRole", role)
        console.log(`[DEV] Set development role to: ${role}`)

        // Create a JWT-like token for the auth cookie (not a real JWT, just for development)
        const fakeToken = btoa(JSON.stringify({ role }))
        document.cookie = `authToken=${fakeToken}; path=/; max-age=${60 * 60 * 24}; SameSite=Strict;`

        console.log(`[DEV] Set development auth cookie`)
        return true
    }
    return false
}

export const clearDevelopmentRole = () => {
    if (process.env.NODE_ENV !== "production") {
        localStorage.removeItem("userRole")
        document.cookie = "authToken=; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT; SameSite=Strict;"
        console.log(`[DEV] Cleared development role and auth cookie`)
        return true
    }
    return false
}

