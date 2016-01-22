#!/bin/bash -   
#title          :SparCC.sh
#description    :Run SparCC pipiline (according to http://psbweb05.psb.ugent.be/conet/microbialnetworks/analysis.php)
#author         :Roey Angel
#date           :20150925
#version        :1.0    
#usage          :SparCC.sh OtuTable.tshared
#notes          :       
#bash_version   :4.3.30(1)-release
#============================================================================

. /etc/profile

# Set parameters
OtuTable=$1

# Set paths
SPARCC=/home/user/angel/Tools/SparCC/
RUNDIR=`pwd`"/"
WORKDIR=${RUNDIR}${OtuTable}_SparCC_Results
BS=100

if [ -d ${WORKDIR} ]
then
 rm -r ${WORKDIR}
fi

mkdir ${WORKDIR}
cp ${RUNDIR}${OtuTable} ${WORKDIR}
cd ${WORKDIR}

# Run SparCC pipeline
echo -e "Generating correlation matrix:" > ${RUNDIR}${OtuTable}_sparcc.log
echo -e "-----------------------------------" >> ${RUNDIR}${OtuTable}_sparcc.log
echo -e "SparCC.py ${OtuTable} -i 10 --cor_file=otuCountTable_sparcc.txt" >> ${RUNDIR}${OtuTable}_sparcc.log
# making the correlation matrix:
python ${SPARCC}SparCC.py ${OtuTable} -i 10 --cor_file=${OtuTable}_sparcc.txt >> ${RUNDIR}${OtuTable}_sparcc.log 2>&1
echo -e "-- \n" >> ${RUNDIR}${OtuTable}_sparcc.log

# Calculating bootstrap values:
echo -e "Calculating bootstrap values:" >> ${RUNDIR}${OtuTable}_sparcc.log
echo -e "-----------------------------------" >> ${RUNDIR}${OtuTable}_sparcc.log
echo -e "Generating shuffled datasets:" >> ${RUNDIR}${OtuTable}_sparcc.log
echo -e "MakeBootstraps.py ${OtuTable} -n ${BS} -o Resamplings/boot" >> ${RUNDIR}${OtuTable}_sparcc.log
mkdir Resamplings
python ${SPARCC}MakeBootstraps.py ${OtuTable} -n ${BS} -o Resamplings/boot >> ${RUNDIR}${OtuTable}_sparcc.log 2>&1
echo -e "-- \n" >> ${RUNDIR}${OtuTable}_sparcc.log

echo -e "SparCC.py Resamplings/boot_\$i.txt -i 10 --cor_file=Bootstraps/sim_cor_\$i.txt" >> ${RUNDIR}${OtuTable}_sparcc.log
mkdir Bootstraps
for i in $(seq 0 99)
do
SparCC_BS.sh $i 
done

# Wait untill bootstrapping is done
sleep 10m
while [[ `ls Bootstraps/sim_cor* | wc -w` -lt ${BS} ]]
do
  sleep 10m
done

cat Bootstraps/BS_*.log >> ${RUNDIR}${OtuTable}_sparcc.log
echo -e "-- \n" >> ${RUNDIR}${OtuTable}_sparcc.log

# Calculating p values
echo -e "Calculating p values:" >> ${RUNDIR}${OtuTable}_sparcc.log
echo -e "-----------------------------------" >> ${RUNDIR}${OtuTable}_sparcc.log
echo -e "PseudoPvals.py ${OtuTable}_sparcc.txt Bootstraps/sim_cor 10 -o pvals_two_sided.txt -t 'two_sided'" >> ${RUNDIR}${OtuTable}_sparcc.log
python ${SPARCC}PseudoPvals.py ${OtuTable}_sparcc.txt Bootstraps/sim_cor 10 -o pvals_two_sided.txt -t 'two_sided'  >> ${RUNDIR}${OtuTable}_sparcc.log 2>&1
echo -e "-- \n" >> ${RUNDIR}${OtuTable}_sparcc.log

# Clean up 
rm -f SparCC_BS.*
rm -f Bootstraps/*.log

echo "Done"