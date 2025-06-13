class acewrite_slave_driver extends uvm_driver #(acewrite_item);

  `uvm_component_utils (acewrite_slave_driver)

  // Virtual interface for the ACE Write Interface
  virtual acewrite_if vif;
  acewrite_config    m_wr_config;
  int i;

    // Mailboxes for internal communication
  mailbox #(acewrite_item) wdata_mbox;
  mailbox #(acewrite_item) resp_mbox;
  mailbox #(acewrite_item) snoop_data_mbox;
  mailbox #(acewrite_item) snoop_resp_mbox;

  // Constructor
  function new(string name = "acewrite_slave_driver", uvm_component parent = null);
    super.new(name, parent);
    wdata_mbox      = new();
    resp_mbox       = new();
    snoop_data_mbox = new();
    snoop_resp_mbox = new();
  endfunction

  // Build phase to get the virtual interface
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

  endfunction

    // Run phase
    task run_phase(uvm_phase phase);
    acewrite_item item;
    init();
    @(posedge vif.rst_n);
    `uvm_info ("run_phase",$sformatf(" inainte de fork"), UVM_LOW)
    fork
      // Wait for data phase
      get_and_drive();
      data_handshake();
      // Wait for response phase
      resp_handshake();
      snoop_data_handshake(); //if needed (crresp[0] == 1), put information on snoop data channel
    join
    `uvm_info ("run_phase",$sformatf(" dupa fork"), UVM_LOW)
  endtask : run_phase

  task init();
    @(posedge vif.clk);
    vif.wack    <= 'd0;
  //Write
    vif.awready <= 'd0;
    vif.wready  <= 'd0;
    vif.bvalid  <= 'd0;
  //Snoop
    vif.crready <= 'd0;
    vif.cdready <= 'd0;
    vif.acvalid <= 'd0;
  endtask : init

  task get_and_drive();
    forever begin
      //Get next response item from the sequencer
      seq_item_port.get_next_item(req);
      `uvm_info ("SLAVE: Getting next item...",$sformatf("get_next_item fn calling rsp"), UVM_LOW)
      $cast(rsp, req.clone());
      rsp.set_id_info(req);
      fork
      `uvm_info ("1111111111111111111111SLAVE: Getting next item...",$sformatf("get_next_item fn calling rsp"), UVM_LOW)
        //Drive the response item
        addr_handshake(rsp);
        snoop_addr_hsk(rsp); //put the item on the snoop addr channel
        mailbox_item(rsp);
        snoop_resp_handshake(rsp);
      `uvm_info ("22222222222222222222SLAVE: Getting next item...",$sformatf("get_next_item fn calling rsp"), UVM_LOW)
      join
      //Consume the response item
      `uvm_info ("3333333333333333333SLAVE Driver",$sformatf("after item_done"), UVM_LOW)
      seq_item_port.item_done();
    end
  endtask : get_and_drive

  task addr_handshake(acewrite_item item);
    case(item.addr_hsk_type)
      VAL_BFR_RDY: begin
          //Wait for the valid signal
          `uvm_info ("addr_handshake",$sformatf("1111111111111111"), UVM_LOW)
          @(posedge vif.clk iff vif.awvalid);
          @(posedge vif.clk);
          //Delay between val and rdy
          repeat(item.addr_val_rdy_dly) @(posedge vif.clk);
          `uvm_info ("addr_handshake",$sformatf("222222222222222"), UVM_LOW)
          //Assert ready
          vif.awready <= 1'b1;
          @(posedge vif.clk);
          //Deassert ready
          vif.awready <= 1'b0;
          `uvm_info ("addr_handshake",$sformatf("33333333333333333"), UVM_LOW)
      end
      RDY_BFR_VAL: begin
          //Assert ready
          vif.awready <= 1'b1;
          //Delay
          repeat(item.addr_rdy_val_dly) @(posedge vif.clk);
          //Wait for Valid Signal
          @(posedge vif.clk iff vif.awvalid);
          //Deassert ready
          vif.awready <= 1'b0;
      end
      VAL_AND_RDY: begin
          //Wait for valid signal
          @(posedge vif.clk iff vif.awvalid);
          //Assert ready
          vif.awready <= 1'b1;
          @(posedge vif.clk);
          //Deassert ready
          vif.awready <= 1'b0;
      end
    endcase
  endtask : addr_handshake

  task data_handshake();
    acewrite_item item;
    forever begin
      wdata_mbox.get(item);
      fork
        case(item.data_hsk_type)
          VAL_BFR_RDY: forever begin
            //Wait for the ready signal
            `uvm_info ("slvaeeeeeeeeeee data_handshake",$sformatf("11111111111"), UVM_LOW)
            @(posedge vif.clk iff vif.wvalid);
            @(posedge vif.clk);
            //Delay between val and rdy
            repeat(item.data_val_rdy_dly) @(posedge vif.clk);
            //Assert ready
            `uvm_info ("slvaeeeeeeeeeee data_handshake",$sformatf("222222222222"), UVM_LOW)
            vif.wready <= 1'b1;
            @(posedge vif.clk);
            //Deassert ready
            `uvm_info ("slvaeeeeeeeeeee data_handshake",$sformatf("33333333333"), UVM_LOW)
            vif.wready <= 1'b0;
          end
          RDY_BFR_VAL: forever begin
            //Assert ready signal
            vif.wready <= 1'b1;
            //Delay
            repeat(item.data_rdy_val_dly) @(posedge vif.clk);
            //Assert valid signal
            @(posedge vif.clk iff (vif.wvalid));
            //Deassert ready
            vif.wready <= 1'b0;
          end
          VAL_AND_RDY: forever begin
            //Wait for valid signal
            @(posedge vif.clk iff vif.wvalid);
            //Assert ready
            vif.wready <= 1'b1;
            @(posedge vif.clk);
            //Deassert ready
            vif.wready <= 1'b0;
          end
        endcase
        `uvm_info ("slvaeeeeeeeeeee data_handshake",$sformatf("444444444444"), UVM_LOW)
      join_none
        `uvm_info ("slvaeeeeeeeeeee data_handshake",$sformatf("55555555555"), UVM_LOW)
      @(posedge vif.clk iff (vif.wvalid & vif.wready & vif.wlast));
        `uvm_info ("slvaeeeeeeeeeee data_handshake",$sformatf("6666666666"), UVM_LOW)
      disable fork;
        `uvm_info ("slvaeeeeeeeeeee data_handshake",$sformatf("77777777777"), UVM_LOW)
      resp_mbox.put(item);
    end
  endtask : data_handshake

  task resp_handshake();
    acewrite_item item;
    // forever begin
      resp_mbox.get(item);
      case(item.resp_hsk_type)
        VAL_BFR_RDY: begin
          //Assert valid
          // @(posedge vif.clk iff vif.wlast);
          vif.bvalid <= 1'b1;
          `uvm_info ("slaveeeeeeeeeeeresp_handshake",$sformatf(" dupa valid"), UVM_LOW)
          send_response(item);
          `uvm_info ("slaveeeeeeeeeeeresp_handshake",$sformatf(" item %s", item.sprint()), UVM_LOW)
          repeat(item.resp_val_rdy_dly) @(posedge vif.clk);
          //Wait for ready
          @(posedge vif.clk iff vif.bready);
          //Deassert Valid
          vif.bvalid <= 1'b0;
          `uvm_info ("slaveeeeeeeeeeeeeeeeeresp_handshake",$sformatf(" dupa valid"), UVM_LOW)
        end
        RDY_BFR_VAL: begin
          //Wait for the ready signal to be asserted
          @(posedge vif.clk iff vif.bready);
          //Delay between bready and bvalid
          repeat(item.resp_rdy_val_dly) @(posedge vif.clk);
          //Assert bvalid
          vif.bvalid <= 1'b1;
          send_response(item);
          //Deassert valid
          vif.bvalid <= 1'b0;
        end
        VAL_AND_RDY: begin
          //Wait for the ready signal
          @(posedge vif.clk iff vif.bready);
          //Assert valid without delay and deassert it
          vif.bvalid <= 1'b1;
          send_response(item);
          @(posedge vif.clk);
          vif.bvalid <= 1'b0;
        end
      endcase
    `uvm_info ("slaveeeeeeeeeeeresp_handshake",$sformatf(" dupa endcase"), UVM_LOW)
    // end
    `uvm_info ("slaveeeeeeeeeeresp_handshake",$sformatf(" dupa forever"), UVM_LOW)
  endtask : resp_handshake

  task send_response(acewrite_item item);
    vif.bid   <= item.bid;
    vif.bresp <= item.bresp;
    vif.buser <= item.buser;
  endtask : send_response

  task snoop_addr_hsk(acewrite_item item);
    @(posedge vif.clk);
    //Choosing of addr channel hsk type
    case(item.snoop_addr_hsk_type)
      VAL_BFR_RDY: begin
        //Assert valid
        repeat(item.snoop_addr_val_rdy_dly) @(posedge vif.clk);
        vif.acvalid <= 1'b1;
        //Send addr and other snoop addr ch information
        send_snoop_addr(item);
        //Wait for the ready signal assertion
        `uvm_info ("send_snoop_addr",$sformatf(" item.acaddr = %h", item.acaddr), UVM_LOW)
        @(posedge vif.clk iff vif.acready);
        //Deassert valid if it remains asserted
        vif.acvalid <= 1'b0;
        `uvm_info ("send_snoop_addr",$sformatf(" dupa valid"), UVM_LOW)
      end
      RDY_BFR_VAL: begin
        //Wait for the ready signal assertion
        @(posedge vif.clk iff vif.acready);
        repeat(item.snoop_addr_rdy_val_dly) @(posedge vif.clk);
        //Optional delay between rdy and val
        //Assert valid
        vif.acvalid <= 1'b1;
        //Send addr and other snoop addr ch information
        send_snoop_addr(item);
        @(posedge vif.clk iff vif.acready);
        //Deasserting valid
        vif.acvalid <= 1'b0;
      end
      VAL_AND_RDY: begin
        //Wait for the assertion of ready signal
        @(posedge vif.clk iff vif.acready);
        //Assert valid
        vif.acvalid <= 1'b1;
        //Send addr and other snoop addr ch information
        send_snoop_addr(item);
        //In case ready drops bfr valid is asserted
        @(posedge vif.clk iff vif.acready);
        vif.acvalid <= 1'b0;
      end
    endcase
  endtask: snoop_addr_hsk

  task snoop_data_handshake();
    acewrite_item item;
    `uvm_info ("snoop_data_handshake",$sformatf(" inainte valid"), UVM_LOW)
    snoop_data_mbox.get(item);
    if(item.en_cd_channel == 1) begin
        fork
          case(item.snoop_data_hsk_type)
            VAL_BFR_RDY: forever begin
              //Wait for the ready signal
              @(posedge vif.clk iff vif.cdvalid);
              @(posedge vif.clk);
              `uvm_info ("snoop_data_handshake",$sformatf(" dupa valid"), UVM_LOW)
              //Delay between val and rdy
              repeat(item.snoop_data_val_rdy_dly) @(posedge vif.clk);
              //Assert ready
              vif.cdready <= 1'b1;
              @(posedge vif.clk);
              //Deassert ready
              vif.cdready <= 1'b0;
            end
            RDY_BFR_VAL: forever begin
              //Assert ready signal
              vif.cdready <= 1'b1;
              //Delay
              repeat(item.snoop_data_rdy_val_dly) @(posedge vif.clk);
              //Assert valid signal
              @(posedge vif.clk iff (vif.cdvalid));
              //Deassert ready
              vif.cdready <= 1'b0;
            end
            VAL_AND_RDY: forever begin
              //Wait for valid signal
              @(posedge vif.clk iff vif.cdvalid);
              //Assert ready
              vif.cdready <= 1'b1;
              @(posedge vif.clk);
              //Deassert ready
              vif.cdready <= 1'b0;
            end
          endcase
        join_none
        @(posedge vif.clk iff (vif.cdvalid & vif.cdready));//& vif.cdlast));
        disable fork;
        `uvm_info ("snoop_data_handshake",$sformatf("dupa join"), UVM_LOW)
      end
    else
      vif.cdready <= 1'b0;
    `uvm_info ("snoop_data_handshake",$sformatf("dupa if"), UVM_LOW)
  endtask : snoop_data_handshake

  task snoop_resp_handshake(acewrite_item item);
    // forever begin
      // item = acewrite_item::type_id::create("item");
      $display("snoop_resp_handshake snoop_resp_mbox = %h", snoop_resp_mbox.num());
      snoop_resp_mbox.get(item);
      case(item.snoop_resp_hsk_type)
        VAL_BFR_RDY: begin
          //Wait for valid signal
          @(posedge vif.clk iff vif.crvalid);
          `uvm_info ("slaveee_snoop_resp_handshake",$sformatf("vif.crvalid = %h", vif.crvalid), UVM_LOW)
          vif.crready <= 1'b1;
          `uvm_info ("slaveee_snoop_resp_handshake",$sformatf("vif.crvalid = %h", vif.crvalid), UVM_LOW)
          `uvm_info ("slaveee_snoop_resp_handshake",$sformatf("item.snoop_resp_val_rdy_dly = %s", item.snoop_resp_val_rdy_dly), UVM_LOW)
          repeat(item.snoop_resp_val_rdy_dly) @(posedge vif.clk);
          @(posedge vif.clk);
          //Deassert ready after receiving the response
          vif.crready <= 1'b0;
          `uvm_info ("slaveee_snoop_resp_handshake",$sformatf("vif.crready = %h", vif.crready), UVM_LOW)
        end
        RDY_BFR_VAL: begin
          @(posedge vif.clk iff vif.cdlast);
          //Assert ready signal
          vif.crready <= 1'b1;
          //Wait for valid signal assertion
          @(posedge vif.clk iff vif.crvalid);
          repeat(item.snoop_resp_rdy_val_dly) @(posedge vif.clk);
          //Deassert ready after receiving the response
          vif.crready <= 1'b0;
        end
        VAL_AND_RDY: begin
          //Assert ready signal
          vif.crready <= 1'b1;
          //Wait for valid signal assertion
          @(posedge vif.clk iff vif.crvalid);
          //Deassert ready after receiving the response
          vif.crready <= 1'b0;
        end
      endcase
      `uvm_info ("snoop_resp_handshake",$sformatf("dupa endcase"), UVM_LOW)
    // end
      `uvm_info ("snoop_resp_handshake",$sformatf("dupa forever"), UVM_LOW)
  endtask : snoop_resp_handshake

  task send_snoop_addr(acewrite_item item);
    vif.acaddr  <= item.acaddr;
    vif.acsnoop <= item.acsnoop;
    vif.acprot  <= item.acprot;
  endtask : send_snoop_addr

  task mailbox_item(acewrite_item item);
    // item = acewrite_item::type_id::create("item");
    wdata_mbox.put(item);
    snoop_data_mbox.put(item);
    snoop_resp_mbox.put(item);
  endtask : mailbox_item


endclass : acewrite_slave_driver