#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <dirent.h>

pthread_mutex_t mutexVector = PTHREAD_MUTEX_INITIALIZER;

int revisarParametros(int argc,char* argv[],int* cantHilos,char** input,char** output);
void procesarDirectorio(DIR* dir,int cantHilos);
int crearHilo(DIR* dir,int** vec);
void procesarArchivos(int** vec);

int main(int argc,char* argv[]){
    int cantHilos = 0;
    char* input = NULL;
    char* output = NULL;

    if(revisarParametros(argc,argv,&cantHilos,&input,&output) != 0){
        return 1;
    }

    input = realpath(input,NULL);

    if(output != NULL){
        output = realpath(output,NULL);
    }
    
    DIR* dir = opendir(input);
    if(!dir){
        printf("Error, el directorio a leer no existe");
        return 1;
    }

    procesarDirectorio(dir,cantHilos);
    closedir(dir);

    return 0;   
}

int revisarParametros(int argc,char* argv[],int* cantHilos,char** input,char** output){
    int i;

    for(int i = 1; i < argc; i++){
        if(strcmp(argv[i],"-h") == 0 || strcmp(argv[i],"--help") == 0){
            printf("Ayudita");
            return 1;
        }

        if(strcmp(argv[i],"-t") == 0 || strcmp(argv[i],"--threads") == 0){
            *cantHilos = strtol(argv[i+1],NULL,10);
        }

        if(strcmp(argv[i],"-i") == 0 || strcmp(argv[i],"--input") == 0){
            *input = argv[i+1];
        }

        if(strcmp(argv[i],"-o") == 0 || strcmp(argv[i],"--output") == 0){
            *output = argv[i+1];
        }

    }

    //Reviso errores
    if(*cantHilos <= 0 || *cantHilos > 10){
        printf("Error de parametros, la cantidad de hilos no puede ser menor o igual a 0 o mayor a 10");
        return 1;
    }

    if(*input == NULL){
        printf("Error, se debe especificar un directorio de entrada para analizar los archivos");
        return 1;
    }

    return 0;
}

int crearHilo(DIR* dir, int** vec){

    pthread_t hilo;

    if(pthread_create(&hilo,NULL,procesarArchivos,vec)){
        
    }

}

void procesarDirectorio(DIR* dir,int cantHilos){
    struct dirent* dirent;
    dirent = readdir(dir);
    int cantArchivosTxt = 0;

    while(dirent != NULL){
        if(strcmp(dirent->d_name, ".") != 0 && strcmp(dirent->d_name, "..") != 0){
            if(strstr(dirent->d_name,".txt") != NULL){
                cantArchivosTxt++;
            }
        }
        
        dirent = readdir(dir);
    }

    //Creo el vector con la cantidad de txts y los dejo en 0 para saber que ninguno esta leido
    int* vec = malloc(cantArchivosTxt*sizeof(int));

    for(int i;i < cantHilos;i++){
        crearHilo(dir,&vec);
        borrarHilo();
    }

}