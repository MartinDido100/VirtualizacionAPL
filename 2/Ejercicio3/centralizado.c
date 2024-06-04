#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <time.h>
#include <signal.h>
#include <sys/stat.h>
#include <semaphore.h>
#include <sys/wait.h>
#include <string.h>
#include <getopt.h>
#include <limits.h>
#include <sys/prctl.h>

// Definiciones de constantes
// Ruta del FIFO y nombre del semáforo
#define FIFO_PATH "/tmp/sensor_fifo"
#define SEM_NAME "/sensor_sem"
// Nombre del proceso
#define NomDemon "Centralizado"
#define ES_DEMONIO 0

// Flag para indicar la finalización del proceso
volatile sig_atomic_t running = 1;

// Funciones utilizadas
void parse_arguments(int argc, char* argv[], char** log_file);
void handle_sigterm(int sig);
void daemon_process(const char *log_file_path);
void show_help();

int main(int argc, char *argv[]) {
    // Si se pasa el argumento --help o -h, mostrar la ayuda
    if (argc == 2 && (strcmp(argv[1], "--help") == 0 || strcmp(argv[1], "-h") == 0)) {
        // Mostrar la ayuda y salir
        show_help();
        return 0;
    }

    // Parsea los argumentos
    char *log_file = NULL;
    parse_arguments(argc, argv, &log_file);

    // Crear el proceso demonio
    pid_t demonio;
    demonio=fork();

    // Verifica si el proceso es el proceso demonio
    if(demonio==ES_DEMONIO){
        printf("Ejecutando el proceso %s con PID %d\n",NomDemon,getpid());

        // Crea una nueva sesión, el proceso hijo se convierte en el líder de la sesión y del grupo
        if (setsid() < 0) {
            perror("setsid");
            exit(EXIT_FAILURE);
        }

        // Obtiene la ruta absoluta del archivo .log (si es relativa)
        char resolved_path[PATH_MAX];
        realpath(log_file, resolved_path);
        if (chdir("/") < 0) {
            perror("chdir");
            exit(EXIT_FAILURE);
        }

        // Ejecuta el proceso demonio
        daemon_process(resolved_path);
        
        // Se cierran descriptores de archivo estándar
        close(STDIN_FILENO);
        close(STDOUT_FILENO);
        close(STDERR_FILENO);

        // Cambia el nombre del proceso
        if (prctl(PR_SET_NAME, NomDemon, NULL, NULL, NULL) < 0) {
            perror("prctl");
            exit(EXIT_FAILURE);
        }

        // Una vez que finaliza, cierra exitosamente el proceso
        exit(EXIT_SUCCESS);
    }


    return 0;
}

void handle_sigterm(int sig) {
    // Setea la variable running en 0 para finalizar el proceso
    if(sig == SIGTERM) {
        running = 0;
    }
}

void parse_arguments(int argc, char* argv[], char** log_file) {
    struct option long_options[] = {
        {"log", required_argument, 0, 'l'},
        {0, 0, 0, 0}
    };

    int opt;
    while ((opt = getopt_long(argc, argv, "l:", long_options, NULL)) != -1) {
        switch (opt) {
            case 'l':
                *log_file = optarg;
                break;
            default:
                fprintf(stderr, "Uso: %s --log <archivo_log>\n", argv[0]);
                exit(EXIT_FAILURE);
        }
    }

    if (*log_file == NULL) {
        fprintf(stderr, "Debe especificar un archivo de log con --log\n");
        exit(EXIT_FAILURE);
    }
}

void daemon_process(const char *log_file_path) {

    // Pide señal para la finalización
    signal(SIGTERM, handle_sigterm);

    // Crea el FIFO si no existe
    if (mkfifo(FIFO_PATH, 0666) == -1) {
        perror("mkfifo");
        exit(EXIT_FAILURE);
    }

    // Abre el archivo de log en modo append
    FILE *log_file = fopen(log_file_path, "a");
    if (!log_file) {
        perror("fopen");
        printf("\nruta: %s\n", log_file_path);
        unlink(FIFO_PATH);
        exit(EXIT_FAILURE);
    }

    // Abre el FIFO en modo lectura y filtro no bloqueante
    char buffer[128];
    int fifo_fd = open(FIFO_PATH, O_RDONLY | O_NONBLOCK);

    // Verifica si se pudo abrir el FIFO
    if (fifo_fd == -1) {
        perror("open");
        fclose(log_file); // Cerrar el archivo de log antes de salir (si se abre correctamente)
        unlink(FIFO_PATH);
        exit(EXIT_FAILURE);
    }

    // Bucle principal hasta que la señal SIGTERM sea recibida y handle_sigterm cambie el valor de running
    while (running) {
        // Lee mensajes del FIFO y escribirlos en el archivo de log
        while (read(fifo_fd, buffer, sizeof(buffer)) > 0) {

            // Obtiene la fecha y hora actual
            time_t now = time(NULL);
            char *timestamp = ctime(&now);
            timestamp[strlen(timestamp) - 1] = '\0'; // Quitar el salto de línea

            // Escribe el mensaje en el archivo de log
            fprintf(log_file, "%s %s", timestamp, buffer);
            fflush(log_file);
            // Limpiar el buffer después de procesar el mensaje
            memset(buffer, 0, sizeof(buffer));
        }
    }

    // Cierra el FIFO y el archivo de log
    close(fifo_fd);
    fclose(log_file);
    unlink(FIFO_PATH);

    // Sale con éxito
    exit(EXIT_SUCCESS);
}

// Función para mostrar la ayuda
void show_help() {
    printf("\n---------------------------------------------------------------------------------------------------------\n");
    printf("\t\t\tFuncion de ayuda del proceso centralizado del ejercicio 3:\n");
    printf("\nIntegrantes:\n\t-MATHIEU ANDRES SANTAMARIA LOIACONO, MARTIN DIDOLICH, FABRICIO MARTINEZ, LAUTARO LASORSA, MARCOS EMIR QUELALI AMISTOY\n");

    printf("\nPara preparar el entorno de desarrollo ejecutar el siguiente comando:\n");
    printf("\n\t$sudo apt install build-essential\n");
    printf("\nPara compilar los makefile ejecutar el siguiente comando:\n");
    printf("\n\t$make all\n");
    printf("\nPara borrar los archivos generados por el makefile ejecutar el siguiente comando:\n");
    printf("\n\t$make clean\n");

    printf("\nParametros\n");
    printf("\n-l/--log: Archivo de log donde se irán escribiendo los mensajes. En caso de no existir es necesario crearlo. (Requerido)\n");

    printf("\nDescripción:\n");
    printf("\nEste programa abre un FIFO para leer los mensajes que le envían los distintos sensores y registra en un archivo de log la fecha, hora, número de sensor y medición.\n");
    printf("\nEl programa queda ejecutando como proceso demonio, finaliza con una señal SIGTERM\n");

    printf("\nEjemplos de llamadas:\n");
    printf("\n\t$./centralizado --log /tmp/sensor.log\n");
    printf("\n\t$./centralizado -l ./salida.log\n");

    printf("\nAclaraciones:\n");
    printf("\nLas rutas de los archivos pueden ser tanto relativas como absolutas y deben ser validas\n");
}