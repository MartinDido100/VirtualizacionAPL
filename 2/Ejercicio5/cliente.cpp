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

int main( int argc, char *argv[]){
    
    if(argc==2 and ( strcmp(argv[1],"-h")==0 or strcmp(argv[1],"--help")==0)){
        help();
        return 0;
    }

    int puerto;
    

    signal(SIGINT, SIG_IGN);
    signal(SIGUSR1, muerte_ordenada);
    signal(SIGTERM, muerte_ordenada);
    signal(SIGHUP, muerte_ordenada);
    signal(SIGQUIT, muerte_ordenada);

   
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