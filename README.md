# 🧠 5-Stage Pipelined RISC-V Core

## 📝 1. Overview
This project is a complete implementation of a **32-bit RISC-V processor** written in **Verilog**.  
It features a **classic 5-stage pipeline architecture**:

> **Fetch → Decode → Execute → Memory → Write-Back**

designed to execute a subset of the RISC-V instruction set.  
The core can run C code compiled using a standard **RISC-V GCC toolchain**.

The design emphasizes:
- **Correctness and clarity**
- **Full hazard detection**
- **Data forwarding** for maximum pipeline efficiency and correct data dependency handling.

---

## ⚙️ 2. Core Features

### 🧩 ISA Support: **RV32IMC**
- **I:** Base Integer Instruction Set  
- **M:** Hardware Multiplier and Divider Extension  
- **C:** Compressed Instruction Set Extension (reduces code size by ~25–30%)

---

### 🏗️ 5-Stage Classic Pipeline
| Stage | Description |
|:------|:-------------|
| **IF** | Instruction Fetch |
| **ID** | Instruction Decode & Register Fetch |
| **EX** | Execute / Address Calculation |
| **MEM** | Memory Access |
| **WB** | Write-Back |

---

### ⚡ Advanced Hazard Handling
- **Full Data Forwarding:**  
  Resolves **Read-After-Write (RAW)** hazards by forwarding results from the **EX** and **MEM** stages directly to the ALU, minimizing stalls.

- **Load-Use Hazard Detection:**  
  A dedicated hazard detection unit stalls the pipeline for one cycle when an instruction depends on the result of a preceding `lw`.

---

### 🧭 Optimized Control Hazard Handling
- **Branch decisions** are resolved **early in the Decode (ID)** stage instead of Execute.
- This reduces the branch penalty to **a single-cycle flush**, improving performance.

---

### 🧮 Compressed Instruction Support
A **decompressor module** is included to fully support the `'C'` extension, reducing code size by **25–30%**.

---

## 🧱 3. Architecture
The processor follows a standard **5-stage pipeline** design.  
Key components include:
- Control Unit  
- Register File  
- ALU  
- Pipeline Registers  
- Hazard Management Units  

---

## 🧰 4. Toolchain & Simulation

### **Prerequisites**
- **RISC-V GCC Toolchain:**  
  `riscv64-unknown-elf-gcc`, `objdump`
- **Verilog Simulator:**  
  `iverilog` (Icarus Verilog), `vvp`
- **Build Tool:**  
  `make`

---

## 🚀 5. How to Use

The **Makefile** automates the entire build and simulation process.

### **Step 1: Write a C Program**
Write your desired C code in `tst.c`.  
The program should return its final result from `main()`, which will appear in register **a0 (x10)** after execution.

```c
// Example: tst.c
int main() {
    int a = 1;
    int b = 0;
    
    for (a = 1; a <= 4; a++) {
        b = b + a;
    }
    
    return b; // Final result will be 10
}
