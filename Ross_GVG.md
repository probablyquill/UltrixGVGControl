# Communicating with a Ross Ultrix Router over IP using the GVG protocol
The goal of this project is to create a program that can interface with a Ross Ultrix Router over IP using the GVG protocol documented in the Ross Ultix User Guide verison 5.6.0.

The protocol can be found on page 312 of the User Guide.

## Formatting GVG Commands:
Resources for reference:
- [Reddit: Ross NK Router GVG Control](https://www.reddit.com/r/CommercialAV/comments/1aewx6d/ross_nk_router_gvg_control/)
- [Ross Website: GVG Controls](https://help.rossvideo.com/acuity-device/Topics/Devices/Editor/GVG100.html)
- [Ross Forums: GVG Native Protocol](https://rossvideo.community/communities/community-home/digestviewer/viewthread?GroupId=301&MID=24269&CommunityKey=43f96bed-ff4a-4d2b-8f71-d4f218c9dd77&ReturnUrl=%2Fcommunities%2Fcommunity-home%2Fdigestviewer%3FCommunityKey%3D43f96bed-ff4a-4d2b-8f71-d4f218c9dd77)
- [Ross Forums: Contd](https://rossvideo.community/discussion/ultrix-gvg-native-protocol-commands )


The GVG Native Commands need to be transfered over the network via TCP, in the form of hex codes. There is a windows only tool for sending these codes called [Hercules](https://www.hw-group.com/software/hercules-setup-utility). 

The following is made using information in the Reddit and Ross Forums post:

| Hex Code | Translation / Command |
| --- | --- |
| 0x01 | SOH (start of heading) |
| 0x4E | N (protocol identification)|
| 0x30 | 0 (Sequence number, will be set to zero.) |
| 0x54 | T |
| 0x49 | I (Take Index) |
| 0x09 | TAB (horizontal tab) | 
| 0x30 | 0 <- Destination (“0016” sent as four hex numbers, ) |
| 0x30 | 0 |
| 0x30 | 0 |
| 0x46 | 16 |
| 09 | Horizontal tab |
| 0x30 | 0 <- Source (selects source “0013”, sent as 4 hex numbers). |
| 0x30 | 0 |
| 0x30 | 0 |
| 0x43 | 13 |
| 0x34 | Checksum byte0 (character “2”) (see note below) |
| 0x36 | Checksum byte1 (character “C”) (see note below) |
| 0x04 | EOT (end of transmission) |

The hex numbers to be sent for data (source, dest, and checksum) start at 0x30, and are added to from there.

A checksum calculator will need to created and implemented to generate the checksum based on the values from 4E to the last source Hex code.

## Commands to Implement:
The commands which need to be implemented to create a custom software panel are as follows: 

| Command | Hex Code | 
| --- | --- |
| Take Index (TI) | 0x54 0x49 |
| Query Name (QN) | 0x51 0x4E | 

Query Name can be given the following parameters:
- S: Source names
- D: Destination names
- IS: Name by source index.
- ID: Name by destination index.

GVG Native does not appear to have a way to interface with Ross' locking system. It is presently unclear if that means it cannot interact with locked sources / destinations, or if it will override the lock to execute its command.

## Final goal for the production version of this project: 
I'd like it to be packagable as an application, however for our use case it would also make sense for it to be a webpage accesible over our SD-WAN. Regardless it will need to start as a command line application, so I'll probably start with a python script and work my way up from there.