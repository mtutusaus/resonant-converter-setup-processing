# Junction Temperature Estimation from Switching Waveforms

![MATLAB](https://img.shields.io/badge/MATLAB-R2024a-orange.svg)
![AI-Assisted](https://img.shields.io/badge/Development-AI--Assisted-purple)
[![License: CC BY-NC-SA 4.0](https://licensebuttons.net/l/by-nc-sa/4.0/88x31.png)](https://creativecommons.org/licenses/by-nc-sa/4.0/)

During my PhD at the [IMB-CNM (CSIC)](https://www.imb-cnm.csic.es/en) in Barcelona I was in charge (among other things) of developing postprocessing software to convert measured electrical waveforms of a device under test (operating inside the resonant converter setup) to junction temperature. This repository has all the MATLAB scripts and functions needed to do so.

---
## **Overview**
The workflow:
1. Import measured waveforms (`Vce`, `Ic`, `Vge`) from CSV files acquired with the TiePie setup.
2. Generate processing mask for switching periods.
3. Apply corrections:
   - Offset correction for `Vce`
   - Inductive drop compensation
5. Estimate junction temperature using a lookup table (LUT) and thermal impedance.
6. Compute uncertainty propagation and statistical analysis.

---
## **Requirements**
- MATLAB (works on R2024a)
- Look up table properly formatted `.mat` files for the specific device under test

---
## **Repository Structure**
```
📂 /functions
    ├── importCSV.m
    ├── generateProcessMask.m
    ├── applyOffsetCorrection.m
    ├── compensateInductiveDrop.m
    ├── estimateTj.m

📂 /scripts
    ├── main_script.m          # Single-file processing
    ├── bulk_processing.m      # Batch processing of multiple files

📂 /docs
    ├── generateProcessMask.md
    ├── applyOffsetCorrection.md
    ├── compensateInductiveDrop.md
    ├── estimateTj.md
```

---
## **How to Use**
### **Single File Processing**
Run:
```matlab
main_script
```
- Select two CSV files: one with `time, Vce, Ic` and another with `Vge`.
- Outputs:
  - Full Tj and uncertainty waveform during processing window.
  - Period-wise analysis of Tj during processing window.
  - Period-wise analysis of Tj at the point of maximum Ic.

### **Bulk Processing**
Run:
```matlab
bulk_processing
```
- Select multiple CSV files (pairs of waveform and Vge files).
- Outputs:
  - Period-wise analysis of Tj at the point of maximum Ic only.

---
## **Functions**
See detailed documentation in `/docs`:
- [importCSV](docs/importCSV.md)
- [generateProcessMask](docs/generateProcessMask.md)
- [applyOffsetCorrection](docs/applyOffsetCorrection.md)
- [compensateInductiveDrop](docs/compensateInductiveDrop.md)
- [estimateTj](docs/estimateTj.md)

---
## **Development**

- This project is developed with AI assistance (M365 Copilot) for code suggestions, debugging, and optimization.

---
## **License**
This project is licensed under the [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-nc-sa/4.0/).

You are free to:
- **Share** — copy and redistribute the material in any medium or format
- **Adapt** — remix, transform, and build upon the material

Under the following terms:
- **Attribution** — You must give appropriate credit
- **NonCommercial** — You may not use the material for commercial purposes
- **ShareAlike** — Derivatives must use the same license

See the [LICENSE](LICENSE.md) file for the full license text.

---
## Author

[Miquel Tutusaus](https://github.com/mtutusaus), 2025
