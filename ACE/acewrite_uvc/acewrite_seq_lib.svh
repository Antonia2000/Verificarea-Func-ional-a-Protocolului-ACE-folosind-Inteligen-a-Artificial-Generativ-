class acewrite_base_sequence extends uvm_sequence;

  `uvm_declare_p_sequencer(acewrite_sequencer)

  acewrite_item item;
  acewrite_item item_t;
  int trans_no = 2;
  logic [31:0] awaddr;
  logic [31:0] acaddr;

  // Constructor
  function new(string name = "acewrite_base_sequence");
    super.new(name);
    // item = acewrite_item::type_id::create("item");
  endfunction

endclass : acewrite_base_sequence

class ace_write_master_sequence extends acewrite_base_sequence;

  `uvm_object_utils (ace_write_master_sequence)

  // Constructor
  function new(string name = "ace_write_master_sequence");
    super.new(name);
  endfunction

  // Body task
  virtual task body();
    `uvm_info(get_type_name(), "Starting write sequence", UVM_LOW)

      // Randomize the sequence item with inline constraints
      start_item(item);
      if (!item.randomize() with {
        // Ensure address alignment
        awaddr % (1 << awsize) == 0;

        // Ensure valid ranges for ACE-specific fields
        awsnoop  inside {3'b000, 3'b001, 3'b010, 3'b011};
        awdomain inside {2'b00, 2'b01, 2'b10, 2'b11};
        awbar    inside {2'b00, 2'b01, 2'b10, 2'b11};
        awunique inside {1'b0, 1'b1};
        // Randomize all other fields
        awburst  inside {2'b00, 2'b01, 2'b10, 2'b11};
        awcache  inside {4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101, 4'b0110, 4'b0111, 4'b1000, 4'b1001, 4'b1010, 4'b1011, 4'b1100, 4'b1101, 4'b1110, 4'b1111};
        awid     inside {[4'b0000:4'b1111]};
        awlen    inside {[8'b00000000:8'b11111111]};
        awprot   inside {3'b000, 3'b001, 3'b010, 3'b011, 3'b100, 3'b101, 3'b110, 3'b111};
        awsize   inside {3'b000, 3'b001, 3'b010, 3'b011, 3'b100, 3'b101, 3'b110, 3'b111};
        awqos    inside {4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101, 4'b0110, 4'b0111, 4'b1000, 4'b1001, 4'b1010, 4'b1011, 4'b1100, 4'b1101, 4'b1110, 4'b1111};
        awregion inside {4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101, 4'b0110, 4'b0111, 4'b1000, 4'b1001, 4'b1010, 4'b1011, 4'b1100, 4'b1101, 4'b1110, 4'b1111};
        awuser   inside {4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101, 4'b0110, 4'b0111, 4'b1000, 4'b1001, 4'b1010, 4'b1011, 4'b1100, 4'b1101, 4'b1110, 4'b1111};
        awlock   inside {1'b0, 1'b1};
        wuser    inside {[8'b00000000:8'b11111111]};
        bid      inside {2'b00, 2'b01, 2'b10, 2'b11};
        bresp    inside {8'b00000000, 8'b00000001, 8'b00000010, 8'b00000011, 8'b00000100, 8'b00000101, 8'b00000110, 8'b00000111};
        buser    inside {2'b00, 2'b01, 2'b10, 2'b11};
        acaddr   inside {[32'h0000_0000:32'hFFFF_FFFF]};
        acsnoop  inside {2'b00, 2'b01, 2'b10, 2'b11};
        acprot   inside {3'b000, 3'b001, 3'b010, 3'b011, 3'b100, 3'b101, 3'b110, 3'b111};
        cddata   inside {[128'b0:128'b1]};
        crresp   inside {5'b00000, 5'b00001, 5'b00010, 5'b00011, 5'b00100, 5'b00101, 5'b00110, 5'b00111, 5'b01000, 5'b01001, 5'b01010, 5'b01011, 5'b01100, 5'b01101, 5'b01110, 5'b01111,
                       5'b10000, 5'b10001, 5'b10010, 5'b10011, 5'b10100, 5'b10101, 5'b10110, 5'b10111, 5'b11000, 5'b11001, 5'b11010, 5'b11011, 5'b11100, 5'b11101, 5'b11110, 5'b11111};
      }) begin
        `uvm_error("RANDOMIZE_FAIL", "Failed to randomize acewrite_item")
      end

      finish_item(item);
    `uvm_info(get_type_name(), "Completed write sequence", UVM_LOW)
  endtask : body

endclass : ace_write_master_sequence

class acewrite_writeunique_seq extends acewrite_base_sequence;

  `uvm_object_utils(acewrite_writeunique_seq)

  function new(string name = "acewrite_writeunique_seq");
    super.new(name);
  endfunction

  virtual task body();
    item_t = acewrite_item::type_id::create("item_t");
    `uvm_info(get_type_name(), "Master Starting WriteUnique sequence", UVM_LOW)
    repeat(trans_no) begin
    // Start transaction (sequencer arbitration point)
      start_item(item_t);
      `uvm_info ("acewrite_writeunique_seq",$sformatf("awaddr = %h", awaddr), UVM_LOW)
      item_t.awaddr = awaddr;
      `uvm_info ("acewrite_writeunique_seq",$sformatf("item_t.awaddr = %h", awaddr), UVM_LOW)

      if (!item_t.randomize() with {
      // Write Address Channel
        // awaddr   inside {[32'h0000_0000:32'hFFFF_FFFF]};
        awburst  ==     2'd1;// INCR
        awcache  ==     4'd0;
        awid     ==     1'd0 ;
        awlen    inside {[0:5]};
        awprot   ==     3'd2 ; // b010(Data access,non-secure access,unprivileged)
        awsize   ==     3'd3 ; // 16 bytes transfer-0b100
        awqos    ==     4'd0 ;
        awregion ==     4'd0 ;
        awuser   ==     8'd0 ;
        awlock   ==     1'd0 ;

        // ACE-specific
        awsnoop  == 3'b000;     // CleanUnique (WriteUnique)
        awdomain == 2'b10;      // b10 - Inner Shareable
        awbar    == 2'b00;      // awbar[0] = 0 - No Barrier

        // Data Write Channel
        // wuser inside {[0:255]};

        // Delay Types
        addr_val_rdy_dly       == B2B;
        addr_rdy_val_dly       == B2B;
        data_val_rdy_dly       == B2B;
        data_rdy_val_dly       == B2B;
        resp_val_rdy_dly       == B2B;
        resp_rdy_val_dly       == B2B;
        snoop_addr_val_rdy_dly == B2B;
        snoop_addr_rdy_val_dly == B2B;
        snoop_data_val_rdy_dly == B2B;
        snoop_data_rdy_val_dly == B2B;
        snoop_resp_val_rdy_dly == B2B;
        snoop_resp_rdy_val_dly == B2B;

        // Handshake Types
        addr_hsk_type         == VAL_BFR_RDY;
        data_hsk_type         == VAL_BFR_RDY;
        resp_hsk_type         == VAL_BFR_RDY;
        snoop_addr_hsk_type   == VAL_BFR_RDY;
        snoop_resp_hsk_type   == VAL_AND_RDY;
        snoop_data_hsk_type   == RDY_BFR_VAL;
        //Channels delay
        addr_delay_type       == B2B;
        data_delay_type       == B2B;
        resp_delay_type       == B2B;
        snoop_addr_delay_type == B2B;
        snoop_data_delay_type == B2B;
        snoop_resp_delay_type == B2B;

                                   }) //giving values to axi4wr signals
          `uvm_error(get_type_name(), "Rand error!")

        item_t.crresp        = 5'd1;
        item_t.en_cd_channel = 1'd1;
    `uvm_info(get_type_name(), $sformatf("11111111WriteUnique transaction randomized:\n%s", item_t.sprint()), UVM_LOW)
       finish_item(item_t); //all data is on transaction item
    end

    `uvm_info(get_type_name(), $sformatf("11111111WriteUnique transaction randomized:\n%s", item_t.sprint()), UVM_LOW)
  endtask

