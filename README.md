# Simple-RISC-Processor
design and verify a simple multi cycle RISC processor in Verilog


## Processor Specifications
1. The instruction size and the word size is 16 bits 
2. 8 16-bit general-purpose registers: from R0 to R7.  
3. R0 is hardwired to zero. Any attempt to write it will be discarded.  
4. 16-bit special purpose register for the program counter (PC) 
5. Four instruction types (R-type, I-type, J-type, and S-type).  
6. Separate data and instruction memories 
7. Byte addressable memory 
8. Little endian byte ordering 
9. You need to generate the required signals from the ALU to calculate the condition branch outcome (taken/ not taken). These signals might include zero, carry, overflow, etc. 


## Instruction Types and Formats

As mentioned above, this Instruction Set Architecture (ISA) has four instruction types, namely, R-type, I-type, J-type, and S-type. These four types have a common opcode field, which determines the specific operation of the 
instruction 

### R-Type (Register Type)

| Opcode | Rd   | Rs1  | Rs2  | Unused |
|--------|------|------|------|--------|
| 4 bits | 3 bits| 3 bits | 3 bits | 3 bits |

- 4-bit Rd: destination register
- 3-bit Rs1: first source register
- 3-bit Rs2: second source register
- 3-bit unused

### I-Type (Immediate Type)

| Opcode | Mode   | Rd  | Rs1 | Immediate |
|--------|------|------|-----------|------|
| 4 bits | 1 bits | 3 bits | 3 bits  | 5 bits|

- 3-bit Rd: destination register 
- 3-bit Rs1: first source register 
- 5-bit immediate: unsigned for logic instructions, and signed otherwise.  
- 1-bit mode: this is used with load and branch instructions, such that: 
  * For the load: 
  - 0: LBs load byte with zero extension 
  - 1: LBu load byte with sign extension 
  * For the branch: 
  - 0: compare Rd with Rs1 
  - 1: compare Rd with R0 


### J-Type (Jump Type)
This type includes the following instruction formats. The opcode is used to distinguish each instruction

#### Unconditional Jump
| Opcode | Jump Offset |
|--------|-------------|
| 4 bits | 12 bits     |

- `jmp L`: Unconditional jump to the target `L`.

#### Call Function
| Opcode | Jump Offset |
|--------|-----------------|
| 4 bits | 12 bits         |

- `call F`: Call the function `F`.
  -  The return address is pushed on r7.
- The target address is calculated by concatenating the most significant 7-bit of the current PC with the 12-bit offset after multiplying offset by 2.  

#### Return from Function
| Opcode | Unused |
|--------|--------|
| 4 bits | 12 bits |

- `ret`: Return from a function.
  - The next PC will be the value stored in r7 


### S-Type (Store)
| Opcode | Rs | Immediate  |
|--------|----|------------------|
| 4 bits| 3 bits | 8 bits        |


- `Sv  Rs, imm`:  M[rs] = imm
<br>


## Team Member:

* [Omar Masalmah](https://github.com/Omarmasalmah) <br>
* [Ahmad Bakri](https://github.com/AhmadBakri7) <br>
* [Batool Hammouda](https://github.com/BatoolHammouda)


