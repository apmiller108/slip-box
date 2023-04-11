#!/bin/bash
set -euo pipefail

for file in ./images/*.jpg ./images/*.jpeg; do 
  echo "Converting $file to webp..."
  mogrify -resize '800>' -format webp "$file"
  echo "Converted $file to webp. It is `identify -format "%b\n" $file`"
  rm "$file"
done
echo "Conversion complete!"

# for file in ./images/*.webp; do
#   echo "resizing..."
#   mogrify -resize '800>' "$file"
#   echo "Resized $file. It is `identify -format "%b\n" $file`"
# done
# echo "Conversion complete!" 
