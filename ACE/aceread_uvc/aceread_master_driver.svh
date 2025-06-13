// Define the ACE driver class
class aceread_master_driver extends uvm_driver #(aceread_item);

  `uvm_component_utils (aceread_master_driver)

  // Virtual interface handle
  aceread_config m_read_config;
  virtual aceread_if vif;
  aceread_item item;

   // Mailboxes for internal communication
  mailbox #(aceread_item) addr_mb;
  mailbox #(aceread_item) data_mb;
  mailbox #(aceread_item) snoop_addr_mb;
  mailbox #(aceread_item) snoop_data_mb;
  mailbox #(aceread_item) snoop_resp_mb;

  // Constructor
  function new(string name = "aceread_master_driver", uvm_component parent);
    super.new(name, parent);
  endfunction

  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Create mailboxes
    addr_mb       = new();
    data_mb       = new();
    snoop_addr_mb = new();
    snoop_data_mb = new();
    snoop_resp_mb = new();

  endfunction


  // Run phase
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    fork
      drive_read_address();
      drive_read_data();
      drive_snoop_address();
      drive_snoop_data();
      drive_snoop_response();
    join

    phase.drop_objection(this);
  endtask

  // Task to drive Read Address Channel
  task drive_read_address();

    forever begin
      addr_mb.get(item);
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
      vif.arvalid  <= 1'b1;
      wait(vif.arready);
      vif.arvalid <= 1'b0;
    end
  endtask

  // Task to drive Read Data Channel
  task drive_read_data();
    forever begin
      data_mb.get(item);
      vif.rdata  <= item.rdata[1];
      vif.rid    <= item.rid;
      vif.rresp  <= item.rresp;
      vif.rvalid <= 1'b1;
      wait(vif.rready);
      vif.rvalid <= 1'b0;
    end
  endtask

  // Task to drive Snoop Address Channel
  task drive_snoop_address();
    forever begin
      snoop_addr_mb.get(item);
      vif.acaddr  <= item.acaddr;
      vif.acsnoop <= item.acsnoop;
      vif.acprot  <= item.acprot;
      vif.acvalid <= 1'b1;
      wait(vif.acready);
      vif.acvalid <= 1'b0;
    end
  endtask

  // Task to drive Snoop Data Channel
  task drive_snoop_data();
    aceread_item item;
    forever begin
      snoop_data_mb.get(item);
      vif.cddata  <= item.cddata;
      vif.cdvalid <= 1'b1;
      wait(vif.cdready);
      vif.cdvalid <= 1'b0;
    end
  endtask

  // Task to drive Snoop Response Channel
  task drive_snoop_response();
    forever begin
      snoop_resp_mb.get(item);
      vif.crresp  <= item.crresp;
      vif.crvalid <= 1'b1;
      wait(vif.crready);
      vif.crvalid <= 1'b0;
    end
  endtask

endclass : aceread_master_driver
