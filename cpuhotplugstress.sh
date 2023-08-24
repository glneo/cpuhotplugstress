#!/bin/bash
#
# Stress test CPU hotplug
#
# Andrew Davis <afd@ti.com>

up_cores=("0" "1" "2" "3") # Cores all start on
down_cores=()

online_file="/sys/devices/system/cpu/cpu{0}/online"


core_change()
{
	printf "$([ "$2" = "up" ] && echo "Starting" || echo "Stopping") core $1\n"
	f="/sys/devices/system/cpu/cpu$1/online"
	target_value=$([ "$2" = "up" ] && echo "1" || echo "0")
	echo $target_value > $f
	status=$(cat $f)
	if [ "$status" != "$target_value" ]; then
		echo "Could not $([ "$2" = "up" ] && echo "start" || echo "stop") core $1"
		exit 1
	fi
}

cpu_directions=("down" "up")
while [ 1 ]
do
	direction=${cpu_directions[$RANDOM % ${#cpu_directions[@]}]}

	if [ $direction = "down" ]; then
		if [ ${#up_cores[@]} -le 1 ]; then  # need to keep at least 1 core alive
			continue
		fi
		core=${up_cores[$RANDOM % ${#up_cores[@]}]}
		core_change "$core" "$direction"
		up_cores=(${up_cores[@]/$core})
		up_cores=( "${up_cores[@]}" )
		down_cores+=("$core")
	elif [ $direction = "up" ]; then
		if [ ${#down_cores[@]} -le 0 ]; then  # no cores to bring up
			continue
		fi
		core=${down_cores[$RANDOM % ${#down_cores[@]}]}
		core_change "$core" "$direction"
		down_cores=(${down_cores[@]/$core})
		down_cores=( "${down_cores[@]}" )
		up_cores+=("$core")
	fi
done
