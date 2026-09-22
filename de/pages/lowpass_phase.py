 
import matplotlib.pyplot as plt
import numpy as np

# Define the transfer function of a first-order low-pass filter
def lowpass_first_order(frequency, cutoff_frequency):
    return 1 / np.sqrt(1 + (frequency / cutoff_frequency)**2)

# Frequency range for the Bode diagram (logarithmic scale)
frequency = np.logspace(0, 6, 1000)  # From 10^0 to 10^6 Hertz

# Cutoff frequency of the low-pass filter
cutoff_frequency = 1000  # Example value - You can set your own value here

# Calculate the gain in decibels (20 * log10(Amplitude))
gain_db = 20 * np.log10(lowpass_first_order(frequency, cutoff_frequency))

# Calculate the phase response in degrees (angle)
phase_deg = np.degrees(np.arctan(-frequency / cutoff_frequency))

# Create the Bode diagram with both gain and phase
plt.figure(figsize=(10, 6))

# Gain plot (magnitude)
plt.subplot(2, 1, 1)
plt.semilogx(frequency, gain_db, label='Gain (dB)')
plt.ylabel('Gain (dB)')
plt.title('Bode Diagram of a First-Order Low-Pass Filter')
plt.grid(which='both', axis='both', linestyle='--')
plt.legend()

# Phase plot
plt.subplot(2, 1, 2)
plt.semilogx(frequency, phase_deg, label='Phase (degrees)')
plt.xlabel('Frequency (Hz)')
plt.ylabel('Phase (degrees)')
plt.grid(which='both', axis='both', linestyle='--')
plt.legend()

plt.tight_layout()

# Save the Bode diagram as an SVG file
plt.savefig('lowpass_bode_phase.svg', format='svg')

# Optionally, display the Bode diagram
plt.show()
