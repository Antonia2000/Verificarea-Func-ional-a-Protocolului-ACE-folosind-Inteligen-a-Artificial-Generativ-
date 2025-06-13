//------------------------------------------------------------------------------
// File: acewrite_config.sv
// Description: Configuration class for AMBA ACE protocol verification components
//------------------------------------------------------------------------------

class acewrite_config extends uvm_object;

  //----------------------------------------------------------------------------
  // Configuration Fields
  //----------------------------------------------------------------------------

  // Agent type (master or slave)
  acewrite_agent_type agent_type = MASTER;

  // UVC operation mode (using standard UVM active/passive enum)
  uvm_active_passive_enum is_active = UVM_ACTIVE;

  // Virtual interface handle
  virtual acewrite_if vif;

  //----------------------------------------------------------------------------
  // UVM Factory Registration
  //----------------------------------------------------------------------------

  // Register class and fields with UVM factory
  `uvm_object_utils_begin(acewrite_config)
    `uvm_field_enum(uvm_active_passive_enum, is_active,  UVM_DEFAULT)
    `uvm_field_enum(acewrite_agent_type,     agent_type, UVM_DEFAULT)
  `uvm_object_utils_end


  // Constructor
  function new(string name = "acewrite_config");
    super.new(name);
  endfunction


endclass : acewrite_config