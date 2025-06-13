//------------------------------------------------------------------------------
// File: ace_virtual_sequencer.sv
// Description: Virtual sequencer for ACE project
//------------------------------------------------------------------------------

class ace_virtual_sequencer extends uvm_sequencer;

  //----------------------------------------------------------------------------
  // Sub-sequencers
  //----------------------------------------------------------------------------
  `uvm_component_utils(ace_virtual_sequencer)

  acewrite_config        m_wr_config;

  // ACE read sequencer
  aceread_sequencer m_aceread_master_seqr;
  aceread_sequencer m_aceread_slave_seqr;

  // ACE write sequencer
  acewrite_sequencer m_acewr_master_seqr;
  acewrite_sequencer m_acewr_slave_seqr;

  // Configuration object
  ace_proj_config cfg;

  //----------------------------------------------------------------------------
  // UVM Factory Registration
  //----------------------------------------------------------------------------


  //----------------------------------------------------------------------------
  // Methods
  //----------------------------------------------------------------------------

  // Constructor
  function new(string name = "ace_virtual_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

endclass : ace_virtual_sequencer