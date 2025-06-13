class acewrite_agent extends uvm_agent;

  `uvm_component_utils (acewrite_agent)

  // Declare the driver, monitor, and sequencer
  acewrite_master_driver m_master_driver;
  acewrite_slave_driver  m_slave_driver;
  acewrite_monitor       m_monitor;
  acewrite_sequencer     m_sequencer;
  acewrite_config        m_wr_config;

  // Constructor
  function new(string name = "acewrite_agent", uvm_component parent);
    super.new(name, parent);
  endfunction

  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Check if the agent is active or passive
    if (!uvm_config_db#(acewrite_config)::get(this, "", "m_wr_config", m_wr_config))
      `uvm_fatal("NOCONFIG", {"Config object not set for: %s", get_full_name()})

    if(!uvm_config_db #(virtual acewrite_if)::get(this, "" , "acewrite_if" , m_wr_config.vif))
    `uvm_fatal (get_type_name() , "Didn't get handle to virtual interface vif")

    m_monitor = acewrite_monitor::type_id::create("m_monitor", this);
    m_monitor.vif = m_wr_config.vif;

    // Instantiate the driver and sequencer only if the agent is active
    if (m_wr_config.is_active == UVM_ACTIVE) begin
      if(m_wr_config.agent_type == MASTER) begin
        m_master_driver     = acewrite_master_driver::type_id::create("m_master_driver", this);
        m_sequencer         = acewrite_sequencer::type_id::create("m_sequencer", this);
        m_master_driver.vif = m_wr_config.vif;
      end
      else begin
        m_slave_driver      = acewrite_slave_driver::type_id::create("m_slave_driver", this);
        m_sequencer         = acewrite_sequencer::type_id::create("m_sequencer", this);
        m_slave_driver.vif  = m_wr_config.vif;
      end
    end

  endfunction : build_phase

  // Connect phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Connect the sequencer to the driver if the agent is active
    if (m_wr_config.is_active == UVM_ACTIVE)
      if(m_wr_config.agent_type == MASTER)
        m_master_driver.seq_item_port.connect(m_sequencer.seq_item_export);
      else
        m_slave_driver.seq_item_port.connect(m_sequencer.seq_item_export);

    // Connect the monitor to the analysis port
    m_monitor.mon_request_port.connect(m_sequencer.request_export);
    m_sequencer.request_export.connect(m_sequencer.request_fifo.analysis_export);
  endfunction

endclass : acewrite_agent