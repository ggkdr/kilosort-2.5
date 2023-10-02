#!/bin/bash

# load necessary variables/paths
source /home/kgg/Desktop/kilosort-2.5/custom_pipeline_scripts/globals.sh

a=$1
d=$2

# rsync transfer from server to local
echo "downloading ${a}-${d} from server.."
rsync -av kgupta@turing.rockefeller.edu:/Freiwald/kgupta/neural_data/$a/$d $LOCAL_DATA_PATH/$a
