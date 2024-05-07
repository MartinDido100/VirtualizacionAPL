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

param (
    [Parameter(Mandatory=$true)]
    [ValidateScript({
        if (-not (Test-Path -Path $_ -PathType Container)) {
            throw "El directorio '$_' no existe"
        }
        $true
    })]
    [string]$directorio,

    [Parameter(Mandatory=$false)]
    [ValidateScript({
        if (-not (Test-Path -Path $_ -PathType Container)) {
            throw "El directorio de salida '$_' no existe"
        }
        $true
    })]
    [string]$salida,

    [Parameter(Mandatory=$false)]
    [ValidateScript({
        if (-not ($_ -eq "create" -or $_ -eq "modify")) {
            throw "Solo se permiten los valores 'create' o 'modify' para el patron"
        }
        $true
    })]
    [string]$patron,

    [Parameter(Mandatory=$false)]
    [switch]$kill
)

if($kill -and ($patron -or $salida)){
    Write-Host "No se permiten los parametros 'patron' o 'salida' si se especifica el parametro 'kill'"
    return
}

if(-not $kill -and (-not $patron -or -not $salida)){
    Write-Host "Los parametros 'patron' y 'salida' son obligatorios si no se especifica el parametro 'kill'"
    return
}

$directorio=Resolve-Path $directorio

if($kill){
    Stop-Job -Name "daemon$directorio"
    Remove-Job -Name "daemon$directorio"
    Write-Host "Se ha detenido el monitoreo en el directorio $directorio"
    return
}

try{
    $existeMonitoreo = Get-Job -Name "daemon$directorio" -ErrorAction SilentlyContinue
    if($existeMonitoreo.count -ge 1){
        Write-Host "Ya existe un monitoreo en el directorio $directorio"
        return
    }
}catch{
    # No hacer nada
}


$salida=Resolve-Path $salida

$evento = "Changed"

if($patron -eq "create"){
    $evento="Created"
}

$ruta = ".\monitoreo.log"
if (-not (Test-Path -Path $ruta)) {
    #Mando la salida a un null para que no se muestre en pantalla 
    New-Item -Path $ruta -ItemType "file" > $null
}

$proceso={
    param($directorio, $pathsalida,$ruta,$evento)

    $watcher = New-Object System.IO.FileSystemWatcher
    $watcher.Path = $directorio
    $watcher.IncludeSubdirectories = $true

    $action={
        $FullPath = $event.SourceEventArgs.FullPath
        $ChangeType = $event.SourceEventArgs.ChangeType
        $Timestamp = $event.TimeGenerated

        $formato=$Timestamp.ToString("yyyyMMdd-HHmmss")

        $formato = $Timestamp.ToString("yyyyMMdd-HHmmss")

        try {
            Compress-Archive -Path "$directorio" -DestinationPath "$pathsalida\$formato.zip"
        } catch {
            Write-Host "Error durante la compresion: $_" >> $ruta
        }

        $text = "{0} was {1} at {2}" -f $FullPath, $ChangeType, $Timestamp
        $text >> $ruta
    }

    $handlers = . {
        Register-ObjectEvent -InputObject $watcher -EventName $evento  -Action $action
    }

    $watcher.EnableRaisingEvents = $true

    while($true){
        wait-Event -Timeout 1
    }

}

$job = start-Job -Name "daemon$directorio" -ScriptBlock $proceso -ArgumentList $directorio, $salida, $ruta,$evento

Write-Host "Ha comenzado el monitoreo en segundo plano, para detenerlo debe ejecutar el script con el comando -kill"