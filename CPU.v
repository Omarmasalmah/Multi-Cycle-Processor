/*         ****************************************************************************
          *                 Title: Multi-Cycle-Processor                              *
          *                                                                           *
          *	                 ---------> Authors <-------- 			                  *
          *		           Omar Masalmah	           1200060   	                  *
          *		           Ahmad Bakri 	               1201509	                      *
          *                Batool Hammouda             1202874                        *
          *****************************************************************************										 */


module cpu(
  input clk,
  input [15:0] InstructionMemory [0:255],
  output reg [15:0] result,
  output reg [15:0] currentInstruction,
  output reg [15:0] operand1,
  output reg [15:0] operand2,
  output reg [15:0] data_out,
  output reg [15:0] data_in
);

reg [15:0] DataMemory [0:255]; // 16-bit data memory with 256 locations
reg [15:0] registers [0:7]; // Array of 8 16-bit registers
reg [15:0] pc = 16'b0; // Program counter

// Instruction Fields
reg [3:0] opcode;
reg [2:0] rs1, rs2, rd;
reg [4:0] immediate;
reg mode;
reg [11:0] jumpOffset;
reg [8:0] svImmediate;
reg [1:0] Type;
reg stop;
reg MemRead;
reg MemWrite;
reg RegWrite;
reg ExtOP;
reg Z, C, N;
reg EnableFetch = 1'b1;
reg EnableDecode = 1'b0;
reg EnableALU = 1'b0;
reg EnableMemoryAccess = 1'b0;
reg EnableWriteBack = 1'b0;

// Initialize data memory and registers
initial begin
  integer i;
  for (i = 0; i < 256; i = i + 1) begin
    DataMemory[i] = 0;
  end
  for (i = 0; i < 8; i = i + 1) begin
    registers[i] = i;
  end
end

// -------------------- Instruction Fetch Stage  ------------------------------

always @ (posedge clk) begin
  if (EnableFetch) begin
    currentInstruction = InstructionMemory[pc];
    #1;
    EnableFetch = 1'b0;
    EnableDecode = 1'b1;
  end
end

// ---------------------- Instruction Decode Stage -----------------------------

