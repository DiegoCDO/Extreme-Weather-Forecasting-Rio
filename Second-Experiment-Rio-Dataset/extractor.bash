#!/bin/bash

# Before using this script make sure the path data.archive exist
# and contains the archive of the AlertaRio website http://alertario.rio.rj.gov.br/download/
# The archive don't need to be renamed

# Extracting the Meteorological station archive
met_archive_list=$(ls data/archive/*Met*.zip)
mkdir -p "data/input/AlertaRio_DadosMet/"
while IFS= read -r file_path; do
	unzip "$file_path" -d "data/input/AlertaRio_DadosMet/"
done <<< $met_archive_list

# Extracting the Pluviometric station archive
pluv_archive_list=$(ls data/archive/*Pluv*.zip)
mkdir -p "data/input/AlertaRio_DadosPluv/"
while IFS= read -r file_path; do
	unzip "$file_path" -d "data/input/AlertaRio_DadosPluv/"
done <<< $pluv_archive_list

# Fix the name format of some files (some files in the meteorological station have random caracter at the end):
# data/input/AlertaRio_DadosMet/riocentro_201609_Met_ahlIdbJ.txt
# data/input/AlertaRio_DadosMet/riocentro_201610_Met_1D7kCbB.txt
# data/input/AlertaRio_DadosMet/sao_cristovao_201207_Met_2.txt
while IFS= read -r file_path; do
	echo "$file_path"
	mv -v "$file_path" "${file_path/_Met_*/_Met.txt}"
done <<< $(ls data/input/AlertaRio_DadosMet/*Met_*.txt)
