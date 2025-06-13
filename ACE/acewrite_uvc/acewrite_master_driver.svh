// Define the ACE driver class
class acewrite_master_driver extends uvm_driver #(acewrite_item);

  `uvm_component_utils (acewrite_master_driver)

  // Virtual interface handle
  virtual acewrite_if vif;
  acewrite_config     m_wr_config;

  // Mailboxes for inter-task communication
  mailbox #(acewrite_item) wdata_mb;
  mailbox #(acewrite_item) resp_mb ;
  mailbox #(acewrite_item) snoop_data_mb ;

  int i = 0;

  // Constructor
  function new(string name = "acewrite_master_driver", uvm_component parent);
    super.new(name, parent);

    wdata_mb        = new();
    resp_mb         = new();
    snoop_data_mb = new();
  endfunction

  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  // Run phase
  task run_phase(uvm_phase phase);
    init();
    @(posedge vif.rst_n);
    // forever begin
    fork
      get_and_drive();
      data_handshake(); //drive data with the handshakes ass soon as the data mailbox is not empty
      resp_handshake();
      snoop_data_handshake();
    join
    // end

  endtask

 task get_and_drive();
    forever begin
      seq_item_port.get_next_item(req); //getting transaction data from TLM sequencer port
      `uvm_info ("MASTER: Getting next item...",$sformatf("get_next_item fn calling rsp"), UVM_LOW)
      $cast(rsp, req.clone()); // casting the transaction data into a clone transaction data item
      rsp.set_id_info(req); //setting the transaction/sequence id for future response compatibility
      fork
        addr_handshake(rsp);  //put the item on the addr channel
        mailbox_item(rsp);   //put the item in the mailbox after address
        snoop_addr_hsk(rsp); //put the item on the snoop addr channel
        snoop_resp_handshake(rsp);
        // snoop_resp_handshake(rsp);
        //TODO: Document display feature for debug in the project documentation
        //$display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ADDR rdy_val_dly %d",rsp.addr_rdy_val_dly);
        //$display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ADDR delay_type %s",rsp.addr_delay_type.name());
      `uvm_info ("1111111111111MASTER: Getting next item...",$sformatf("get_next_item fn calling rsp"), UVM_LOW)
      join
      `uvm_info ("1111111111111MASTER: Getting next item...",$sformatf("get_next_item fn calling rsp"), UVM_LOW)
      seq_item_port.item_done(); //all requested transaction data was successfully drived to the virtual interface that
                                 //communicates with the DUT
      `uvm_info ("222222222222MASTER: Getting next item...",$sformatf("get_next_item fn calling rsp"), UVM_LOW)
    end
  endtask: get_and_drive

  task init();
    @(posedge vif.clk);
    vif.awvalid <= 'd0;
    vif.wvalid  <= 'd0;
    vif.bready  <= 'd0;
    vif.wack    <= 'd0;
    //Snoop
    vif.crvalid <= 'd0;
    vif.cdvalid <= 'd0;
    vif.acready <= 'd0;
  endtask : init

  task send_addr(acewrite_item item);
    //AXI4WR Addr channel
    vif.awaddr   <= item.awaddr  ;
    `uvm_info ("send_addr",$sformatf("item.awaddr = %h", item.awaddr), UVM_LOW)
    vif.awid     <= item.awid    ;
    vif.awlen    <= item.awlen   ;
    vif.awsize   <= item.awsize  ;
    vif.awburst  <= item.awburst ;
    vif.awlock   <= item.awlock  ;
    vif.awcache  <= item.awcache ;
    vif.awprot   <= item.awprot  ;
    vif.awqos    <= item.awqos   ;
    vif.awregion <= item.awregion;
    vif.awuser   <= item.awuser  ;
  //ACE protocol additional signals
    vif.awdomain <= item.awdomain;
    vif.awbar    <= item.awbar   ;
    vif.awsnoop  <= item.awsnoop ;
    vif.awunique <= item.awunique;
  endtask: send_addr

  task send_data(acewrite_item item, int i);
  //AXI4WR Data channel
    // i           = item.awlen;
    vif.wdata  <= item.wdata[i];
    vif.wstrb  <= item.wstrb[i];
    vif.wuser  <= item.wuser;
    vif.wlast  <= (i == (item.wdata.size() - 1)) ? 1'b1 : 1'b0;
  endtask: send_data

  // task rcv_response(acewrite_item item);
  //   //AXI4WR Response Channel
  //   vif.bready <= 1'b1;
  // endtask: rcv_response

  task addr_handshake(acewrite_item item);
    @(posedge vif.clk);
    `uvm_info ("1111111111111addr_handshake",$sformatf("inceput"), UVM_LOW)
       `uvm_info ("data_handshake",$sformatf("item %s", item.sprint()), UVM_LOW)
    //Choosing of addr channel hsk type
    case(item.addr_hsk_type)
      VAL_BFR_RDY: begin
        //Assert valid
        `uvm_info ("2222222222222222addr_handshake",$sformatf("inainte de valid"), UVM_LOW)
        repeat(item.addr_val_rdy_dly) @(posedge vif.clk);
        vif.awvalid <= 1'b1;
        `uvm_info ("333333333333333addr_handshake",$sformatf("dupa valid"), UVM_LOW)
        //Put address channel items/information on interface bus
        send_addr(item);
        //Wait for the ready signal assertion
        `uvm_info ("44444444444444addr_handshake",$sformatf("dupa send_addr"), UVM_LOW)
        @(posedge vif.clk iff vif.awready);
        //Deassert valid if it remains asserted
        vif.awvalid <= 1'b0;
      end
      RDY_BFR_VAL: begin
        //Wait for the ready signal assertion
        @(posedge vif.clk iff vif.awready);
        repeat(item.addr_rdy_val_dly) @(posedge vif.clk);
        //Optional delay between rdy and val
        //Assert valid
        vif.awvalid <= 1'b1;
        //Put address channel items/information on interface bus
        send_addr(item);
        @(posedge vif.clk iff vif.awready);
        //Deasserting valid
        vif.awvalid <= 1'b0;
      end
      VAL_AND_RDY: begin
        //Wait for the assertion of ready signal
        @(posedge vif.clk iff vif.awready);
        //Assert valid
        vif.awvalid <= 1'b1;
        //Put address channel items/information on interface bus
        send_addr(item);
        //In case ready drops bfr valid is asserted
        @(posedge vif.clk iff vif.awready);
        vif.awvalid <= 1'b0;
      end
    endcase
    `uvm_info ("222222222222222222addr_handshake",$sformatf("final"), UVM_LOW)
  endtask: addr_handshake

  task data_handshake();
    //Choosing of data channel hsk type
    acewrite_item item;
    @(posedge vif.clk);
    forever begin
      `uvm_info ("1111111111111111111111111data_handshake",$sformatf("inceput"), UVM_LOW)
      wdata_mb.get(item);
      $display("dupa mailbox cu reponse wdata_mb.num = %h", wdata_mb.num());
      foreach(item.wdata[i]) begin
        case(item.data_hsk_type)
          VAL_BFR_RDY: begin
            //Assert valid
            repeat(item.data_val_rdy_dly) @(posedge vif.clk);
            `uvm_info ("data_handshake",$sformatf("11111111111111VAL_BFR_RDY"), UVM_LOW)
            vif.wvalid <= 1'b1;
            //Put data channel items/information on interface bus
            send_data(item, i);
            `uvm_info ("data_handshake",$sformatf("2222222222222222VAL_BFR_RDY"), UVM_LOW)
            //Wait for the ready signal assertion
            @(posedge vif.clk iff vif.wready);
            `uvm_info ("data_handshake",$sformatf("33333333333333333VAL_BFR_RDY"), UVM_LOW)
            //Deassert valid if it remains asserted
            vif.wvalid <= 1'b0;
            `uvm_info ("data_handshake",$sformatf("4444444444444444444VAL_BFR_RDY"), UVM_LOW)
          end
          RDY_BFR_VAL: begin
            //Wait for the ready signal assertion
            @(posedge vif.clk iff vif.wready);
            repeat(item.data_rdy_val_dly) @(posedge vif.clk);
            //Optional delay between rdy and val
            //Assert valid
            vif.wvalid <= 1'b1;
            //Put data channel items/information on interface bus
            send_data(item, i);
            //In case ready drops bfr valid is asserted
            @(posedge vif.clk iff vif.wready);
            //Deasserting valid
            vif.wvalid <= 1'b0;
          end
          VAL_AND_RDY: begin
            //Wait for the assertion of ready signal
            @(posedge vif.clk iff vif.wready);
            //Assert valid
            vif.wvalid <= 1'b1;
            //Put data channel items/information on interface bus
            send_data(item, i);
            //In case ready drops bfr valid is asserted
            @(posedge vif.clk iff vif.wready);
            vif.wvalid <= 1'b0;
          end
        endcase
      end
      `uvm_info ("22222222222222222222222222data_handshake",$sformatf("dupa foreach"), UVM_LOW)
    end
      `uvm_info ("3333333333333333333333333333data_handshake",$sformatf("dupa forever"), UVM_LOW)
  endtask : data_handshake

  task resp_handshake();
    acewrite_item item;
    // item = acewrite_item::type_id::create("item");
    // forever begin
      // `uvm_info ("111111111111111111111111111111111resp_handshake",$sformatf("item %s", item.sprint()), UVM_LOW)
    // forever begin
      resp_mb.get(item);
      $display("dupa mailbox cu reponse resp_mb.num = %h", resp_mb.num());
      `uvm_info ("MAster_resp_handshake",$sformatf("inceput"), UVM_LOW)
      case(item.resp_hsk_type)
        VAL_BFR_RDY: begin
          //Wait for valid signal
          `uvm_info ("MAster_resp_handshake",$sformatf("inceput"), UVM_LOW)
          @(posedge vif.clk iff vif.bvalid);
          `uvm_info ("MAster_resp_handshake",$sformatf("inceput"), UVM_LOW)
          //Assert bready after valid is asserted
          vif.bready <= 1'b1;
          `uvm_info ("MAster_resp_handshake",$sformatf("dupa vif.bready"), UVM_LOW)
          repeat(item.resp_val_rdy_dly) @(posedge vif.clk);
          @(posedge vif.clk);
          `uvm_info ("MAster_resp_handshake",$sformatf("dupa repeat"), UVM_LOW)
          //Deassert ready after receiving the response
          vif.bready <= 1'b0;
          `uvm_info ("MAster_resp_handshake",$sformatf("dupa bready 0"), UVM_LOW)
        end
        RDY_BFR_VAL: begin
          @(posedge vif.clk iff vif.wlast);
          //Assert ready signal
          vif.bready <= 1'b1;
          //Wait for valid signal assertion
          @(posedge vif.clk iff vif.bvalid);
          repeat(item.resp_rdy_val_dly) @(posedge vif.clk);
          //Deassert ready after receiving the response
          vif.bready <= 1'b0;
        end
        VAL_AND_RDY: begin
          //Assert ready signal
          vif.bready <= 1'b1;
          //Wait for valid signal assertion
          @(posedge vif.clk iff vif.bvalid);
          //Deassert ready after receiving the response
          vif.bready <= 1'b0;
        end
      endcase
      `uvm_info ("22222222222222222222222222222222resp_handshake",$sformatf("inceput"), UVM_LOW)
    // end
      `uvm_info ("3333333333333333333333333333333333resp_handshake",$sformatf("inceput"), UVM_LOW)
  endtask : resp_handshake

  //task for seding optional data for writing to MM or to other uP's caches
  task send_snoop_data(acewrite_item item);
    vif.cddata <= item.cddata;
    //vif.cdlast <= item.cddata ? 1'b1 : 1'b0;
  endtask : send_snoop_data

  task send_snoop_resp(acewrite_item item);
    vif.crresp <= item.crresp;
  endtask : send_snoop_resp

  task snoop_addr_hsk(acewrite_item item);
    forever begin
      case(item.snoop_addr_hsk_type)
        VAL_BFR_RDY: begin
            //Wait for the valid signal
            @(posedge vif.clk iff vif.acvalid);
            @(posedge vif.clk);
            //Delay between val and rdy
            repeat(item.snoop_addr_val_rdy_dly) @(posedge vif.clk);
            //Assert ready
            vif.acready <= 1'b1;
            //Master can recieve address
            @(posedge vif.clk);
            //Deassert ready
            vif.acready <= 1'b0;
        end
        RDY_BFR_VAL: begin
            //Assert ready
            vif.acready <= 1'b1;
            //Delay
            repeat(item.snoop_addr_rdy_val_dly) @(posedge vif.clk);
            //Wait for Valid Signal
            @(posedge vif.clk iff vif.acvalid);
            //Master can recieve address
            //Deassert ready
            vif.acready <= 1'b0;
        end
        VAL_AND_RDY: begin
            //Wait for valid signal
            @(posedge vif.clk iff vif.acvalid);
            //Assert ready
            vif.acready <= 1'b1;
            @(posedge vif.clk);
            //Master can recieve address
            //Deassert ready
            vif.acready <= 1'b0;
        end
      endcase
    end
  endtask : snoop_addr_hsk

  task snoop_data_handshake();
    acewrite_item item;
    //if snooped data needs to be stored to a uP cache or updated/loaded in the main memory (from the sequence | for ex. it's in a Dirty state)
    //the crresp[0] bit needs to be 'b1, and the following if else condition does that from the constraint in item
    @(posedge vif.clk);
    forever begin
    snoop_data_mb.get(item);
      if(item.en_cd_channel == 1) begin
        //Choosing of snoop data channel hsk type
        case(item.snoop_data_hsk_type)
          VAL_BFR_RDY: begin
            //Assert valid
            repeat(item.snoop_data_val_rdy_dly) @(posedge vif.clk);
            `uvm_info ("snoop_data_handshake",$sformatf("11111111111"), UVM_LOW)
            vif.cdvalid <= 1'b1;
            //Put snoop data channel items/information on interface bus
            send_snoop_data(item);
            `uvm_info ("snoop_data_handshake",$sformatf("22222222222"), UVM_LOW)
            //Wait for the ready signal assertion
            @(posedge vif.clk iff vif.cdready);
            //Deassert valid if it remains asserted
            `uvm_info ("snoop_data_handshake",$sformatf("33333333333333"), UVM_LOW)
            vif.cdvalid <= 1'b0;
          end
          RDY_BFR_VAL: begin
            //Wait for the ready signal assertion
            @(posedge vif.clk iff vif.cdready);
            repeat(item.snoop_data_rdy_val_dly) @(posedge vif.clk);
            //Optional delay between rdy and val
            //Assert valid
            vif.cdvalid <= 1'b1;
            //Put snoop data channel items/information on interface bus
            send_snoop_data(item);
            //In case ready drops bfr valid is asserted
            @(posedge vif.clk iff vif.cdready);
            //Deasserting valid
            vif.cdvalid <= 1'b0;
          end
          VAL_AND_RDY: begin
            //Wait for the assertion of ready signal
            @(posedge vif.clk iff vif.cdready);
            //Assert valid
            vif.cdvalid <= 1'b1;
            //Put snoop data channel items/information on interface bus
            send_snoop_data(item);
            //In case ready drops bfr valid is asserted
            @(posedge vif.clk iff vif.cdready);
            vif.cdvalid <= 1'b0;
          end
        endcase
      end
      else
      vif.cdvalid <= 1'b0;
    end
  endtask : snoop_data_handshake

  task snoop_resp_handshake(acewrite_item item);

    // forever begin
      case(item.snoop_resp_hsk_type)
        VAL_BFR_RDY: begin
          //Assert valid
          `uvm_info ("masterrrrrrrsnoop_resp_handshake",$sformatf("a intrat in snoop response"), UVM_LOW)
          vif.crvalid <= 1'b1;
          //Wait for ready
          send_snoop_resp(item);
          `uvm_info ("masterrrrsnoop_resp_handshake",$sformatf("vif.crready  = %h", vif.crready), UVM_LOW)
          @(posedge vif.clk iff vif.crready);
          // repeat(item.snoop_resp_val_rdy_dly) @(posedge vif.clk);
          @(posedge vif.clk);
          @(posedge vif.clk);
          `uvm_info ("masterrrrsnoop_resp_handshake",$sformatf("vif.crready  = %h", vif.crready), UVM_LOW)
          //Deassert Valid
          vif.crvalid <= 1'b0;
          `uvm_info ("masterrrrsnoop_resp_handshake",$sformatf("111111111111111vif.crvalid  = %h", vif.crvalid), UVM_LOW)
        end
        RDY_BFR_VAL: begin
          //Wait for the ready signal to be asserted
          @(posedge vif.clk iff vif.crready);
          //Delay between bready and bvalid
          repeat(item.snoop_resp_rdy_val_dly) @(posedge vif.clk);
          //Assert bvalid
          vif.crvalid <= 1'b1;
          send_snoop_resp(item);
          //Deassert valid
          vif.crvalid <= 1'b0;
        end
        VAL_AND_RDY: begin
          //Wait for the ready signal
          @(posedge vif.clk iff vif.crready);
          //Assert valid without delay and deassert it
          vif.crvalid <= 1'b1;
          send_snoop_resp(item);
          @(posedge vif.clk);
          vif.crvalid <= 1'b0;
        end
      endcase
    // end
  endtask : snoop_resp_handshake

  task mailbox_item(acewrite_item item);
    `uvm_info ("mailbox_item",$sformatf("item %s", item.sprint()), UVM_LOW)
    wdata_mb.put(item);
    resp_mb.put(item);
    snoop_data_mb.put(item);
  endtask : mailbox_item

endclass : acewrite_master_driver
