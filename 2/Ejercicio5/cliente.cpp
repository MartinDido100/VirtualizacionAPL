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
    printf("\n---------------------------------------------------------------------------------------------------------\n");
    printf("\t\t\tFuncion de ayuda del ejercicio 5:\n");
    printf("\nIntegrantes:\n\t-MATHIEU ANDRES SANTAMARIA LOIACONO, MARTIN DIDOLICH, FABRICIO MARTINEZ, LAUTARO LASORSA, MARCOS EMIR QUELALI AMISTOY\n");

    printf("\nPara preparar el entorno de desarrollo ejecutar el siguiente comando:\n");
    printf("\n\t$sudo apt install build-essential\n");
    printf("\nPara compilar los makefile ejecutar el siguiente comando:\n");
    printf("\n\t$make all\n");

    printf("\nDescripcion:");
    printf("\n\tEl siguiente programa ejecuta el juego de la memoria Memotest, pero alfabetico \n\n");
    printf("\nEl programa se implementa a travez de de conexiones de red, pudiendo admitir más de un cliente por servidor.");
    printf("\nEl cliente debe solicitar la dirección IP (o el nombre) del servidor y el puerto del mismo.");

    printf("\nParametros\n");
    printf("\n-n/--nickname: Nickname del usuario. (Requerido)\n");
    printf("\n-p/--puerto: Puerto del servidor. (Requerido)\n");
    printf("\n-s/--servidor: Dirección IP o nombre del servidor (Requerido)\n");

    printf("\nEjemplos de llamadas:\n");
    printf("\n\t$./cliente -n Pepe -p 8080 -s <IP>\n");
    printf("\n\t$./cliente --nickname Pepe --puerto 8080 --servidor <IP>\n");

    printf("\n---------------------------------------------------------------------------------------------------------\n");

    printf("\nAclaraciones\n");
    printf("\n\tEl juego de la memoria Memotest consiste en encontrar las parejas de letras en el menor tiempo posible.");
    printf("\n\tEl juego finaliza cuando se encuentran todas las parejas.");
    printf("\n1. Si el servidor se cae (deja de funcionar) o es detenido, los clientes deben seran notificados y se cerrara de forma controlada.\n");
    printf("\n2. Si alguno de los clientes se cae o es detenido, el servidor indentifica el problema ,cierra la conexión de forma controlada y sigue funcionando hasta que solo quede un cliente\n");
    printf("\n3. Los clientes pueden ver el estado actualizado del tablero cuando ocurran aciertos y solo se permitirá una jugada por turno de cada cliente\n");
    printf("\nSe llevara un marcador indicando cuantos aciertos realizó cada jugador y al final mostrara el ganador.\n");

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