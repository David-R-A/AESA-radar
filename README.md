# Hardware Architecture Design for Parallel AESA Radar Signal Processing

This repository contains the source code and project files developed as part of the Master's thesis *"Design of a Hardware Architecture for Parallel AESA Radar Signal Processing"* by David Ramón Alamán (2025), submitted in the MSc Embedded Systems program at [Kungliga Tekniska Högskolan (KTH)](https://www.kth.se).  
The full thesis report is available at: [URL]

---

## About the Project

This thesis focuses on developing a set of translation rules for converting functional models, described in ForSyDe-Shallow, into synthesisable VHDL implementations. The proposed rules are applied and validated through a case study based on an Active Electronically Scanned Array (AESA) radar signal processing pipeline ([ForSyDe AESA radar](https://github.com/forsyde/aesa-radar)). Two stages of this pipeline -- Digital Beamforming (DBF) and Pulse Compression (PC) -- were manually translated into VHDL using the defined transformation rules.

The system was implemented on an Intel Cyclone V SoC, integrating the FPGA fabric and the Hard Processor System (HPS). The system architecture includes memory-mapped input and output stages via AXI interfaces, FIFO-based buffering between the processing stages, and clock-domain separation to meet the timing constraints.

To ensure that numerical accuracy was maintained after converting the model from floating-point to fixed-point representation, a MATLAB evaluation model was developed ad hoc to validate the hardware output.

The results confirm the feasibility of applying rigorous translation rules to develop hardware implementations from functional models. The thesis also supports the possibility of developing an automated tool capable of applying these rules systematically. However, the work also highlights that models can be developed without considering hardware constraints, reinforcing the need to integrate hardware-awareness into the translation process.

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
