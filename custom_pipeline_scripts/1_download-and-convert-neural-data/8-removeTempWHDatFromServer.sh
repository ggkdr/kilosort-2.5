#!/bin/bash

animal="Diego"
BASE_DIR_SERVER="/mnt/Freiwald/kgupta/neural_data/${animal}"
#date_list=(220715 220717 220918 220719 221217 221220 230103 230104 221218 230616 230622 230623 230105 230126 230125 230127 221024 221015 220915 230612 230613)

# within each date: have to go through folders with name *batch* and delete temp_wh.dat
#for d in ${date_list[@]}; do
for d in $BASE_DIR_SERVER/*/; do
	cd $d

	for dir in ./*batch*/; do
		bdir=$(basename $dir)
		if [ -f "${bdir}/temp_wh.dat" ]; then
			file_to_remove="${d}${bdir}/temp_wh.dat"

			read -r -p "Delete ${file_to_remove}? [y/N]: " response
			case "$response" in
				[yY][eE][sS]|[yY]) echo -e "--Deleting ${file_to_remove}\n"; rm $file_to_remove ;;
				*) echo -e "--SKIPPING ${file_to_remove}\n"
			esac
		fi
	done
done

