
// CS224 Lab 5
// Description: MIPS Pipelined 
//				Datapath and Controller
// Author: 		Zübeyir Bodur
// ID : 		21702382

// Pipelined MIPS processor, top module
module mips (input  logic        CLK, CLR, 	// CLR resets the cur PC, used only in the beginning
			 output logic        MemWriteM,
             output logic        RegWriteW,
             output logic        WriteDataM,
             output logic[7:0]   PCF,
             output logic[31:0]  ALUOutM, ResultW,
             output logic[31:0]  InstrOut,
             output logic[7:0] PCPlus4F,
             output logic FlushF
            );
	
  	logic RegWriteD, RegWriteE, RegWriteM/*, RegWriteW*/;
  	logic MemtoRegD, MemtoRegE, MemtoRegM, MemtoRegW;
  	logic MemWriteD, MemWriteE, /*MemWriteM,*/ MemWriteW;
  	logic[2:0] ALUControlD, ALUControlE, ALUControlM, ALUControlW;
  	logic ALUSrcD, ALUSrcE, ALUSrcM, ALUSrcW;
  	logic RegDstD, RegDstE, RegDstM, RegDstW;
  	logic BranchD, BranchE, BranchM, BranchW;
  	logic PCSrcM;
  	logic ZeroE, ZeroM;
  	logic[7:0] /*PCPlus4F,*/ PCPlus4D, PCPlus4E;
  	logic[7:0] PCBranchE, PCBranchM;
  	logic[7:0] PC;
  	logic StallF, StallD;
  	logic /*FlushF,*/ FlushD, FlushE;
  	logic[1:0] ForwardAE, ForwardBE;
  	logic[31:0] InstrF, InstrD;
  	logic[31:0] RD1D, RD1E;
  	logic[31:0] RD2D, RD2E;
  	logic[4:0] RsD, RtD, RdD;
  	logic[4:0] RsE, RtE, RdE;
	logic[31:0] SignImmD, SignImmE;
  	logic[31:0] ALUOutE, /*ALUOutM,*/ ALUOutW;
  	logic[31:0] WriteDataE/*, WriteDataM*/;
  	logic[4:0] WriteRegE, WriteRegM, WriteRegW;
  	logic[31:0] ReadDataM, ReadDataW;
  	/*logic[31:0] ResultW;*/
  	
  	mux2#(8) pcmux(PCPlus4F, PCBranchM, PCSrcM, PC);
    PipeWtoF pcreg(PC, ~StallF, CLK, CLR | FlushF, PCF);
  
    IF stageIF(PCF, InstrF, PCPlus4F);

  PipeFtoD IF_ID(InstrF, PCPlus4F, ~StallD, CLK, 
                   FlushD, InstrD, PCPlus4D);

  	ID stageID(InstrD, RegWriteW, WriteRegW, ResultW,
               CLK, RegWriteD, MemtoRegD, MemWriteD,
               ALUControlD, ALUSrcD, RegDstD, BranchD,
               RD1D, RD2D, RsD, RtD, RdD, SignImmD);

    PipeDtoE ID_IE(RegWriteD, MemtoRegD, MemWriteD,
                   ALUControlD, ALUSrcD, RegDstD, 
                   BranchD, RD1D, RD2D, RsD, RtD,
                   RdD, SignImmD, PCPlus4D, CLK,
                   FlushE, RegWriteE, MemtoRegE,
                   MemWriteE, ALUControlE, ALUSrcE,
                   RegDstE, BranchE, RD1E, RD2E,
                   RsE, RtE, RdE, SignImmE, PCPlus4E);

    IE stageIE(ALUControlE, ALUSrcE, RegDstE, RD1E, RD2E,
               RtE, RdE, SignImmE, PCPlus4E, ForwardAE,
               ForwardBE, ALUOutM, ResultW, ZeroE, ALUOutE,
               WriteDataE, WriteRegE, PCBranchE);

    PipeEtoM IE_IM(ZeroE, RegWriteE, MemtoRegE, MemWriteE,
                   ALUOutE, WriteDataE, WriteRegE, PCBranchE,
                   CLK, ZeroM, RegWriteM, MemtoRegM, MemWriteM,
                   ALUOutM, WriteDataM, WriteRegM, PCBranchM);
  	
  	MEM stageMEM(BranchM, ZeroM, MemWriteM, ALUOutM,
               	 WriteDataM, CLK, PCSrcM, ReadDataM);

    PipeMtoW IM_IW(RegWriteM, MemtoRegM, ReadDataM, ALUOutM,
                   WriteRegM, CLK, RegWriteW, MemtoRegW,
                   ReadDataW, ALUOutW, WriteRegW);

    WB stageWB(MemtoRegW, ReadDataW, ALUOutW, ResultW);

  	HazardUnit HU(RegWriteM, RegWriteW,WriteRegM, WriteRegW,
                  RsE, RtE, RsD, RtD, MemtoRegE, MemWriteE, 
                  PCSrcM, ForwardAE, ForwardBE, FlushF, FlushD,
                  FlushE, StallD, StallF);
  
  	assign InstrOut = InstrF;
  	always_comb begin
      // Begining of the main debugging
      /*$display("=======================TEST BEGIN==================");
      $display("MemtoRegD = 0x%0h\t MemtoRegE = 0x%0h\t MemtoRegM = 0x%0h\t MemtoRegW = 0x%0h\t", MemtoRegE, MemtoRegM, MemtoRegW);
      $display("MemWriteD = 0x%0h\t MemWriteE = 0x%0h\t MemWriteM = 0x%0h\t MemWriteW = 0x%0h\t", MemWriteD, MemWriteE, MemWriteM, MemWriteW);
      $display("ALUControlD = 0x%0h\t ALUControlE = 0x%0h\t ALUControlM = 0x%0h\t ALUControlW = 0x%0h\t", ALUControlD, ALUControlE, ALUControlM, ALUControlW);
      $display("ALUSrcD = 0x%0h\t ALUSrcE = 0x%0h\t ALUSrcM = 0x%0h\t ALUSrcW = 0x%0h\t", ALUSrcD, ALUSrcE, ALUSrcM, ALUSrcW);
      $display("RegDstD = 0x%0h\t RegDstE = 0x%0h\t RegDstM = 0x%0h\t RegDstW = 0x%0h\t", RegDstD, RegDstE, RegDstM, RegDstW);
      $display("BranchD = 0x%0h\t BranchE = 0x%0h\t BranchM = 0x%0h\t BranchW = 0x%0h\t", BranchD, BranchE, BranchM, BranchW);
      $display("PCSrcM = 0x%0h\t ZeroE = 0x%0h\t ZeroM = 0x%0h\t", PCSrcM, ZeroE, ZeroM);
      $display("PCPlus4F = 0x%0h\t PCPlus4D = 0x%0h\t PCPlus4E = 0x%0h\t", PCPlus4F, PCPlus4D, PCPlus4E);
      $display("PCBranchE = 0x%0h\t PCBranchM = 0x%0h\t", PCBranchE, PCBranchM);
      $display("PC = 0x%0h\t", PC);
      $display("StallF = 0x%0h\t StallD = 0x%0h\t", StallF, StallD);
      $display("FlushF = 0x%0h\t FlushD = 0x%0h\t FlushE = 0x%0h\t", FlushF, FlushD, FlushE);
      $display("ForwardAE = 0x%0h\t ForwardBE = 0x%0h\t", ForwardAE, ForwardBE);
      $display("InstrF = 0x%0h\t InstrD = 0x%0h\t", InstrF, InstrD);
      $display("RD1D = 0x%0h\t RD1E = 0x%0h\t", RD1D, RD1E);
      $display("RD2D = 0x%0h\t RD2E = 0x%0h\t", RD1D, RD1E);
      $display("RsD = 0x%0h\t RtD = 0x%0h\t RdD = 0x%0h\t", RsD, RtD, RdD);
      $display("RsE = 0x%0h\t RtE = 0x%0h\t RdE = 0x%0h\t", RsE, RtE, RdE);
      $display("SignImmD = 0x%0h\t SignImmE = 0x%0h\t", SignImmD, SignImmE);
      $display("ALUOutE = 0x%0h\t ALUOutM = 0x%0h\t ALUOutW = 0x%0h\t", ALUOutE, ALUOutM, ALUOutW);
      $display("WriteDataE = 0x%0h\t WriteDataM = 0x%0h\t", WriteDataE, WriteDataM);
      $display("WriteRegE = 0x%0h\t WriteRegM = 0x%0h\t WriteRegW = 0x%0h\t", WriteDataE, WriteDataM, WriteRegW);
      $display("ReadDataM = 0x%0h\t ReadDataW = 0x%0h\t", ReadDataM, ReadDataW);
      $display("=======================TEST END==================");*/
    end
  
