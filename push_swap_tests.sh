#!/bin/bash
#### Description: check various things for push_swap
#### Written by: jkettani

# -------- VARIABLES -------- 

PROJECT_PATH=../push_swap
PUSH_SWAP_EXEC=push_swap
CHECKER_EXEC=checker
TEMP_FILE=push_swap.tmp
VALGRIND_TMP_FILE=valgrind.tmp
CHECKER_PATH=.
CHECKER_SCRIPT_NAME=checker_tests.sh
CHECKER_SCRIPT=$CHECKER_PATH/$CHECKER_SCRIPT_NAME

# Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
GREEN_BG='\033[1;32;42m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
NC='\033[0m'

# -------- FUNCTIONS -------- 

# Print error message
print_error(){
	printf "${RED}%s${NC}\n" "$1"
}

# Print message ok
print_ok(){
	printf "${GREEN}%s${NC}\n" "$1"
}

# Print header
print_header ()
{
	printf "\n====== ${BLUE}%s${NC} ======\n\n" "$1"
}

# Generate a list of ${3} random numbers between an upper ${2} and lower ${1} bound
random_nbr_list ()
{
	seq ${1} ${2} | shuf -n ${3} | tr '\n' ' ' | sed 's/ $//'
}

nb_of_leaks(){
	valgrind $PROJECT_PATH/$PUSH_SWAP_EXEC $1 > /dev/null 2> $VALGRIND_TMP_FILE
	local nb_leaks=`cat -v $VALGRIND_TMP_FILE | grep 'definitely lost' | tr -s " " | cut -d' ' -f4 | bc`
	rm -f $VALGRIND_TMP_FILE
	echo $nb_leaks
}

# Estimate execution time (in seconds)
estimate_exec_time(){
	local timer_start=`gdate +%s%N`
	local nums=`random_nbr_list "$2" "$3" "$4"`
	local res=`$PROJECT_PATH/push_swap $nums 2> /dev/null | $PROJECT_PATH/checker $nums 2> /dev/null | cat -e`
	if $LEAKS; then
		nb_leaks=`nb_of_leaks $nums`
	fi
	local nb_instr=`$PROJECT_PATH/push_swap $nums 2> /dev/null | wc -l | bc`
	local timer_end=`gdate +%s%N`
	local timer_res=$(((timer_end - timer_start)/1000000))
	local total_exec_time=`echo "scale=3; ($timer_res * $1)/1000" | bc`
	echo $total_exec_time
}

# Display a progress bar based on the execution time given as argument (in seconds)
progress_bar (){
	local exec_time=${1}
	local sleep_time=`echo "scale=3; $exec_time/10" | bc`
	printf ".................................................. 0%%\r"
	sleep $sleep_time
	printf "${GREEN}▓▓▓▓▓${NC}............................................. 10%%\r"
	sleep $sleep_time
	printf "${GREEN}▓▓▓▓▓▓▓▓▓▓${NC}........................................ 20%%\r"
	sleep $sleep_time
	printf "${GREEN}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}................................... 30%%\r"
	sleep $sleep_time
	printf "${GREEN}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}.............................. 40%%\r"
	sleep $sleep_time
	printf "${GREEN}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}......................... 50%%\r"
	sleep $sleep_time
	printf "${GREEN}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}.................... 60%%\r"
	sleep $sleep_time
	printf "${GREEN}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}............... 70%%\r"
	sleep $sleep_time
	printf "${GREEN}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}.......... 80%%\r"
	sleep $sleep_time
	printf "${GREEN}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}..... 90%%\r"
	sleep $sleep_time
	printf "${GREEN}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC} 100%%\r"
	printf "${NC}\n"
}

print_test() {
	index_rfmt=`printf "%03d" $1`
	grep "Test $index_rfmt" $TEMP_FILE | cut -d ':' -f 2 | cut -c 2-
}

