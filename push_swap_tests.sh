#!/bin/sh
#### Description: check various things for push_swap
#### Written by: jkettani

# -------- VARIABLES -------- 

TEMP_FILE=push_swap.tmp
CHECKER_PATH=../push_swap_checker
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
	printf ">>> %s <<<\n\n" "$1"
}

# Generate a list of ${3} random numbers between an upper ${2} and lower ${1} bound
random_nbr_list ()
{
	seq ${1} ${2} | shuf -n ${3} | tr '\n' ' ' | sed 's/ $//'
}

# Check input values used to generate the random list of numbers
check_bounds ()
{
	if [ ${1} -gt 999999 ] || [ ${1} -lt -999999 ] || [ ${1} -gt 999999 ] || [ ${1} -lt -999999 ]; then
		print_error "Error: choose numbers between -999999 and 999999 for the upper and lower bound"
		exit
	elif [ ${1} -gt ${2} ]; then
		print_error "Error: lower bound (${1}) superior to upper bound (${2})"
		exit
	elif [ ${3} -gt `echo "${2} - ${1}" | bc` ]; then
		print_error "Error: interval between upper (${2}) and lower (${1}) bound to small to countain ${3} values"
		exit
	fi
	return 0
}

# Estimate execution time (in seconds)
estimate_exec_time(){
	local timer_start=`gdate +%s%N`
	local nums=`random_nbr_list "$2" "$3" "$4"`
	local res=`./push_swap $nums 2> /dev/null | ./checker $nums 2> /dev/null | cat -e`
	local nb_instr=`./push_swap $nums 2> /dev/null | wc -l | bc`
	local timer_end=`gdate +%s%N`
	local timer_res=$(((timer_end - timer_start)/1000000))
	local total_exec_time=`echo "scale=3; ($timer_res * $1)/1000" | bc`
	echo $total_exec_time
}

# Display a progress bar based on the execution time given as argument (in seconds)
progress_bar (){
	local exec_time=${1}
	printf "Estimated duration: ${GREEN}%.3f${NC} second(s)\n\n" $exec_time
	local sleep_time=`echo "scale=3; $exec_time/10" | bc`
	printf "[ .................................................. ] 0%%\r"
	sleep $sleep_time
	printf "[ ${GREEN}▓▓▓▓▓${NC}............................................. ] 10%%\r"
	sleep $sleep_time
	printf "[ ${GREEN}▓▓▓▓▓▓▓▓▓▓${NC}........................................ ] 20%%\r"
	sleep $sleep_time
	printf "[ ${GREEN}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}................................... ] 30%%\r"
	sleep $sleep_time
	printf "[ ${GREEN}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}.............................. ] 40%%\r"
	sleep $sleep_time
	printf "[ ${GREEN}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}......................... ] 50%%\r"
	sleep $sleep_time
	printf "[ ${GREEN}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}.................... ] 60%%\r"
	sleep $sleep_time
	printf "[ ${GREEN}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}............... ] 70%%\r"
	sleep $sleep_time
	printf "[ ${GREEN}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}.......... ] 80%%\r"
	sleep $sleep_time
	printf "[ ${GREEN}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}..... ] 90%%\r"
	sleep $sleep_time
	printf "[ ${GREEN}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC} ] 100%%\r"
	printf "${NC}\n\n"
}

launch_tests() {
	print_header "PUSH_SWAP TESTS"
	printf "Estimate execution duration...\n"
	exec_time=`estimate_exec_time ${1} ${2} ${3} ${4}`
	progress_bar $exec_time &
	local progress_bar_pid=$!
	trap 'kill $progress_bar_pid; exit' SIGINT
	[ -f $TEMP_FILE ] && rm -f $TEMP_FILE
	local index=0
	local sum=0
	local max=0
	local min=10000000
	local nb_fail=0
	while [ "$index" -lt "$1" ];
	do
#		printf "> Test %03d:" $((index + 1)) | tee -a $TEMP_FILE
		local nums=`random_nbr_list "$2" "$3" "$4"`
#		printf " %s\n" "$nums" >> $TEMP_FILE
		res=`./push_swap $nums 2> /dev/null | ./checker $nums 2> /dev/null | cat -e`
		if [ "$res" = "OK$" ]; then
#			printf " ✅ "
			local nb_instr=`./push_swap $nums 2> /dev/null | wc -l | bc`
			sum=$((sum + nb_instr))
#			printf " - $nb_instr"
			[ "$nb_instr" -lt "$min" ] && min="$nb_instr"
			[ "$nb_instr" -gt "$max" ] && max="$nb_instr"
		else
			((nb_fail++))
#			printf " ❌ "
		fi
#		printf "\n"
#		[ "$index" -eq 0 ] && echo "total time = $total_exec_time second(s)"
		((index++))
	done
	local average=`echo "$sum/$index" | bc`
	wait $progress_bar_pid
	printf "> Inputs:\n"
	printf "  • nb of tests = %s\n" $1
	printf "  • lowest value = %s\n" $2
	printf "  • highest value = %s\n" $3
	printf "  • nb of elements = %s\n\n" $4
	printf "> Results:\n"
	printf "  • Average = %d\n" "$average"
	printf "  • Min = %d\n" "$min"
	printf "  • Max = %d\n" "$max"
	if [ "$nb_fail" -gt 0 ]; then
		print_error "\n$nb_fail test(s) failed"
	fi
}

display_usage(){
	printf "Usage: ./push_swap_checker.sh [option] nb_of_tests low high nb_of_elm\n"
	printf "Options:\n"
	printf "%s\n" " -a, --all                 Check everything"
	printf "%s\n" " -c, --checker             Check checker"
	exit
}

parse_args(){
	if ([ "$#" -lt 4 ] && [ "$#" -ne 1 ]) || [ "$#" -gt 5 ]; then
		display_usage
	fi
	if [ "$#" -eq 1 ]; then
		NO_ARGS=true
	fi
	if [ "$#" -eq 1 ] || [ "$#" -eq 5 ]; then
		local option="$1"
		if [ "$option" = "-a" ] || [ "$option" = "--all" ]; then
			ALL=true
			return
		elif [ "$option" = "-c" ] || [ "$option" = "--checker" ]; then
			CHECKER=true
		else
			display_usage
		fi
		shift
	fi
	NB_OF_TESTS="$1"
	LOW="$2"
	HIGH="$3"
	NB_ELM="$4"
}

ARGS="$@"
ALL=false
CHECKER=false
PRINT=false
NB_OF_TESTS=100
LOW=-2000
HIGH=2000
NB_ELM=100
NO_ARGS=false

parse_args $ARGS

if $ALL || $CHECKER; then
	if [ ! -f $CHECKER_SCRIPT_NAME ]; then 
		ln -s $CHECKER_SCRIPT
	fi
	sh $CHECKER_SCRIPT_NAME
fi

if $ALL; then
	launch_tests $NB_OF_TESTS $LOW $HIGH $NB_ELM
	NB_ELM=500
	launch_tests $NB_OF_TESTS $LOW $HIGH $NB_ELM
elif ! $NO_ARGS; then
	check_bounds $LOW $HIGH $NB_ELM
	launch_tests $NB_OF_TESTS $LOW $HIGH $NB_ELM
fi
