# -------- VARIABLES -------- 

TEMP_FILE=push_swap.tmp
CHECKER_PATH=../push_swap_checker
CHECKER_SCRIPT_NAME=checker_tests.sh
CHECKER_SCRIPT=$CHECKER_PATH/$CHECKER_SCRIPT_NAME

# Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
NC='\033[0m'

print_header ()
{
	printf "\n>>> %s <<<\n\n" "$1"
}

random_nbr_list ()
{
	seq ${1} ${2} | shuf -n ${3} | tr '\n' ' ' | sed 's/ $//'
}

launch_tests() {
	print_header "PUSH_SWAP TESTS"
	printf "Inputs:\n"
	printf " • nb of tests = %s\n" $1
	printf " • lowest value = %s\n" $2
	printf " • highest value = %s\n" $3
	printf " • nb of elements = %s\n\n" $4
	[ -f $TEMP_FILE ] && rm -f $TEMP_FILE
	local index=0
	local sum=0
	local max=0
	local min=10000000
	while [ "$index" -lt "$1" ];
	do
		printf "> Test %03d:" $((index + 1)) | tee -a $TEMP_FILE
		local nums=`random_nbr_list "$2" "$3" "$4"`
		printf " %s\n" "$nums" >> $TEMP_FILE
		res=`./push_swap $nums 2> /dev/null | ./checker $nums 2> /dev/null | cat -e`
		if [ "$res" = "OK$" ]; then
			printf " ✅ "
			local nb_instr=`./push_swap $nums 2> /dev/null | wc -l | bc`
			sum=$((sum + nb_instr))
			printf " - $nb_instr"
			[ "$nb_instr" -lt "$min" ] && min="$nb_instr"
			[ "$nb_instr" -gt "$max" ] && max="$nb_instr"
		else
			printf " ❌ "
		fi
		printf "\n"
		((index++))
	done
	local average=`echo "$sum/$index" | bc`
	printf "\n%s\n" "SUMMARY:"
	printf "  • Average = %d\n" "$average"
	printf "  • Min = %d\n" "$min"
	printf "  • Max = %d\n" "$max"
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
	launch_tests $NB_OF_TESTS $LOW $HIGH $NB_ELM
fi