always @ (posedge clk) begin
  if (EnableDecode) begin
    opcode = currentInstruction[15:12];
    //Type = currentInstruction[1:0];
	//mode = currentInstruction[11];

   case ( currentInstruction[15:12])
            4'b0000, 4'b0001, 4'b0010: begin // R-Type Instructions: AND, ADD, SUB
                Type = 2'b00;
         
			end				
			
            4'b0011, 4'b0100, 4'b0101, 4'b0110, 4'b0111, 
            4'b1000, 4'b1001, 4'b1010, 4'b1011: begin // I-Type Instructions
                Type = 2'b01; 
				//mode <= instruction[11];
               
        
            end									
			
            4'b1100: begin // J-Type: jmp,
                Type = 2'b10;
               
			end	
			
			 4'b1101: begin // J-Type:  call
                Type = 2'b10;
                
			end
			
			4'b1110: begin // J-Type: ret
                Type = 2'b10; // J-Type
               
            end
			
            4'b1111: begin // S-Type 
                Type = 2'b11;
                
			end			   
			
            default: begin // Default case 
                Type = 2'b00;
                
            end
        endcase

  //-------------------- Generate control signals ---------------------------------
  
	if (opcode == 4'b0000 && Type== 2'b00) begin // AND
		rs1 = currentInstruction[8:6];
        rs2 = currentInstruction[5:3];
        rd = currentInstruction[11:9];
        operand1 = registers[rs1];
        operand2 = registers[rs2];
	  MemRead = 1'b0;
	  MemWrite = 1'b0;
	  RegWrite = 1'b1;
	end
	
  else if (opcode == 4'b0001 &&  Type== 2'b00) begin // ADD
	    rs1 = currentInstruction[8:6];
        rs2 = currentInstruction[5:3];
        rd = currentInstruction[11:9];
        operand1 = registers[rs1];
        operand2 = registers[rs2];
	  MemRead = 1'b0;
	  MemWrite = 1'b0;
	  RegWrite = 1'b1;
  end
  
  else if (opcode == 4'b0010 && Type== 2'b00) begin // SUB
	    rs1 = currentInstruction[8:6];
        rs2 = currentInstruction[5:3];
        rd = currentInstruction[11:9];
        operand1 = registers[rs1];
        operand2 = registers[rs2];
	  MemRead = 1'b0;
	  MemWrite = 1'b0;
	  RegWrite = 1'b1;
  end
  
  else if (opcode == 4'b0011 && Type== 2'b01) begin // ADDI
	   rs1 = currentInstruction[7:5];
        rd = currentInstruction[10:8];
		mode = currentInstruction[11];
        operand1 = registers[rs1];
        operand2 = currentInstruction[4:0];
	  MemRead = 1'b0;
	  MemWrite = 1'b0;
	  RegWrite = 1'b1;
	end
  else if (opcode == 4'b0100 && Type== 2'b01) begin // ANDI
	   rs1 = currentInstruction[7:5];
        rd = currentInstruction[10:8];
		mode = currentInstruction[11];
        operand1 = registers[rs1];
        operand2 = currentInstruction[4:0];
	  MemRead = 1'b0;
	  MemWrite = 1'b0;
	  RegWrite = 1'b1;
  end
  
  else if (opcode == 4'b0101 && Type== 2'b01) begin // LW
	   rs1 = currentInstruction[7:5];
        rd = currentInstruction[10:8];
		mode = currentInstruction[11];
        operand1 = registers[rs1];
        operand2 = currentInstruction[4:0];
	  MemRead = 1'b1;
	  MemWrite = 1'b0;
	  RegWrite = 1'b1;
  end
  
  else if (opcode == 4'b0110 && Type== 2'b01) begin // LBu / LBs
	    rs1 = currentInstruction[7:5];
        rd = currentInstruction[10:8];
		mode = currentInstruction[11];
        operand1 = registers[rs1];
        operand2 = currentInstruction[4:0];
	  MemRead = 1'b1;
	  MemWrite = 1'b0;
	  RegWrite = 1'b1;
	end
	
  else if (opcode == 4'b0111 && Type== 2'b01) begin // SW
	  	rs1 = currentInstruction[7:5];
        rd = currentInstruction[10:8];
		mode = currentInstruction[11];
        operand1 = registers[rs1];
        operand2 = currentInstruction[4:0];
	  MemRead = 1'b0;
	  MemWrite = 1'b1;
	  RegWrite = 1'b0;
	  data_in = registers[rd];
  end
  
  else if (opcode == 4'b1000 && Type== 2'b01 && mode ==0) begin // BGT
	  	rs1 = currentInstruction[7:5];
        rd = currentInstruction[10:8];
		mode = currentInstruction[11];
        immediate = currentInstruction[4:0];
        operand1 = registers[rd];
        operand2 = registers[rs1];
	  MemRead = 1'b0;
	  MemWrite = 1'b0;
	  RegWrite = 1'b0;
	end
  else if (opcode == 4'b1000 && Type== 2'b01 && mode ==1) begin // BGTZ
	  	rs1 = currentInstruction[7:5];
        rd = currentInstruction[10:8];
		mode = currentInstruction[11];
        immediate = currentInstruction[4:0];
        operand1 = registers[rd];
        operand2 = registers[0];
	  MemRead = 1'b0;
	  MemWrite = 1'b0;
	  RegWrite = 1'b0;
  end
  
  else if (opcode == 4'b1001 && Type== 2'b01  && mode ==0) begin // BLT
	   	rs1 = currentInstruction[7:5];
        rd = currentInstruction[10:8];
		mode = currentInstruction[11];
        immediate = currentInstruction[4:0];
        operand1 = registers[rd];
        operand2 = registers[rs1];
	  MemRead = 1'b0;
	  MemWrite = 1'b0;
	  RegWrite = 1'b0;
	end
	
  else if (opcode == 4'b1001 && Type== 2'b01  && mode ==1) begin // BLTZ
	  rs1 = currentInstruction[7:5];
        rd = currentInstruction[10:8];
		mode = currentInstruction[11];
        immediate = currentInstruction[4:0];
        operand1 = registers[rd];
        operand2 = registers[0];
	  MemRead = 1'b0;
	  MemWrite = 1'b0;
	  RegWrite = 1'b0;
	end
	
  else if (opcode == 4'b1010 && Type== 2'b01 && mode ==0) begin // BEQ 
	  	rs1 = currentInstruction[7:5];
        rd = currentInstruction[10:8];
		mode = currentInstruction[11];
        immediate = currentInstruction[4:0];
        operand1 = registers[rd];
        operand2 = registers[rs1];
	  MemRead = 1'b0;
	  MemWrite = 1'b0;
	  RegWrite = 1'b0;
  end 
  
   else if (opcode == 4'b1010 && Type== 2'b01 && mode ==1) begin // BEQZ
	  	rs1 = currentInstruction[7:5];
        rd = currentInstruction[10:8];
		mode = currentInstruction[11];
        immediate = currentInstruction[4:0];
        operand1 = registers[rd];
        operand2 = registers[0];
	  MemRead = 1'b0;
	  MemWrite = 1'b0;
	  RegWrite = 1'b0;
	end
	
  else if (opcode == 4'b1011 && Type== 2'b01 && mode ==0) begin // BNE
	   	rs1 = currentInstruction[7:5];
        rd = currentInstruction[10:8];
		mode = currentInstruction[11];
        immediate = currentInstruction[4:0];
        operand1 = registers[rd];
        operand2 = registers[rs1];
	  MemRead = 1'b0;
	  MemWrite = 1'b0;
	  RegWrite = 1'b0;
  end	
  
  else if (opcode == 4'b1011 && Type== 2'b01 && mode ==1) begin // BNEZ
	   	rs1 = currentInstruction[7:5];
        rd = currentInstruction[10:8];
		mode = currentInstruction[11];
        immediate = currentInstruction[4:0];
        operand1 = registers[rd];
        operand2 = registers[0];
	  MemRead = 1'b0;
	  MemWrite = 1'b0;
	  RegWrite = 1'b0;
	end
	
  else if (opcode == 4'b1100 && Type== 2'b10) begin // JMP
	  jumpOffset = currentInstruction[11:0];
	  MemRead = 1'b0;
	  MemWrite = 1'b0;
	  RegWrite = 1'b0;
	  pc = {pc[15:12], jumpOffset};
  end	
  
  else if (opcode == 4'b1101 && Type== 2'b10) begin // CALL
	  jumpOffset = currentInstruction[11:0];
	  MemRead = 1'b0;
	  MemWrite = 1'b0;
	  RegWrite = 1'b0;
	  pc = {pc[15:12], jumpOffset};
	  registers[7] = pc + 1; // Save return address in r7
  end
  
	else if (opcode == 4'b1110 && Type== 2'b10) begin // RET
	  MemRead = 1'b0;
	  MemWrite = 1'b0;
	  RegWrite = 1'b0;
	  pc = registers[7]; // Return to address in r7
	end
  else if (opcode == 4'b1111 && Type== 2'b11) begin // Sv
	  	rs1 = currentInstruction[11:9];
        svImmediate = currentInstruction[8:0];
        operand1 = registers[rs1];
        operand2 = svImmediate;
	  MemRead = 1'b0;
	  MemWrite = 1'b1;
	  RegWrite = 1'b0;
	  data_in = operand2; // Store immediate value
	end

	 
    if (opcode != 4'b1100 && opcode != 4'b1110) begin 
		#1
		EnableFetch = 1'b0;	   
		EnableDecode = 1'b0;
        EnableALU = 1'b1;
		EnableMemoryAccess = 1'b0;
		EnableWriteBack = 1'b0;
    end
  end
