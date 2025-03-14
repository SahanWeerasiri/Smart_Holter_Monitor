import { NextResponse } from "next/server"
import type { NextRequest } from "next/server"

// This function can be marked `async` if using `await` inside
export function middleware(request: NextRequest) {
  // Get the pathname
  const path = request.nextUrl.pathname

  // Define public paths that don't require authentication
  const isPublicPath = path === "/login" || path === "/" || path === "/forgot-password"

  // Get the token from the cookies
  const token = request.cookies.get("authToken")?.value || ""

  // Redirect logic
  if (isPublicPath && token) {
    // If user is on a public path but has a token, redirect to dashboard
    return NextResponse.redirect(new URL("/dashboard", request.url))
  }

  if (!isPublicPath && !token) {
    // If user is on a protected path but doesn't have a token, redirect to login
    return NextResponse.redirect(new URL("/login", request.url))
  }

  // Continue with the request if no redirects are needed
  return NextResponse.next()
}

// Configure the paths that should trigger this middleware
export const config = {
  matcher: ["/", "/login", "/dashboard/:path*", "/forgot-password"],
}

