#!/bin/bash 

#Ejercicio 3, Realizado en Bash.
#Integrantes:

#-SANTAMARIA LOAICONO, MATHIEU ANDRES
#-MARTINEZ, FABRICIO
#-DIDOLICH, MARTIN
#-LASORSA, LAUTARO
#-QUELALI AMISTOY, MARCOS EMIR

# Funcion de ayuda
function mostrar_ayuda(){
echo -e "\n-------------------------------------------------------------------------------------------------------------------\n"
echo -e "                                       FUNCION DE AYUDA DEL EJERCICIO 3"
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
echo "  Desarrollar dos scripts, uno en bash y otro en Powershell, que analicen los archivos de texto en un"
echo "  directorio pasado por parametro e informen un resumen final con:"
echo "      -La cantidad de ocurrencias de palabras de X caracteres. Se deben incluir todos los largos de caracteres. Ejemplo:"
echo "      .Palabras de 1 caracter: 5"
echo "      .Palabras de 2 caracteres: 10"
echo "      ..."
echo "      .Palabras de N caracteres: 32"
echo "      -La palabra o palabras que más ocurrencias tuvo, puede ser más de una si la cantidad de ocurrencias es igual."
echo "      -La cantidad total de palabras."
echo "      -El promedio de palabras por archivo (cantidad de palabras sobre el total de archivos analizados)."
echo "      -El carácter más repetido."

echo -e "\n------------------------------------------------ Que hace el Script -----------------------------------------------\n"
echo "  Analiza los archivos de texto de un directorio y realiza un informe acerca de las palabras leidas."

echo -e "\n------------------------------------------------ Breve Descripcion  -----------------------------------------------\n"
echo "  El siguiente script recibe por parametro un directorio que contiene archivos de texto."
echo "  Lee cada uno de esos archivos, y emite un informe final con:"
echo "      -La cantidad de ocurrencias de palabras de X caracteres. Se deben incluir todos los largos de caracteres. Ejemplo:"
echo "      -La palabra o palabras que más ocurrencias tuvo, puede ser más de una si la cantidad de ocurrencias es igual."
echo "      -La cantidad total de palabras."
echo "      -El promedio de palabras por archivo (cantidad de palabras sobre el total de archivos analizados)."
echo "      -El carácter más repetido."
echo "  El informe final se hara por pantalla."
echo "  El script permite filtrar los archivos que se desean analizar con el parametro -x para indicar la extension."

echo -e "\n---------------------------------------------- Parametros de Entrada ----------------------------------------------\n"
echo "  -h / --help: Descripcion de los parametros que se le deben pasar al programa."
echo "  -d / --directorio: Ruta del directorio a analizar. Obligatorio."
echo "  -x / --extension: Si esta presente, indica las extensiones de los archivos a analizar. Opcional. (.txt por defecto)"
echo "  -s / --separador Un carácter separador de palabras. Opcional. Valor por defecto: “ “ (espacio). Ignora si es" 
echo "  mayúscula o minúscula."
echo " -o / --omitir Array de caracteres a buscar en las palabras del archivo. Si ese carácter se encuentra en la" 
echo "  palabra, esta no debe ser contabilizada. (Obligatorio)"
:
echo -e "\n-------------------------------------------------- Forma de Uso ---------------------------------------------------\n"
echo "  Pasos:"
echo "          1) Se le deben otorgar permisos de ejecucion al script. Para esto puede usar el siguiente comando: "
echo '                  $chmod +x Ejercicio3.sh'
echo "          2) Ejecutar el script, por defecto analiza el directorio actual. Si se quiere analizar otro directorio,"
echo "             indicar el path de ese directorio con el parametro -d o --directorio."
echo "          3) Si se desea analizar algun/os tipo de archivo en particular, indicar la extension con el parametro -x o --extension"
echo "          4) Tanto la extension como el separador son opcionales"

echo -e "\n---------------------------------------------- Ejemplos de llamadas -----------------------------------------------\n"
echo "  ACLARACION: Se utilizaran los nombres y valores de los archivos entregados en el lote de prueba."
echo -e "\n  Para llamar a la funcion de ayuda:"
echo '          $./Ejercicio3.sh -h o tambien se puede usar $./Ejercicio3.sh --help'
echo -e "\n  Si se desean analizar todos los archivos dentro del directorio sin extension especifica:"
echo '          $./Ejercicio3.sh -d [Path del directorio] -s [separador] -o [arrayAomitir]'
echo -e "\n  Si se desean analizar todos los archivos dentro del directorio sin extension ni separador especifico:"
echo '          $./Ejercicio3.sh -d [Path del directorio] -o [arrayAomitir]'
echo -e "\n  Si se quieren analizar los archivos con extension "
echo '          $./Ejercicio3.sh -d [Path del directorio] -x [extension] -s [separador] -o [omitir] '
echo -e "\n  Resultado esperado de analizar todos los archivos: "
echo " contenido archivo 1: [ho,la ,como, eees,tas]"
echo "contenido archivo 2: [aprueee,ben,nos&,vor,como]"
echo " separador= [,] y omitir = [&]"
echo "  La cantidad de ocurrencias de palabras de:"
echo "  2 caracteres: 1"
echo "  3 caracteres: 4"
echo "  4 caracteres: 2"
echo "  5 caracteres: 1"
echo "  7 caracteres: 1"
echo "          -Cantidad maxima de ocurrencias:                5 ocurrencias"
echo "          -Palabra/s con mas ocurrencias:                 como"
echo "          -Longitud de la palabra mas larga:              7 caracteres"
echo "          -Palabra/s mas larga:                           aprueee"
echo "          -La cantidad total de palabras analizadas fue:  9"
echo "          -La cantidad total de archivos analizados fue:  2"
echo "          -El promedio de palabras por archivo fue:       5"
echo "          -El caracter mas repetido:                      e"

echo -e "\n-------------------------------------------------- Aclaraciones ---------------------------------------------------\n"
echo "  Se pueden pasar los path de forma tanto absoluta como relativa."
echo "  Los parametros se pueden pasar en cualquier orden."
echo "  Por defecto, se analizaran todos los archivos de texto dentro del directorio especificado."
echo " los unicos parametros opcionales son -x (extension) y -s (separador), que en el caso de no estar"
echo " especificados, se tomaran los valor por defecto txt y " " respectivamente".
echo -e "\n-------------------------------------------------------------------------------------------------------------------\n"
}