endmodule


module PipeWtoF(input logic[7:0] PC,
                input logic EN, CLK, CLR,
                output logic[7:0] PCF);

	always_ff @(posedge CLK)
      	if(CLR) begin
			PCF <= 0;
		end
		else if(EN) begin
			PCF <= PC;
		end
  
  always_comb begin
    //$monitor("PC = 0x%0h\t ~StallF = 0x%0h\t CLK = 0x%0h\t FlushF = 0x%0h\t PCF = 0x%0h\t", PC, EN, CLK, CLR, PCF);
  end
endmodule

module PipeFtoD(input logic[31:0] InstrF, 
                input logic[7:0] PCPlus4F,
                input logic EN, CLK, CLR,	// StallD will be connected as this EN
                output logic[31:0] InstrD, 
                output logic[7:0] PCPlus4D);

  	always_ff @(posedge CLK) begin
      	if (CLR) begin
          	InstrD <= 0;
			PCPlus4D <= 0;
      	end
    	else if (EN) begin
			InstrD <= InstrF;
			PCPlus4D <= PCPlus4F;
		end
  	end
                
endmodule

// Similarly, the pipe between Writeback (W) and Fetch (F) is given as follows.

module PipeDtoE(input logic RegWriteD,
                input logic MemtoRegD,
                input logic MemWriteD,
                input logic[2:0] ALUControlD,
                input logic ALUSrcD,
                input logic RegDstD,
                input logic BranchD,
                input logic[31:0] RD1D,
                input logic[31:0] RD2D,
                input logic[4:0] RsD,
                input logic[4:0] RtD,
                input logic[4:0] RdD,
                input logic[31:0] SignImmD,
                input logic[7:0] PCPlus4D,
                input logic CLK, CLR,
                output logic RegWriteE,
                output logic MemtoRegE,
                output logic MemWriteE,
                output logic[2:0] ALUControlE,
                output logic ALUSrcE,
                output logic RegDstE,
                output logic BranchE,
                output logic[31:0] RD1E,
                output logic[31:0] RD2E,
                output logic[4:0] RsE,
                output logic[4:0] RtE,
                output logic[4:0] RdE,
                output logic[31:0] SignImmE,
                output logic[7:0] PCPlus4E,
               );
	always_ff @(posedge CLK)
      if (CLR) begin
        RegWriteE <= 0;
		MemtoRegE <= 0;
        MemWriteE <= 0;
        ALUControlE <= 0;
        ALUSrcE <= 0;
        RegDstE <= 0;
        RegWriteE <= 0;
        BranchE <= 0;
        RD1E <= 0;
        RD2E <= 0;
        RsE <= 0;
        RtE <= 0;
        RdE <= 0;
        SignImmE <= 0;
        PCPlus4E <= 0;
      end
      else begin
        RegWriteE <= RegWriteD;
		MemtoRegE <= MemtoRegD;
        MemWriteE <= MemWriteD;
        ALUControlE <= ALUControlD;
        ALUSrcE <= ALUSrcD;
        RegDstE <= RegDstD;
        RegWriteE <= RegWriteD;
        BranchE <= BranchD;
        RD1E <= RD1D;
        RD2E <= RD2D;
        RsE <= RsD;
        RtE <= RtD;
        RdE <= RdD;
        SignImmE <= SignImmD;
        PCPlus4E <= PCPlus4D;
      end
