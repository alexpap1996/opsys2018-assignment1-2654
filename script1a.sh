#!/bin/bash

#this won't run if there are no "myfile.txt" and "arrayfile.txt" in the current directory

file="$PWD/myfile.txt"
i=-1
declare -A Arr
touch $PWD/arrayfile.txt

arrFile="$PWD/arrayfile.txt" 
while IFS= read -r line || [[ -n "$line" ]] 	
do						
	key=$(echo $line | cut -d ' ' -f1)	#I use an associative array "Arr"
	value=$(echo $line | cut -d ' ' -f2)	#put the URLS into the "key" fields of the array
	Arr[$key]=" $value"			#and the md5 sum as values,
done < "$arrFile"				#with a space in the beginning to be used as a delimiter later

i=${#Arr[@]}					#if the array is populated we take its size and use it to add new sites into it

while IFS= read -r line || [[ -n "$line" ]]
do
	md=-1	
	exists=0
	k=-1
	
	if [[ "$line" != \#* ]] 
	then
		if s=$(wget -q -O - $line)
		then
			echo > /dev/null
		else
			echo $line 'FAILED'
		fi	

		md=$(echo $s | md5sum | cut -d " " -f1) 
		
		for j in "${!Arr[@]}"        
		do
			if [[ "$line" == "$j" ]]
			then
				exists=1
				k=$j
			fi
		done

		if (( $exists==0 )) 
		then
			Arr[$line]=" $md"
			((i++))
			
			echo $line 'INIT'
		else
			if [ "$md" != "$(echo ${Arr[j]} | cut -d' ' -f2)" ]
			then
				Arr[$line]=" $md"
				echo "$line already exists but is changed"
			fi
		fi	
	fi
done < "$file"

#delete all contents of arrayfile.txt, so I can just append the whole array in an empty file
> $arrFile

for j in "${!Arr[@]}"       
do
	printf "%s" "$j" >> $arrFile		
	printf "%s\n" "${Arr[$j]}" >> $arrFile	
done
