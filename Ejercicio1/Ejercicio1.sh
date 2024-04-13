#!/bin/awk

#Veo si se mando el parametro de help
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "\n-d, --directorio para pasar la ruta de los archivos .csv (Debe usarse)\n"
    echo "-p, --pantalla para mostrar el arhivo JSON generado por pantalla\n"
    echo "-s, --salida para mostrar la ruta del archivo JSON generado\n"
    echo "-h, --help ayuda\n"
    echo "ATENCION, no se puede usar -s y -p al mismo tiempo"
    exit 1
fi

pantalla="false"
salida="false"
directorios="false"
rutaArchivos=""

#Contador de parametros
contadorPar=0

#Como no se el orden de parametros veo cuales se mandaron
for par in $@; do
    echo $contadorPar
    case "$par" in 
        '-p' | '--pantalla')
            pantalla="true"
        ;;
        '-s'| '--salida')
            salida="true"
        ;;
        '-d' | '--directorio')
          directorios="true"
          shift
          rutaArchivos="${!contadorPar}"
        ;;
    esac
    contadorPar=$((contadorPar+1))
done

echo $rutaArchivos

if [ "$directorios" = "false" ]; then
    echo "Falta el parametro -d/--directorio, use -h o --help para ayuda"
    exit 1
fi

if [ "$pantalla" = "true" ] && [ "$salida" = "true" ]; then
    echo "No se puede mandar -p y -s al mismo tiempo, use -h o --help para ayuda"
    exit 1
fi

# Puede llegar a usarse Grep para buscar por dni en cada archivo leido
# Con el  pipe > para escribir en archivo JSON


#Creo el archivo JSON
touch ./resumenMesasEstudiantes.json

exit 0