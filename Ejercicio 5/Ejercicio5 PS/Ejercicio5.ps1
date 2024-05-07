#Ejercicio 5, Realizado en PowerShell.

#Integrantes:
#-SANTAMARIA LOAICONO MATHIEU ANDRES
#-MARTINEZ FABRICIO
#-DIDOLICH MARTIN
#-LASORSA LAUTARO
#-QUELALI AMISTOY MARCOS EMIR

<#
.NOTES
--------------------------------------------------------------------------------------------------------------------------------
                                                FUNCION DE AYUDA DEL EJERCICIO 5
--------------------------------------------------------------------------------------------------------------------------------

Informacion General:

(+) Universidad: Universidad Nacional de la Matanza.
(+) Carrera: Ingenieria en Informatica.
(+) Materia: Virtualizacion de Hardware.
(+) Comision: Jueves-Noche.
(+) Cuatrimestre: 1C2024.
(+) APL: Numero 1.
(+) Integrantes: -SANTAMARIA LOAICONO MATHIEU ANDRES, -MARTINEZ FABRICIO, -DIDOLICH MARTIN, -LASORSA LAUTARO, -QUELALI AMISTOY MARCOS EMIR.
(+) Grupo: Numero C1.
(+) Resuelto en: PowerShell.
.SYNOPSIS
Permite buscar informacion de los personajes de Rick y Morty por su id o su nombre a traves de la api https://rickandmortyapi.com/documentation/#character
.DESCRIPTION
Buscar informacion de los personajes cuyo ID o Nombre fue pasado por parametro e informa por cada personaje:
-Id:
-Name:
-Status:
-Species:
-Gender:
-Origin:
-Location:

Aclaraciones:
-Este script buscara primero los personajes en archivos locales. Si no los encuentra, los busca en la API.
-Es IMPORTANTE que envie AL MENOS un parametro, ya sea el ID o el Nombre o ambos. Si no, el programa finalizara.
.PARAMETER Id
-Id: Id del personaje a buscar informacion. Opcional.
.PARAMETER Nombre
-Nombre: Nombre del personaje a buscar informacion. Opcional.
.INPUTS
Solo se busca informacion de los personajes que se ingresaron su Id o Nombre.
.OUTPUTS
-El resumen final de la informacion del personaje se hara por pantalla y se generara un archivo con dicha informacion para evitar consultar la API
nuevamente en caso de solicitar informacion repetida.
-El formato del archivo sera [Id] o [Nombre] y se guardara en el directorio donde se encuentra el script.
.EXAMPLE
ACLARACION:
    Para llamar a la funcion de ayuda:
        >get-help ./Ejercicio5.ps1 -Full
.EXAMPLE
Si se indica el nombre del personaje nada mas
    >./Ejercicio5.ps1 -nombre personaje
        
    Resultado esperado: 
        Informacion del personaje:
        Id: 1
        Name: Rick Sanchez  
        Status: Alive
        Species: Human
        Gender: Male
        Origin: Earth(C-137)
        Location: Citadel of Ricks
.EXAMPLE
Si se indica el nombre de varios personajes
    >./Ejercicio5.ps1 -nombre "Rick Sanchez", "Morty Smith" 
        
    Resultado esperado: 
        Informacion del personaje:
        Id: 1
        Name: Rick Sanchez  
        Status: Alive
        Species: Human
        Gender: Male
        Origin: Earth(C-137)
        Location: Citadel of Ricks
        ---------------------------
        Informacion del personaje:
        Id: 2
        Name: Morty Smith 
        Status: Alive
        Species: Human
        Gender: Male
        Origin: unknown
        Location: Citadel of Ricks
        ---------------------------
.EXAMPLE
Si se indica el Id del personaje nada mas
    >./Ejercicio5.ps1 -id 1
        
    Resultado esperado: 
        Informacion del personaje:
        Id: 1
        Name: Rick Sanchez  
        Status: Alive
        Species: Human
        Gender: Male
        Origin: Earth(C-137)
        Location: Citadel of Ricks
.EXAMPLE
Si se indica el Id de varios personajes
    >./Ejercicio5.ps1 -id 1,2
        
    Resultado esperado: 
        Informacion del personaje:
        Id: 1
        Name: Rick Sanchez  
        Status: Alive
        Species: Human
        Gender: Male
        Origin: Earth(C-137)
        Location: Citadel of Ricks
        ---------------------------
        Informacion del personaje:
        Id: 2
        Name: Morty Smith 
        Status: Alive
        Species: Human
        Gender: Male
        Origin: unknown
        Location: Citadel of Ricks
        ---------------------------
.EXAMPLE
Si se indica el Id o nombre de los personajes.
    >./Ejercicio5.ps1 -id 3 -nombre rick, morty
        
    Resultado esperado:
        Informacion del personaje:
        Id: 3
        Name: Summer Smith
        Status: Alive
        Species: Human
        Gender: Female
        Origin: Earth (Replacement Dimension)
        Location: Earth (Replacement Dimension)
        ---------------------------
        Informacion del personaje:
        Id: 1
        Name: Rick Sanchez
        Status: Alive
        Species: Human
        Gender: Male
        Origin: Earth (C-137)
        Location: Citadel of Ricks
        ---------------------------
        Informacion del personaje:
        Id: 2
        Name: Morty Smith
        Status: Alive
        Species: Human
        Gender: Male
        Origin: unknown
        Location: Citadel of Ricks
        ---------------------------
.EXAMPLE
Si se repite el id o el nombre del personaje, se mostraran los datos duplicados
    >./Ejercicio5.ps1 -nombre morty morty

    Resultado esperado:
    Informacion del personaje:
        Id: 2
        Name: Morty Smith
        Status: Alive
        Species: Human
        Gender: Male
        Origin: unknown
        Location: Citadel of Ricks
        ---------------------------
        Informacion del personaje:
        Id: 2
        Name: Morty Smith
        Status: Alive
        Species: Human
        Gender: Male
        Origin: unknown
        Location: Citadel of Ricks
        ---------------------------
