//------------------------------------------------------------------------------
// File: ace_tb.sv
// Description: Testbench environment for ACE project
//------------------------------------------------------------------------------

class ace_tb extends uvm_env;

  `uvm_component_utils(ace_tb)
  //----------------------------------------------------------------------------
  // Components
  //----------------------------------------------------------------------------

  // ACE read agent
  aceread_agent m_aceread_mst_agnt;
  aceread_agent m_aceread_slv_agnt;

  // ACE write agent
  acewrite_agent m_acewrite_mst_agnt;
  acewrite_agent m_acewrite_slv_agnt;

  // Virtual sequencer
  ace_virtual_sequencer m_aceread_vseqr;
  ace_virtual_sequencer m_acewrite_vseqr;

  // Configuration object
  aceread_config  m_read_config;
  acewrite_config m_wr_config;
  ace_proj_config m_ace_cfg;

  //----------------------------------------------------------------------------
  // UVM Factory Registration
  //----------------------------------------------------------------------------


  //----------------------------------------------------------------------------
  // Methods
  //----------------------------------------------------------------------------

  // Constructor
  function new(string name = "ace_tb", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    m_ace_cfg = new("m_ace_cfg");
    m_ace_cfg.is_active = UVM_ACTIVE;
    m_ace_cfg.build();

    // Create agents
    uvm_config_db#(aceread_config)::set(this, "m_aceread_mst_agnt*", "m_read_config", m_ace_cfg.m_aceread_mst_cfg);
    m_aceread_mst_agnt = aceread_agent::type_id::create("m_aceread_mst_agnt", this);

    uvm_config_db#(aceread_config)::set(this, "m_aceread_slv_agnt*", "m_read_config", m_ace_cfg.m_aceread_slv_cfg);
    m_aceread_slv_agnt = aceread_agent::type_id::create("m_aceread_slv_agnt", this);

    uvm_config_db#(acewrite_config)::set(this, "m_acewrite_mst_agnt*", "m_wr_config", m_ace_cfg.m_acewr_mst_cfg);
    m_acewrite_mst_agnt = acewrite_agent::type_id::create("m_acewrite_mst_agnt", this);

    uvm_config_db#(acewrite_config)::set(this, "m_acewrite_slv_agnt*", "m_wr_config", m_ace_cfg.m_acewr_slv_cfg);
    m_acewrite_slv_agnt = acewrite_agent::type_id::create("m_acewrite_slv_agnt", this);

    // Create virtual sequencer
    m_aceread_vseqr  = ace_virtual_sequencer::type_id::create("m_aceread_vseqr", this);
    m_acewrite_vseqr = ace_virtual_sequencer::type_id::create("m_acewrite_vseqr", this);

  endfunction

  // Connect phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Connect sequencers to virtual sequencer if agents are active
    m_aceread_vseqr.m_aceread_master_seqr  = m_aceread_mst_agnt.m_sequencer;
    m_aceread_vseqr.m_aceread_slave_seqr   = m_aceread_slv_agnt.m_sequencer;

    m_acewrite_vseqr.m_acewr_master_seqr  = m_acewrite_mst_agnt.m_sequencer;
    m_acewrite_vseqr.m_acewr_slave_seqr   = m_acewrite_slv_agnt.m_sequencer;


  endfunction

endclass : ace_tb