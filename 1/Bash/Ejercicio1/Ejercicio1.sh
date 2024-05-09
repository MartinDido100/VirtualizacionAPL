#!/bin/bash
#Ejercicio 1, Realizado en Bash.
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
echo "  (+) Integrantes: -SANTAMARIA LOAICONO MATHIEU ANDRES, -MARTINEZ FABRICIO, -DIDOLICH MARTIN, -LASORSA LAUTARO, -QUELALI AMISTOY MARCOS EMIR."
echo "  (+) Grupo: Numero 1."
echo "  (+) Resuelto en: Bash."

echo -e "\n---------------------------------------------------- Consigna -----------------------------------------------------\n"
echo "  Se necesita implementar un script que dado un archivo CSV con las notas finales de diferentes alumnos en diferentes materias,"
echo "  realizar un resumen de las notas de cada alumno para luego poder publicarlo en un sitio web"
echo "  Una vez obtenida la información, se generará un archivo JSON con la información obtenida"

echo -e "\n------------------------------------------------ Que hace el Script -----------------------------------------------\n"
echo "  procesara un archivo CSV pasado por parametro, y generara un archivo JSON resumiendo las notas de cada alumno"

echo -e "\n------------------------------------------------ Breve Descripcion  -----------------------------------------------\n"
echo "  El programa recibe por parametro el directorio donde se encuentra el archivo CSV y la pantalla o la"
echo "  ruta de salida "

echo -e "\n---------------------------------------------- Parametros de Entrada ----------------------------------------------\n"
echo " -d  /--directorio:  Ruta del directorio que contiene los archivos CSV a procesar."
echo " -s / --salida: Ruta del archivo JSON de salida" 
echo " -p / --pantalla: Muestra la salida por pantalla, no genera el archivo JSON. Este parámetro no se puede "
echo "usar a la vez que -s."


echo -e "\n-------------------------------------------------- Forma de Uso ---------------------------------------------------\n"
echo "          1) Ejecutar el script, pasandole al menos uno de los parametros, salida o pantalla."
echo "          a) para imprimir por pantalla debera pasarse como parametro el directorio (-d) y la pantalla (-p)"
echo "          b) para crear el archivo JSON debera pasarse como parametro el directorio (-d) y la salida (-s)"

echo -e "\n---------------------------------------------- Ejemplos de llamadas -----------------------------------------------\n"
echo "  ACLARACION: Se utilizaran los nombres y valores de los archivos entregados en el lote de prueba."
echo -e "\n  Para llamar a la funcion de ayuda:"
echo "          $./Ejercicio1.sh -h o tambien se puede usar $./Ejercicio1.sh --help"
echo -e "\n  Para generar el JSON"
echo "          $./Ejercicio1.sh -d directorio -s salida"
echo -e "para mostrar por pantalla"
echo "          $./Ejercicio1.sh -d directorio -p pantalla"
echo " salida esperada en ambos casos (tanto como por pantalla o en archivo json)"
echo "{" 
echo "notas: ["
echo "      {"
echo "      dni: "12345678","
echo "      notas: ["
echo "        { "materia": 1115, "nota": 8 },"
echo "        { "materia": 1116, "nota": 2 }"
echo "       ]"
echo "      },"
echo "      {"
echo "      dni: "87654321","
echo "      notas: ["
echo "        { "materia": 1116, "nota": 9 },"
echo "        { "materia": 1118, "nota": 7 }"
echo "       ]"
echo "      }"
echo "    ] }"

echo -e "\n-------------------------------------------------- Aclaraciones ---------------------------------------------------\n"
echo "  el script solo recibe 2 parametros, siendo estos directorio y pantalla o directorio y salida"
echo " en el caso de que se pasen los parametros pantalla y salida, el script no funcionara y mostrara el error"
echo -e "\n-------------------------------------------------------------------------------------------------------------------\n"
}

crearArchivo(){
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
            mostrar_ayuda
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
    if [[ $codigo_mesa =~ [^0-9] ]]; then
        echo "El archivo $archivo no tiene un nombre valido"
        continue
    fi
    if [ -f "$archivo" ]; then
        cantNotas=$(awk -F';' '{print NF-1; exit 1}' $archivo)
        if((cantNotas == 0)); then
            echo "Error en el archivo $archivo, se uso otro separador al deseado"
            continue
        fi


        while IFS=';' read -r dni notas; do
            if [[ $dni =~ [^0-9] ]]; then
                echo "El archivo $archivo no es valido, no tiene dni"
                continue
            fi
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

        done < <(awk -F';' 'NR {print $0}' $archivo) # Leo a partir de la segunda linea del archivo, y con el <(..) hago que se trate como un archivo y no como un string
    fi
done

if [ "$salida" = "true" ]; then
    crearArchivo
    echo "Archivo JSON creado en la ruta: $(pwd)/resumenMesasEstudiantes.json"
else
    mostrarPorPantalla
fi
