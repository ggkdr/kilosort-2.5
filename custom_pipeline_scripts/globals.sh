#!/bin/bash

# storing all global variables here
stores=("RSn2" "RSn3")
channelsPerStore=256 # should not change
batchesPerStore=4 # may wish to increase to 8, if kilosort is running out of memory [optimal]
# batchesPerStore=2 # may wish to increase to 8, if kilosort is running out of memory [2 is too large and slow.]
channelsPerBatch=$(($channelsPerStore / $batchesPerStore))

KILOSORT_PATH="/home/kgg/Desktop/kilosort-2.5"
PIPELINE_SCRIPTS_PATH1="${KILOSORT_PATH}/custom_pipeline_scripts/1_download-and-convert-neural-data"
PIPELINE_SCRIPTS_PATH2="${KILOSORT_PATH}/custom_pipeline_scripts/2_run-kilosort-matlab"
LOCAL_DATA_PATH="/home/kgg/Desktop/kilosort_data"
# SERVER_DATA_PATH="/mnt/hopfield_data01/ltian/recordings"
SERVER_DATA_PATH="/mnt/Freiwald/ltian/recordings" # lt 8/14/23




