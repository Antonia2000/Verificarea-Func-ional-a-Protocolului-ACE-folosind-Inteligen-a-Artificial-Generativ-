//------------------------------------------------------------------------------
// File: ace_proj_config.sv
// Description: Top-level configuration for ACE project
//------------------------------------------------------------------------------

class ace_proj_config extends uvm_object;

  //----------------------------------------------------------------------------
  // Sub-configurations
  //----------------------------------------------------------------------------

  // ACE read configuration
  aceread_config m_aceread_mst_cfg;
  aceread_config m_aceread_slv_cfg;

  // ACE write configuration
  acewrite_config m_acewr_mst_cfg;
  acewrite_config m_acewr_slv_cfg;

  uvm_active_passive_enum is_active    = UVM_ACTIVE;
  bit                     has_checks   = 1;
  bit                     has_coverage = 1;

  virtual aceread_if  rd_vif;
  virtual acewrite_if wr_vif;

  `uvm_object_utils_begin(ace_proj_config)
    `uvm_field_int(                          has_checks,   UVM_DEFAULT)
    `uvm_field_int(                          has_coverage, UVM_DEFAULT)
    `uvm_field_enum(uvm_active_passive_enum, is_active,    UVM_DEFAULT)
  `uvm_object_utils_end


  //----------------------------------------------------------------------------
  // Methods
  //----------------------------------------------------------------------------

  // Constructor
  function new(string name = "ace_proj_config");
    super.new(name);
  endfunction


  function void build();
    m_aceread_mst_cfg = new("m_aceread_mst_cfg");
    m_aceread_slv_cfg = new("m_aceread_slv_cfg");
    m_acewr_mst_cfg   = new("m_acewr_mst_cfg");
    m_acewr_slv_cfg   = new("m_acewr_slv_cfg");
    if(is_active == UVM_ACTIVE) begin
      //ACE Read
      m_aceread_mst_cfg.is_active  = UVM_ACTIVE;
      m_aceread_mst_cfg.agent_type = aceread_pkg::MASTER;
      m_aceread_slv_cfg.is_active  = UVM_ACTIVE;
      m_aceread_slv_cfg.agent_type = aceread_pkg::SLAVE;
      //ACE Write
      m_acewr_mst_cfg.is_active   = UVM_ACTIVE;
      m_acewr_mst_cfg.agent_type  = acewrite_pkg::MASTER;
      m_acewr_slv_cfg.is_active   = UVM_ACTIVE;
      m_acewr_slv_cfg.agent_type  = acewrite_pkg::SLAVE;
    end
    else begin
      m_aceread_mst_cfg.is_active  = UVM_PASSIVE;
      m_aceread_slv_cfg.is_active  = UVM_PASSIVE;
      m_acewr_mst_cfg.is_active    = UVM_PASSIVE;
      m_acewr_slv_cfg.is_active    = UVM_PASSIVE;
    end
  endfunction : build

endclass : ace_proj_config