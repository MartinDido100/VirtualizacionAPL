#!/bin/bash


ayuda() {
    echo "\n-m1, --matriz1, ruta del archivo con la matriz1, debe ser valido\n"
    echo "-m2, --matriz2, ruta del archivo con la matriz2, debe ser valido\n"
    echo "-s, Caracter separador de valores, por defecto es ';'\n"
    echo "-h, --help ayuda\n"
}

options=$(getopt -o m,1:,2:,s:,h, --l help,matriz1:,matriz2:,separador: -- "$@" 2> /dev/null)
rm1="false"
rm2="false"
s="false"

eval set -- "$options"
while true
do
    case "$1" in
        -m)
            shift
        ;;
        -1 | --matriz1)
            rm1=$2
            shift 2
        ;;
        -2 | --matriz2)
            rm2=$2
            shift 2
        ;;
        -s | --salida)
            s=$2
            shift 2
        ;;
        -h | --help)
            ayuda
            exit 0
        ;;
        --)
            shift
            break
        ;;
        *)
            echo "Error de parametros, -h o --help para ayuda"
            exit 1
        ;;
    esac
done

if [ $rm1 = "false" ] || [ $rm2 = "false" ]; then
    echo "Faltan parametros, -h o --help para ayuda"
    exit 1
fi

if [ $s = "false" ]; then
 s=";"
fi


if [ ! -f $rm1 ] || [ ! -f $rm2 ]; then
    echo "Los archivos no existen"
    exit 1
fi

declare -a matriz1

cantFilasM1=$(awk -F';' '{print NF; exit 1}' $rm1)

while IFS="$s" read -r line
do
    matriz1+=("${line[@]}")
done < $rm1

for fila in "${matriz1[@]}"; do
    cantCol=$(echo "$fila" | awk -F ';' '{print NF}')
    for ((i=1; i<=$cantCol; i++)); do
            campo=$(echo "$fila" | awk -F';' '{print $'$i'}')
            echo "$i campo de la fila: $campo"
    done
done