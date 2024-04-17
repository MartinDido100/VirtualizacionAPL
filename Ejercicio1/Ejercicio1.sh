#!/bin/bash

#Veo si se mando el parametro de help

carearArchivo(){
    #Creo el archivo JSON
    touch ./resumenMesasEstudiantes.json
    echo -e "{\n\"notas\": [" > ./resumenMesasEstudiantes.json

    alumnoActual=0
    totalAlumnos=${#alumnos[@]}
    for dni in "${!alumnos[@]}"; do
     #Con $alumno obtengo la clave del array asociativo
     #Con ${alumnos[$alumno]} obtengo el valor del array asociativo
     cantCampos=$(echo ${alumnos[$dni]} | awk -F',' '{print NF-1}')
     echo -e "\t{" >> ./resumenMesasEstudiantes.json
     echo -e "\t\t\"dni\": \"$dni\"," >> ./resumenMesasEstudiantes.json
     echo -e "\t\t\"notas\": [" >> ./resumenMesasEstudiantes.json
     for ((i=1; i<=cantCampos; i+=2)){
        #El -n no pone enter al final del echo, -e acepta los \t y \n
        echo -n -e "\t\t\t{ \"materia\": \"$(echo ${alumnos[$dni]} | awk -F',' '{print $'$i'}')\", " >> ./resumenMesasEstudiantes.json
        echo -n "\"nota\": \"$(echo ${alumnos[$dni]} | awk -F',' '{print $'$((i+1))'}')\"}" >> ./resumenMesasEstudiantes.json

        if [ "$i" -lt "$((cantCampos-1))" ]; then
            echo -e "," >> ./resumenMesasEstudiantes.json
        fi

     }
        echo -e -n "\n\t\t]\n\t}" >> ./resumenMesasEstudiantes.json

        if [ "$alumnoActual" -lt "$((totalAlumnos-1))" ]; then
            echo -e "," >> ./resumenMesasEstudiantes.json
        fi

        ((alumnoActual++))
    done

    echo -e "\n] }" >> ./resumenMesasEstudiantes.json
}

mostrarPorPantalla(){
    echo -e "{\n\"notas\": ["

    alumnoActual=0
    totalAlumnos=${#alumnos[@]}
    for dni in "${!alumnos[@]}"; do
     #Con $alumno obtengo la clave del array asociativo
     #Con ${alumnos[$alumno]} obtengo el valor del array asociativo
     cantCampos=$(echo ${alumnos[$dni]} | awk -F',' '{print NF-1}')
     echo -e "\t{"
     echo -e "\t\t\"dni\": \"$dni\","
     echo -e "\t\t\"notas\": ["
     for ((i=1; i<=cantCampos; i+=2)){
        #El -n no pone enter al final del echo, -e acepta los \t y \n
        echo -n -e "\t\t\t{ \"materia\": \"$(echo ${alumnos[$dni]} | awk -F',' '{print $'$i'}')\", "
        echo -n "\"nota\": \"$(echo ${alumnos[$dni]} | awk -F',' '{print $'$((i+1))'}')\"}"

        if [ "$i" -lt "$((cantCampos-1))" ]; then
            echo -e ","
        fi

     }
        echo -e -n "\n\t\t]\n\t}"

        if [ "$alumnoActual" -lt "$((totalAlumnos-1))" ]; then
            echo -e ","
        fi

        ((alumnoActual++))
    done

    echo -e "\n] }"
}

ayuda() {
    echo "\n-d, --directorio para pasar la ruta de los archivos .csv (Debe usarse)\n"
    echo "-p, --pantalla para mostrar el arhivo JSON generado por pantalla\n"
    echo "-s, --salida para mostrar la ruta del archivo JSON generado\n"
    echo "-h, --help ayuda\n"
    echo "ATENCION, no se puede usar -s y -p al mismo tiempo\n"
}

#Configuro como me vienen los parametros, -o para los cortos y --l para los largos, el 2> /dev/null es para que no muestre errores
# Los : son para que sepa que el parametro necesita un valor
options=$(getopt -o d:,p,s,h --l help,directorio:,pantalla,salida -- "$@" 2> /dev/null)

pantalla="false"
salida="false"
directorios="false"
rutaArchivos=""

eval set -- "$options"
while true
do
    case "$1" in
        -p | --pantalla)
            pantalla="true"
            shift
        ;;
        -s | --salida)
            salida="true"
            shift
        ;;
        -d | --directorio)
            directorios="true"

            if [ $2 = '-p' ] || [ $2 = '--pantalla' ] || [ $2 = '-s' ] || [ $2 = '--salida' ]; then
                echo "Falta el parametro de directorio"
                exit 1
            fi

            if [ $2 = '-h' ] || [ $2 = '--help' ]; then
                ayuda
                exit 0
            fi

            rutaArchivos=$2
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
            echo "Error de parametros"
            exit 1
        ;;
    esac
