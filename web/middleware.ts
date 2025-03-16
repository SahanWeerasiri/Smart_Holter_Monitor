import { NextResponse } from "next/server"
import type { NextRequest } from "next/server"
import { jwtVerify } from "jose"

// This function can be marked `async` if using `await` inside
export async function middleware(request: NextRequest) {
  console.log(`[MIDDLEWARE] Processing request for path: ${request.nextUrl.pathname}`)

  // Get the pathname
  const path = request.nextUrl.pathname

  // Define public paths that don't require authentication
  const isPublicPath = path === "/login" || path === "/" || path === "/forgot-password"
  console.log(`[MIDDLEWARE] Is public path: ${isPublicPath}`)

  // Get the token from the cookies
  const token = request.cookies.get("authToken")?.value || ""
  console.log(`[MIDDLEWARE] Auth token exists: ${!!token}`)

  // If no token and trying to access protected route, redirect to login
  if (!isPublicPath && !token) {
    console.log(`[MIDDLEWARE] No token for protected route, redirecting to login`)
    return NextResponse.redirect(new URL("/login", request.url))
  }

  // If token exists and trying to access public route, check role and redirect accordingly
  if (isPublicPath && token) {
    try {
      console.log(`[MIDDLEWARE] Token exists for public route, verifying token`)
      // Verify and decode the JWT token
      const secret = new TextEncoder().encode(process.env.JWT_SECRET || "default_secret")
      const { payload } = await jwtVerify(token, secret)

      // Extract role from payload
      const role = payload.role as string
      console.log(`[MIDDLEWARE] Token verified, user role: ${role}`)

      // Redirect based on role
      if (role === "admin") {
        console.log(`[MIDDLEWARE] Redirecting admin to admin dashboard`)
        return NextResponse.redirect(new URL("/dashboard/admin", request.url))
      } else if (role === "doctor") {
        console.log(`[MIDDLEWARE] Redirecting doctor to doctor dashboard`)
        return NextResponse.redirect(new URL("/dashboard", request.url))
      } else if (role === "hospital") {
        console.log(`[MIDDLEWARE] Redirecting hospital to hospital dashboard`)
        return NextResponse.redirect(new URL("/dashboard/hospital", request.url))
      }
    } catch (error) {
      console.error(`[MIDDLEWARE] Token verification failed:`, error)
      // If token verification fails, clear the cookie and continue to login
      const response = NextResponse.redirect(new URL("/login", request.url))
      response.cookies.delete("authToken")
      console.log(`[MIDDLEWARE] Deleted invalid auth token cookie`)
      return response
    }
  }

  // Role-based access control for protected routes
  if (!isPublicPath && token) {
    try {
      console.log(`[MIDDLEWARE] Verifying token for protected route`)
      // Verify and decode the JWT token
      const secret = new TextEncoder().encode(process.env.JWT_SECRET || "default_secret")
      const { payload } = await jwtVerify(token, secret)

      // Extract role from payload
      const role = payload.role as string
      console.log(`[MIDDLEWARE] Token verified, user role: ${role}, accessing path: ${path}`)

      // Admin routes
      if (path.startsWith("/dashboard/admin") && role !== "admin") {
        console.log(`[MIDDLEWARE] Non-admin user attempting to access admin route, redirecting`)
        return NextResponse.redirect(new URL(role === "doctor" ? "/dashboard" : "/dashboard/hospital", request.url))
      }

      // Hospital routes
      if (path.startsWith("/dashboard/hospital") && role !== "hospital") {
        console.log(`[MIDDLEWARE] Non-hospital user attempting to access hospital route, redirecting`)
        return NextResponse.redirect(new URL(role === "admin" ? "/dashboard/admin" : "/dashboard", request.url))
      }

      // Doctor routes (default dashboard)
      if (
        path === "/dashboard" &&
        role !== "doctor" &&
        !path.startsWith("/dashboard/admin") &&
        !path.startsWith("/dashboard/hospital")
      ) {
        console.log(`[MIDDLEWARE] Non-doctor user attempting to access doctor dashboard, redirecting`)
        return NextResponse.redirect(
          new URL(role === "admin" ? "/dashboard/admin" : "/dashboard/hospital", request.url),
        )
      }
    } catch (error) {
      console.error(`[MIDDLEWARE] Token verification failed for protected route:`, error)
      // If token verification fails, clear the cookie and redirect to login
      const response = NextResponse.redirect(new URL("/login", request.url))
      response.cookies.delete("authToken")
      console.log(`[MIDDLEWARE] Deleted invalid auth token cookie and redirecting to login`)
      return response
    }
  }

  // Continue with the request if no redirects are needed
  console.log(`[MIDDLEWARE] Request allowed to proceed`)
  return NextResponse.next()
}

// Configure the paths that should trigger this middleware
export const config = {
  matcher: ["/", "/login", "/dashboard", "/dashboard/:path*", "/forgot-password"],
}

