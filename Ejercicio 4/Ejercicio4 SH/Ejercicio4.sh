#!/bin/bash

#Ejercicio 4, Realizado en Bash.
#Integrantes:

#-SANTAMARIA LOAICONO, MATHIEU ANDRES
#-MARTINEZ, FABRICIO
#-DIDOLICH, MARTIN
#-LASORSA, LAUTARO
#-QUELALI AMISTOY, MARCOS EMIR

# Funcion de ayuda
function mostrar_ayuda(){
echo -e "\n-------------------------------------------------------------------------------------------------------------------\n"
echo -e "                                       FUNCION DE AYUDA DEL EJERCICIO 4"
echo -e "\n-------------------------------------------------------------------------------------------------------------------\n"

echo -e "\n----------------------------------------------- Informacion general -----------------------------------------------\n"
echo "  (+) Universidad: Universidad Nacional de la Matanza."
echo "  (+) Carrera: Ingenieria en Informatica."
echo "  (+) Materia: Virtualizacion de Hardware."
echo "  (+) Comision: Jueves-Noche."
echo "  (+) Cuatrimestre: 21C - 2024."
echo "  (+) APL: Numero 1."
echo "  (+) Grupo: Numero 1."
echo "  (+) Resuelto en: Bash."

echo -e "\n---------------------------------------------------- Consigna -----------------------------------------------------\n"
echo "  Desarrollar dos scripts, uno en bash y otro en Powershell, que realicen el monitoreo en segundo"
echo "  plano de un directorio. Cada vez que se detecte un cambio, ya sea creacion o modificacion de un"
echo "  archivo (no se monitorea borrado), el script debe realizar un backup del directorio monitoreado y"
echo "  crear un registro en un archivo de log con la fecha, hora, ruta del directorio monitoreado y un detalle"
echo "  de los cambios detectados."
echo "  El backup es un archivo comprimido con todo el contenido del directorio monitoreado."
echo "  Para el script de bash, el archivo es de extension ".tar.gz". En el caso de Powershell, la extension es ".zip""
echo "  El nombre de los archivos de backup debe tener el siguiente formato: "yyyyMMdd-HHmmss", donde:"
echo "      -yyyy: ano con 4 digitos."
echo "      -MM: mes con 2 digitos."
echo "      -dd: dia con 2 digitos."
echo "      -HH: hora con dos digitos en formato 24 horas."
echo "      -mm: minutos con 2 digitos."
echo "      -ss: segundos con 2 digitos."
echo "  El script debe quedar por si solo en segundo plano, el usuario no debe necesitar ejecutar ningun"
echo "  comando adicional a la llamada del propio script para que quede ejecutando como demonio en"
echo "  segundo plano. La solucion debe utilizar un unico archivo script (por cada tecnologia), no se aceptan"
echo "  soluciones con dos o mas scripts que trabajen en conjunto."
echo "  El script debe poder ejecutarse nuevamente para finalizar el demonio ya iniciado. Debe validar que" 
echo "  esté en ejecución sobre el directorio correspondiente"
echo "  No se debe poder ejecutar más de 1 proceso demonio para un determinado directorio al mismo tiempo"
echo "  Nota: El monitoreo del directorio se debe hacer utilizando inotify-tools en bash y FileSystemWatcher en Powershell."

echo -e "\n------------------------------------------------ Que hace el Script -----------------------------------------------\n"
echo "  Monitorea un directorio. Ante cada creacion o modificacion de algun archivo, realiza un backup del directorio y "
echo "  crea un registro en un archivo log, informando el/los cambios detectado." 

echo -e "\n------------------------------------------------ Breve Descripcion  -----------------------------------------------\n"
echo "  El siguiente script recibe por parametro un directorio."
echo "  La funcion del script es comenzar la ejecucion del monitoreo del directorio en segundo plano."
echo "  Ante cada creacion o modificacion de un archivo dentro del directorio:"
echo "      -Genera el backup del contenido del directorio (un archivo con extension ".tar.gz")."
echo "      -Genera un nuevo registro en el archivo .log, detallando el evento detectado."
echo "  Los archivos de backups se guardaran en el directorio especificado con el parametro -s."
echo "  El archivo log se guadara en la ruta actual, es decir, en el mismo directorio donde se esta ejecutando el script."

echo -e "\n---------------------------------------------- Parametros de Entrada ----------------------------------------------\n"
echo " -h / --help: Descripcion de los parametros que se le deben pasar al programa."
echo " -d / --directorio: Ruta del directorio a monitorear."
echo " -s / --salida: Ruta del directorio en donde se van a crear los backups."
echo " -p / --patron: Patrón a buscar una vez detectado un cambio en los archivos monitoreados."
echo "el patron puede ser o modify o create"
echo " -k / -kill Flag que se utiliza para indicar que el script debe detener el demonio previamente iniciado."
echo " Este parámetro solo se puede usar junto con -d/-- directorio/-directorio."

echo -e "\n------------------------------------  Tutorial de instalacion de inotify-tools ------------------------------------\n"
echo "  Pasos para la instalacion:"

echo "  PRIMERA FORMA:"
echo "      1) Abra una terminal."
echo "      2) Actualice la lista de paquetes con el siguiente comando: "
echo '          $sudo apt update'
echo "      En este paso si es la primera vez que usa el comando sudo, debera ingresar la contrasena del usuario root."
echo "      3) Instale inotify-tools con el siguiente comando: "
echo '          $sudo apt -y install inotify-tools'
echo "      4) Verifique la instalacion con el siguiente comando: "
echo '          $inotifywait --version'
echo "      Deberia mostrar la informacion de la version de inotify-tools instalada."

echo -e "\n SEGUNDA FORMA:"
echo "      1) Abra una terminal."
echo "      2) Actualice la lista de paquetes con el siguiente comando: "
echo '          $sudo apt-get update'
echo "      En este paso si es la primera vez que usa el comando sudo, debera ingresar la contrasena del usuario root."
echo "      3) Instale inotify-tools con el siguiente comando: "
echo '          $sudo apt-get install inotify-tools'
echo "      4) Verifique la instalacion con el siguiente comando: "
echo '          $inotifywait -h'
echo "      Deberia mostrar la informacion de la version de inotify-tools instalada."

echo -e "\n-------------------------------------------------- Forma de Uso ---------------------------------------------------\n"
echo -e "\n   Antes de ejecutar el script, se necesita instalar el paquete inotify-tools."
echo  -e "   Puede seguir el tutorial de instalacion mencionado en la seccion anterior.\n"
echo "  Pasos:"
echo "          1) Se le deben otorgar permisos de ejecucion al script. Para esto puede usar el siguiente comando: "
echo '                  $chmod +x Ejercicio4.sh'
echo "          2) Ejecutar el script, pasandole el path del directorio que se quiere monitorear con el parametro -d o --directorio."
echo "          3) Pasar el directorio donde se guardaran los archivos de backup, con el parametro -s o --salida."
echo "          4) Una vez ejecutado el script, se muestra por panatalla el PID del proceso de monitoreo para facilitar la detencion."
echo "             En caso de querer detener el monitoreo puede utilizar el siguiente comando:"
echo '                  $kill [pidDemonio]'

echo -e "\n-----------------------------------  Tutorial de desinstalacion de inotify-tools ----------------------------------\n"
echo "  Pasos para la desinstalacion:"
echo "      1) Abra una terminal."
echo "      2) Desinstale inotify-tools con el siguiente comando: "
echo '          $sudo apt-get remove inotify-tools'
echo "      En este paso si es la primera vez que usa el comando sudo, debera ingresar la contrasena del usuario root."
echo "      3) (Opcional) Elimine los paquetes huerfanos con el siguiente comando: "
echo '          $sudo apt-get autoremove'
echo "      4) Verifique la desinstalacion con el siguiente comando: "
echo '          $inotifywait --version'
echo "      Deberia recibir un mensaje de error indicando que el comando no se encuentra."

echo -e "\n---------------------------------------------- Ejemplos de llamadas -----------------------------------------------\n"
echo "  ACLARACION: Se utilizaran los nombres y valores de los archivos entregados en el lote de prueba."
echo -e "\n  Para llamar a la funcion de ayuda:"
echo '          $./Ejercicio4.sh -h o tambien se puede usar $./Ejercicio4.sh --help'
echo -e "\n  Para monitorear un directorio:"
echo '$./Ejercicio4.sh -d/--directorio [Path del directorio a monitorear] -s/--salida [Path del directorio de backups] -p/--patron [modify o create]'
echo '$./Ejercicio4.sh -d ./Directorio -k/--kill'

echo -e "\n-------------------------------------------------- Aclaraciones ---------------------------------------------------\n"
echo "  Se pueden pasar los path de forma tanto absoluta como relativa."
echo "  No se pueden almacenar los backups en el mismo directorio que se esta monitoreando."
echo "  El archivo .log almacena informacion de todos los monitoreos realizados, es decir, "
echo "      con cada ejecucion no se sobreescribe la informacion preexistente, sino que se agrega al final del archivo."
echo "  El archivo .log se guardara en el mismo directorio donde se este ejecutando este script con el nombre: 'monitoreo.log'."
echo "  Se monitoreara el directorio proporcionado por parametro y todos sus subdirectorios."
echo "  El backup se realiza del directorio pasado por parametro, por mas que el cambio haya sido solo en algun subdirectorio."
echo "  Para detener todos los monitoreos puede utilizar el siguiente comando:"
echo '      $kill $(pgrep inotifywait)'
echo -e "\n-------------------------------------------------------------------------------------------------------------------\n"
}

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
