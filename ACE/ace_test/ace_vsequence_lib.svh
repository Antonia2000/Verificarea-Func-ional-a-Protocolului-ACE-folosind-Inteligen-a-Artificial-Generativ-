// Base virtual sequence class
class ace_base_vseq extends uvm_sequence#(uvm_sequence_item);

  // Factory registration
  `uvm_object_utils(ace_base_vseq)

  logic [31:0] acaddr = 0;
  logic [31:0] awaddr = 0;

  `uvm_declare_p_sequencer(ace_virtual_sequencer)

  // Constructor
  function new(string name = "ace_base_vseq");
    super.new(name);
  endfunction

endclass : ace_base_vseq

// Virtual sequence to start the read sequence
class ace_read_vseq extends ace_base_vseq;

  // Factory registration
  `uvm_object_utils(ace_read_vseq)

  typedef ace_read_sequence ace_read_sequence_t;


  // Constructor
  function new(string name = "ace_read_vseq");
    super.new(name);
  endfunction

  // Body task - start the read sequence
  virtual task body();
     ace_read_sequence_t read_seq;

    `uvm_info(get_type_name(), "Starting ACE read virtual sequence", UVM_LOW)

    // Create and start the read sequence
    read_seq = ace_read_sequence_t::type_id::create("read_seq");

    // Start the sequence on the ACE sequencer
    read_seq.start(p_sequencer.m_aceread_master_seqr);

    `uvm_info(get_type_name(), "Completed ACE read virtual sequence", UVM_LOW)
  endtask : body

endclass : ace_read_vseq

// Virtual sequence to start the slave read sequence
class ace_read_slave_vseq extends ace_base_vseq;

  // Factory registration
  `uvm_object_utils(ace_read_slave_vseq)

  // Constructor
  function new(string name = "ace_read_slave_vseq");
    super.new(name);
  endfunction

  // Body task - start the slave read sequence
  virtual task body();
    ace_read_slave_seq slave_read_seq;

    `uvm_info(get_type_name(), "Starting ACE slave read virtual sequence", UVM_LOW)

    // Create and start the slave read sequence
    slave_read_seq = ace_read_slave_seq::type_id::create("slave_read_seq");

    // Start the sequence on the ACE slave sequencer
    slave_read_seq.start(p_sequencer.m_aceread_slave_seqr);

    `uvm_info(get_type_name(), "Completed ACE slave read virtual sequence", UVM_LOW)
  endtask : body

endclass : ace_read_slave_vseq

//----------------------------------------------------------------------
// WRITE VIRTUAL SEQUENCES
//----------------------------------------------------------------------

// Virtual sequence to start the master write sequence
class ace_write_master_vseq extends ace_base_vseq;

  // Factory registration
  `uvm_object_utils(ace_write_master_vseq)

    acewrite_writeunique_seq write_seq;
    acewrite_completer_seq   comp_write_seq;
  // Constructor
  function new(string name = "ace_write_master_vseq");
    super.new(name);
  endfunction

  // Body task - start the master write sequence
  virtual task body();

    `uvm_info(get_type_name(), "Starting ACE master write virtual sequence", UVM_LOW)

    // Create and start the write sequence
    write_seq      = acewrite_writeunique_seq::type_id::create("write_seq");
    comp_write_seq = acewrite_completer_seq::type_id::create("comp_write_seq");

    // Start the sequence on the ACE sequencer
    awaddr = $urandom_range(0,10);
    `uvm_info ("ace_write_master_vseq",$sformatf("awaddr = %h", awaddr), UVM_LOW)
    acaddr = awaddr;
    `uvm_info ("ace_write_master_vseq",$sformatf("acaddr = %h", acaddr), UVM_LOW)
    write_seq.awaddr      = awaddr;
    comp_write_seq.acaddr = acaddr;
    fork
        write_seq.start(p_sequencer.m_acewr_master_seqr);
        #50ns;
        comp_write_seq.start(p_sequencer.m_acewr_slave_seqr);
    join_any
    disable fork;


    `uvm_info(get_type_name(), "Completed ACE master write virtual sequence", UVM_LOW)
  endtask : body

endclass : ace_write_master_vseq

// Virtual sequence to start the slave write sequence
class ace_write_slave_vseq extends ace_base_vseq;

  // Factory registration
  `uvm_object_utils(ace_write_slave_vseq)

  // Constructor
  function new(string name = "ace_write_slave_vseq");
    super.new(name);
  endfunction

  // Body task - start the slave write sequence
  virtual task body();
    ace_write_slave_sequence slave_write_seq;

    `uvm_info(get_type_name(), "Starting ACE slave write virtual sequence", UVM_LOW)

    // Create and start the slave write sequence
    slave_write_seq = ace_write_slave_sequence::type_id::create("slave_write_seq");

    // Start the sequence on the ACE slave sequencer
    slave_write_seq.start(p_sequencer.m_acewr_slave_seqr);

    `uvm_info(get_type_name(), "Completed ACE slave write virtual sequence", UVM_LOW)
  endtask : body

endclass : ace_write_slave_vseq

// //----------------------------------------------------------------------
// // COMBINED VIRTUAL SEQUENCES
// //----------------------------------------------------------------------

// // Combined virtual sequence that starts both master and slave read sequences
// class ace_read_combined_vseq extends ace_base_vseq;

//   // Factory registration
//   `uvm_object_utils(ace_read_combined_vseq)

//   // Constructor
//   function new(string name = "ace_read_combined_vseq");
//     super.new(name);
//   endfunction

//   // Body task - start both master and slave read sequences
//   virtual task body();
//     ace_read_sequence master_read_seq;
//     ace_read_slave_seq slave_read_seq;

//     `uvm_info(get_type_name(), "Starting ACE combined read virtual sequence", UVM_LOW)

//     // Create the sequences
//     master_read_seq = ace_read_sequence::type_id::create("master_read_seq");
//     slave_read_seq = ace_read_slave_seq::type_id::create("slave_read_seq");

//     // Start sequences in parallel using fork-join
//     fork
//       master_read_seq.start(m_ace_seqr);
//       slave_read_seq.start(m_ace_slave_seqr);
//     join

//     `uvm_info(get_type_name(), "Completed ACE combined read virtual sequence", UVM_LOW)
//   endtask : body

// endclass : ace_read_combined_vseq

// // Combined virtual sequence that starts both master and slave write sequences
// class ace_write_combined_vseq extends ace_base_vseq;

//   // Factory registration
//   `uvm_object_utils(ace_write_combined_vseq)

//   // Constructor
//   function new(string name = "ace_write_combined_vseq");
//     super.new(name);
//   endfunction

//   // Body task - start both master and slave write sequences
//   virtual task body();
//     ace_write_master_sequence master_write_seq;
//     ace_write_slave_sequence slave_write_seq;

//     `uvm_info(get_type_name(), "Starting ACE combined write virtual sequence", UVM_LOW)

//     // Create the sequences
//     master_write_seq = ace_write_master_sequence::type_id::create("master_write_seq");
//     slave_write_seq = ace_write_slave_sequence::type_id::create("slave_write_seq");

//     // Start sequences in parallel using fork-join
//     fork
//       master_write_seq.start(m_ace_seqr);
//       slave_write_seq.start(m_ace_slave_seqr);
//     join

//     `uvm_info(get_type_name(), "Completed ACE combined write virtual sequence", UVM_LOW)
//   endtask : body

// endclass : ace_write_combined_vseq