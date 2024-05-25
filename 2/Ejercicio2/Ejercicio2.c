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
void crearHilo(DIR* dir,char* input,int* vec);
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
    if(!dir){
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
    
    struct dirent* dirent;
   
    int posicionVector = 0;

    dirent = readdir(dir);


    while(dirent != NULL){
        
        if(strcmp(dirent->d_name, ".") != 0 && strcmp(dirent->d_name, "..") != 0 && strstr(dirent->d_name,".txt") != NULL){
            FILE* arch;
            int apariciones[10] = {0};
            int i = 0;

            //Pedir mutex 

            pthread_mutex_lock(&mutexVector);

            while(i==0){
                if(*(vec + posicionVector) != 0){
                    dirent = readdir(dir);
                    posicionVector++;
                }
                else{
                    i=1;
                }
            }

            *(vec + posicionVector) = 1;
       

            for(int j = 0; j<cantArchivosTxt; j++){
                printf("%d ", *(vec + j));
            }

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

            pthread_mutex_unlock(&mutexApariciones);

            printf("Archivo leido %s. Apariciones ",dirent->d_name);

            for(int j = 0;j < 10;j++){
                aparicionesTotales[j]+=apariciones[j];
                printf("%d=%d, ",j,apariciones[j]);
            }

            pthread_mutex_unlock(&mutexApariciones);
            printf("\n");
        }
        else{
            dirent = readdir(dir);
        }
        if(posicionVector == (cantArchivosTxt - 1)){
            dirent = readdir(dir);
        }
    }

    return NULL; //Return 0 finaliza el hilo
}

void crearHilo(DIR* dir,char* input,int* vec){

    pthread_t hilo;

    struct dirent* dt;

    argsRutina args = {
        vec,
        dir,
        input
    };

    if(pthread_create(&hilo,NULL,procesarArchivos,&args) != 0){
       printf("Error al crear el hilo");
       exit(0); 
    }
    else{
        printf("Hilo creado ");
    }

    pthread_join(hilo, NULL);
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

    for(int i = 0;i < cantHilos;i++){
        rewinddir(dir);
        crearHilo(dir,input,vec);
    }

}