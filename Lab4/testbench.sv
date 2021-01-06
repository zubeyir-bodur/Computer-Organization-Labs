// CS224 Lab 4
// Description: Testbench for 
// 				MIPS Single-Cycle 
//				Datapath and Controller
// Author: 		Zübeyir Bodur
// ID : 		21702382

module testbench();
  logic clk, reset;
  logic [31:0] writedata, dataadr, pc, instr;
  logic memwrite;
  integer i;
  
  top uut(.clk(clk),
          .reset(reset),
          .writedata(writedata),
          .dataadr(dataadr),
          .pc(pc),
          .instr(instr),
          .memwrite(memwrite));
  
  initial begin
    clk <= 0;
    #1 reset <= 1;
    $monitor("clk = 0x%0h\t reset = 0x%0h\t writedata = 0x%0h\t dataadr = 0x%0h\t pc = 0x%0h\t instr = 0x%0h\t memwrite = 0x%0h", clk, reset, writedata, dataadr, pc, instr, memwrite );
    for(i = 0; i < 156; i = i + 1)begin
    	reset = 0;
    	#1 clk = ~clk;
    end
  end
endmodule