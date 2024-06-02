#include <bits/stdc++.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <semaphore.h>
#include "config.hpp"
using namespace std;

void help();
void mostrar(char memoria[4][4]);
void muerte_ordenada(int sig);

datos_compartidos * memoria;

int main( int argc, char *argv[]){
    
    if(argc==2 and ( strcmp(argv[1],"-h")==0 or strcmp(argv[1],"--help")==0)){
        help();
        return 0;
    }

    signal(SIGINT, SIG_IGN);
    signal(SIGUSR1, muerte_ordenada);
    signal(SIGTERM, muerte_ordenada);
    signal(SIGHUP, muerte_ordenada);
    signal(SIGQUIT, muerte_ordenada);

    auto semaforo_servidor = sem_open(
        SEMAFORO_SERVIDOR.c_str(),
        O_CREAT,
        0600,
        1
    );

    int value = 0;
    sem_getvalue(semaforo_servidor, &value);
    
    if(value==1){
        cerr << "\033[1;31mERROR : NO EXISTE UN SERVIDOR EN EJECUCION\033[0m" << endl;
        return 1;
    }

    auto semaforo_cliente = sem_open(
        SEMAFORO_CLIENTE.c_str(),
        O_CREAT,
        0600,
        1
    );

    sem_getvalue(semaforo_cliente, &value);
    if(value==0){
        cerr << "\033[1;31mERROR : YA EXISTE UN CLIENTE EN EJECUCION\033[0m" << endl;
        return 1;
    }

    sem_wait(semaforo_cliente);
    
    
    int idMemoria = shm_open(MEMORIA_COMPARTIDA.c_str(), O_CREAT | O_RDWR, 0600);
    
    memoria = (datos_compartidos *)mmap(NULL,
                            sizeof(datos_compartidos),
                            PROT_READ | PROT_WRITE,
                            MAP_SHARED,
                            idMemoria,
                            0);
    
    auto time_init = time(0);

    auto semaforo_jugada_a = sem_open(
            SEMAFORO_JUGADA_A.c_str(),
            O_CREAT,
            0600,
            0
    );

    auto semaforo_jugada_b = sem_open(
            SEMAFORO_JUGADA_B.c_str(),
            O_CREAT,
            0600,
            0
    );
    
    auto semaforo_no_cliente = sem_open(
            SEMAFORO_NO_CLIENTE.c_str(),
            O_CREAT,
            0600,
            0
    );

    while(!memoria->fin){
        mostrar(memoria->mostrar);
        int i,j;
        cout<<"Ingrese las coordenadas de fila y columna (0 - 3) de la celda que desea seleccionar "<<endl;
        cin>>i>>j;
        
        memoria->jugada[0] = char(i);
        memoria->jugada[1] = char(j);

        sem_post(semaforo_jugada_a);
        sem_wait(semaforo_jugada_b);
        cout<<"\033[2J\033[H";
        printf("\n%s\n", memoria->mensaje);
    }

    auto time_final = time(0);

    sem_post(semaforo_no_cliente);

    cout << "\033[1;32mJuego terminado en " << (time_final - time_init) << " segundos y " << memoria->num_jugadas << " jugadas \033[0m" << endl;
    // cout<<"Juego terminado en "<<time_final-time_init<<" segundos y "<<jugadas<<" jugadas "<<endl;

    exit(0);
}

void help(){
    cout<<"Cliente del juego de la memoria"<<endl;
    cout<<" IMPORTANTE: Solo puede haber un cliente por servidor y un servidor por computadora "<<endl;
    cout<<" USO: ./cliente"<<endl;
    cout<<" ./cliente -h | --help : muestra esta ayuda"<<endl;
    cout<<" El cliente permite al usuario jugar y le muestra el estado del juego por salida estandar (consola)"<<endl;
}

void mostrar(char memoria[4][4]){
    cout << "\t0\t1\t2\t3" << endl;
    for(int i = 0; i < 4; i++){
        cout << i << "\t";
        for(int j = 0; j < 4; j++){
            if(memoria[i][j] >= 'A' and memoria[i][j] <= 'Z'){
                cout << "\033[1;32m" << memoria[i][j] << "\033[0m\t";
            }else if(memoria[i][j] >= -'Z' and memoria[i][j] <= -'A'){
                cout << "\033[1;33m" << char(-memoria[i][j]) << "\033[0m\t";
            }else{
                cout<<"-\t";
            }
        }
        cout << endl;
    }
    cout << "\033[0m";
}

void muerte_ordenada(int sig){
    cerr << "Signal : "<<sig<<endl;
    cout << "\033[1;31mEl cliente se cerrara\033[0m" << endl;
    
    memoria->fin = true;

    auto semaforo_jugada_a = sem_open(
            SEMAFORO_JUGADA_A.c_str(),
            O_CREAT,
            0600,
            0
    );

    int value;
    sem_getvalue(semaforo_jugada_a, &value);
    if(value==0){
        sem_post(semaforo_jugada_a);
    }
    
    auto semaforo_no_cliente = sem_open(
            SEMAFORO_NO_CLIENTE.c_str(),
            O_CREAT,
            0600,
            0
    );

    sem_post(semaforo_no_cliente);
    exit(0);
}