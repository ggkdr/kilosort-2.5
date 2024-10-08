#!/bin/bash -e
# takes list of dates, creates .bin files in N batches (default N=8), and runs kilosort on all of them

# load necessary variables and paths
#source /home/kgg/Desktop/kilosort-2.5/custom_pipeline_scripts/globals.sh
source /gorilla4/kilosort-2024/kilosort-2.5/custom_pipeline_scripts/globals.sh
# #  mount hopfield using kgupta ssh key (-wx access)
# if [ ! -d /mnt/hopfield_data01 ]; then
#   #bash /mnt/mount_hopfield_kgupta.sh
#   hopfield_mount
# fi

kilosort_only=0

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
# date_list=(230120 220909) # LT, 
# date_list=(220929 220908) # LT, 
# date_list=( 221001 ) # LT, 
# date_list=(220906 221121 220925) # LT, 
# date_list=(230126 230127) # KGG
# date_list=(230125 220915) # KGG
# date_list=(230811) # KGG
# date_list=(220831 220916) # KGG
#date_list=(221117) # KGG
# date_list=(221023 220715 220606 220608 220609 220610 220718 230117 230118 230119 230124 230905 230910 230911 230918 230914 230919 230912 230920)

# date_list=(230124 230905 230910) # LT 10/14/23
#date_list=(230117 230919 230920 230921 230810 230928 230929 220829 221021) # KG 10/18/23

#date_list=(230919 230920 230921 230929 221119 231113 231114 230111 230105 230106 230108 230109 230608 230112 220812 220814 220816 220823 220824 20827 221118 230309 230308 221105)
#date_list=(230920 230921 231113 231114 230105 230106 230109 230608 230112 220812 220814 220816 220823 220824 220827 221118 230309 230308 221105)
#date_list=(221113 221114)
#date_list=(231114 230928 230929)
#date_list=(220709 220711 220714 220805 221201 220621 220622 220624 220531 220602 220603 220614 220616 220618 220626 220627 220628 220630 220702 220703 220704 220706 220707)
#date_list=(221002 221014 221125 231005 221128 221216 230602 231011 231101 231102 231103 231106 231109 231110 221016 221018 221116 230831 230904 231013 231018 231023 231024 231026  231027 230803)
#date_list=(231005 231101 231102 231103 221018 221116 230831 230904 231013 231018 231023 231024 231026 231027)
#date_list=(220531 220602 220603 220614 220616 220618 220622 220626 220627 220628 220630 220702 220704 220707 220709 220711 220725 220728 220730 220802 220803 220817 220818 220819 220822)
#date_list=(231005 220818 220819 220822 221112 230329 221002 221014 231101 231102 231103 231106 230831 230904 231024 231026 220728)
# date_list=(231005 230329 231101 231102 231103 231110 230831 230904)
# date_list=(240508 240509 240510 240515) # LT, pruned on 3/13/24, those I think already done.

date_list=(240521 240530 240604 240605 240606 240607 240612 240618 240619) # LT, pruned on 3/13/24, those I think already done.

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
  # echo "${SERVER_KILOSORT_DATA_PATH}/${a}/${d}/KS_done.txt"
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




