#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <time.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <semaphore.h>
#include <getopt.h>
#include <limits.h>

#define FIFO_PATH "/tmp/sensor_fifo"
#define SEM_NAME "/sensor_sem"

void sensor_process(int sensor_number, int num_messages, int interval
                    // , sem_t *sem
                    ) {
    srand(time(NULL) + sensor_number); // Semilla para el generador de números aleatorios
    for (int i = 0; i < num_messages; i++) {
        if(i!=0)
            sleep(interval);

        int measurement = rand() % 101; // Genera una medición aleatoria entre 0 y 100
        int fifo_fd = open(FIFO_PATH, O_WRONLY);
        if (fifo_fd == -1) {
            perror("open");
            exit(EXIT_FAILURE);
        }

        // sem_wait(sem); // Adquiere el semáforo antes de escribir en el FIFO
        dprintf(fifo_fd, "%d %d\n", sensor_number, measurement);
        // sem_post(sem); // Indica que hay un nuevo mensaje listo para ser leído por el demonio
        close(fifo_fd);


    }
    exit(EXIT_FAILURE);
}

void parse_arguments(int argc, char* argv[], int* sensor_number, int* interval, int* num_messages) {
    struct option long_options[] = {
        {"numero", required_argument, 0, 'n'},
        {"segundos", required_argument, 0, 's'},
        {"mensajes", required_argument, 0, 'm'},
        {"help", no_argument, 0, 'h'},
        {0, 0, 0, 0}
    };

    int opt;
    while ((opt = getopt_long(argc, argv, "n:s:m:", long_options, NULL)) != -1) {
        switch (opt) {
            case 'n':
                *sensor_number = atoi(optarg);
                break;
            case 's':
                *interval = atoi(optarg);
                break;
            case 'm':
                *num_messages = atoi(optarg);
                break;
            default:
                fprintf(stderr, "Uso: %s --numero <numero_sensor> --segundos <intervalo> --mensajes <num_mensajes>\n", argv[0]);
                exit(EXIT_FAILURE);
        }
    }

    if (*sensor_number == -1 || *interval == -1 || *num_messages == -1) {
        fprintf(stderr, "Debe especificar todos los argumentos requeridos.\n");
        exit(EXIT_FAILURE);
    }
}

// Función para mostrar la ayuda
void show_help() {
    printf("\n---------------------------------------------------------------------------------------------------------\n");
    printf("\t\t\tFuncion de ayuda del sensor del ejercicio 3:\n");
    printf("\nIntegrantes:\n\t-MATHIEU ANDRES SANTAMARIA LOIACONO, MARTIN DIDOLICH, FABRICIO MARTINEZ, LAUTARO LASORSA, MARCOS EMIR QUELALI AMISTOY\n");

    printf("\nPara preparar el entorno de desarrollo ejecutar el siguiente comando:\n");
    printf("\n\t$sudo apt install build-essential\n");
    printf("\nPara compilar los makefile ejecutar el siguiente comando:\n");
    printf("\n\t$make all\n");
    printf("\nPara borrar los archivos generados por el makefile ejecutar el siguiente comando:\n");
    printf("\n\t$make clean\n");

    printf("\nParametros\n");
    printf("\n-n/--numero: Número del sensor (Requerido)\n");
    printf("\n-s/--segundos: Intervalo en segundos para el envío del mensaje (Requerido)\n");
    printf("\n-m / --mensajes: Cantidad de mensajes a enviar (Requerido)\n");

    printf("\nDescripción:\n");
    printf("\nLos procesos sensores toman por parámetro el número que les corresponde, y para hacer la simulación generan cada una cierta cantidad de segundos una medición que generan en forma aleatoria, informando el mensaje vía el FIFO con su número de sensor y la medición a registrar\n");
    printf("\nEl proceso de un sensor finaliza luego de enviar la cantidad de mensajes especificada\n");

    printf("\nEjemplos de llamadas:\n");
    printf("\n\t$./sensor --numero 1 --segundos 5 --mensajes 10\n");
    printf("\n\t$./sensor -n 2 -s 3 -m 5\n");

    printf("\nAclaraciones:\n");
    printf("\nLos valores enviados deben ser enteros positivos\n");
    printf("\nPuede haber varios sensores ejecutando al mismo tiempo");

}

int main(int argc, char *argv[]) {
    if (argc == 2 && (strcmp(argv[1], "--help") == 0 || strcmp(argv[1], "-h") == 0)) {
        // Mostrar la ayuda y salir
        show_help();
        return 0;
    }
    int sensor_number = -1;
    int interval = -1;
    int num_messages = -1;

    parse_arguments(argc, argv, &sensor_number, &interval, &num_messages);

    // sem_t *sem = sem_open(SEM_NAME, O_RDWR);
    // if (sem == SEM_FAILED) {
    //     perror("sem_open");
    //     exit(EXIT_FAILURE);
    // }

    sensor_process(sensor_number, num_messages, interval
                    // , sem
                    );

    // sem_close(sem);
    return 0;
}
