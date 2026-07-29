#!/bin/bash
#
# get_entry_point.sh
#
# Extracts and displays key fields from the ELF header of a given file:
#   - Magic Number
#   - Class (32-bit / 64-bit)
#   - Byte Order (endianness)
#   - Entry Point Address
#
# Usage: ./get_entry_point.sh <path_to_file>

# Directory this script lives in, so messages.sh can be found regardless
# of the caller's current working directory.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Pull in the shared display function.
source "${SCRIPT_DIR}/messages.sh"

# --- 1. Argument check -------------------------------------------------
if [ $# -ne 1 ]; then
    echo "Usage: $0 <file_name>"
    exit 1
fi

file_name="$1"

# --- 2. File existence check --------------------------------------------
if [ ! -f "$file_name" ]; then
    echo "Error: File '$file_name' does not exist."
    exit 1
fi

# --- 3. ELF validity check ----------------------------------------------
# The first 4 bytes of a valid ELF file are the magic bytes: 7F 45 4C 46
# ("\x7fELF"). `file` and `readelf` both rely on this, so we check it
# directly with `head`/`od` to give a clean, dependency-light validation.
magic_bytes=$(head -c 4 "$file_name" | od -An -tx1 | tr -d ' \n')

if [ "$magic_bytes" != "7f454c46" ]; then
    echo "Error: '$file_name' is not a valid ELF file."
    exit 1
fi

# Double check with readelf itself (in case of truncated/corrupt files).
if ! readelf -h "$file_name" &>/dev/null; then
    echo "Error: '$file_name' is not a valid ELF file."
    exit 1
fi

# --- 4. Extract required data with readelf -------------------------------
header_info=$(readelf -h "$file_name")

magic_number=$(echo "$header_info" | grep "Magic:" | sed 's/.*Magic:\s*//' | sed 's/^[ \t]*//;s/[ \t]*$//')
class=$(echo "$header_info" | grep "Class:" | cut -d':' -f2 | sed 's/^[ \t]*//;s/[ \t]*$//')
byte_order=$(echo "$header_info" | grep "Data:" | grep -oE '(little|big) endian')
entry_point_address=$(echo "$header_info" | grep "Entry point address:" | cut -d':' -f2 | sed 's/^[ \t]*//;s/[ \t]*$//')

# --- 5. Display formatted output via messages.sh -------------------------
display_elf_header_info
