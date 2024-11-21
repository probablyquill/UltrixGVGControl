import socket

# Sends data to a TCP server.
def send_gvg_data(host: str, port, message: str):
    # Strips spaces so that the correct number of bytes are sent.
    message = message.replace(" ", "")

    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.connect((host, port))
        s.sendall(bytes.fromhex(message))

        response = s.recv(1024)

        # The Ultrix router should respond depending on what was sent to it.
        print(response)

# Known working command:
# 01 4E 30 54 49 09 30 30 37 35 09 30 30 35 39 33 39 04

# Should work:
# 01 4E 30 54 49 09 30 30 38 33 09 30 30 35 39 33 61 04
if __name__ == "__main__":
    message = "01 4E 30 51 4E 09 30 30 49 53 09 30 30 38 33 30 61 04"
    host = "127.0.0.1" # Ross IP Address
    port = 12345
    send_gvg_data(host, port, message)