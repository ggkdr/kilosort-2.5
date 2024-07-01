#!/bin/bash

# "Auto" means you give it list of dates and it runs. 
# STeps:
# 1. Get list of dates by running ./6-printAllDatesPOst...
# 2. Copy here, and run.

animal="Pancho"
BASE_DIR_SERVER="/mnt/Freiwald/kgupta/neural_data/${animal}"
date_list=(220830 220531 220602 220603 220614 220616 220618 220621 220622 220624 220626 220627 220628 220630 220702 220703 220704 220706 220707 220709 220711 220714 220725 220727 220728 220730 220731)
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

