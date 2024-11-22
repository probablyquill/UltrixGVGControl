# Communicating with a Ross Ultrix Router over IP using the GVG protocol
The goal of this project is to create a program that can interface with a Ross Ultrix Router over IP using the GVG protocol documented in the Ross Ultix User Guide verison 5.6.0.

The supported commands in the protocol can be found on page 312 of the User Guide.

## Formatting GVG Commands:
Resources for reference:
- [Reddit: Ross NK Router GVG Control](https://www.reddit.com/r/CommercialAV/comments/1aewx6d/ross_nk_router_gvg_control/)
- [Ross Website: GVG Controls](https://help.rossvideo.com/acuity-device/Topics/Devices/Editor/GVG100.html)
- [Ross Forums: GVG Native Protocol](https://rossvideo.community/communities/community-home/digestviewer/viewthread?GroupId=301&MID=24269&CommunityKey=43f96bed-ff4a-4d2b-8f71-d4f218c9dd77&ReturnUrl=%2Fcommunities%2Fcommunity-home%2Fdigestviewer%3FCommunityKey%3D43f96bed-ff4a-4d2b-8f71-d4f218c9dd77)
- [Ross Forums: Ultrix GVG Native Protocol Commands](https://rossvideo.community/discussion/ultrix-gvg-native-protocol-commands )
- [GVG Routing Products Protocols](https://www.grassvalley.jp/pdf/RoutingProductsProtocolManual_2.pdf)


The GVG Native Commands need to be transfered over the network via TCP, in the form of hex codes. There is a Windows only tool for sending these codes called [Hercules](https://www.hw-group.com/software/hercules-setup-utility). 

Example of what the TI command looks like, made using information in the Reddit post and Ross Forum posts:

| Hex Code | Translation / Command |
| --- | --- |
| 0x01 | SOH (start of heading) |
| 0x4E | N (protocol identification)|
| 0x30 | 0 (Sequence number, will be set to zero.) |
| 0x54 | T |
| 0x49 | I (TI = Take Index) |
| 0x09 | TAB (horizontal tab) |
| 0x30 | Hex conversion of an ascii encoding of the hex as a string (more below). |
| 0x30 | " |
| 0xXX | " |
| 0xXX | " |
| 0x09 | Horizontal tab |
| 0x30 | Hex conversion of an ascii encoding of the hex as a string (more below). |
| 0x30 | " |
| 0xXX | " |
| 0xXX | " |
| 0x34 | Checksum byte0 (character “2”) (see second note below) |
| 0x36 | Checksum byte1 (character “C”) |
| 0x04 | EOT (end of transmission) |

In other words, formatting of commands is as follows:

[soh][protocol][sequence][command][checksum][eot]

Commands in the documentation often have parameters, such as QN,IS. The "," is a horizontal tab, 0x09. Most commands do not require a trailing tab before the checksum.

### Encoding data to send:
To send a number as data over the GVG Native protocol requires undertaking several steps.
1. The number needs to be converted from decimal to hex. (e.x. 15 -> 0x0F). 
2. That hex needs to be converted to an ascii string with a length of 4. (e.x. 0x0F -> 000F). 
3. That string needs to be converted back into a hex number, which is then sent over TCP. (e.x. 000F -> 30 30 30 46). 

This needs to be done for any information being passed to a command, e.x. source and destination, and the generated checksum. Command strings (TI, QN) are passable over the protocol just by converting their characters to hex.

### Creating the checksum:
The checksum is created by summing all of the hex between 4E and the final hex parameter which will be passed to the server. After taking the sum, find the 2s compliment. That generated checksum then needs to follow the preceeding conversion to be formatted for inclusion in the TCP message.

## Commands to Implement:
The commands which need to be implemented to create a custom software panel are as follows: 

| Command | Format | Hex Code |
| --- | --- | --- | 
| Take Index | TI,dest_number,source_number | 0x54 0x49 |
| Query Name | QN,IS | 0x51 0x4E | 
| Remove Protect | UP,dest_name | 0x55 0x50 |
| Query Destination | QI,dest_index | 0x51 0x49 | 

Query Name can be given the following parameters:
- S: Source names
- D: Destination names
- IS: Name by source index.
- ID: Name by destination index.

These commands do not take any additional commands aside from the QN,S/D/IS/ID commands. (e.x.) Formatted as QN 0x09 S. The router will respond with all of the source/destination names.

GVG Native appears to interact with Ross' locking feature through the PR command. 

## Final goal for the production version of this project: 
The final goal is to create a cross-platform Flutter(? undecided) application that can be deployed to allow management of a Ross Ultrix router via TCP. The program will connect over a local connection to perform take and query operations.