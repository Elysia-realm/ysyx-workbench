module lfsr8 (
  input wire clk, 
  input wire rst,
  input wire [7:0] in,
  output reg [7:0] out
);

   wire next;
   always @(posedge clk or posedge rst) begin
   	if(rst) begin
   	   out <= in;
   	end
   	else begin
   	   out <= { next, out[7:1] };
   	end
   end
   
   assign next = out[4] ^ out[3] ^ out[2] ^ out[0];

endmodule
