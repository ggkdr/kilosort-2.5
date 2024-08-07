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
    echo "moving ${a}-${dat} to server.."
    # move entire date folder to server using rsync
    rsync --remove-source-files -av $dat kgupta@${SERVER_URL}:/Freiwald/kgupta/neural_data/$a/
  fi
done