done

if [ "$pantalla" = "false" ] && [ "$salida" = "false" ]; then
    echo "Faltan parametros, use -h o --help para ayuda"
    exit 1
fi

if [ "$directorios" = "false" ]; then
    echo "Falta el parametro -d/--directorio, use -h o --help para ayuda"
    exit 1
fi

if [ "$pantalla" = "true" ] && [ "$salida" = "true" ]; then
    echo "No se puede mandar -p y -s al mismo tiempo, use -h o --help para ayuda"
    exit 1
fi

#Verifico si la ruta es valida
if [ ! -d $rutaArchivos ]; then
    echo "La ruta de los archivos no es valida"
    exit 1
fi

# Puede llegar a usarse Grep para buscar por dni en cada archivo leido
# Con el  pipe > para escribir en archivo JSON




declare -A alumnos

for archivo in "$rutaArchivos"/*; do
    codigo_mesa=$(basename "$archivo" ".csv")
    if [ -f "$archivo" ]; then
        cantNotas=$(awk -F';' '{print NF-1; exit 1}' $archivo)

        while IFS=';' read -r dni notas; do
            sumaTotal=0
            pesoNota=$(awk "BEGIN { printf \"%.2f\", 10 / $cantNotas }")

            for ((i=1; i<=cantNotas; i++))
            do
                notaAct=$(echo $notas | awk -F';' '{print $'$i'}' | tr -d '\n' | tr -d '\r')
                case $notaAct in
                    b)
                        sumaTotal=$(awk "BEGIN { printf \"%.2f\", $sumaTotal + ($pesoNota*1) }")
                    ;;
                    r)
                        sumaTotal=$(awk "BEGIN { printf \"%.2f\", $sumaTotal + ($pesoNota*0.5) }")
                    ;;
                esac
            done

            notaFinal=$(printf "%.0f" $sumaTotal) #Redondeo el numero a entero mas cercano

            alumnos["$dni"]+=$codigo_mesa,$notaFinal,

        done < <(awk -F';' 'NR > 1 {print $0}' $archivo) # Leo a partir de la segunda linea del archivo, y con el <(..) hago que se trate como un archivo y no como un string

<<<<<<< HEAD
        for alumno in "${!alumnos[@]}"; do
            echo "DNI: $alumno, Valor: ${alumnos[$alumno]}"
        done
asas
=======
>>>>>>> a726982979ed1169655996494f75919dd18b07c0
    fi
done

if [ "$salida" = "true" ]; then
    crearArchivo
    echo "Archivo JSON creado en la ruta: $(pwd)/resumenMesasEstudiantes.json"
else
    mostrarPorPantalla
fi

<<<<<<< HEAD
asas
# # Iterar sobre los archivos
# for archivo in mesa*.csv; do
#     # Obtener el código de la mesa desde el nombre del archivo
#     codigo_mesa="${archivo%.csv}"

#     # Leer el archivo y procesar los registros
#     while IFS=',' read -r dni nota; do
#         # Almacenar el dni y la nota en el array asociativo
#         alumnos["$dni"]=$codigo_mesa,$nota
#     done < "$archivo"
# done
=======
exit 0
>>>>>>> a726982979ed1169655996494f75919dd18b07c0
