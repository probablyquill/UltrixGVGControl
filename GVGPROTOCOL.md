# Using GVG to Communicate with a Ross Router over TCP
Ross provides various different protocols which can be used to control their routers over a TCP/IP connection. I'm going to give a brief overview of these protocols, and the reasons to use them. 

The protocols are:

**RossTalk**
A text-based protocol that sends simple text commands over TCP/IP. This protocol is very easy to use, however it is not very powerful compared to the alternatives as there are only a handful of commands. A massive drawback to using RossTalk is that the router does not send a response based on the command it recieved, so there is no confirmation from the system that a Take or Salvo operation was sucessful. 

**ogScript**
The protocol supported by Ross' Dashboard software, as well as any custom panels which are written for their other products such an [Ultritouch Panel](https://www.rossvideo.com/control-systems/routing-control/ultritouch/). These custom panels are written using XML, JavaScript, and the ogScript framework that Ross includes. This protocol is incredibly powerful, however as far as I can tell it is only possible to run applications using ogScript inside of the Ross Dashboard application, or on Ross' hardware.

**GVG**
A TCP/IP or Serial protocol that provides a much wider suite of options than the RossTalk protocol, while not being locked to Dashboard. Unlike RossTalk it is able to receive responses to its commands, which allows for things such as querying source or destination names, and receiving error or confirmation codes after a command is run.

## RossTalk vs GVG vs ogScript
While RossTalk functions, and is able to execute Take commands, I am hesitant to consider it a reliable solution for writing a piece of software that is intended to operate as a control surface. On top of the lack of responses to commands, it also does not allow for querying of source and destination names, nor is it able to check crosspoints to see what is directed at a specific output. 

RossTalk is an excellent option for very simple automation tasks or a simple control platform, however the lack of features makes it less reliable than its alternatives. It is by far the easiest protocol to get working as commands for it can be made and sent in a matter of seconds due to it being a plain text protocol.

ogScript is an incredibly powerful option, however it is locked to the Dashboard platform, which means that there is no way to run any panel without also running Dashboard on the system. I have had reliability issues with Dashboard on the ARM Macs I often use for work, which has soured my relationship with the software.

This leaves us with GVG, which has a feature set more comparable to ogScript, however it is a rather obnoxious protocol to implement due to how it is written. ogScript is heavily implemented into Dashboard— while that locks it to Dashboard, it also increases its ease of use. There were also just more ogScript resources on the Ross forums than for GVG. In comparison to ogScript, GVG is a hex-based TCP/IP protocol. While ogScript lets you just fire off commands, GVG requires to to build a command and generate its checksum before it can be sent to the router.

## Using the GVG Protocol
My biggest headache when working with the GVG Protocol was a lack of examples of it being implemented into code. I will be giving examples using Python for convenience, but this can very easily be integrated into any programming or scripting language that supports IP communication. 

The GVG Protocol is built out of several pieces which are combined to send a single TCP/IP command to the Router.

A command sent in the GVG Protocol is structured as follows:
| Hex Code | Translation / Command |
| --- | --- |
| 0x01 | SOH (start of heading) |
| 0x4E | N (protocol identification)|
| 0x30 | 0 (Sequence number, will be set to zero.) |
| 0x??-0x?? | Command with arguments if applicable. |
| 0x??, 0x?? | Checksum |
| 0x04 | EOT (end of transmission) |

Or, written in a single line:

[soh][protocol][sequence][command][checksum][eot]

### Understanding GVG Commands

