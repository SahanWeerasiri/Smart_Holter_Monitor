"use client"

import { useState, useEffect, useRef } from "react"
import { initializeApp } from "firebase/app"
import { get, getDatabase, ref, set } from "firebase/database"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardFooter, CardHeader, CardTitle } from "@/components/ui/card"
import { Battery, Clock, Database, MemoryStickIcon as Memory, Power, Wifi } from "lucide-react"
import EcgDisplay from "@/components/ecg-display"
import MemoryChip from "@/components/memory-chip"
import { toast } from "sonner"

// Firebase configuration - replace with your own config
const firebaseConfig = {
  apiKey: process.env.NEXT_PUBLIC_FIREBASE_API_KEY,
  authDomain: process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN,
  databaseURL: process.env.NEXT_PUBLIC_FIREBASE_DATABASE_URL,
  projectId: process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID,
  storageBucket: process.env.NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: process.env.NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID,
  appId: process.env.NEXT_PUBLIC_FIREBASE_APP_ID,
}

// Initialize Firebase
const app = initializeApp(firebaseConfig)
const database = getDatabase(app)

export default function HolterMonitor() {
  const [isRunning, setIsRunning] = useState(false)
  const [heartRate, setHeartRate] = useState(72)
  const [ecgData1, setEcgData1] = useState<number[]>([])
  const [ecgData2, setEcgData2] = useState<number[]>([])
  const [ecgData3, setEcgData3] = useState<number[]>([])
  const [memoryUsed, setMemoryUsed] = useState(0)
  const [batteryLevel, setBatteryLevel] = useState(98)
  const [lastSync, setLastSync] = useState<Date | null>(null)
  const [isSyncing, setIsSyncing] = useState(false)
  const [deviceCode, setDeviceCode] = useState<string>("");
  const [devices, setDevices] = useState<string[]>([]);

  // Add a new state for heartbeat animation
  const [heartbeatPulse, setHeartbeatPulse] = useState(false)

  // Constants for simulation
  const DATA_RATE = 20 // 20 data points per second
  const MEMORY_CAPACITY = 512 // 512 MB simulated memory
  const MEMORY_PER_HOUR = 10 // 10 MB per hour of recording
  const SYNC_INTERVAL = 5 * 60 * 1000 // 5 minutes in milliseconds

  // References for intervals
  const dataIntervalRef1 = useRef<NodeJS.Timeout | null>(null)
  const dataIntervalRef2 = useRef<NodeJS.Timeout | null>(null)
  const dataIntervalRef3 = useRef<NodeJS.Timeout | null>(null)
  const syncIntervalRef = useRef<NodeJS.Timeout | null>(null)
  const batteryIntervalRef = useRef<NodeJS.Timeout | null>(null)
  const heartbeatIntervalRef = useRef<NodeJS.Timeout | null>(null)

  // Buffer to store data before sending to Firebase
  const dataBufferRef1 = useRef<Map<string, number>>(new Map())
  const dataBufferRef2 = useRef<Map<string, number>>(new Map())
  const dataBufferRef3 = useRef<Map<string, number>>(new Map())
  const samplesPerBeat = 11 // As in the Python code
  const [heartRatesToSync, setHeartRateToSync] = useState<{ timestamp: string; value: number }[]>([]);
  const fetchDevices = async () => {
    try {
      // Fetch data from Firebase
      const snapshot = await get(ref(database, "devices"));

      // Check if data exists
      if (snapshot.exists()) {
        const devicesData = snapshot.val(); // Get the actual data
        const temp = [];

        // Iterate over the keys in the devices data
        for (let key in devicesData) {
          temp.push(key); // Push the device object into the array
        }

        // Update the state with the fetched devices
        setDevices(temp);
        console.log(temp);
      } else {
        console.log("No devices found.");
        setDevices([]); // Set devices to an empty array if no data exists
      }
    } catch (error) {
      console.error("Error fetching devices:", error);
    }
  };
  // Counter for position in the heartbeat cycle
  const beatPositionRef = useRef<number>(0)

  // Generate a realistic ECG waveform point based on the provided Python code
  const generateEcgPoint = () => {
    // Baseline value
    const baseline = 1024

    // Calculate samples per beat based on heart rate


    // Get current position in the beat cycle
    const position = beatPositionRef.current

    // Increment position for next call
    beatPositionRef.current = (position + 1) % samplesPerBeat

    // Normalize time within one heartbeat cycle (0 to 1)
    const t = position / samplesPerBeat

    let heartbeatValue

    // Following the pattern from the Python code
    if (0 < t && t < 0.1) {
      // Small P wave (pre-peak)
      heartbeatValue = baseline
    } else if (0.1 <= t && t < 0.2) {
      // Sharp QRS complex (high spike)
      heartbeatValue = Math.max(baseline, Math.floor(Math.random() * 512) + baseline)
    } else if (0.2 <= t && t < 0.3) {
      // T wave (post-peak bump)
      heartbeatValue = baseline
    } else if (0.3 <= t && t < 0.4) {
      heartbeatValue = Math.max(baseline - 512, Math.floor(Math.random() * 512) + (baseline - 512))
    } else if (0.4 <= t && t < 0.5) {
      heartbeatValue = Math.max(
        baseline + 1024,
        Math.floor(Math.random() * (4096 - (baseline + 1024))) + (baseline + 1024),
      )

      // Trigger heartbeat visual when we hit the R wave peak
      if (position === Math.floor(0.45 * samplesPerBeat)) {
        setHeartbeatPulse(true)
        setTimeout(() => setHeartbeatPulse(false), 150)
      }
    } else if (0.5 <= t && t < 0.6) {
      heartbeatValue = Math.max(baseline - 512, Math.floor(Math.random() * 512) + (baseline - 512))
    } else if (0.6 <= t && t < 0.8) {
      heartbeatValue = baseline
    } else if (0.8 <= t && t < 0.9) {
      heartbeatValue = Math.max(baseline + 512, Math.floor(Math.random() * 512) + (baseline + 512))
    } else {
      // Baseline (steady level)
      heartbeatValue = baseline
    }

    // Ensure the value stays within 0-4095 range
    return Math.max(0, Math.min(4095, Math.floor(heartbeatValue)))
  }

  // Variables to track R-peaks and calculate heart rate

  let count = 0;

  const startMonitor = () => {
    if (isRunning) return;

    setIsRunning(true);

    // Reset beat position
    beatPositionRef.current = 0;

    // Generate ECG data at the specified rate for each channel
    dataIntervalRef1.current = setInterval(() => {
      const timestamp = getDateTime();
      const newPoint = generateEcgPoint();

      // Update the displayed ECG data (keep only the last 200 points for display)
      setEcgData1((prev) => {
        const updated = [...prev, newPoint];
        return updated.slice(-200);
      });

      // Add to buffer for Firebase sync - store as [timestamp, value]
      dataBufferRef1.current.set(timestamp, newPoint);

      // Update memory usage
      const newMemoryUsed = memoryUsed + (1 / (DATA_RATE * 3600)) * MEMORY_PER_HOUR;
      setMemoryUsed(newMemoryUsed);

      // // Detect R-peak in channel 1
      const position = beatPositionRef.current;
      // const t = position / samplesPerBeat;

      // if (0.4 <= t && t < 0.6) {
      //   // This is the R-peak region
      //   if (position === Math.floor(0.45 * samplesPerBeat)) {
      //     const currentTime = Date.now();

      //     if (lastRPeakTime !== null) {
      //       // Calculate the time difference between consecutive R-peaks
      //       const interval = currentTime - lastRPeakTime;
      //       rPeakIntervalSum += interval;
      //       rPeakCount++;

      //       // Calculate average interval and heart rate
      //       if (rPeakCount >= 2) {
      //         const averageInterval = rPeakIntervalSum / rPeakCount;
      //         const heartRateBPM = Math.round((60 * 1000) / averageInterval);

      //         // Update heart rate state
      //         // setHeartRate((prev) => {
      //         //   // Smooth the transition using a weighted average
      //         //   const smoothedHeartRate = Math.round((prev * 0.7) + (heartRateBPM * 0.3));
      //         //   return Math.max(60, Math.min(100, smoothedHeartRate));
      //         // });
      //         setHeartRate(heartRateBPM);

      //         // Add the new heart rate to the sync array
      //         setHeartRateToSync((prev) => [
      //           ...prev,
      //           { timestamp: getDateTime(), value: heartRateBPM }, // Use heartRateBPM instead of heartRate
      //         ]);
      //       }
      //     }

      //     // Update last R-peak time
      //     lastRPeakTime = currentTime;
      //   }
      // }
      if (count > 20) {//by 30 seconds = 600
        let heartRateBPM = Math.round(Math.random() * 10 + 65);
        setHeartRate(heartRateBPM);
        //         // Add the new heart rate to the sync array
        setHeartRateToSync((prev) => [
          ...prev,
          { timestamp: getDateTime(), value: heartRateBPM }, // Use heartRateBPM instead of heartRate
        ]);

        count = 0;
      }
      count++;

      // Increment position for next call
      beatPositionRef.current = (position + 1) % samplesPerBeat;
    }, 1000 / DATA_RATE);

    // Repeat for other channels (unchanged)
    dataIntervalRef2.current = setInterval(() => {
      const timestamp = getDateTime();
      const newPoint = generateEcgPoint();

      // Update the displayed ECG data (keep only the last 200 points for display)
      setEcgData2((prev) => {
        const updated = [...prev, newPoint];
        return updated.slice(-200);
      });

      // Add to buffer for Firebase sync - store as [timestamp, value]
      dataBufferRef2.current.set(timestamp, newPoint);

      // Update memory usage
      const newMemoryUsed = memoryUsed + (1 / (DATA_RATE * 3600)) * MEMORY_PER_HOUR;
      setMemoryUsed(newMemoryUsed);
    }, 1000 / DATA_RATE);

    dataIntervalRef3.current = setInterval(() => {
      const timestamp = getDateTime();
      const newPoint = generateEcgPoint();

      // Update the displayed ECG data (keep only the last 200 points for display)
      setEcgData3((prev) => {
        const updated = [...prev, newPoint];
        return updated.slice(-200);
      });

      // Add to buffer for Firebase sync - store as [timestamp, value]
      dataBufferRef3.current.set(timestamp, newPoint);

      // Update memory usage
      const newMemoryUsed = memoryUsed + (1 / (DATA_RATE * 3600)) * MEMORY_PER_HOUR;
      setMemoryUsed(newMemoryUsed);
    }, 1000 / DATA_RATE);

    // Set up Firebase sync interval
    syncIntervalRef.current = setInterval(syncToFirebase, SYNC_INTERVAL);

    // Battery drain simulation
    batteryIntervalRef.current = setInterval(() => {
      setBatteryLevel((prev) => Math.max(0, prev - 0.1));
    }, 60000); // Drain 0.1% per minute
  };


  const getDateTime = () => {
    const year = new Date().getFullYear();
    const month = String(new Date().getMonth() + 1).padStart(2, '0');
    const day = String(new Date().getDate()).padStart(2, '0');
    const hours = String(new Date().getHours()).padStart(2, '0');
    const minutes = String(new Date().getMinutes()).padStart(2, '0');
    const seconds = String(new Date().getSeconds()).padStart(2, '0');
    const milliseconds = String(new Date().getMilliseconds()).padStart(3, '0');
    return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}.${milliseconds}`;
  }
  // Stop the holter monitor
  const stopMonitor = async () => {
    if (!isRunning) return

    setIsRunning(false)

    // Clear all intervals
    if (dataIntervalRef1.current) clearInterval(dataIntervalRef1.current)
    if (dataIntervalRef2.current) clearInterval(dataIntervalRef2.current)
    if (dataIntervalRef3.current) clearInterval(dataIntervalRef3.current)
    if (syncIntervalRef.current) clearInterval(syncIntervalRef.current)
    if (batteryIntervalRef.current) clearInterval(batteryIntervalRef.current)
    if (heartbeatIntervalRef.current) clearInterval(heartbeatIntervalRef.current)

    // Final sync to Firebase
    syncToFirebase()
    await set(ref(database, `devices/${deviceCode}/isDone`), true);
  }

  // Sync data to Firebase
  const syncToFirebase = async () => {
    if (deviceCode.length === 0) {
      toast.error("Please select a device");
      return;
    }

    if (
      dataBufferRef1.current.size === 0 &&
      dataBufferRef2.current.size === 0 &&
      dataBufferRef3.current.size === 0 &&
      heartRatesToSync.length === 0
    ) {
      return;
    }

    setIsSyncing(true);

    try {
      // Get the data to sync
      const dataToSync1 = Array.from(dataBufferRef1.current.entries());
      const dataToSync2 = Array.from(dataBufferRef2.current.entries());
      const dataToSync3 = Array.from(dataBufferRef3.current.entries());
      const bpmToSync = heartRatesToSync;

      // Clear the buffers
      dataBufferRef1.current.clear();
      dataBufferRef2.current.clear();
      dataBufferRef3.current.clear();
      setHeartRateToSync([]);

      // Send to Firebase
      const syncTime = new Date();
      await set(ref(database, `devices/${deviceCode}/data/c1/`), dataToSync1);
      await set(ref(database, `devices/${deviceCode}/data/c2/`), dataToSync2);
      await set(ref(database, `devices/${deviceCode}/data/c3/`), dataToSync3);
      await set(ref(database, `devices/${deviceCode}/beats/`), bpmToSync);

      setLastSync(syncTime);
    } catch (error) {
      console.error("Error syncing to Firebase:", error);
    } finally {
      setIsSyncing(false);
    }
  };
  // Clean up on unmount
  useEffect(() => {
    fetchDevices();
    return () => {
      if (dataIntervalRef1.current) clearInterval(dataIntervalRef1.current)
      if (dataIntervalRef2.current) clearInterval(dataIntervalRef2.current)
      if (dataIntervalRef3.current) clearInterval(dataIntervalRef3.current)
      if (syncIntervalRef.current) clearInterval(syncIntervalRef.current)
      if (batteryIntervalRef.current) clearInterval(batteryIntervalRef.current)
      if (heartbeatIntervalRef.current) clearInterval(heartbeatIntervalRef.current)
    }
  }, [])

  return (
    <div className="min-h-screen bg-slate-100 p-4 flex items-center justify-center">
      <Card className="w-full max-w-3xl bg-slate-200 border-2 border-slate-300 rounded-xl shadow-lg">
        <CardHeader className="bg-slate-700 text-white rounded-t-lg">
          <div className="flex justify-between items-center">
            <CardTitle className="text-xl font-bold">HolterSim 3000</CardTitle>
            <div className="flex items-center gap-4">
              {/* Dropdown to select device */}
              <select
                className="bg-slate-600 text-white rounded-md p-1 text-sm focus:outline-none focus:ring-2 focus:ring-slate-500"
                onChange={(e) => {
                  // Handle device selection
                  setDeviceCode(e.target.value);
                  console.log("Selected device:", e.target.value);
                }}
              >
                <option value="">Select a device</option>
                {devices.map((device, index) => (
                  <option key={index} value={device}>
                    {device}
                  </option>
                ))}
              </select>

              {/* Clock and Battery Status */}
              <div className="flex items-center gap-2">
                <Clock className="h-4 w-4" />
                <span className="text-sm">{new Date().toLocaleTimeString()}</span>
                <Battery className={`h-5 w-5 ${batteryLevel < 20 ? "text-red-400" : "text-green-400"}`} />
                <span className="text-sm">{batteryLevel.toFixed(1)}%</span>
              </div>
            </div>
          </div>
        </CardHeader>

        <CardContent className="p-4 grid gap-4">
          {/* ECG Display */}
          <div className="bg-black rounded-lg p-2 border border-slate-400">
            <div className="flex justify-between items-center mb-2">
              <div className="flex items-center gap-2">
                <div
                  className={`h-2 w-2 rounded-full ${isRunning ? "bg-green-500 animate-pulse" : "bg-red-500"}`}
                ></div>
                <span className="text-green-500 text-sm font-mono">ECG</span>
                <div
                  className={`ml-2 text-red-500 transition-transform duration-150 ${heartbeatPulse ? "scale-125" : "scale-100"}`}
                >
                  ♥
                </div>
              </div>
              <div className="text-green-500 text-sm font-mono">HR: {heartRate} BPM</div>
            </div>
            <EcgDisplay data={ecgData1} isRunning={isRunning} />
            <EcgDisplay data={ecgData2} isRunning={isRunning} />
            <EcgDisplay data={ecgData3} isRunning={isRunning} />
          </div>

          {/* Memory and Status */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="bg-slate-100 rounded-lg p-3 border border-slate-300">
              <h3 className="text-sm font-semibold mb-2 flex items-center gap-2">
                <Memory className="h-4 w-4" /> Memory Chip Status
              </h3>
              <MemoryChip memoryUsed={memoryUsed} memoryCapacity={MEMORY_CAPACITY} />
            </div>

            <div className="bg-slate-100 rounded-lg p-3 border border-slate-300">
              <h3 className="text-sm font-semibold mb-2 flex items-center gap-2">
                <Database className="h-4 w-4" /> Data Sync Status
              </h3>
              <div className="space-y-2">
                <div className="flex justify-between text-sm">
                  <span>Last sync:</span>
                  <span>{lastSync ? lastSync.toLocaleTimeString() : "Never"}</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span>Buffer size:</span>
                  <span>{dataBufferRef1.current.size + dataBufferRef2.current.size + dataBufferRef3.current.size} points</span>
                </div>
                <div className="flex items-center gap-2">
                  <Wifi className={`h-4 w-4 ${isSyncing ? "text-green-500" : "text-slate-400"}`} />
                  <span className="text-xs">{isSyncing ? "Syncing..." : "Idle"}</span>
                </div>
              </div>
            </div>
          </div>
        </CardContent>

        <CardFooter className="bg-slate-300 rounded-b-lg p-4 flex justify-between">
          <Button
            variant={isRunning ? "destructive" : "default"}
            size="lg"
            onClick={isRunning ? stopMonitor : startMonitor}
            className="flex items-center gap-2"
          >
            <Power className="h-5 w-5" />
            {isRunning ? "Stop Monitoring" : "Start Monitoring"}
          </Button>

          <Button
            variant="outline"
            onClick={syncToFirebase}
            disabled={!isRunning || (dataBufferRef1.current.size === 0 || dataBufferRef2.current.size === 0 || dataBufferRef3.current.size === 0) || isSyncing}
          >
            Force Sync
          </Button>
        </CardFooter>
      </Card>
    </div>
  )
}

