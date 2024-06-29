#!/bin/bash

# load necessary variables/paths
#source /home/kgg/Desktop/kilosort-2.5/custom_pipeline_scripts/globals.sh
source /gorilla4/kilosort-2024/kilosort-2.5/custom_pipeline_scripts/globals.sh

a=$1
cd $LOCAL_DATA_PATH/$a
echo "$LOCAL_DATA_PATH/$a"
for d in ./*/; do
  dat=$(basename $d)
  echo $dat
  if [ -e ./$dat/KS_done.txt ]; then
    echo "moving ${a}-${dat} to drive.."
    # move entire date folder to drive using rsync
    rsync --remove-source-files -av $dat ${LOCAL_DATA_BACKUP_PATH}/$a/
  fi
done