endclass : acewrite_writeunique_seq

class acewrite_completer_seq extends acewrite_base_sequence;

  `uvm_object_utils(acewrite_completer_seq)


  function new(string name = "acewrite_completer_seq");
    super.new(name);
  endfunction

  virtual task body();

    acewrite_item slave_item;
    acewrite_item item;
    slave_item = acewrite_item::type_id::create("slave_item");
    `uvm_info(get_type_name(), "Slave Starting ACE Completer sequence for WriteUnique", UVM_LOW)
    forever begin
      $cast(item, slave_item.clone());
      start_item(item);
        item.acaddr = acaddr;
        item.bid    = 'd0;
        item.buser  = 'd0;
        item.bresp  = 'd0;

        item.acsnoop = 'b1001;
        item.acprot  = 'd0;
      //Channels handshakes between valid and ready
        item.addr_hsk_type       = VAL_AND_RDY;
        item.data_hsk_type       = VAL_AND_RDY;
        item.resp_hsk_type       = VAL_AND_RDY;
        item.snoop_addr_hsk_type = VAL_BFR_RDY;
        item.snoop_resp_hsk_type = VAL_BFR_RDY;
        item.snoop_data_hsk_type = RDY_BFR_VAL;
      //Channels delay
        item.addr_delay_type       = B2B;
        item.data_delay_type       = B2B;
        item.resp_delay_type       = B2B;
        item.snoop_addr_delay_type = B2B;
        item.snoop_data_delay_type = B2B;
        item.snoop_resp_delay_type = B2B;

        item.addr_val_rdy_dly       = B2B;
        item.addr_rdy_val_dly       = B2B;
        item.data_val_rdy_dly       = B2B;
        item.data_rdy_val_dly       = B2B;
        item.resp_val_rdy_dly       = B2B;
        item.resp_rdy_val_dly       = B2B;
        item.snoop_addr_val_rdy_dly = B2B;
        item.snoop_addr_rdy_val_dly = B2B;
        item.snoop_data_val_rdy_dly = B2B;
        item.snoop_data_rdy_val_dly = B2B;
        item.snoop_resp_val_rdy_dly = B2B;
        item.snoop_resp_rdy_val_dly = B2B;

      //Enable/Disable Data Channel CRRESP[0] = 1 Enable Snoop Ch / CRRESP[0] = 0 Disable Snoop Ch

       item.en_cd_channel = 1'd1;
       item.crresp        = 5'd1;
      //  item.acaddr        = acaddr;
      `uvm_info(get_type_name(), $sformatf("Completer sent Write response:\n%s, acaddr = %h", item.sprint(), acaddr), UVM_LOW)
      finish_item(item);
      p_sequencer.request_fifo.get(item);
    end

    `uvm_info(get_type_name(), $sformatf("Completer sent Write response:\n%s", item.sprint()), UVM_LOW)
  endtask