launch_tests() {
	print_header "PUSH_SWAP TESTS"
	printf "Estimate execution duration...\n"
	exec_time=`estimate_exec_time ${1} ${2} ${3} ${4}`
	printf "Estimated duration: ${GREEN}%.3f${NC} second(s)\n\n" $exec_time
	if ! $VERBOSE; then
		progress_bar $exec_time &
		local progress_bar_pid=$!
		trap 'kill $progress_bar_pid; exit' SIGINT
	fi
	[ -f $TEMP_FILE ] && rm -f $TEMP_FILE
	local index=0
	local sum=0
	local max=0
	local min_index=0
	local max_index=0
	local min=10000000
	local nb_fail=0
	local has_leaks=false
	while [ "$index" -lt "$1" ];
	do
		if $VERBOSE; then
			printf "⇢  Test %03d:" $((index + 1)) | tee -a $TEMP_FILE
		else
			printf "⇢  Test %03d:" $((index + 1)) >> $TEMP_FILE
		fi
		local nums=`random_nbr_list "$2" "$3" "$4"`
		printf " %s\n" "$nums" >> $TEMP_FILE
		res=`$PROJECT_PATH/push_swap $nums 2> /dev/null | $PROJECT_PATH/checker $nums 2> /dev/null | cat -e`
		if [ "$res" = "OK$" ]; then
			$VERBOSE && printf " ✅"
			if $LEAKS; then
				local nb_of_leaks=`nb_of_leaks $nums`
				if [ "$nb_of_leaks" -ne 0 ]; then
					has_leaks=true
					$VERBOSE && printf " - leaks ?"
					$VERBOSE && printf "${RED} ✗ ($nb_of_leaks)${NC}\n"
				fi
			fi
			local nb_instr=`$PROJECT_PATH/push_swap $nums 2> /dev/null | wc -l | bc`
			sum=$((sum + nb_instr))
			$VERBOSE && printf " - $nb_instr"
			[ "$nb_instr" -lt "$min" ] && min="$nb_instr" && min_index="$((index + 1))"
			[ "$nb_instr" -gt "$max" ] && max="$nb_instr" && max_index="$((index + 1))"
		else
			((nb_fail++))
			$VERBOSE && printf " ❌ "
		fi
		$VERBOSE && printf "\n"
		((index++))
	done
	local average=`echo "$sum/$index" | bc`
	wait $progress_bar_pid
	printf "\nInputs\n"
	printf "  → nb of tests: %s\n" $1
	printf "  → lowest value: %s\n" $2
	printf "  → highest value: %s\n" $3
	printf "  → nb of elements: %s\n\n" $4
	printf "Results\n"
	printf "  ⤷ Average: ${YELLOW}%d${NC}\n" "$average"
	printf "  ⤷ Min: ${YELLOW}%d${NC}\n" "$min"
	printf "  ⤷ Max: ${YELLOW}%d${NC}\n" "$max"
	printf "  ⤷ Worst case:\n"
	print_test $max_index
	printf "  ⤷ Best case:\n"
	print_test $min_index
	if $LEAKS; then
		printf "  ⤷ Leaks:"
		$has_leaks && printf " ${RED}yes${NC}\n" || printf " ${GREEN}no${NC}\n"
	fi
	if [ "$nb_fail" -gt 0 ]; then
		printf "\n"
		print_error "➞ $nb_fail test(s) failed"
	fi
	printf "\n"
}

display_usage(){
	printf "Usage: sh push_swap_tests.sh [options] nb_of_tests lower_bound upper_bound nb_of_elm\n"
	printf "Example:\n"
	printf "%s\n" " sh push_swap_tests.sh -c 150 -200 200 100"
	printf "%s\n" "      > test checker"
	printf "%s\n" "      > run 150 different tests with generated lists of 100 random numbers between -200 and 200"
	printf "Options:\n"
	printf "%s\n" " -h, --help                Display usage"
	printf "%s\n" " -a, --all                 Check everything"
	printf "%s\n" " -c, --checker             Check checker"
	printf "%s\n" " -v, --verbose             Print tests"
	exit
}

args_are_numeric_values(){
	while [ "$#" -gt 0 ];
	do
		if ! echo $1 | grep -E -q '^[0-9-][0-9]*$'; then
			return 1
		fi
		shift
	done
	return 0
}

is_option(){
	if [ ${1:0:1} = "-" ] || [ ${1:0:2} == "--" ]; then
		return 0
	else
		return 1
	fi
}

