class ace_base_test extends uvm_test;

  `uvm_component_utils(ace_base_test)

  ace_tb m_tb;

  //uvm_factory factory = uvm_factory::get();

  function new(string name = "ace_base_test", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_tb = ace_tb::type_id::create("m_tb", this);
  endfunction : build_phase

  function void final_phase(uvm_phase phase);
    `uvm_info("@@@@@@@@~~~~~~~~~~~~| TEST PASSED |~~~~~~~~~~~~@@@@@@@@", "No errors detected", UVM_NONE)
  endfunction : final_phase

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();
  endfunction: end_of_elaboration_phase

endclass : ace_base_test

//----------------------------------------------------------------------
// READ TEST CASES
//----------------------------------------------------------------------

// Master read test
class ace_master_write_test extends ace_base_test;

  // Factory registration
  `uvm_component_utils(ace_master_write_test)

  // Constructor
  function new(string name = "ace_master_write_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Run phase
  virtual task run_phase(uvm_phase phase);
    ace_write_master_vseq vseq;

    phase.raise_objection(this, "Starting master read test");
    `uvm_info(get_type_name(), "Master read test started", UVM_LOW)

    // Create and start the virtual sequence
    vseq = ace_write_master_vseq::type_id::create("vseq");
    vseq.start(m_tb.m_acewrite_vseqr);

    phase.phase_done.set_drain_time(this, 50);
    phase.drop_objection(this, "Finished master read test");
  endtask

endclass : ace_master_write_test

// // Slave read test
// class ace_slave_read_test extends ace_base_test;

//   // Factory registration
//   `uvm_component_utils(ace_slave_read_test)

//   // Constructor
//   function new(string name = "ace_slave_read_test", uvm_component parent = null);
//     super.new(name, parent);
//   endfunction

//   // Run phase
//   virtual task run_phase(uvm_phase phase);
//     ace_read_slave_vseq vseq;

//     phase.raise_objection(this, "Starting slave read test");
//     `uvm_info(get_type_name(), "Slave read test started", UVM_LOW)

//     // Create and start the virtual sequence
//     vseq = ace_read_slave_vseq::type_id::create("vseq");
//     vseq.start(m_vsequencer);

//     phase.drop_objection(this, "Finished slave read test");
//   endtask

// endclass : ace_slave_read_test

// // // Combined read test
// // class ace_combined_read_test extends ace_base_test;

// //   // Factory registration
// //   `uvm_component_utils(ace_combined_read_test)

// //   // Constructor
// //   function new(string name = "ace_combined_read_test", uvm_component parent = null);
// //     super.new(name, parent);
// //   endfunction

// //   // Run phase
// //   virtual task run_phase(uvm_phase phase);
// //     ace_read_combined_vseq vseq;

// //     phase.raise_objection(this, "Starting combined read test");
// //     `uvm_info(get_type_name(), "Combined read test started", UVM_LOW)

// //     // Create and start the virtual sequence
// //     vseq = ace_read_combined_vseq::type_id::create("vseq");
// //     vseq.start(m_vsequencer);

// //     phase.drop_objection(this, "Finished combined read test");
// //   endtask

// // endclass : ace_combined_read_test

// // //----------------------------------------------------------------------
// // WRITE TEST CASES
// //----------------------------------------------------------------------

// // Master write test
// class ace_master_write_test extends ace_base_test;

//   // Factory registration
//   `uvm_component_utils(ace_master_write_test)

//   // Constructor
//   function new(string name = "ace_master_write_test", uvm_component parent = null);
//     super.new(name, parent);
//   endfunction

//   // Run phase
//   virtual task run_phase(uvm_phase phase);
//     ace_write_master_vseq vseq;

//     phase.raise_objection(this, "Starting master write test");
//     `uvm_info(get_type_name(), "Master write test started", UVM_LOW)

//     // Create and start the virtual sequence
//     vseq = ace_write_master_vseq::type_id::create("vseq");
//     vseq.start(m_vsequencer);

//     phase.drop_objection(this, "Finished master write test");
//   endtask

// endclass : ace_master_write_test

// // Slave write test
// class ace_slave_write_test extends ace_base_test;

//   // Factory registration
//   `uvm_component_utils(ace_slave_write_test)

//   // Constructor
//   function new(string name = "ace_slave_write_test", uvm_component parent = null);
//     super.new(name, parent);
//   endfunction

