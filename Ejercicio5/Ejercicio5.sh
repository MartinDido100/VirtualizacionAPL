#!/bin/bash

#Ejercicio 5, Realizado en Bash.

#Integrantes:
#-SANTAMARIA LOAICONO, MATHIEU ANDRES
#-MARTINEZ, FABRICIO
#-DIDOLICH, MARTIN
#-LASORSA, LAUTARO
#-QUELALI AMISTOY, MARCOS EMIR

# Funcion de ayuda
function mostrar_ayuda(){
echo -e "\n-------------------------------------------------------------------------------------------------------------------\n"
echo -e "                                       FUNCION DE AYUDA DEL EJERCICIO 5"
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
echo "  Se necesita implementar un script que facilite la consulta de información relacionada a la serie Rick and Morty."
echo "  El script permitirá buscar información de los personajes por su id o su nombre a través de la api"
echo "  https://rickandmortyapi.com/ y pueden enviarse más de 1 id o nombre en la ejecución del script e incluso "
echo "  solicitar la búsqueda por ambos parámetros. Tener en cuenta que al buscar por nombre el resultado será ."
echo "  una lista a diferencia de la búsqueda por ID."
echo "  Una vez obtenida la información, se generará un archivo con la información obtenida, para evitar volver a"
echo "  consultarlo a la api, y se mostrará por pantalla la información básica de él/los personaje/s con el siguiente formato."
echo "  La información de cómo obtener los datos se puede consultar en el siguiente link: https://rickandmortyapi.com/documentation/#character"
echo " En caso de ingresar un id inválido o un nombre que no traiga resultados, se deberá informar al cliente un mensaje acorde. Mismo en caso de que la api retorne un error."

echo -e "\n------------------------------------------------ Que hace el Script -----------------------------------------------\n"
echo "  Busca informacion de el/los personajes de la serie RICK y MORTY enviados por parametros a traves de su id o nombre en una api de RICK y MORTY."

echo -e "\n------------------------------------------------ Breve Descripcion  -----------------------------------------------\n"
echo "  El programa recibe por parametro uno o varios ID o Nombres de personajes de RICK y MORTY."
echo "  Primero, buscara la informacion de estos en un archivo local y en caso de no encontrarlo ahi, buscara en la api."
echo "  Una vez obtenida la informacion del personaje, se mostrara por pantalla la siguiente informacion:"
echo "      Character info: "
echo "      ID: ID del personaje: "
echo "      Name: Nombre del personaje: "
echo "      Status: Estado del personaje: "
echo "      Species: Especie del personaje:"
echo "      Gender: Genero del personaje: "
echo "      Origin: Origen del personaje: "
echo "      Location: Ubicacion del personaje: "
echo -e "\nEn caso de no encontrar la informacion ni el archivo ni en la api, el programa lo informara."

echo -e "\n---------------------------------------------- Parametros de Entrada ----------------------------------------------\n"
echo " -h / --help: Descripcion de los parametros que se le deben pasar al programa."
echo " -i / --id: ID del personaje a buscar. Si se quieren enviar varios, deben separarse por coma." 
echo " -n / --nombre: Nombre del personaje a buscar. Si se quieren enviar varios, deben separarse por coma."

echo -e "\n------------------------------------  Tutorial de instalacion de jq ------------------------------------\n"
echo "  Pasos para la instalacion:"
echo "      1) Abra una terminal."
echo "      2) Actualice la lista de paquetes con el siguiente comando: "
echo "          $ sudo apt update"
echo "      En este paso si es la primera vez que usa el comando sudo, debera ingresar la contrasena del usuario root."
echo "      3) Instale jq con el siguiente comando: "
echo "          $ sudo apt install -y jq"
echo "      4) Verifique la instalacion con el siguiente comando: "
echo "          $ jq --version"
echo "      Deberia mostrar la informacion de la version de jq instalada."

echo -e "\n-------------------------------------------------- Forma de Uso ---------------------------------------------------\n"
echo -e "\n  Antes de ejecutar el script, se necesita instalar el paquete jq."
echo -e "  Puede seguir el tutorial de instalacion mencionado en la seccion anterior.\n"
echo "          1) Se le deben otorgar permisos de ejecucion al script. Para esto puede usar el siguiente comando: "
echo '                  $chmod +x Ejercicio5.sh'
echo "          2) Ejecutar el script, pasandole al menos uno de los parametros, ID o Nombre."
echo "              2.1) Para busqueda por ID, utilice el parametro -i o --id seguido de uno o varios IDs de personaje."
echo "              2.2) Para busqueda por Nombre, utilice el parametro -n o --nombre seguido de uno o varios nombres de personaje."
echo "              2.3) Para busqueda por ID y Nombre, utilice la combinacion de los dos puntos anteriores."


echo -e "\n-----------------------------------  Tutorial de desinstalacion de jq ----------------------------------\n"
echo "  Pasos para la desinstalacion:"
echo "      1) Abra una terminal."
echo "      2) Desinstale jq con el siguiente comando: "
echo "          $ sudo apt purge --autoremove -y jq"
echo "      En este paso si es la primera vez que usa el comando sudo, debera ingresar la contrasena del usuario root."
echo "      4) Verifique la desinstalacion con el siguiente comando: "
echo '          $jq --version'
echo "      Deberia recibir un mensaje de error indicando que el comando no se encuentra."

echo -e "\n---------------------------------------------- Ejemplos de llamadas -----------------------------------------------\n"
echo "  ACLARACION: Se utilizaran los nombres y valores de los archivos entregados en el lote de prueba."
echo -e "\n  Para llamar a la funcion de ayuda:"
echo '          $./Ejercicio5.sh -h o tambien se puede usar $./Ejercicio5.sh --help'
echo -e "\n  Para buscar un personaje por su id:"
echo '          $./Ejercicio5.sh -i [id del personaje]'
echo '          $./Ejercicio5.sh -i 1'
echo -e "\n  Para buscar varios personaje por su id:"
echo '          $./Ejercicio5.sh -i [lista de los id de los personaje]'
echo '          $./Ejercicio5.sh -i 1,2,3'
echo -e "\n  Para buscar un personaje por su nombre:"
echo '          $./Ejercicio5.sh -n [nombre del personaje]'
echo '          $./Ejercicio5.sh -n rick'
echo -e "\n  Para buscar varios personaje por su nombre:"
echo '          $./Ejercicio5.sh -n [lista de los nombre de los personaje]'
echo '          $./Ejercicio5.sh -n rick,morty'
echo -e "\n  Para buscar varios personajes por su id y su nombre:"
echo '          $./Ejercicio5.sh -i [lista de los id de los personajes] -n [lista de los nombre de los personajes]'
echo '          $./Ejercicio5.sh -i 1,2,3 -n rick,morty'
echo -e "\n  Resultado esperado del primer ejemplo: "
echo "       Character info:"
echo "       Id: 1"
echo "       Name: Rick Sanchez"
echo "       Status: Alive"
echo "       Species: Human"
echo "       Gender: Male"
echo "       Origin: Earth (C-137)"
echo "       Location: Citadel of Ricks"

echo -e "\n-------------------------------------------------- Aclaraciones ---------------------------------------------------\n"
echo "  En caso de pasar una lista con varios ids de personajes, se los debe separar con una coma y no utilizar espacios ni comillas."
echo "  Ejemplo valido de pasaje de parametro de ID:"
echo "      -i 1,2,3"
echo "  Ejemplo invalidos de pasaje de parametro de ID:"
echo "      -i 1, 2, 3"
echo "      -i \"1,2,3\""
echo "      -i \"1, 2, 3\""
echo -e "\n  En caso de pasar una lista con varios nombres de personajes, se los debe separar con una coma y no utilizar espacios."
echo "  Ejemplo valido de pasaje de parametro de Nombre:"
echo "      -n rick,morty"
echo "      -n \"rick,morty\""
echo "  Ejemplo invalidos de pasaje de parametro de Nombre:"
echo "      -n rick, morty"
echo "      -n \"rick, morty\""

echo -e "\n-------------------------------------------------------------------------------------------------------------------\n"
}

