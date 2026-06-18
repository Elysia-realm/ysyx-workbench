module encode83 (
   input wire en,
   input wire [7:0] x,
   output wire [2:0] y
);

   wire y0, y1, y2;
   assign y2 = x[7] | (~x[7] & x[6]) | (~x[7] & ~x[6] & x[5]) | (~x[7] & ~x[6] & ~x[5] & x[4]);
   assign y1 = x[7] | (~x[7] & x[6]) | (~x[7] & ~x[6] & ~x[5] & ~x[4] & x[3]) | (~x[7] & ~x[6] & ~x[5] & ~x[4] & ~x[3] & x[2]);
   assign y0 = x[7] | (~x[7] & ~x[6] & x[5]) | (~x[7] & ~x[6] & ~x[5] & ~x[4] & x[3]) | (~x[7] & ~x[6] & ~x[5] & ~x[4] & ~x[3] & ~x[2] & x[1]);

   assign y[0] = en & y0;
   assign y[1] = en & y1;
   assign y[2] = en & y2;

endmodule
