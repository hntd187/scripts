chomp(){
  usage(){ echo -e "Usage: $1 \n\t[-d <delimiter>]\n\t[-c <column>]" 1>&2; }
  if [[ $# == 0 ]]; then
    echo "No arguments provided, must provide at least the -c flag."
    usage $FUNCNAME
    return
  fi
  local delim="|"
  local file=""
  local col=1
  local OPTIND opt
  while getopts "d:c:h" opt; do
    case $opt in
    d)
      delim=${OPTARG};;
    c)
      col=${OPTARG};;
    h)
      usage $FUNCNAME
      return;;
    \?)
      return;;
    :)
      echo "-$OPTARG requires an argument."
      return;;
    *)
      echo "Error in getopts."
      return ;;
    esac
  done
  shift $((OPTIND-1)) 
  while [[ $# -ge 0 ]]; do
    file=$1
    echo $file
    awk "BEGIN{FS=OFS=\"$delim\"} {gsub(/^[ \t]+|[ \t]+$/, \"\", \$$col)}1" $file
    shift
  done
}

alias chomp=chomp