options=$(getopt -o i:n:h --l help,id:,nombre: -- "$@" 2> /dev/null)
if [ "$?" != "0" ] 
then
    echo 'Opciones no validas, consulte la ayuda para conocer los formatos aceptados'
    exit 1
fi

parametrosIngresados=false

eval set -- "$options"
while true
do
    case "$1" in

        -i | --id)
            id="$2"
            parametrosIngresados=true
            if [[ $id =~ ^[0-9]+(,[0-9]+)*$ ]]; then
                shift 2
            else
                echo "No se ingresaron datos del ID de un personaje de Rick y Morty correctamente"
                exit
            fi
            ;;
        -n | --nombre)
            nombre="$2"
            parametrosIngresados=true
            if [[ $nombre =~ ^[a-zA-Z]+(,[a-zA-Z]+)*$ ]]; then
                shift 2
            else
                echo "No se ingresaron datos del nombre de un personaje de Rick y Morty correctamente"
                exit
            fi
            ;;
        -h | --help)
            if [ "$#" -gt 2 ] || [ "$parametrosIngresados" = true ]; then
                    echo "El parametro de ayuda (-h / --help) no puede ir junto a otros parametros."
                    echo 'Ejemplo valido: $ ./Ejercicio5.sh -h o $ ./Ejercicio5.sh --help'
                    echo "Vuelva a intentarlo."
                    exit 1

            else
                    mostrar_ayuda
                    exit 0
            fi
            ;;
        *)  
            if [[ -z $id && -z $nombre ]]
            then
                echo "No se ingresaron datos del nombre ni de un id de un personaje de Rick y Morty correctamente"
                exit
            fi
            break
            ;;
    esac

