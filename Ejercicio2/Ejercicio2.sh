<<<<<<< HEAD
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
 s=","
fi

if [ $s = '-' ]; then
    echo "El separador no puede ser "-""
    exit 1
fi

if [ ! -f $rm1 ] || [ ! -f $rm2 ]; then
    echo "Los archivos no existen"
    exit 1
fi

#Valido que las matrices sean validas con awk

validacion1=$(awk -v RS="\r\n|\n" -F"$s" '

    BEGIN {
        esValida=1
        cantCamposAnt=0
    }
    
    {
        if (NF == 0) {
            esValida=0
        }

        if (cantCamposAnt != 0 && cantCamposAnt != NF) {
            esValida=0
        }

        for (i=1; i<=NF; i++) {
            if ($i !~ /^[[:space:]]*[-]?[0-9]+[[:space:]]*$/) {
                esValida=0
            }
        }
        cantCamposAnt = NF
    }
    
    END {
        print esValida
    }
' "$rm1")

validacion2=$(awk -v RS="\r\n|\n" -F"$s" '

    BEGIN {
        esValida=1
        cantCamposAnt=0
    }
    
    {
        if (NF == 0) {
            esValida=0
        }

        if (cantCamposAnt != 0 && cantCamposAnt != NF) {
            esValida=0
        }

        for (i=1; i<=NF; i++) {
            if ($i !~ /^[[:space:]]*[-]?[0-9]+[[:space:]]*$/) {
                esValida=0
            }
        }
        cantCamposAnt = NF
    }
    
    END {
        print esValida
    }
' "$rm2")

if [ $validacion1 = 0 ]; then
    echo "La matriz 1 no es valida"
    exit 1
fi

if [ $validacion2 = 0 ]; then
    echo "La matriz 2 no es valida"
    exit 1
fi

declare -a matriz1

while IFS="$s" read -r line
do
    matriz1+=("${line[@]}")
done < $rm1

echo -e "Matriz 1\n"

declare -a matriz2

while IFS="$s" read -r line
do
    matriz2+=("${line[@]}")
done < $rm2

#Despues de leer las 2 matrices chequeo que las pueda multiplicar

cantFilasM1=$(awk -F';' '{print NF; exit 1}' $rm1)
cantFilasM2=$(awk -F';' '{print NF; exit 1}' $rm2)
cantColM1=$(echo "${matriz1[0]}" | awk -F';' '{print NF}')
cantColM2=$(echo "${matriz2[0]}" | awk -F';' '{print NF}')

if [ $cantColM1 != $cantFilasM1 ]; then
    echo "No se pueden multiplicar las matrices"
    exit 1
fi

declare -a matrizResultado

for ((i=1; i<=$cantFilasM1; i++)); do
    for ((j=1; j<=$cantColM2; j++)); do
        suma=0
        for ((k=1; k<=$cantColM1; k++)); do
            campom1=$(echo "${matriz1[$((i - 1))]}" | awk -F';' '{print $'$k'}' | tr -d '\r')
            campom2=$(echo "${matriz2[$((k - 1))]}" | awk -F';' '{print $'$j'}' | tr -d '\r')

            suma=$(($suma + $campom1*$campom2))
        done
        matrizResultado[$i]+="$suma|"
    done
done
=======
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
 s=","
fi

if [ $s = '-' ]; then
    echo "El separador no puede ser "-""
    exit 1
fi

if [ ! -f $rm1 ] || [ ! -f $rm2 ]; then
    echo "Los archivos no existen"
    exit 1
fi

#Valido que las matrices sean validas con awk

validacion1=$(awk -v RS="\r\n|\n" -F"$s" '

    BEGIN {
        esValida=1
        cantCamposAnt=0
    }
    
    {
        if (NF == 0) {
            esValida=0
        }

        if (cantCamposAnt != 0 && cantCamposAnt != NF) {
            esValida=0
        }

        for (i=1; i<=NF; i++) {
            if ($i !~ /^[[:space:]]*[-]?[0-9]+[[:space:]]*$/) {
                esValida=0
            }
        }
        cantCamposAnt = NF
    }
    
    END {
        print esValida
    }
' "$rm1")

validacion2=$(awk -v RS="\r\n|\n" -F"$s" '

    BEGIN {
        esValida=1
        cantCamposAnt=0
    }
    
    {
        if (NF == 0) {
            esValida=0
        }

        if (cantCamposAnt != 0 && cantCamposAnt != NF) {
            esValida=0
        }

        for (i=1; i<=NF; i++) {
            if ($i !~ /^[[:space:]]*[-]?[0-9]+[[:space:]]*$/) {
                esValida=0
            }
        }
        cantCamposAnt = NF
    }
    
    END {
        print esValida
    }
' "$rm2")

if [ $validacion1 = 0 ]; then
    echo "La matriz 1 no es valida"
    exit 1
fi

if [ $validacion2 = 0 ]; then
    echo "La matriz 2 no es valida"
    exit 1
fi

declare -a matriz1

while IFS="$s" read -r line
do
    matriz1+=("${line[@]}")
done < $rm1

echo -e "Matriz 1\n"

declare -a matriz2

while IFS="$s" read -r line
do
    matriz2+=("${line[@]}")
done < $rm2

#Despues de leer las 2 matrices chequeo que las pueda multiplicar

cantFilasM1=$(awk -F"$s" 'END{print NR}' $rm1)
cantFilasM2=$(awk -F"$s" 'END{print NR}' $rm2)
cantColM1=$(echo "${matriz1[0]}" | awk -F';' '{print NF}')
cantColM2=$(echo "${matriz2[0]}" | awk -F';' '{print NF}')

if [ $cantColM1 != $cantFilasM2 ]; then
    echo "No se pueden multiplicar las matrices"
    exit 1
fi

declare -a matrizResultado

for ((i=1; i<=$cantFilasM1; i++)); do
    for ((j=1; j<=$cantColM2; j++)); do
        suma=0
        for ((k=1; k<=$cantColM1; k++)); do
            campom1=$(echo "${matriz1[$((i - 1))]}" | awk -F';' '{print $'$k'}' | tr -d '\r')
            campom2=$(echo "${matriz2[$((k - 1))]}" | awk -F';' '{print $'$j'}' | tr -d '\r')

            suma=$(($suma + $campom1*$campom2))
        done
        matrizResultado[$i]+="$suma|"
    done
done

for fila in "${matrizResultado[@]}"; do
    echo $fila
    echo "---------"
done
echo "Orden de la matriz resultado: $cantFilasM1 x $cantColM2"
#Mostrar si es cuadrada
if [ $cantFilasM1 = $cantColM2 ]; then
    echo "La matriz resultado es cuadrada"
else
    echo "La matriz resultado no es cuadrada"
fi
#Mostrar si es matriz fila
if [ $cantFilasM1 = 1 ]; then
    echo "La matriz resultado es una matriz fila"
else
    echo "La matriz resultado no es una matriz fila"
fi
#Mostrar si es matriz columna
if [ $cantColM2 = 1 ]; then
    echo "La matriz resultado es una matriz columna"
else
    echo "La matriz resultado no es una matriz columna"
fi
>>>>>>> 21d011ece015a237f24f8a15b3b3e4825dea6af7
