/* -----------------------------------------------------------------------------
   Copyright (c) 2024 FFE implementation Digital design course final project
   -----------------------------------------------------------------------------
   FILE NAME : ffe_controller.v
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
   PURPOSE : Control unit that trace the state of the system
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
    output reg                  rd_en,
    output reg                  str_out_n_rst_add_reg,
    output reg  [ADDR_SIZE-1:0] rd_addr
);
/* ----------------------------------
            Local parameters
 ----------------------------------*/
localparam  L_RESET_STATE   = 2'b00,
            L_IDLE          = 2'b01,
            L_COMPUTE       = 2'b11;

localparam L_STATUS_REG_WIDTH = 2;

localparam  L_ZERO          = 2'd0,
            L_ONE           = 2'd1,
            L_TWO           = 2'd2,
            L_THREE         = 2'd3;
/* ----------------------------------
  Internal connections and components
 ----------------------------------*/
reg [L_STATUS_REG_WIDTH - 1 : 0]    current_state;
reg [L_STATUS_REG_WIDTH - 1 : 0]    next_state;
reg [ADDR_SIZE-1:0]                 rd_addr_c;
/* ----------------------------------
            FSM logic
 ----------------------------------*/
always @(posedge ffe_clk or negedge rst) begin
    if(!rst) begin
        current_state <=    L_RESET_STATE;
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
    L_RESET_STATE: begin
        rd_addr_c = L_ZERO;
        shift_en = 1'b0;
        str_out_n_rst_add_reg = 1'b0;
        rd_en = 1'b0;
        next_state = L_IDLE;
    end
    L_IDLE : begin
        rd_addr_c = L_ZERO;
        shift_en = 1'b0;
        str_out_n_rst_add_reg = 1'b0;
        rd_en = 1'b0;
        if(load) begin
            next_state = L_COMPUTE;
        end else begin
            next_state = L_IDLE;
        end
    end
    L_COMPUTE : begin
        // Default values
        rd_en = 1'b1;
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
        default : begin
            next_state = L_RESET_STATE;
        end
        endcase
    end
    default : begin
        next_state = L_RESET_STATE;
    end
    endcase
end
endmodule
/* ---------------- End of file  ---------------- */