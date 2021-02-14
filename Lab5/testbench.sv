// CS224 Lab 5
// Description: Testbench for MIPS Pipelined 
//				Datapath and Controller
// Author: 		Zübeyir Bodur
// ID : 		21702382
module testbench();
  logic CLK, CLR, MemWriteM, RegWriteW, WriteDataM;
  logic [7:0] PCF, PCPlus4F;
  logic [31:0] ALUOutM, ResultW, InstrOut;
  integer i;
  
  mips uut(.CLK(CLK),
           .CLR(CLR),
           .MemWriteM(MemWriteM),
           .RegWriteW(RegWriteW),
           .WriteDataM(WriteDataM),
           .PCF(PCF),
           .ALUOutM(ALUOutM),
           .ResultW(ResultW),
           .InstrOut(InstrOut),
           .PCPlus4F(PCPlus4F),
           .FlushF(FlushF));
  
  initial begin
    CLK <= 0;
    #1 CLR <= 1;
    $monitor("CLK = 0x%0h\t CLR = 0x%0h\t MemWriteM = 0x%0h\t RegWriteW = 0x%0h\t WriteDataM = 0x%0h\t PCF = 0x%0h\t InstrOut = 0x%0h\t ResultW = 0x%0h\t ALUOutM = 0x%0h\t PCPlus4F = 0x%0h\t FlushF = 0x%0h\t", CLK, CLR, MemWriteM, RegWriteW, WriteDataM, PCF, InstrOut, ResultW, ALUOutM, PCPlus4F, FlushF);
    for(i = 0; i < 2; i = i + 1) begin // Wait for IF to read the first instruction
    	CLR = 1;
    	#1 CLK = ~CLK;
    end
    for(i = 0; i < 200; i = i + 1) begin
    	CLR = 0;
    	#1 CLK = ~CLK;
    end
  end
endmodule