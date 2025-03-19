"use client"

import type React from "react"

import { useState, useEffect, useRef } from "react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Separator } from "@/components/ui/separator"
import { Send, Bot, AlertCircle, Sparkles } from "lucide-react"
import { Alert, AlertDescription } from "@/components/ui/alert"
import { sendChatMessage, getChatHistory } from "@/lib/firebase/firestore"
import { getCurrentUser } from "@/lib/firebase/auth"

interface ChatMessage {
  id: string
  content: string
  sender: "user" | "ai"
  timestamp: number
  userId: string
}

export default function ChatPage() {
  const [messages, setMessages] = useState<ChatMessage[]>([])
  const [newMessage, setNewMessage] = useState("")
  const [loading, setLoading] = useState(true)
  const [sending, setSending] = useState(false)
  const [error, setError] = useState("")
  const messagesEndRef = useRef<HTMLDivElement>(null)
  const [user, setUser] = useState<any>(null)

  useEffect(() => {
    const fetchUser = async () => {
      try {
        const currentUser = await getCurrentUser()
        setUser(currentUser)
      } catch (error) {
        console.error("Error fetching user:", error)
      } finally {
        fetchChatHistory()
      }
    }

    fetchUser()
  }, [])

  const fetchChatHistory = async () => {
    try {
      const history = await getChatHistory()
      setMessages(history)
    } catch (error) {
      console.error("Error fetching chat history:", error)
      setError("Failed to load chat history")
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    scrollToBottom()
  }, [messages])

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" })
  }

  const handleSendMessage = async (e: React.FormEvent) => {
    e.preventDefault()

    if (!newMessage.trim()) return

    try {
      setSending(true)
      setError("")

      // Add user message to UI immediately
      const userMessage: ChatMessage = {
        id: Date.now().toString(),
        content: newMessage,
        sender: "user",
        timestamp: Date.now(),
        userId: user?.uid || "",
      }

      setMessages((prev) => [...prev, userMessage])
      setNewMessage("")

      // Send message to backend and get AI response
      const aiResponse = await sendChatMessage(newMessage)

      // Add AI response to UI
      const aiMessage: ChatMessage = {
        id: (Date.now() + 1).toString(),
        content: aiResponse,
        sender: "ai",
        timestamp: Date.now(),
        userId: "ai",
      }

      setMessages((prev) => [...prev, aiMessage])
    } catch (error) {
      console.error("Error sending message:", error)
      setError("Failed to send message. Please try again.")
    } finally {
      setSending(false)
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
        <h1 className="text-3xl font-bold tracking-tight">AI Assistant</h1>
        <p className="text-muted-foreground">Get help with medical questions and patient care</p>
      </div>

      {error && (
        <Alert variant="destructive">
          <AlertCircle className="h-4 w-4" />
          <AlertDescription>{error}</AlertDescription>
        </Alert>
      )}

      <Card className="h-[calc(100vh-12rem)]">
        <CardHeader>
          <div className="flex items-center gap-2">
            <Avatar className="h-8 w-8">
              <AvatarImage src="/placeholder.svg?height=32&width=32" alt="AI" />
              <AvatarFallback>
                <Bot className="h-4 w-4" />
              </AvatarFallback>
            </Avatar>
            <div>
              <CardTitle>Medical AI Assistant</CardTitle>
              <CardDescription>Powered by advanced healthcare AI</CardDescription>
            </div>
          </div>
        </CardHeader>
        <CardContent className="overflow-y-auto h-[calc(100%-8rem)]">
          <div className="space-y-4">
            {messages.length === 0 ? (
              <div className="flex flex-col items-center justify-center h-full text-center p-4">
                <Sparkles className="h-12 w-12 text-primary mb-4" />
                <h3 className="text-lg font-medium">Welcome to the Medical AI Assistant</h3>
                <p className="text-muted-foreground mt-2 max-w-md">
                  Ask me questions about patient care, medical conditions, treatment options, or help interpreting
                  holter monitor data.
                </p>
              </div>
            ) : (
              messages.map((message) => (
                <div key={message.id} className={`flex ${message.sender === "user" ? "justify-end" : "justify-start"}`}>
                  <div className={`flex gap-3 max-w-[80%] ${message.sender === "user" ? "flex-row-reverse" : ""}`}>
                    <Avatar className="h-8 w-8 mt-0.5">
                      {message.sender === "user" ? (
                        <>
                          <AvatarImage src="/placeholder.svg?height=32&width=32" alt="User" />
                          <AvatarFallback>U</AvatarFallback>
                        </>
                      ) : (
                        <>
                          <AvatarImage src="/placeholder.svg?height=32&width=32" alt="AI" />
                          <AvatarFallback>
                            <Bot className="h-4 w-4" />
                          </AvatarFallback>
                        </>
                      )}
                    </Avatar>
                    <div
                      className={`rounded-lg p-3 ${
                        message.sender === "user" ? "bg-primary text-primary-foreground" : "bg-muted"
                      }`}
                    >
                      <p className="text-sm whitespace-pre-wrap">{message.content}</p>
                      <p className="text-xs opacity-70 mt-1">{new Date(message.timestamp).toLocaleTimeString()}</p>
                    </div>
                  </div>
                </div>
              ))
            )}
            <div ref={messagesEndRef} />
          </div>
        </CardContent>
        <Separator />
        <CardFooter className="p-4">
          <form onSubmit={handleSendMessage} className="flex w-full gap-2">
            <Input
              placeholder="Type your message..."
              value={newMessage}
              onChange={(e) => setNewMessage(e.target.value)}
              disabled={sending}
              className="flex-1"
            />
            <Button type="submit" disabled={sending || !newMessage.trim()}>
              {sending ? (
                <div className="h-4 w-4 animate-spin rounded-full border-2 border-current border-t-transparent" />
              ) : (
                <Send className="h-4 w-4" />
              )}
            </Button>
          </form>
        </CardFooter>
      </Card>
    </div>
  )
}

