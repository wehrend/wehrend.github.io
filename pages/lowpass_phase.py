import matplotlib.pyplot as plt
import numpy as np

# Define the transfer function of a first-order low-pass filter (magnitude only)
def lowpass_first_order(frequency, cutoff_frequency):
    x = frequency / cutoff_frequency
    return 1 / np.sqrt(1 + x**2)

# Frequency range for the Bode diagram (logarithmic scale)
frequency = np.logspace(0, 6, 1000)  # From 10^0 to 10^6 Hertz

# Cutoff frequency of the low-pass filter
cutoff_frequency = 1000  # Example value - You can set your own value here

# --- BODE DIAGRAM --------------------------------------------------------

# Calculate the gain in decibels (20 * log10(Amplitude))
gain_db = 20 * np.log10(lowpass_first_order(frequency, cutoff_frequency))

# Calculate the phase response in degrees
phase_deg = np.degrees(np.arctan(-frequency / cutoff_frequency))

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
plt.savefig('lowpass_bode_phase.svg', format='svg')
plt.show()

# --- S-PLANE POLE-ZERO PLOT ---------------------------------------------

# Für den 1. Ordnung Tiefpass: H(s) = 1 / (1 + s/ωc)
# Pol bei s = -ωc, keine endliche Nullstelle

omega_c = 2 * np.pi * cutoff_frequency

pole_real = -omega_c
pole_imag = 0.0

plt.figure(figsize=(5, 5))

# Achsen zuerst (damit Marker oben liegen)
plt.axhline(0, linewidth=0.5, zorder=0)
plt.axvline(0, linewidth=0.5, zorder=0)

# Pol(e) – gut sichtbar machen
plt.scatter(pole_real, pole_imag,
            marker='x', s=150,
            label='Pole', zorder=3)

# Hier gäbe es theoretisch keine endliche Nullstelle.
# Wenn du eine hypothetische Nullstelle plotten willst, kannst du z.B. s = ∞ nicht darstellen,
# daher lassen wir sie weg.

plt.xlabel('Re{s}')
plt.ylabel('Im{s}')
plt.title('Pole-Zero Plot (s-plane) of 1st-Order Low-Pass')
plt.grid(True, linestyle='--')
plt.legend()
plt.tight_layout()
plt.savefig('lowpass_pz_plot.svg', format='svg')
plt.show()
