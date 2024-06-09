/* -----------------------------------------------------------------------------
   Copyright (c) 2024 FFE implementation Digital design course final project
   -----------------------------------------------------------------------------
   FILE NAME : ffe.tb.v
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
   PURPOSE : testbench for the designed ffe
-FHDR------------------------------------------------------------------------*/

/*Time percision*/
`timescale 1ns/1ns

module ffe_tb();

/*--------------------------------------------------------------------
                Parameters used in the testbench module
  --------------------------------------------------------------------*/
localparam  CLK_PERIOD  = 100;
localparam  CLK_DIFFERENCE_FACTOR = 4;
localparam  IN_OUT_BUS_WIDTH = 12;
/*--------------------------------------------------------------------
                        Declaring testbench signals
  --------------------------------------------------------------------*/
reg                                           CLK_TB;
reg                                           DATA_CLK_TB;
reg                                           RST_TB;
reg                                           LOAD_TB;
reg      signed  [IN_OUT_BUS_WIDTH - 1:0]     DIN_TB;
wire     signed  [IN_OUT_BUS_WIDTH - 1:0]     DOUT_TB;
/*--------------------------------------------------------------------
                            DUT instantiation
  --------------------------------------------------------------------*/
ffe DUT(
    .ffe_clk  (CLK_TB),
    .data_clk (DATA_CLK_TB),
    .rst      (RST_TB),
    .load     (LOAD_TB),
    .d_in     (DIN_TB),
    .y        (DOUT_TB)
);
/*--------------------------------------------------------------------
                           CLK waveform
  --------------------------------------------------------------------*/
// input data clock
always
  begin
    #(CLK_PERIOD * (CLK_DIFFERENCE_FACTOR/2))  DATA_CLK_TB = ~ DATA_CLK_TB;
  end
// ffe clock
always
  begin
    #(CLK_PERIOD / 2)  CLK_TB = ~ CLK_TB;
  end
/*--------------------------------------------------------------------
                      Loop variables 
--------------------------------------------------------------------*/
integer                       test_cases;
/*--------------------------------------------------------------------
                        Initial block 
  --------------------------------------------------------------------*/
initial
begin
  $dumpfile("ffe_tb.vcd");
  $dumpvars ;

  // Initialize 
  initialize();

  // Input stimulus generator
  for (test_cases = 1; test_cases < 8; test_cases = test_cases + 1) begin
    data_input_stimulus(test_cases * 10);
  end

   #(6 * CLK_PERIOD) $stop;
end

// Task desciption: This task is used to initalize the system.
task initialize;
begin
  CLK_TB = 1'b1;
  DATA_CLK_TB = 1'b0;
  RST_TB = 1'b0;
  LOAD_TB='d0;
  DIN_TB='d00;

  // RST Activation
  #CLK_PERIOD
  RST_TB = 1'b0 ;

  // RST De-activation
  #CLK_PERIOD
  RST_TB = 1'b1 ;
  #(4 * CLK_PERIOD);
end
endtask

// Task desciption: This task is used to invoke the input data to the system.
task data_input_stimulus;
input signed [IN_OUT_BUS_WIDTH - 1:0] data_in_tb;
begin
  LOAD_TB='d1;
  DIN_TB= data_in_tb;

  #CLK_PERIOD
  LOAD_TB='d0;
  #(3 * CLK_PERIOD);
end
endtask
endmodule
/* ---------------- End of file  ---------------- */