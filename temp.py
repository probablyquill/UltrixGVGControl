def number_to_hex(input: int) -> str:
    # Converts the input from an integer to a hex string
    # Int 15 = "0x0f"
    output = hex(input)

    # Trim the hex string and switch it to upercase.
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

print(number_to_hex(51))