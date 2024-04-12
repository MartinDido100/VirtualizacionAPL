#!/bin/awk

if [ $1="-h" ] || [ $1="--help" ]; then
    echo "\n-d, --directorio para pasar la ruta de los archivos .csv\n"
    echo "-p, --pantalla para mostrar el arhivo JSON generado por pantalla\n"
    echo "-s, --salida para mostrar la ruta del archivo JSON generado\n"
    echo "-h, --help ayuda\n"
    echo "ATENCION, no se puede usar -s y -p al mismo tiempo"
    exit 1
fi