#!/bin/bash
# Usage: ./timestomp.sh <target_file_or_dir> [reference_file]
# Example: ./timestomp.sh /opt/payload /bin/systemd

TARGET="$1"
REF="${2:-/bin/ls}"

if [ -z "$TARGET" ]; then
    echo "Usage: $0 <target_file_or_dir> [reference_file]"
    exit 1
fi

if [ ! -e "$TARGET" ]; then
    echo "[!] Target $TARGET does not exist."
    exit 1
fi

if [ ! -f "$REF" ]; then
    echo "[!] Reference $REF does not exist or is not a file."
    exit 1
fi

# Extract timestamps from reference
REF_ATIME=$(stat -c %X "$REF") # access time (epoch)
REF_MTIME=$(stat -c %Y "$REF") # modify time (epoch)

echo "[*] Using reference file: $REF"
echo "[*] Applying timestamps to: $TARGET"

# Function to timestomp a single file
timestomp_file() {
    FILE="$1"
    # Apply access and modification time
    touch -a -d @"$REF_ATIME" "$FILE"
    touch -m -d @"$REF_MTIME" "$FILE"
}

# Apply to single file or recursively to directories
if [ -f "$TARGET" ]; then
    timestomp_file "$TARGET"
elif [ -d "$TARGET" ]; then
    find "$TARGET" -type f -print0 | while IFS= read -r -d '' FILE; do
        timestomp_file "$FILE"
    done
    find "$TARGET" -type d -print0 | while IFS= read -r -d '' DIR; do
        timestomp_file "$DIR"
    done
fi

echo "[*] Timestomping complete."
