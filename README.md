# Pipeshell
Pipeshell is a tool that enables local inter-process communication (IPC) through <a href="https://learn.microsoft.com/en-us/windows/win32/ipc/interprocess-communications#using-pipes-for-ipc" target="_blank">named pipes</a> for command execution between processes on the same machine. It uses the .NET framework's `System.IO.Pipes` namespace, specifically the `NamedPipeServerStream` and `NamedPipeClientStream` classes, to establish a communication channel.

There are two components:

1. **Server Script (`pipeshell_server.ps1`):** sets up the named pipe server,  listens for incoming client connections, and executes received commands.

2. **Client Script (`pipeshell_client.ps1`):** connects to the named pipe server, sends commands, and displays the results returned by the server.

They should both be run on the same machine.

## **Usage**

Run the server script to setup the pipe:


`-p [pipe_name]`: a unique name for the named pipe.

`-k [one_byte_XOR_key]`: a single-byte key (in integer form) for XOR encryption.

```html
PS C:\> .\pipeshell_server.ps1 -p some_pipe -k 11
```

On the same machine, run the client script to connect to the pipe and issue commands.

`-p [pipe_name]`: the name of the pipe to connect to (must match the server's pipe name).

`-k [one_byte_XOR_key]`: the XOR key used for encryption (must match the server's key).

```html
PS C:\> .\pipeshell_client.ps1 -p some_pipe -k 11
```

Once connected, you can issue commands from the client. The server will execute the command and return output to the client.

<img src="https://x42.obscurechannel.com/images/pipeshell.gif?ver=1"></img>

### **OPSEC Consideration:**

- **XOR:** a one-byte XOR key in-general, is not secure, and additionally for purposes of this PoC, only encrypts the *command*, but not the output as it traverses the pipe. Not to mention that the key itself is visible in the PowerShell process' command line. For real-world use, you should probably use something better to encrypt the communication (i.e., `AES`, `ChaCha20`).
