TEMP_FILE=push_swap.tmp

random_nbr_list ()
{
	seq ${1} ${2} | shuf -n ${3} | tr '\n' ' ' | sed 's/ $//'
}

launch_tests() {
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

ARGS="$@"

launch_tests $ARGS
