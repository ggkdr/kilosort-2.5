#!/bin/bash -e
# takes list of dates, creates .bin files in N batches (default N=8), and runs kilosort on all of them

# load necessary variables and paths
source /home/kgg/Desktop/kilosort-2.5/custom_pipeline_scripts/globals.sh

# #  mount hopfield using kgupta ssh key (-wx access)
# if [ ! -d /mnt/hopfield_data01 ]; then
#   #bash /mnt/mount_hopfield_kgupta.sh
#   hopfield_mount
# fi

kilosort_only=0

a="Diego"
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
# date_list=(230120 220909) # LT, 
# date_list=(220929 220908) # LT, 
# date_list=( 221001 ) # LT, 
# date_list=(220906 221121 220925) # LT, 
# date_list=(230126 230127) # KGG
# date_list=(230125 220915) # KGG
# date_list=(230811) # KGG
# date_list=(220831 220916) # KGG
#date_list=(221017) # KGG
# date_list=(221117 220921 230923 230811 230810 230829 230826 230824 230928 230929 221020 221019 220830 220829 221021 221119)

# date_list=(230911) # LT 10/14/23
#date_list=(221117 221119 230306 231113 231114 220921 220920 220928 220926) # KG 10/18/23
#date_list=(230823 230824 230825 230827 230917 230918 230919 230719 230920 230921 230922 231001 230705 230703)
#date_list=(231122 231128 231129 231120 231121)
#date_list=(220618 220825 220817 220818 220819 220822 221113 221114 221111 221112 220830 220911 221001 230731 230329 220725 220727 220728 220730 220731 210802 220803)
#date_list=(230621 231005 230525 230527 230601 230605 230606 230607 230608 230609 230610 230612 230622 230623 231219 231220 230525 230527 230601 230613 231209 231214 231215)
#date_list=(230601 230622 230623 231219 231220 230525 231214 231215 231103 231110 231111 231112 231114 231026 231027 231029 230810 230811)
#date_list=(220825 220911 221002 221014 221016 221018 221111 221116 221125 221128 221201 221216 230329 230602 230731 230831 230904 231011 231013 231018 231023 231024 231026 231106 231109 231110)
#date_list=(230606 231130 231201 231204 231205 231206 231207 231211 231213 231218 231219 231209 231214 231215 231017 230814 231101)
# date_list=(231214 231215 230814 231103 231110 231114 231115 231026 231027 231029)
# date_list=(231214 231215 231103 231110 231114 231115 231026 231027 231029) # LT, pruned on 3/13/24, those I think already done.
date_list=(231214 231215 231103 231110 231114) # LT, pruned on 3/13/24, those I think already done.

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

#  - SKIP, too large for GPU for now...

# # AnBm
# 
# 220901
# 220902
# 
# 
# 

# #AnBmCk

# # dir vs dir vs superv
# 

# # dir vs. dir
# 
# 221119
# 

# # AnBm vs. sup
# 
# 
# 
# 

# # AnBm vs. dir vs. sup
# 

# # dir vs. dir vs. shape
# 
# 221021

# # rowcol
# 230307
# 230306
# 230320
# 230310

# Command to track gpu usage.
# touch gpu_log.txt && nvidia-smi dmon -s mu -d 5 -o TD >> gpu_log.txt 

# main
for d in ${date_list[@]}; do
  if [ -f "${SERVER_KILOSORT_DATA_PATH}/${a}/${d}/KS_done.txt" ]; then
    echo "${d} kilosort full run is found on server... SKIPPING"
    continue
  fi
  logfile="log_kilosortOneDate_${d}.txt"
  touch ${logfile}  
  # bash ./3-kilosortOneDate.sh $a $d 2>&1 | tee ${logfile} &

  # NOTE: this runs in parallel, but we are instead running in serial and then running 3 of these scripts in parallel.
  #/usr/bin/time -v ./3-kilosortOneDate.sh $a $d 2>&1 | tee ${logfile} &
  /usr/bin/time -v ./3-kilosortOneDate.sh $a $d $kilosort_only 2>&1 | tee ${logfile}
  ./7-uploadKilosortedDayFromLocalToServer.sh $a $d &
done





