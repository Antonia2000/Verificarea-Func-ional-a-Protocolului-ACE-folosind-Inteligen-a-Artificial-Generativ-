package aceread_pkg;

  // Import UVM package
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Include all ACE UVM files
  `include "aceread_type_def.svh"
  `include "aceread_item.svh"
  `include "aceread_config.svh"
  `include "aceread_master_driver.svh"
  `include "aceread_slave_driver.svh"
  `include "aceread_monitor.svh"
  `include "aceread_sequencer.svh"
  `include "aceread_agent.svh"
  `include "aceread_seq_lib.svh"

endpackage : aceread_pkg
