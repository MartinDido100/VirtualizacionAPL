<#
.SYNOPSIS
Este script toma archivos CSV de notas de alumnos y genera un archivo JSON con las notas finales de cada alumno.

.DESCRIPTION
Se procesan las notas conceptuales y se les asigna un valor numérico antes de guardar las notas en variables JSON.
Puede imprimir los resultados por pantalla o crear un archivo JSON con los resultados.

.PARAMETER directorio
Ruta del directorio que contiene los archivos CSV a procesar.

.PARAMETER salida
Ruta del archivo JSON de salida.

.PARAMETER pantalla
Muestra la salida por pantalla, no genera el archivo JSON. Este parámetro no se puede usar a la vez que -salida.


.EXAMPLE
Get-Help .\Ejercicio1.ps1 -Full
Muestra la ayuda completa del script.

.EXAMPLE
.\Ejercicio1.ps1 -directorio "ruta\del\directorio" -pantalla
Procesa los archivos CSV en la ruta especificada y los muestra por pantalla.

.EXAMPLE
.\Ejercicio1.ps1 -directorio "ruta\del\directorio" -salida "resultados.json"
Procesa los archivos CSV en la ruta especificada y guarda los resultados en un archivo JSON cuyo nombre se recibe por parámetro.
#>


param(
    [Parameter(Mandatory=$true)]
    [ValidateScript({Test-Path $_ -PathType 'Container'})]
    [string]$directorio,

    [Parameter(Mandatory=$false)]
    [ValidateScript({-not ($pantalla -and $_)})]
    [string]$salida,

    [Parameter(Mandatory=$false)]
    [switch]$pantalla
)

if (-not $directorio) {
    Write-Error "El parámetro -directorio es obligatorio."
    exit
}

# Verificar que los parámetros -salida y -pantalla no se usen al mismo tiempo
if ($salida -and $pantalla) {
    Write-Error "No se pueden usar los parámetros -salida y -pantalla al mismo tiempo."
    exit
}

# Definir el directorio donde están los archivos CSV
$notas = @{}

# Obtener todos los archivos CSV en el directorio
$archivosCsv = Get-ChildItem -Path $directorio -Filter "*.csv"


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
        foreach ($nota in $notasAlumno) {
            $multiplicador = switch ($nota) {
                'b' { 1 }
                'r' { 0.5 }
                'm' { 0 }
                default { 0 }
            }
            $sumaTotal += (10 / ($notasAlumno.Length)) * $multiplicador
        }

        $sumaTruncada = [math]::Floor($sumaTotal)

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
        $json = $jsonObj | ConvertTo-Json -Depth 3
        Write-Output $json
    }
}


try {
    if ($pantalla) {
        $archivosCsv | Get-manejarArchivos
        exit
    } else {
        $archivosCsv | Get-manejarArchivos > "$salida"
    }
} catch {
    Write-Error "Se ha producido un error: $_"
    exit
}
