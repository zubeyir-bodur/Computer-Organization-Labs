// CS224 Lab 4
// Description: MIPS Single-Cycle 
//				Datapath and Controller
// Author: 		Zübeyir Bodur
// ID : 		21702382

// Top level system including MIPS and memories
// All tested and working
module top  (input  logic 	 clk, reset,            
	     	 output logic[31:0] writedata, dataadr,
             output logic[31:0] pc, instr,
	     	 output logic       memwrite);  

   logic [31:0] readdata;    

   // instantiate processor and memories  
   mips mips (clk, reset, pc, instr, memwrite, dataadr, writedata, readdata);  
   imem imem (pc[7:2], instr);  
   dmem dmem (clk, memwrite, dataadr, writedata, readdata);

endmodule



// External data memory used by MIPS single-cycle processor
module dmem (input  logic        clk, we,
             input  logic[31:0]  a, wd,
             output logic[31:0]  rd);

   logic  [31:0] RAM[63:0];
  
   assign rd = RAM[a[31:2]];    // word-aligned  read (for lw)

   always_ff @(posedge clk)
     if (we)
       RAM[a[31:2]] <= wd;      // word-aligned write (for sw)

endmodule



// External instruction memory used by MIPS single-cycle
// processor. It models instruction memory as a stored-program 
// ROM, with address as input, and instruction as output
// Answer to question given in part 2 - e:
//	writedata is undefined as RD2 is equal to rt for the
//	given instruction. For the beginnin of the instructions
//	rt was "X" initially then they were given a value
//	in the "addi" instruction. For lw, writedata doesn't
//	has value since it has $t3 uninitialized in rt register
module imem ( input logic [5:0] addr, output logic [31:0] instr);

