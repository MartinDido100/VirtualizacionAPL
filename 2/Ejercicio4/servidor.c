#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <signal.h>
#include "shared.h"

int shm_id;
SharedData *shared_data;
int sem_id;

void initialize_board() {
    char letters[TAM_TABLERO / 2];
    for (int i = 0; i < TAM_TABLERO / 2; i++) {
        letters[i] = 'A' + i;
    }
    for (int i = 0; i < 2; i++) {
        for (int j = 0; j < TAM_TABLERO / 2; j++) {
            int pos;
            do {
                pos = rand() % TAM_TABLERO;
            } while (shared_data->board[pos] != 0);
            shared_data->board[pos] = letters[j];
        }
    }
    memset(shared_data->revealed, 0, sizeof(shared_data->revealed));
    shared_data->pairs_found = 0;
    shared_data->game_in_progress = 1;
}

void server_signal_handler(int sig) {
    if (sig == SIGUSR1 && shared_data->game_in_progress == 0) {
        cleanup_shared_memory(shm_id, shared_data);
        cleanup_semaphores(sem_id);
        exit(0);
    }
}

void start_server() {
    signal(SIGUSR1, server_signal_handler);
    srand(time(NULL));

    shm_id = setup_shared_memory(&shared_data);
    sem_id = setup_semaphores();

    initialize_board();
    sem_signal(sem_id, 0); // Indica que el servidor está listo

    while (1) {
        sem_wait(sem_id, 1); // Espera la entrada del cliente

        // Procesar la entrada del cliente
        int index1 = -1, index2 = -1;
        for (int i = 0; i < TAM_TABLERO; i++) {
            if (shared_data->revealed[i]) {
                if (index1 == -1) index1 = i;
                else index2 = i;
            }
        }

        if (index1 != -1 && index2 != -1) {
            if (shared_data->board[index1] == shared_data->board[index2]) {
                shared_data->pairs_found++;
                if (shared_data->pairs_found == TAM_TABLERO / 2) {
                    shared_data->game_in_progress = 0; // Juego terminado
                }
            } else {
                shared_data->revealed[index1] = 0;
                shared_data->revealed[index2] = 0;
            }
        }

        sem_signal(sem_id, 0); // Señala al cliente que puede continuar
    }
}

int main(int argc, char *argv[]) {

    if (argc == 2 && (strcmp(argv[1], "--help") == 0 || strcmp(argv[1], "-h") == 0)) {
        // Mostrar la ayuda y salir
        show_help(argv[0]);
        return 0;
    }
    
    start_server();

    return 0;
}
