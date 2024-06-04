#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <dirent.h>
#include <unistd.h>
#include <sys/types.h>
#include <errno.h>
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
void mostrarAyuda();

int main(int argc,char* argv[]){

    int cantHilos = 0;
    char* input = NULL;
    char* output = NULL;
    FILE* outFile = NULL;

    if(revisarParametros(argc,argv,&cantHilos,&input,&output) != 0){
        return 1;
    }

    DIR* dir = opendir(input);
    if (dir == NULL) {
        printf("Error no existe el directorio de entrada\n");
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

void mostrarAyuda(){
    printf("\n---------------------------------------------------------------------------------------------------------\n");
    printf("\t\t\tFuncion de ayuda del ejercicio 2:\n");
    printf("\nIntegrantes:\n\t-MATHIEU ANDRES SANTAMARIA LOIACONO, MARTIN DIDOLICH, FABRICIO MARTINEZ, LAUTARO LASORSA, MARCOS EMIR AMISTOY QUELALI\n");

    printf("\nPara preparar el entorno de desarrollo ejecutar el siguiente comando:\n");
    printf("\n\t$sudo apt install build-essential\n");
    printf("\nPara compilar los makefile ejecutar el siguiente comando:\n");
    printf("\n\t$make (Ejercicio2)\n");
    printf("\nPara borrar los archivos generados por el makefile ejecutar el siguiente comando:\n");
    printf("\n\t$make clean\n");

    printf("\nParametros\n");
    printf("\n-t/--threads <nro>: Cantidad de threads a ejecutar concurrentemente para procesar los archivos del directorio (Requerido). El número ingresado debe ser un entero positivo.\n");
    printf("\n-i/--input <directorio>: Ruta del directorio a analizar. (Requerido)\n");
    printf("\n-o/--output <archivo>: Ruta del archivo con los resultados del procesamiento. (Opcional)");
    printf("\n-h/--help: Muestra la ayuda del programa\n");

    printf("\nDescripcion\n");
    printf("\nEl programa es capaz de contar la cantidad de números del 0 al 9 que aparece en todos los archivos de texto (con extensión .txt) que se encuentra en el directorio pasado por parametros.");
    printf("\nCada hilo lee un archivo y contabilizar la cantidad de número que leyó. Adicionalmente al final se menciona la cantidad de números leídos totales.\n");
    printf("\nPor ejemplo: la palabra: “Hola C-3PO, soy R2-D2”, sumaría una aparición al número “3” y dos apariciones al número “2”.\n");
    printf("\nOpcionalmente, si se recibe el parámetro -o / --output se generará un archivo con los resultados de los archivosprocesados.\n");

    printf("\nEjemplo de salida por pantalla\n");
    printf("\nThread 1: Archivo leído test.txt. Apariciones 0=${cantCeros}, 1=${cantUnos}, etc\n");
    printf("\nThread 2: Archivo leído prueba.txt. Apariciones 0=${cantCeros}, 1=${cantUnos}, etc\n");
    printf("\nThread 1: Archivo leído pepe.txt. Apariciones 0=${cantCeros}, 1=${cantUnos}, etc\n");
    printf("\nFinalizado lectura: Apariciones total: 0=${cantTotalCeros}, 1=${cantTotalUnos}, etc\n");

    printf("\nEjemplos de llamadas:\n");
    printf("\n$./Ejercicio2 -t 3 -i ./archivos");
    printf("\n$./Ejercicio2 --threads 2 --input home/user/Ejercicio2/archivos");
    printf("\n$./Ejercicio2 -t 3 -i ./archivos -o ./salida.txt"); //Chequear que output sea solo txt
    printf("\n$./Ejercicio2 -h\n");

    printf("\nAclaraciones:\n");
    printf("\nLas rutas de los archivos pueden ser tanto relativas como absolutas y deben ser validas\n");
    printf("\nSe leeran solo archivos .txt que esten en el directorio de entrada\n");
    printf("\nLa extension del archivo de salida debe ser obligatoriamente .txt\n");
    printf("\nEl numero de hilos debe ser un entero positivo\n");
}

int revisarParametros(int argc,char* argv[],int* cantHilos,char** input,char** output){
    int i;
    for(int i = 1; i < argc; i++){
        if(strcmp(argv[i],"-h") == 0 || strcmp(argv[i],"--help") == 0){
            mostrarAyuda();
            return 1;
        }

        if(strcmp(argv[i],"-t") == 0 || strcmp(argv[i],"--threads") == 0){
            *cantHilos = strtol(argv[i+1],NULL,10);
        }

        if(strcmp(argv[i],"-i") == 0 || strcmp(argv[i],"--input") == 0){
            *input = argv[i+1];
        }

        if(strcmp(argv[i],"-o") == 0 || strcmp(argv[i],"--output") == 0){
            if(strstr(argv[i+1],".txt") == NULL){
                printf("Error, el archivo de salida debe tener extension .txt");
                return 1;
            }
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