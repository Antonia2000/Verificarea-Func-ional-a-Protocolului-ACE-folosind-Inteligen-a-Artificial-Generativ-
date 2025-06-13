// Define the ACE Read Driver class
class aceread_slave_driver extends uvm_driver #(aceread_item);

  `uvm_component_utils (aceread_slave_driver)

  aceread_config m_read_config;

  // Virtual interface for the ACE Read Interface
  virtual aceread_if vif;
    // Mailboxes for each channel
  mailbox #(aceread_item) ar_mb;
  mailbox #(aceread_item) r_mb;
  mailbox #(aceread_item) ac_mb;
  mailbox #(aceread_item) cd_mb;
  mailbox #(aceread_item) cr_mb;

  // Constructor
  function new(string name = "aceread_slave_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Build phase to get the virtual interface
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ar_mb = new();
    r_mb = new();
    ac_mb = new();
    cd_mb = new();
    cr_mb = new();
  endfunction

  // Run phase: Process and drive transactions
  task run_phase(uvm_phase phase);
    fork
      process_read_address_channel();
      process_read_data_channel();
      process_snoop_address_channel();
      process_snoop_data_channel();
      process_snoop_response_channel();
    join
  endtask

  // Task to handle Read Address Channel
  task process_read_address_channel();
    aceread_item item;
    forever begin
      ar_mb.get(item); // Get transaction from mailbox
      vif.araddr   <= item.araddr;
      vif.arburst  <= item.arburst;
      vif.arcache  <= item.arcache;
      vif.arid     <= item.arid;
      vif.arlen    <= item.arlen;
      vif.arsize   <= item.arsize;
      vif.arqos    <= item.arqos;
      vif.arregion <= item.arregion;
      vif.aruser   <= item.aruser;
      vif.arprot   <= item.arprot;
      vif.arlock   <= item.arlock;
      vif.arsnoop  <= item.arsnoop;
      vif.ardomain <= item.ardomain;
      vif.arbar    <= item.arbar;
      vif.arvalid  <= 1'b1;

      // Wait for ready signal
      @(posedge vif.arready);
      vif.arvalid <= 1'b0;
    end
  endtask

  // Task to handle Read Data Channel
  task process_read_data_channel();
    aceread_item item;
    forever begin
      r_mb.get(item); // Get transaction from mailbox
      vif.rdata  <= item.rdata[1];
      vif.rid    <= item.rid;
      vif.rresp  <= item.rresp;
      vif.rvalid <= 1'b1;

      // Wait for ready signal
      @(posedge vif.rready);
      vif.rvalid <= 1'b0;
    end
  endtask

  // Task to handle Snoop Address Channel
  task process_snoop_address_channel();
    aceread_item item;
    forever begin
      ac_mb.get(item); // Get transaction from mailbox
      vif.acaddr  <= item.acaddr;
      vif.acsnoop <= item.acsnoop;
      vif.acprot  <= item.acprot;
      vif.acvalid <= 1'b1;

      // Wait for ready signal
      @(posedge vif.acready);
      vif.acvalid <= 1'b0;
    end
  endtask

  // Task to handle Snoop Data Channel
  task process_snoop_data_channel();
    aceread_item item;
    forever begin
      cd_mb.get(item); // Get transaction from mailbox
      vif.cddata  <= item.cddata;
      vif.cdvalid <= 1'b1;

      // Wait for ready signal
      @(posedge vif.cdready);
      vif.cdvalid <= 1'b0;
    end
  endtask

  // Task to handle Snoop Response Channel
  task process_snoop_response_channel();
    aceread_item item;
    forever begin
      cr_mb.get(item); // Get transaction from mailbox
      vif.crresp  <= item.crresp;
      vif.crvalid <= 1'b1;

      // Wait for ready signal
      @(posedge vif.crready);
      vif.crvalid <= 1'b0;
    end
  endtask

endclass : aceread_slave_driver