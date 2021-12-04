#!/bin/sh

function copyright()
{
  printf "Copyright(C) 2021, kimura.shinichi@ieee.org\n"
}
function license()
{
  printf "Licenced by Apache 2.0 License.\n"
  printf "%s\n" "https://opensource.org/licenses/Apache-2.0"
}
function help()
{
  printf "%s - Convert encoding to UTF-8.\n" "`basename $0`"
  printf "Usage: %s { -h | -C | -L | [ -v ] FILES... }\n" "$0"
  printf "OPTIONS:\n"
  printf " -h  - Show this help and exit with 1.\n"
  printf " -C  - Show Copyright and exit with 1.\n"
  printf " -L  - Show License and exit with 1.\n"
  printf " -v  - Show encoding at the top of each line.\n"
}
TMP=/tmp/mconv.$$
mkdir -p ${TMP}
trap 'rm -rf ${TMP}' 1
trap 'rm -rf ${TMP}' 2
trap 'rm -rf ${TMP}' 3
trap 'rm -rf ${TMP}' 15
LCNV=${TMP}/mconv_a_line.sh
cat <<EOF > ${LCNV}
function showType()
{
  if [ "\${VISIBLE}" == "YES" ]; then
    printf "%s\t" \$1
  fi
}
TEMP=${TMP}
LINE=\${TEMP}/\$\$
cat > \${LINE}
FTYPE=\`file --brief \${LINE}\`
case "\${FTYPE}" in
*extended-ASCII*text) showType cp932; cat \${LINE} | iconv -f cp932;;
*ASCII*text) showType ASCII; cat \${LINE};;
*UTF-8*text) showType UTF-8; cat \${LINE};;
*text) showType text; cat \${LINE};;
*) showType data; cat \${LINE};;
esac
EOF
VISIBLE=NO
while :; do
  if [ 0 -lt $# ]; then
    if [ "-v" == "$1" ]; then
      VISIBLE=YES
    elif [ "-h" == "$1" ]; then
      help
      exit 1
    elif [ "-C" == "$1" ]; then
      copyright
      exit 1
    elif [ "-L" == "$1" ]; then
      license
      exit 1
    else
      break
    fi 
    shift
  fi
done
function mconv()
{
  awk '{printf("printf \"%%s\\n\" '\''%s'\'' | VISIBLE='${VISIBLE}' sh '${LCNV}' '${TMP}'\n",$0);}' | sh
}
cat $* | mconv
rm -rf ${TMP}
