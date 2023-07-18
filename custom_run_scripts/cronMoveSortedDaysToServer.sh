#!/bin/bash

a=$1
cd /data5/Kedar/neural_spike_sorting/kilosort_data/$a

for d in ./*/; do
  dat=$(basename $d)
  echo $dat
  if [ -e ./$dat/KS_done.txt ]; then
    echo "moving ${a}-${dat} to server.."
    # move entire date folder to server using rsync
    rsync --remove-source-files -av $dat kgupta@turing.rockefeller.edu:/Freiwald/kgupta/neural_data/$a/
  fi
done


