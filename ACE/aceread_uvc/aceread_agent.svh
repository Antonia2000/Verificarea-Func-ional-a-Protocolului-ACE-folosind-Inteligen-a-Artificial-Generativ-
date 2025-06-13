class aceread_agent extends uvm_agent;

  `uvm_component_utils (aceread_agent)

  // Declare the driver, monitor, and sequencer
  aceread_master_driver m_master_driver;
  aceread_slave_driver  m_slave_driver;
  aceread_monitor       m_monitor;
  aceread_sequencer     m_sequencer;
  aceread_config        m_read_config;

  // Constructor
  function new(string name = "aceread_agent", uvm_component parent);
    super.new(name, parent);
  endfunction

  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Check if the agent is active or passive
    if (!uvm_config_db#(aceread_config)::get(this, "", "m_read_config", m_read_config))
      `uvm_fatal("NOCONFIG", {"Config object not set for: %s", get_full_name()})

    if(!uvm_config_db #(virtual aceread_if)::get(this, "" , "aceread_if" , m_read_config.vif))
    `uvm_fatal (get_type_name() , "Didn't get handle to virtual interface vif")

    m_monitor     = aceread_monitor::type_id::create("monitor", this);
    m_monitor.vif = m_read_config.vif;

    // Instantiate the driver and sequencer only if the agent is active
    if (m_read_config.is_active == UVM_ACTIVE) begin
      if(m_read_config.agent_type == MASTER) begin
        m_master_driver     = aceread_master_driver::type_id::create("m_master_driver", this);
        m_sequencer         = aceread_sequencer::type_id::create("m_sequencer", this);
        m_master_driver.vif = m_read_config.vif;
      end
      else begin
        m_slave_driver      = aceread_slave_driver::type_id::create("m_slave_driver", this);
        m_sequencer         = aceread_sequencer::type_id::create("m_sequencer", this);
        m_slave_driver.vif  = m_read_config.vif;
      end
    end

  endfunction : build_phase

  // Connect phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Connect the sequencer to the driver if the agent is active
    if (m_read_config.is_active == UVM_ACTIVE)
      if(m_read_config.agent_type == MASTER)
        m_master_driver.seq_item_port.connect(m_sequencer.seq_item_export);
      else
        m_slave_driver.seq_item_port.connect(m_sequencer.seq_item_export);

    // // Connect the monitor to the analysis port
    m_monitor.analysis_port.connect(m_sequencer.request_export);
    m_sequencer.request_export.connect(m_sequencer.request_fifo.analysis_export);
  endfunction

endclass : aceread_agent