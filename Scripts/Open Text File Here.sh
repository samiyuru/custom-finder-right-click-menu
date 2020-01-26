#!/bin/bash

DEF_FILE_NAME="NewText"
FILE_EXT="txt"

filePath="${1}/${DEF_FILE_NAME}.${FILE_EXT}"
fileNo=1

while [ -f "${filePath}" ]
do
    filePath="${1}/${DEF_FILE_NAME}_${fileNo}.${FILE_EXT}"
    fileNo=$((fileNo+1))
done

touch "${filePath}"
open -a TextEdit "${filePath}"
