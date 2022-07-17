#!/bin/bash

CACHE_DIR="/home/heeh/.leetcode"

TEXT_WIDTH=80

HEIGHT=0
WIDTH=0
CHOICE_HEIGHT=10
BACKTITLE=""
TITLE=""
MENU="Choose one of the following options:"

LIST_OPT=(1 "TODO Easy"
          2 "TODO Medium"
	  3 "DONE Easy"
	  4 "DONE Medium"
	  5 "Statatistics"
	  6 "Quit"
	 )

PROB_OPT=(1 "Show Problem"
          2 "Edit Solution"
	  3 "Test Solution"
	  4 "Submit Solution"
	  5 "Change Problem"
	  6 "Change Problem List"
	  7 "Quit"
	 )


function promptList() {
    LIST_CHOICE=$(dialog --clear \
			 --backtitle "$BACKTITLE" \
			 --title "$TITLE" \
			 --menu "$MENU" \
			 $HEIGHT $WIDTH $CHOICE_HEIGHT \
			 "${LIST_OPT[@]}" \
			 2>&1 >/dev/tty)
    if [ $? -eq 0 ]
    then
	echo $LIST_CHOICE
    else
	PROB_NUMBER=""
	if [ -e ${CACHE_DIR}/prob.txt ]
	   then
	       rm ${CACHE_DIR}/prob.txt
	fi
	if [ -e ${CACHE_DIR}/prob_cache.txt ]
	   then	
	       rm ${CACHE_DIR}/prob_cache.txt
	fi
    fi
}

function loadList() {
    if [ ! -e ${CACHE_DIR}/prob_cache.txt ]
    then
	touch ${CACHE_DIR}/prob_cache.txt
    fi
    local LIST_CHOICE=$1
    case $LIST_CHOICE in
	1)
	    leetcode list -c algorithms -q eD > ${CACHE_DIR}/prob_cache.txt
	    ;;
	2)
	    leetcode list -c algorithms -q mD > ${CACHE_DIR}/prob_cache.txt
	    ;;
	3)
	    leetcode list -c algorithms -q ed > ${CACHE_DIR}/prob_cache.txt
	    ;;
	4)
	    leetcode list -c algorithms -q md > ${CACHE_DIR}/prob_cache.txt
	    ;;
	5)
	    leetcode stat
	    read -p "Press enter to continue"
	    ;;		
	6)
	    clear
	    rm ${CACHE_DIR}/prob_cache.txt
	    exit
	    ;;	
    esac
}

function processList() {
    PROBLEMS=()
    while read -r s ; do
	index=$(echo "$s" | grep -o -E '[0-9]+' | head -1 )
	PROBLEMS+=("$index" "${s}")
    done < ${CACHE_DIR}/prob_cache.txt
    PROB_NUMBER=$(dialog --menu "$MENU" $HEIGHT $WIDTH $CHOICE_HEIGHT \
			 "${PROBLEMS[@]}" \
			 2>&1 >/dev/tty)
    if [ $? -eq 0 ]
    then
	echo $PROB_NUMBER
    else
	PROB_NUMBER=""
	rm ${CACHE_DIR}/prob.txt
	rm ${CACHE_DIR}/prob_cache.txt	
	break
    fi
}

function processProblem() {
    PROB_NUMBER=$1
    PROB_ACTION=$(dialog --menu "Problem Number: $PROB_NUMBER" $HEIGHT $WIDTH $CHOICE_HEIGHT \
			 "${PROB_OPT[@]}" \
			 2>&1 >/dev/tty)
    if [ $? -eq 0 ]
    then
	case $PROB_ACTION in
	    1)
		#	    leetcode pick "${PROB_NUMBER}" > ${CACHE_DIR}/prob.txt
		clear
		leetcode pick "${PROB_NUMBER}" | fold -w $TEXT_WIDTH -s > ${CACHE_DIR}/prob.txt
		dialog --textbox ${CACHE_DIR}/prob.txt $HEIGHT $WIDTH
		;;
	    2)
		leetcode edit "${PROB_NUMBER}" > ${CACHE_DIR}/prob.txt
		;;
	    3)
		clear
		leetcode test "${PROB_NUMBER}" | fold -w $TEXT_WIDTH -s > ${CACHE_DIR}/prob.txt
		dialog --textbox ${CACHE_DIR}prob.txt $HEIGHT $WIDTH
		;;
	    4)
		clear
		leetcode exec "${PROB_NUMBER}" | fold -w $TEXT_WIDTH -s > ${CACHE_DIR}/prob.txt
		dialog --textbox ${CACHE_DIR}/prob.txt $HEIGHT $WIDTH
		;;
	    5)
		PROB_NUMBER=""
		rm ${CACHE_DIR}/prob.txt
		;;
	    6)
		PROB_NUMBER=""
		rm ${CACHE_DIR}/prob.txt
		rm ${CACHE_DIR}/prob_cache.txt
		break
		;;

	    7)
		rm ${CACHE_DIR}/prob.txt
		rm ${CACHE_DIR}/prob_cache.txt
		rm ${CACHE_DIR}/stat.txt
		clear
		exit
		;;
	esac
    else
	PROB_NUMBER=""
	rm ${CACHE_DIR}/prob.txt
	rm ${CACHE_DIR}/prob_cache.txt
	break
    fi
}


function main() {
    while true; do
	if [ -e ${CACHE_DIR}/prob_cache.txt ]
	    then
		if [ ! -z "$PROB_NUMBER" ]  
		then
		    processProblem $PROB_NUMBER
		    clear
		else # no problem selected yet
		    PROB_NUMBER=$(processList)
		    clear
		fi
	else
	    PROB_NUMBER=""
	    LIST_CHOICE=$(promptList)
	    loadList $LIST_CHOICE

	fi
    done
}
 
main

