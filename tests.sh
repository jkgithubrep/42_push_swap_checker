# -------- VARIABLES -------- 

EXEC_NAME=checker
OUT_FILE=out.tmp
VALGRIND_OUT_FILE=valgrind.tmp
CHECKER_PATH=../push_swap_checker
TESTS_PATH=$CHECKER_PATH
ACTIONS_FILES_PATH=$CHECKER_PATH/actions_files
TESTS_FILE=tests.txt

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m'

debug(){
	printf "%s: %s\n" "test_name" "$1"
	printf "%s: %s\n" "expected" "$2"
	printf "%s: %s\n" "args" "$3"
	printf "%s: %s\n" "actions" "$4"
	printf "%s: %s\n" "index" "$5"
}


nb_of_leaks(){
	valgrind ./$EXEC_NAME $1 < $ACTIONS_FILES_PATH/$2 > /dev/null 2> $VALGRIND_OUT_FILE
	local nb_leaks=`cat -v $VALGRIND_OUT_FILE | grep 'definitely lost' | tr -s " " | cut -d' ' -f4 | bc`
	rm -f $VALGRIND_OUT_FILE
	echo $nb_leaks
}

launch_test(){
	printf "> Test %03d:" $5
	if [ "$2" = "Error$" ]; then
		./$EXEC_NAME $3 >/dev/null 2> $OUT_FILE < $ACTIONS_FILES_PATH/$4
	else
		./$EXEC_NAME $3 2> /dev/null > $OUT_FILE < $ACTIONS_FILES_PATH/$4
	fi
	if [ "`cat -e $OUT_FILE`" = "$2" ]; then
		printf " ✅ "
	else
		printf " ❌ "
	fi
	printf " - leaks ?"
	local nb_of_leaks=`nb_of_leaks "$3" "$4"`
	if [ $nb_of_leaks -ne 0 ]; then
		printf "${RED} ✗ ($nb_of_leaks)${NC}"
	else
		printf "${GREEN} ✔${NC}"
	fi
	printf " - $1 (./checker $3 < $4)\n"
}

get_val(){
	echo "$1" | cut -d';' -f$2
}

index_in_arg(){
	index=$1
	shift
	while [ "$#" -gt 0 ];
	do
		if [ $index -eq $1 ]; then
			return 0
		fi
		shift
	done
	return 1
}

launch_tests(){
	local index=1	
	while read line
	do
		local test_name=`get_val "$line" 1`
		local expected=`get_val "$line" 2`
		local args=`get_val "$line" 3`
		local actions=`get_val "$line" 4`
		if $ALL || index_in_arg $index $ARGS; then
			launch_test "$test_name" "$expected" "$args" "$actions" $index
		fi
		shift
		((index++))
	done < $TESTS_PATH/$TESTS_FILE
	rm -f $OUT_FILE
}

check_args(){
	while [ "$#" -gt 0 ];
	do
		if ! echo $1 | grep -E -q '^[0-9]+$'; then
			return 0
		fi
		shift
	done
	return 1
}

ALL=true
ARGS="$@"

if check_args $ARGS; then
	exit
fi

if [ "$#" -ne 0 ];then
	ALL=false
fi

launch_tests
