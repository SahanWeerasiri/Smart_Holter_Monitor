"use client"

import { useEffect, useRef, useState } from "react"
import { Card, CardContent } from "@/components/ui/card"
import { getHeartRateData } from "@/lib/firebase/realtime"

interface HeartRateChartProps {
  timeRange?: { start: number; end: number }
  interactive?: boolean
}

export default function HeartRateChart({
  timeRange = { start: 0, end: 24 },
  interactive = false,
}: HeartRateChartProps) {
  const chartRef = useRef<HTMLDivElement>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState("")
  const [chartInstance, setChartInstance] = useState<any>(null)

  useEffect(() => {
    let chart: any = null

    const initChart = async () => {
      try {
        setLoading(true)

        // Dynamically import Chart.js to avoid SSR issues
        const { Chart, LineController, LineElement, PointElement, LinearScale, TimeScale, Legend, Tooltip } =
          await import("chart.js")
        \
        const { default: 'chartjs-plugin-zoom' } = await import('chartjs-plugin-zoom');

        Chart.register(LineController, LineElement, PointElement, LinearScale, TimeScale, Legend, Tooltip)

        // Get heart rate data from Firebase Realtime Database
        const heartRateData = await getHeartRateData(timeRange.start, timeRange.end)

        if (!chartRef.current) return

        // Destroy previous chart if it exists
        if (chartInstance) {
          chartInstance.destroy()
        }

        // Create new chart
        const ctx = document.createElement("canvas")
        chartRef.current.innerHTML = ""
        chartRef.current.appendChild(ctx)

        chart = new Chart(ctx, {
          type: "line",
          data: {
            datasets: [
              {
                label: "Channel 1",
                data: heartRateData.channel1,
                borderColor: "rgba(75, 192, 192, 1)",
                borderWidth: 1,
                pointRadius: 0,
                tension: 0.1,
              },
              {
                label: "Channel 2",
                data: heartRateData.channel2,
                borderColor: "rgba(153, 102, 255, 1)",
                borderWidth: 1,
                pointRadius: 0,
                tension: 0.1,
              },
              {
                label: "Channel 3",
                data: heartRateData.channel3,
                borderColor: "rgba(255, 99, 132, 1)",
                borderWidth: 1,
                pointRadius: 0,
                tension: 0.1,
              },
            ],
          },
          options: {
            responsive: true,
            maintainAspectRatio: false,
            scales: {
              x: {
                type: "time",
                time: {
                  unit: "hour",
                  displayFormats: {
                    hour: "HH:mm",
                  },
                },
                title: {
                  display: true,
                  text: "Time",
                },
              },
              y: {
                title: {
                  display: true,
                  text: "mV",
                },
              },
            },
            plugins: {
              legend: {
                position: "top",
              },
              tooltip: {
                mode: "index",
                intersect: false,
              },
              zoom: interactive
                ? {
                    pan: {
                      enabled: true,
                      mode: "x",
                    },
                    zoom: {
                      wheel: {
                        enabled: true,
                      },
                      pinch: {
                        enabled: true,
                      },
                      mode: "x",
                    },
                  }
                : undefined,
            },
          },
        })

        setChartInstance(chart)
      } catch (error) {
        console.error("Error initializing heart rate chart:", error)
        setError("Failed to load heart rate data")
      } finally {
        setLoading(false)
      }
    }

    initChart()

    return () => {
      if (chartInstance) {
        chartInstance.destroy()
      }
    }
  }, [timeRange, interactive])

  // Update chart when time range changes
  useEffect(() => {
    if (chartInstance) {
      const updateChartData = async () => {
        try {
          const heartRateData = await getHeartRateData(timeRange.start, timeRange.end)

          chartInstance.data.datasets[0].data = heartRateData.channel1
          chartInstance.data.datasets[1].data = heartRateData.channel2
          chartInstance.data.datasets[2].data = heartRateData.channel3

          chartInstance.update()
        } catch (error) {
          console.error("Error updating heart rate chart:", error)
        }
      }

      updateChartData()
    }
  }, [timeRange, chartInstance])

  if (loading) {
    return (
      <Card>
        <CardContent className="flex items-center justify-center h-full p-6">
          <div className="h-8 w-8 animate-spin rounded-full border-4 border-primary border-t-transparent"></div>
        </CardContent>
      </Card>
    )
  }

  if (error) {
    return (
      <Card>
        <CardContent className="flex items-center justify-center h-full p-6">
          <p className="text-destructive">{error}</p>
        </CardContent>
      </Card>
    )
  }

  return <div ref={chartRef} className="w-full h-full" />
}

