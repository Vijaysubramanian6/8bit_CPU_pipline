# ISA Reference — 8-bit Pipelined CPU

## Instruction Format

All instructions are **16 bits wide**.

```
 15  14  13  12 | 11  10   9  | 8 |  7   6   5   4   3   2   1   0
 ───────────────────────────────────────────────────────────────────
   OPCODE [3:0]  |  DEST [2:0] |  SRC  [2:0] |     IMM / ADDR [7:0]
```

For `LOADI`, bits [7:0] carry the full 8-bit immediate value.  
For `JNZ` / `JUMP`, bits [7:0] carry the 8-bit target address.

---

## Registers

| Name | Index | Purpose            |
|------|-------|--------------------|
| R0   | 000   | General purpose    |
| R1   | 001   | General purpose    |
| R2   | 010   | General purpose    |
| R3   | 011   | General purpose    |
| R4   | 100   | General purpose    |
| R5   | 101   | General purpose    |
| R6   | 110   | General purpose    |
| R7   | 111   | General purpose    |

All registers are **8 bits** wide. Reset clears all to `0x00`.

---

## Instruction Set

| Opcode (hex) | Mnemonic      | Syntax            | Operation                          | Flags updated |
|:---:|--------------|-------------------|------------------------------------|:---:|
| `0` | **LOADI**    | `LOADI Rd, imm`   | `Rd ← imm`                         | —   |
| `1` | **ADD**      | `ADD Rd, Rs`      | `Rd ← Rd + Rs`                     | Z, C |
| `2` | **SUB**      | `SUB Rd, Rs`      | `Rd ← Rd − Rs`                     | Z, C |
| `3` | **MOV**      | `MOV Rd, Rs`      | `Rd ← Rs`                          | —   |
| `4` | **READ**     | `READ Rd, addr`   | `Rd ← RAM[addr]`                   | —   |
| `5` | **WRITE**    | `WRITE Rs, addr`  | `RAM[addr] ← Rs`                   | —   |
| `6` | **JUMP**     | `JUMP addr`       | `PC ← addr` (unconditional)        | —   |
| `7` | **JNZ**      | `JNZ addr`        | `if (Z == 0): PC ← addr`          | —   |
| `8` | **MUL**      | `MUL Rd, Rs`      | `Rd ← Rd × Rs` (lower 8 bits)     | —   |
| `E` | **HALT**     | `HALT`            | Stop execution (PC enable = 0)     | —   |

### Flag Register

| Flag | Name       | Set when …                     |
|------|------------|-------------------------------|
| Z    | Zero       | ALU result == 0               |
| C    | Carry/Borrow | Arithmetic overflow / borrow |

> **Note:** Only `ADD`, `SUB` update flags. `JNZ` reads the Z flag set by the last ALU instruction.

---

## Pipeline Architecture

```
  ┌─────────┐   ┌─────────┐   ┌─────────┐
  │  IF     │ → │  ID     │ → │  EX/WB  │
  │ Fetch   │   │ Decode  │   │Execute  │
  │ PC+ROM  │   │ CU+RegF │   │ALU+Mem  │
  └─────────┘   └─────────┘   └─────────┘
       ↑               ↑
   IF/ID reg       ID/EX reg
```

This is a **3-stage in-order pipeline** (IF → ID → EX/WB).  
Hazards are handled by **software-inserted NOPs** (the assembler does this automatically).

### Pipeline Registers

| Register  | Contents forwarded                                      |
|-----------|---------------------------------------------------------|
| `IF/ID`   | 16-bit instruction word                                 |
| `ID/EX`   | ALU op, register data, write-enable, opcode, immediate |

### Hazard Handling

The assembler automatically inserts NOP bubbles (`0x0000`):

- **1-instruction-ago RAW hazard** → 2 NOPs inserted
- **2-instructions-ago RAW hazard** → 1 NOP inserted
- **After every JNZ / JUMP** → 2 NOPs inserted (branch delay slots)

---

## Assembly Syntax

```asm
// This is a comment
LOADI R1, 42      // Load immediate 42 into R1
ADD   R1, R2      // R1 = R1 + R2
SUB   R3, R1      // R3 = R3 - R1
MOV   R4, R2      // R4 = R2
READ  R5, 64      // R5 = RAM[64]
WRITE R5, 64      // RAM[64] = R5
JUMP  0           // Unconditional jump to address 0
JNZ   4           // Jump to address 4 if Z flag is 0
MUL   R1, R2      // R1 = R1 * R2  (lower 8 bits)
HALT              // Stop
```

Register names are **case-insensitive** (`R1`, `r1` both work).  
Addresses and immediates are **decimal integers**.

---

## Memory Map

| Region            | Address range | Size    |
|-------------------|---------------|---------|
| Instruction ROM   | `0x00`–`0xFF` | 256 × 16-bit words |
| Data RAM          | `0x00`–`0xFF` | 256 × 8-bit bytes  |

ROM and RAM are in **separate address spaces** (Harvard architecture).
