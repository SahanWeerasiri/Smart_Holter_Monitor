"use client"

import { useMemo } from "react"
import { Line, LineChart, ResponsiveContainer, Tooltip, XAxis, YAxis, CartesianGrid, Legend } from "recharts"

export function TimeChart({
    data: data = [],
    xKey = "timestamp",
    series = [{ key: "value", name: "Value", color: "hsl(var(--chart-1))" }],
    height = 300,
    showGrid = true,
    showLegend = true,
    tooltipFormatter = null,
}) {
    // Format the timestamp for display
    const formatTimestamp = (timestamp: string) => {
        if (!timestamp) return ""

        // Check if timestamp is in the format "YYYY:MM:DD HH:MM:SS:SSS"
        if (typeof timestamp === "string" && timestamp.includes(":")) {
            const parts = timestamp.split(" ")
            if (parts.length === 2) {
                // Just return the time part for display
                return parts[1].split(":").slice(0, 3).join(":")
            }
        }

        // Fallback to original value
        return timestamp
    }

    // Custom tooltip formatter
    const defaultTooltipFormatter = (value: any, name: string) => {
        const seriesItem = series.find((s) => s.key === name)
        return [value, seriesItem?.name || name]
    }

    // Process data to ensure timestamps are properly formatted
    const processedData = useMemo(() => {
        if (!data || !data.length) return []

        return data.map((item: any) => {
            // Create a new object with the same properties
            const newItem = { ...item }

            // Format the timestamp if it exists
            if (newItem[xKey]) {
                newItem[`${xKey}Original`] = newItem[xKey] // Keep original for tooltip
            }

            return newItem
        })
    }, [data, xKey])

    return (
        <ResponsiveContainer width="100%" height={height}>
            <LineChart data={processedData} margin={{ top: 5, right: 30, left: 20, bottom: 5 }}>
                {showGrid && <CartesianGrid strokeDasharray="3 3" />}

                <XAxis dataKey={xKey} tickFormatter={formatTimestamp} minTickGap={30} />

                <YAxis />

                <Tooltip
                    labelFormatter={(label) => {
                        // Use the original timestamp for the tooltip label
                        const item = processedData.find((d: { [x: string]: any }) => d[xKey] === label)
                        return item ? item[`${xKey}Original`] || label : label
                    }}
                    formatter={tooltipFormatter || defaultTooltipFormatter}
                />

                {showLegend && <Legend />}

                {series.map((s) => (
                    <Line
                        key={s.key}
                        type="monotone"
                        dataKey={s.key}
                        name={s.name}
                        stroke={s.color}
                        activeDot={{ r: 8 }}
                        dot={false}
                    />
                ))}
            </LineChart>
        </ResponsiveContainer>
    )
}

