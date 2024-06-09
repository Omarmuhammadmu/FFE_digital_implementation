/* -----------------------------------------------------------------------------
   Copyright (c) 2024 FFE implementation Digital design course final project
   -----------------------------------------------------------------------------
   FILE NAME : register_file.v
   DEPARTMENT : FFE
   AUTHOR : Omar Muhammad
   AUTHOR’S EMAIL : omarmuhammadmu0@gmail.com
   -----------------------------------------------------------------------------
   RELEASE HISTORY
   VERSION  DATE        AUTHOR      DESCRIPTION
   1.0      2024-06-05  Omar        initial version
   -----------------------------------------------------------------------------
   KEYWORDS : FFE
   -----------------------------------------------------------------------------
   PURPOSE : Memory that deals with reception of the data
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
module register_file #(
    parameter   IN_OUT_BUS_WIDTH = 12,
                DEPTH = 4,
                ADDR_SIZE = $clog2(DEPTH)
)(
    /* ----------- inputs -----------*/
    input  wire                                 ffe_clk,
    input  wire                                 data_clk,
    input  wire                                 rst,
    input  wire                                 load,
    input  wire                                 shift_en,
    input  wire                                 rd_en,
    input  wire        [ADDR_SIZE-1:0]          rd_addr,
    input  wire signed [IN_OUT_BUS_WIDTH-1:0]   d_in,
    /* ----------- outputs -----------*/
    output wire signed [IN_OUT_BUS_WIDTH-1:0]   rd_data
);
/* ----------------------------------
  Internal connections and components
 ----------------------------------*/
reg signed [IN_OUT_BUS_WIDTH-1:0]   data_in_mem [DEPTH-1:0];
integer i;
/* ----------------------------------
    Storing data in memory logic
 ----------------------------------*/
always @(posedge data_clk or negedge rst) begin
    if(!rst) begin
        data_in_mem[0] <= 'b0;
    end else begin
        if(load) begin
            data_in_mem[0]  <=  d_in;
        end
    end
end
always @(posedge ffe_clk or negedge rst) begin
    if(!rst) begin
        for(i = 1; i < DEPTH; i = i + 1) begin
            data_in_mem[i] <= 'b0;
        end
    end else begin
        if(shift_en) begin
            for(i = 1; i<DEPTH; i = i + 1) begin
                data_in_mem[i] <= data_in_mem[i - 1];
            end
        end
    end
end
/* ----------------------------------
    Reading data from memory logic
 ----------------------------------*/
assign rd_data = (rd_en)? data_in_mem[rd_addr]: 'b0;
endmodule
/* ---------------- End of file  ---------------- */