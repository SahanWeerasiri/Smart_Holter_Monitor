import numpy as np
import matplotlib.pyplot as plt
from datetime import datetime, timedelta

def generate_real_heartbeat_wave(bpm=72, duration=5):
    """
    Generates a realistic heartbeat waveform (P, QRS, T waves) with values between 0-4095.

    :param bpm: Beats per minute (default: 72)
    :param duration: Duration in seconds for which data should be generated.
    :return: Dictionary of {timestamp: value}.
    """
    beat_interval = 60 / bpm  # Time in seconds per beat
    samples_per_beat = 20  # More than 10 samples per beat
    time_step = beat_interval / samples_per_beat  # Interval per sample

    start_time = datetime.now()
    time_points = []
    values = []

    # Baseline (average signal level)
    baseline = 1500  

    for i in range(int(duration / time_step)):
        timestamp = start_time + timedelta(seconds=i * time_step)
        time_points.append(timestamp.strftime('%Y-%m-%d %H:%M:%S.%f')[:-3])  # Format to milliseconds

        # Normalize time within one heartbeat cycle
        t = (i % samples_per_beat) / samples_per_beat
        
        # Constructing a realistic ECG-like waveform (no negative values)
        if 0.05 < t < 0.10:  # Small P wave (pre-peak)
            heartbeat_value = baseline + 200 * (1 - ((t - 0.075) / 0.025) ** 2)
        elif 0.15 < t < 0.20:  # Sharp QRS complex (high spike)
            heartbeat_value = baseline + 2000 * np.exp(-((t - 0.175) / 0.01) ** 2)
        elif 0.25 < t < 0.35:  # T wave (post-peak bump)
            heartbeat_value = baseline + 400 * (1 - ((t - 0.30) / 0.05) ** 2)
        else:  # Baseline (steady level)
            heartbeat_value = baseline

        heartbeat_value = max(0, min(4095, int(heartbeat_value)))  # Ensure within 0-4095
        values.append(heartbeat_value)

    # Convert timestamps to numerical values for plotting
    x_ticks = np.arange(len(values))

    # Plotting
    plt.figure(figsize=(10, 4))
    plt.plot(x_ticks, values, marker='o', linestyle='-', color='r', markersize=4, label="Heartbeat")
    plt.xlabel("Time Steps")
    plt.ylabel("Signal Strength (0-4095)")
    plt.title(f"Simulated Realistic Heartbeat Waveform ({bpm} BPM)")
    plt.legend()
    plt.grid(True)
    plt.show()

    return dict(zip(time_points, values))

# Generate and visualize realistic heartbeat data
heartbeat_data = generate_real_heartbeat_wave(72, 5)
