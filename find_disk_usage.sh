#!/bin/ksh
#This file is used to display the size of the disk usage in linux/solaris.
#Here the argument given to this file is 
#				1.Drive(or path the the folder from root) whose disk usage needs to be obtained
#				2.The threshold value for size beyond which give  the folder list
#				3.The maximum depth from the given drive or path to find the disk usgae
#sample call for this file: ./find_disk_usage.sh /A/ 30	3
#First we find the list of all the dirs upto the given depth and write in the temp file.
#Then we run du sh for all the listed dir and check if the size is greater than threshold.
#For the greater size we write in another file and display the result.
###################################################################
#########################################################################
#!/bin/ksh
#This file is used to display the size of the disk usage in linux/solaris.
#Here the argument given to this file is 
#				1.Drive(or path the the folder from root) whose disk usage needs to be obtained
#				2.The threshold value for size beyond which give  the folder list
#				3.The maximum depth from the given drive or path to find the disk usgae
#sample call for this file: ./find_disk_usage.sh /A/ 30	3
#First we find the list of all the dirs upto the given depth and write in the temp file.
#Then we run du sh for all the listed dir and check if the size is greater than threshold.
#For the greater size we write in another file and display the result.#########################################################################

rm display_disk_usage
rm processing
touch processing
touch display_disk_usage
v_now=$(date '+%Y%m%d_%H%M%S')
#filename=display_disk_usage
hostname=`hostname`
echo "********start time $v_now 	***********">>display_disk_usage
echo " "
echo "Finding Disk-uasge for the host: $hostname  in directory: $1 for threshold value $2:">>display_disk_usage

#sanity check check if p1, p2, p3 all are present
p1=$1
p2=$2
p3=$3
if [ "$1"  == "" ]; then  echo "ERROR:Param path name is blank/missing";   		 	    exit 1;    fi
if [ "$2"  == "" ]; then  echo "ERROR:Param Threshold value is blank/missing";    		exit 1;    fi
if [ "$3"  == "" ]; then  echo "ERROR:Param depth value is blank/missing";    		    exit 1;    fi
#remove the first and last  slash if given by the user in argument. We have included the slash in  it code. 
if [ $1 == "/" ];  #$1 is not 
then
p1=$1
else 

	first=`echo $1 | cut -c1-1`  #removes the first slash if there is any
	if [ "$first" == "/" ];
	then   
	p1=`echo $1 | sed 's/^.//'`   
	else p1=$1   
	fi
	last=`echo -n $p1 | tail -c -1` #remove the last slash if there is any
		if [ "$last" == "/" ];
		then
		p1=`echo $p1 | sed 's/.$//'`
		else
		p1=$p1
  fi
fi  
		
echo "Path:		/"$p1"/"
echo "Threshold : 	"$p2" GB"
echo "Depth of dir: "$p3
echo "hostname:" $hostname


# Name of this script file, without path.
script_file=${0##*/}
# Path to this script. Other scripts are there also. Full path is retrieved then dissected to get clean path.
script_path=$(whence $0) # whence returns full path and may include '.' or '..' if this script called using a relative path.
# If script_path has one or more '/./' in it, remove the '.' notation.
while [[ -z ${script_path##*/./*} ]]; do               # ${script_path##*/./*} is null if script_path contains a '/./'
  script_path=${script_path%/./*}/${script_path##*/./} # Remove the last "/./"
done
# If one or more ".." relative paths were used to call this script, remove them from script_path.
while [[ -z ${script_path##*/../*} ]]; do       # There is a ".." in the path.
  front_path=${script_path%%/../*}              # The path up to the first "..".
  front_path=${front_path%/*}                   # The front_path with the lowest level directory removed.
  # The path to the script file with the "next upper" level directory removed.
  script_path=${front_path}/${script_path#*/../} # Combine $front_path with everything after the first "..".
done
script_path=${script_path%/*}  # Remove the script file name and last / of the path.
echo $script_path


find /$p1/ -maxdepth $p3 -type d > testing #list all the dir in testing file
file="$script_path/testing"
while read line
do
echo `du -sh $line 2>/dev/null` >> processing  
     
done <"$file"
sed '/^$/d' processing > processing1

for list_dir in `awk '{print $2}' processing1`; do
				
				echo "Processing  dir = [${list_dir}]" 					
					size_of_dir=`du -sh $list_dir 2>/dev/null | awk '{print $1}' | sed -n -e '/^.*[0-9]G$/p' ` 2>/dev/null				   
				   sz=`echo $size_of_dir| awk '{print substr($0,1,(length($0)-1))}'`					
					if [ -z "$sz" ]; then 
					sz=1
					fi					
					if [ $sz -gt $2 ]  ## checks if the size is greater than 20 GB
					then						
					echo "$sz G $list_dir " >> display_disk_usage					
					else 				
					echo "$list_dir ">> deleting_temp
					fi
				done
			
			v_end=$(date '+%Y%m%d_%H%M%S')
			echo " "
			echo "********end time $v_end*********">>display_disk_usage
echo "Thee result is written in the file $script_path/display_disk_usage_$v_end"	
cat display_disk_usage>	display_disk_usage_$hostname_$v_end	

