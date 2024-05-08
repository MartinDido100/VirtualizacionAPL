#Ejercicio 3, Realizado en PowerShell.

#Integrantes:
#-SANTAMARIA LOAICONO MATHIEU ANDRES
#-MARTINEZ FABRICIO
#-DIDOLICH MARTIN
#-LASORSA LAUTARO
#-QUELALI AMISTOY MARCOS EMIR

<#
.NOTES
--------------------------------------------------------------------------------------------------------------------------------
                                                FUNCION DE AYUDA DEL EJERCICIO 3
--------------------------------------------------------------------------------------------------------------------------------

Informacion General:

(+) Universidad: Universidad Nacional de la Matanza.
(+) Carrera: Ingenieria en Informatica.
(+) Materia: Virtualizacion de Hardware.
(+) Comision: Jueves-Noche.
(+) Cuatrimestre: 1C2024.
(+) APL: Numero 1.
(+) Integrantes: -SANTAMARIA LOAICONO MATHIEU ANDRES, -MARTINEZ FABRICIO, -DIDOLICH MARTIN, -LASORSA LAUTARO, -QUELALI AMISTOY MARCOS EMIR.
(+) Grupo: Numero 1.
(+) Resuelto en: PowerShell.
.SYNOPSIS
Analiza los archivos de texto de un directorio y realiza un informe acerca de las palabras leidas.
.DESCRIPTION
Analiza los archivos de texto en un directorio pasado por parametro e informa un resumen final con:
    -La cantidad de ocurrencias de palabras de X caracteres.
    -La palabra o palabras que más ocurrencias tuvo, puede ser más de una si la cantidad de ocurrencias es igual.
    -La cantidad total de palabras.
    -El promedio de palabras por archivo (cantidad de palabras sobre el total de archivos analizados)
    -El carácter más repetido.

Aclaraciones:

-Busca los archivos dentro del directorio recursivamente, es decir, que se buscara dentro del directorio y los subdirectorios
los archivos que cumplan con las extensiones indicadas.

-Las extensiones no hay que pasarlas entre comillas.
    Formas validas de pasar las extensiones:    
    -extension txt, log, html, csv
    
    Forma invalida de pasar las extensiones:
    -extension "txt, log, html"

-El analisis de este script NO es case sensitive, es decir, no se distingue entre mayusculas y minusculas.
    Por ejemplo: "Hola" y "hola" seran consideradas la misma palabra, por lo que si en el archivo aparecen escritas de ambas
    formas, seran consideradas como la misma palabra con 2 ocurrencias.

-En el resumen final, para diferenciar las distintas formas en las que aparecio la palabra en los archivos se la muestra
encerrada entre parentesis. 
    
    Por ejemplo: 
    -Cantidad maxima de ocurrencias: 2
    -Palabra(s) con mas ocurrencias: hola con dos ocurrencias

    En este caso, la palabra "Hola" se la escribio en los archivos tanto con la 'H' en mayuscula como con la 'h' en minuscula. 
    Pero en total, sumando las ocurrencias de "Hola" y de "hola", llego al maximo de ocurrencias (2 ocurrencias).
    
    Esto no significa que "Hola" tuvo 2 ocurrencias individualmente y "hola" tuvo otras 2 ocurrencias, sino que la suma de ambas
    dio como resultado las 2 ocurrencias.

.PARAMETER directorio
-directorio: Ruta del directorio a analizar. Opcional, en caso de no informarse se ejecuta sobre la ruta actual.
.PARAMETER extension
-extension: Si esta presente, indica las extensiones de los archivos a analizar. Opcional. Por defecto analiza todo tipo de archivo.
.PARAMETER separador
-separadorUn carácter separador de palabras. Opcional. Valor por defecto: “ “ (espacio). Ignora si es mayúscula o minúscula.
.PARAMETER omitir
-omitir: Array de caracteres a buscar en las palabras del archivo. Si ese carácter se encuentra en la palabra, esta no debe ser contabilizada.

.INPUTS
Solo se analizan los archivos de texto plano dentro del directorio indicado. 
Quedan excluidos del analisis archivos de otro tipo tales como imagenes, videos, audios, etc.
.OUTPUTS
El resumen final se hara por pantalla.
.EXAMPLE
ACLARACION: Se utilizaran los nombres y valores de los archivos entregados en el lote de prueba.
    Para llamar a la funcion de ayuda:
        >get-help ./Ejercicio3.ps1 -Full
