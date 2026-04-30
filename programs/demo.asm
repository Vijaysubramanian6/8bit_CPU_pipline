LOADI R1, 10    // R1 = 10

LOADI R2, 5     // R2 = 5

ADD R1, R2      // R1 = 15

WRITE R1, 100   // RAM[100] = 15

LOADI R1, 0     // Reset R1

READ R1, 100    // R1 = RAM[100] (Should be 15)

MUL R1, R2      // R1 = 10

HALT            // Stop














