#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <dirent.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/syscall.h>

typedef struct{
    DIR* dir;
    char* input;
    FILE* outFile;
    int nroHilo;
}argsRutina;

pthread_mutex_t mutexDirent = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t mutexApariciones = PTHREAD_MUTEX_INITIALIZER;
int cantArchivosTxt = 0;
int aparicionesTotales[10] = {0};

int revisarParametros(int argc,char* argv[],int* cantHilos,char** input,char** output);
void procesarDirectorio(DIR* dir,char* input,int cantHilos,FILE* outFile);
void* procesarArchivos(void* args);

int main(int argc,char* argv[]){

    int cantHilos = 0;
    char* input = NULL;
    char* output = NULL;
    FILE* outFile = NULL;

    if(revisarParametros(argc,argv,&cantHilos,&input,&output) != 0){
        return 1;
    }

    input = realpath(input,NULL);
    
    DIR* dir = opendir(input);
    if(dir == NULL){
        printf("Error, el directorio a leer no existe");
        return 1;
    }

    if(output != NULL){
        outFile = fopen(output,"wt");
        if(!outFile){
            printf("Error al abrir el archivo de salida\n");
            return 1;
        }
    }
    
    procesarDirectorio(dir,input,cantHilos,outFile);
    closedir(dir);

    printf("Finalizado lectura: Apariciones total: ");

    if(outFile != NULL){
        fprintf(outFile,"Finalizado lectura: Apariciones total: ");
    }

    for(int j = 0;j < 10;j++){
        printf("%d=%d, ",j,aparicionesTotales[j]);
        if(outFile != NULL){
            fprintf(outFile,"%d=%d, ",j,aparicionesTotales[j]);
        }
    }
    printf("\n");

    pthread_mutex_destroy(&mutexApariciones);    
    pthread_mutex_destroy(&mutexDirent);

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

    DIR* dir = datos->dir;
    char* input = datos->input;
    FILE* outFile = datos->outFile;
    int nroHilo = datos->nroHilo;

    struct dirent* dirent;

    pthread_mutex_lock(&mutexDirent); // lo voy a usar para controlar el readdir
    dirent= readdir(dir);        //leer
    pthread_mutex_unlock(&mutexDirent);// lo voy usar para controlar el readdir

    while(dirent  != NULL){
        if(strcmp(dirent->d_name, ".") != 0 && strcmp(dirent->d_name, "..") != 0 && strstr(dirent->d_name,".txt") != NULL){
            FILE* arch;
            int apariciones[10] = {0};
            int i = 0;

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

            printf("El hilo %d leyo %s. Apariciones ",nroHilo,dirent->d_name);

            if(outFile != NULL){
                fprintf(outFile,"El hilo %d leyo %s. Apariciones ",nroHilo,dirent->d_name);
            }

            for(int j = 0;j < 10;j++){
                aparicionesTotales[j]+=apariciones[j];
                printf("%d=%d, ",j,apariciones[j]);

                if(outFile != NULL){
                    fprintf(outFile,"%d=%d, ",j,apariciones[j]);
                }

            }

            if(outFile != NULL){
                fputs("\n",outFile);
            }

            printf("\n");
            pthread_mutex_unlock(&mutexApariciones);
        }
        pthread_mutex_lock(&mutexDirent); // lo voy a usar para controlar el readdir
        dirent= readdir(datos->dir); //leer
        pthread_mutex_unlock(&mutexDirent);// lo voy usar para controlar el readdir
    }
    free(args);
    return NULL; //Return 0 finaliza el hilo
}

void procesarDirectorio(DIR* dir,char* input,int cantHilos,FILE* outFile){
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

    rewinddir(dir);

    pthread_t hilos[cantHilos];
    
    if(cantHilos > cantArchivosTxt){
        cantHilos = cantArchivosTxt;
    }

    for(int i = 0;i < cantHilos;i++){
        argsRutina* args = (argsRutina*)malloc(sizeof(argsRutina));
        //Reservo memoria aca, ya que si uso memoria estatica no se muestran correctament el nro de hilo ya que por cada bucle se sobreescribia el valor
        args->dir = dir;
        args->input = input;
        args->outFile = outFile;
        args->nroHilo = i+1;

        if(pthread_create(&hilos[i],NULL,procesarArchivos,args) != 0){
           printf("Error al crear el hilo");
           exit(0); 
        }
    }

    for(int j = 0;j < cantHilos;j++){
        pthread_join(hilos[j],NULL);
    }

}