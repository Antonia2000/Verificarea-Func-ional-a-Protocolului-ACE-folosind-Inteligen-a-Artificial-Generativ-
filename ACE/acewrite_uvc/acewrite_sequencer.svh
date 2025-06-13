class acewrite_sequencer extends uvm_sequencer #(acewrite_item);
  `uvm_component_utils(acewrite_sequencer)

  acewrite_config m_wr_config;

  uvm_analysis_export #(acewrite_item) request_export;
  uvm_tlm_analysis_fifo #(acewrite_item) request_fifo;

  function new(string name = "acewrite_sequencer", uvm_component parent);
    super.new(name, parent);
    request_export = new("request_export" , this);
    request_fifo   = new("request_fifo" , this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(acewrite_config)::get(this, "", "m_wr_config", m_wr_config))
      `uvm_fatal("NOCONFIG", {"Config object not set for: %s", get_full_name()})
  endfunction : build_phase

endclass : acewrite_sequencer
