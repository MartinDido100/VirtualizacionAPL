#Ejercicio 2, Realizado en PowerShell.
#Integrantes:
#-SANTAMARIA LOAICONO, MATHIEU ANDRES
#-MARTINEZ, FABRICIO
#-DIDOLICH, MARTIN
#-LASORSA, LAUTARO
#-QUELALI AMISTOY, MARCOS EMIR

<#
.NOTES
---------------------------------------------------------------------------------------------------------------------------
                                                FUNCION DE AYUDA DEL EJERCICIO 2
---------------------------------------------------------------------------------------------------------------------------

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
Este script realiza una multiplicacion entre 2 matrices y analiza el resultado obtenido
.DESCRIPTION
Permite leer dos matrices de enteros desde un archivo, las multiplica e informa:
    - Orden de la matriz.
            El orden de la matriz nos indica la cantidad de filas y columnas, por ejemplo: 3x5 (3 filas y 5 columnas).
    - Si es cuadrada.
            Una matriz es cuadrada cuando la cantidad de filas y columnas son iguales.
    - Si es identidad.
            Una matriz es identidad cuando su diagonal principal esta compuesta por unos y el resto de las celdas por ceros.
    - Si es nula.
            Una matriz es nula si tiene todas las celdas en cero.
    - Si es fila.
            Una matriz es fila si tiene una sola fila.
    - Si es columna. 
            Una matriz es columna si tiene una sola columna.

.PARAMETER ayuda
-help: Funcion de ayuda del script. Descripcion del funcionamiento.
.PARAMETER matriz1
-matriz1: Ruta del archivo de entrada de la matriz 1
.PARAMETER matriz2
-matriz2: Ruta del archivo de entrada de la matriz 2
.PARAMETER separador
-separador: Caracter separador de valores. Opcional, por defecto es coma ','. 
No se puede elegir un numero o un guion (para no evitar inconvenientes con numeros negativos).
.INPUTS
La matriz pasada por parametro debe tener el mismo numero de columnas en cada fila, como el siguiente ejemplo:"
                                        0,2,5
                                        4,6,7
                                        6,4,-3

Se permite cualquier separador menos numeros y el caracter '-' (signo menos) 
por lo que tambien se admiten los siguientes formatos entre otros:
                1$3$5               1/3/5           1a3a5
                4$6$7               4/6/7           4a6a7
                6$4$-3              6/4/-3          6a4a-3

Se puede dejar como MÁXIMO un ÚNICO salto de línea al final de la matriz.
.OUTPUTS
La salida siempre se hace por pantalla.
.EXAMPLE
ACLARACION: Se utilizaran los nombres y valores de los archivos entregados en el lote de prueba.
    Para llamar a la funcion de ayuda:
        >get-help ./Ejercicio2.ps1 -Full
.EXAMPLE
    Para analizar una matriz que tiene como separador una coma ",":
        >./Ejercicio2.ps1 -matriz1[Path del archivo de entrada]
        >./Ejercicio2.ps1 -matriz1matriz.txt
.EXAMPLE
    Para que el caso de tener una matriz con un separador distinto a una coma ",":
        >./Ejercicio2.ps1 -matriz1 [Path del archivo de entrada] -separador [Caracter Separador]
        >./Ejercicio2.ps1 -matriz1 matriz.csv -separador "$"
.EXAMPLE
    Resultado esperado de analizar matriz.csv: 
        3 x 3
        Es cuadrada
        No es una matriz nula
        No es matriz fila ni matriz columna
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
