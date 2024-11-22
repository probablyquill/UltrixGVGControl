# Communicating with a Ross Ultrix Router over IP using the GVG protocol
The goal of this project is to create a program that can interface with a Ross Ultrix Router over IP using the GVG protocol.

## Formatting GVG Commands:
Resources for reference:
- [Reddit: Ross NK Router GVG Control](https://www.reddit.com/r/CommercialAV/comments/1aewx6d/ross_nk_router_gvg_control/)
- [Ross Website: GVG Controls](https://help.rossvideo.com/acuity-device/Topics/Devices/Editor/GVG100.html)
- [Ross Forums: GVG Native Protocol](https://rossvideo.community/communities/community-home/digestviewer/viewthread?GroupId=301&MID=24269&CommunityKey=43f96bed-ff4a-4d2b-8f71-d4f218c9dd77&ReturnUrl=%2Fcommunities%2Fcommunity-home%2Fdigestviewer%3FCommunityKey%3D43f96bed-ff4a-4d2b-8f71-d4f218c9dd77)
- [Ross Forums: Ultrix GVG Native Protocol Commands](https://rossvideo.community/discussion/ultrix-gvg-native-protocol-commands )
- [GVG Routing Products Protocols](https://www.grassvalley.jp/pdf/RoutingProductsProtocolManual_2.pdf)
- [Ultrix and Ultricore Database Guide](https://documentation.rossvideo.com/files/Manuals/Routers/Ultrix/Ultrix%20and%20Ultricore%20Database%20Guide.pdf)
- [Ultrix User Guide](https://documentation.rossvideo.com/files/Manuals/Routers/Ultrix/Ultrix%20User%20Guide%20(2101DR-004).pdf)


The GVG Native Commands need to be transfered over the network via TCP, in the form of hex codes. There is a Windows only tool for sending these codes called [Hercules](https://www.hw-group.com/software/hercules-setup-utility). Communication can also be done by sending the hex data over a normal TCP socket in a language such as Python.

The command structure is as follows:

| Hex Code | Translation / Command |
| --- | --- |
| 0x01 | SOH (start of heading) |
| 0x4E | N (protocol identification)|
| 0x30 | 0 (Sequence number, will be set to zero.) |
| [0x??-0x??] | Command with arguments if applicable. |
| 0x?? | Checksum byte0 (see notes below) |
| 0x?? | Checksum byte1 |
| 0x04 | EOT (end of transmission) |

In other words, a command will be a collection of hex using the following information:

[soh][protocol][sequence][command][checksum][eot]

Commands in the documentation often have parameters, such as QN,IS. The "," is a horizontal tab, 0x09. Most commands do not require a trailing tab before the checksum. The protocol requirements and instructions are covered in [GVG Routing Products Protocols](https://www.grassvalley.jp/pdf/RoutingProductsProtocolManual_2.pdf). It is worth noting that Ross does not implement every command included in the GVG protocol, so not everything listed by GVG will work with an Ultrix Router.

### Encoding numerical data to send:
To send a number as data over the GVG Native protocol requires undertaking several steps.
1. The number needs to be converted from decimal to hex. (e.x. 15 -> 0x0F). 
2. That hex needs to be converted to an ascii string with a length of 4. (e.x. 0x0F -> 000F). 
3. That string needs to be converted back into a hex number, which is then sent over TCP. (e.x. 000F -> 30 30 30 46). 

This needs to be done for any information being passed to a command, e.x. source and destination, and the generated checksum. The checksum then needs to be trimmed down to remove leading 0x30s. Command strings (TI, QN) and string parameters are passable over the protocol just by converting their characters to hex.

### Creating the checksum:
The checksum is created by summing all of the hex between 4E and the final hex parameter which will be passed to the server. After taking the sum, find the 2s compliment. That generated checksum then needs to follow the preceeding encoding to be formatted for inclusion in the TCP message. This is covered with more detail on page 27 of the [GVG Routing Products Protocols](https://www.grassvalley.jp/pdf/RoutingProductsProtocolManual_2.pdf)

### Example Commands:

| Command Type: | Command | soh | protocol | sequence | command | checksum | eot | 
| --- | --- | --- | --- | --- | --- | --- | --- |
| Query Destinations | QN,S | 0x01 | 0x4E | 0x30 | 0x51 0x4E 0x09 0x30 0x44 | 0x36 0x36 | 0x04 |
| Take 132, 100 | TI,dest,src | 0x01 | 0x4E | 0x30 | 0x54 0x49 0x09 0x30 0x30 0x38 0x33 0x09 0x30 0x30 0x30 0x39 | 0x33 0x66 | 0x04 |


## Commands to Implement:
The commands which need to be implemented to create a custom software panel are as follows: 

| Command | Format | Hex Code |
| --- | --- | --- | 
| Take Index | TI,dest_number,source_number | 0x54 0x49 |
| Query Name | QN,IS | 0x51 0x4E | 
| Remove Protect by Index | UI,dest_name | 0x55 0x49 |
| Protect by Index | PI,dest_index | 0x50, 0x49 |
| Query Destination | QI,dest_index | 0x51 0x49 | 

Note: UI and PI may be unsupported by Ultrix, needs to be tested. The only option may be to use the UP and PR commands. These commands use the destination name instead of the index.

Query Name can be given the following parameters:
- S: Source names
- D: Destination names
- IS: Name by source index.
- ID: Name by destination index.

These commands do not take any additional commands aside from the QN,S/D/IS/ID commands. (e.x.) Formatted as QN 0x09 S. The router will respond with all of the source/destination names.

GVG Native appears to interact with Ross' locking feature through the PR and UP commands. 

## Goal for this Project:
The final goal is to create a cross-platform Flutter(? undecided) application that can be deployed to allow management of a Ross Ultrix router via TCP. The program will connect over a local connection to perform take and query operations.