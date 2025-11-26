# `generateProcessMask`

**Purpose:**  
Generates a logical mask indicating processing windows around the maximum current in each switching period.

---

## **Syntax**
```matlab
process = generateProcessMask(time, Ic, left_margin_us, right_margin_us)
```

---

## **Inputs**
- `time` (vector): Time samples [s]
- `Ic` (vector): Collector current waveform [A]
- `left_margin_us` (scalar): Time before peak current [μs]
- `right_margin_us` (scalar): Time after peak current [μs]

---

## **Output**
- `process` (logical vector): `true` during processing windows

---

## **Example**
```matlab
process = generateProcessMask(time, Ic, 0.25, 0.25);
```

---

## **Notes**
- Zero-crossings of Ic are used to detect switching periods.
- Margins are converted from microseconds to seconds.
