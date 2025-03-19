"use client"

import { Progress } from "@/components/ui/progress"
import { Cpu } from "lucide-react"

interface MemoryChipProps {
  memoryUsed: number
  memoryCapacity: number
}

export default function MemoryChip({ memoryUsed, memoryCapacity }: MemoryChipProps) {
  const percentUsed = (memoryUsed / memoryCapacity) * 100
  const remainingMemory = memoryCapacity - memoryUsed

  // Determine color based on memory usage
  const getStatusColor = () => {
    if (percentUsed < 50) return "text-green-500"
    if (percentUsed < 80) return "text-amber-500"
    return "text-red-500"
  }

  // Determine progress color based on memory usage
  const getProgressColor = () => {
    if (percentUsed < 50) return "bg-green-500"
    if (percentUsed < 80) return "bg-amber-500"
    return "bg-red-500"
  }

  // Calculate estimated remaining recording time
  const getRemainingTime = () => {
    // Assuming 10MB per hour of recording
    const hoursRemaining = remainingMemory / 10

    if (hoursRemaining < 1) {
      return `${Math.round(hoursRemaining * 60)} minutes`
    }

    return `${hoursRemaining.toFixed(1)} hours`
  }

  return (
    <div className="space-y-2">
      <div className="flex items-center gap-2">
        <Cpu className={`h-5 w-5 ${getStatusColor()}`} />
        <div className="text-sm font-medium">
          {memoryUsed.toFixed(2)} MB / {memoryCapacity} MB
        </div>
      </div>

      <Progress value={percentUsed} className="h-2" indicatorClassName={getProgressColor()} />

      <div className="grid grid-cols-2 gap-2 text-xs">
        <div>
          <span className="text-slate-500">Remaining:</span>
          <span className="ml-1 font-medium">{remainingMemory.toFixed(2)} MB</span>
        </div>
        <div>
          <span className="text-slate-500">Est. time left:</span>
          <span className="ml-1 font-medium">{getRemainingTime()}</span>
        </div>
        <div>
          <span className="text-slate-500">Data format:</span>
          <span className="ml-1 font-medium">[timestamp, 0-4095]</span>
        </div>
        <div>
          <span className="text-slate-500">Baseline:</span>
          <span className="ml-1 font-medium">1024</span>
        </div>
      </div>

      <div className="flex items-center justify-center mt-2">
        <div className="relative w-16 h-16 flex items-center justify-center">
          {/* Chip visualization */}
          <div className="absolute inset-0 border-2 border-slate-400 bg-slate-200 rounded-md"></div>
          <div className="absolute top-1 left-1 right-1 h-2 bg-slate-300 rounded"></div>
          <div className="absolute bottom-1 left-1 right-1 h-2 bg-slate-300 rounded"></div>

          {/* Chip pins */}
          {Array.from({ length: 6 }).map((_, i) => (
            <div
              key={`left-pin-${i}`}
              className="absolute w-1 h-0.5 bg-slate-500 left-0 transform -translate-x-1"
              style={{ top: `${(i + 1) * 2 + 2}px` }}
            ></div>
          ))}

          {Array.from({ length: 6 }).map((_, i) => (
            <div
              key={`right-pin-${i}`}
              className="absolute w-1 h-0.5 bg-slate-500 right-0 transform translate-x-1"
              style={{ top: `${(i + 1) * 2 + 2}px` }}
            ></div>
          ))}

          <div className={`text-xs font-bold ${getStatusColor()}`}>{percentUsed.toFixed(0)}%</div>
        </div>
      </div>
    </div>
  )
}

