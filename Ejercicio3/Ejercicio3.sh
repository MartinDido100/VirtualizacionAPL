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

cantArchivos=$(ls $directorio/*.$extension | wc -l)

letrasOmitir=$(awk -v omitir="$omitir" 'BEGIN{gsub(/[\[\],]/,"",omitir); print omitir}')

if [ $letrasOmitir = " " ]; then
    echo "No se ingresaron letras a omitir"
    exit 1
fi

cat $directorio/*.$extension | awk -v cArch="$cantArchivos" -v letrasOmitir="$letrasOmitir" -F"$separador" '

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
