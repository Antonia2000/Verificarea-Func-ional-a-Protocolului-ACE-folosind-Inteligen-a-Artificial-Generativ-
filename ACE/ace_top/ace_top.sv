//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//
//  Designer              : Raul Milchis (RM)
//  Date                  : 16/02/2023
//  File name             : ace_top.sv
//  Last modified+updates : 16/02/2023 (RM)
//  Project               : ACE Protocol VIP
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Top module for ACE Verification Environment
//  ======================================================================================================

`define AXI4PC_OFF

module ace_top;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import ace_tb_pkg::*;
  import ace_test_pkg::*;

  import acewrite_pkg::*;
  import aceread_pkg::*;

  reg clk;
  reg rst_n;

  acewrite_if #(
    .TP          (0          ),
    .AGENT_NAME  ("acewrite_agent")
  ) i_acewr_if (
    .clk  (clk),
    .rst_n(rst_n)
  );

  aceread_if #(
    .TP          (0          ),
    .AGENT_NAME  ("aceread_agent")
  ) i_aceread_if (
    .clk  (clk),
    .rst_n(rst_n)
  );

  initial begin
    clk = 1'b0;
    forever begin
      #10;
      clk = ~clk;
    end
  end

  initial begin
    rst_n = 1'b0;
    #30;
    @(posedge clk);
    rst_n = 1'b1;
  end

  initial begin
    uvm_config_db #(virtual acewrite_if)::set (null, "uvm_test_top*", "acewrite_if", i_acewr_if);
    uvm_config_db #(virtual aceread_if)::set (null, "uvm_test_top*", "aceread_if", i_aceread_if);
    run_test("ace_master_write_test");
  end


endmodule : ace_top
