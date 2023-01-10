#!/usr/bin/env bash

#get parsed arguments
WORK_DIR=$1

#go to data dir
cd $WORK_DIR

#sometimes Matlab does not output all field delimiters when there is no data (,)
FIRST_LINE=$(head -1 'Data(corrected).csv' | grep ',')

if [[ -z $FIRST_LINE ]]
then
	#get line number where mass isotopomer data start
	LINE_NUMBER=$(grep -n 'Mass isotopomer abundances' 'Data(corrected).csv' | awk -F ':' '{print $1}')
	sed "1,${LINE_NUMBER}d" 'Data(corrected).csv' | grep -v '^,*$' > data_corrected_4processing_temp.csv
	
	#tidy up file
	sed 's/, *$//' data_corrected_4processing_temp.csv | cut -d, -f1-$(head -1 'data_corrected_4processing_temp.csv' | awk -F, '{print NF-2}')  > data_corrected_4processing.csv
	
	rm 'data_corrected_4processing_temp.csv'
else
	#get line number where mass isotopomer data start
	LINE_NUMBER=$(grep -n 'Mass isotopomer abundances' 'Data(corrected).csv' | awk -F ':' '{print $1}')

	#tidy up file
	#END=$(head -1 'Data(corrected).csv' | awk -F, '{print NF-2}')
	#cut -d, -f1-$END 'Data(corrected).csv' > data_corrected_4processing_temp.csv

	#output file with just mass isotopomer data
	sed "1,${LINE_NUMBER}d" 'Data(corrected).csv' | grep -v '^,*$' > data_corrected_4processing.csv
	#rm 'data_corrected_4processing_temp.csv'
fi





