#!/bin/bash

user=$(pwd | cut -d '/' -f3)

mkdir /home/$user/script2folder
dir="/home/$user/script2folder"
mkdir $dir/extractedfiles
mkdir $dir/Assignments

#this only works if file.tar.gz is in currect directory
#the pdf doesn't specify where the file will be so I can only assume

#IT WON'T RUN IF THERE IS NO file.tar.gz as it is now
tar -x -z -f file.tar.gz -C $dir/extractedfiles

Arr=()
while IFS=  read -r -d $'\0'
do
	Arr+=("$REPLY")
done < <(find $dir/extractedfiles -name "*.txt" -print0)

j=0
for i in "${Arr[@]}" 	
do
	((j++))

	found=0	
	while IFS= read -r line			
	do
		if [[ "$line" == "https"* && $found==0 ]] 	
			site=$line			#line is always the first i so it downloads the first repo 3 times
			found=1
		fi
	done < "$i"
	
	#cloning the site
	git clone -q $site "$dir/Assignments/repo$j"	
	if [ $? ] 
	then
		echo "$site: Cloning OK"
	else
		>&2 echo "$site: Cloning FAILED"
	((j--))
	fi
	
done

#this saves the number of directories inside the Assignment directory
nod=$(tree -L 1 "$dir/Assignments" | tail -1 | cut -d ' ' -f1)

k=1		
((nod++)) 		#starting from k=1 so this needs to be bigger by 1 to loop the proper amount of times, also doesn't enter loop if nod=0
while [[ $k -ne $nod ]]
do	
	temp=$(tree -i -f --noreport --dirsfirst "$dir/Assignments/repo$k")
	tree1=$(echo "$temp" | tr '\n' ' ' ) #can't use cut with newlines so replacing them with spaces

	temp2=$(tree $dir/Assignments/repo$k/)
	n_o_txt=$(find $dir/Assignments/repo$k/ -type f -name "*.txt" | wc -l)
	(( n_o_misc=$(echo "$temp2" | tail -1 | cut -d ' ' -f3) - $n_o_txt ))
	n_o_dir=$(echo "$temp2" | tail -1 | cut -d ' ' -f1 )	
	
	#checking if: the two files after a directory are inside it and if there is only 1 directory and 3 files in general inside the repo
	#due to the operands of tree if all the below arguments are true, the repo has the correct structure
	if [[ "$(echo $tree1 | cut -d ' ' -f2)/dataB.txt" == "$(echo $tree1 | cut -d ' ' -f3)" && "$(echo $tree1 | cut -d ' ' -f2)/dataC.txt" == "$(echo $tree1 | cut -d ' ' -f4)" && "$(echo $tree1 | cut -d ' ' -f1)/dataA.txt" == "$(echo $tree1 | cut -d ' ' -f5)" && $temp2 == *"1 directory, 3 files" ]]
	then
		echo "Number of directories: $n_o_dir"
		echo "Number of txt files: $n_o_txt"
		echo "Number of other files: $n_o_misc"
		echo "Directory structure is OK."
	else 
		echo "Number of directories: $n_o_dir"
		echo "Number of txt files: $n_o_txt"
		echo "Number of other files: $n_o_misc"
		echo "Directory structure is NOT OK."
	fi
	((k++))
done
