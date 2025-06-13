interface aceread_if(
    input clk,
    input rst_n
    );

    // Address Channel
    logic [31:0] araddr;    // Read address
    logic [1:0]  arburst;   // Burst type
    logic [3:0]  arcache;   // Cache type
    logic [3:0]  arid;      // Transaction ID
    logic [7:0]  arlen;     // Burst length
    logic [2:0]  arsize  ;
    logic [3:0]  arqos   ;
    logic [3:0]  arregion;
    logic [8-1:0] aruser  ;
    logic [2:0]  arprot;    // Protection type
    logic        arvalid;   // Address valid
    logic        arready;   // Address ready
    logic        arlock  ;


    logic [3:0]  arsnoop ;
    logic [1:0]  ardomain;
    logic [1:0]  arbar   ;

    // Data Channel
    logic [128 -1:0] rdata;     // Read data
    logic [3:0]  rid;       // Read ID
    logic        rlast;     // Last transfer in burst
    logic [1:0]  rresp;     // Read response
    logic        rvalid;    // Read valid
    logic        rready;    // Read ready
    logic        rack  ;

    // Snoop Address Channel
    logic [31:0] acaddr;    // Snoop address
    logic [1:0]  acsnoop;   // Snoop type
    logic        acvalid;   // Snoop address valid
    logic        acready;   // Snoop address ready
    logic [2 : 0] acprot;

    // Snoop Data Channel
    logic [31:0] cddata;     // Snoop data
    logic        cdlast;     // Last transfer in burst
    logic        cdvalid;    // Snoop data valid
    logic        cdready;    // Snoop data ready

    // Snoop Response Channel
    logic [4:0]  crresp;    // Snoop response
    logic        crvalid;   // Snoop response valid
    logic        crready;   // Snoop response ready

endinterface : aceread_if





