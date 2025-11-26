# `estimateTj`

**Purpose:**  
Estimates junction temperature (Tj) and uncertainty using waveform data, LUT, and thermal impedance.

---

## **Syntax**
```matlab
[results, Tj_period, Tj_max] = estimateTj(Vce_clamped, Ic, Vge, process, Zth, LUT, sigma)
```

---

## **Inputs**
- `Vce_clamped` (vector): Corrected Vce waveform [V]
- `Ic` (vector): Collector current [A]
- `Vge` (vector): Gate voltage [V]
- `process` (logical vector): Processing mask
- `Zth` (scalar): Thermal impedance [K/W]
- `LUT` (struct): Lookup table with fields:
  - `current`, `temp`, `Vce_interpolation_current`
- `sigma` (struct): Uncertainty parameters

---

## **Outputs**
- `results` (struct):
  - `.Tj`: Pointwise estimated Tj
  - `.Tj_std_estimated`: Uncertainty per point
  - `.Tj_periods`: Tj per switching period
- `Tj_period` (struct):
  - `.mean`: Mean Tj across periods
  - `.std`: Combined standard deviation
- `Tj_max` (struct):
  - `.mean`: Mean Tj at peak Ic
  - `.std`: Combined std at peak Ic

---

## **Example**
```matlab
[results, Tj_period, Tj_max] = estimateTj(Vce_clamped, Ic, Vge, process, 0.113, LUT, sigma);
```

---

## **Notes**
- Applies Vge filtering (default: 14.9–15.1 V).
- Performs interpolation or extrapolation if exact match not found.
- Propagates uncertainties.
