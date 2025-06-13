package acewrite_pkg;

  // Import UVM package
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Include all Write ACE UVM files
  `include "acewrite_type_def.svh"
  `include "acewrite_item.svh"
  `include "acewrite_config.svh"
  `include "acewrite_master_driver.svh"
  `include "acewrite_slave_driver.svh"
  `include "acewrite_sequencer.svh"
  `include "acewrite_monitor.svh"
  `include "acewrite_agent.svh"
  `include "acewrite_seq_lib.svh"

endpackage : acewrite_pkg