#>

param (
    [Parameter(Mandatory=$false)]
    [Array]
    [ValidateScript({
        if (-not ($_ -match "^[0-9]+$")) {
            throw "El valor ingresado no corresponde a un ID válido: $_"
        }
        $true
    })]
    [Int[]]
    $ids=@(),

    [Parameter(Mandatory=$false)]
    [Array]
    [ValidateScript({
        if (-not ($_ -match "^[a-zA-Z]+$")) {
                throw "El valor ingresado no corresponde a un Nombre válido: $_"
            }
        $true
    })]
    [String[]]
    $nombres=@()
)



$validezId = !($ids.Length -eq 0)
$validezNombre = !($nombres.Length -eq 0)

if($validezId){
    Write-Host "ID/s ingresado/s: $ids"
}

if($validezNombre){
    Write-Host "Nombre/s ingresado/s: $nombres"
}

if(!$validezId -and !$validezNombre){
    Write-Output "ERROR: Ningun parametro detectado."
    Write-Output "Para mostrar la informacion de un personaje, es necesario que se indique cual desea ver por medio de parametros."
    Write-Output "Recuerde que puede indicar el ID, el Nombre, o incluso ambos."
    Write-Output "Para mas informacion, puede consultar la ayuda con Get-Help ./Ejercicio5.ps1`n"
    exit
}

for ($i = 0; $i -lt $nombres.Length; $i++) {
    $nombres[$i] = $nombres[$i].ToLower()
}

if(($validezId)){

    foreach ($idsElemento in $ids) {

        $archivo = Join-Path $PWD "$idsElemento.txt"

        if (Test-Path $archivo -PathType Leaf) {
            $existeArchivo = (Get-ChildItem -Path $archivo | Where-Object { $_.Name -like "$idsElemento.txt"}).Count -gt 0
        } else {
            $existeArchivo = $false
        }
        #me fijo si el archivo existe, en caso de existir, la variable es verdadera

        if ($existeArchivo) {
            Write-Host "`nEl archivo $archivo existe."
            Write-Host "Mostrando archivo...`n"
            Get-Content $archivo
            Write-Output "---------------------------"

        } else {
            Write-Host "`nEl archivo $archivo no existe."
            Write-Host "Creando archivo y extrayendo informacion...`n"
            $url= "https://rickandmortyapi.com/api/character/$idsElemento"
            try{
                $resultado=Invoke-WebRequest $url
                $objeto=$resultado.content | ConvertFrom-Json

                $ruta = "$PWD\$idsElemento.txt"
                New-Item -Path "./ruta/del/archivo.txt" -ItemType "file" -ErrorAction SilentlyContinue
                #esto hace que no se muestre info del archivo creado

                "Informacion del personaje:" >> $ruta
                "Id: $($objeto.id)" >> $ruta
                "Name: $($objeto.name)" >> $ruta
                "Status: $($objeto.status)" >> $ruta
                "Species: $($objeto.species)" >> $ruta
                "Gender: $($objeto.gender)" >> $ruta
                "Origin: $($objeto.origin.name)" >> $ruta
                "Location: $($objeto.location.name)" >> $ruta

            Get-Content -Path $ruta
            Write-Output "---------------------------"
    
            }   
            catch{
                Write-Host "El Id:"$idsElemento" es invalido, no corresponde a un personaje de la serie"
            }
        }
            
    }
}

else{
    Write-Host "No se ingresaron Ids"
}

if(($validezNombre)){

    foreach ($nombresElemento in $nombres) {

        $archivo = Join-Path $PWD "$nombresElemento.txt"

        if (Test-Path $archivo -PathType Leaf) {
            $existeArchivo = (Get-ChildItem -Path $archivo | Where-Object { $_.Name -like "$nombresElemento.txt"}).Count -gt 0
        } else {
            $existeArchivo = $false
        }
        #me fijo si el archivo existe, en caso de existir, la variable es verdadera

        if ($existeArchivo) {
            Write-Host "`nEl archivo $archivo existe."
            Write-Host "Mostrando archivo...`n"
            Get-Content $archivo
            Write-Output "---------------------------"

        } else {
            Write-Host $nombresElemento
            Write-Host "`nEl archivo $archivo no existe."
            Write-Host "Creando archivo y extrayendo informacion...`n"
            $url= "https://rickandmortyapi.com/api/character/?name=$nombresElemento"
            try{
                $resultado=Invoke-WebRequest $url
                $objeto=$resultado.content | ConvertFrom-Json
                $ruta = "$PWD\$nombresElemento.txt"
                New-Item -Path "./ruta/del/archivo.txt" -ItemType "file" -ErrorAction SilentlyContinue
                #esto hace que no se muestre info del archivo creado

                "Informacion del personaje:" >> $ruta
                "Id: $($objeto.results[0].id)" >> $ruta
                "Name: $($objeto.results[0].name)" >> $ruta
                "Status: $($objeto.results[0].status)" >> $ruta
                "Species: $($objeto.results[0].species)" >> $ruta
                "Gender: $($objeto.results[0].gender)" >> $ruta
                "Origin: $($objeto.results[0].origin.name)" >> $ruta
                "Location: $($objeto.results[0].location.name)" >> $ruta

            Get-Content -Path $ruta
            Write-Output "---------------------------"
    
            }   
            catch{
                Write-Host "El Id:"$nombresElemento" es invalido, no corresponde a un personaje de la serie"
            }
        }
            
    }
}

else{
    Write-Host "No se ingresaron Ids"
}