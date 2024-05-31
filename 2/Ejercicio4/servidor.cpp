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
void inicializar(char * memoria);
void muerte_ordenada(int sig);

int main( int argc, char *argv[]){
    
    if(argc==2 and ( strcmp(argv[1],"-h")==0 or strcmp(argv[1],"--help")==0)){
        help();
        return 0;
    }

    signal(SIGINT, SIG_IGN);
    signal(SIGUSR1, muerte_ordenada);
    signal(SIGTERM, SIG_IGN);
    signal(SIGHUP, SIG_IGN);
    signal(SIGQUIT, SIG_IGN);

    auto semaforo_servidor = sem_open(
        SEMAFORO_SERVIDOR.c_str(),
        O_CREAT,
        0600,
        1
    );

    int value = 0;
    sem_getvalue(semaforo_servidor, &value);
    
    if(value==0){
        cerr << "\033[1;31mERROR : YA EXISTE UN SERVIDOR EN EJECUCION\033[0m" << endl;
        // cerr << " ERROR : YA EXISTE UN SERVIDOR EN EJECUCION" << endl;
        return 1;
    }

    sem_wait(semaforo_servidor);

    int idMemoria = shm_open(MEMORIA_COMPARTIDA.c_str(), O_CREAT | O_RDWR, 0600);
    ftruncate(idMemoria, 16);

    auto memoria = (char *)mmap(NULL,
                                16,
                                PROT_READ | PROT_WRITE,
                                MAP_SHARED,
                                idMemoria,
                                0);
    auto semaforo_cliente = sem_open(
            SEMAFORO_CLIENTE.c_str(),
            O_CREAT,
            0600,
            0
    );

    auto semaforo_juego = sem_open(
            SEMAFORO_JUEGO.c_str(),
            O_CREAT,
            0600,
            0
    );

    while(true){
        inicializar(memoria);
        sem_post(semaforo_cliente);

        cout << "\033[1;33m SE INICIO UN JUEGO NUEVO (ESPERANDO CLIENTE) \033[0m" << endl;

        sem_wait(semaforo_juego);
    }

}

void help(){
    cout<<"Servidor del juego de la memoria"<<endl;
    cout<<" IMPORTANTE: Solo puede haber un cliente por servidor y un servidor por computadora "<<endl;
    cout<<" USO: ./servidor"<<endl;
    cout<<" ./servidor -h | --help : muestra esta ayuda"<<endl;
    cout<<" El servidor seguira ejecutandose aunque cierres esta ventana y solo puede cerrarse con el comando kill"<<endl;
    cout<<" El servidor se encarga de inicializar el juego y esperar a que el cliente juegue"<<endl;
    cout<<" El servidor se cierra con la señal SIGUSR1 y solo si no hay ningún cliente activo "<<endl;
}

void inicializar(char * memoria){
    srand(time(0));
    vector<int> posiciones(16);
    for(int pos = 0; pos < 16; pos ++ ){
        posiciones[pos] = pos;
    }

    string letras;
    
    for(char c = 'A'; c <= 'Z'; c++){
        letras.push_back(c);
    }
    
    random_shuffle(letras.begin(), letras.end());
    random_shuffle(posiciones.begin(), posiciones.end());
    
    for(int letra = 0; letra<8;letra++){
        char cletra = letras[letra];
        memoria[posiciones[2*letra]] = cletra;
        memoria[posiciones[2*letra+1]] = cletra;
    }
}

void muerte_ordenada(int sig){
    
    cerr << "Signal "<<sig<<endl;
    cout << "\033[1;31m CERRANDO SERVIDOR\t\033[0m" << endl;
    
    auto semaforo_cliente = sem_open(
        SEMAFORO_CLIENTE.c_str(),
        O_CREAT,
        0600,
        0
    );

    sem_wait(semaforo_cliente);
    auto semaforo_servidor = sem_open(
        SEMAFORO_SERVIDOR.c_str(),
        O_CREAT,
        0600,
        0
    );
        
    sem_unlink(SEMAFORO_CLIENTE.c_str());
    sem_unlink(SEMAFORO_JUEGO.c_str());
    shm_unlink(MEMORIA_COMPARTIDA.c_str());
        
    sem_post(semaforo_servidor);
    exit(0);
    
}