<<<<<<< HEAD:Ejercicio 4/Ejercicio 4 PS/Ejercicio4.ps1
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
el script realiza un backup del directorio monitoreado y crea un registro en un archivo de log 
con la fecha, hora, ruta del directorio monitoreado y un detalle de los resultados encontrados.

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
    >./Ejercicio4.ps1 -directorio './Directorio/' -salida './Backup'
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

=======
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
el script realiza un backup del directorio monitoreado y crea un registro en un archivo de log 
con la fecha, hora, ruta del directorio monitoreado y un detalle de los resultados encontrados.

Aclaraciones:
-Este script analiza el directorio pasado por parametro y sus subdirectorios.
-El archivo de log se va a guardar en el mismo directorio donde se encuentra el script.
-No se pueden almacenar los backups en el mismo directorio que se esta monitoreando.
-Si el directorio a monitorear y el directorio donde se van a generar los back-up es el mismo el comportamiento del script es impredecible,
 ya que cada vez que se genera un back-up se estaría disparando un nuevo evento y así indefinidamente, por lo que esto no estara permitido.
-Si se ejecuta dos o más veces el mismo script sobre el mismo directorio de monitoreo y back-up se generará una solo archivo .zip pero en el
 archivo de monitoreo aparecerán las modificaciones o creaciones tantas veces como se haya ejecutado el script
.PARAMETER directorio
-directorio: Ruta del directorio a monitorear. Es obligatorio
.PARAMETER salida
-salida: Ruta del directorio en donde se van a crear los backups.
.PARAMETER patron
-patron: Patrón a buscar una vez detectado un cambio en los archivos monitoreados. (Puede ser create o modify)
.PARAMETER kill
-kill: Flag que se utiliza para indicar que el script debe
detener el demonio previamente iniciado.
Este parámetro solo se puede usar junto con -d/--
directorio/-directorio.
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
    >./Ejercicio4.ps1 -directorio './Directorio/' -salida './Backup'
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

if($directorio -eq $salida){
    Write-Host "Los parametros 'directorio' y 'salida' no pueden ser iguales."
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

>>>>>>> 3d747a6ed6cb4e7e83fc11e6f8a49f88cd6039b3:PowerShell/Ejercicio4 PS/Ejercicio4.ps1
Write-Host "Ha comenzado el monitoreo en segundo plano, para detenerlo debe ejecutar el script con el comando -kill"