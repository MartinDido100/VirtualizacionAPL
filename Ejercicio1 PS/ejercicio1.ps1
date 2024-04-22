# Definir el directorio donde están los archivos CSV
$directorioCsv = ".\"
$notas = @{}

# Obtener todos los archivos CSV en el directorio
$archivosCsv = Get-ChildItem -Path $directorioCsv -Filter "*.csv"


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

$archivosCsv | Get-manejarArchivos > ./alumnos.json