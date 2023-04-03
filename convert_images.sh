#!/bin/bash
mkdir webp # create a new directory to store the converted files
for file in ./images/*gpt4.jpg; do # loop through all JPG files in the current directory
  echo "Converting $file to webp..." # print a message to the console
  mogrify -format webp "$file" # convert to webp
  echo "Converted $file. It is `identify -format "%b\n" $file`" # print completion message and file size
done
echo "Conversion complete!" # print a message to the console when all files have been converted
