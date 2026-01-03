#!/bin/bash

# Find and convert all .wav and .mp3 files referenced in .tscn files to .ogg

set -e

# Get the project root (current directory or passed as argument)
PROJECT_ROOT="${1:-.}"

# Find all sound file references in .tscn files
grep -inr --include \*.tscn -E '\.(mp3|wav)"' "$PROJECT_ROOT" | \
    grep -oP 'path="res://\K[^"]+\.(mp3|wav)' | \
    sort -u | \
while read -r relative_path; do
    input_file="$PROJECT_ROOT/$relative_path"
    
    # Generate output filename (replace extension with .ogg)
    output_file="${input_file%.*}.ogg"
    
    if [[ ! -f "$input_file" ]]; then
        echo "WARNING: File not found: $input_file"
        continue
    fi
    
    if [[ -f "$output_file" ]]; then
        echo "SKIP: Already exists: $output_file"
        continue
    fi
    
    echo "Converting: $input_file -> $output_file"
    ffmpeg -i "$input_file" -c:a libvorbis -q:a 8 "$output_file" -y -loglevel warning
done

echo "Done!"