endmodule

module PipeEtoM(input logic ZeroE,
                input logic RegWriteE,
                input logic MemtoRegE,
                input logic MemWriteE,
                input logic[31:0] ALUOutE,
                input logic[31:0] WriteDataE,
                input logic[4:0] WriteRegE,
                input logic[7:0] PCBranchE,
                input logic CLK,
                output logic ZeroM,
                output logic RegWriteM,
                output logic MemtoRegM,
                output logic MemWriteM,
                output logic[31:0] ALUOutM,
                output logic[31:0] WriteDataM,
                output logic[4:0] WriteRegM,
                output logic[7:0] PCBranchM,
				);
  	always_ff @(posedge CLK) begin
          ZeroM <= ZeroE;
          RegWriteM <= RegWriteE;
          MemtoRegM <= MemtoRegE;
          MemWriteM <= MemWriteE;
          ALUOutM <= ALUOutE;
          WriteDataM <= WriteDataE;
          WriteRegM <= WriteRegE;
          PCBranchM <= PCBranchE;
  	end
endmodule

module PipeMtoW(input logic RegWriteM,
                input logic MemtoRegM,
  				input logic[31:0] ReadDataM,
                input logic[31:0] ALUOutM,
                input logic[4:0] WriteRegM,
                input logic CLK,
                output logic RegWriteW,
                output logic MemtoRegW,
                output logic[31:0] ReadDataW,
                output logic[31:0] ALUOutW,
                output logic[4:0] WriteRegW
				);
  	always_ff @(posedge CLK) begin
    	RegWriteW <= RegWriteM;
    	MemtoRegW <= MemtoRegM;
		ReadDataW <= ReadDataM;
		ALUOutW <= ALUOutM;
		WriteRegW <= WriteRegM;
  	end
