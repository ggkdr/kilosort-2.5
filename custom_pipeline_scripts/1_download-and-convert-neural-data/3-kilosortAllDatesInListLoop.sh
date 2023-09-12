#!/bin/bash -e
# takes list of dates, creates .bin files in N batches (default N=8), and runs kilosort on all of them

# load necessary variables and paths
source /home/kgg/Desktop/kilosort-2.5/custom_pipeline_scripts/globals.sh

# #  mount hopfield using kgupta ssh key (-wx access)
# if [ ! -d /mnt/hopfield_data01 ]; then
#   #bash /mnt/mount_hopfield_kgupta.sh
#   hopfield_mount
# fi

a="Pancho"
# date_list=(220930 221014 221020 221031 221102 221107 221114 221121 221125)
# date_list=(221020 220930 221014 221031 221102 221107 221114 221121 221125)
# date_list=(220715 220709 220714 230105)
# date_list=(221020 220715 221014 220714 220709 220930)
#date_list=(220716 220717 230106 221031 221102 221107 221114 221121 221125)

# Before 6/16/23
# date_list=(220709 220714 220716 220717 220930 221014 221107 221114 221121 221125 230106)

# 6/16/23 - LT added:
#date_list=(230105 230108 230109 221031 221102 220727 220731)
#date_list=(220621 220624 220703 220706 220715 220805)
# date_list=(220815)
# date_list=(220815)
# date_list=(230620)
# date_list=(230621 230622 230623 230626) # LT, 8/15/23
# date_list=(221015 221024 221220 230616) # LT, 8/17/23
# date_list=(221015 221024) # LT, 8/18/23
# date_list=(220724 220918 220719 221217) # LT, 8/21/23
# date_list=(230103 230104 221218 230612) # LT, 8/21/23
# date_list=(230613 230105) # LT, 
# date_list=(230108 230109) # LT, 
# date_list=(230608 230615) # LT, 
# date_list=(230122) # LT, 
date_list=(230120 220909) # LT, 

# # LOGGING DATES TO DO (8/21/23)
# # singleprims
# 
# 
# 

# # complexvar

# # pig
# 
# 
# 
# 
# 

# 230811 - SKIP, too large for GPU for now...

# # chars
# 
# 
# 230125
# 230126
# 230127

# # AnBm
# 220831
# 220901
# 220902
# 220906
# 220908
# 

# #AnBmCk

# # dir vs dir vs superv
# 221017

# # dir vs. dir
# 221117
# 221119
# 221121

# # AnBm vs. sup
# 220915
# 220916
# 220925
# 220929

# # AnBm vs. dir vs. sup
# 221001

# # dir vs. dir vs. shape
# 221023
# 221021

# # rowcol
# 230307
# 230306
# 230320
# 230310

# main
for d in ${date_list[@]}; do
  logfile="log_kilosortOneDate_${d}.txt"
  touch ${logfile}	
  # bash ./3-kilosortOneDate.sh $a $d 2>&1 | tee ${logfile} &
  /usr/bin/time -v ./3-kilosortOneDate.sh $a $d 2>&1 | tee ${logfile} &
done




