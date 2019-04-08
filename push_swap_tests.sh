TEMP_FILE=push_swap.tmp

random_nbr_list ()
{
	seq ${1} ${2} | shuf -n ${3} | tr '\n' ' ' | sed 's/ $//'
}

launch_tests() {
	[ -f $TEMP_FILE ] && rm -f $TEMP_FILE
	local index=0;
	local sum=0;
	while [ "$index" -lt "$1" ];
	do
		printf "> Test %03d:" $index | tee -a $TEMP_FILE
		local nums=`random_nbr_list "$2" "$3" "$4"`
		printf " %s\n" "$nums" >> $TEMP_FILE
		res=`./push_swap $nums | ./checker $nums | cat -e`
		if [ "$res" = "OK$" ]; then
			printf " ✅ "
			local nb_instr=`./push_swap $nums | wc -l | bc`
			sum=$((sum + nb_instr))
			printf " - $nb_instr"
		else
			printf " ❌ "
		fi
		printf "\n"
		((index++))
	done
	local average=`echo "$sum/$index" | bc`
	printf "Average = %d\n" $average
	rm -f $TEMP_FILE
}

ARGS="$@"

launch_tests $ARGS
