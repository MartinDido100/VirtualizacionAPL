<#
.SYNOPSIS
Este script toma dos archivos CSV y ejecuta una multiplicación de matrices.

.DESCRIPTION
Cada archivo debe contener una matriz, donde cada fila es una línea y los elementos están separados por un delimitador.
El script importa las matrices de los archivos CSV y las multiplica.
El resultado se muestra por pantalla y se indica si la matriz resultante es cuadrada, fila o columna.

.PARAMETER matriz1
Ruta del archivo CSV que contiene la primera matriz.

.PARAMETER matriz2
Ruta del archivo CSV que contiene la segunda matriz.

.PARAMETER separador
Carácter que se utiliza para separar los elementos de las matrices. Por defecto es la coma. No puede utilizarse un número como separador, ni un signo "-"

.EXAMPLE
Get-Help .\Ejercicio1.ps1 -Full
Muestra la ayuda completa del script.

.EXAMPLE
.\Ejercicio2.ps1 -matriz1 "ruta\de\la\matriz1.csv" -matriz2 "ruta\de\la\matriz2.csv"

.EXAMPLE
.\Ejercicio2.ps1 -matriz1 "ruta\de\la\matriz1.csv" -matriz2 "ruta\de\la\matriz2.csv" -separador ";"

.NOTES
Ambas matrices deben ser compatibles para la multiplicación.
La matriz resultante tendrá el mismo número de filas que la primera matriz y el mismo número de columnas que la segunda matriz.
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$matriz1,
    [Parameter(Mandatory=$true)]
    [string]$matriz2,
    [ValidatePattern("^[^0-9\-]+$")]
    [string]$separador = ','
)

try {
    if (-not (Test-Path $matriz1)) {
        throw "El archivo $matriz1 no existe."
    }
    if (-not (Test-Path $matriz2)) {
        throw "El archivo $matriz2 no existe."
    }
} catch {
    Write-Host "Error: $_"
    exit
}

function Import-CsvMatrix {
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string]$line,
        [string]$delimiter
    )
    Begin {
        $matrix = @()
        $columnas = 0
    }
    Process {
        $row = $line -split $delimiter
        if ($columnas -eq 0) {
            $columnas = $row.Length
        }
        if ($columnas -ne $row.Length) {
            throw "Todas las filas de la matriz deben tener la misma cantidad de elementos."
        }
        $row = $row | ForEach-Object {
            if (-not ($_ -match "^(-)?[0-9]+([\.,])?([0-9]+)?$")) {
                throw "El archivo contiene caracteres no permitidos, los valores deben ser numéricos. $_"
            }
            [float]$_ 
        }

        # Agrega la fila procesada a la matriz
        $matrix += ,@($row)
    }
    End {
        $matrix
    }
}

function Multiply-Matrices {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [float[][]]$matrix1,
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [float[][]]$matrix2
    )

    # Inicializar la matriz de resultados
    $result = New-Object 'float[][]' ($matrix1.Length)

    for ($i = 0; $i -lt $matrix1.Length; $i++) {
        $result[$i] = New-Object 'float[]' ($matrix2[0].Length)
    }

    # Verificar que las matrices sean compatibles para la multiplicación
    if ($matrix1[0].Length -ne $matrix2.Length) {
        throw "Las matrices no son compatibles para la multiplicación."
    }

    for ($i = 0; $i -lt $matrix1.Length; $i++) {
        for ($j = 0; $j -lt $matrix2[0].Length; $j++) {
            $sum = 0
            for ($k = 0; $k -lt $matrix1[0].Length; $k++) {
                $sum += $matrix1[$i][$k] * $matrix2[$k][$j]
            }
            $result[$i][$j] = $sum
        }
    }

    # Devolver la matriz de resultados
    return $result
}

function Get-MatrixInfo {
    param(
        [float[][]]$matrix
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

try {
    $matrix1 = Get-Content $matriz1 | Import-CsvMatrix -delimiter $separador
    $matrix2 = Get-Content $matriz2 | Import-CsvMatrix -delimiter $separador
    $resultMatrix = Multiply-Matrices -matrix1 $matrix1 -matrix2 $matrix2
    $resultMatrix | ForEach-Object { $_ -join ' ' }
    Get-MatrixInfo -matrix $resultMatrix
} catch {
    Write-Host "Error: $_"
    exit
}
