#!/bin/bash
# convert data from a sessionfolder (on server), from .sev to .bin, in N batches (default N=8)

# get positional args
a=$1
date=$2
session_name=$3

# load necessary variables and paths
#source /home/kgg/Desktop/kilosort-2.5/custom_pipeline_scripts/globals.sh
source /gorilla4/kilosort-2024/kilosort-2.5/custom_pipeline_scripts/globals.sh
#batchesPerStore=$4
#channelsPerStore=$5

# important variables
#channelsPerBatch=$(($channelsPerStore / $batchesPerStore))
#stores=("RSn2" "RSn3")

# make local directories for storing .bin files
SERVER_SESSION_PATH="$SERVER_RAW_DATA_PATH/$a/$date/$session_name"
#KS_PATH="/data5/Kedar/neural_spike_sorting/kilosort_data"
LOCAL_SESSION_PATH="$LOCAL_DATA_PATH/$a/$date/$session_name"
mkdir -p $LOCAL_SESSION_PATH

# for each .sev file in $SERVER_SESSION_PATH, create a symlink in $LOCAL_SESSION_PATH
cd $SERVER_SESSION_PATH
echo $SERVER_SESSION_PATH
for f in *.sev; do
  ln -s $SERVER_SESSION_PATH/$f $LOCAL_SESSION_PATH/$f
done

# create .bin files in multiple batches, for memory purposes
cd $LOCAL_SESSION_PATH

for s in ${stores[@]}; do
  for b in $(seq 1 $batchesPerStore); do

    # halt script if this date has already been processed
    if [ -f $LOCAL_SESSION_PATH/${s}_batch${b}.bin ]; then
      echo "NOTE: seems like $LOCAL_SESSION_PATH/${s}_batch${b}.bin has already been converted... SKIPPING"
      # exit 1
      continue
    fi
    
    echo "CONVERTING sev2bin for $LOCAL_SESSION_PATH/${s}_batch${b}..."
    ind=$(($b-1))
    startChan=$(($ind*$channelsPerBatch+1))
    endChan=$(($b*$channelsPerBatch))
    python $PIPELINE_SCRIPTS_PATH1/1-convertSev2Bin.py $s $startChan $endChan
    mv $s.i16 $LOCAL_SESSION_PATH/${s}_batch${b}.bin
    echo "Starting LOCAL_SESSION_PATH: " $startChan >> interlaced_sev_export.txt
    echo "Ending Channel: " $endChan >> interlaced_sev_export.txt
    #mv interlaced_sev_export.txt $sbDir/${s}_batch${b}_export.txt
    mv interlaced_sev_export.txt $LOCAL_SESSION_PATH/${s}_batch${b}_export.txt
  done
done

# clean up local directory by deleting all symlink .sev files
rm $LOCAL_SESSION_PATH/*.sev
