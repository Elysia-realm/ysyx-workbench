module E58(
  input wire clk,
  input wire rst,
  
  /* lab2
  input wire [8:0] sw,
  output wire [7:0] seg0,
  output wire [3:0] led
  */
  
  /* lab2
  input wire [10:0] sw,  // op=sw[10:8], A=sw[7:4], B=sw[3:0] 
  output wire [2:0] led, // ZF, OF, CF
  output wire [7:0] seg0,
  output wire [7:0] seg1
  */
  
  /* lab6
  input wire [1:0] btn,
  output wire [7:0] seg0,
  output wire [7:0] seg1
  */
  
  /* lab7
  input ps2_clk,
  input ps2_data,
  output wire [7:0] seg0,
  output wire [7:0] seg1,
  output wire [7:0] seg2,
  output wire [7:0] seg3,
  output wire [7:0] seg4,
  output wire [7:0] seg5,
  output wire [2:0] led
  */
  
  output VGA_CLK,
  output VGA_HSYNC,
  output VGA_VSYNC,
  output VGA_BLANK_N,
  output [7:0] VGA_R,
  output [7:0] VGA_G,
  output [7:0] VGA_B
);

   /* lab2
   wire [2:0] encode;
   encode83 encode83_inst(sw[8], sw[7:0], encode);
   seg7 seg7_inst({1'b0, encode}, seg0);
   assign led[3] = sw[0] | sw[1] | sw[2] | sw[3] | sw[4] | sw[5] | sw[6] | sw[7];
   assign led[2:0] = encode;
   */
   
   /* lab3
   wire [3:0] alu_res;
   ALU ALU_inst(sw[10:8], sw[7:4], sw[3:0], alu_res, led[0], led[1], led[2]);
   wire [2:0] seg_in = (alu_res[2:0] ^ {3{alu_res[3]}}) + alu_res[3];
   seg7 sge7_inst({1'b0, seg_in}, seg0);
   assign seg1 = (alu_res[3] == 1'b0) ? ~(8'b11111101) : ~(8'b00000010);
   */
   
   /* lab6
   wire [7:0] seg_in;
   lfsr8 lfsr8_inst(btn[0], btn[1], 8'b00000001, seg_in);
   seg7 seg7_inst1(seg_in[3:0], seg0);
   seg7 seg7_inst2(seg_in[7:4], seg1);
   */
   
   /* lab7
   wire [7:0] cur_kbd, last_kbd, last2_kbd;
   kbd_controller kbd_inst(clk, rst, ps2_clk, ps2_data, cur_kbd, last_kbd, last2_kbd, led);
   seg7 seg7_inst1(cur_kbd[3:0], seg0);
   seg7 seg7_inst2(cur_kbd[7:4], seg1);
   seg7 seg7_inst3(last_kbd[3:0], seg2);
   seg7 seg7_inst4(last_kbd[7:4], seg3);
   seg7 seg7_inst5(last2_kbd[3:0], seg4);
   seg7 seg7_inst6(last2_kbd[7:4], seg5);
   */
   
   assign VGA_CLK = clk;
   wire [9:0] h_addr;
   wire [9:0] v_addr;
   wire [23:0] vga_data;
   vga_ctrl my_vga_ctrl(
       .pclk(clk),
       .reset(rst),
       .vga_data(vga_data),
       .h_addr(h_addr),
       .v_addr(v_addr),
       .hsync(VGA_HSYNC),
       .vsync(VGA_VSYNC),
       .valid(VGA_BLANK_N),
       .vga_r(VGA_R),
       .vga_g(VGA_G),
       .vga_b(VGA_B)
   );
   vmem my_vmem(
       .h_addr(h_addr),
       .v_addr(v_addr[8:0]),
       .vga_data(vga_data)
   );
   
endmodule

module vmem(
    input [9:0] h_addr,
    input [8:0] v_addr,
    output [23:0] vga_data
);

reg [23:0] vga_mem [524287:0];

initial begin
    $readmemh("/home/sqh/ysyx-workbench/npc/vsrc/picture.hex", vga_mem);
end

assign vga_data = vga_mem[{h_addr, v_addr}];

endmodule
