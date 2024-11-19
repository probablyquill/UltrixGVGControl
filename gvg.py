import socket

def get_checksum(hex_data):
    # Prevent overflow past max hex bit.
    total = sum(hex_data) & 0xFF

    # Invert, add one for 2s compliment.
    twos_complement = (0x100 - total) & 0xFF
    return twos_complement

def decimal_to_ascii_as_hex_to_hex(number):
    output = hex(number).split('x')[-1]
    while (len(output) < 4):
        output = "0" + output
    
    output = output.encode('ascii')
    output = output.hex()
    return output

def send_data(host, port, message):
    #Sends data to a TCP server.

    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as client_socket:
        client_socket.connect((host, port))
        client_socket.sendall(message.encode("UTF-8"))

soh = [0x01] 
protocol = [0x4e, 0x30]
eot = [0x04]

# Take Index = Hex TI
# Query Name = Hex QN
take_index = [0x54, 0x49]
query_name = [0x51, 0x4e]
tab = [0x09]

# Destination 132, source 10
# Have to convert decimal to hex 
# then ascii (using hex values) to hex
dest = 132 - 1

source = 13 - 1

dest_hex = [0x30, 0x30, dest, dest]
source_hex = [0x30, 0x30, 48 + int(source / 16),48 + source % 16]

pre_checksum = protocol + take_index + tab + dest_hex + tab + source_hex

"""
pre_checksum_hex = ""
for item in pre_checksum:
    pre_checksum_hex += hex(item) + " "
"""


# Adds 48 (0x30) to the broken up checksum.
checksum_hex = []

command = soh + pre_checksum + checksum_hex + eot

# mine (not working:)
# 01 4e 30 54 49 09 30 30 37 35 09 30 30 35 39 33 39 04 

# forums (working):
# 01 4E 30 54 49 09 30 30 37 35 09 30 30 35 39 33 39 04

print(decimal_to_ascii_as_hex_to_hex(132))