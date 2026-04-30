# 8-bit Pipelined CPU — RTL Design in Verilog

A fully functional **8-bit CPU** implemented in Verilog, featuring a **3-stage pipeline** (IF → ID → EX/WB), a custom **ISA with 10 instructions**, a **Harvard memory architecture**, and a **Python assembler** that converts assembly code to machine hex with automatic hazard NOP insertion.

---

## Architecture Overview

```
                ┌──────────────────────────────────────────────┐
                │               top_piplined.v                 │
                │                                              │
  ┌──────────┐  │  ┌────────┐  IF/ID  ┌──────────┐  ID/EX     │
  │  Clock   │──┼─▶│   PC   │────────▶│Control   │───────┐    │
  │  Reset   │  │  │        │         │  Unit    │       │    │
  └──────────┘  │  └────────┘         └──────────┘       ▼    │
                │       │                    │       ┌────────┐│
                │       ▼                   ▼        │  ALU   ││
                │  ┌────────┐         ┌──────────┐   └────────┘│
                │  │  ROM   │         │ Reg File │       │     │
                │  │(Instr) │         │ (8×8-bit)│       ▼     │
                │  └────────┘         └──────────┘  ┌────────┐│
                │                          │         │  RAM   ││
                │                          └────────▶│(256×8b)││
                │                                    └────────┘│
                └──────────────────────────────────────────────┘
```

### Pipeline Stages

| Stage | Name    | Modules involved                          |
|-------|---------|-------------------------------------------|
| 1     | **IF**  | `program_counter`, `instruction_mem`      |
| 2     | **ID**  | `control_unit`, `register_file`           |
| 3     | **EX/WB** | `alu`, `data_mem`, register write-back  |

Pipeline registers: `IF/ID` and `ID/EX`.

---

## Repository Layout

```
8bit_cpu/
├── rtl/                  # Synthesisable Verilog source
│   ├── top_piplined.v    # Top-level: wires together all pipeline stages
│   ├── control_unit.v    # Instruction decoder — generates all control signals
│   ├── alu.v             # 8-bit ALU (ADD, SUB, MUL, AND, OR, XOR, NOT, shifts)
│   ├── pc.v              # Program counter with load (jump) support
│   ├── register_file.v   # 8 × 8-bit register file (async read, sync write)
│   ├── data_mem.v        # 256 × 8-bit data RAM (async read, sync write)
│   └── instruction_mem.v # 256 × 16-bit instruction ROM ($readmemh)
│
├── sim/                  # Simulation
│   ├── top_tb.v          # Testbench
│   └── run_sim.sh        # One-shot: assemble → compile → simulate
│
├── tools/
│   └── assembler.py      # Python assembler (.asm → program.txt hex)
│
├── programs/             # Example assembly programs
│   ├── demo.asm          # ALU demo: ADD, MUL, READ/WRITE
│   └── counter_loop.asm  # Countdown loop using JNZ
│
├── docs/
│   └── ISA_reference.md  # Full instruction set reference
│
└── .gitignore
```

---

## Instruction Set (Quick Reference)

| Opcode | Mnemonic | Operation |
|:------:|----------|-----------|
| `0`    | LOADI Rd, imm  | `Rd ← imm` |
| `1`    | ADD Rd, Rs     | `Rd ← Rd + Rs` |
| `2`    | SUB Rd, Rs     | `Rd ← Rd − Rs` |
| `3`    | MOV Rd, Rs     | `Rd ← Rs` |
| `4`    | READ Rd, addr  | `Rd ← RAM[addr]` |
| `5`    | WRITE Rs, addr | `RAM[addr] ← Rs` |
| `6`    | JUMP addr      | `PC ← addr` |
| `7`    | JNZ addr       | `if (Z==0): PC ← addr` |
| `8`    | MUL Rd, Rs     | `Rd ← Rd × Rs` |
| `E`    | HALT           | Stop |

See [`docs/ISA_reference.md`](docs/ISA_reference.md) for the full encoding, flag behaviour, and pipeline hazard rules.

---

## Getting Started

### Prerequisites

| Tool | Purpose | Install |
|------|---------|---------|
| [Icarus Verilog](https://steveicarus.github.io/iverilog/) | Verilog simulation | `sudo apt install iverilog` |
| Python 3.x | Assembler | `sudo apt install python3` |
| [GTKWave](http://gtkwave.sourceforge.net/) *(optional)* | Waveform viewer | `sudo apt install gtkwave` |

### Quick-start

```bash
# 1. Clone
git clone https://github.com/YOUR_USERNAME/8bit-cpu.git
cd 8bit-cpu

# 2. Run the full flow (assemble + compile + simulate)
cd sim
chmod +x run_sim.sh
./run_sim.sh ../programs/demo.asm

# 3. View waveforms (optional)
gtkwave cpu_sim.vcd &
```

### Running a custom program

```bash
# Write your program
nano programs/my_program.asm

# Assemble it manually
python3 tools/assembler.py programs/my_program.asm rtl/program.txt

# Then compile & simulate from the sim/ folder
cd sim && ./run_sim.sh
```

---

## Assembler

The assembler lives in `tools/assembler.py` and handles:

- **Instruction encoding** — converts mnemonics to 16-bit hex words
- **Automatic NOP insertion** — detects RAW (read-after-write) data hazards and inserts the correct number of pipeline bubbles
- **Branch delay slots** — inserts 2 NOPs after every `JNZ` / `JUMP`

```bash
python3 tools/assembler.py <input.asm> [output.txt]
```

---

## Example Programs

### `programs/demo.asm` — ALU & Memory Test

```asm
LOADI R1, 10    // R1 = 10
LOADI R2, 5     // R2 = 5
ADD   R1, R2    // R1 = 15
WRITE R1, 100   // RAM[100] = 15
LOADI R1, 0     // Reset R1
READ  R1, 100   // R1 = RAM[100]  → should be 15
MUL   R1, R2    // R1 = 15 × 5  → lower 8 bits = 75
HALT
```

### `programs/counter_loop.asm` — Countdown with JNZ

```asm
LOADI R1, 3     // Counter = 3
LOADI R2, 0     // Sum = 0
ADD   R2, R1    // Sum += Counter   ← loop top
LOADI R3, 1
SUB   R1, R3    // Counter -= 1
JNZ   4         // Jump back if Counter != 0
HALT            // R2 = 3+2+1 = 6
```

---

## Design Notes

- **Harvard architecture** — instruction ROM and data RAM are separate address spaces (both 256 entries).
- **Hazard handling** — done entirely in software (the assembler); no forwarding paths in hardware.
- **Jump condition** — `JNZ` reads the `zero_flag` produced by the ALU in the EX stage. The assembler ensures the flag-setting instruction has completed before the `JNZ` is decoded, via branch delay NOPs.
- **Reset** — active-low asynchronous reset (`rst = 0`). All registers and the PC clear to zero.

---

## License

MIT — free to use for learning, coursework, and personal projects.
