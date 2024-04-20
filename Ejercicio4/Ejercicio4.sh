# Funcion para empezar a monitoriar el directorio
monitorear_directorio() {
    inotifywait -m -q -r -e "$patron" --format "%e %w %f" "$directorio" |
    while read -r evento ruta archivo; do
        # Agrego el evento detectado en el .log
        archivo_log="./monitoreo.log"
        echo "$(date +"%Y-%m-%d %H:%M:%S") - Cambio detectado en "${ruta%/*}". Evento: "$evento" en Archivo: "$archivo"" >> "$archivo_log"
        # realizar_backup
    done
}

# Funcion para realizar el backup
realizar_backup() {
    nombre_archivo=$(date +"%Y%m%d-%H%M%S")
    archivo_backup="$salida/$nombre_archivo.tar.gz"
       
    # Crea el archivo comprimido con todo el contenido del directorio mas el archivo de log
    tar -czf "$archivo_backup" -C "$directorio" . > /dev/null 2>&1
    
    if [ ! $? -eq 0 ]; then
        echo "Se produjo un error al realizar el backup. El proceso de monitoreo se detendra"
        detener_monitoreo
        exit 1
    fi
}

detener_monitoreo() {
    kill $(pgrep inotifywait)
    echo -e "\n  (!) Se ha detenido el monitoreo del directorio "$directorio"."
    exit 0
}

options=$(getopt -o hkp:d:s: --l kill,patron,help,directorio:,salida: -- "$@" 2> /dev/null)    

if [ "$?" != "0" ]
then
        echo "Opciones Incorrectas"
        exit 1
fi

parametrosIngresados=false
kill=false

eval set -- "$options"
while true
do
        case "$1" in
                -d | --directorio)
                        directorio="$2"
                        parametrosIngresados=true
                        shift 2
                ;;
                -s | --salida)
                        salida="$2"
                        parametrosIngresados=true
                        shift 2
                ;;
                -h | --help)
                       if [ "$#" -gt 2 ] || [ "$parametrosIngresados" = true ]; then
                                echo "El parametro de ayuda (-h / --help) no puede ir junto a otros parametros."
                                echo 'Ejemplo valido: $ ./Ejercicio4.sh -h o $ ./Ejercicio4.sh --help'
                                echo "Vuelva a intentarlo."
                                exit 1
                        else
                                mostrar_ayuda
                                exit 0
                        fi
                        ;;
                -k | --kill)
                    kill=true
                    parametrosIngresados=true
                    shift
                ;;
                -p | --patron)
                        patron="$2"

                        if [ "$patron" != "create" ] && [ "$patron" != "modify" ]; then
                            echo "El patron ingresado no es valido. Los patrones validos son: CREATE, MODIFY"
                            exit 1
                        fi

                        parametrosIngresados=true
                        shift 2
                ;;
                --)
                shift
                break
                ;;
                *)
                echo "Ingreso algun parametro no valido, vuelva a intentarlo"
                exit 1
                ;;
        esac
done

# Aca valido que se haya ingresado el directorio a monitorear 
if [ -z "$directorio" ]; then
    echo "No ha ingresado la ruta del directorio que desea monitonear. Vuelva a intentarlo"
    exit 1
fi

if [ "$kill" = false ] && [ -z "$salida" ]; then
    echo "No ha ingresado la ruta del directorio donde se crearan los backups. Vuelva a intentarlo"
    exit 1
fi

if [ "$kill" = false ] && [ -z "$patron" ]; then
    echo "No ha ingresado el patron de eventos a monitorear. Vuelva a intentarlo"
    exit 1
fi

#Pregunto si se quiere detener el monitoreo
if [ "$kill" = true ] && ( [ -n "$salida" ] || [ -n "$patron" ] ); then
    echo "No se puede detener el monitoreo y al mismo tiempo ingresar otros parametros que no sean el directorio. Vuelva a intentarlo."
    echo "Ejemplo correcto: $ ./Ejercicio4.sh -k -d /ruta/directorio o $ ./Ejercicio4.sh --kill --directorio /ruta/directorio"
    exit 1

elif [ "$kill" = true ]; then
        detener_monitoreo
fi

if [ ! -d "$directorio" ]; then
    echo "El directorio a monitorear no existe."
    exit 1
fi

if [ ! -d "$salida" ]; then
    mkdir -p "$salida"
fi


# Normalizo las rutas 
directorio=$(readlink -f "$directorio")
salida=$(readlink -f "$salida")

if [ "$directorio" == "$salida" ]; then
    echo "Comportamiento indefinido. No se permite monitorear el mismo directorio donde se almacenan los backups."
    exit 1
fi

#Si ya existe un monitoreo en el directorio, no empiezo otro
dirExistente=$(ps aux | grep '[i]notifywait.*'"$directorio" | awk '{print $21}')

if [ -n "$dirExistente" ]; then
    echo "Ya existe un monitoreo en el directorio "$directorio". No se puede iniciar otro."
    exit 1
fi

monitorear_directorio &

sleep 1
pidDemonio=$(pgrep -n inotifywait)
echo -e "\n  (!) El PID del proceso demonio que monitorea recien creado es: $pidDemonio."
echo "          Puede detenerlo utilizando: el parametro -k/--kill"
echo -e "\n  (!) Ha comenzado el monitoreo del directorio "$directorio" en segundo plano."
exit 0
