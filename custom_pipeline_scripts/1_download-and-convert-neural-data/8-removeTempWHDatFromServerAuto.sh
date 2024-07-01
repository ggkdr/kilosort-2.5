#!/bin/bash

# "Auto" means you give it list of dates and it runs. 
# STeps:
# 1. Get list of dates by running ./6-printAllDatesPOst...
# 2. Copy here, and run.

animal="Diego"
BASE_DIR_SERVER="/mnt/Freiwald/kgupta/neural_data/${animal}"
date_list=(230614 230615 230616 230617 230618 230619 230621 230622 230623 230624 230625 230627 230628 230629 230630 230703 230704 230705 230707 230711 230713 230717 230719 230723 230724 230726 230727 230915 230924 231120 231121 231122 231128 231130 231201 231204 231205 231206 231207 231211 231213 231218 231219)

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

			read -r -p "Delete ${d}/${file_to_remove}? [y/N]: " response
			case "$response" in
				[yY][eE][sS]|[yY]) echo -e "--Deleting ${file_to_remove}\n"; rm $file_to_remove ;;
				*) echo -e "--SKIPPING ${file_to_remove}\n"
			esac
		fi
	done
done

