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

reg  signed [IN_OUT_BUS_WIDTH-1:0]  ffe_multipler_out_reg;
reg  signed [IN_OUT_BUS_WIDTH-1:0]  ffe_adder_out_reg;
reg  signed [IN_OUT_BUS_WIDTH-1:0]  ffe_out_reg;
wire signed [IN_OUT_BUS_WIDTH-1:0]  ffe_multipler_out_c;
wire signed [IN_OUT_BUS_WIDTH-1:0]  ffe_adder_out_c;
wire signed [IN_OUT_BUS_WIDTH-1:0]  ffe_out_c;
wire [(IN_OUT_BUS_WIDTH * 2)-1:0]   multipler_out;
/* ----------------------------------
        FFE datapath logic
 ----------------------------------*/
always @(posedge ffe_clk or negedge rst) begin
    if(!rst) begin
        ffe_multipler_out_reg <= 'b0;
        ffe_adder_out_reg <= 'b0;
        ffe_out_reg <= 'b0;
    end else begin
        if(str_out_n_rst_add_reg) begin
            ffe_adder_out_reg <= 'b0;
            ffe_out_reg <= ffe_adder_out_c;
        end else begin
            ffe_adder_out_reg <= ffe_adder_out_c;
        end
        ffe_multipler_out_reg <= ffe_multipler_out_c; 
    end
end

assign multipler_out = h_mem[rd_addr] * rd_data;
assign ffe_multipler_out_c = multipler_out[22:11];
assign ffe_adder_out_c = ffe_multipler_out_reg + ffe_adder_out_reg;

always @(*) begin
    if(str_out_n_rst_add_reg) begin
        y = ffe_adder_out_c;
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