endmodule

// Define the stages between pipes seperately

// IF stage, takes PC from the WB stage
// and outputs PC + 4 and Instr bits
module IF(input  logic[7:0] PCF,
          output logic[31:0] InstrF,
          output logic[7:0] PCPlus4F);
  imem instruction_memory(PCF, InstrF);
  assign PCPlus4F = PCF + 4;
endmodule

// ID stage, takes the Instr bits and PC
// outputs SignImm, RD1-2, PC, and all control bits
module ID(input logic[31:0] InstrD,
          input logic RegWriteW,
          input logic[4:0] WriteRegW,
          input logic[31:0] ResultW,
          input logic CLK,
          output logic RegWriteD,
          output logic MemtoRegD,
          output logic MemWriteD,
          output logic[2:0] ALUControlD,
          output logic ALUSrcD,
          output logic RegDstD,
          output logic BranchD,
          output logic[31:0] RD1,
          output logic[31:0] RD2,
          output logic[4:0] RsD,
          output logic[4:0] RtD,
          output logic[4:0] RdD,
          output logic[31:0] SignImmD);
  	
	control controlUnit(InstrD[31:26], InstrD[5:0], RegWriteD, MemtoRegD, MemWriteD, ALUControlD, ALUSrcD, RegDstD, BranchD);
  
  	regfile RF(CLK, RegWriteW, InstrD[25:21], InstrD[20:16], WriteRegW, ResultW, RD1, RD2);
  	
  	assign RsD = InstrD[25:21];
  	assign RtD = InstrD[20:16];
  	assign RdD = InstrD[15:11];
  
  	signext SE(InstrD[15:0], SignImmD);
endmodule

// All CL in IE stage
module IE(input logic[2:0] ALUControlE,
          input logic ALUSrcE,
          input logic RegDstE,
          input logic[31:0] RD1,
          input logic[31:0] RD2,
          input logic[4:0] RtE,
          input logic[4:0] RdE,
          input logic[31:0] SignImmE,
          input logic[7:0] PCPlus4E,
          input logic[1:0] ForwardAE, ForwardBE,
          input logic[31:0] ALUOutM, ResultW,
          output logic ZeroE,
          output logic[31:0] ALUOutE,
          output logic[31:0] WriteDataE,
          output logic[4:0] WriteRegE,
          output logic[7:0] PCBranchE);
  	logic[31:0] SrcAE, SrcBE, SignImmE_sh;
  
	mux2#(5) rdstmux(RtE, RdE, RegDstE, WriteRegE);
  	
  	mux4#(32) srcamux(RD1, ResultW, ALUOutM, 0, ForwardAE, SrcAE);
  	mux4#(32) srcb1mux(RD2, ResultW, ALUOutM, 0, ForwardBE, WriteDataE);
  	mux2#(32) srcb2mux(WriteDataE, SignImmE, ALUSrcE, SrcBE);
  	
  	alu alu_pp(SrcAE, SrcBE, ALUControlE, ALUOutE, ZeroE);	
  
  	sl2 lshiftleft(SignImmE, SignImmE_sh);
  	assign PCBranchE = PCPlus4E + SignImmE_sh;
  
endmodule