//   // Run phase
//   virtual task run_phase(uvm_phase phase);
//     ace_write_slave_vseq vseq;

//     phase.raise_objection(this, "Starting slave write test");
//     `uvm_info(get_type_name(), "Slave write test started", UVM_LOW)

//     // Create and start the virtual sequence
//     vseq = ace_write_slave_vseq::type_id::create("vseq");
//     vseq.start(m_vsequencer);

//     phase.drop_objection(this, "Finished slave write test");
//   endtask

// endclass : ace_slave_write_test

// Combined write test
// class ace_combined_write_test extends ace_base_test;

//   // Factory registration
//   `uvm_component_utils(ace_combined_write_test)

//   // Constructor
//   function new(string name = "ace_combined_write_test", uvm_component parent = null);
//     super.new(name, parent);
//   endfunction

//   // Run phase
//   virtual task run_phase(uvm_phase phase);
//     ace_write_combined_vseq vseq;

//     phase.raise_objection(this, "Starting combined write test");
//     `uvm_info(get_type_name(), "Combined write test started", UVM_LOW)

//     // Create and start the virtual sequence
//     vseq = ace_write_combined_vseq::type_id::create("vseq");
//     vseq.start(m_vsequencer);

//     phase.drop_objection(this, "Finished combined write test");
//   endtask

// endclass : ace_combined_write_test

//----------------------------------------------------------------------
// MIXED READ/WRITE TEST CASES
//----------------------------------------------------------------------

// Mixed read/write test
// class ace_mixed_rw_test extends ace_base_test;

//   // Factory registration
//   `uvm_component_utils(ace_mixed_rw_test)

//   // Constructor
//   function new(string name = "ace_mixed_rw_test", uvm_component parent = null);
//     super.new(name, parent);
//   endfunction

//   // Run phase
//   virtual task run_phase(uvm_phase phase);
//     ace_read_combined_vseq read_vseq;
//     ace_write_combined_vseq write_vseq;

//     phase.raise_objection(this, "Starting mixed read/write test");
//     `uvm_info(get_type_name(), "Mixed read/write test started", UVM_LOW)

//     // Create the virtual sequences
//     read_vseq = ace_read_combined_vseq::type_id::create("read_vseq");
//     write_vseq = ace_write_combined_vseq::type_id::create("write_vseq");

//     // Run read sequence followed by write sequence
//     read_vseq.start(m_vsequencer);
//     write_vseq.start(m_vsequencer);

//     phase.drop_objection(this, "Finished mixed read/write test");
//   endtask

// endclass : ace_mixed_rw_test

// // Multiple operations test
// class ace_multiple_operations_test extends ace_base_test;

//   // Factory registration
//   `uvm_component_utils(ace_multiple_operations_test)

//   // Constructor
//   function new(string name = "ace_multiple_operations_test", uvm_component parent = null);
//     super.new(name, parent);
//   endfunction

//   // Run phase
//   virtual task run_phase(uvm_phase phase);
//     ace_read_vseq master_read_vseq;
//     ace_write_master_vseq master_write_vseq;
//     ace_read_slave_vseq slave_read_vseq;
//     ace_write_slave_vseq slave_write_vseq;

//     phase.raise_objection(this, "Starting multiple operations test");
//     `uvm_info(get_type_name(), "Multiple operations test started", UVM_LOW)

//     // Create the virtual sequences
//     master_read_vseq = ace_read_vseq::type_id::create("master_read_vseq");
//     master_write_vseq = ace_write_master_vseq::type_id::create("master_write_vseq");
//     slave_read_vseq = ace_read_slave_vseq::type_id::create("slave_read_vseq");
//     slave_write_vseq = ace_write_slave_vseq::type_id::create("slave_write_vseq");

//     // Run sequences in a specific order
//     master_read_vseq.start(m_vsequencer);
//     slave_read_vseq.start(m_vsequencer);
//     master_write_vseq.start(m_vsequencer);
//     slave_write_vseq.start(m_vsequencer);

//     // Run some sequences in parallel
//     fork
//       master_read_vseq.start(m_vsequencer);
//       slave_write_vseq.start(m_vsequencer);
//     join

//     phase.drop_objection(this, "Finished multiple operations test");
//   endtask

// endclass : ace_multiple_operations_test