end	 


//---------------------------------- ALU Stage --------------------------------------------
																
always @ (posedge clk) begin
  if (EnableALU) begin
	   if (opcode == 4'b0000 && Type== 2'b00) begin // AND
	  result = operand1 & operand2;
	end 
	
	else if (opcode == 4'b0001 && Type== 2'b00) begin // ADD
	  result = operand1 + operand2;
	  C = (result < operand1);
	end 
	
	else if (opcode == 4'b0010 && Type== 2'b00) begin // SUB
	  result = operand1 - operand2;
	  C = operand1 < operand2;
	end 
	
	else if (opcode == 4'b0011 && Type== 2'b01) begin // ADDI
	  result = operand1 + operand2;	
	  C = (result < operand1) || (result < operand2);
	end 
	
	else if (opcode == 4'b0100 && Type== 2'b01) begin // ANDI
	  result = operand1 & operand2;
	end 
	
	else if (opcode == 4'b0101 && Type== 2'b01) begin // LW
	  result = operand1 + operand2;
	   C = (result < operand1) || (result < operand2);
	end
	
	else if (opcode == 4'b0110 && Type== 2'b01) begin // LBu / LBs
	  result = operand1 + operand2;
	   C = (result < operand1) || (result < operand2);
	end 
	
	else if (opcode == 4'b0111 && Type== 2'b01) begin // SW
	  result = operand1 + operand2;
	   C = (result < operand1) || (result < operand2);
	end 
	
	else if (opcode == 4'b1000 && Type== 2'b01 && mode ==0) begin // BGT 
	  if (operand1 > operand2) begin
	    pc = pc + immediate;
		end
	  else begin 
	    pc = pc + 2;
	  end 
	  
	 	#1
		EnableFetch = 1'b1;
		EnableDecode = 1'b0;
		EnableALU = 1'b0;
		EnableMemoryAccess = 1'b0;
		EnableWriteBack = 1'b0;
	  
	end 
	
	else if (opcode == 4'b1000 && Type== 2'b01 && mode ==1) begin // BGTZ
	  if (operand1 > operand2)begin 
	    pc = pc + immediate;
		end
	  else begin
	    pc = pc + 2;
	  end 
	  
	  #1
	  	EnableFetch = 1'b1;
		EnableDecode = 1'b0;
		EnableALU = 1'b0;
		EnableMemoryAccess = 1'b0;
		EnableWriteBack = 1'b0;
	  
	  
	end 
	
	else if (opcode == 4'b1001 && Type== 2'b01 && mode ==0) begin // BLT 
	  if (operand1 < operand2)begin 
	    pc = pc + immediate;
		end
	  else begin
	    pc = pc + 2;
	  end 
	  
	  #1
	  	EnableFetch = 1'b1;
		EnableDecode = 1'b0;
		EnableALU = 1'b0;
		EnableMemoryAccess = 1'b0;
		EnableWriteBack = 1'b0;
	  
	  
	end 
	
	else if (opcode == 4'b1001 && Type== 2'b01 && mode ==1) begin //BLTZ
	  if (operand1 < operand2)begin 
	    pc = pc + immediate;
		end
	  else begin
	    pc = pc + 2;
	  end 
	  	 #1
	  	EnableFetch = 1'b1;
		EnableDecode = 1'b0;
		EnableALU = 1'b0;
		EnableMemoryAccess = 1'b0;
		EnableWriteBack = 1'b0;
	  
	  
	end  
	
	else if (opcode == 4'b1010 && Type== 2'b01 && mode ==0) begin // BEQ 
	  if (operand1 == operand2)begin 
	    pc = pc + immediate;
		end
	  else begin
	    pc = pc + 2;
	  end 
	  	#1
	  	EnableFetch = 1'b1;
		EnableDecode = 1'b0;
		EnableALU = 1'b0;
		EnableMemoryAccess = 1'b0;
		EnableWriteBack = 1'b0;
	  
	  
	end 
	
	else if (opcode == 4'b1010 && Type== 2'b01 && mode ==1) begin // BEQZ
	  if (operand1 == operand2)begin 
	    pc = pc + immediate;
		end
	  else begin
	    pc = pc + 2;
	  end 
	  	#1
	  	EnableFetch = 1'b1;
		EnableDecode = 1'b0;
		EnableALU = 1'b0;
		EnableMemoryAccess = 1'b0;
		EnableWriteBack = 1'b0;
	  
	  
	end 
	
	else if (opcode == 4'b1011 && Type== 2'b01 && mode ==0) begin // BNE 
	  if (operand1 != operand2)begin 
	    pc = pc + immediate;
		end
	  else begin
	    pc = pc + 2;
	  end 
	  	#1
	  	EnableFetch = 1'b1;
		EnableDecode = 1'b0;
		EnableALU = 1'b0;
		EnableMemoryAccess = 1'b0;
		EnableWriteBack = 1'b0;
	  
	  
	end 
	
	else if (opcode == 4'b1011 && Type== 2'b01 && mode ==1) begin // BNEZ
	 if (operand1 != operand2)begin 
	    pc = pc + immediate;
		end
	  else begin
	    pc = pc + 2;
	  end 
	  	#1
	  	EnableFetch = 1'b1;
		EnableDecode = 1'b0;
		EnableALU = 1'b0;
		EnableMemoryAccess = 1'b0;
		EnableWriteBack = 1'b0;
	  
	  
	end 	
	
	if (opcode == 4'b1111 && Type== 2'b11) begin // SV
	  result = operand1;
	end 
	

    if (!(opcode >= 4'b1000 &&  opcode <= 4'b1011 &&Type== 2'b10))	// if not BRANCH -> go next	  
							begin
		#1
		EnableFetch = 1'b0;
		EnableDecode = 1'b0;
		EnableALU = 1'b0;
		EnableMemoryAccess = 1'b1;
		EnableWriteBack = 1'b0;
		end
  end
end

//--------------------------------- Memory Access Stage	-------------------------------------	

always @ (posedge clk) begin
  if (EnableMemoryAccess) begin
    if (MemRead) begin
      data_out = DataMemory[result];
    end else if (MemWrite) begin
      DataMemory[result] = data_in;
    end
	  else begin
	data_out = result;
	end
	
	
	
   if (opcode == 4'b0111 && Type== 2'b01 || opcode == 4'b1111 && Type== 2'b11) begin	// if SW -> fetch is next
		#1	
		pc = pc +1;
		EnableFetch = 1'b1;
		EnableDecode = 1'b0;
		EnableALU = 1'b0;
		EnableMemoryAccess = 1'b0;
		EnableWriteBack = 1'b0;
		end
		else begin	// if anything other than SW -> go to WriteBack
		#1
		EnableFetch = 1'b0;
		EnableDecode = 1'b0;
		EnableALU = 1'b0;
		EnableMemoryAccess = 1'b0;
		EnableWriteBack = 1'b1;
		end
  end
end

//---------------------------------- Write Back Stage ---------------------------------------

always @ (posedge clk) begin
  if (EnableWriteBack) begin
    if (RegWrite) begin
      registers[rd] = data_out;
    end
    
	#1	
	pc = pc+1;
	EnableFetch = 1'b1; // go back to fetch 
	EnableDecode = 1'b0;
	EnableALU = 1'b0;
	EnableMemoryAccess = 1'b0;
	EnableWriteBack = 1'b0;
	
  end
end

endmodule

// --------------------------------- TestBench------------------------------------

`timescale 1ns / 1ns

module testbench;
  reg clk;
  reg [15:0] InstructionMemory [0:255];
  reg [15:0] result;
  reg [15:0] currentInstruction;
  reg [15:0] operand1;
  reg [15:0] operand2;
  reg [15:0] data_out;											
  reg [15:0] data_in;

  cpu myCpu(.clk(clk), .InstructionMemory(InstructionMemory), .result(result), 
            .currentInstruction(currentInstruction), .operand1(operand1), 
            .operand2(operand2), .data_out(data_out), .data_in(data_in));

  initial begin
    clk = 0;
    repeat(500) begin
      #10 clk = ~clk;	  
    end
  end

  initial begin
    // Initialize Instruction Memory with test instructions
	
	 InstructionMemory[0]  = 16'b0000_001_010_011_000; // AND R1, R2, R3
     InstructionMemory[1]  = 16'b0001_101_010_001_000; // ADD R5, R1, R2
     InstructionMemory[2]  = 16'b0010011101001000; // SUB R3, R5, R1	 
		// I type
     InstructionMemory[3]  = 16'b0011_0_110_010_11010; // ADDI R6, R2, 26 
	 
        //InstructionMemory[4]  = 16'b0100000111001101; // ANDI R1, R6, 13
        //InstructionMemory[5]  = 16'b0101001010011010; // LW R2, R4, 26
        //InstructionMemory[6]  = 16'b0110001000110100; // LBu R2, R1, 20
        //InstructionMemory[7]  = 16'b0110101000110100; // LBS R2, R1, 20
		
  //  InstructionMemory[4] = 16'b1101_001011000110; // CALL 2	
  // InstructionMemory[5] = 16'b1110_001011000110; // RET 2  
  
  
	InstructionMemory[4] = 16'b1111_101_000000110; // SV R5 6	// R5 value is 4, so the address in memory will be 4	  
	InstructionMemory[5]  = 16'b0101_0_010_000_00100; // LW R2, R0,4
	InstructionMemory[6]  = 16'b0001_001_010_100_000; // ADD R1, R2, R4	   
	
	
   /* InstructionMemory[1] = 16'b001101001000001; // ADDI R2, R2, 1
    InstructionMemory[2] = 16'b101000100000001; // BEQ R1, R0, 1 (PC relative address)
    InstructionMemory[3] = 16'b011100100000000; // SW R1, 0 (R0)
    InstructionMemory[4] = 16'b010101000000000; // LW R2, 0 (R0)
    InstructionMemory[5] = 16'b0010001010000;   // SUB R1, R2
    InstructionMemory[6] = 16'b1100000000000000;  // JMP to address 0
    InstructionMemory[7] = 16'b0000001010000;   // AND R1, R2
	
	*/ 
	
  end
endmodule