#Configuro como me vienen los parametros, -o para los cortos y --l para los largos, el 2> /dev/null es para que no muestre errores
# Los : son para que sepa que el parametro necesita un valor
options=$(getopt -o d:,x:,s:,o:,h --l help,directorio:,omitir:,extension:,separador: -- "$@" 2> /dev/null)

directorio="false"
omitir="false"
extension="false"
separador="false"

eval set -- "$options"
while true
do
    case "$1" in
        -s | --separador)
            separador=$2
            shift 2
        ;;
        -x | --extension)
            extension=$2
            shift 2
        ;;
        -d | --directorio)
            directorio=$2

            if [ "$2" = '-h' ] || [ "$2" = '--help' ]; then
                ayuda
                exit 0
            fi

            shift 2
        ;;
        -h | --help)
            mostrar_ayuda
            exit 0
        ;;
        -o | --omitir)
            omitir=$2
            shift 2
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

if [ "$directorio" = "false" ]; then
    echo "Falta el parametro -d/--directorio, use -h o --help para ayuda"
    exit 1
fi

if [ "$omitir" = "false" ]; then
    echo "Falta el parametro -o/--omitir, use -h o --help para ayuda"
    exit 1
fi

if [ "$separador" = "false" ]; then
    separador=" "
fi

if [ "$extension" = "false" ]; then
    extension="txt"
fi

#Verifico si la ruta es valida
if [ ! -d "$directorio" ]; then
    echo "La ruta de los archivos no es valida"
    exit 1
fi

cantArchivos=$(ls "$directorio"/*.$extension | wc -l)

letrasOmitir=$(awk -v omitir="$omitir" 'BEGIN{gsub(/[\[\],]/,"",omitir); print omitir}')

if [ $letrasOmitir = " " ]; then
    echo "No se ingresaron letras a omitir"
    exit 1
fi

cat "$directorio"/*.$extension | awk -v cArch="$cantArchivos" -v letrasOmitir="$letrasOmitir" -F"$separador" '

    BEGIN{
        mayorAct=0
        cantTotal=0
        palabrasMayores[""]=0
    }

    {
        for(i=1; i<=NF; i++){
            omitir=0
            for(letraOmitir=1; letraOmitir<=length(letrasOmitir); letraOmitir++){
                if( index( $i, substr( letrasOmitir, letraOmitir, 1 ) ) > 0){
                    omitir=1
                }
            }

            if( length( $i ) > 0 && omitir == 0){
                cantTotal++
                ocurrencias[ $i ]++
                palabrasPorCantCaracter[ length( $i ) ]++
                
                for(nCaracter = 1; nCaracter <= length( $i ); nCaracter++){
                    caracteres[ substr( $i, nCaracter, 1 ) ]++
                }

            }
        }
    }

    END{

        for(palabra in ocurrencias){
            if(ocurrencias[palabra] > mayorAct){

                mayorAct=ocurrencias[palabra]
                delete palabrasMayores
                palabrasMayores[palabra]=ocurrencias[palabra]

            }else if (ocurrencias[palabra] == mayorAct){

                palabrasMayores[palabra]=ocurrencias[palabra]

            }
        }

        for(cantCar in palabrasPorCantCaracter){
            print "Palabras de "cantCar" caracteres: "palabrasPorCantCaracter[cantCar]
        }

        for(palabraMayor in palabrasMayores){
            print "Palabra/s mas repetida/s: "palabraMayor" con "ocurrencias[palabraMayor]" ocurrencias"
        }

        print "Cantidad total de palabras: "cantTotal

        print "Promedio de palabras por archivo: "cantTotal/cArch

        for(caracter in caracteres){
            print "Caracter ["caracter"] aparece "caracteres[caracter]" veces"
        }

    }

'

exit 0