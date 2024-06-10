/* -----------------------------------------------------------------------------
   Copyright (c) 2024 FFE implementation Digital design course final project
   -----------------------------------------------------------------------------
   FILE NAME : ffe_datapath.v
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
   PURPOSE : datapath of the ffe
   -----------------------------------------------------------------------------
   PARAMETERS
   PARAM NAME           : RANGE   : DESCRIPTION         : DEFAULT   : UNITS       
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

// `define CRITICAL_PATH_BREAKING
// `define INCREASE_ACCURACY

module ffe_datapath #(
    parameter   IN_OUT_BUS_WIDTH = 12,
                DEPTH = 4,
                ADDR_SIZE = $clog2(DEPTH)
)(
    /* ----------- inputs -----------*/
    input  wire                                 ffe_clk,
    input  wire                                 rst,
    input  wire                                 str_out_n_rst_add_reg,
    input  wire        [ADDR_SIZE-1:0]          rd_addr,
    input  wire signed [IN_OUT_BUS_WIDTH-1:0]   rd_data,
    /* ----------- outputs -----------*/
    output reg signed [IN_OUT_BUS_WIDTH-1:0]   y
);
/* ----------------------------------
  Internal connections and components
 ----------------------------------*/
wire signed [IN_OUT_BUS_WIDTH-1:0]   h_mem [DEPTH-1:0];

`ifdef CRITICAL_PATH_BREAKING
    `ifdef INCREASE_ACCURACY
        reg  signed [(IN_OUT_BUS_WIDTH * 2 ) - 1  :0]  ffe_multipler_out_reg;
    `else
        reg  signed [IN_OUT_BUS_WIDTH-1:0]         ffe_multipler_out_reg;
    `endif
`endif

`ifdef INCREASE_ACCURACY
wire signed [(IN_OUT_BUS_WIDTH * 2 ) - 1  :0]  ffe_multipler_out_c;
wire signed [(IN_OUT_BUS_WIDTH * 2 ) - 1  :0]  ffe_adder_out_c;
reg  signed [(IN_OUT_BUS_WIDTH * 2 ) - 1  :0]  ffe_adder_out_reg;
`else
wire signed [IN_OUT_BUS_WIDTH-1:0]  ffe_multipler_out_c;
wire signed [IN_OUT_BUS_WIDTH-1:0]  ffe_adder_out_c;
reg  signed [IN_OUT_BUS_WIDTH-1:0]  ffe_adder_out_reg;
`endif

reg  signed [IN_OUT_BUS_WIDTH-1:0]  ffe_out_reg;
wire signed [IN_OUT_BUS_WIDTH-1:0]  ffe_out_c;
wire [(IN_OUT_BUS_WIDTH * 2)-1:0]   multipler_out;
/* ----------------------------------
        FFE datapath logic
 ----------------------------------*/
always @(posedge ffe_clk or negedge rst) begin
    if(!rst) begin
        `ifdef CRITICAL_PATH_BREAKING
        ffe_multipler_out_reg <= 'b0;
        `endif 
        ffe_adder_out_reg <= 'b0;
        ffe_out_reg <= 'b0;
    end else begin
        if(str_out_n_rst_add_reg) begin
            ffe_adder_out_reg <= 'b0;
            `ifdef INCREASE_ACCURACY
                ffe_out_reg <= ffe_out_c;
            `else
                ffe_out_reg <= ffe_adder_out_c;
            `endif
        end else begin
            ffe_adder_out_reg <= ffe_adder_out_c;
        end
        `ifdef CRITICAL_PATH_BREAKING
        ffe_multipler_out_reg <= ffe_multipler_out_c;
        `endif 
    end
end

assign multipler_out = h_mem[rd_addr] * rd_data;

`ifdef INCREASE_ACCURACY
    assign ffe_out_c = ffe_adder_out_c[22:11];
    assign ffe_multipler_out_c = multipler_out;
`else
    assign ffe_multipler_out_c = multipler_out[22:11];
`endif

`ifdef CRITICAL_PATH_BREAKING
    assign ffe_adder_out_c = ffe_multipler_out_reg + ffe_adder_out_reg;
`else
    assign ffe_adder_out_c = ffe_multipler_out_c + ffe_adder_out_reg;
`endif 

always @(*) begin
    if(str_out_n_rst_add_reg) begin
        `ifdef INCREASE_ACCURACY
            y = ffe_out_c;
        `else
            y = ffe_adder_out_c;
        `endif
    end else begin
        y = ffe_out_reg;
    end
end
/* ----------------------------------
 H memory initializing (Not generic)
 ----------------------------------*/
assign h_mem[0] =   'd1024;
assign h_mem[1] = - 'd512;
assign h_mem[2] =   'd320;
assign h_mem[3] = - 'd128;
endmodule
/* ---------------- End of file  ---------------- */