# Takes a string of hex codes, seperates then sums them, and returns the 
# two's compliment.
def get_checksum(hex_data):
    i = 0
    total = 0
    hex_data = hex_data.split(' ')
    
    while i < len(hex_data) - 1:
        data = int(hex_data[i], 16)
        total += data
        i += 1
    
    # Prevent overflow past max hex bit.
    total = total & 0xFF

    # Invert, add one for 2s compliment.
    twos_complement = (0x100 - total) & 0xFF
    return twos_complement

# To pass a number to the Ultrix router over the GVG protocol, a handful of 
# conversions need to take place.
# Decimal -> Hex e.x.: 15 -> 0x0F
# Hex to 4 char ASCII string e.x. 0x0F -> 000F
# ASCII string to hex e.x. 000F -> 3030303F
# Said string is then sliced into each hex value e.x. 30 30 30 3F
def gvg_conversion(number):
    output = hex(number).split('x')[-1]
    while (len(output) < 4):
        output = "0" + output
    
    output = output.encode('ascii')
    output = output.hex()
    i = 0
    return_string = ""
    while i < len(output):
        return_string += output[i]
        if(i % 2 != 0): return_string += " "
        i += 1

    return return_string

soh = "01 "
protocol = "4e 30 "
eot = "04"

# Take Index = Hex TI
# Query Name = Hex QN
take_index = "54 49 "
query_name = "51 4e "
tab = "09 "

# Destination 132, source 10
# Have to convert decimal to hex 
# then ascii (using hex values) to hex
dest = 132 - 1

source = 90 - 1

dest_hex = gvg_conversion(dest)
source_hex = gvg_conversion(source)

pre_checksum = protocol + take_index + tab + dest_hex + tab + source_hex

checksum = gvg_conversion(get_checksum(pre_checksum))

#Source / dest values are padded when converted, and so the checksum has to be trimmed.
output = (soh + pre_checksum + checksum[6:] + eot).upper()

print(output)

# forums (working):
# 01 4E 30 54 49 09 30 30 37 35 09 30 30 35 39 33 39 04