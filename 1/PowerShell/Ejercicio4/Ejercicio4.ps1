#Ejercicio 4, Realizado en PowerShell.

#Integrantes:
#-SANTAMARIA LOAICONO MATHIEU ANDRES
#-MARTINEZ FABRICIO
#-DIDOLICH MARTIN
#-LASORSA LAUTARO
#-QUELALI AMISTOY MARCOS EMIR

<#
.NOTES
--------------------------------------------------------------------------------------------------------------------------------
                                                FUNCION DE AYUDA DEL EJERCICIO 4
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
Realiza el monitoreo en segundo plano de los archivos de un directorio.
.DESCRIPTION
Cada vez que se detecte un cambio, ya sea creacion o modificacion de un archivo (no se monitorea borrado), 
el script realiza un backup del directorio monitoreado y crea un registro en un archivo de log con la fecha, hora, ruta del directorio monitoreado y un detalle de los resultados encontrados.
Siempre y cuando el contenido del archivo contenga el patron pasado por parametro

Aclaraciones:
-Este script analiza el directorio pasado por parametro y sus subdirectorios.
-El archivo de log se va a guardar en el mismo directorio donde se encuentra el script.
-No se pueden almacenar los backups en el mismo directorio que se esta monitoreando.
-Si el directorio a monitorear y el directorio donde se van a generar los back-up es el mismo el comportamiento del script es impredecible,
 ya que cada vez que se genera un back-up se estaría disparando un nuevo evento y así indefinidamente, por lo que esto no estara permitido.
-Si se ejecuta dos o más veces el mismo script sobre el mismo directorio de monitoreo y back-up se generará una solo archivo .zip pero en el
 archivo de monitoreo aparecerán las modificaciones o creaciones tantas veces como se haya ejecutado el script
.PARAMETER directorio
-directorio: Ruta del directorio a monitorear. Es obligatorio.
.PARAMETER salida
-salida: Ruta del directorio en donde se van a crear los backups.
.PARAMETER patron
-patron: Patron que debe contener el archivo para que se realice el backup.
.INPUTS
-Solo se va a monitoriar  el directorio indicado y sus subdirectorios.
-Las rutas pueden ser relativas o absolutas y es recomendable indicarlas entre comillas simples por si los nombres contienen espacios.
.OUTPUTS
-El resumen de los cambios efectuados en el directorio estaran disponibles en el archivo de log llamado "monitoreo.log"
.EXAMPLE
ACLARACION:
    Para llamar a la funcion de ayuda:
        >get-help ./Ejercicio4.ps1 -Full
.EXAMPLE
    Si se indica el directorio y la salida
    >./Ejercicio4.ps1 -directorio './Directorio/' -patron "patron a buscar" -salida './Backup'
.EXAMPLE
    Si se quiere finalizar el proceso demonio
    >../Ejercicio4.ps1 -directorio './Directorio/' -kill
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

if($directorio -eq $salida){
    Write-Host "Los parametros 'directorio' y 'salida' no pueden ser iguales"
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

$ruta = ".\monitoreo.log"
if (-not (Test-Path -Path $ruta)) {
    #Mando la salida a un null para que no se muestre en pantalla 
    New-Item -Path $ruta -ItemType "file" > $null
}

$proceso={
    param($directorio,$pathsalida,$ruta,$evento,$patron)

    $watcher = New-Object System.IO.FileSystemWatcher
    $watcher.Path = $directorio
    $watcher.IncludeSubdirectories = $true

    $action={
        $FullPath = $event.SourceEventArgs.FullPath
        $ChangeType = $event.SourceEventArgs.ChangeType
        $Timestamp = $event.TimeGenerated

        $formato=$Timestamp.ToString("yyyyMMdd-HHmmss")

        $contienePatron = Select-String -Path "$FullPath" -Pattern "$patron"

        if ($contienePatron) {
            try {
                Compress-Archive -Path $path -DestinationPath "$pathsalida\$formato.zip"
            } catch {
                Write-Host "Error durante la compresión: $_" >> $ruta
            }
    
            $text = "{0} was {1} at {2}" -f $FullPath, $ChangeType, $Timestamp
            $text >> $ruta
        }
    }

    $handlers = . {
        Register-ObjectEvent -InputObject $watcher -EventName Changed -Action $action 
        Register-ObjectEvent -InputObject $watcher -EventName Created -Action $action
    }

    $watcher.EnableRaisingEvents = $true

    while($true){
        wait-Event -Timeout 1
    }

}

$job = start-Job -Name "daemon$directorio" -ScriptBlock $proceso -ArgumentList $directorio, $salida, $ruta,$evento,$patron

Write-Host "Ha comenzado el monitoreo en segundo plano en los archivos del directorio $directorio, se hara log de los archivos con el patron $patron, para detenerlo debe ejecutar el script con el comando -kill"