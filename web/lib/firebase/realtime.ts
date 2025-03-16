import { ref, get, update, push, onValue, off } from "firebase/database"
import { rtdb, logOperation } from "./config"

// Generate mock heart rate data for demo purposes
export const generateMockHeartRateData = (startHour: number, endHour: number) => {
  logOperation("Generating mock heart rate data", { startHour, endHour })

  const channel1 = []
  const channel2 = []
  const channel3 = []

  const startTime = new Date()
  startTime.setHours(startHour, 0, 0, 0)

  const endTime = new Date()
  endTime.setHours(endHour, 0, 0, 0)

  // If end time is before start time, assume it's the next day
  if (endTime < startTime) {
    endTime.setDate(endTime.getDate() + 1)
  }

  // Generate data points every 5 seconds
  const interval = 5 * 1000 // 5 seconds in milliseconds
  const totalPoints = Math.floor((endTime.getTime() - startTime.getTime()) / interval)

  for (let i = 0; i < totalPoints; i++) {
    const time = new Date(startTime.getTime() + i * interval)

    // Generate realistic-looking ECG patterns with some randomness
    const baseValue1 = Math.sin(i * 0.2) * 0.5
    const baseValue2 = Math.sin(i * 0.2 + 1) * 0.4
    const baseValue3 = Math.sin(i * 0.2 + 2) * 0.6

    // Add R peaks (heartbeats) approximately every 60 data points (assuming 72 bpm)
    const rPeak1 = i % 60 < 3 ? 1.5 : 0
    const rPeak2 = (i + 20) % 60 < 3 ? 1.2 : 0
    const rPeak3 = (i + 40) % 60 < 3 ? 1.8 : 0

    // Add some noise
    const noise1 = (Math.random() - 0.5) * 0.1
    const noise2 = (Math.random() - 0.5) * 0.1
    const noise3 = (Math.random() - 0.5) * 0.1

    // Add occasional anomalies (about 1% of the time)
    const anomaly1 = Math.random() > 0.99 ? (Math.random() - 0.5) * 2 : 0
    const anomaly2 = Math.random() > 0.99 ? (Math.random() - 0.5) * 2 : 0
    const anomaly3 = Math.random() > 0.99 ? (Math.random() - 0.5) * 2 : 0

    channel1.push({
      x: time.getTime(),
      y: baseValue1 + rPeak1 + noise1 + anomaly1,
    })

    channel2.push({
      x: time.getTime(),
      y: baseValue2 + rPeak2 + noise2 + anomaly2,
    })

    channel3.push({
      x: time.getTime(),
      y: baseValue3 + rPeak3 + noise3 + anomaly3,
    })
  }

  return { channel1, channel2, channel3 }
}

export const getHeartRateData = async (deviceId: string, startHour: number, endHour: number) => {
  try {
    logOperation("Getting heart rate data", { deviceId, startHour, endHour })

    // Get device data from Realtime Database
    const deviceRef = ref(rtdb, `devices/${deviceId}/data`)
    const deviceSnapshot = await get(deviceRef)

    if (!deviceSnapshot.exists()) {
      logOperation("No data found for device", { deviceId })
      // Return mock data for demo purposes
      return generateMockHeartRateData(startHour, endHour)
    }

    const deviceData = deviceSnapshot.val() || []

    // Filter data by time range
    const startTime = new Date()
    startTime.setHours(startHour, 0, 0, 0)

    const endTime = new Date()
    endTime.setHours(endHour, 0, 0, 0)

    // Process data into channels
    const channel1 = []
    const channel2 = []
    const channel3 = []

    for (const dataPoint of deviceData) {
      const timestamp = dataPoint.timestamp

      if (timestamp >= startTime.getTime() && timestamp <= endTime.getTime()) {
        // Split the value into 3 channels (for demo purposes)
        const value = dataPoint.value

        channel1.push({
          x: timestamp,
          y: value * 0.5,
        })

        channel2.push({
          x: timestamp,
          y: value * 0.75,
        })

        channel3.push({
          x: timestamp,
          y: value,
        })
      }
    }

    // If no data points found in the time range, return mock data
    if (channel1.length === 0) {
      logOperation("No data found in time range, using mock data", { deviceId, startHour, endHour })
      return generateMockHeartRateData(startHour, endHour)
    }

    logOperation("Heart rate data retrieved", { deviceId, dataPoints: channel1.length })
    return { channel1, channel2, channel3 }
  } catch (error) {
    logOperation("Error getting heart rate data", error)
    // Return mock data for demo purposes
    return generateMockHeartRateData(startHour, endHour)
  }
}

export const addDeviceDataPoint = async (deviceId: string, value: number) => {
  try {
    logOperation("Adding device data point", { deviceId, value })

    // Get device reference
    const deviceRef = ref(rtdb, `devices/${deviceId}/data`)

    // Add new data point
    const newDataPoint = {
      timestamp: Date.now(),
      value: value,
    }

    await push(deviceRef, newDataPoint)
    logOperation("Device data point added", { deviceId })

    return true
  } catch (error) {
    logOperation("Error adding device data point", error)
    throw error
  }
}

export const subscribeToDeviceData = (deviceId: string, callback: (data: any) => void) => {
  logOperation("Subscribing to device data", { deviceId })

  const deviceRef = ref(rtdb, `devices/${deviceId}/data`)

  onValue(deviceRef, (snapshot) => {
    const data = snapshot.val() || []
    callback(data)
  })

  // Return unsubscribe function
  return () => {
    logOperation("Unsubscribing from device data", { deviceId })
    off(deviceRef)
  }
}

export const getDeviceDetails = async (deviceId: string) => {
  try {
    logOperation("Getting device details", { deviceId })

    const deviceRef = ref(rtdb, `devices/${deviceId}`)
    const deviceSnapshot = await get(deviceRef)

    if (!deviceSnapshot.exists()) {
      logOperation("Device not found", { deviceId })
      throw new Error("Device not found")
    }

    const deviceData = deviceSnapshot.val()
    logOperation("Device details retrieved", { deviceId })

    return {
      id: deviceId,
      use: deviceData.use || "",
      assigned: deviceData.assigned,
      isDone: deviceData.isDone || false,
      hospitalId: deviceData.hospitalId || "",
      deadline: deviceData.deadline,
      other: deviceData.other || "",
    }
  } catch (error) {
    logOperation("Error getting device details", error)
    throw error
  }
}

export const updateDeviceDetails = async (deviceId: string, details: any) => {
  try {
    logOperation("Updating device details", { deviceId })

    const deviceRef = ref(rtdb, `devices/${deviceId}`)
    await update(deviceRef, details)

    logOperation("Device details updated", { deviceId })
    return true
  } catch (error) {
    logOperation("Error updating device details", error)
    throw error
  }
}

