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
    [string]$matriz1,
    [Parameter(Mandatory=$true)]
    [string]$matriz2,
    [string]$separador = ','
)

function Import-CsvMatrix {
    param(
        [string]$path,
        [string]$delimiter
    )
    $matrix = Get-Content $path | ForEach-Object {
        # Divide cada línea por el delimitador para crear un array de enteros
        $row = $_ -split $delimiter | ForEach-Object { [int]$_ }
        # Retorna el array de enteros (fila de la matriz)
        ,@($row)
    }
    return $matrix
}

function Multiply-Matrices {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [int[][]]$matrix1,
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [int[][]]$matrix2
    )
    Begin {
        # Inicializar la matriz de resultados
        $result = New-Object 'int[][]' ($matrix1.Length)
        for ($i = 0; $i -lt $matrix1.Length; $i++) {
            $result[$i] = New-Object 'int[]' ($matrix2[0].Length)
        }
    }
    Process {
        for ($i = 0; $i -lt $matrix1.Length; $i++) {
            for ($j = 0; $j -lt $matrix2[0].Length; $j++) {
                $sum = 0
                for ($k = 0; $k -lt $matrix1[0].Length; $k++) {
                    $sum += $matrix1[$i][$k] * $matrix2[$k][$j]
                }
                $result[$i][$j] = $sum
            }
        }
    }
    End {
        # Devolver la matriz de resultados
        return $result
    }
}

function Get-MatrixInfo {
    param(
        [int[][]]$matrix
    )
    $rows = $matrix.Length
    $cols = $matrix[0].Length
    $esCuadrada = $rows -eq $cols
    $esMatrizFila = $rows -eq 1
    $esMatrizColumna = $cols -eq 1

    Write-Host "Orden de la matriz: $rows x $cols"
    Write-Host "Es cuadrada: $(if ($esCuadrada) {'Sí'} else {'No'})"
    Write-Host "Es una matriz fila: $(if ($esMatrizFila) {'Sí'} else {'No'})"
    Write-Host "Es una matriz columna: $(if ($esMatrizColumna) {'Sí'} else {'No'})"
}

# Cargar las matrices
$matrix1 = Import-CsvMatrix -path $matriz1 -delimiter $separador
$matrix2 = Import-CsvMatrix -path $matriz2 -delimiter $separador

# Multiplicar las matrices
$resultMatrix = Multiply-Matrices -matrix1 $matrix1 -matrix2 $matrix2

# Mostrar el resultado
$resultMatrix | ForEach-Object { $_ -join ' ' }
Get-MatrixInfo -matrix $resultMatrix
