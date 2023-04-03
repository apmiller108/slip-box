#!/bin/bash
mkdir webp # create a new directory to store the converted files
for file in ./images/*gpt4.jpg; do # loop through all JPG files in the current directory
  filename=$(basename -- "$file") # get the filename without the extension
  extension="${filename##*.}" # get the file extension
  filename="${filename%.*}" # remove the file extension from the filename
  echo "Converting $file to webp..." # print a message to the console
  mogrify -format webp "$file" -path ./webp/ # convert the file to WebP and save it to the webp directory
done
echo "Conversion complete!" # print a message to the console when all files have been converted