GVG Provides reference documentation for their protocol in [GVG Routing Products Protocols](https://www.grassvalley.jp/pdf/RoutingProductsProtocolManual_2.pdf). This document has a lot of information and details on the protocol, however when implementing commands, it is important to note that Ross only supports the commands listed in the [Ultrix User Guide](https://documentation.rossvideo.com/files/Manuals/Routers/Ultrix/Ultrix%20User%20Guide%20(2101DR-004).pdf).

GVG operations are formatted as [operation],[data] where the "," is a Horizontal Tab signified by the hex code 0x09. The operation is translated directly to hex using the ascii characters.

Examples:
| Command Type: | Command  | Operation Hex | 
| --- | --- | --- |
| Query Names, Destinations | QN,D | 0x51 0x4E 0x09 0x44 |
| Query Names, Sources | QN,S | 0x51 0x4E 0x09 0x53 |
| Take | TI,dest,src | 0x54 0x49 0x09 dest 0x09 source | 

Calculating numerical values to use for sources and destinations is rather involved and is discussed in the next section.


### Encoding Numerical Data
To include numerical data into a command, such as for specifying source or destination parameters, a couple of steps must be taken. 
1. The number needs to be converted from decimal to hex. 
    - 15 -> 0x0F
2. That hex needs to be converted to an ascii string with a length of 4.
    - 0x0F -> 000F
3. That string needs to be converted back into a hex number, which can then be included in the command that will be sent over TCP/IP. 
    - 000F -> 30 30 30 46

Python conversion function example:
```python
def number_to_hex(input: int) -> str:
    # Converts the input from an integer to a hex string
    # Int 15 = "0x0f"
    output = hex(input)

    # Trim the hex string and switch it to uppercase.
    # "0x0f" -> "0F"
    output = output.split('x')[-1].upper()

    # Extend the string until it has a length of four.
    # "0F" -> "000F"
    while (len(output) < 4):
        output = "0" + output
    
    # Change the output variable to be encoded in ascii.
    output = output.encode('ascii')
    # Change the output from ASCII to Hex
    # "000F" -> "30303046"
    output = output.hex()
    i = 0
    return_string = ""

    #Format the string
    # "30303046" -> "30 30 30 46 "
    while i < len(output):
        return_string += output[i]
        if(i % 2 != 0): return_string += " "
        i += 1

    return return_string
```
Number conversion examples:

15 -> 30 30 30 36

140 -> 30 30 38 43 

47 -> 30 30 32 46 

38 -> 30 30 32 36 

The protocol requires leading zeroes per the [Ross Forums](https://rossvideo.community/discussion/ultrix-gvg-native-protocol-commands) for sources and destinations, hence the hex number being padded to four digits. Any numbers being sent to the system need to be converted to ASCII, then to hex, as the GVG Protocol reads all incoming data as ASCII transmitted as hex. This includes the checksum, which is discussed below.
### Generating a Checksum
After the command has been made, the checksum needs to be generated. The checksum is made using the following segment of the command:

[protocol][sequence][command]

If a checksum is malformed or improperly generated, then the system will return an error and no operation will be taken. Because of this it is important to check your checksum and make sure that you're not accidentally feeding it the start of header (soh) as it is not supposed to be included.

The checksum is generated as followed:
```python
def get_checksum(hex_data):
    # This function is assuming that the hex data is being given in the following format:
    # "30 30 30 36 " <- there is a trailing space here from how the number was generated. 
    # If there is no trailing zero, then the loop summing the hex data needs to be adjusted accordingly.
    i = 0
    total = 0

    # Splits the hex string into an array using the spaces.
    # "30 30 30 36 " -> ["30","30","30",36",""]
    hex_data = hex_data.split(' ')
    
    # Iterates through the array and converts the string back into a decimal number, then adds that to the total sum.
    # 30 -> 48, 36 -> 54
    while i < len(hex_data) - 1:
        data = int(hex_data[i], 16)
        total += data
        i += 1
    # i = 48 + 48 + 48 + 54 = 198

    # Prevent overflow past max hex bit.
    # No value over FF (255) is allowed and will be truncated.
    total = total & 0xFF
    # total = 198 & 255 = 198

    # Take the two bit two's compliment.
    twos_complement = (0x100 - total) & 0xFF
    # 0x100 = 256 -> 256 - 198 = 58 -> 58 & 255 = 58
    # The twos complement is 58.
    return twos_complement
```
More information on the checksum and its generation can be found in the [GVG Routing Products Protocols](https://www.grassvalley.jp/pdf/RoutingProductsProtocolManual_2.pdf) document.


### Sending a Command
With all of that in mind, lets create a Take command to route input 100 to destination 30.

To start, we'll convert both numbers from integers to the ascii encoded as hex using the function from earlier.

30 -> "30 30 31 45 "

100 -> "30 30 36 34 "

Next we'll combine all of the numbers into the section of the command that will be used for the checksum.

[protocol][sequence][command]

Which turns in to:

>4E 30 54 49 09 30 30 31 45 09 30 30 36 34

(As a reminder, the 0x09 hex is added as the horizontal tab in between parts of the data which will be sent.)

We can then feed that data into the checksum generator to receive the value of the checksum:

checksum(4E 30 54 49 09 30 30 31 45 09 30 30 36 34) -> 51

But wait a moment, that returned us a number. To be able to send a number through to the Router, it needs to be formatted using the number formatting process from before.

51 -> "30 30 33 33

Specifically for the checksum, we do not want or need the leading zeroes which our function adds, so we can drop those when putting the command together.

We can add the checksum, the soh, and the eoh, and that leaves us with the following GVG command:

01 4E 30 54 49 09 30 30 31 45 09 30 30 36 34 33 33 04

It is important to note that while I have added spaces both in this document and in the program, those spaces **CANNOT** be included in the packet sent to the system. When actually being sent, the data would look like this:

014E30544909303031450930303634333304

If we break this down into each individual piece:
| Hex Code | Translation / Command |
| --- | --- |
| 0x01 | SOH (start of heading) |
| 0x4E | N (protocol identification)|
| 0x30 | 0 (Sequence number, will be set to zero.) |
| 0x54 0x49 | TI (Take Index) |
| 0x09 | Horizontal Tab |
| 0x30 0x30 0x31 0x45 | Destination 30 |
| 0x09 | Horizontal Tab | 
| 0x30 0x30 0x36 0x34 | Source 100 |
| 0x33 0x33 | Checksum |
| 0x04 | EOT (end of transmission) |

Finally, we can send that command to the router with our code. Here's a bare-bones Python example for sending a command and receiving a single response back from the router.

```python
message = "014E30544909303031450930303634333304"
host = "192.168.0.100" # Ross IP Address
port = 12345 # Default GVG port.

#Creates a TCP/IP connection.
with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.connect((host, port))
    s.sendall(bytes.fromhex(message))

    # Commands such as QN,IS will return multiple responses as the entire response cannot be fit in one packet.
    response = s.recv(1024)

    # The Ultrix router should respond depending on what was sent to it. This could be a data response, or just
    # the router returning the command sent to it which means that the command was sucessful.
    print(response)
```

Getting everything set up for the first time was quite a hassle for me, so hopefully this is a useful resource for anyone else looking to create an application using the GVG protocol. I've attempted to consolidate what I've learned here, and to cover the different headaches I had while trying to understand what exactly I was working with. 

Resources referred to in this document, as well as other helpful resources include:
- [GVG Routing Products Protocols](https://www.grassvalley.jp/pdf/RoutingProductsProtocolManual_2.pdf)
- [Ultrix and Ultricore Database Guide](https://documentation.rossvideo.com/files/Manuals/Routers/Ultrix/Ultrix%20and%20Ultricore%20Database%20Guide.pdf)
- [Ultrix User Guide](https://documentation.rossvideo.com/files/Manuals/Routers/Ultrix/Ultrix%20User%20Guide%20(2101DR-004).pdf)
- [Reddit: Ross NK Router GVG Control](https://www.reddit.com/r/CommercialAV/comments/1aewx6d/ross_nk_router_gvg_control/)
- [Ross Website: GVG Controls](https://help.rossvideo.com/acuity-device/Topics/Devices/Editor/GVG100.html)
- [Ross Forums: GVG Native Protocol](https://rossvideo.community/communities/community-home/digestviewer/viewthread?GroupId=301&MID=24269&CommunityKey=43f96bed-ff4a-4d2b-8f71-d4f218c9dd77&ReturnUrl=%2Fcommunities%2Fcommunity-home%2Fdigestviewer%3FCommunityKey%3D43f96bed-ff4a-4d2b-8f71-d4f218c9dd77)
- [Ross Forums: Ultrix GVG Native Protocol Commands](https://rossvideo.community/discussion/ultrix-gvg-native-protocol-commands )