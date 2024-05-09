#!/bin/bash

#Ejercicio 2, Realizado en Bash.
#Integrantes:

#-SANTAMARIA LOAICONO, MATHIEU ANDRES
#-MARTINEZ, FABRICIO
#-DIDOLICH, MARTIN
#-LASORSA, LAUTARO
#-QUELALI AMISTOY, MARCOS EMIR

# Funcion de ayuda
function mostrar_ayuda(){
echo -e "\n-------------------------------------------------------------------------------------------------------------------\n"
echo -e "                                       FUNCION DE AYUDA DEL EJERCICIO 1"
echo -e "\n-------------------------------------------------------------------------------------------------------------------\n"

echo -e "\n----------------------------------------------- Informacion general -----------------------------------------------\n"
echo "  (+) Universidad: Universidad Nacional de la Matanza."
echo "  (+) Carrera: Ingenieria en Informatica."
echo "  (+) Materia: Virtualizacion de Hardware."
echo "  (+) Comision: Jueves-Noche."
echo "  (+) Cuatrimestre: 1C - 2024."
echo "  (+) APL: Numero 1."
echo "  (+) Grupo: Numero 1."
echo "  (+) Resuelto en: Bash."

echo -e "\n---------------------------------------------------- Consigna -----------------------------------------------------\n"
echo "  Se necesita implementar un script que dada 2 matrices cargadas en 2 archivos separados, las multiplique"
echo "  y muestre el resultado por pantalla."
echo "  Tambien se debera informar: orden de la matriz, si es matriz cuadrada, si es matriz fila, si es matriz columna"

echo -e "\n------------------------------------------------ Que hace el Script -----------------------------------------------\n"
echo " Procesara 2 archivos CSV obteniendo de dichos archivos las 2 matrices, luego si es posible se multiplicaran"
echo " y se muestra el resultado por pantalla y tambien el orden , si es matriz cuadrada, si es matriz fila o matriz columna"

echo -e "\n---------------------------------------------- Parametros de Entrada ----------------------------------------------\n"
echo " -m1  /--matriz1: Ruta del directorio que contiene el archivo con la matriz 1."
echo " -m2 / --matriz2: Ruta del directorio que contiene el archivo con la matriz 2" 
echo " -s / --separador:  Carácter separador de valores. Opcional, por defecto es coma “,”."

echo -e "\n-------------------------------------------------- Forma de Uso ---------------------------------------------------\n"
echo "          1) Ejecutar el script, pasandole 3 parametros, matriz1 (-m1) o matriz2(-m2) y el separador(-s)"

echo -e "\n---------------------------------------------- Ejemplos de llamadas -----------------------------------------------\n"
echo "  ACLARACION: Se utilizaran los nombres y valores de los archivos entregados en el lote de prueba."
echo -e "\n  Para llamar a la funcion de ayuda:"
echo "          $./Ejercicio2.sh -h o tambien se puede usar $./Ejercicio1.sh --help"
echo -e "\n para multiplicar 2 matrices separadas por un caracter especifico"
echo "          $./Ejercicio2.sh -m1 matriz1 -m2 matriz2 -s separador"
echo -e "\n para multiplicar 2 matrices separadas por el caracter por defecto ",""
echo "          $./Ejercicio2.sh -m1 matriz1 -m2 matriz2 -s separador"
echo "      matriz cargada en -m1"
echo "               1,1,3"
echo "               4,5,-1"
echo "               2,0,0"
echo "      matriz cargada en -m1"
echo "               2,0,0"
echo "               0,2,0"
echo "               0,0,2"
echo "      salida esperada por pantalla"
echo "               2,2,6"
echo "               8,10,-2"
echo "               4,0,0"       

echo -e "\n-------------------------------------------------- Aclaraciones ---------------------------------------------------\n"
echo "El script solo funcionara si se pasan la totalidad de los parametros y si es posible la multiplicacion de"
echo "las matrices, caso contrario indicara el error por pantalla."
echo "Las matrices no son aptas para la multiplicacion si la cantidad de columnas de la primera matriz no coincide"
echo "con la cantidad de filas de la segunda matriz."
echo -e "\nNo se podra pasar como parametro separador el caracter - ya que evitaria la existencia de numeros negativos"
echo -e "\n-------------------------------------------------------------------------------------------------------------------\n"
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
        -s | --separador)
            s=$2
            shift 2
        ;;
        -h | --help)
            mostrar_ayuda
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

if [ "$rm1" = "false" ] || [ "$rm2" = "false" ]; then
    echo "Faltan parametros, -h o --help para ayuda"
    exit 1
fi

if [ $s = "false" ]; then
 s=","
fi

if [[ "$s" =~ ^[-0-9]+$ ]]; then
    echo "El separador no puede ser '-' o contener números."
    exit 1
fi



if [ ! -f "$rm1" ] || [ ! -f "$rm2" ]; then
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
done < "$rm1"

echo -e "Matriz 1\n"

declare -a matriz2

while IFS="$s" read -r line
do
    matriz2+=("${line[@]}")
done < "$rm2"

#Despues de leer las 2 matrices chequeo que las pueda multiplicar

cantFilasM1=$(awk -F"$s" 'END{print NR}' "$rm1")
cantFilasM2=$(awk -F"$s" 'END{print NR}' "$rm2")
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
