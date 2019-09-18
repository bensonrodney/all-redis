#!/bin/bash

rcmd="redis-cli"
port=6379
server="localhost"

function usage() {
	cat <<EOF
Usage:
	$(basename ${0}) [-p PORT]

EOF
}

function print_list() {
	key=$1
	listdata=$(${rcmd} LRANGE ${key} 0 -1 | sed -r "s/^/${key} (LIST) /g")
	echo -e "${listdata}"
}

function print_set() {
	key=$1
	setdata=$(${rcmd} SMEMBERS ${key} | sed -r "s/^/${key} (SET) /g")
	echo -e "${setdata}"
}

while getopts "p:s:h" o; do
    case "${o}" in
        p)
            port=${OPTARG}
            ;;
        s)
            server=${OPTARG}
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

rcmd="redis-cli -p ${port} -h ${server}"

for key in $(${rcmd} keys \* | sort) ; do

	case "$(${rcmd} TYPE ${key})" in
		list)
			print_list ${key}
			;;
		set)
			print_set ${key}
			;;
		*)
			echo "$key - $(${rcmd} GET $key)"
			;;
	esac
done
