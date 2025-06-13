class aceread_item extends uvm_sequence_item;

  // Declare the signals needed for ACE transactions

    // Address Channel
    rand logic [31:0 ] araddr  ;    // Read address
    rand logic [1:0  ] arburst ;   // Burst type
    rand logic [3:0  ] arcache ;   // Cache type
    rand logic [3:0  ] arid    ;      // Transaction ID
    rand logic [7:0  ] arlen   ;     // Burst length
    rand logic [2:0  ] arprot  ;    // Protection type
    rand bit   [3:0  ] arqos   ;
    rand bit   [3:0  ] arsnoop ;
    rand bit   [1:0  ] ardomain;
    rand bit   [1:0  ] arbar   ;
    rand bit           arlock  ;
    rand bit   [2:0  ] arsize  ;
    rand bit   [3:0  ] arregion;
    rand bit   [8-1:0] aruser  ;

    // Data Channel
    rand bit [128 -1:0]  rdata [];          // Read data
    logic    [1     :0]  rresp;          // Read response
    rand bit [8 -1  :0]  ruser;
    rand bit [1     :0]  rid;

    // Snoop Address Channel
    rand logic [31:0] acaddr;    // Snoop address
    rand logic [1: 0] acsnoop;   // Snoop type
    rand bit [2 : 0]  acprot;

    // Snoop Data Channel
    rand logic [128-1 :0] cddata;          // Snoop data

    // Snoop Response Channel
    rand logic [4:0]  crresp;         // Snoop response

  // Constraints
  constraint data_size_c {
    arsize inside {3'b000, 3'b001, 3'b010, 3'b011, 3'b100, 3'b101, 3'b110, 3'b111};
  }

  constraint address_size_c {
    araddr inside {[32'h0000_0000:32'hFFFF_FFFF]};
  }

  constraint snoop_data_c {
    arsnoop inside {2'b00, 2'b01, 2'b10, 2'b11};
  }

  constraint address_channel_delay_c {
    arlen inside {[0:255]};
  }

  constraint response_channel_delay_c {
    rresp inside {2'b00, 2'b01, 2'b10, 2'b11};
  }

  constraint snoop_address_channel_delay_c {
    arbar inside {2'b00, 2'b01, 2'b10, 2'b11};
  }

  constraint snoop_data_channel_delay_c {
    ardomain inside {2'b00, 2'b01, 2'b10, 2'b11};
  }

  constraint snoop_response_channel_delay_c {
    arsnoop inside {2'b00, 2'b01, 2'b10, 2'b11};
  }

  // Constructor
  function new(string name = "aceread_item");
    super.new(name);
  endfunction

  // Add UVM macros to register the class with the UVM factory
  `uvm_object_utils_begin(aceread_item)
    `uvm_field_int (araddr,   UVM_DEFAULT)
    `uvm_field_int (arid,     UVM_DEFAULT)
    `uvm_field_int (arlen,    UVM_DEFAULT)
    `uvm_field_int (aruser,   UVM_DEFAULT)
    `uvm_field_int (arregion, UVM_DEFAULT)
    `uvm_field_int (arsize,   UVM_DEFAULT)
    `uvm_field_int (arburst,  UVM_DEFAULT)
    `uvm_field_int (arlock,   UVM_DEFAULT)
    `uvm_field_int (arcache,  UVM_DEFAULT)
    `uvm_field_int (arprot ,  UVM_DEFAULT)
    `uvm_field_int (arqos,    UVM_DEFAULT)
    `uvm_field_int (arsnoop,  UVM_DEFAULT)
    `uvm_field_int (ardomain, UVM_DEFAULT)
    `uvm_field_int (arbar,    UVM_DEFAULT)
  //Data channel
    `uvm_field_array_int (rdata, UVM_DEFAULT)
    `uvm_field_int (rid, UVM_DEFAULT)
    `uvm_field_int (ruser, UVM_DEFAULT)
  //Snoop address channel (AC) signals
    `uvm_field_int (acaddr,    UVM_DEFAULT)
    `uvm_field_int (acsnoop,  UVM_DEFAULT)
    `uvm_field_int (acprot,  UVM_DEFAULT)
  //Snoop response channel (CR) signals
    `uvm_field_int (crresp,  UVM_DEFAULT)
  //Snoop data channel (CD) signals
    `uvm_field_int (cddata, UVM_DEFAULT)
  `uvm_object_utils_end

endclass : aceread_item