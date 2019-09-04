#!/bin/bash

port=6379

function usage() {
	cat <<EOF
Usage:
	$(basename ${0}) [-p PORT]

EOF
}

function print_list() {
	key=$1
	listdata=$(redis-cli -p ${port} LRANGE ${key} 0 -1 | sed -r "s/^/${key} (LIST) /g")
	echo -e "${listdata}"
}

function print_set() {
	key=$1
	setdata=$(redis-cli -p ${port} SMEMBERS ${key} | sed -r "s/^/${key} (SET) /g")
	echo -e "${setdata}"
}

while getopts "p:h" o; do
    case "${o}" in
        p)
            port=${OPTARG}
            ;;
        h)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: ${o}"
            usage
            exit 1
            ;;
    esac
done
shift $((OPTIND-1))


for key in $(redis-cli -p ${port} keys \* | sort) ; do

	case "$(redis-cli -p ${port} TYPE ${key})" in
		list)
			print_list ${key}
			;;
		set)
			print_set ${key}
			;;
		*)
			echo "$key - $(redis-cli -p ${port} GET $key)"
			;;
	esac
done
