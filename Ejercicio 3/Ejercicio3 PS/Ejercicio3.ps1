param(
    [Parameter(Mandatory=$true)]
    [ValidateScript({Test-Path $_ -PathType 'Container'})]
    [string]$directorio,
    [Parameter(Mandatory=$true)]
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
                    Write-Host "Longitud de palabra: $i $($i.Length)"
                    $palabrasPorCantCaracter[$i.Length] = 0
                }
                $palabrasPorCantCaracter[$i.Length]++
                for ($nCaracter = 0; $nCaracter -lt $i.Length; $nCaracter++) {
                    if($null -eq $caracteres[$i[$nCaracter]]) {
                        $caracteres[$i[$nCaracter]] = 0
                    }
                    $caracteres[$i[$nCaracter]]++
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

        foreach ($caracter in $caracteres.Keys) {
            Write-Host "Caracter [$caracter] aparece $($caracteres[$caracter]) veces"
        }
    }
}

Get-Content "$directorio\*.$extension" -Encoding UTF8 | Procesar-Palabras -letrasOmitir "$omitir"
