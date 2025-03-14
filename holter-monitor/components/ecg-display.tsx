"use client"

import { useRef, useEffect } from "react"

interface EcgDisplayProps {
  data: number[]
  isRunning: boolean
}

export default function EcgDisplay({ data, isRunning }: EcgDisplayProps) {
  const canvasRef = useRef<HTMLCanvasElement>(null)

  useEffect(() => {
    const canvas = canvasRef.current
    if (!canvas) return

    const ctx = canvas.getContext("2d")
    if (!ctx) return

    // Set canvas dimensions
    const dpr = window.devicePixelRatio || 1
    const rect = canvas.getBoundingClientRect()

    canvas.width = rect.width * dpr
    canvas.height = rect.height * dpr

    ctx.scale(dpr, dpr)

    // Clear canvas
    ctx.clearRect(0, 0, rect.width, rect.height)

    // If not running, draw a flat line
    if (!isRunning || data.length === 0) {
      ctx.beginPath()
      ctx.moveTo(0, rect.height / 2)
      ctx.lineTo(rect.width, rect.height / 2)
      ctx.strokeStyle = "#22c55e" // Green color
      ctx.lineWidth = 2
      ctx.stroke()
      return
    }

    // Draw grid
    drawGrid(ctx, rect.width, rect.height)

    // Draw ECG line
    ctx.beginPath()

    const pointSpacing = rect.width / Math.min(200, data.length - 1)

    // For the Python code pattern, baseline is 1024
    const baseline = 1024
    const verticalScale = rect.height / 4096 // Scale for full 0-4095 range

    data.forEach((point, index) => {
      const x = index * pointSpacing
      // Invert the y-coordinate because canvas 0 is at the top
      const y = rect.height - point * verticalScale

      if (index === 0) {
        ctx.moveTo(x, y)
      } else {
        ctx.lineTo(x, y)
      }
    })

    ctx.strokeStyle = "#22c55e" // Green color
    ctx.lineWidth = 2
    ctx.stroke()

    // Draw baseline
    ctx.beginPath()
    ctx.moveTo(0, rect.height - baseline * verticalScale)
    ctx.lineTo(rect.width, rect.height - baseline * verticalScale)
    ctx.strokeStyle = "rgba(34, 197, 94, 0.3)" // Light green
    ctx.lineWidth = 1
    ctx.setLineDash([5, 5])
    ctx.stroke()
    ctx.setLineDash([])
  }, [data, isRunning])

  // Draw the background grid
  const drawGrid = (ctx: CanvasRenderingContext2D, width: number, height: number) => {
    // Major grid
    ctx.beginPath()
    const majorGridSize = 50

    for (let x = 0; x <= width; x += majorGridSize) {
      ctx.moveTo(x, 0)
      ctx.lineTo(x, height)
    }

    for (let y = 0; y <= height; y += majorGridSize) {
      ctx.moveTo(0, y)
      ctx.lineTo(width, y)
    }

    ctx.strokeStyle = "rgba(34, 197, 94, 0.2)" // Light green
    ctx.lineWidth = 1
    ctx.stroke()

    // Minor grid
    ctx.beginPath()
    const minorGridSize = 10

    for (let x = 0; x <= width; x += minorGridSize) {
      ctx.moveTo(x, 0)
      ctx.lineTo(x, height)
    }

    for (let y = 0; y <= height; y += minorGridSize) {
      ctx.moveTo(0, y)
      ctx.lineTo(width, y)
    }

    ctx.strokeStyle = "rgba(34, 197, 94, 0.1)" // Very light green
    ctx.lineWidth = 0.5
    ctx.stroke()
  }

  return <canvas ref={canvasRef} className="w-full h-32 bg-black rounded" />
}