parse_args(){
	if [ $# -eq 0 ]; then
		display_usage
	fi
	if is_option $1; then
		while is_option $1;
		do
			local option="$1"
			if [ "$option" = "-a" ] || [ "$option" = "--all" ]; then
				ALL=true
				return
			elif [ "$option" = "-h" ] || [ "$option" = "--help" ]; then
				display_usage
			elif [ "$option" = "-c" ] || [ "$option" = "--checker" ]; then
				CHECKER=true
			elif [ "$option" = "-v" ] || [ "$option" = "--verbose" ]; then
				VERBOSE=true
			elif [ "$option" = "-l" ] || [ "$option" = "--leaks" ]; then
				LEAKS=true
			else
				display_usage
			fi
			shift
		done
	fi
	if [ $# -ne 4 ]; then
		display_usage
	fi
	NB_OF_TESTS="$1"
	LOW="$2"
	HIGH="$3"
	NB_ELM="$4"
}

# Check that the commands given as arguments are installed
check_command_availability(){
	while [ $# -gt 0 ];
	do
		command=`command -v $1`
		if [ $? -ne 0 ]; then
			printf "You dont\'t seem to have \`%s\' installed.\n" "$1"
			if [ "$1" = "shuf" ]; then
				printf "\`brew install coreutils\' to get it.\n"
			elif [ "$1" = "gdate" ]; then
				printf "\`brew install coreutils\' to get it.\n"
			elif [ "$1" = "valgrind"]; then
				printf "\`brew install valgrind\' to get it.\n"
			fi
			exit 1
		fi
		shift
	done
	return 0
}

# Verify that the project has been compiled
check_executables(){
	local missing=false
	if [ ! -f $PROJECT_PATH/$PUSH_SWAP_EXEC ]; then
		printf "%s\n" "$PUSH_SWAP_EXEC executable is missing."
		missing=true
	fi
	if [ ! -f $PROJECT_PATH/$CHECKER_EXEC ]; then
		printf "%s\n" "$CHECKER_EXEC executable is missing."
		missing=true
	fi
	if $missing; then
		local answer=empty
		while [ "$answer" != "y" ] && [ "$answer" != "n" ];
		do
			printf "%s\n" "Would you like to compile the missing executables? (y or n)"
			read answer
		done
		if [ "$answer" = "y" ]; then
			make -C $PROJECT_PATH
		else
			exit
		fi
	fi
	if [ ! -f $PROJECT_PATH/$PUSH_SWAP_EXEC ] || [ ! -f $PROJECT_PATH/$CHECKER_EXEC ]; then
		printf "%s\n" "Compilation failed"
		exit
	fi
}

# Check input values used to generate the random list of numbers
check_bounds ()
{
	local nb_tests=$1
	local low=$2
	local high=$3
	local nb_elm=$4
	if [ $nb_tests -eq 0 ]; then
		print_error "Error: number of tests to run is 0"
		exit
	elif [ $low -gt 999999 ] || [ $low -lt -999999 ] || [ $high -gt 999999 ] || [ $high -lt -999999 ]; then
		print_error "Error: choose numbers between -999999 and 999999 for the upper and lower bound"
		exit
	elif [ $low -gt $high ]; then
		print_error "Error: lower bound ($low) superior to upper bound ($high)"
		exit
	elif [ $nb_elm -gt `echo "$high - $low + 1" | bc` ]; then
		print_error "Error: interval between upper ($high) and lower ($low) bound to small to countain $nb_elm values"
		exit
	fi
	return 0
}

ARGS="$@"
ALL=false
CHECKER=false
VERBOSE=false
LEAKS=false
NB_OF_TESTS=100
LOW=-1000
HIGH=1000
NB_ELM=100
NO_ARGS=false

check_command_availability "shuf" "gdate"

parse_args $ARGS

if $ALL || $CHECKER || $LEAKS; then
	check_command_availability "valgrind"
fi

if $LEAKS; then
	printf "${YELLOW}%s${NC}\n" "Warning: leaks flag selected, this will increase the duration of the tests"
	sleep 1
fi

if ! args_are_numeric_values $NB_OF_TESTS $LOW $HIGH $NB_ELM; then
	display_usage
fi

check_executables

if $ALL || $CHECKER; then
	sh $CHECKER_SCRIPT_NAME
fi

if $ALL; then
	launch_tests $NB_OF_TESTS $LOW $HIGH $NB_ELM
	NB_OF_TESTS=20
	NB_ELM=500
	launch_tests $NB_OF_TESTS $LOW $HIGH $NB_ELM
else
	check_bounds $NB_OF_TESTS $LOW $HIGH $NB_ELM
	launch_tests $NB_OF_TESTS $LOW $HIGH $NB_ELM
fi
