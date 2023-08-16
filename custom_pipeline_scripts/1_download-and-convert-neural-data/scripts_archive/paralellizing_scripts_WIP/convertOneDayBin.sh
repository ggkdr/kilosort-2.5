#!/bin/bash

a=$1  
d=$2

# first, mount hopfield using kgupta ssh key (-wx access)
if [ ! -d /mnt/hopfield_data01 ]; then
  bash /mnt/mount_hopfield_kgupta.sh
fi

# paths
SERVER_PATH="/mnt/hopfield_data01/ltian/recordings/$a"
LOCAL_PATH="/data5/Kedar/neural_spike_sorting/kilosort_data"

# important variables
batches=8
channels=256
batch_size=$(($channels / $batches))
stores=("RSn2" "RSn3")

# make sure this date has recordings
DATE_FOLDER_SERVER=$SERVER_PATH/$d
DATE_FOLDER_LOCAL=$LOCAL_PATH/${a}/${d}

if [ -d "$DATE_FOLDER_SERVER" ]; then
  cd $DATE_FOLDER_SERVER

  # get all directories, e.g. Pancho-220520-162344, Pancho-220520-164412
  for f in ./*/; do
    # get basename
    session_name=$(basename $f)
	  echo "--PROCESSING: ${session_name}"

    # create bin files (note: if createLocalBinsFSSF fails, this script terminates because of -e in 1st line)
		bash $LOCAL_PATH/createLocalBinsFromServerSessionFolder.sh $a $d $session_name
	done

  # combine .bins across sessions into one
  cd $DATE_FOLDER_LOCAL
  # for each session in chronological order: combine .bin with other .bins for that store/batch
  for s in ${stores[@]}; do
    for b in $(seq 1 $batches); do
      sb=${s}_batch${b}
      bin_name=${sb}.bin
      mkdir $sb
      touch $sb/$bin_name
      # get list of sessions in chronological order, then add all their bins together
      for f in ./${a}-${d}-*/; do
        cat $f/$bin_name >> $sb/$bin_name
        #mv $f/${bin_name}_export.txt $sb/${bin_name}_export.txt
        # remove bin file that was copied
        rm $f/$bin_name
      done
    done
  done

  # now run kilosort on the .bin files
  # bash /data1/programs/MATLAB/R2021a/bin/matlab -batch "runKilosortMain('$a', '$d')"
fi
