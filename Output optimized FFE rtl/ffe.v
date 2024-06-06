/* -----------------------------------------------------------------------------
   Copyright (c) 2024 FFE implementation Digital design course final project
   -----------------------------------------------------------------------------
   FILE NAME : ffe.v
   DEPARTMENT : --
   AUTHOR : Omar Muhammad
   AUTHOR’S EMAIL : omarmuhammadmu0@gmail.com
   -----------------------------------------------------------------------------
   RELEASE HISTORY
   VERSION  DATE        AUTHOR      DESCRIPTION
   1.0      2024-06-05  Omar        initial version
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
module ffe #(
    parameter   IN_OUT_BUS_WIDTH = 12
)(
    /* ----------- inputs -----------*/
    input  wire                                 ffe_clk,
    input  wire                                 data_clk,
    input  wire                                 rst,
    input  wire                                 load,
    input  wire signed [IN_OUT_BUS_WIDTH-1:0]   d_in,
    /* ----------- outputs -----------*/
    output wire signed [IN_OUT_BUS_WIDTH-1:0]   y
);
/* ----------------------------------
            local parameters
 ----------------------------------*/
localparam L_RD_ADDR_SIZE = 2;
/* ----------------------------------
        internal connections
 ----------------------------------*/
wire shift_en, rd_en;
wire str_out_n_rst_add_reg;
wire [L_RD_ADDR_SIZE-1 : 0] rd_addr;
wire [IN_OUT_BUS_WIDTH - 1 : 0] rd_data;
/* ----------------------------------
            instantiations
 ----------------------------------*/
register_file u_register_file (
    .ffe_clk (ffe_clk),
    .data_clk (data_clk),
    .rst (rst),
    .load (load),
    .shift_en (shift_en),
    .rd_en (rd_en),
    .rd_addr (rd_addr),
    .d_in (d_in),
    .rd_data (rd_data)
);

ffe_controller u_ffe_controller (
    .ffe_clk (ffe_clk),
    .rst (rst),
    .load (load),
    .shift_en (shift_en),
    .rd_en (rd_en),
    .str_out_n_rst_add_reg (str_out_n_rst_add_reg),
    .rd_addr (rd_addr)
);

ffe_datapath u_ffe_datapath (
    .ffe_clk (ffe_clk),
    .rst (rst),
    .str_out_n_rst_add_reg (str_out_n_rst_add_reg),
    .rd_addr (rd_addr),
    .rd_data (rd_data),
    .y (y)
);
endmodule
/* ---------------- End of file  ---------------- */