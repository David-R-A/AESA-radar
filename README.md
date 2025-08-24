# Hardware Architecture Design for Parallel AESA Radar Signal Processing

This repository contains the source code and project files developed as part of the Master's thesis *"Design of a Hardware Architecture for Parallel AESA Radar Signal Processing"* by David Ramón Alamán (2025), submitted in the MSc Embedded Systems program at [Kungliga Tekniska Högskolan (KTH)](https://www.kth.se).  
The full thesis report is available at: [URL]

---

## About the Project

TBA

---

## Repository Structure

The repository is organized into the following main directories:

### `MATLAB/`  
Contains the MATLAB model and auxiliary scripts used during the system's modeling and simulation phase.

### `others/`  
Includes various supporting media files used in the thesis, as well as Python scripts to visualize how an AESA radar operates.

### `quartus_project/`  
Holds the complete Intel Quartus project, including:
- Platform Designer configuration files  
- Compiled SRAM Object File (.sof)  
- Design integration for FPGA synthesis

### `soc/`  
Includes pre-compiled files used in the final SoC hardware design.

### `terasic_tools/`  
Contains utilities and scripts sourced from Terasic, used throughout the development process.

### `vhdl/`  
Provides all VHDL source files:
- ForSyDe-VHDL templates  
- FPGA implementation modules  
- Literal translation of the radar model from ForSyDe-Shallow to synthesizable VHDL

---
