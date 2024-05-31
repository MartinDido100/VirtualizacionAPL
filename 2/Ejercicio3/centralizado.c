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

#define FIFO_PATH "/tmp/sensor_fifo"
#define SEM_NAME "/sensor_sem"

volatile sig_atomic_t running = 1;

void handle_sigterm(int sig) {
    if(sig == SIGTERM) {
        running = 0;
    }
}

void daemon_process(const char *log_file_path
                    // , sem_t *sem
                    ) {

    // Pide señal para la finalización
    signal(SIGTERM, handle_sigterm);

    if (mkfifo(FIFO_PATH, 0666) == -1) {
        perror("mkfifo");
        exit(EXIT_FAILURE);
    }



    FILE *log_file = fopen(log_file_path, "a");
    if (!log_file) {
        perror("fopen");
        exit(EXIT_FAILURE);
    }

    char buffer[128];
    int fifo_fd = open(FIFO_PATH, O_RDONLY);
    if (fifo_fd == -1) {
        perror("open");
        exit(EXIT_FAILURE);
    }
    while (running) {
        // sem_wait(sem); // Adquiere el semáforo antes de leer del FIFO
        while (read(fifo_fd, buffer, sizeof(buffer)) > 0) {
            time_t now = time(NULL);
            char *timestamp = ctime(&now);
            timestamp[strlen(timestamp) - 1] = '\0'; // Quitar el salto de línea
            fprintf(log_file, "%s %s", timestamp, buffer);
            fflush(log_file);
            memset(buffer, 0, sizeof(buffer)); // Limpiar el buffer después de procesar
        }
        // sem_post(sem); // Libera el semáforo después de leer del FIFO
    }
    close(fifo_fd);

    fclose(log_file);
    unlink(FIFO_PATH);
    // sem_close(sem);
    // sem_unlink(SEM_NAME);
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
void show_help(const char* program_name) {
    printf("Uso: %s --log <archivo_log>\n", program_name);
    printf("\nDescripción:\n");
    printf("Este programa abre un FIFO para leer las entradas que le envían los distintos sensores y registra en un archivo de log la fecha, hora, número de sensor y medición.\n");
}

int main(int argc, char *argv[]) {
    if (argc == 2 && (strcmp(argv[1], "--help") == 0 || strcmp(argv[1], "-h") == 0)) {
        // Mostrar la ayuda y salir
        show_help(argv[0]);
        return 0;
    }
    char *log_file = NULL;
    parse_arguments(argc, argv, &log_file);



    // Obtén la ruta absoluta (si es relativa)
    char resolved_path[PATH_MAX];
    realpath(log_file, resolved_path);
    // sem_t *sem = sem_open(SEM_NAME, O_CREAT, 0666, 1);
    // if (sem == SEM_FAILED) {
    //     perror("sem_open");
    //     exit(EXIT_FAILURE);
    // }

    daemon_process(resolved_path
                    //, sem
                    );

    return 0;
}
