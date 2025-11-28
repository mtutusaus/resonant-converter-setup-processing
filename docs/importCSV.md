# `importCSV`

**Purpose:**  
Imports time, Vce, and Ic data from a semicolon-delimited CSV file into MATLAB as column vectors.

---

## **Syntax**
```matlab
[time, Vce, Ic] = importCSV(filename, dataLines)
```

---

## **Inputs**
- `filename` (string): Path to the CSV file.
- `dataLines` (scalar or N-by-2 array): Row interval(s) to read.  
  - Default: `[10, Inf]` (starts at row 10 and reads until the end).

---

## **Outputs**
- `time` (vector): Time data [s].
- `Vce` (vector): Collector-emitter voltage [V].
- `Ic` (vector): Collector current [A].

---

## **Example**
```matlab
[time, Vce, Ic] = importCSV('measurement.csv', [10, Inf]);
```
