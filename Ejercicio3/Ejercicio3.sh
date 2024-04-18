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

            if [ $2 = '-h' ] || [ $2 = '--help' ]; then
                ayuda
                exit 0
            fi

            shift 2
        ;;
        -h | --help)
            ayuda
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
if [ ! -d $rutaArchivos ]; then
    echo "La ruta de los archivos no es valida"
    exit 1
fi

#Cantidad de arvhivos del directorio que tengan la extension
cantArchivos=$(ls "$directorio"/*."$extension" | wc -l)

# declare -A ocurrencias
# declare -A palabras
# declare -A caracteres
# declare -A palabrasMayores

cantTotal=0

#Inicializo palabrasMayores

for archivo in "$directorio"/*.txt; do

    awk_script = `awk -v cArch="$cantArchivos" -F"$separador" '

    BEGIN{
        mayorAct=0
        cantTotal=0
    }

    {
        for(i=1; i<=NF; i++){
            if( length( $i ) > 0 ){
                cantTotal++
                ocurrencias[ $i ]++
                palabras[ length( $i ) ]++
                
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

        for(palabra in palabrasMayores){
            print palabra, palabrasMayores[palabra]
        }

        for(caract in caracteres){
            print cara, caracteres[caract]
        }

        for(palabra in palabras){
            print palabra, palabras[palabra]
        }

        print cantTotal

    }

' "$archivo"`

read cantTotal palabrasMayores caracteres palabras <<< "$(awk "${awk_script}")"

# echo $cantTotal

done

