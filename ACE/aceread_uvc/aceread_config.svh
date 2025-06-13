//------------------------------------------------------------------------------
// File: aceread_config.sv
// Description: Configuration class for AMBA ACE protocol verification components
//------------------------------------------------------------------------------

class aceread_config extends uvm_object;

  //----------------------------------------------------------------------------
  // Configuration Fields
  //----------------------------------------------------------------------------
  // UVC operation mode (using standard UVM active/passive enum)
  uvm_active_passive_enum is_active = UVM_ACTIVE;

  // Agent type (master or slave)
  aceread_agent_type agent_type = MASTER;


  // Virtual interface handle
  virtual aceread_if vif;

  //----------------------------------------------------------------------------
  // UVM Factory Registration
  //----------------------------------------------------------------------------

  // Register class and fields with UVM factory
  `uvm_object_utils_begin(aceread_config)
    `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_DEFAULT)
    `uvm_field_enum(aceread_agent_type, agent_type,     UVM_DEFAULT)
  `uvm_object_utils_end


  // Constructor
  function new(string name = "aceread_config");
    super.new(name);
  endfunction


endclass : aceread_config