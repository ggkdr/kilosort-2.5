
a=$1 # animal

echo "-- Checking status of postprocessing on all dates for this animal: $a"
LIST_DIR=(/mnt/Freiwald/kgupta/neural_data/postprocess/final_clusters) #/lemur2/kilosort_data /home/kgg/Desktop/kilosort_data /mnt/Freiwald/kgupta/neural_data_curated)
#PP_DIR=/mnt/Freiwald/kgupta/neural_data/postprocess/final_clusters/$a
DONE_DATES=()
PARTIAL_DATES=()
NONE_DATES=()
NO_POSTPROCESS_DATES=()
for DIR in ${LIST_DIR[@]}; do
	# DIR=/lemur2/kilosort_data/Pancho

	#echo "-- Checking this dir: $DIR/$a"
	# go thru all dates 
	cd "$DIR/$a"

	# get all dates for this animal
	for d in ./*/; do
		dat=$(basename $d)

		# postprocessing is all contained within server
		# echo "$f"
		#cd $dat
		if [ -f "${dat}/DATSTRUCT_CLEAN_MERGED.mat" ]; then
			#echo "$f -- Done!"
			DONE_DATES+=($dat)
		elif [ -f "${dat}/CLEAN_AFTER_MERGE/LIST_MERGE_SU.mat" ]; then
			#echo "$f -- Partial (no KS_done.txt)"
			PARTIAL_DATES+=($dat)
		elif [ ! -z "$(ls -A $dat)" ]; then # check that not empty
			NONE_DATES+=($dat)
		else
			NO_POSTPROCESS_DATES+=($dat)
		fi
		#cd ..
	done
done

# Now print all dates, sorted
# DONE_DATES=$(echo $DONE_DATES | xargs -n1 | sort | xargs)
# DONE_DATES=$(echo "$DONE_DATES" | tr ' ' '\n' | sort | tr '\n' ' ')
#readarray -td '' DONE_DATES < <(printf '%s\0' "${DONE_DATES[@]}" | sort -z)
#echo "-- COLLECTED ACROSS ALL DIRS:"
echo "Dates that have been curated AND finalized:"
for date in ${DONE_DATES[@]}; do
	# DIR=/lemur2/kilosort_data/Pancho
	echo "-- $date"
done

echo "Dates that have been curated, but NOT finalized:"
for date in ${PARTIAL_DATES[@]}; do
	# DIR=/lemur2/kilosort_data/Pancho
	echo "-- $date"
done

echo "Dates that have not been curated, but postprocessing has been run:"
for date in ${NONE_DATES[@]}; do
	# DIR=/lemur2/kilosort_data/Pancho
	echo "-- $date"
done

echo "Dates that need to have postprocessing run:"
for date in ${NO_POSTPROCESS_DATES[@]}; do
	# DIR=/lemur2/kilosort_data/Pancho
	echo "-- $date"
done