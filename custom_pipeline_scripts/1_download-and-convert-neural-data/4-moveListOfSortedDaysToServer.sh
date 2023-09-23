#!/bin/bash

# load necessary variables/paths
source /home/kgg/Desktop/kilosort-2.5/custom_pipeline_scripts/globals.sh

a=$1
cd $LOCAL_DATA_PATH/$a
echo "$LOCAL_DATA_PATH/$a"

date_list=(220906 221121 220925)
for d in ${date_list[@]}; do  dat=$(basename $d)
  echo $dat
  if [ -e ./$dat/KS_done.txt ]; then
    echo "moving ${a}-${dat} to server.."
    # move entire date folder to server using rsync
    rsync --remove-source-files -av $dat kgupta@turing.rockefeller.edu:/Freiwald/kgupta/neural_data/$a/
  fi
done


