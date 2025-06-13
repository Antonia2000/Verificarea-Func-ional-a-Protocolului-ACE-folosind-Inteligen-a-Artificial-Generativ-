interface acewrite_if(
    input clk,
    input rst_n
    );

    // Address Write Channel
    logic [31:0] awaddr;    // Write address
    logic [1:0]  awid  ;
    logic [1:0]  awburst;   // Burst type
    logic [3:0]  awcache;   // Cache type
    logic [3:0]  awid;      // Transaction ID
    logic [7:0]  awlen;     // Burst length
    logic [2:0]  awprot;    // Protection type
    logic [2:0]  awsize;    // Burst size
    logic [3:0]  awqos;     // Quality of Service
    logic [3:0]  awregion;  // Region identifier
    logic [3:0]  awuser;    // User signal
    logic        awlock;    // Lock type
    logic        awvalid;   // Address valid
    logic        awready;   // Address ready

    //Ace signals
    logic [2:0]  awsnoop;   // Snoop type
    logic [1:0]  awdomain;  // Domain
    logic [1:0]  awbar;     // Barrier
    logic        awunique;  // Unique transaction

    // Data Write Channel
    logic [31:0] wdata;     // Write data
    logic        wlast;     // Last transfer in burst
    logic [3:0]  wstrb;     // Write strobes
    logic [3:0]  wuser;     // User signal
    logic        wvalid;    // Write valid
    logic        wready;    // Write ready
    logic        wack;

    // Response Channel
    logic [3:0]  bid;       // Response ID
    logic [1:0]  bresp;     // Write response
    logic [3:0]  buser;     // User signal
    logic        bvalid;    // Response valid
    logic        bready;    // Response ready

    // Snoop Address Channel
    logic [31:0] acaddr;    // Snoop address
    logic [3:0]  acsnoop;   // Snoop type
    logic [2:0]  acprot;    // Protection type
    logic        acvalid;   // Snoop address valid
    logic        acready;   // Snoop address ready

    // Snoop Data Channel
    logic [31:0] cddata;     // Snoop data
    logic        cdlast;     // Last transfer in burst
    logic        cdvalid;    // Snoop data valid
    logic        cdready;    // Snoop data ready

    // Snoop Response Channel
    logic [4:0]  crresp;    // Snoop response
    logic        crvalid;   // Snoop response valid
    logic        crready;   // Snoop response ready
endinterface : acewrite_if
