#!/bin/bash

######################################################
# Create a new text file with a name not existing
# in the dir given as a param.
# Open the created text with TextEdit.
# Param is the directory to create the text file.
######################################################

DEF_FILE_NAME="NewText"
FILE_EXT="txt"

# Default text file name.
filePath="${1}/${DEF_FILE_NAME}.${FILE_EXT}"
fileNo=1

# Try new names until a non-existing one is found.
while [ -f "${filePath}" ]
do
    filePath="${1}/${DEF_FILE_NAME}_${fileNo}.${FILE_EXT}"
    fileNo=$((fileNo+1))
done

# Create the text file.
touch "${filePath}"

# Open the file with TextEdit.
open -a TextEdit "${filePath}"