endclass : acewrite_completer_seq

class ace_write_slave_sequence extends acewrite_base_sequence;

  `uvm_object_utils (ace_write_slave_sequence)

  // Constructor
  function new(string name = "ace_write_slave_sequence");
    super.new(name);
  endfunction

  // Body task
  virtual task body();
    `uvm_info(get_type_name(), "Starting ACE Write Slave Sequence", UVM_LOW)

    // start_item(item_write);
    // if (!item_write.randomize() with {
    //   awaddr   inside {[32'h0000_0000:32'hFFFF_FFFF]};
    //   awlen    inside {[0:255]};
    //   awsize   inside {3'b000, 3'b001, 3'b010, 3'b011, 3'b100, 3'b101, 3'b110, 3'b111};
    //   awburst  inside {2'b00, 2'b01, 2'b10, 2'b11};
    //   awcache  inside {4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101, 4'b0110, 4'b0111, 4'b1000, 4'b1001, 4'b1010, 4'b1011, 4'b1100, 4'b1101, 4'b1110, 4'b1111};
    //   awprot   inside {3'b000, 3'b001, 3'b010, 3'b011, 3'b100, 3'b101, 3'b110, 3'b111};
    //   awqos    inside {4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101, 4'b0110, 4'b0111, 4'b1000, 4'b1001, 4'b1010, 4'b1011, 4'b1100, 4'b1101, 4'b1110, 4'b1111};
    //   awregion inside {4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101, 4'b0110, 4'b0111, 4'b1000, 4'b1001, 4'b1010, 4'b1011, 4'b1100, 4'b1101, 4'b1110, 4'b1111};
    //   awsnoop  inside {2'b00, 2'b01, 2'b10, 2'b11};
    //   awdomain inside {2'b00, 2'b01, 2'b10, 2'b11};
    //   awbar    inside {2'b00, 2'b01, 2'b10, 2'b11};
    //   wdata    inside {[32'h0000_0000:32'hFFFF_FFFF]};
    //   wstrb    inside {4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101, 4'b0110, 4'b0111, 4'b1000, 4'b1001, 4'b1010, 4'b1011, 4'b1100, 4'b1101, 4'b1110, 4'b1111};
    //   bresp    inside {2'b00, 2'b01, 2'b10, 2'b11};
    //   bid      inside {4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101, 4'b0110, 4'b0111, 4'b1000, 4'b1001, 4'b1010, 4'b1011, 4'b1100, 4'b1101, 4'b1110, 4'b1111};
    // }) begin
    //   `uvm_error(get_type_name(), "Randomization failed")
    // end
    // finish_item(item_write);

    `uvm_info(get_type_name(), "Completed ACE Write Slave Sequence", UVM_LOW)
  endtask : body

endclass : ace_write_slave_sequence