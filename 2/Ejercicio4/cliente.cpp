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
void mostrar(char * memoria, char estado[4][4]);
void muerte_ordenada(int sig);

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
    
    auto memoria = (char *)mmap(NULL,
                                16,
                                PROT_READ | PROT_WRITE,
                                MAP_SHARED,
                                idMemoria,
                                0);
    
    auto semaforo_juego = sem_open(
            SEMAFORO_JUEGO.c_str(),
            O_CREAT,
            0600,
            0
    );

    auto time_init = time(0);

    int exitos = 0;
    int jugadas = 0;
    int last_p = -1;

    char estado[4][4] = {0};

    while(exitos < 8){
        int i,j;
        cout<<"Ingrese las coordenadas de fila y columna (1 - 4) de la celda que desea seleccionar "<<endl;
        cin>>i>>j;
        cout<<"\033[2J\033[H";
        
        i--, j--;
        if(i<0 or j<0 or i>=4 or j>=4){
            cout << "\033[1;31mCoordenadas invalidas\033[0m" << endl;
            continue;
        }

        if(estado[i][j] == 1){
            cout << "\033[1;33mCelda ya revelada\033[0m" << endl;
            continue;
        }

        int p = i*4+j;
        
        if(jugadas%2==1 and p == last_p){
            cout << "\033[1;33mYa se selecciono esta celda\033[0m" << endl;
            continue;
        }
        
        estado[i][j] = -1;
        jugadas++;

        mostrar(memoria, estado);
    
        if(jugadas%2==0){
            if(memoria[p] == memoria[last_p]){
                cout << "\033[1;32mEncontraste una pareja\033[0m" << endl;
                estado[i][j] = 1;
                estado[last_p/4][last_p%4] = 1;
                exitos++;
            }else{
                cout << "\033[1;31mNo encontraste una pareja\033[0m" << endl;
                estado[i][j] = 0;
                estado[last_p/4][last_p%4] = 0;
            }
        }

        last_p = p;
    }

    auto time_final = time(0);

    cout << "\033[1;32mJuego terminado en " << (time_final - time_init) << " segundos y " << jugadas << " jugadas \033[0m" << endl;
    // cout<<"Juego terminado en "<<time_final-time_init<<" segundos y "<<jugadas<<" jugadas "<<endl;

    sem_post(semaforo_juego);
    exit(0);
}

void help(){
    cout<<"Cliente del juego de la memoria"<<endl;
    cout<<" IMPORTANTE: Solo puede haber un cliente por servidor y un servidor por computadora "<<endl;
    cout<<" USO: ./cliente"<<endl;
    cout<<" ./cliente -h | --help : muestra esta ayuda"<<endl;
    cout<<" El cliente permite al usuario jugar y le muestra el estado del juego por salida estandar (consola)"<<endl;
}

void mostrar(char * memoria, char estado[4][4]){
    cout << "\t1\t2\t3\t4" << endl;
    for(int i = 0; i < 4; i++){
        cout << i+1 << "\t";
        for(int j = 0; j < 4; j++){
            if(estado[i][j] == 1){
                cout << "\033[1;32m" << memoria[i*4+j] << "\033[0m\t";
            }else if(estado[i][j] == -1){
                cout << "\033[1;33m" << memoria[i*4+j] << "\033[0m\t";
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
    
    auto semaforo_juego = sem_open(
        SEMAFORO_JUEGO.c_str(),
        O_CREAT,
        0600,
        0
    );

    sem_post(semaforo_juego);

    auto semaforo_cliente = sem_open(
        SEMAFORO_CLIENTE.c_str(),
        O_CREAT,
        0600,
        1
    );

    sem_post(semaforo_cliente);
    exit(0);
}