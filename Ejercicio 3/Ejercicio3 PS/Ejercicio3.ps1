<#
.SYNOPSIS
Analiza archivos de texto para contar palabras y caracteres, excluyendo los caracteres que especifique el usuario.

.DESCRIPTION
Cada archivo de texto en un directorio dado es analizado, contando la cantidad de palabras y caracteres, excluyendo aquellos caracteres especificados. También proporciona estadísticas como la palabra más repetida y la frecuencia de cada caracter.

.PARAMETER directorio
El directorio que contiene los archivos de texto a procesar. Este parámetro es obligatorio.

.PARAMETER extension
La extensión de los archivos de texto a procesar. Este parámetro es obligatorio.

.PARAMETER omitir
Una cadena de caracteres que se deben omitir durante el análisis. Si no se especifica, no se omitirá ningún caracter.

.PARAMETER separador
El separador utilizado para dividir el texto en palabras. El valor predeterminado es un espacio (' ').

.EXAMPLE
PS> Procesar-Archivos -directorio "C:\Textos" -extension "txt" -omitir "abc" -separador " "
Este ejemplo procesa todos los archivos .txt en el directorio C:\Textos, omitiendo las letras a, b y c.

.EXAMPLE
PS> Procesar-Archivos -directorio "C:\Textos" -extension "txt"
Este ejemplo procesa todos los archivos .txt en el directorio C:\Textos sin omitir ningún caracter.

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