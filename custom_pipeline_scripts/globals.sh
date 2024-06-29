#!/bin/bash

# storing all global variables here
stores=("RSn2" "RSn3")
channelsPerStore=256 # should not change
batchesPerStore=4 # may wish to increase to 8, if kilosort is running out of memory [optimal]
# batchesPerStore=2 # may wish to increase to 8, if kilosort is running out of memory [2 is too large and slow.]
channelsPerBatch=$(($channelsPerStore / $batchesPerStore))

KILOSORT_PATH="/gorilla4/kilosort-2024/kilosort-2.5"
PIPELINE_SCRIPTS_PATH1="${KILOSORT_PATH}/custom_pipeline_scripts/1_download-and-convert-neural-data"
PIPELINE_SCRIPTS_PATH2="${KILOSORT_PATH}/custom_pipeline_scripts/2_run-kilosort-matlab"

LOCAL_DATA_PATH="/gorilla4/kilosort-2024/kilosort_data"
LOCAL_DATA_BACKUP_PATH="/gorilla4/kilosort-2024/kilosort_data"
# LOCAL_DATA_BACKUP_PATH="/lemur2/kilosort_data" # For moving, large drive, if not completed and therefore not allowed to mvoe to server.

# SERVER_DATA_PATH="/mnt/hopfield_data01/ltian/recordings"
SERVER_RAW_DATA_PATH="/mnt/Freiwald/ltian/recordings" # lt 8/14/23
SERVER_KILOSORT_DATA_PATH="/mnt/Freiwald/kgupta/neural_data"
SERVER_URL="vera.rockefeller.edu"

MATLAB_PATH=/gorilla1/programs/MATLAB/R2021a/bin/matlab



