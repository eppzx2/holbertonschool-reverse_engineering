### 1.The purpose of the task is to create a Bash script that extracts and displays important information from the ELF (Executable and Linkable Format) header of a given binary file. Specifically, the script will output:

1. **Magic Number**: Identifies the file as an ELF file.
2. **Class**: Indicates whether the ELF file is 32-bit or 64-bit.
3. **Byte Order**: Specifies whether the file is little-endian or big-endian.
4. **Entry Point Address**: Shows the memory address where program execution starts.

The script accepts the ELF file name as a command-line argument, checks for the file's validity, and displays the extracted data in a formatted output using `messages.sh` for consistent styling. If the file is not a valid ELF or doesn’t exist, it will display an error message. 

The script aims to make it easy to analyze ELF files and understand key attributes necessary for reverse engineering and security analysis.

### 2 Enumerating sections 
In reverse engineering helps identify the structure of a binary. Key sections like `.text` (code), `.data` (initialized data), and `.bss` (uninitialized data) provide insights into the program's layout. It allows detection of custom or suspicious sections, such as `.hbtn-custom`, which may store hidden data or payloads. This process aids in analyzing the binary’s behavior, identifying vulnerabilities, and understanding its dependencies on external libraries. It also helps with debugging, patching, and ensuring compatibility.

### 3. The information about the external libraries required by a binary is incredibly useful for several reasons, especially in the context of analyzing and working with binaries:
 **Reverse Engineering and Malware Analysis**
   - **Understanding Binary Behavior**: Knowing the external libraries a binary uses helps reverse engineers and malware analysts understand its functionality. Many binaries use standard libraries to implement common functions like string manipulation, file handling, or networking. Identifying these libraries can help analysts trace how the binary works and what kind of operations it performs.
   - **Identifying Malicious Libraries**: Malicious software often uses specific libraries to perform certain actions (e.g., `libcurl` for networking, `libssl` for encryption). By identifying these libraries, analysts can better understand the nature of the binary and its potential malicious intent.
