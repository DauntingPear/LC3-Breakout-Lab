## LC-3 Instruction Set
Originally authored by Mark. D Hill on 03/14/2007. Updated by Adrian Brady 03/28/2024

`PC': incremented PC.` `setcc(): set condition codes N, Z, and P.` `mem[A]: memory contents at address A.`
`SEXT(immediate): sign-extend immediate to 16-bits.` `ZEXT(immediate): zero-extend immediate to 16 bits.`

```
<==== ADD ====>
 15  14  13  12  11  10   9   8   7   6   5   4   3   2   1   0
+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+ ADD DR. SR1, SR2 ; Addition
| 0   0   0   1 |    DR     |    SR1    | 0 | 0   0 |    SR2    |
+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+ DR <- SR1 + SR2 also setcc()

<==== ADD imm5 ====>
+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+ ADD DR, SR1, imm5 ; Addition with Immediate
| 0   0   0   1 |    DR     |    SR1    | 1 |       imm5        |
+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+ DR <- SR1 + SEXT(imm5) also setcc()

<==== AND ====>
+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+ AND DR, SR1, SR2 ; Bit-wise AND
| 0   1   0   1 |    DR     |    SR1    | 0 | 0   0 |    SR2    |
+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+ DR <- SR1 AND SR2 also setcc()

<==== AND imm5 ====>
+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+ AND DR, SR1, imm5 ; Bit-wise AND with Immediate
| 0   1   0   1 |    DR     |    SR1    | 1 |       imm5        |
+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+ DR <- SR1 AND SEXT(imm5) also setcc()

<==== Branch nzp ====>
+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+ BRx, label (where x = {n,z,pzp,np,nz,nzp}) ; Branch
| 0   0   0   0 | n | z | p |              PCoffset9            | GO <- ( (n AND N) OR (z AND Z) OR (p AND P) )
+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+ if (GO is true) then PC <- PC' + SEXT(PCoffset9)

<==== Jump ====>
+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+ JMP BaseR ; Jump
| 1   1   0   0 | 0 | 0 | 0 |   BaseR   | 0   0   0   0   0   0 |
+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+ PC <- BaseR

<==== Jump Subroutine ====>
+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+ JSR label ; Jump to Subroutine
| 0   1   0   0 | 1 |                  PCoffset11               | 
+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+ R7 <- PC' , PC <- PC' + SEXT(PCoffset11)

<==== Jump Subroutine in Register ====>
+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+ JSRR BaseR ; Jump to Subroutine in Register
| 0   1   0   0 | 0 | 0   0 |   BaseR   | 0   0   0   0   0   0 |
+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+ temp <- PC' , PC <- BaseR, R7 <- temp

<==== Load PC Relative ====>
+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+ LD DR, label ; Load PC-Relative
| 0   0   1   0 |    DR     |              PCoffset9            |
+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+ DR <- mem[PC' + SEXT(PCoffset9)] also setcc()

<==== Load Indirect ====>
+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+ LDI DR, label ; Load Indirect
| 1   0   1   0 |    DR     |              PCoffset9            |
+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+ DR <- mem[mem[PC' + SEXT(PCoffset9)]] also setcc()

<==== Load Base Offset ====>
+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+ LDR DR, BaseR, offset6 ; Load Base+Offset
| 0   1   1   0 |    DR     |   BaseR   |        offset6        |
+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+ DR <- mem[BaseR + SEXT(offset6)] also setcc()

<==== Load Effective Address ====>
+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+ LEA, DR, label ; Load Effective Address
| 1   1   1   0 |    DR     |              PCoffset9            |
+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+ DR <- PC' + SEXT(PCoffset9) also setcc()

<==== Bit-wise Complement ====>
+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+ NOT DR, SR ; Bit-wise Complement
| 1   0   0   1 |    DR     |     SR    | 1 | 1   1   1   1   1 |
+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+ DR <- NOT(SR) also setcc()

<==== Return from Subroutine ====>
+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+ RET ; Return from Subroutine
| 1   1   0   0 | 0   0   0 | 1   1   1 | 0   0   0   0   0   0 |
+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+ PC <- R7

<==== Return from Interrupt ====>
+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+ RET ; Return from Interrupt
| 1   0   0   0 | 0   0   0   0   0   0   0   0   0   0   0   0 |
+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+ See textbook (2nd Ed. page 537)

<==== Store PC-Relative ====>
+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+ ST SR, label ; Store PC-Relative
| 0   0   1   1 |    SR     |              PCoffset9            |
+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+ mem[PC' + SEXT(PCoffset9)] <- SR

<==== Store Indirect ====>
+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+ STI, SR, label ; Store Indirect
| 1   0   1   1 |    SR     |              PCoffset9            |
+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+ mem[mem[PC' + SEXT(PCoffset9)]] <- SR

<==== Store Base Offset ====>
+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+ STR SR, BaseR, offset6 ; Store Base+Offset
| 0   1   1   1 |    SR     |   BaseR   |        offset6        |
+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+ mem[BaseR + SEXT(offset6)] <- SR

<==== TRAP ====>
+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+ TRAP ; System Call
| 1   1   1   1 | 0   0   0   0 |           trapvect8           |
+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+ R7 <- PC', PC <- mem[ZEXT(trapvect8)]

<==== Unused Opcode ====>
+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+ ; Unused Opcode
| 1   1   0   1 |                                               |
+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+ Initiate illegal opcode exception
 15  14  13  12  11  10   9   8   7   6   5   4   3   2   1   0
```
