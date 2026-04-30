#!/usr/bin/env python3
"""
assembler.py  —  8-bit CPU Assembler
Converts .asm source files to hex machine code (program.txt).

Usage:
    python3 assembler.py <input.asm> [output.txt]

    If output path is omitted, writes to program.txt in the current directory.
"""

import sys
import os

# ── Opcode table ─────────────────────────────────────────────────────────────
OPCODE_MAP = {
    "LOADI": "0",
    "ADD":   "1",
    "SUB":   "2",
    "MOV":   "3",
    "READ":  "4",
    "WRITE": "5",
    "JUMP":  "6",
    "JNZ":   "7",
    "MUL":   "8",
    "HALT":  "E",
}

def reg(token: str) -> int:
    """Parse 'R0'–'R7' → integer register index."""
    return int(token.upper().replace("R", ""))


def assemble(input_file: str, output_file: str = "program.txt") -> None:
    output_hex        = []
    last_write        = None   # dest reg of previous instruction
    second_last_write = None   # dest reg two instructions ago

    with open(input_file, "r") as f:
        lines = f.readlines()

    for raw_line in lines:
        line = raw_line.split("//")[0].strip()   # strip comments
        if not line:
            continue

        parts = line.replace(",", "").split()
        instr = parts[0].upper()

        if instr not in OPCODE_MAP:
            print(f"Warning: unknown instruction '{instr}' — skipped.")
            continue

        opcode        = OPCODE_MAP[instr]
        hex_val       = ""
        current_reads = []
        reg_dest      = None

        # ── Encoding ──────────────────────────────────────────────────────
        if instr == "HALT":
            output_hex.append("0000")   # flush pipeline
            output_hex.append("0000")
            hex_val = "E000"

        elif instr == "LOADI":
            reg_dest = reg(parts[1])
            imm      = int(parts[2])
            binary   = (int(opcode, 16) << 12) | (reg_dest << 9) | imm
            hex_val  = f"{binary:04X}"

        elif instr in ("ADD", "SUB", "MUL"):
            reg_dest      = reg(parts[1])
            reg_src       = reg(parts[2])
            binary        = (int(opcode, 16) << 12) | (reg_dest << 9) | (reg_src << 6)
            hex_val       = f"{binary:04X}"
            current_reads = [reg_dest, reg_src]

        elif instr == "MOV":
            reg_dest      = reg(parts[1])
            reg_src       = reg(parts[2])
            binary        = (int(opcode, 16) << 12) | (reg_dest << 9) | (reg_src << 6)
            hex_val       = f"{binary:04X}"
            current_reads = [reg_src]

        elif instr == "READ":
            reg_dest      = reg(parts[1])
            addr          = int(parts[2])
            binary        = (int(opcode, 16) << 12) | (reg_dest << 9) | addr
            hex_val       = f"{binary:04X}"
            current_reads = [reg_dest]

        elif instr == "WRITE":
            reg_src       = reg(parts[1])
            addr          = int(parts[2])
            binary        = (int(opcode, 16) << 12) | (reg_src << 9) | addr
            hex_val       = f"{binary:04X}"
            current_reads = [reg_src]

        elif instr == "JUMP":
            addr    = int(parts[1])
            hex_val = f"{opcode}{addr:03X}"

        elif instr == "JNZ":
            addr    = int(parts[1])
            binary  = (int(opcode, 16) << 12) | addr
            hex_val = f"{binary:04X}"

        # ── RAW hazard detection ──────────────────────────────────────────
        if last_write is not None and last_write in current_reads:
            output_hex.append("0000")
            output_hex.append("0000")
            last_write        = None
            second_last_write = None
        elif second_last_write is not None and second_last_write in current_reads:
            output_hex.append("0000")
            second_last_write = None

        # ── Emit instruction ──────────────────────────────────────────────
        output_hex.append(hex_val)

        # Branch delay slots (2 NOPs after every jump)
        if instr == "JNZ":
            output_hex.append("0000")
            output_hex.append("0000")

        # ── Update hazard tracking ────────────────────────────────────────
        second_last_write = last_write
        last_write        = reg_dest

    # ── Write output file ─────────────────────────────────────────────────────
    out_dir = os.path.dirname(output_file)
    if out_dir:
        os.makedirs(out_dir, exist_ok=True)

    with open(output_file, "w") as f:
        for h in output_hex:
            f.write(h + "\n")

    print(f"Assembled  {input_file}  →  {output_file}  ({len(output_hex)} words)")


# ── Entry point ───────────────────────────────────────────────────────────────
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    in_file  = sys.argv[1]
    out_file = sys.argv[2] if len(sys.argv) > 2 else "program.txt"
    assemble(in_file, out_file)
