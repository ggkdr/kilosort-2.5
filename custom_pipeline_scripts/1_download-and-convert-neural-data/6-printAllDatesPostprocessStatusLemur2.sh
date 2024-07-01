
a=$1 # animal
whichdir=$2 # lemur2, server, ...

echo "-- Checking status of postprocessing on all dates for this animal: $a"

if [ "$whichdir" = "lemur2" ]; then
	LIST_DIR=(/lemur2/kilosort_data) #/home/kgg/Desktop/kilosort_data /mnt/Freiwald/kgupta/neural_data /mnt/Freiwald/kgupta/neural_data_curated)
elif [ "$whichdir" = "server" ]; then
	LIST_DIR=(/mnt/Freiwald/kgupta/neural_data) #/home/kgg/Desktop/kilosort_data /mnt/Freiwald/kgupta/neural_data /mnt/Freiwald/kgupta/neural_data_curated)
else
	echo "ERROR: entire which directory as second argument!!"
fi
echo "** Looking at raw data dates here: $LIST_DIR"

# LIST_DIR=(/mnt/Freiwald/kgupta/neural_data) #/home/kgg/Desktop/kilosort_data /mnt/Freiwald/kgupta/neural_data /mnt/Freiwald/kgupta/neural_data_curated)
PP_DIR=/mnt/Freiwald/kgupta/neural_data/postprocess/final_clusters/$a
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
		# datpp=$(PP_DIR $d)

		# postprocessing is all contained within server
		# echo "$f"
		if [ -f "${PP_DIR}/${dat}/DATSTRUCT_CLEAN_MERGED.mat" ]; then
			#echo "$f -- Done!"
			DONE_DATES+=($dat)
		elif [ -f "${PP_DIR}/${dat}/CLEAN_AFTER_MERGE/LIST_MERGE_SU.mat" ]; then
			#echo "$f -- Partial (no KS_done.txt)"
			PARTIAL_DATES+=($dat)
		# elif [ ! -z "$(ls -A ${PP_DIR}/${dat})" ]; then # check that not empty
		elif [ -d "${PP_DIR}/${dat}" ] && [ ! -z "$(ls -A ${PP_DIR}/${dat})" ]; then # check that exists AND check that not empty
			NONE_DATES+=($dat)
		else
			# Then pp not even started.
			NO_POSTPROCESS_DATES+=($dat)
		fi
	done
done

# Now print all dates, sorted
# DONE_DATES=$(echo $DONE_DATES | xargs -n1 | sort | xargs)
# DONE_DATES=$(echo "$DONE_DATES" | tr ' ' '\n' | sort | tr '\n' ' ')
#readarray -td '' DONE_DATES < <(printf '%s\0' "${DONE_DATES[@]}" | sort -z)
#echo "-- COLLECTED ACROSS ALL DIRS:"
echo "(1) Dates that have been curated AND finalized:"
for date in ${DONE_DATES[@]}; do
	# DIR=/lemur2/kilosort_data/Pancho
	echo "-- $date"
done
echo "... as a list you can copy:"
echo "${DONE_DATES[*]}"

echo "(2) Dates that have been curated (by hand), but NOT finalized (did not run the final script):"
for date in ${PARTIAL_DATES[@]}; do
	# DIR=/lemur2/kilosort_data/Pancho
	echo "-- $date"
done
echo "... as a list you can copy:"
echo "${PARTIAL_DATES[*]}"

echo "(3) Dates that have not been curated, but postprocessing has been run:"
for date in ${NONE_DATES[@]}; do
	# DIR=/lemur2/kilosort_data/Pancho
	echo "-- $date"
done
echo "... as a list you can copy:"
echo "${NONE_DATES[*]}"

echo "(4) Dates that need to have postprocessing run:"
for date in ${NO_POSTPROCESS_DATES[@]}; do
	# DIR=/lemur2/kilosort_data/Pancho
	echo "-- $date"
done
echo "... as a list you can copy:"
echo "${NO_POSTPROCESS_DATES[*]}"
