#!/bin/bash
# convert data from a sessionfolder (on server), from .sev to .bin, in N batches (default N=8)

# get positional args
a=$1
date=$2
session_name=$3
batchesPerStore=$4
channelsPerStore=$5

# important variables
channelsPerBatch=$(($channelsPerStore / $batchesPerStore))
stores=("RSn2" "RSn3")

# make local directories for storing .bin files
SERVER_PATH="/mnt/hopfield_data01/ltian/recordings/$a/$date/$session_name"
KS_PATH="/data5/Kedar/neural_spike_sorting/kilosort_data"
LOCAL_PATH="$KS_PATH/$a/$date/$session_name"
mkdir -p $LOCAL_PATH

# halt script if this date has already been processed
if [ -f $LOCAL_PATH/RSn2_batch1/RSn2_batch1.bin ]; then
  echo "ERROR: seems like ${session_name} has already been converted...ending script"
  exit 1
fi

# for each .sev file in $SERVER_PATH, create a symlink in $LOCAL_PATH
cd $SERVER_PATH
for f in *.sev; do
  ln -s $SERVER_PATH/$f $LOCAL_PATH/$f
done

# create .bin files in multiple batches, for memory purposes
cd $LOCAL_PATH

for s in ${stores[@]}; do
  for b in $(seq 1 $batchesPerStore); do
    ind=$(($b-1))
    startChan=$(($ind*$channelsPerBatch+1))
    endChan=$(($b*$channelsPerBatch))
    python $KS_PATH/convertSev2Bin.py $s $startChan $endChan
    #sbDir="$LOCAL_PATH/${s}_batch${b}"
    #mkdir $sbDir
    #mv $s.i16 $sbDir/${s}_batch${b}.bin
    mv $s.i16 $LOCAL_PATH/${s}_batch${b}.bin
    echo "Starting Channel: " $startChan >> interlaced_sev_export.txt
    echo "Ending Channel: " $endChan >> interlaced_sev_export.txt
    #mv interlaced_sev_export.txt $sbDir/${s}_batch${b}_export.txt
    mv interlaced_sev_export.txt $LOCAL_PATH/${s}_batch${b}_export.txt
  done
done

# clean up local directory by deleting all symlink .sev files
rm $LOCAL_PATH/*.sev
