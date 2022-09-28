#!/usr/bin/env bash

#get line number where mass isotopomer data start
LINE_NUMBER=$(grep -n 'Mass isotopomer abundances' 'Data(corrected).csv' | awk -F ':' '{print $1}')

#tidy up file
END=$(head -1 'Data(corrected).csv' | awk -F, '{print NF-2}')
cut -d, -f1-$END 'Data(corrected).csv' > data_corrected_4processing_temp.csv

#output file with just mass isotopomer data
sed "1,${LINE_NUMBER}d" 'data_corrected_4processing_temp.csv' | grep -v '^,*$' > data_corrected_4processing.csv

rm 'data_corrected_4processing_temp.csv'



