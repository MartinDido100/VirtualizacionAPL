#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <dirent.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/syscall.h>

typedef struct{
    int* vec;
    DIR* dir;
    char* input;
}argsRutina;

pthread_mutex_t mutexVector = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t mutexApariciones = PTHREAD_MUTEX_INITIALIZER;
int cantArchivosTxt = 0;
int aparicionesTotales[10] = {0};

int revisarParametros(int argc,char* argv[],int* cantHilos,char** input,char** output);
void procesarDirectorio(DIR* dir,char* input,int cantHilos);
void* procesarArchivos(void* args);

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
    if(dir == NULL){
        printf("Error, el directorio a leer no existe");
        return 1;
    }
    
    procesarDirectorio(dir,input,cantHilos);
    closedir(dir);

    pthread_mutex_destroy(&mutexVector);

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
    if(*cantHilos <= 0){
        printf("Error de parametros, la cantidad de hilos no puede ser menor o igual a 0 o mayor a 10");
        return 1;
    }

    if(*input == NULL){
        printf("Error, se debe especificar un directorio de entrada para analizar los archivos");
        return 1;
    }

    return 0;
}

void* procesarArchivos(void* args){
    argsRutina* datos = (argsRutina*)args;
    int* vec = datos->vec;
    DIR* dir = datos->dir;
    char* input = datos->input;

    pid_t tid = syscall(SYS_gettid);
    
    int posicionVector = 0;
    struct dirent* dirent;

    while((dirent = readdir(dir)) != NULL && posicionVector < cantArchivosTxt){
        if(strcmp(dirent->d_name, ".") != 0 && strcmp(dirent->d_name, "..") != 0){
            FILE* arch;
            int apariciones[10] = {0};
            int i = 0;

            //Pedir mutex 

            pthread_mutex_lock(&mutexVector);

            // while(i==0){
            //     if(*(vec + posicionVector) != 0){
            //         dirent = readdir(dir);
            //         if(strcmp(dirent->d_name, ".") != 0 && strcmp(dirent->d_name, "..") != 0){
            //             posicionVector++;
            //         }else{
            //             dirent = readdir(dir);
            //         }
            //     }
            //     else{
            //         i=1;
            //     }
            // }

            while (posicionVector < cantArchivosTxt && vec[posicionVector] != 0) {
                posicionVector++;
            }
            printf("%d  %d\n", posicionVector,tid);

            *(vec + posicionVector) = 1;

            //Liberar mutex

            pthread_mutex_unlock(&mutexVector);

            char fullPath[strlen(input) + strlen(dirent->d_name) + 2];
            sprintf(fullPath,"%s/%s",input,dirent->d_name);

            arch = fopen(fullPath,"rt");

            if(!arch){
                printf("Error al abrir el archivo %s\n",dirent->d_name);
                return NULL;
            }

            char caract;
            while((caract = fgetc(arch)) != EOF){

                if(caract >= '0' && caract <= '9'){
                    apariciones[caract-'0']++;
                }
            }

            fclose(arch);

            pthread_mutex_lock(&mutexApariciones);

            printf("%d leyo %s. Apariciones ",tid,dirent->d_name);

            for(int j = 0;j < 10;j++){
                aparicionesTotales[j]+=apariciones[j];
                printf("%d=%d, ",j,apariciones[j]);
            }

            printf("\n");
            pthread_mutex_unlock(&mutexApariciones);
        }
    }

    return NULL; //Return 0 finaliza el hilo
}

void procesarDirectorio(DIR* dir,char* input,int cantHilos){
    struct dirent* dirent;
    dirent = readdir(dir);

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

    pthread_t hilos[cantHilos];

    for(int i = 0;i < cantHilos;i++){
        rewinddir(dir);

        argsRutina args = {
            vec,
            dir,
            input
        };

        if(pthread_create(&hilos[i],NULL,procesarArchivos,&args) != 0){
           printf("Error al crear el hilo");
           exit(0); 
        }
    }

    for(int j = 0;j < cantHilos;j++){
        pthread_join(hilos[j],NULL);
    }

    free(vec);

}