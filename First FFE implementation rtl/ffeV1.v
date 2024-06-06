/* -----------------------------------------------------------------------------
   Copyright (c) 2024 FFE implementation, Digital design course final project
   -----------------------------------------------------------------------------
   FILE NAME : ffe.v
   DEPARTMENT : --
   AUTHOR : --
   AUTHOR’S EMAIL : --
   -----------------------------------------------------------------------------
   RELEASE HISTORY
   VERSION  DATE        AUTHOR      DESCRIPTION
   1.0      2024-06-05  --          initial version
   -----------------------------------------------------------------------------
   KEYWORDS : FFE
   -----------------------------------------------------------------------------
   PURPOSE : Implementation of FFE using only one adder and multipler
   -----------------------------------------------------------------------------
   PARAMETERS
   PARAM NAME           : RANGE   : DESCRIPTION         : DEFAULT   : UNITS
   IN_OUT_BUS_WIDTH     : N/A     : Input and output    : 12        : bits
                                    width              
   -----------------------------------------------------------------------------
   REUSE ISSUES
   Reset Strategy   : Asynch rst
   Clock Domains    : N
   Critical Timing  : N/A
   Test Features    : N/A
   Asynchronous I/F : N/A  
   Scan Methodology : N/A
   Instantiations   : N/A
   Synthesizable    : Y
   Other            : N/A
   -FHDR------------------------------------------------------------------------*/
module ffeV1 #(parameter  depth = 4,
                          width = 12,
                          rom_width = 12
)(
  /* ----------- inputs -----------*/
  input  wire                       SYS_CLK,
  input  wire                       FFE_CLK,
  input  wire                       RST,
  input  wire                       load,
  input  wire signed  [width-1:0]   D_in,
  /* ----------- outputs -----------*/
  output reg  signed  [width-1:0]   D_out
);
/* ----------------------------------
  Internal connections and components
 ----------------------------------*/
// Memories
wire  signed  [rom_width-1:0]  h    [depth-1:0];
reg   signed  [width-1:0]      mem  [depth-1:0];
// regs and internal connections
reg           [1:0]           counter_edge;
reg   signed  [2*width-1:0]   comb_sum; 
integer i;
/* ----------------------------------
              FFE logic
 ----------------------------------*/
always@(posedge SYS_CLK or negedge RST) begin
  if(!RST) begin
    for(i=0;  i < depth;  i = i + 1) begin
        mem[i]  <=  'b0;
    end
  end else begin
    if(load) begin
      mem[0]  <=  D_in;
      mem[1]  <=  mem[0];
      mem[2]  <=  mem[1];
      mem[3]  <=  mem[2];
    end
  end
end

always@(posedge FFE_CLK or negedge RST) begin
  if(!RST) begin
      D_out         <='b0;
      comb_sum      <='b0;
      counter_edge  <='b0;
  end else begin
      if(load || counter_edge == 0) begin
        comb_sum      <= h[counter_edge] * mem[counter_edge];
        counter_edge  <= counter_edge  + 1;
        D_out         <= comb_sum >>> 'd11;
      end else begin
        comb_sum <=  comb_sum + (h[counter_edge] * mem[counter_edge]);
        if(counter_edge ==  'd3) begin
          counter_edge  <=  'b0;
        end else begin
          counter_edge  <=  counter_edge  + 1;
        end
      end
  end
end
/* ----------------------------------
 H memory initializing (Not generic)
 ----------------------------------*/
assign h[0] =   'd1024;
assign h[1] = - 'd512;
assign h[2] =   'd320;
assign h[3] = - 'd128;
endmodule
/* ---------------- End of file  ---------------- */