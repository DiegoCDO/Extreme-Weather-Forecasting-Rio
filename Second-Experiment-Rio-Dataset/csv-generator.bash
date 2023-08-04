#!/bin/bash

# Check the input parameter
if [[ $1 == "" ]]; then
    echo "wrong usage the station path must be added as an input parameter"
    exit
fi

if [[ $(pwd) == */input ]]; then
    cd ..
fi

if [[ $(pwd) != */data ]]; then
    cd data
fi

if [[ $(pwd) != */data ]]; then
    echo "Can't find the data folder, this script must be run under the data folder"
    echo "exiting..."
    exit
fi

path=$1
output_path="output/"$path
input_path="input/"$path

# Check if the path contains wether a Pluviometric or Meteorological station
if [[ $output_path == *AlertaRio_DadosPluv* ]]; then
    mode=1
elif [[ $output_path == *AlertaRio_DadosMet* ]]; then
    mode=2
else
    echo "The script is made to process only the AlertaRio met/pluv station"
    echo "Exiting..."
    exit
fi

process_file() {
    input_file_path=$1
    output_file_path=$2

    # Read the input file ignoring the headers line and changing the ND and - text to NA and shrinking the number of continuous spaces to 1.
    # As an example "1      8    7   80 -   ND" become  "1 8 7 80 NA NA"
    content_HBV=$(tail -n +5 $input_file_path | sed "s/\s\+/ /g; s/ND/NA/g; s/\s-\s/ NA /g")

    # Get the columns names and write it to the output file with a comma as name separator
    sed "s/HBV//g; s/\([a-Z]\)\s\+/\1,/g; s/\s//g; s/,$//g" <<<"$content_HBV" | head -n 1 >$output_file_path

    # The index is an offset that allow the script to ignore the second line that contains the unit of the values in the meteorological station
    index=$((1 + $mode))

    # If the file is empty (no data but contains a header), the output file only contains the columns name
    if [[ $(head -n $index <<<"$content_HBV" | wc -l) < $index ]]; then
        return
    fi

    # Memorize if the last time was summer or winter time (0 for winter and 1 for summer)
    last=0

    # Memorize the last line used to avoid to write the same exact same line 2 times
    last_line=""

    # Read the file and process it to write it to the output file
    while IFS= read -r line; do
        # Check if there is a problem with the summer time (NA value in HBV column) and fix it to have the write value instead
        if [[ ${line:20:2} == NA && $(grep -o "NA" <<< "$line" | wc -l) -ge 5 ]]; then
            if [[ $last == 0 ]]; then
                line=${line:0:20}$"NA,NA,NA,NA,NA"
            else
                line=${line:0:20}$"HBV,NA,NA,NA,NA,NA"
            fi
        fi

        # If the summer time is used for a line we reduce the time from 1h
        if [[ ${line:20:3} == HBV ]]; then
            last=1
            date=$(date '+%d/%m/%Y %H:%M:%S' -u -d "${line:6:4}/${line:3:2}/${line:0:2} ${line:11:8}Z - 1 hour")
            line="$date${line:23}"
        else
            last=0
        fi

        # If the 2 last lines are different, the new one is send to the output stream
        if [[ $last_line != $line ]]; then
            echo "$line"
        fi
        last_line=$line

    # Read the content of the file in which the spaces has been replaced by a comma
    done <<<$(tail -n +$index <<<"$content_HBV" | sed "s/\s\+/,/g") |
        # Write the stream to the output
        sed "s/\s/,/g; s/,$//" >>$output_file_path
}

# Create the directory for the output and get the list of txt input file
mkdir -p "$output_path"

file_list=$(ls $input_path*)

start_time=$(date +%s)

# Read the CSV file list
while IFS= read -r input_file_path; do
    # For each file the process_file function is runned to generate the CSV file
    input_file_name_without_ext=$(basename $input_file_path .txt)
    output_file_path="$output_path/${input_file_name_without_ext}.csv"

    process_file "$input_file_path" "$output_file_path"
done <<<$file_list

# Get the name of the station and the source (AlertaRio_DadosPluv or AlertaRio_DadosMet)
station=$(basename $output_path)
source=$(basename $(dirname $output_path))
mkdir -p "output/$source/full"

# Concatenate all the CSV files generated to an output file and sort the data by dates
head -n 1 "$(ls output/$source/$station/$station*.csv | head -n 1)" > output/$source/full/$station.csv
sed "/Dia/d" output/$source/$station/$station*.csv | sort -t',' -k1.7,1.10n -k1.4,1.5n -k1.1,1.2n -k2.1,2.2n -k2.4,2.5n -k2.7,2.8n | uniq >> output/$source/full/$station.csv

# Record the end time
end_time=$(date +%s)

# Calculate the elapsed time in seconds
elapsed_time=$((end_time - start_time))

# Print the elapsed time
echo "Elapsed time ($station): $elapsed_time seconds"
