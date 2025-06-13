


# UVM Driver Development Guidelines

## General Requirements

In developing a UVM driver, there are two distinct categories of requirements to consider:

1. General requirements applicable to any UVM driver class
2. Specific requirements tailored to each individual project

### General Requirements Overview

- Extend the `uvm_driver` class
- Implement standard UVM phases
- Use essential UVM macros

### Specific Requirements Overview

- Reflect the unique nature and particular needs of the system under verification
- Examples include:
  - ACE channel structure
  - Handshake protocols
  - Driver's role as a slave for ACE READ transactions

This combination of general and specific requirements ensures that the resulting driver is both compliant with UVM standards and adapted to current project requirements.

## Detailed General Requirements for Driver

- Define the driver class, extending it from `uvm_driver` with appropriate parameterization using the provided item class
- Include essential UVM macros, especially `uvm_component_utils`, for correct factory registration
- Implement standard UVM phases, focusing on `build_phase` and `run_phase`
- During `build_phase`, establish proper connectivity with the sequencer and virtual interface
- Use clear and consistent naming conventions throughout your code

## Detailed Specific Requirements for Driver

- Develop separate tasks for each ACE channel:
  - Read Address
  - Read Data
  - Snoop Address
  - Snoop Data
  - Snoop Response
- Call these tasks within the `run_phase` to manage different aspects of the ACE protocol
- Implement valid-ready handshakes for each channel to ensure proper synchronization with the slave interface, a key component in ACE transactions:
  -there are 3 cases for the handshake: Valid before ready, Valid after ready, Valid and Ready
- Implement mailboxes to facilitate efficient data transfer between tasks, improving the driver's internal communication


| Channel                    | Signal   | Width  | Description             |
|--------------------------- |--------  |--------|-------------------------|
| **Address Write Channel**  | awaddr   | [31:0] | Write address           |
|                            | awid     | [3:0]  | Transaction ID          |
|                            | awburst  | [1:0]  | Burst type              |
|                            | awcache  | [3:0]  | Cache type              |
|                            | awlen    | [7:0]  | Burst length            |
|                            | awprot   | [2:0]  | Protection type         |
|                            | awsize   | [2:0]  | Burst size              |
|                            | awqos    | [3:0]  | Quality of Service      |
|                            | awregion | [3:0]  | Region identifier       |
|                            | awuser   | [3:0]  | User signal             |
|                            | awlock   |        | Lock type               |
|                            | awvalid  |        | Address valid           |
|                            | awready  |        | Address ready           |
| **ACE Extensions**         | awsnoop  | [2:0]  | Snoop type              |
|                            | awdomain | [1:0]  | Domain                  |
|                            | awbar    | [1:0]  | Barrier                 |
|                            | awunique |        | Unique transaction      |
| **Data Write Channel**     | wdata    | [31:0] | Write data              |
|                            | wlast    | |        Last transfer in burst  |
|                            | wstrb    | [3:0]  | Write strobes           |
|                            | wuser    | [3:0]  | User signal             |
|                            | wvalid   | |        Write valid             |
|                            | wready   | |        Write ready             |
|                            | wack     | |        Write acknowledge       |
| **Response Channel**       | bid      | [3:0]  | Response ID             |
|                            | bresp    | [1:0]  | Write response          |
|                            | buser    | [3:0]  | User signal             |
|                            | bvalid   | |        Response valid          |
|                            | bready   | |        Response ready          |
| **Snoop Address Channel**  | acaddr   | [31:0] | Snoop address           |
|                            | acsnoop  | [1:0]  | Snoop type              |
|                            | acprot   | [2:0]  | Protection type         |
|                            | acvalid  | |        Snoop address valid     |
|                            | acready  | |        Snoop address ready     |
| **Snoop Data Channel**     | cddata   | [31:0] | Snoop data              |
|                            | cdlast   | |        Last transfer in burst  |
|                            | cdvalid  | |        Snoop data valid        |
|                            | cdready  | |        Snoop data ready        |
| **Snoop Response Channel** | crresp   | [4:0]  | Snoop response          |
|                            | crvalid  | |        Snoop response valid    |
|                            | crready  | |        Snoop response ready    |