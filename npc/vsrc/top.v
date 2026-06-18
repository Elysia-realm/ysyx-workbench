module rom(
   input wire [3:0] PC,
   output wire [7:0] Ins
);

   reg [7:0] ROM [15:0];
   
   initial begin
      $readmemh("/home/sqh/ysyx-workbench/npc/vsrc/rom.hex", ROM);
   end
   
   assign Ins = ROM[PC];

endmodule

module gpr(
   input wire clk,
   input wire rst,
   input wire [7:0] wdata,
   input wire wen,
   input wire [1:0] waddr,
   input wire [1:0] raddr1,
   input wire [1:0] raddr2,
   output wire [7:0] rdata1,
   output wire [7:0] rdata2,
   output wire [7:0] R0
);

   reg [7:0] GPRs [3:0];
   
   integer i;
   always @(posedge clk) begin
      if(rst) begin
         for(i=1; i<5'd4; i=i+1) begin
            GPRs[i] <= 8'h00;
         end
      end
      else begin
         if(wen) begin
            GPRs[waddr] <= wdata;
         end
      end
   end
   
   assign rdata1 = GPRs[raddr1];
   assign rdata2 = GPRs[raddr2];
   assign R0 = GPRs[2'b00];

endmodule

module sCPU(
   input wire clk,
   input wire rst,
   output wire [7:0] out_rs
);
   
   reg [3:0] PC;
   wire [7:0] Ins;
   rom rom_inst(PC, Ins);
   
   wire [1:0] opcode;
   wire [1:0] rd;
   wire [1:0] rs1, rs2;
   wire [3:0] imm;
   wire [3:0] addr;
   assign opcode = Ins[7:6];
   assign rd = Ins[5:4];
   assign rs1 = Ins[3:2];
   assign rs2 = Ins[1:0];
   assign imm = Ins[3:0];
   assign addr = Ins[5:2];
   
   wire add, li, benr0, out;
   assign add = (opcode == 2'b00) ? 1'b1 : 1'b0;
   assign li = (opcode == 2'b10) ? 1'b1 : 1'b0;
   assign benr0 = (opcode == 2'b11) ? 1'b1 : 1'b0;
   assign out = (opcode == 2'b01) ? 1'b1 : 1'b0;
   
   wire [7:0] wdata;
   wire wen;
   wire [7:0] rdata1, rdata2;
   wire [7:0] R0;
   gpr gpr_inst(
      clk, rst,
      wdata, wen, rd,
      rs1, rs2, rdata1, rdata2,
      R0
   );
   
   wire [7:0] alu_res;
   assign alu_res = rdata1 + rdata2;
   
   assign wen = add | li;
   assign wdata = (li) ? { 4'h0, imm } : alu_res;
   
   always @(posedge clk) begin
      if(rst) begin
         PC <= 4'h0;
      end
      else begin
         PC <= (benr0 && (R0 != rdata2)) ? addr : (PC + 4'd1);
      end
      $strobe("Ins: %x", Ins);
   end
   
   reg [7:0] out_reg;
   always @(posedge clk) begin
      if(rst) begin
         out_reg <= 8'h00;
      end
      else begin
         if(out) begin
            out_reg <= rdata2;
         end
      end
   end
   assign out_rs = out_reg;

endmodule

module top(
   input wire clk,
   input wire rst,
   output wire [7:0] seg0,
   output wire [7:0] seg1
);

   wire [7:0] seg_in;
   sCPU sCPU_inst(clk, rst, seg_in);
   seg7 seg7_inst1(seg_in[3:0], seg0);
   seg7 seg7_inst2(seg_in[7:4], seg1);

endmodule
