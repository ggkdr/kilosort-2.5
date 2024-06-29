#!/bin/bash

# load necessary variables and paths
#source /home/kgg/Desktop/kilosort-2.5/custom_pipeline_scripts/globals.sh
source /gorilla4/kilosort-2024/kilosort-2.5/custom_pipeline_scripts/globals.sh

a=$1
d=$2


# note: actual postprocessing datstruct etc. is already on server (/kgupta/neural_data/postprocess) but
# we also want to move the actual kilosorted data.
if [ -e $LOCAL_DATA_PATH/$a/$d/KS_done.txt ]; then
	# rsync transfer from local to server
	echo "uploading ${a}-${d} from ${LOCAL_DATA_PATH} to server.."

	# move entire date folder to server using rsync
	rsync -av --remove-source-files $LOCAL_DATA_PATH/$a/$d kgupta@${SERVER_URL}:/Freiwald/kgupta/neural_data/$a
	
	# move empty directories after rsync completes, to a folder that can be checked and deleted
	mkdir -p $LOCAL_DATA_PATH/$a/dates_transferred_to_server/$d
	mv $LOCAL_DATA_PATH/$a/$d $LOCAL_DATA_PATH/$a/dates_transferred_to_server/$d
elif [ ! -n "$(ls -A $LOCAL_DATA_PATH/$a/$d)" ]; then
	echo "did not convert or kilosort ${a}-${d}; maybe neural data isn't uploaded to server?"
elif [ ! -e "$(ls -A $LOCAL_DATA_PATH/$a/$d/RSn3_batch4/temp_wh.dat)" ]; then
	echo "interrupted kilosort for ${a}-${d}? did GPU fail?"
else
	# Not complete, so move to lemur2, instead of server.
	# Probably had bug or ran out of disk space.

	# rsync transfer from local to server
	echo "uploading ${a}-${d} from ${LOCAL_DATA_PATH} to backup drive: ${LOCAL_DATA_BACKUP_PATH}.."

	# move entire date folder to server using rsync
	# rsync -av --remove-source-files $LOCAL_DATA_PATH/$a/$d kgupta@${SERVER_URL}:/Freiwald/kgupta/neural_data/$a
	rsync -av --remove-source-files $LOCAL_DATA_PATH/$a/$d ${LOCAL_DATA_BACKUP_PATH}/$a/
	
	# move empty directories after rsync completes, to a folder that can be checked and deleted
	mkdir -p $LOCAL_DATA_PATH/$a/dates_transferred_to_lemur2/$d
	mv $LOCAL_DATA_PATH/$a/$d $LOCAL_DATA_PATH/$a/dates_transferred_to_lemur2/$d
fi