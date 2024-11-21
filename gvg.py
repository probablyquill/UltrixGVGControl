# Necessary values and variables.
soh = "01 "
protocol = "4e 30 "
eot = "04"

# GVG Commands:
# Take Index = Hex TI
# Query Name = Hex QN
ti = "54 49 "
qn = "51 4e "

tab = "09 "

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
def gvg_conversion(input):

    # Handle different types of inputs - some will be ints, some will be
    # single character strings.
    if type(input) is int:
        output = hex(input)
    elif type(input) is str:
        output = input
    else:
        raise TypeError("Unsupported type: must be str or int.")

    output = output.split('x')[-1]
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


def gvg_command(command, arg1, arg2):

    # GVG Native counts from zero, so inputs refering to IO need to be adjusted.
    if command == ti:
        arg1 -= 1
        arg2 -= 1

    if command == qn:
        arg2 -= 1

    # Convert decimal to GVG Native Hex.
    arg1_hex = gvg_conversion(arg1)
    arg2_hex = gvg_conversion(arg2)

    # Create value to be used for checksum.
    pre_checksum = protocol + command + tab + arg1_hex + tab + arg2_hex

    #Generate checksum
    checksum = gvg_conversion(get_checksum(pre_checksum))

    #Trim checksum to correct size and create final GVG Native command.
    output = (soh + pre_checksum + checksum[6:] + eot).upper()
    
    return output

# Test for Take Index, dest 132 source 10
command = gvg_command(ti, 132, 10)
print(command)

# Test for Query Name, destination 132
command = gvg_command(qn, "IS", 132)
print(command)

# Example from forums (working, dest 118 source 90):
# 01 4E 30 54 49 09 30 30 37 35 09 30 30 35 39 33 39 04

# QN Command to test:
# 01 4E 30 51 4E 09 30 30 34 34 09 30 30 38 33 33 65 04
# 014E30514E09303034340930303833336504