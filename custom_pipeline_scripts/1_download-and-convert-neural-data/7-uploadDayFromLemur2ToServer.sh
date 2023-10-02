#!/bin/bash

a=$1
d=$2

# rsync transfer from local to server
echo "uploading ${a}-${d} to server.."

# note: actual postprocessing datstruct etc. is already on server (/kgupta/neural_data/postprocess) but
# we also want to move the actual kilosorted data.

rsync -av --remove-source-files /lemur2/kilosort_data/$a/$d kgupta@turing.rockefeller.edu:/Freiwald/kgupta/neural_data/$a

# move empty directories after rsync completes, to a folder that can be checked and deleted
mkdir -p /lemur2/kilosort_data/$a/dates_transferred_to_server/$d
mv /lemur2/kilosort_data/$a/$d /lemur2/kilosort_data/$a/dates_transferred_to_server/$d
