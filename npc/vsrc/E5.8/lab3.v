module ALU (
   input wire [2:0] op,
   input wire [3:0] A,
   input wire [3:0] B,
   output wire [3:0] Y,
   output wire CF,
   output wire OF,
   output wire ZF
);

   wire sub;
   assign sub = (op == 3'b001 || op == 3'b110 || op == 3'b111) ? 1'b1 : 1'b0;
   
   wire [3:0] subB, subBB1;
   assign subBB1 = B ^ {4{sub}};
   assign subB = subBB1 + sub;
   
   wire [3:0] math;
   assign { CF, math } = A + subB;
   assign OF = (math[3] ^ A[3]) & (math[3] ^ subB[3]);
   assign ZF = (math == 4'b0000);
   
   reg [3:0] res;
   always @(op or A or B) begin
      case(op)
         3'b000: res = math;
         3'b001: res = math;
         3'b010: res = ~A;
         3'b011: res = A & B;
         3'b100: res = A | B;
         3'b101: res = A ^ B;
         3'b110: res = { 3'b0, math[3] ^ OF };
         3'b111: res = { 3'b0, ZF };
      endcase
   end
   
   assign Y = res;

endmodule
