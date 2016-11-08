#!/bin/bash

directory=`zenity --file-selection --title="Please, select the directory" --directory`
cd "$directory"
ls | egrep '[0-9]-Pos_' > position_list.txt
nbPositions=`awk 'END {print NR}' position_list.txt`
for (( i = 1; i <= nbPositions; i++ )); do
    position[$i]=`awk -v i=$i 'NR==i {print $0}' position_list.txt`
done

end=`zenity --entry --title="Last time point" --text="Enter the last relevant time point"`
(( end++ ))
end=`printf "%3d" $end | sed 's/ /0/g'`

c=${end:0:1}
d=${end:1:1}
u=${end:2:1}

prefix="img_0{6}"
suffix="_(PHASE|GFP|RFP)_000.tif"
if [ $u == 9 ]; then
    if [ $d == 9 ]; then
	timePoint="([$(( $c + 1))-9][0-9][0-9])"
    else
	timePoint="($c[$(( $d + 1 ))-9][0-9]|[$(( $c+1 ))-9][0-9][0-9])"
    fi
else
    if [ $d == 9 ]; then
	timePoint="($c$d[$u-9]|[$(( $c + 1))-9][0-9][0-9])"
    else
	timePoint="($c$d[$u-9]|$c[$(( $d + 1))-9][0-9]|[$(( $c+1 ))-9][0-9][0-9])"
    fi
fi
regex="$prefix$timePoint$suffix"
ls ${position[1]} | egrep $regex > deletedFiles_list.txt
nbDeletedFiles=`awk 'END {print NR}' deletedFiles_list.txt`
for (( i = 1; i <= nbDeletedFiles; i++ )); do
    deletedFile[$i]=`awk -v i=$i 'NR==i {print $0}' deletedFiles_list.txt`
done

for (( i = 1; i <= nbPositions; i++ )); do
    for (( j = 1; j <= nbDeletedFiles; j++)); do
	rm ${position[$i]}"/"${deletedFile[$j]}
    done
done
	


