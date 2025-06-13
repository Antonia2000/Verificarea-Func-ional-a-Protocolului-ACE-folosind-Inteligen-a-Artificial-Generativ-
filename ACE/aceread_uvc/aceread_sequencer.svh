// Define the ACE sequencer class
class aceread_sequencer extends uvm_sequencer#(aceread_item);
  // UVM Factory Registration
  `uvm_component_utils(aceread_sequencer)

  aceread_config m_read_config;

  uvm_analysis_export   #(aceread_item) request_export;
  uvm_tlm_analysis_fifo #(aceread_item) request_fifo;

  function new(string name = "aceread_sequencer", uvm_component parent);
    super.new(name, parent);
    request_export = new("request_export" , this);
    request_fifo   = new("request_fifo" , this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(aceread_config)::get(this, "", "m_read_config", m_read_config))
      `uvm_fatal("NOCONFIG", {"Config object not set for: %s", get_full_name()})
  endfunction : build_phase

endclass : aceread_sequencer

