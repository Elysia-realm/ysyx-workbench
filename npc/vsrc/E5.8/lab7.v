module kbd_controller (
   input wire clk,
   input wire rst,
   input wire ps2_clk,
   input ps2_data,
   output wire [7:0] dout1,
   output wire [7:0] dout2,
   output wire [7:0] dout3,
   output wire [2:0] flag
);

   wire [7:0] kbd;
   wire ready, overflow, sampling, sampling2;
   reg nextdata_n;
   ps2_keyboard ps2_kbd_inst(clk, ~rst, ps2_clk, ps2_data, kbd, ready, nextdata_n, overflow, sampling);
   ps2_keyboard_nvboard nv_inst(clk, ~rst, ps2_clk, ps2_data, sampling2);
   
   reg [7:0] last2_kbd, last_kbd, cur_kbd;
   always @(posedge clk) begin
      if(rst) begin
         last2_kbd <= 8'h00;
         last_kbd <= 8'h00;
         cur_kbd <= 8'h00;
      end
      else begin
         if(ready == 1'b1) begin
            cur_kbd <= kbd;
            last_kbd <= cur_kbd;
            last2_kbd <= last_kbd;
         end
      end
   end
   
   // nextdata_n have to blocking-assignment
   always @(*) begin
      if(rst) begin
         nextdata_n = 1'b1;
      end
      else begin
        if(ready == 1'b1) begin
           nextdata_n = 1'b0;
        end
        else
           nextdata_n = 1'b1;
      end
   end
   
   reg [7:0] count;
   always @(posedge clk) begin
      if(rst) begin
         count <= 8'h00;
      end
      else begin
         if(ready == 1'b1 && cur_kbd == 8'hF0) begin
            count <= count + 8'b1;
         end
      end
   end
   
   wire [7:0] kbd_ascii;
   kbd2ASCII mem_inst(cur_kbd, kbd_ascii);
   
   assign dout1 = (last_kbd == 8'hF0) ? 8'h00 : cur_kbd;
   assign dout2 = (last_kbd != 8'hF0) ? kbd_ascii : 8'h00;
   assign dout3 = count;
   
   assign flag[0] = overflow;
   assign flag[1] = sampling2;
   assign flag[2] = ready;

endmodule

module ps2_keyboard(clk,clrn,ps2_clk,ps2_data,data,
                    ready,nextdata_n,overflow, sampling);
    input clk,clrn,ps2_clk,ps2_data;
    input nextdata_n;
    output [7:0] data;
    output reg ready;
    output reg overflow;     // fifo overflow
    output sampling;
    // internal signal, for test
    reg [9:0] buffer;        // ps2_data bits
    reg [7:0] fifo[7:0];     // data fifo
    reg [2:0] w_ptr,r_ptr;   // fifo write and read pointers
    reg [3:0] count;  // count ps2_data bits
    // detect falling edge of ps2_clk
    reg [2:0] ps2_clk_sync;

    always @(posedge clk) begin
        ps2_clk_sync <=  {ps2_clk_sync[1:0],ps2_clk};
    end

    assign sampling = ps2_clk_sync[2] & ~ps2_clk_sync[1];

    always @(posedge clk) begin
        if (clrn == 0) begin // reset
            count <= 0; w_ptr <= 0; r_ptr <= 0; overflow <= 0; ready<= 0;
        end
        else begin
            if ( ready ) begin // read to output next data
                if(nextdata_n == 1'b0) //read next data
                begin
                    r_ptr <= r_ptr + 3'b1;
                    if(w_ptr==(r_ptr+1'b1)) //empty
                        ready <= 1'b0;
                end
            end
            if (sampling) begin
              if (count == 4'd10) begin
                if ((buffer[0] == 0) &&  // start bit
                    (ps2_data)       &&  // stop bit
                    (^buffer[9:1])) begin      // odd  parity
                    fifo[w_ptr] <= buffer[8:1];  // kbd scan code
                    w_ptr <= w_ptr+3'b1;
                    ready <= 1'b1;
                    overflow <= overflow | (r_ptr == (w_ptr + 3'b1));
                end
                count <= 0;     // for next
              end else begin
                buffer[count] <= ps2_data;  // store ps2_data
                count <= count + 3'b1;
              end
            end
        end
    end
    assign data = fifo[r_ptr]; //always set output data

endmodule

module ps2_keyboard_nvboard(clk,resetn,ps2_clk,ps2_data, sampling);
    input clk,resetn,ps2_clk,ps2_data;
    output sampling;

    reg [9:0] buffer;        // ps2_data bits
    reg [3:0] count;  // count ps2_data bits
    reg [2:0] ps2_clk_sync;

    always @(posedge clk) begin
        ps2_clk_sync <=  {ps2_clk_sync[1:0],ps2_clk};
    end

    assign sampling = ps2_clk_sync[2] & ~ps2_clk_sync[1];

    always @(posedge clk) begin
        if (resetn == 0) begin // reset
            count <= 0;
        end
        else begin
            if (sampling) begin
              if (count == 4'd10) begin
                if ((buffer[0] == 0) &&  // start bit
                    (ps2_data)       &&  // stop bit
                    (^buffer[9:1])) begin      // odd  parity
                    $display("receive %x", buffer[8:1]);
                end
                count <= 0;     // for next
              end else begin
                buffer[count] <= ps2_data;  // store ps2_data
                count <= count + 3'b1;
              end
            end
        end
    end

endmodule

module kbd2ASCII(
   input wire [7:0] addr,
   output wire [7:0] ascii
);

   reg [7:0] kbd_mem [255:0];
   
   initial begin
      // have to write absolute-path
      $readmemh("/home/sqh/ysyx-workbench/npc/vsrc/kbd2ASCII.hex", kbd_mem);
      $strobe("kbd_mem[1]", kbd_mem[8'h01]);
   end
   
   assign ascii = kbd_mem[addr];

endmodule