done

declare -l nombre
nombre=$nombre

busqueda="$id,$nombre"

claves=$(echo "$busqueda" | awk -F ',' '{for (i=1; i<=NF; i++) if ($i != "") print $i}')

echo -e "Los ids y/o nombres a buscar fueron: $claves"
echo "---------------------------"

for clave in $claves; do

    archivo="$PWD/$clave.txt"

    if [ $(find "$PWD" -type f -name "$clave.txt" | wc -l ) -eq 1 ]; then
        #Este bloque condicional verifica si existe exactamente un archivo que coincide con el patrón "$clave-*.txt" en el directorio actual ($PWD).
        #find "$PWD" -type f -name "$clave-*.txt": Este comando busca archivos en el directorio actual ($PWD) que coincidan con el patrón "$clave-*.txt".
        #wc -l: Cuenta el número de líneas de salida de find, que corresponde al número de archivos encontrados., si es = 1 significa que lo encontro entonces cat lo muestra abajo
        echo -e "El archivo de los datos del personaje se encuentra en el sistema...\n"
        cat "$archivo"
        echo "---------------------------"

    else
        if [[ $clave =~ ^[0-9]+$ ]]; then
            URL="https://rickandmortyapi.com/api/character/$clave"
        else
            URL="https://rickandmortyapi.com/api/character/?name=$clave"
        fi    

        Json=$(curl -s "$URL")

        # Verificar si la solicitud a la API fue exitosa
        if [ -z "$Json" ]; then
            echo "Error: No se pudo conectar a la API. Verifica tu conexión a internet."
            exit 1
        fi

        if echo "$Json" | grep -q "error"; then
            echo "No se encuentra información del personaje de Rick y Morty con el valor: ($clave)"
            echo "---------------------------"
            continue
        fi

        # Crear el archivo si no existe
        touch "$archivo"
            
        # Extraer información del JSON y escribir en el archivo
        if [[ $clave =~ ^[0-9]+$ ]]; then

            echo "Informacion del personaje:" >> "$archivo"
            echo "Id: $(echo "$Json" | jq '.id')" >> "$archivo"
            echo "Name: $(echo "$Json" | jq '.name' | sed 's/"//g')" >> "$archivo"
            echo "Status: $(echo "$Json" | jq '.status' | sed 's/"//g')" >> "$archivo"
            echo "Species: $(echo "$Json" | jq '.species' | sed 's/"//g')" >> "$archivo"
            echo "Gender: $(echo "$Json" | jq '.gender' | sed 's/"//g')" >> "$archivo"
            echo "Origin: $(echo "$Json" | jq -r '.origin.name')" >> "$archivo"
            echo "Location: $(echo "$Json" | jq -r '.location.name')" >> "$archivo"
           
        else

            echo "Informacion del personaje:" >> "$archivo"
            echo "Id: $(echo "$Json" | jq -r '.results[0].id')" >> "$archivo"
            echo "Name: $(echo "$Json" | jq -r '.results[0].name' | sed 's/"//g')" >> "$archivo"
            echo "Status: $(echo "$Json" | jq -r '.results[0].status' | sed 's/"//g')" >> "$archivo"
            echo "Species: $(echo "$Json" | jq -r '.results[0].species' | sed 's/"//g')" >> "$archivo"
            echo "Gender: $(echo "$Json" | jq -r '.results[0].gender' | sed 's/"//g')" >> "$archivo"
            echo "Origin: $(echo "$Json" | jq -r '.results[0].origin.name')" >> "$archivo"
            echo "Location: $(echo "$Json" | jq -r '.results[0].location.name')" >> "$archivo"

        fi

            # Mostrar el contenido del archivo
            echo -e "El archivo de los datos del personaje NO se encontraba en el sistema...\n"
            cat $archivo
            echo "---------------------------"


    fi

done