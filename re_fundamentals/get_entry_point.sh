#!/bin/bash
# Usage: ./get_entry_point.sh <path_to_file>

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/messages.sh"

if [ $# -ne 1 ]; then
    echo "Usage: $0 <file_name>"
    exit 1
fi

file_name="$1"

if [ ! -f "$file_name" ]; then
    echo "Error: File '$file_name' does not exist."
    exit 1
fi

magic_bytes=$(head -c 4 "$file_name" | od -An -tx1 | tr -d ' \n')

if [ "$magic_bytes" != "7f454c46" ]; then
    echo "Error: '$file_name' is not a valid ELF file."
    exit 1
fi

if ! readelf -h "$file_name" &>/dev/null; then
    echo "Error: '$file_name' is not a valid ELF file."
    exit 1
fi

header_info=$(readelf -h "$file_name")

magic_number=$(echo "$header_info" | grep "Magic:" | sed 's/.*Magic:\s*//' | sed 's/^[ \t]*//;s/[ \t]*$//')
class=$(echo "$header_info" | grep "Class:" | cut -d':' -f2 | sed 's/^[ \t]*//;s/[ \t]*$//')
byte_order=$(echo "$header_info" | grep "Data:" | grep -oE '(little|big) endian')
entry_point_address=$(echo "$header_info" | grep "Entry point address:" | cut -d':' -f2 | sed 's/^[ \t]*//;s/[ \t]*$//')

display_elf_header_info
