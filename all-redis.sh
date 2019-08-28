#!/bin/bash

function print_list() {
	key=$1
	listdata=$(redis-cli LRANGE ${key} 0 -1 | sed -r "s/^/${key} /g")
	echo -e "${listdata}"
}

for key in $(redis-cli keys \* | sort) ; do
	if [[ $(redis-cli TYPE ${key}) = 'list' ]] ; then
		print_list ${key}
	else
		echo "$key - $(redis-cli GET $key)"
	fi
done
