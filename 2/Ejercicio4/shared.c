// shared.c
#include <stdio.h>
#include <stdlib.h>
#include <sys/shm.h>
#include <sys/sem.h>
#include <sys/ipc.h>
#include <unistd.h>
#include "shared.h"

int setup_shared_memory(SharedData **shared_data) {
    int shm_id = shmget(SHM_KEY, sizeof(SharedData), IPC_CREAT | 0666);//Creo segmento memoria compartida
    if (shm_id < 0) {
        perror("shmget");
        exit(1);
    }
    *shared_data = (SharedData *)shmat(shm_id, NULL, 0);//Asocio el segmento de mem compartida con el espacio de dir del proceso
    if (*shared_data == (SharedData *)-1) { //compara con -1 ya que es lo que devuelve en caso de error
        perror("shmat");
        exit(1);
    }
    return shm_id; //retorna el id del segmento de area compartida
}

void cleanup_shared_memory(int shm_id, SharedData *shared_data) {//Desasocio el segmento de mem compartida y lo limpio
    shmdt(shared_data);
    shmctl(shm_id, IPC_RMID, NULL);
}

int setup_semaphores() {
    int sem_id = semget(SEM_KEY, 2, IPC_CREAT | 0666);
    if (sem_id < 0) {
        perror("semget");
        exit(1);
    }
    return sem_id;
}

void sem_wait(int sem_id, int sem_num) {
    struct sembuf sb = {sem_num, -1, 0};
    if (semop(sem_id, &sb, 1) == -1) {
        perror("semop wait");
        exit(1);
    }
}

void sem_signal(int sem_id, int sem_num) {
    struct sembuf sb = {sem_num, 1, 0};
    if (semop(sem_id, &sb, 1) == -1) {
        perror("semop signal");
        exit(1);
    }
}

void cleanup_semaphores(int sem_id) {
    semctl(sem_id, 0, IPC_RMID, 0);
}
