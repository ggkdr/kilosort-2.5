#!/bin/bash

# "Auto" means you give it list of dates and it runs. 
# STeps:
# 1. Get list of dates by running ./6-printAllDatesPOst...
# 2. Copy here, and run.

animal="Diego"
BASE_DIR_SERVER="/mnt/Freiwald/kgupta/neural_data/${animal}"
date_list=(230525 230527 230601 230605 230606 230607 230608 230609 230610 230612 230613 230626 230728 230730 230802 230804 230808 230809 230810 230811)
safe_mode=false
# within each date: have to go through folders with name *batch* and delete temp_wh.dat
for d in ${date_list[@]}; do
# for d in $BASE_DIR_SERVER/*/; do
	cd ${BASE_DIR_SERVER}/$d

	for dir in ./*batch*/; do
		bdir=$(basename $dir)
		# echo "${bdir}/temp_wh.dat"
		pwd
		if [ -f "${bdir}/temp_wh.dat" ]; then
			file_to_remove="${bdir}/temp_wh.dat"

			if ${safe_mode}; then
				read -r -p "Delete ${d}/${file_to_remove}? [y/N]: " response
				case "$response" in [yY][eE][sS]|[yY]) 
					echo -e "--Deleting ${file_to_remove}\n"; 
					rm $file_to_remove ;;
					*) echo -e "--SKIPPING ${file_to_remove}\n"
				esac
			else
				echo -e "--Deleting ${file_to_remove}\n"; 
				rm $file_to_remove;
			fi
		fi
	done
done

