#!/bin/bash
# Karol Melanczuk
# Pracownia Jezykow Skrptyowych 2025/2026
A=0
B=0
C=0
hash_alg="md5sum"
hardlink_flag=0
n_depth=-1
handle_equal_checksum() {
IFS=',,,,,' read -ra array <<< "$1"
local -A local_table
local separator=',,,,,'
local size="${#array[@]}"
for ((i=0; i<"$size"; i++)); do
        if [[ -n "${array[i]}" ]]; then
            for ((j=i+1; j<"$size"; j++)); do
                if [[ -n "${array[j]}" ]]; then
                    if cmp --silent "${array[i]}" "${array[j]}"; then
                       # echo "Usuwam/łączę duplikat: ${array[j]} -> ${array[i]}"
                        if [[ "$hardlink_flag" == 0 ]]; then 
                            rm -f "${array[j]}"
                        else
                            ln -f "${array[i]}" "${array[j]}"
                            ((C++))
                        fi
                        ((B++))
                        unset array[j]
                    fi
                fi
            done
        fi
    done
#for ((i=0;i<"${#array[@]}";i++)); do
#    if [[ -n "${array[i]}" ]]; then
#        for ((j=i+1;j<"${#array[@]}";j++)); do
#            if [[ -n "${array[j]}" ]]; then
#                 if cmp --silent "${array[i]}" "${array[j]}" ; then
#                    #ln -f "${array[i]}" "${array[j]}"
#                    if [[ "$hardlink_flag" == 0 ]]; then 
#                        rm -f "${array[j]}"
#                        #((C++))
#                    else
#                        ln -f "${array[i]}" "${array[j]}"
#                        ((C++))
#                    fi
#                    ((B++))
#                    unset "${array[j]}"
#                fi
#            fi
#        done
#    fi
#done
}
handle_equal_size() {
IFS=',,,,,' read -ra array <<< "$1"
local -A local_table
local separator=',,,,,'
for element in "${array[@]}"; do
    if [[ -n "$element" ]]; then
        tmp=$(md5sum "$element" | cut -d ' ' -f1)
            local_table["$tmp"]+="$separator"
            local_table["$tmp"]+="$element"
    fi
done
for key in "${!local_table[@]}"; do
    handle_equal_checksum "${local_table[$key]}"
done
handle_equal_checksum
};

declare -A pliki
separator=',,,,,'
opis_uzycia() {
    echo "Program shell03 sluzy do poszukiwania duplikatu plikow."
    echo "Domyslnie usuwa on znalezione duplikaty ale mozna to zmienic."
    echo "Uzyj --replace-with-hardlinks aby znaleziony duplikat zastapic hiperlaczem"
    echo "Mozesz kontrolowac zakres poszukiwan plikow, ustawiajac flage --max-depth"
    echo "Jezeli chcesz, program moze uzyc zaproponowanej przez Ciebie funkcji haszujacej - --hash-algo"
};

result=$(getopt -o  ":" -l "help max-depth: hash-algo: replace-with-hardlinks"  -- "$@")
if [ $? -ne 0 ]; then
    argument_error=1
fi
eval set -- "$result"

while true;
do
case "$1" in
    "--help")
    opis_uzycia
    exit 0;;
    "--hash-algo")
        if type "$2" >/dev/null 2>&1; then
            hash_alg="$2"
        else
            echo "$2 not supported"
            exit 0
        fi
        shift 2
        ;;
    "--replace-with-hardlinks")
        hardlink_flag=1
        shift 1
        ;;
    "--max-depth")
        n_depth="$2"
        shift 2
        ;;
    *)
    shift 1
    break
esac
done
DIRNAME="$1"
cmd=("find" "$DIRNAME")
if [[ "$n_depth" != -1 ]]; then
    cmd+=("-maxdepth" "$n_depth")
fi
cmd+=("-type" "f" "-print0")

tempfile=$(mktemp tmpXXXXXXXXX)
("${cmd[@]}") > "$tempfile"
while IFS= read -r -d '' file; do
    tmp=$(stat --printf="%s" "$file")
    ((A++))
    pliki["$tmp"]+="$separator"
    pliki["$tmp"]+="$file"
done < "$tempfile" 
for key in "${!pliki[@]}"; do
    handle_equal_size "${pliki[$key]}"
done

echo "Liczba przetworzonych plikow: $A"
echo "Liczba znalezionych duplikatow: $B"
echo "Liczba zastapionych duplikatow: $C"
rm "$tempfile"