#!/bin/bash -e

# load necessary variables and paths
source /home/kgg/Desktop/kilosort-2.5/custom_pipeline_scripts/globals.sh

a=$1  
d=$2

# make sure this date has recordings
DATE_FOLDER_SERVER=$SERVER_DATA_PATH/$a/$d
DATE_FOLDER_LOCAL=$LOCAL_DATA_PATH/$a/$d

echo "$DATE_FOLDER_SERVER"
echo "$DATE_FOLDER_LOCAL"

if [ -d "$DATE_FOLDER_SERVER" ]; then
  cd $DATE_FOLDER_SERVER

  # get all directories, e.g. Pancho-220520-162344, Pancho-220520-164412
  for f in ./*/; do
    # get basename
    session_name=$(basename $f)
	  echo "--PROCESSING: ${session_name}"

    # create bin files (note: if createLocalBinsFSSF fails, this script terminates because of -e in 1st line)
		bash $PIPELINE_SCRIPTS_PATH1/2-createLocalBinsFromServerSessionFolder.sh $a $d $session_name
	done
	
  # combine .bins across sessions into one
  cd $DATE_FOLDER_LOCAL

  # if KS_done.txt exists, then skip...
  if [ ! -f "KS_done.txt" ]; then
  	
	  # # for each session in chronological order: combine .bin with other .bins for that store/batch
	  for s in ${stores[@]}; do
	    for b in $(seq 1 $batchesPerStore); do
	      sb=${s}_batch${b}
	      bin_name=${sb}.bin

	      # Delete previous concated bin if exitst. assumes is failed attempt.
	      # also ensures you are not appending to old bin file.
		    if [ -d $sb ]; then
		      echo "DELETING: this old dir, to avoid partial bin files... $sb"
		      # mv $sb ${sb}_OLD
		      rm -r $sb
		    fi

	      mkdir $sb
	      touch $sb/$bin_name
	      echo "** Concatting bin files to here: $sb/$bin_name"
	      # get list of sessions in chronological order, then add all their bins together
	      for f in ./${a}-${d}-*/; do
	        cat $f$bin_name >> $sb/$bin_name
	        #mv $f/${bin_name}_export.txt $sb/${bin_name}_export.txt
	        # remove bin file that was copied
	        rm $f$bin_name
	        echo "... Appended this file (and deleted it): $f$bin_name"
	      done
	    done
	  done

	  # now run kilosort on the .bin files
	  # bash /data1/programs/MATLAB/R2021a/bin/matlab -batch "runKilosortMain('$a', '$d', '$batchesPerStore', '$channelsPerBatch')"
	  echo "** Running kilosort..."
	  bash /usr/local/MATLAB/R2021a/bin/matlab -batch "runKilosortMain('$a', '$d', ${batchesPerStore}, ${channelsPerBatch})"
  fi
fi
