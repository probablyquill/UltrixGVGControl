# Communicating with a Ross Ultrix Router over IP using the GVG protocol
The goal of this project is to create a program that can interface with a Ross Ultrix Router over IP using the GVG protocol.

An explanation and guide to the GVG Protocol which this program implements can be found [here.](GVGPROTOCOL.md)

## Commands to Implement:
The commands which need to be implemented to create a custom software panel are as follows: 

| Command | Format | Hex Code |
| --- | --- | --- | 
| Take Index | TI,dest_number,source_number | 0x54 0x49 |
| Query Name | QN,IS | 0x51 0x4E | 
| Remove Protect by Index | UI,dest_name | 0x55 0x49 |
| Protect by Index | PI,dest_index | 0x50, 0x49 |
| Query Destination | QJ,dest_index | 0x51 0x49 | 

Note: UI and PI may be unsupported by Ultrix, needs to be tested. The only option may be to use the UP and PR commands. These commands use the destination name instead of the index.

Query Name can be given the following parameters:
- S: Source names
- D: Destination names
- IS: Name by source index.
- ID: Name by destination index.

These commands do not take any additional commands aside from the QN,S/D/IS/ID commands. (e.x.) Formatted as QN 0x09 S. The router will respond with all of the source/destination names. 

GVG Native appears to interact with Ross' locking feature through the PR and UP commands. 

## Goal for this Project:
The final goal is to create a cross-platform Flutter application that can be deployed to allow management of a Ross Ultrix router via TCP. The program will connect over a local connection to perform take and query operations.

The program needs to have a settings menu where the router size, IP address, and port can be configured, as well as the ability to generate a panel interface with the correc number of buttons. Executed commands should be confirm whether they were succesful based on the response from the switcher.  