module ffe_controller #(
    parameter   DEPTH = 4,
                ADDR_SIZE = $clog2(DEPTH)
)(
    /* ----------- inputs -----------*/
    input  wire                 ffe_clk,
    input  wire                 rst,
    input  wire                 load,
    /* ----------- outputs -----------*/
    output reg                  shift_en,
    output reg                  str_out_n_rst_add_reg,
    output reg  [ADDR_SIZE-1:0] rd_addr
);
/* ----------------------------------
            Local parameters
 ----------------------------------*/
localparam  L_IDLE      = 1'b0,
            L_COMPUTE   = 1'b1;
localparam  L_ZERO      = 2'd0,
            L_ONE       = 2'd1,
            L_TWO       = 2'd2,
            L_THREE     = 2'd3;
/* ----------------------------------
  Internal connections and components
 ----------------------------------*/
reg                 current_state, next_state;
reg [ADDR_SIZE-1:0] rd_addr_c;
/* ----------------------------------
            FSM logic
 ----------------------------------*/
always @(posedge ffe_clk or negedge rst) begin
    if(!rst) begin
        current_state <=    L_IDLE;
    end else begin
        current_state <=    next_state;
    end
end

//Read address register
always @(posedge ffe_clk or negedge rst) begin
    if(!rst) begin
        rd_addr <=  'b0;
    end else begin
        rd_addr <= rd_addr_c;
    end
end

// state and output logic
always @(*) begin
    case (current_state) 
    L_IDLE : begin
        rd_addr_c = L_ZERO;
        shift_en = 1'b0;
        str_out_n_rst_add_reg = 1'b0;
        if(load) begin
            next_state = L_COMPUTE;
        end else begin
            next_state = L_IDLE;
        end
    end
    L_COMPUTE : begin
        // Default values
        shift_en = 1'b0;
        next_state = L_COMPUTE;
        str_out_n_rst_add_reg = 1'b0;

        case (rd_addr)
        L_ZERO: begin
            rd_addr_c = L_THREE;
            shift_en = 1'b1;
        end
        L_ONE: begin
            rd_addr_c = L_ZERO;
            if(~load) begin
                next_state = L_IDLE;
            end
        end
        L_TWO: begin
            rd_addr_c = L_ONE;
        end
        L_THREE: begin
            rd_addr_c = L_TWO;
            str_out_n_rst_add_reg = 1'b1;
        end
        endcase
    end
    default : begin
        next_state = L_IDLE;
    end
    endcase
end
endmodule
/* ---------------- End of file  ---------------- */