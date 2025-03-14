// Generate mock heart rate data for demo purposes
const generateMockHeartRateData = (startHour: number, endHour: number) => {
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

export const getHeartRateData = async (startHour: number, endHour: number) => {
  try {
    // In a real application, you would fetch data from Firebase Realtime Database
    // For demo purposes, we'll generate mock data

    // This is how you would fetch real data from Firebase:
    /*
    const startTime = new Date();
    startTime.setHours(startHour, 0, 0, 0);
    
    const endTime = new Date();
    endTime.setHours(endHour, 0, 0, 0);
    
    const heartRateRef = ref(rtdb, 'heartRateData');
    const heartRateQuery = query(
      heartRateRef,
      orderByChild('timestamp'),
      startAt(startTime.getTime()),
      endAt(endTime.getTime())
    );
    
    const snapshot = await get(heartRateQuery);
    const data = snapshot.val();
    
    // Process the data into the format needed for the chart
    */

    // For demo, return mock data
    return generateMockHeartRateData(startHour, endHour)
  } catch (error) {
    console.error("Error fetching heart rate data:", error)
    throw error
  }
}

