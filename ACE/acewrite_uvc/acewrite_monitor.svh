class acewrite_monitor extends uvm_monitor;

  `uvm_component_utils (acewrite_monitor)

  acewrite_item item;

  // Interface handle
  virtual acewrite_if vif;
  int i = 0;

  // Mailboxes for communication between channels
  mailbox #(acewrite_item) m_req_snoop_addr_mb;

  virtual acewr_if vif; //declaration of virtual interface

  uvm_analysis_port #(acewrite_item) analysis_port; //data analysis port input for monitor
  uvm_analysis_port #(acewrite_item) mon_request_port; // partial data request analysis port for monitor

  function new (string name = "acewrite_monitor" , uvm_component parent = null);
    super.new(name, parent);
  endfunction: new

  virtual function void build_phase (uvm_phase phase);
    super.build_phase (phase);
    //Creation of declared analysis port
    analysis_port       = new ("analysis_port", this);
    mon_request_port    = new ("mon_request_port", this);
    m_req_snoop_addr_mb = new(); //m = monitor
  endfunction: build_phase


  virtual task run_phase(uvm_phase phase);
    item = acewrite_item::type_id::create("item",this);
    item.wdata  = new [1];
    item.wstrb  = new [1];
    `uvm_info ("run_phase monitor",$sformatf("inainte de fork"), UVM_LOW)
    // fork
    forever begin
       collect_req_snoop_addr();
       collect_items();
    end
    // join
    `uvm_info ("run_phase monitor",$sformatf("dupa fork"), UVM_LOW)
  endtask : run_phase

  task collect_items();
    fork
      retrieve_snoop_addr_from_mb(item);
      collect_addr(item);
      collect_data(item);
      collect_response(item);
    join
    `uvm_info ("collect_items",$sformatf("dupa join"), UVM_LOW)
    //collect_req_snoop_addr();
    //retrieve_snoop_addr_from_mb(item);
    //collect_snoop_resp(item);
    //collect_snoop_data(item);
    //$display("================================================================");
    //$display("%s", item.sprint());
    //$display("================================================================");
    `uvm_info ("collect_items",$sformatf("inainte de write"), UVM_LOW)
    analysis_port.write(item);
    `uvm_info ("collect_items",$sformatf("dupa write"), UVM_LOW)
  endtask : collect_items

  task collect_addr(ref acewrite_item item);
    acewrite_item addr_item;
    // mon_request_port.write(item);
    @(posedge vif.clk iff (vif.awvalid));
    item.awaddr   = vif.awaddr;
    `uvm_info ("collect_addr",$sformatf("11item.awaddr = %h", item.awaddr), UVM_LOW)
    item.awid     = vif.awid;
    item.awlen    = vif.awlen;
    item.awuser   = vif.awuser;
    item.awregion = vif.awregion;
    item.awsize   = vif.awsize;
    item.awburst  = vif.awburst;
    item.awlock   = vif.awlock;
    item.awcache  = vif.awcache;
    item.awprot   = vif.awprot;
    item.awqos    = vif.awqos;
    item.awsnoop  = vif.awsnoop;
    item.awdomain = vif.awdomain;
    item.awbar    = vif.awbar;
    item.awunique = vif.awunique;
    $cast(addr_item, item.clone());
    mon_request_port.write(addr_item);
    // @(posedge vif.clk iff (vif.awready & vif.awvalid));
  endtask : collect_addr

  task collect_data(ref acewrite_item item);
    `uvm_info ("collect_data",$sformatf("inainte de posedge"), UVM_LOW)
    @(posedge vif.clk iff (vif.wvalid & vif.wready));
      item.wuser = vif.wuser;
      repeat(vif.awlen + 1)
      `uvm_info ("collect_data",$sformatf("repeat"), UVM_LOW)
      item.wdata = new[item.wdata.size() + 1](item.wdata);
      item.wstrb = new[item.wstrb.size() + 1](item.wstrb);
      @(posedge vif.clk iff ~vif.wlast)
      `uvm_info ("collect_data",$sformatf("dupa ~wlast"), UVM_LOW)
      //if(~vif.wlast) begin
      item.wdata    = new [item.wdata.size() - 1](item.wdata);
      item.wdata[i] = vif.wdata;
      item.wstrb    = new [item.wstrb.size() - 1](item.wstrb);
      item.wstrb[i] = vif.wstrb;
    `uvm_info ("collect_data",$sformatf("final"), UVM_LOW)
      //end
  endtask : collect_data

  task collect_response(ref acewrite_item item);
    `uvm_info ("collect_response",$sformatf("inainte de posedge"), UVM_LOW)
    // @(posedge vif.clk iff (vif.bvalid & vif.bready));
    @(posedge vif.clk iff (vif.bvalid));
    `uvm_info ("collect_response",$sformatf("dupa posedge"), UVM_LOW)
    item.bid   = vif.bid;
    item.buser = vif.buser;
    item.bresp = vif.bresp;
    `uvm_info ("collect_response",$sformatf("1111111111dupa posedge"), UVM_LOW)
  endtask : collect_response

  task collect_req_snoop_addr();
    acewrite_item wr_snoop_addr_item;
    wr_snoop_addr_item = acewrite_item::type_id::create("wr_snoop_addr_item",this);
    `uvm_info ("collect_req_snoop_addr",$sformatf("inainde valid si ready"), UVM_LOW)
    // @(posedge vif.clk iff (vif.acvalid & vif.acready));
    @(posedge vif.clk iff (vif.acvalid ));
    `uvm_info ("collect_req_snoop_addr",$sformatf("dupa valid si ready"), UVM_LOW)
    wr_snoop_addr_item.acaddr  = vif.acaddr;
    wr_snoop_addr_item.acsnoop = vif.acsnoop;
    wr_snoop_addr_item.acprot  = vif.acprot;
    //$cast(snoop_addr_item, item.clone());
    // mon_request_port.write(wr_snoop_addr_item);
    m_req_snoop_addr_mb.put(wr_snoop_addr_item);
    `uvm_info ("collect_req_snoop_addr",$sformatf("final"), UVM_LOW)
  endtask : collect_req_snoop_addr

  task retrieve_snoop_addr_from_mb(ref acewrite_item item);
    acewrite_item snoop_addr_item;
    $cast(snoop_addr_item, item.clone());
    m_req_snoop_addr_mb.get(snoop_addr_item);
    `uvm_info ("retrieve_snoop_addr_from_mb",$sformatf("11111111"), UVM_LOW)
    item.acaddr  = snoop_addr_item.acaddr;
    item.acsnoop = snoop_addr_item.acsnoop;
    item.acprot  = snoop_addr_item.acprot;
    // mon_request_port.write(item);
  endtask : retrieve_snoop_addr_from_mb

  task collect_snoop_data(ref acewrite_item item);
    `uvm_info ("collect_snoop_data",$sformatf("inainde valid si ready"), UVM_LOW)
    @(posedge vif.clk iff (vif.cdvalid & vif.cdready));
    `uvm_info ("collect_snoop_data",$sformatf("dupa valid si ready"), UVM_LOW)
    item.cddata = vif.cddata;
  endtask : collect_snoop_data

  task collect_snoop_resp(ref acewrite_item item);
    `uvm_info ("collect_snoop_resp",$sformatf("11111111"), UVM_LOW)
    item.crresp = vif.crresp;
    `uvm_info ("collect_snoop_resp",$sformatf("11111111 vif.crresp = %h", vif.crresp), UVM_LOW)
  endtask : collect_snoop_resp

endclass : acewrite_monitor