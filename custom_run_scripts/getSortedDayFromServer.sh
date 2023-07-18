#!/bin/bash

a=$1
d=$2

# rsync transfer from server to local
echo "downloading ${a}-${d} from server.."
rsync -av kgupta@turing.rockefeller.edu:/Freiwald/kgupta/neural_data/$a/$d $a
