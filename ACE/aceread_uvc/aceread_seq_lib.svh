class aceread_base_sequence extends uvm_sequence;

  `uvm_object_utils (aceread_base_sequence)

  `uvm_declare_p_sequencer(aceread_sequencer)

  aceread_item read_item;

  // Constructor
  function new(string name = "aceread_base_sequence");
    super.new(name);
    read_item = aceread_item::type_id::create("read_item");
  endfunction

endclass : aceread_base_sequence

// Define the read transaction sequence class
class ace_read_sequence extends aceread_base_sequence;

  `uvm_object_utils (ace_read_sequence)

  // Constructor
  function new(string name = "ace_read_sequence");
    super.new(name);
  endfunction

  // Body task
  virtual task body();
    `uvm_info(get_type_name(), "Starting read sequence", UVM_LOW)

    start_item(read_item);
    if (!read_item.randomize() with {
      araddr    inside {[32'h0000_0000:32'hFFFF_FFFF]};
      arlen     inside {[0:255]};
      arsize    inside {3'b000, 3'b001, 3'b010, 3'b011, 3'b100, 3'b101, 3'b110, 3'b111};
      arburst   inside {2'b00, 2'b01, 2'b10, 2'b11};
      arcache   inside {4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101, 4'b0110, 4'b0111, 4'b1000, 4'b1001, 4'b1010, 4'b1011, 4'b1100, 4'b1101, 4'b1110, 4'b1111};
      arprot    inside {3'b000, 3'b001, 3'b010, 3'b011, 3'b100, 3'b101, 3'b110, 3'b111};
      arqos     inside {4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101, 4'b0110, 4'b0111, 4'b1000, 4'b1001, 4'b1010, 4'b1011, 4'b1100, 4'b1101, 4'b1110, 4'b1111};
      arregion  inside {4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101, 4'b0110, 4'b0111, 4'b1000, 4'b1001, 4'b1010, 4'b1011, 4'b1100, 4'b1101, 4'b1110, 4'b1111};
      arid      inside {4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101, 4'b0110, 4'b0111, 4'b1000, 4'b1001, 4'b1010, 4'b1011, 4'b1100, 4'b1101, 4'b1110, 4'b1111};
      arsnoop   inside {2'b00, 2'b01, 2'b10, 2'b11};
      ardomain  inside {2'b00, 2'b01, 2'b10, 2'b11};
      arbar     inside {2'b00, 2'b01, 2'b10, 2'b11};
    }) begin
      `uvm_error(get_type_name(), "Randomization failed")
    end
    finish_item(read_item);
    `uvm_info(get_type_name(), "Completed read sequence", UVM_LOW)
  endtask : body

endclass : ace_read_sequence

// Define the sequence class
class ace_read_slave_seq extends aceread_base_sequence;

  `uvm_object_utils (ace_read_slave_seq)

  // Constructor
  function new(string name = "ace_read_slave_seq");
    super.new(name);
  endfunction

  // Sequence body
  virtual task body();

    // Start the sequence
    start_item(read_item);
    if (!read_item.randomize() with {
      arsize   inside {3'b000, 3'b001, 3'b010, 3'b011, 3'b100, 3'b101, 3'b110, 3'b111};
      araddr   inside {[32'h0000_0000:32'hFFFF_FFFF]};
      arsnoop  inside {2'b00, 2'b01, 2'b10, 2'b11};
      arlen    inside {[0:255]};
      rresp    inside {2'b00, 2'b01, 2'b10, 2'b11};
      arbar    inside {2'b00, 2'b01, 2'b10, 2'b11};
      ardomain inside {2'b00, 2'b01, 2'b10, 2'b11};
      arburst  inside {2'b00, 2'b01, 2'b10, 2'b11};
      arcache  inside {4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101, 4'b0110, 4'b0111, 4'b1000, 4'b1001, 4'b1010, 4'b1011, 4'b1100, 4'b1101, 4'b1110, 4'b1111};
      arprot   inside {3'b000, 3'b001, 3'b010, 3'b011, 3'b100, 3'b101, 3'b110, 3'b111};
      arqos    inside {4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101, 4'b0110, 4'b0111, 4'b1000, 4'b1001, 4'b1010, 4'b1011, 4'b1100, 4'b1101, 4'b1110, 4'b1111};
      arlock   inside {1'b0, 1'b1};
      arregion inside {4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101, 4'b0110, 4'b0111, 4'b1000, 4'b1001, 4'b1010, 4'b1011, 4'b1100, 4'b1101, 4'b1110, 4'b1111};
      aruser   inside {[0:255]};
      acaddr   inside {[32'h0000_0000:32'hFFFF_FFFF]};
      acsnoop  inside {2'b00, 2'b01, 2'b10, 2'b11};
    });
    else
      `uvm_error(get_type_name(), "Randomization failed")
    finish_item(read_item);

  endtask: body

endclass: ace_read_slave_seq