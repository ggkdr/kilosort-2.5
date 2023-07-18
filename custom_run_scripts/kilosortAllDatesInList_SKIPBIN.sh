#!/bin/bash
# takes list of dates, creates .bin files in N batches (default N=8), and runs kilosort on all of them

# first, mount hopfield using kgupta ssh key (-wx access)
if [ ! -d /mnt/hopfield_data01 ]; then
  bash /mnt/mount_hopfield_kgupta.sh
fi

a="Pancho"
# date_list=(220930 221014 221020 221031 221102 221107 221114 221121 221125)
# date_list=(221020 220930 221014 221031 221102 221107 221114 221121 221125)
# date_list=(220715 220709 220714 230105)
# date_list=(221020 220715 221014 220714 220709 220930)
#date_list=(220716 220717 230106 221031 221102 221107 221114 221121 221125)
#date_list=(220709 220714 220716 220717 220930 221014 221107 221114 221121 221125 230106)
date_list=(220709 220714 220930 221014 221107 221114 221121 221125 230105 230106 230108 230109)

# paths
SERVER_PATH="/mnt/hopfield_data01/ltian/recordings/$a"
# LOCAL_PATH="/data4/Kedar/neural_spike_sorting/kilosort_data"
LOCAL_PATH="/data5/Kedar/neural_spike_sorting/kilosort_data"

# important variables
batchesPerStore=4
channelsPerStore=256
channelsPerBatch=$(($channelsPerStore / $batchesPerStore))
stores=("RSn2" "RSn3")

# main
for d in ${date_list[@]}; do

  # make sure this date has recordings
  DATE_FOLDER_SERVER=$SERVER_PATH/$d
  DATE_FOLDER_LOCAL=$LOCAL_PATH/$a/$d

  if [ -d "$DATE_FOLDER_SERVER" ]; then
    # cd $DATE_FOLDER_SERVER

    # # get all directories, e.g. Pancho-220520-162344, Pancho-220520-164412
    # for f in ./*/; do
    #   # get basename
    #   session_name=$(basename $f)
		#   echo "--PROCESSING: ${session_name}"

    #   # create bin files (note: if createLocalBinsFSSF fails, this script terminates because of -e in 1st line)
		# 	bash $LOCAL_PATH/createLocalBinsFromServerSessionFolder.sh $a $d $session_name $batchesPerStore $channelsPerStore
		# done

    # combine .bins across sessions into one
    cd $DATE_FOLDER_LOCAL
    # # for each session in chronological order: combine .bin with other .bins for that store/batch
    # for s in ${stores[@]}; do
    #   for b in $(seq 1 $batchesPerStore); do
    #     sb=${s}_batch${b}
    #     bin_name=${sb}.bin
    #     mkdir $sb
    #     touch $sb/$bin_name
    #     # get list of sessions in chronological order, then add all their bins together
    #     for f in ./${a}-${d}-*/; do
    #       cat $f/$bin_name >> $sb/$bin_name
    #       #mv $f/${bin_name}_export.txt $sb/${bin_name}_export.txt
    #       # remove bin file that was copied
    #       rm $f/$bin_name
    #     done
    #   done
    # done


    # now run kilosort on the .bin files
    bash /data1/programs/MATLAB/R2021a/bin/matlab -batch "runKilosortMain('$a', '$d', ${batchesPerStore}, ${channelsPerBatch})"
  fi
  
done




