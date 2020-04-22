#!/bin/bash

######################################################
# Created by Samiyuru Senarathne on 1/22/20.
# Copyright Samiyuru Senarathne 2020
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY
# OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
# LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
# OR OTHER LIABILITY, WHETHER IN AN ACTION OF
# CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
# OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
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