.EXAMPLE
Si se indica el directorio y las extensiones, se analizaran todos los archivos 
que contenga el directorio indicado, que cumplan con las extensiones indicadas.
    >./Ejercicio3.ps1 -directorio ./Directorio/ -extension txt
        
    Resultado esperado: 
      Resumen Final:
	Palabras de 4 caracteres: 2
	Palabra/s mas repetida/s: Hola con 2 ocurrencias
	Cantidad total de palabras: 2
	Promedio de palabras por archivo: 0.666666666666667
	Caracter/es mas repetido/s: H, l, a con 2 ocurrencias

.EXAMPLE
Si se indica una extension y no hay ningun archivo de esa extension en el directorio indicado se muestra el siguiente mensaje:

    >./Ejercicio3.ps1 -directorio ./Directorio/ -extension xml -omitir "a"

    Resultado esperado:
        
	"No se encontraron archivos con la extensión '$extension' en el directorio '$directorio'.
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateScript({
        if (-not (Test-Path $_ -PathType 'Container')) {
            throw "El directorio `'$($_)`' no existe. Por favor, verifica la ruta e inténtalo de nuevo."
        }
        return $true
    })]
    [string]$directorio,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$extension,
    [string]$omitir,
    [string]$separador = ' '
)

function Procesar-Palabras {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [string]$linea,
        [string]$letrasOmitir
    )

    BEGIN {
        $mayorAct = 0
        $cantTotal = 0
        $ocurrencias = @{}
        $palabrasPorCantCaracter = @{}
        $palabrasMayores = @{}
        $caracteres = @{}
        $maxCaracteres = 0
        $caracterMayor = ""
    }

    PROCESS {
        $palabras = $linea -split $separador

        foreach ($i in $palabras) {
            $i = $i -replace '[[:punct:]|,]', ''
            if (-not $letrasOmitir -or ($i -notmatch "[$letrasOmitir]")) {
                $cantTotal++
                if ($null -eq $ocurrencias[$i]) {
                    $ocurrencias[$i] = 0
                }
                $ocurrencias[$i]++
                if ($null -eq $palabrasPorCantCaracter[$i.Length]) {
                    $palabrasPorCantCaracter[$i.Length] = 0
                }
                $palabrasPorCantCaracter[$i.Length]++
                for ($nCaracter = 0; $nCaracter -lt $i.Length; $nCaracter++) {
                    if($null -eq $caracteres[$i[$nCaracter]]) {
                        $caracteres[$i[$nCaracter]] = 0
                    }
                    $caracteres[$i[$nCaracter]]++
                    if($caracteres[$i[$nCaracter]] -gt $maxCaracteres) {
                        $maxCaracteres = $caracteres[$i[$nCaracter]]
                        $caracterMayor = $i[$nCaracter]
                    } elseif ($caracteres[$i[$nCaracter]] -eq $maxCaracteres) {
                        $caracterMayor += ", " + $i[$nCaracter]
                    }
                }
            }
        }

    }

    END {
        foreach ($palabra in $ocurrencias.Keys) {
            if ($ocurrencias[$palabra] -gt $mayorAct) {
                $mayorAct = $ocurrencias[$palabra]
                $palabrasMayores.Clear()
                $palabrasMayores[$palabra] = $ocurrencias[$palabra]
            } elseif ($ocurrencias[$palabra] -eq $mayorAct) {
                $palabrasMayores[$palabra] = $ocurrencias[$palabra]
            }
        }

        foreach ($cantCar in $palabrasPorCantCaracter.Keys) {
            Write-Host "Palabras de $cantCar caracteres: $($palabrasPorCantCaracter[$cantCar])"
        }

        foreach ($palabraMayor in $palabrasMayores.Keys) {
            Write-Host "Palabra/s mas repetida/s: $palabraMayor con $($ocurrencias[$palabraMayor]) ocurrencias"
        }

        Write-Host "Cantidad total de palabras: $cantTotal"
        Write-Host "Promedio de palabras por archivo: $($cantTotal / 3)"

        Write-Host "Caracter/es mas repetido/s: $caracterMayor con $maxCaracteres ocurrencias"
    }
}

Write-Host "$directorio\*.$extension"
$archivos = Get-ChildItem "$directorio\*$extension" -File

if ($archivos.Count -gt 0) {
    $archivos | Get-Content -Encoding UTF8 | Procesar-Palabras -letrasOmitir "$omitir"
} else {
    Write-Host "No se encontraron archivos con la extensión '$extension' en el directorio '$directorio'."
}