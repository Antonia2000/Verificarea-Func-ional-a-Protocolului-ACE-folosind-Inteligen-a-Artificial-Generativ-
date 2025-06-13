// Define the ACE Read Monitor class
class aceread_monitor extends uvm_monitor;

`uvm_component_utils (aceread_monitor)

  // Analysis port to send transactions to other components
  uvm_analysis_port #(aceread_item) analysis_port;
  uvm_analysis_port #(aceread_item) request_port;

  // Virtual interface for the ACE Read Interface
  virtual aceread_if vif;

  // Constructor
  function new(string name = "aceread_monitor", uvm_component parent = null);
    super.new(name, parent);
    analysis_port = new("analysis_port", this);
    request_port  = new("request_port", this);
  endfunction

  // Build phase to get the virtual interface
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  // Run phase to monitor the signals and capture transactions
  task run_phase(uvm_phase phase);
    forever begin
      @(posedge vif.clk);
      capture_and_send_transaction();
    end
  endtask

  // Task to capture the address channel
  task capture_address_channel(ref aceread_item trans);
    if (vif.arvalid && vif.arready) begin
      trans.araddr   = vif.araddr;
      trans.arlen    = vif.arlen;
      trans.arsize   = vif.arsize;
      trans.arburst  = vif.arburst;
      trans.arcache  = vif.arcache;
      trans.arprot   = vif.arprot;
      trans.arqos    = vif.arqos;
      trans.arregion = vif.arregion;
      trans.arid     = vif.arid;
      trans.arsnoop  = vif.arsnoop;
      trans.ardomain = vif.aruser[1:0]; // Assuming ardomain is part of aruser
      trans.arbar    = vif.aruser[3:2];    // Assuming arbar is part of aruser
    end
  endtask

  // Task to capture the data channel
  task capture_data_channel(ref aceread_item trans);
    if (vif.rvalid && vif.rready) begin
      trans.rdata = new[trans.rdata.size() + 1](trans.rdata);
      trans.rid   = vif.rid;
      trans.rresp = vif.rresp;
    end
  endtask

  // Task to capture the snoop address channel (AC)
  task capture_snoop_address_channel(ref aceread_item trans);
    if (vif.acvalid && vif.acready) begin
      trans.acaddr  = vif.acaddr;
      trans.acsnoop = vif.acsnoop;
      trans.acprot  = vif.acprot;
    end
  endtask

  // Task to capture the snoop response channel (CR)
  task capture_snoop_response_channel(ref aceread_item trans);
    if (vif.crvalid && vif.crready) begin
      trans.crresp = vif.crresp;
    end
  endtask

  // Task to capture the snoop data channel (CD)
  task capture_snoop_data_channel(ref aceread_item trans);
    if (vif.cdvalid && vif.cdready) begin
      trans.cddata = vif.cddata;
    end
  endtask

  // Task to capture all channels and send the transaction
  task capture_and_send_transaction();
    aceread_item item;
    item = aceread_item::type_id::create("item");

    // Capture all channels
    capture_address_channel(item);
    capture_data_channel(item);
    capture_snoop_address_channel(item);
    capture_snoop_response_channel(item);
    capture_snoop_data_channel(item);

    // Send the captured transaction through the analysis port
    analysis_port.write(item);
  endtask

endclass : aceread_monitor