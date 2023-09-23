#!/bin/bash

a=$1
d=$2

# rsync transfer from local to server
echo "uploading ${a}-${d} to server.."

# note: actual postprocessing datstruct etc. is already on server (/kgupta/neural_data/postprocess) but
# we also want to move the actual kilosorted data.
rsync -av /lemur2/kilosort_data/$a/$d kgupta@turing.rockefeller.edu:/Freiwald/kgupta/neural_data/$a
