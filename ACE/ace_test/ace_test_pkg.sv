package ace_test_pkg;

  // Import UVM packages
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Import other required packages
  import aceread_pkg::*;  // Main ACE protocol package
  import acewrite_pkg::*;  // Main ACE protocol package
  import ace_tb_pkg::*;  // Main ACE protocol package

  // Include virtual sequence library
  `include "ace_vsequence_lib.svh"

  // Include test library
  `include "ace_test_lib.svh"

endpackage : ace_test_pkg