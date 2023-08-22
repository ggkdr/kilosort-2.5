
a=$1 # animal

echo "-- Checking kilosorted data for this animal: $a"
LIST_DIR=(/lemur2/kilosort_data /home/kgg/Desktop/kilosort_data /mnt/Freiwald/kgupta/neural_data /mnt/Freiwald/kgupta/neural_data_curated)
DONE_DATES=()
PARTIAL_DATES=()
for DIR in ${LIST_DIR[@]}; do
	# DIR=/lemur2/kilosort_data/Pancho

	echo "-- Checking this dir: $DIR/$a"
	# go thru all dates 
	cd "$DIR/$a"

	# get all directories, e.g. Pancho-220520-162344, Pancho-220520-164412
	for f in ./*/; do
		cd $f
		# echo "$f"
		if [ -f "KS_done.txt" ]; then
			echo "$f -- Done!"
			DONE_DATES+=($f)
		else
			echo "$f -- Partial (no KS_done.txt)"
			PARTIAL_DATES+=($f)
		fi
		cd ..
	done
done

# Now print all dates, sorted
# DONE_DATES=$(echo $DONE_DATES | xargs -n1 | sort | xargs)
# DONE_DATES=$(echo "$DONE_DATES" | tr ' ' '\n' | sort | tr '\n' ' ')
readarray -td '' DONE_DATES < <(printf '%s\0' "${DONE_DATES[@]}" | sort -z)
echo "-- COLLECTED ACROSS ALL DIRS:"
for date in ${DONE_DATES[@]}; do
	# DIR=/lemur2/kilosort_data/Pancho
	echo "$date -- Done!"
done

