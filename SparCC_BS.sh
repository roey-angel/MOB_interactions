#!/bin/bash -   
#title          :SparCC_BS.sh
#description    :Run SparCC bootstrap part
#author         :Roey Angel
#date           :20150925
#version        :1.0    
#usage          :SparCC_BS.sh OtuTable.tshared
#notes          :       
#bash_version   :4.3.30(1)-release
#============================================================================

. /etc/profile

# Set parameters
i=$1
WORKDIR=`pwd`"/"
SPARCC=SparCC/

python ${SPARCC}SparCC.py ${WORKDIR}Resamplings/boot_$i.txt -i 10 --cor_file=Bootstraps/sim_cor_$i.txt >> ${WORKDIR}Bootstraps/BS_${i}.log