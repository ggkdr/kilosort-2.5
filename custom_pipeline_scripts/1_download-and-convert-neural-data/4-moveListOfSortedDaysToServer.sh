#!/bin/bash

# load necessary variables/paths
source /home/kgg/Desktop/kilosort-2.5/custom_pipeline_scripts/globals.sh

a=$1
#cd "/lemur2/kilosort_data/$a"
cd $LOCAL_DATA_PATH/$a
echo "$LOCAL_DATA_PATH/$a"

date_list=(220719 220724 220918 221015 221024 221217 221218 221220 230103 230104 230105 230612 230613 230616 230622 230623)
for d in ${date_list[@]}; do  dat=$(basename $d)
  echo $dat
  if [ -e ./$dat/KS_done.txt ]; then
    echo "moving ${a}-${dat} to server.."
    # move entire date folder to server using rsync
    rsync --remove-source-files -av $dat kgupta@turing.rockefeller.edu:/Freiwald/kgupta/neural_data/$a/
  fi
done

