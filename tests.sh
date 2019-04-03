EXEC_NAME=checker
OUT_FILE=out.tmp
CHECKER_PATH=../push_swap_checker
TESTS_PATH=$CHECKER_PATH
ACTIONS_FILES_PATH=$CHECKER_PATH/actions_files
TESTS_FILE=tests.txt

launch_test(){
#	printf "%s: %s\n" "test_name" "$1"
#	printf "%s: %s\n" "expected" "$2"
#	printf "%s: %s\n" "args" "$3"
#	printf "%s: %s\n" "actions" "$4"
#	printf "%s: %s\n" "index" "$5"
	printf "> Test %03d:" $5
	if [ "$2" = "Error$" ]; then
		./$EXEC_NAME "$3" >/dev/null 2> $OUT_FILE < $ACTIONS_FILES_PATH/$4
	else
		./$EXEC_NAME "$3" 2> /dev/null > $OUT_FILE < $ACTIONS_FILES_PATH/$4
	fi
	if [ "`cat -e $OUT_FILE`" = $2 ]; then
		printf " ✅ "
	else
		printf " ❌ "
	fi
	printf " - $1 (./checker $3 < $4)\n"
}

get_val(){
	echo "$1" | cut -d';' -f$2
}

launch_tests(){
	local index=1	
	while read line
	do
		local test_name=`get_val "$line" 1`
		local expected=`get_val "$line" 2`
		local args=`get_val "$line" 3`
		local actions=`get_val "$line" 4`
		launch_test "$test_name" "$expected" "$args" "$actions" $index
		((index++))
	done < $TESTS_PATH/$TESTS_FILE
	rm -f $OUT_FILE
}

launch_tests
