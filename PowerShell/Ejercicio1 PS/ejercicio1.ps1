#Ejercicio 1, Realizado en PowerShell.

#Integrantes:
#-SANTAMARIA LOAICONO MATHIEU ANDRES
#-MARTINEZ FABRICIO
#-DIDOLICH MARTIN
#-LASORSA LAUTARO
#-QUELALI AMISTOY MARCOS EMIR

<#
.NOTES
--------------------------------------------------------------------------------------------------------------------------------
                                                FUNCION DE AYUDA DEL EJERCICIO 1
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
Se necesita implementar un script que dado un archivo CSV con las notas de diferntes alumnos en diferentes materias,"
realizar un resumen de las notas de cada alumno para luego poder publicarlo en un sitio web"
Una vez obtenida la información, se generará un archivo JSON con la información obtenida"
.DESCRIPTION
El programa recibe por parametro el directorio donde se encuentra el archivo CSV y la pantalla o la
ruta de salida, procesara dicho archivo y realizara un resumen de las notas de cada alumno y luego generara un archivo
JSON con la informacion obtenida y en el directorio indicado por parametro.

.PARAMETER ayuda
-help: Funcion de ayuda del script. Descripcion del funcionamiento.
.PARAMETER directorio
-directorio: Ruta del directorio que contiene los archivos CSV a procesar
.PARAMETER salida
-salida: Ruta del archivo JSON de salida
.PARAMETER pantalla
-pantalla: Muestra la salida por pantalla, no genera el archivo JSON. Este parámetro no se puede 
echo usar a la vez que salida

.ACLARACIONES
el script solo recibe 2 parametros, siendo estos directorio y pantalla o directorio y salida
en el caso de que se pasen los parametros pantalla y salida, el script no funcionara y mostrara el error

.INPUTS
El archivo de entrada debe tener formato CSV donde se respete el siguiente formato:
DNI-alumno,nota-ej-1,nota-ej-2,...,nota-ej-N
10100100,b,r,...,m
20200200,r,b,...,b
    
.OUTPUTS
Dependiendo del parametro pasado, se generara un archivo JSON en el directorio indicado como salida, o 
se imprimira por pantalla dicho archivo JSON sin sen guardado


.EXAMPLE
ACLARACION: Se utilizaran los nombres y valores de los archivos entregados en el lote de prueba."
Para llamar a la funcion de ayuda:"
$./Ejercicio1.sh -h o tambien se puede usar $./Ejercicio1.sh --help"
Para generar el JSON"
/Ejercicio1.sh -d directorio -s salida
para mostrar por pantalla
$./Ejercicio1.sh -d directorio -p pantalla
salida esperada en ambos casos (tanto como por pantalla o en archivo json)
 {
"notas": [
 {
 "dni": "12345678",
 "notas": [
 { "materia": 1115, "nota": 8 },
 { "materia": 1116, "nota": 2 }
 ]
 },
 {
 "dni": "87654321",
 "notas": [
 { "materia": 1116, "nota": 9 },
 { "materia": 1118, "nota": 7 }
 ]
 }
] }"
#>


param(
    [Parameter(Mandatory=$true)]
    [ValidateScript({
        if (-not (Test-Path -Path $_ -PathType Container)) {
            throw "El directorio '$_' no existe"
        }
        $true
    })]
    [string]$directorio,

    [Parameter(Mandatory=$false)]
    [switch]$pantalla,

    [Parameter(Mandatory=$false)]
    [ValidateScript({
        if(Test-Path $_ -PathType 'Container'){
            return $true
        }else {
            throw "El directorio de salida no existe."
            return $false
        }
    })]
    [string]$salida
)

if (-not $directorio) {
    Write-Error "El parámetro -directorio es obligatorio."
    exit
}

$archivosCsv = Get-ChildItem -Path "$directorio/*.csv"

if($archivosCsv.Count -eq 0){
    Write-Error "No se encontraron archivos CSV en el directorio."
    exit
}

if(-not $salida -and -not $pantalla) {
    Write-Error "Debe especificar un archivo de salida o usar el parámetro -pantalla."
    exit
}

# Verificar que los parámetros -salida y -pantalla no se usen al mismo tiempo
if ($salida -and $pantalla) {
    Write-Error "No se pueden usar los parámetros -salida y -pantalla al mismo tiempo."
    exit
}

function Get-csvAArray() {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [string]$value,
        [Parameter(Mandatory=$true)]
        [string]$materia
    )
    Process {
        # Saltar la línea de encabezados
        if ($value -match "DNI-alumno") { return }

        # Separar los valores por comas
        $valores = $value -split ","
        $dni = $valores[0]
        $notasAlumno = $valores[1..($valores.Length - 1)]

        # Calcular la nota final
        $sumaTotal = 0
        $pesoNotas = 10 / ($notasAlumno.Length)
        foreach ($nota in $notasAlumno) {
            $multiplicador = switch ($nota) {
                'b' { 1 }
                'r' { 0.5 }
                'm' { 0 }
                default { 0 }
            }
            $sumaTotal += $pesoNotas * $multiplicador
        }

        $sumaTruncada = [System.Math]::Floor($sumaTotal)

        if ($notas[$dni]) {
            $notas[$dni] += "|"
        }
        $notas[$dni] += "$materia $sumaTruncada"
    }
}

function Get-manejarArchivos() {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [System.IO.FileInfo]$value
    )
    BEGIN {
        $jsonObj = @()
    }
    Process {
        if($value.Extension -ne ".csv"){
            Write-Error "El archivo $value no es un archivo CSV."
            exit
        }
        
        if($value.BaseName -notmatch "^\d+$"){
            Write-Error "El archivo $value tiene un nombre invalido."
            return;
        }
        $contenidoCsv = Get-Content -Path $value.FullName
        $contenidoCsv | Get-csvAArray -materia $value.BaseName
    }
    END {
        # Convertir el objeto a JSON
        foreach ($dni in $notas.Keys) {
            $notasArray = @()
            $notasSplit = $notas[$dni] -split "\|"
            foreach ($nota in $notasSplit) {
                $notaSplit = $nota -split " "
                $notasArray += @{
                    materia = $notaSplit[0]
                    nota = [int]$notaSplit[1]
                }
            }
            $jsonObj += @{
                dni = $dni
                notas = $notasArray
            }
        }
        #
        $json = $jsonObj | ConvertTo-Json -Depth 3
        Write-Output $json
    }
}

try {
    # Se define una variable para guardar las notas de los distintos alumnos
    $notas = @{}
    # Se obtiene todos los archivos CSV en el directorio
    $archivosCsv = Get-ChildItem -Path $directorio -Filter "*.csv"
    if ($pantalla) {
        $archivosCsv | Get-manejarArchivos
        exit
    } else {
        Write-Output "Guardando resultados en $salida/resultado.json..."
        $archivosCsv | Get-manejarArchivos > "$salida/resultado.json"
    }
} catch {
    Write-Error "Se ha producido un error: $_"
    exit
}
