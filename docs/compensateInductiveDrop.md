# `compensateInductiveDrop`

**Purpose:**  
Compensates the inductive voltage drop in Vce caused by bonding wire inductance.

---

## **Syntax**
```matlab
[Vce_corrected, VL, didt] = compensateInductiveDrop(time, Vce_clamped, Ic, process, Ls)
```

---

## **Inputs**
- `time` (vector): Time samples [s]
- `Vce_clamped` (vector): Measured clamped Vce [V]
- `Ic` (vector): Collector current [A]
- `process` (logical vector): Processing mask
- `Ls` (scalar): Bonding wire inductance [H]

---

## **Outputs**
- `Vce_corrected` (vector): Vce after inductive drop compensation [V]
- `VL` (vector): Inductive voltage drop [V]
- `didt` (vector): Current derivative [A/s]

---

## **Example**
```matlab
[Vce_corrected, VL, didt] = compensateInductiveDrop(time, Vce_clamped, Ic, process, 20e-9);
```

---

## **Notes**
- Uses forward, backward, and centered differences for di/dt calculation.
- Handles contiguous blocks in `process`.
