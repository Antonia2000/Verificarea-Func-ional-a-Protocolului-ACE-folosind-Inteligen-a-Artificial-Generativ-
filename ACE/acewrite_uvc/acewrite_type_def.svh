//----------------------------------------------------------------------------
// Agent Types
//----------------------------------------------------------------------------

// Enum to specify agent type (master or slave)
typedef enum {
  MASTER,
  SLAVE
} acewrite_agent_type;

//----------------------------------------------------------------------------
// Handshake Types
//----------------------------------------------------------------------------

// Enum to define different handshake behaviors between valid and ready signals
// All types assume valid is asserted first (valid-before-ready protocol)
typedef enum {VAL_BFR_RDY, RDY_BFR_VAL, VAL_AND_RDY} acewrite_handshake_type;

//----------------------------------------------------------------------------
// Delay Configuration
//----------------------------------------------------------------------------

// Enum to define back-to-back transaction behavior
typedef enum {B2B, SHORT, MEDIUM, LONG } acewrite_delay_type;