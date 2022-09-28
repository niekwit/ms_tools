#!/usr/bin/env bash

#get line number where mass isotopomer data start
LINE_NUMBER=$(grep -n 'Mass isotopomer abundances' 'Data(corrected).csv' | awk -F ':' '{print $1}')

#output file with just mass isotopomer data
sed "1,${LINE_NUMBER}d" 'Data(corrected).csv' | grep -v '^,*$' > data_corrected_4processing.csv
