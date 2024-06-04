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

#define FIFO_PATH "/tmp/sensor_fifo"
#define SEM_NAME "/sensor_sem"
#define NomDemon "Centralizado"

volatile sig_atomic_t running = 1;

void handle_sigterm(int sig) {
    if(sig == SIGTERM) {
        running = 0;
    }
}

void daemon_process(const char *log_file_path) {

    // Pide señal para la finalización
    signal(SIGTERM, handle_sigterm);

    if (mkfifo(FIFO_PATH, 0666) == -1) {
        perror("mkfifo");
        exit(EXIT_FAILURE);
    }

    FILE *log_file = fopen(log_file_path, "a");
    if (!log_file) {
        perror("fopen");
        printf("\nruta: %s\n", log_file_path);
        unlink(FIFO_PATH);
        exit(EXIT_FAILURE);
    }

    // Abre el FIFO en modo lectura
    char buffer[128];
    int fifo_fd = open(FIFO_PATH, O_RDONLY);
    if (fifo_fd == -1) {
        perror("open");
        fclose(log_file); // Cerrar el archivo de log antes de salir (si se abre correctamente)
        unlink(FIFO_PATH);
        exit(EXIT_FAILURE);
    }

    printf("Proceso centralizado iniciado\n");

    // Lee mensajes del FIFO y escribirlos en el archivo de log
    while (running) {
        while (read(fifo_fd, buffer, sizeof(buffer)) > 0) {
            time_t now = time(NULL);
            char *timestamp = ctime(&now);
            timestamp[strlen(timestamp) - 1] = '\0'; // Quitar el salto de línea
            fprintf(log_file, "%s %s", timestamp, buffer);
            fflush(log_file);
            memset(buffer, 0, sizeof(buffer)); // Limpiar el buffer después de procesar
        }
    }
    close(fifo_fd);

    fclose(log_file);
    unlink(FIFO_PATH);
    exit(EXIT_SUCCESS);
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

int main(int argc, char *argv[]) {
    if (argc == 2 && (strcmp(argv[1], "--help") == 0 || strcmp(argv[1], "-h") == 0)) {
        // Mostrar la ayuda y salir
        show_help();
        return 0;
    }
    char *log_file = NULL;
    parse_arguments(argc, argv, &log_file);

    pid_t demonio;
    
    demonio=fork();
    if(demonio==0){
        printf("Ejecutando el proceso %s con PID %d\n",NomDemon,getpid());
        if (setsid() < 0) {
            perror("setsid");
            exit(EXIT_FAILURE);
        }

        // Obtiene la ruta absoluta (si es relativa)
        char resolved_path[PATH_MAX];
        realpath(log_file, resolved_path);
        if (chdir("/") < 0) {
            perror("chdir");
            exit(EXIT_FAILURE);
        }

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

        exit(EXIT_SUCCESS);
    }


    return 0;
}
