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
void inicializar_compartido(datos_compartidos * memoria);
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
    ftruncate(idMemoria, sizeof(datos_compartidos));

    auto memoria = (datos_compartidos *)mmap(NULL,
                                sizeof(datos_compartidos),
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
            1
    );

    char interno[16];
    while(true){
        sem_wait(semaforo_no_cliente);
        inicializar(interno);
        inicializar_compartido(memoria);
        sem_post(semaforo_cliente);

        cout << "\033[1;33m SE INICIO UN JUEGO NUEVO (ESPERANDO CLIENTE) \033[0m" << endl;
        
        while(!memoria->fin){
            sem_wait(semaforo_jugada_a);
            int i = memoria->jugada[0], j = memoria->jugada[1];
            if(i<0 or i>3 or j<0 or j>3){
                sprintf(memoria->mensaje, "\033[1;31mJugada invalida\033[0m\n");
            }else if(memoria->num_jugadas % 2 == 1 and memoria->mostrar[i][j]>=-'Z' and memoria->mostrar[i][j]<=-'A'){
                sprintf(memoria->mensaje, "\033[1;31mJugada repetida\033[0m\n");
            }
            else if(memoria->mostrar[i][j] >= 'A' and memoria->mostrar[i][j] <= 'Z'){
                sprintf(memoria->mensaje, "\033[1;31mCasilla ya destapada\033[0m\n");
            }else{
                if(memoria->num_jugadas % 2 == 0){
                    for(int a = 0; a < 4; a++) 
                        for(int b = 0; b < 4; b++)
                            if(memoria->mostrar[a][b] <= -'A' and memoria->mostrar[a][b] >= -'Z')
                                memoria->mostrar[a][b] = '-';

                    memoria->last_jugada[0] = char(i);
                    memoria->last_jugada[1] = char(j);
                    memoria->mostrar[i][j] = -interno[i*4+j];
                    sprintf(memoria->mensaje, "\033[1;37mJugada valida\033[0m\n");
                }
                else{
                    int ii = memoria->last_jugada[0], jj = memoria->last_jugada[1];
                    if(interno[i*4+j] == interno[ii*4+jj]){
                        memoria->mostrar[i][j] = interno[i*4+j];
                        memoria->mostrar[ii][jj] = interno[ii*4+jj];
                        memoria->aciertos++;
                        if(memoria->aciertos<8) sprintf(memoria->mensaje, "\033[1;32m -- ACIERTO -- \033[0m\n");
                        else{
                            sprintf(memoria->mensaje, "\033[1;32m -- JUEGO TERMINADO -- \033[0m\n");
                            memoria->fin = true;
                        }
                    }else{
                        memoria->mostrar[i][j] = -interno[i*4+j];
                        memoria->mostrar[ii][jj] = -interno[ii*4+jj];
                        sprintf(memoria->mensaje, "\033[1;31m -- FALLO -- \033[0m\n");
                    }
                }
                memoria->num_jugadas++;
            }
            sem_post(semaforo_jugada_b);
        }
    }

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
    printf("\t\tCada vez que se genere una nueva partida, el servidor deberá rellenar de manera aleatoria el tablero con 8 pares de letras mayúsculas (A-Z). Cada letra seleccionada solo deberá aparecer dos veces en posiciones también aleatorias. \n\n");
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

    printf("\nEjemplos de llamadas:\n");
    printf("\nInicio Servidor:");
    printf("\n\t$ ./servidor\n");
    printf("\nAyuda:\n");
    printf("\n\t$ ./servidor -h\n");
    printf("\n\t$ ./servidor --help\n");

    printf("\nNota:\n");
    printf("\n\t- IMPORTANTE: Solo puede haber un cliente por servidor y un servidor por computadora.");
    printf("\n\t- El Servidor finaliza con un SIGUSR1 (pid servidor).");
    printf("\n\t- El servidor seguira ejecutandose aunque cierres esta ventana y solo puede cerrarse con el comando kill.");
    printf("\n\t- El servidor se cierra con la señal SIGUSR1 y solo si no hay ningún cliente activo.");
    printf("\n\t- El servidor se encarga de inicializar el juego y esperar a que el cliente juegue.");
    printf("\n---------------------------------------------------------------------------------------------------------\n");
    return;
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
    
    int value = 0;
    auto semaforo_cliente = sem_open(
        SEMAFORO_CLIENTE.c_str(),
        O_CREAT,
        0600,
        0
    );
    sem_getvalue(semaforo_cliente, &value);
    if(value==0){
        return;
    }
    

    cerr << "Signal "<<sig<<endl;
    cout << "\033[1;31m CERRANDO SERVIDOR\t\033[0m" << endl;
    
    
    // sem_wait(semaforo_cliente);
    sem_unlink(SEMAFORO_CLIENTE.c_str());
    sem_unlink(SEMAFORO_SERVIDOR.c_str());
    sem_unlink(SEMAFORO_JUGADA_A.c_str());
    sem_unlink(SEMAFORO_JUGADA_B.c_str());
    shm_unlink(MEMORIA_COMPARTIDA.c_str());
    exit(0);
}

void inicializar_compartido(datos_compartidos * memoria){
    memoria->aciertos = 0;
    memoria->num_jugadas = 0;
    memoria->fin = false;
    memset(memoria->mostrar, '-', sizeof(memoria->mostrar));
    memset(memoria->last_jugada, 0, sizeof(memoria->last_jugada));
    memset(memoria->jugada, 0, sizeof(memoria->jugada));
    memoria->mensaje[0] = '\0';
}