// CL for MEM stage
module MEM(input logic BranchM,
           input logic ZeroM,
           input logic MemWriteM,
           input logic[31:0] ALUOutM,
           input logic[31:0] WriteDataM,
           input logic CLK,
           output logic PCSrcM,
           output logic[31:0] ReadDataM);
  	assign PCSrcM = BranchM & ZeroM;
  	dmem data_mem(CLK, MemWriteM, ALUOutM, WriteDataM, ReadDataM);
endmodule

// CL for WB stage
module WB(input logic MemtoRegW,
  		  input logic[31:0] ReadDataW,
          input logic[31:0] ALUOutW,
          output logic[31:0] ResultW,
         );
  mux2#(32) wbmux(ReadDataW, ALUOutW, MemtoRegW, ResultW);
endmodule

// CL for HU
module HazardUnit(	input logic RegWriteM, RegWriteW,
  					input logic [4:0] WriteRegM, WriteRegW,
                	input logic [4:0] rsE,rtE,
                	input logic [4:0] rsD,rtD,
                  	input logic MemtoRegE, MemWriteE, PCSrcM,
                	output logic [1:0] ForwardAE,ForwardBE,
                	output logic FlushF, FlushD, FlushE,
                  	output logic StallD,StallF);
  	logic load_use_stall;
  	logic load_store_stall;
    
    always_comb begin
      if (load_use_stall === 1'bx) begin
          	load_use_stall = 0;
        end
        else begin
          	load_use_stall = ( (rsD == rtE) | (rtD == rtE) ) & MemtoRegE;
        end
      	
      if (load_store_stall === 1'bx) begin
          	load_store_stall = 0;
        end
        else begin
          	load_store_stall = (rtD == rtE) & MemWriteE;
        end
      
      if (StallF === 1'bx) begin
          	StallF = 0;
        end
        else begin
          	StallF = load_use_stall | load_store_stall;
        end
      
      if (StallD === 1'bx) begin
          	StallD = 0;
        end
        else begin
          	StallD = load_use_stall | load_store_stall;
        end
      
      if (FlushF === 1'bx) begin
          	FlushF = 0;
        end
        else begin
          	FlushF = PCSrcM;
        end
      
      if (FlushD === 1'bx) begin
          	FlushD = 0;
        end
        else begin
          	FlushD = PCSrcM;
        end
      
      if (FlushE === 1'bx) begin
          	FlushE = 0;
        end
        else begin
          	FlushE = load_use_stall | load_store_stall | PCSrcM;
        end
      	
      	if ((rsE != 0) & (rsE == WriteRegM) & RegWriteM) begin
			ForwardAE = 2'b10;
      	end
        else if ((rsE != 0) & (rsE == WriteRegW) & RegWriteW) begin
			ForwardAE = 2'b01;
        end
		else begin
			ForwardAE = 2'b00;
        end
          
      	if ((rtE != 0) & (rtE == WriteRegM) & RegWriteM) begin
			ForwardBE = 2'b10;
      	end
      	else if ((rtE != 0) & (rtE == WriteRegW) & RegWriteW) begin
			ForwardBE = 2'b01;
      	end
		else begin
			ForwardBE = 2'b00;
        end
      	// Beginning of testing of data hazard
      	/*$display("RegWriteM = 0x%0h\t RegWriteW = 0x%0h\t WriteRegM = 0x%0h\t WriteRegW = 0x%0h\t rsE = 0x%0h\t rtE = 0x%0h\t rsD = 0x%0h rtD = 0x%0h MemtoRegE = 0x%0h MemWriteE = 0x%0h PCSrcM = 0x%0h ForwardAE = 0x%0h ForwardBE = 0x%0h FlushF = 0x%0h FlushD = 0x%0h FlushE = 0x%0h StallD = 0x%0h StallF = 0x%0h", RegWriteM, RegWriteW, WriteRegM, WriteRegW, rsE, rtE, rsD, rtD, MemtoRegE, MemWriteE, PCSrcM, ForwardAE, ForwardBE, FlushF, FlushD, FlushE, StallD, StallF);*/
      
    end
endmodule

// imem is modeled as a lookup table
// a stored-program byte-addressable ROM
module imem ( input logic [7:0] addr, output logic [31:0] instr);

	always_comb
	   case (addr)		   	// word-aligned fetch
//        address		 instruction
//        -------		 -----------
		  8'h00: instr = 32'h21290001;
          8'h04: instr = 32'h214a0002;
          8'h08: instr = 32'h216b0003;
          8'h0c: instr = 32'h218c0004;
          8'h10: instr = 32'h21ad0005;
          8'h14: instr = 32'h21ce0007;
          8'h18: instr = 32'h22310006;
          8'h1c: instr = 32'h22520013;
          8'h20: instr = 32'h22b50008;
          8'h24: instr = 32'h012a9820;
          8'h28: instr = 32'hac120028;
          8'h2c: instr = 32'h0235a022;
          8'h30: instr = 32'h01aea824;
          8'h34: instr = 32'h8c160028;
          8'h38: instr = 32'h016cb825;
          8'h3c: instr = 32'h02538020;
          8'h40: instr = 32'h02114024;
          8'h44: instr = 32'h02904825;
          8'h48: instr = 32'h02155022;
          8'h4c: instr = 32'h8c100028;
          8'h50: instr = 32'h02114024;
          8'h54: instr = 32'h02904825;
          8'h58: instr = 32'h02155022;
          8'h5c: instr = 32'h8c120032;
          8'h60: instr = 32'hac12003c;
          8'h64: instr = 32'hac120046;
          8'h68: instr = 32'hac120050;
          8'h6c: instr = 32'h112affff;
          8'h70: instr = 32'h02114024;
          8'h74: instr = 32'h02904825;
          8'h78: instr = 32'h02155022;
          8'h7c: instr = 32'h8c100028;
          8'h80: instr = 32'h0253582a;
          default:  instr = {32{1'b0}};	// unknown address
	   endcase
endmodule

module control(input  logic[5:0] Op, Funct,
                  output logic RegWriteD, MemtoRegD,
                  output logic MemWriteD, 
                  output logic[2:0] ALUControlD,
                  output logic ALUSrcD,
                  output logic RegDstD, BranchD);

  logic [1:0] ALUOp;
   	maindec md (Op, MemtoRegD, MemWriteD, BranchD, ALUSrcD, RegDstD, RegWriteD, ALUOp);
   	aludec  ad (Funct, ALUOp, ALUControlD);
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

module maindec (input logic[5:0] op, 
	              output logic memtoreg, memwrite, branch,
	              output logic alusrc, regdst, regwrite,
	              output logic[1:0] aluop );
   logic [8:0] controls;

   assign {regwrite, regdst, alusrc, branch, memwrite,
                memtoreg,  aluop} = controls;

  always_comb
    case(op)
      6'b000000: controls <= 9'b110000100; // R-type
      6'b100011: controls <= 9'b101001000; // LW
      6'b101011: controls <= 9'b001010000; // SW
      6'b000100: controls <= 9'b000100010; // BEQ
      6'b001000: controls <= 9'b101000000; // ADDI
      default:   controls <= 9'bxxxxxxxxx; // illegal op
    endcase
endmodule

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

module regfile (input    logic clk, we3, 
                input    logic[4:0]  ra1, ra2, wa3, 
                input    logic[31:0] wd3, 
                output   logic[31:0] rd1, rd2);

  logic [31:0] rf [31:0];

  // three ported register file: read two ports combinationally
  // write third port on rising edge of clock. Register0 hardwired to 0.

  always_ff @(negedge clk)
     if (we3) 
         rf [wa3] <= wd3;	

  assign rd1 = (ra1 != 0) ? rf [ra1] : 0;
  assign rd2 = (ra2 != 0) ? rf[ ra2] : 0;

endmodule

module alu(input  logic [31:0] a, b, 
           input  logic [2:0]  alucont, 
           output logic [31:0] result,
           output logic zero);
    
    always_comb
        case(alucont)
            3'b010: result = a + b;
            3'b110: result = a - b;
            3'b000: result = a & b;
            3'b001: result = a | b;
            3'b111: result = (a < b) ? 1 : 0;
            default: result = {32{1'bx}};
        endcase
    
    assign zero = (result == 0) ? 1'b1 : 1'b0;
    
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
module mux4 #(parameter WIDTH = 8)
  			 (input logic  [WIDTH-1:0] d0, d1, d2, d3,
   			  input logic  [1:0] s,
   			  output logic [WIDTH-1:0] y);
  
  logic [WIDTH-1:0] y0, y1;
  
  mux2#(WIDTH) muxlo(d0, d1, s[0], y0);
  mux2#(WIDTH) muxhi(d2, d3, s[0], y1);
  mux2#(WIDTH) muxmid(y0, y1, s[1], y);
endmodule