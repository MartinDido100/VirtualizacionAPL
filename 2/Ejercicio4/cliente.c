#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include "shared.h"

int shm_id;
SharedData *shared_data;
int sem_id;

void start_client() {
    shm_id = setup_shared_memory(&shared_data);
    sem_id = setup_semaphores();
    signal(SIGINT, SIG_IGN); // Ignorar SIGINT

    while (1) {
        sem_wait(sem_id, 0); // Espera a que el servidor esté listo

        // Mostrar el tablero
        printf("Board:\n");
        for (int i = 0; i < ROWS; i++) {
            for (int j = 0; j < COLS; j++) {
                int idx = i * COLS + j;
                if (shared_data->revealed[idx]) {
                    printf(" %c ", shared_data->board[idx]);
                } else {
                    printf(" * ");
                }
            }
            printf("\n");
        }

        // Obtener la entrada del usuario
        int x1, y1, x2, y2;
        printf("Ingrese las coordenadas de la primera carta (fila columna): ");
        scanf("%d %d", &x1, &y1);
        printf("Ingrese las coordenadas de la segunda carta (fila columna): ");
        scanf("%d %d", &x2, &y2);

        int index1 = x1 * COLS + y1;
        int index2 = x2 * COLS + y2;
        shared_data->revealed[index1] = 1;
        shared_data->revealed[index2] = 1;

        sem_signal(sem_id, 1); // Señala al servidor con la entrada

        // Verificar si el juego ha terminado
        if (shared_data->game_in_progress == 0) {
            printf("¡Felicidades! Has encontrado todos los pares.\n");
            break;
        }
    }

    shmdt(shared_data);
}

int main() {
    start_client();
    return 0;
}
