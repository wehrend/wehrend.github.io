import matplotlib.pyplot as plt
import numpy as np

# Define the transfer function of a first-order high-pass filter (magnitude only)
def highpass_first_order(frequency, cutoff_frequency):
    # Normierter Hochpass: |H(jw)| = (f/fc) / sqrt(1 + (f/fc)^2)
    x = frequency / cutoff_frequency
    return x / np.sqrt(1 + x**2)

# Frequency range for the Bode diagram (logarithmic scale)
frequency = np.logspace(0, 6, 1000)  # From 10^0 to 10^6 Hertz

# Cutoff frequency of the high-pass filter
cutoff_frequency = 1000  # Example value - You can set your own value here

# Calculate the gain in decibels (20 * log10(Amplitude))
gain_db = 20 * np.log10(highpass_first_order(frequency, cutoff_frequency))

# Calculate the phase response in degrees (angle)
# Für H(s) = s / (s + ωc) gilt: φ = 90° - arctan(ω/ωc)
phase_deg = 90 - np.degrees(np.arctan(frequency / cutoff_frequency))

# --- BODE DIAGRAM --------------------------------------------------------

plt.figure(figsize=(10, 6))

# Gain plot (magnitude)
plt.subplot(2, 1, 1)
plt.semilogx(frequency, gain_db, label='Gain (dB)')
plt.ylabel('Gain (dB)')
plt.title('Bode Diagram of a First-Order High-Pass Filter')
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
plt.savefig('highpass_bode_diagram.svg', format='svg')

# Optionally, display the Bode diagram
plt.show()

# --- S-PLANE POLE-ZERO PLOT ---------------------------------------------

omega_c = 2 * np.pi * cutoff_frequency

pole_real = -omega_c
pole_imag = 0.0

zero_real = 0.0
zero_imag = 0.0

plt.figure(figsize=(5, 5))

# Achsen zuerst, mit kleinem zorder
plt.axhline(0, linewidth=0.5, zorder=0)
plt.axvline(0, linewidth=0.5, zorder=0)

# Pol(e) – etwas größer und nach vorne
plt.scatter(pole_real, pole_imag,
            marker='x', s=150,
            label='Pole', zorder=3)

# Nullstelle(n) – deutlich sichtbar
plt.scatter(zero_real, zero_imag,
            marker='o', s=150,
            facecolors='none', edgecolors='red',
            linewidths=2,
            label='Zero', zorder=4)

plt.xlabel('Re{s}')
plt.ylabel('Im{s}')
plt.title('Pole-Zero Plot (s-plane) of 1st-Order High-Pass')
plt.grid(True, linestyle='--')
plt.legend()
plt.tight_layout()
plt.savefig('highpass_pz_plot.svg', format='svg')
plt.show()
