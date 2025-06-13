//------------------------------------------------------------------------------
// File: ace_tb_pkg.sv
// Description: Package for ACE project testbench
//------------------------------------------------------------------------------

package ace_tb_pkg;

  // Import UVM package
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Import agent packages
  import aceread_pkg::*;
  import acewrite_pkg::*;

  // Include files
  `include "ace_tb_config.svh"
  `include "ace_virtual_sequencer.svh"
  `include "ace_tb.svh"

endpackage : ace_tb_pkg