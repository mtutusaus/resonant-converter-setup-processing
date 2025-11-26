# `applyOffsetCorrection`

**Purpose:**  
Applies polynomial offset correction to the measured Vce waveform.

---

## **Syntax**
```matlab
[Vce_corrected, Vce_offset] = applyOffsetCorrection(Vce_clamped, Ic, fit_offset)
```

---

## **Inputs**
- `Vce_clamped` (vector): Measured clamped Vce [V]
- `Ic` (vector): Collector current [A]
- `fit_offset` (vector): Polynomial coefficients for offset correction

---

## **Outputs**
- `Vce_corrected` (vector): Corrected Vce waveform [V]
- `Vce_offset` (vector): Estimated offset [V]

---

## **Example**
```matlab
[Vce_corrected, ~] = applyOffsetCorrection(Vce_clamped, Ic, [5e-4 -0.0087]);
```
