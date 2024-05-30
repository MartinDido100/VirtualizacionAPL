// Esto es la memoria compartida
#ifndef SHARED_H
#define SHARED_H

#define TAM_TABLERO 16
#define FIL 4
#define COL 4
#define SHM_KEY 0x1234
#define SEM_KEY 0x5678

typedef struct {
    char tablero[FIL][COL]; //no deberia poder acceder el cliente
    char tabRevelado[FIL][COL]={0}; 
    int aciertos = 0;
    int jugando;
} SharedData;

// Funciones de memoria compartida
int setup_shared_memory(SharedData **shared_data);
void cleanup_shared_memory(int shm_id, SharedData *shared_data);

// Funciones de semáforos
int setup_semaphores();
void sem_wait(int sem_id, int sem_num);
void sem_signal(int sem_id, int sem_num);
void cleanup_semaphores(int sem_id);

#endif // SHARED_H