// imem is modeled as a lookup table, a stored-program byte-addressable ROM
	always_comb
	   case ({addr,2'b00})		   	// word-aligned fetch
//		 address		instruction
//		 -------		-----------
		 8'h00: instr = 32'h20040005; //addi $a0, $0, 5
         8'h04: instr = 32'h20100001; //addi $s0, $0, 1
		 8'h08: instr = 32'h00804024; //and  $t0, $a0, $0
		 8'h0c: instr = 32'h2005000c; //addi $a1, $0, 12
		 8'h10: instr = 32'h20060044; //addi $a2, $0, 68
		 8'h14: instr = 32'h200a0008; //addi $t2, $0, 8
		 8'h18: instr = 32'h00ca3822; //sub	 $a3, $a2, $t2
         8'h1c: instr = 32'h214a0000; //addi $t2, $t2, 0x10010000
		 8'h20: instr = 32'hbd460004; //sw+	 $a2, 4($t2)
		 8'h24: instr = 32'had470004; //sw   $a3, 4($t2)
		 8'h28: instr = 32'h00001020; //add  $v0, $0, $0
		 8'h2c: instr = 32'h00a04020; //add  $t0, $a1, $0
		 8'h30: instr = 32'h0008482a; //slt  $t1, $0, $t0
		 8'h34: instr = 32'h11300002; //beq  $t1, $s0, L1
		 8'h38: instr = 32'h08000012; //j    L2
		 8'h3c: instr = 32'hfc000000; //nop
/*L1: */ 8'h40: instr = 32'h00441020; //add  $v0, $v0, $a0
		 8'h44: instr = 32'h2108ffff; //addi $t0, $t0, -1
         8'h48: instr = 32'h0008482a; //slt  $t1, $0, $t0
		 8'h4c: instr = 32'hfc000000; //nop
		 8'h50: instr = 32'h1130fffb; //beq $t1, $s0, L1
/*L2: */ 8'h54: instr = 32'h8d4b0004; //lw  $t3, 4($t2)
		 8'h58: instr = 32'h0162602a; //slt $t4, $t3, $v0
         8'h5c: instr = 32'h004b682a; //slt $t5, $v0, $t3
		 8'h60: instr = 32'h018d5825; //or  $t3, $t4, $t5
	     default:  instr = {32{1'bx}};// unknown address
	   endcase
endmodule


// single-cycle MIPS-Lite processor, with controller and datapath
module mips (input  logic        clk, reset,
             output logic[31:0]  pc,
             input  logic[31:0]  instr,
             output logic        memwrite,
             output logic[31:0]  aluout, writedata,
             input  logic[31:0]  readdata);

  logic        memtoreg, pcsrc, zero, alusrc, regdst, regwrite, jump, swplus;
  logic [2:0]  alucontrol;

  controller c (instr[31:26], instr[5:0], zero, memtoreg, memwrite, pcsrc,
                        alusrc, regdst, regwrite, jump, swplus, alucontrol);

  datapath dp (clk, reset, memtoreg, pcsrc, alusrc, regdst, regwrite, jump, swplus, alucontrol, zero, pc, instr, aluout, writedata, readdata);

endmodule

// Controller for the original10 instruction set
// with new instructions sw+ and nop addded
module controller(input  logic[5:0] op, funct,
                  input  logic     zero,
                  output logic     memtoreg, memwrite,
                  output logic     pcsrc, alusrc,
                  output logic     regdst, regwrite,
                  output logic     jump, swplus,
                  output logic[2:0] alucontrol);

   logic [1:0] aluop;
   logic       branch;

   maindec md (op, memtoreg, memwrite, branch, alusrc, regdst, regwrite, 
		 jump, swplus, aluop);

   aludec  ad (funct, aluop, alucontrol);

   assign pcsrc = branch & zero;

endmodule

// Main decoder for the original10 instruction set
// with new instructions sw+ and nop addded
module maindec (input logic[5:0] op, 
	              output logic memtoreg, memwrite, branch,
	              output logic alusrc, regdst, regwrite, jump, swplus,
	              output logic[1:0] aluop );
  logic [9:0] controls;

   assign {regwrite, regdst, alusrc, branch, memwrite,
                memtoreg,  aluop, jump, swplus} = controls;

  always_comb
    case(op)
      6'b000000: controls <= 10'b1100001000; // R-type
      6'b100011: controls <= 10'b1010010000; // LW
      6'b101011: controls <= 10'b0010100000; // SW
      6'b000100: controls <= 10'b0001000100; // BEQ
      6'b001000: controls <= 10'b1010000000; // ADDI
      6'b000010: controls <= 10'b0000000010; // J
      6'b101111: controls <= 10'b1010100001; // SW+
      6'b111111: controls <= 10'b0000000000; // NOP
      default:   controls <= 10'bxxxxxxxxxx; // illegal op
    endcase
endmodule

// ALU Decoder
module aludec (input    logic[5:0] funct,
               input    logic[1:0] aluop,
               output   logic[2:0] alucontrol);
  always_comb
    case(aluop)
      2'b00: alucontrol  = 3'b010;  // add  (for lw/sw/addi)
      2'b01: alucontrol  = 3'b110;  // sub   (for beq)
      default: case(funct)          // R-TYPE instructions
          6'b100000: alucontrol  = 3'b010; // ADD
          6'b100010: alucontrol  = 3'b110; // SUB
          6'b100100: alucontrol  = 3'b000; // AND
          6'b100101: alucontrol  = 3'b001; // OR
          6'b101010: alucontrol  = 3'b111; // SLT
          default:   alucontrol  = 3'bxxx; // ???
        endcase
    endcase
endmodule

// Datapath for the processor
module datapath (input  logic clk, reset, memtoreg, pcsrc, alusrc, regdst,
                 input  logic regwrite, jump, swplus,
		 		 input  logic[2:0]  alucontrol, 
                 output logic zero, 
		 		 output logic[31:0] pc, 
	         	 input  logic[31:0] instr,
                 output logic[31:0] aluout, writedata, 
	         	 input  logic[31:0] readdata);

  logic [4:0]  writereg_prime, writereg;
  logic [31:0] pcnext, pcnextbr, pcplus4, pcbranch;
  logic [31:0] signimm, signimmsh, srca, srcb, result_prime, result;
 
  // next PC logic
  flopr #(32) pcreg(clk, reset, pcnext, pc);
  adder       pcadd1(pc, 32'b100, pcplus4);
  sl2         immsh(signimm, signimmsh);
  adder       pcadd2(pcplus4, signimmsh, pcbranch);
  mux2 #(32)  pcbrmux(pcplus4, pcbranch, pcsrc, pcnextbr);
  mux2 #(32)  pcmux(pcnextbr, {pcplus4[31:28], 
                    instr[25:0], 2'b00}, jump, pcnext);

// register file logic
  regfile     rf (clk, regwrite, instr[25:21], instr[20:16], writereg,
                   result, srca, writedata);
  mux2 #(5)   wrmux1 (instr[20:16], instr[15:11], regdst, writereg_prime); 
  mux2 #(5)   wrmux2 (writereg_prime, instr[25:21], swplus, writereg);
  mux2 #(32)  resmux1 (aluout, readdata, memtoreg, result_prime);
  mux2 #(32)  resmux2 (result_prime, srca + 4, swplus, result);
  signext     se (instr[15:0], signimm);

  // ALU logic
  mux2 #(32)  srcbmux (writedata, signimm, alusrc, srcb);
  alu         alu (srca, srcb, alucontrol, aluout, zero);

endmodule

// three ported register file: read two ports combinationally
// write third port on rising edge of clock. Register0 hardwired to 0.
module regfile (input    logic clk, we3, 
                input    logic[4:0]  ra1, ra2, wa3, 
                input    logic[31:0] wd3, 
                output   logic[31:0] rd1, rd2);

  logic [31:0] rf [31:0];

  always_ff @(posedge clk)
     if (we3) 
         rf [wa3] <= wd3;	

  assign rd1 = (ra1 != 0) ? rf [ra1] : 0;
  assign rd2 = (ra2 != 0) ? rf[ ra2] : 0;

endmodule


// ALU of the processor
// Tested and working
module alu(input  logic [31:0] a, b, 
           input  logic [2:0]  alucont, 
           output logic [31:0] result,
           output logic zero);
  
  logic [31:0] i0, i1, i2, i3, b_mux;
  
  mux2#(32) bmux(b, ~b, alucont[2], b_mux);
  
  assign i0 = a & b_mux;
  assign i1 = a | b_mux;
  assign i2 = a + b_mux + alucont[2];
  assign i3 = {{31{1'b0}}, i2[31]};  // zero extend the  (n-1)th bit
  
  mux4#(32) resultmux(i0, i1, i2, i3, alucont[1:0], result);
  
  assign zero = (result == 0);
endmodule


module adder (input  logic[31:0] a, b,
              output logic[31:0] y);
     
     assign y = a + b;
endmodule

module sl2 (input  logic[31:0] a,
            output logic[31:0] y);
     
     assign y = {a[29:0], 2'b00}; // shifts left by 2
endmodule

module signext (input  logic[15:0] a,
                output logic[31:0] y);
              
  assign y = {{16{a[15]}}, a};    // sign-extends 16-bit a
endmodule

// parameterized register
module flopr #(parameter WIDTH = 8)
              (input logic clk, reset, 
	       input logic[WIDTH-1:0] d, 
               output logic[WIDTH-1:0] q);

  always_ff@(posedge clk, posedge reset)
    if (reset) q <= 0; 
    else       q <= d;
endmodule


// paramaterized 2-to-1 MUX
module mux2 #(parameter WIDTH = 8)
             (input  logic[WIDTH-1:0] d0, d1,  
              input  logic s, 
              output logic[WIDTH-1:0] y);
  
   assign y = s ? d1 : d0; 
endmodule

// parameterized 4-to-1 MUX
// ALU is working, so this is also working
module mux4 #(parameter WIDTH = 8)
  			 (input logic  [WIDTH-1:0] d0, d1, d2, d3,
   			  input logic  [1:0] s,
   			  output logic [WIDTH-1:0] y);
  
  logic [WIDTH-1:0] y0, y1;
  
  mux2#(WIDTH) muxlo(d0, d1, s[0], y0);
  mux2#(WIDTH) muxhi(d2, d3, s[0], y1);
  mux2#(WIDTH) muxmid(y0, y1, s[1], y);
endmodule

