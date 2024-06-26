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
int getNextInt();

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
        //cin>>i>>j;
        
        i = getNextInt();
        j = getNextInt();

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
    printf("\n---------------------------------------------------------------------------------------------------------\n");
    printf("\t\t\tFuncion de ayuda del ejercicio 4:\n");
    printf("\nIntegrantes:\n\t-MATHIEU ANDRES SANTAMARIA LOIACONO, MARTIN DIDOLICH, FABRICIO MARTINEZ, LAUTARO LASORSA, MARCOS EMIR QUELALI AMISTOY\n");

    printf("\nPara preparar el entorno de desarrollo ejecutar el siguiente comando:\n");
    printf("\n\t$sudo apt install build-essential\n");
    printf("\nPara compilar los makefile ejecutar el siguiente comando:\n");
    printf("\n\t$make all\n");

    printf("\nDescripcion:");
    printf("\n\tEl siguiente programa ejecuta el juego de la memoria \"Memotest\", pero alfabetico \n\n");
    printf("\n\tExistira un proceso “Cliente”, cuya tarea será mostrar por pantalla el estado actual del tablero y leer \n");
    printf("\t\tdesde teclado el par de casillas que el usuario quiere destapar\n\n");
    printf("\n\tExistira un proceso “Servidor”, que será el encargado de actualizar el estado del tablero en base al  \n");
    printf("\t\tpar de casillas ingresado, así como controlar la finalización partida. \n\n");		

    printf("\t\tEl tablero tendrá 16 casillas (4 filas x 4 columnas). \n\n");		
    printf("\t\tSe debe garantizar que no se pueda ejecutar más de un cliente a la vez conectado al mismo servidor. \n\n");
    printf("\t\tSe deberá garantizar que solo pueda haber un servidor por computadora. \n\n");
    printf("\t\tEl tablero tendrá 16 casillas (4 filas x 4 columnas). \n\n");
    printf("\t\tCada vez que se genere una nueva partida, el servidor deberá rellenar de manera aleatoria el tablero  con 8 pares de letras mayúsculas (A-Z). Cada letra seleccionada solo deberá aparecer dos veces en posiciones también aleatorias. \n\n");
    printf("\t\tEl servidor se ejecutará y quedará a la espera de que un cliente se ejecute. \n\n");
    printf("\t\tTanto el cliente como el servidor deberán ignorar la señal SIGINT (Ctrl-C). \n\n");
    printf("\t\tEl servidor deberá finalizar al recibir una señal SIGUSR1, siempre y cuando no haya ninguna partida en progreso. \n\n");

    printf("\nInterfaz:");
    printf("\n  0 1 2 3 \n");
    printf("\n0 - - - -\n");
    printf("\n1 - - - -\n");
    printf("\n2 - - - -\n");
    printf("\n3 - - - -\n");
    printf("\nIngrese las coordenadas de fila y columna (0-3) de la celda que desea seleccionar");
    printf("\n(Cualquier caracter que ingrese que no sea un número entre 0 y 3 será ignorado)");
    printf("\nSe puede ingresar cualquier cosa que se leeran los primeros numeros entre 0 y 3");
    printf("\nPor ejemplo si se ingresa: aaa 0odgsaod92 se leeran las coordenadas 0 2");
    
    printf("\nEjemplos de llamadas:\n");
    printf("\nInicio Cliente:");
    printf("\n\t$ ./cliente\n");
    printf("\nAyuda:\n");
    printf("\n\t$ ./cliente -h\n");
    printf("\n\t$ ./cliente --help\n");

    printf("\nNota:\n");
    printf("\n\t- IMPORTANTE: Solo puede haber un cliente por servidor y un servidor por computadora.");
    printf("\n\t- El cliente permite al usuario jugar y le muestra el estado del juego por salida estandar (consola).");
    printf("\n---------------------------------------------------------------------------------------------------------\n");
    return;
}

void mostrar(char tablero[4][4]){
    cout << "\t0\t1\t2\t3" << endl;
    for(int i = 0; i < 4; i++){
        cout << i << "\t";
        for(int j = 0; j < 4; j++){
            if(tablero[i][j] >= 'A' and tablero[i][j] <= 'Z'){
                cout << "\033[1;32m" << tablero[i][j] << "\033[0m\t";
            }else if(tablero[i][j] >= -'Z' and tablero[i][j] <= -'A'){
                cout << "\033[1;33m" << char(-tablero[i][j]) << "\033[0m\t";
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

int getNextInt(){
    char c;
    while(true){
        c = getchar();
        if(c >= '0' and c <= '3'){
            return c - '0';
        }
    }
}