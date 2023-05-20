#!/bin/bash

# Converts the jpg files in the `./images` directory to webp. Filename is
# changed and index appended.
# Usage:
#   From the slip_box directory run
#
#   ./convert_images.sh my_new_file_name
#
#   This will output images/my_new_file_name_{i}.webp
set -euo pipefail

target_dir="./images"
extension=".webp"

if [ $# -eq 0 ]; then
  echo "Please provide a name for the converted files."
  exit 1
fi

conversion_name="$1"
index=1

for file in "$target_dir"/*.jpg; do
  echo "Converting $file to webp..."
  mogrify -resize '800>' -format webp "$file"

  converted_file="${file%.*}$extension"
  new_name="${converted_file%/*}/${conversion_name}_${index}$extension"
  mv "$converted_file" "$new_name"

  echo "Converted $file to $new_name. # It is $(identify -format "%b\n" "$new_name")"
  rm "$file"
  index=$((index+1))
done

echo "Conversion complete!"
