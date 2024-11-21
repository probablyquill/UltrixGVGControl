import socket

# Sends data to a TCP server.
def send_gvg_data(host: str, port, message: str):
    # Strips spaces to match the formatting used in the sniffed Wireshark packets.
    message = message.replace(" ", "")

    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.connect((host, port))
        s.sendall(message.encode("UTF-8"))

        response = s.recv(1024)

        # The recieved response for TI should be the same message sent to the Ultrix,
        # based on what I saw in Wireshark. This could be used to verify a succesful action.
        print(response)

# Known working:
# 01 4E 30 54 49 09 30 30 37 35 09 30 30 35 39 33 39 04

# Should work:
# 01 4E 30 54 49 09 30 30 38 33 09 30 30 35 39 33 61 04
if __name__ == "__main__":
    message = "01 4E 30 54 49 09 30 30 38 33 09 30 30 35 39 33 61 04"
    host = "127.0.0.1"
    port = 12345
    send_gvg_data(host, port, message)