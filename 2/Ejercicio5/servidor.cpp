#include <bits/stdc++.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include "config.hpp"
using namespace std;



void help();
void inicializar(char * memoria);
void muerte_ordenada(int sig);

struct elemento{
    pair<sockaddr, jugador> datos_jugador;
    int socket;
    bool vivo;
};

int main( int argc, char *argv[]){
    
    if(argc==2 and ( strcmp(argv[1],"-h")==0 or strcmp(argv[1],"--help")==0)){
        help();
        return 0;
    }

    int num_puerto = -1;
    int num_jugadores = -1;

    for(int i = 1;i<argc-1;i+=2){
        if(strcmp(argv[i],"-p")==0 or strcmp(argv[i],"--puerto")==0){
            try{
                num_puerto = atoi(argv[i+1]);
                if(num_puerto<0){
                    throw invalid_argument("Numero de puerto invalido");
                }
            }catch(exception e){
                cerr << "\033[1;31mERROR : Argumento -p/--puerto invalido\033[0m" << endl;
                cout<<e.what()<<endl;
            }
        }else if(strcmp(argv[i],"-j")==0 or strcmp(argv[i],"--jugadores")==0){
            try{
                num_jugadores = atoi(argv[i+1]);
                if(num_jugadores<=0){
                    throw invalid_argument("Numero de jugadores invalido");
                }
            }catch(exception e){
                cerr << "\033[1;31mERROR : Argumento -j/--jugadores invalido\033[0m" << endl;
                cout<<e.what()<<endl;
            }
        }else{
            cerr << "\033[1;31mERROR : Argumento "<<argv[i]<<" no existe \033[0m" << endl;
        }
    }

    if(num_puerto <= -1){
        cerr << "\033[1;31mERROR : Falta el argumento -p/--puerto\033[0m" << endl;
    }

    if(num_jugadores <= 0){
        cerr << "\033[1;31mERROR : Falta el argumento -j/--jugadores\033[0m" << endl;
    }

    if(num_puerto <= -1 or num_jugadores <= -1){
        cerr << "\033[1;31mERROR : Faltan argumentos\033[0m" << endl;
        return 1;
    }

    signal(SIGINT, SIG_IGN);
    // signal(SIGUSR1, muerte_ordenada);
    signal(SIGTERM, SIG_IGN);
    signal(SIGHUP, SIG_IGN);
    signal(SIGQUIT, SIG_IGN);



    char interno[16];
    bool hay_juego = false;

    sockaddr_in server_config;
    memset(&server_config, '0', sizeof(server_config));
    server_config.sin_family = AF_INET;
    server_config.sin_addr.s_addr = htonl(INADDR_ANY);
    server_config.sin_port = htons(num_puerto);

    int socketEscucha = socket(AF_INET, SOCK_STREAM, 0);
    bind(socketEscucha, (sockaddr *)&server_config, sizeof(server_config));
    while(true){
        cout << "\033[1;33m ESPERANDO JUGADORES \033[0m" << endl;
        listen(socketEscucha, num_jugadores);
        vector<elemento> jugadores;
        while(jugadores.size() < num_jugadores){
            int socketComunicacion = accept(socketEscucha, (sockaddr * )NULL, NULL);
            pair<sockaddr, jugador> p;
            int val_leidos = read(socketComunicacion, &p, sizeof(p));
            if(val_leidos == sizeof(p)){
                jugadores.push_back({p, socketComunicacion, true});
                cout<<"Ya hay "<<jugadores.size()<<" / "<<num_jugadores<<" jugadores "<<endl;
            }
        }

        cout<<" INICIA LA SALA "<<endl;
        int aciertos_totales = 0;
        int jugadores_vivos = num_jugadores;
        char oculto[16];
        char mostrar[16];
        inicializar(oculto);
        int jugador_i = -1;
        while(aciertos_totales<8 and jugadores_vivos>1){
            for(int i = 0; i < num_jugadores; i++){
                if(jugadores[i].vivo){
                    char estado = char(-1?i!=jugador_i:1);
                    write(jugadores[i].socket,&estado,1);
                    write(jugadores[i].socket, mostrar, 16);
                }
            }

            int jugada[4];
            read(jugadores[jugador_i].socket,jugada,sizeof(jugada));
            
            
            jugador_i = (jugador_i+1)%num_jugadores;
            while(!jugadores[jugador_i].vivo){
                jugador_i = (jugador_i+1)%num_jugadores; 
            }
        }
    }
}

void help(){
    cout<<"Servidor del juego de la memoria"<<endl;
    cout<<" USO: ./servidor"<<endl;
    cout<<" ./servidor -h | --help : muestra esta ayuda"<<endl;
    cout<<" Parametros obligatorios:"<<endl;
    cout<<" \t -p | --puerto : puerto de conexion. Debe ser no negativo."<<endl;
    cout<<" \t -j | --jugadores : numero de jugadores en la sala. Debe ser positivo."<<endl;
    cout<<" El servidor se comunica con los clientes mediante sockets."<<endl;
    cout<<" Una vez iniciado el juego no puden sumarse nuevos jugadores."<<endl;
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
