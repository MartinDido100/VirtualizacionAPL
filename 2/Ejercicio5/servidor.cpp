#include <iostream>
#include <vector>
#include <cstring>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <algorithm>
#include <netinet/tcp.h>
#include <semaphore.h>
#include <fcntl.h>
#include <signal.h>

struct Jugador {
    int socket;
    std::string nombre;
    int puntaje;
    bool vivo;
};

// Inicializa el tablero oculto del juego con pares de letras
void inicializar_tableros(char tablero[4][4], char tablero_mostrar[4][4]);

//Envía el tablero que se muestra y status a los jugadores
int actualizar_y_enviar_tablero(std::vector<Jugador>& jugadores, char tablero[4][4], const std::string& mensaje_turno);

void parse_arguments(int argc, char* argv[], int* puerto, int* max_jugadores);

void crear_conexion(int* servidor_socket, int max_jugadores, int puerto);

std::vector<Jugador> iniciar_conexion_clientes(int max_jugadores, int servidor_socket);

void mostrar_ayuda();

std::function<void(int)> _muerte_ordenada;

void muerte_ordenada(int sig){
    _muerte_ordenada(sig);
}

int main(int argc, char *argv[]) {
    // const std::string SEMAFORO_CLIENTE = "semaforo_clientes";
    int puerto = 27018;
    int max_jugadores = 2;
    std::vector<Jugador> jugadores;
    int servidor_socket;
    char tablero[4][4];
    char tablero_mostrar[4][4];
    int aciertos=0;

    // Inicializar el tablero de juego
    inicializar_tableros(tablero, tablero_mostrar);

    parse_arguments(argc, argv, &puerto, &max_jugadores);

    crear_conexion(&servidor_socket, max_jugadores, puerto);

    _muerte_ordenada = [&](int sig){
        std::cout << "Signal "<<sig<<std::endl;
        std::cout << "Servidor: Cerrando el servidor..." << std::endl;
        close(servidor_socket);
        exit(0);
    };

    signal(SIGINT, SIG_IGN);
    signal(SIGUSR1, muerte_ordenada);
    signal(SIGTERM, muerte_ordenada);
    signal(SIGHUP, muerte_ordenada);
    signal(SIGQUIT, muerte_ordenada);
    signal(SIGPIPE, SIG_IGN);


    std::cout << "Esperando a que se conecten todos los jugadores..." << std::endl;

    jugadores=iniciar_conexion_clientes(max_jugadores, servidor_socket);

    std::cout << "Inicia la partida!" << std::endl;

    // Lógica del juego
    int turno = 0;
    bool partida_activa = true;
    char jugada[2];
    int fila_anterior, col_anterior;
    int vivos = max_jugadores;

    while (partida_activa) {
        std::string mensaje_turno = "Servidor: \nTurno del jugador: " + jugadores[turno].nombre + " con puntaje: " + std::to_string(jugadores[turno].puntaje) + "\n\0";
        if(jugadores[turno].vivo) for (int jugadas = 0; jugadas < 2; ++jugadas) {
            std::cout<<std::endl;
            if(jugadores[turno].vivo == false){
                tablero_mostrar[fila_anterior][col_anterior] = '-';
                break;
            }
            // Verificar si la conexión con el jugador actual está activa
            int error = 0;
            socklen_t len = sizeof(error);
            getsockopt(jugadores[turno].socket, SOL_SOCKET, SO_ERROR, &error, &len);
            if (error != 0) {
                std::cout << "Servidor: Error en la conexión con el jugador: " << jugadores[turno].nombre << std::endl;
                tablero_mostrar[fila_anterior][col_anterior] = '-';
                jugadores[turno].vivo = false;
                vivos--;
                if(vivos<=1){
                    partida_activa = false;
                    for(auto & jugador : jugadores)
                        if(jugador.vivo)
                            jugador.puntaje += (8 - aciertos);
                }
                break;
            }
            
            std::cout << "Servidor: Esperando jugadada del jugador: " << jugadores[turno].nombre << "\n" << std::endl;

            // Enviar mensaje indicando que es el turno del jugador actual
            int mueren = actualizar_y_enviar_tablero(jugadores, tablero_mostrar, mensaje_turno);
            if(mueren>0){
                vivos -= mueren;
                if(vivos<=1){
                    partida_activa = false;
                    for(auto & jugador : jugadores)
                        if(jugador.vivo)
                            jugador.puntaje += (8 - aciertos);
                    break;
                }
                if(jugadores[turno].vivo == false){
                    tablero_mostrar[fila_anterior][col_anterior] = '-';
                    break;
                }
            }
            const char* mensaje_tu_turno = "Servidor: Es tu turno";
            // sem_wait(semaforo_buffer_disp);
            send(jugadores[turno].socket, mensaje_tu_turno, strlen(mensaje_tu_turno)+1, 0);
            // sem_post(semaforo_buffer_disp);

            int bytes_received = recv(jugadores[turno].socket, jugada, sizeof(jugada), 0);
            if (bytes_received <= 0) {
                std::cout << "Servidor: Jugador desconectado: " << jugadores[turno].nombre << std::endl;
                tablero_mostrar[fila_anterior][col_anterior] = '-';
                jugadores[turno].vivo = false;                
                vivos--;
                std::cout<<"Quedan "<<vivos<<" jugadores"<<std::endl;
                if(vivos<=1){
                    partida_activa = false;
                    for(auto & jugador : jugadores)
                        if(jugador.vivo)
                            jugador.puntaje += (8 - aciertos);
                }
                break;
            }
            
            int fila = jugada[0];
            int col = jugada[1];

            if (fila < 0 || fila > 3 || col < 0 || col > 3) {
                const char* mensaje_invalido = "\033[1;31mServidor: Jugada invalida\033[0m\n\0";
                // sem_wait(semaforo_buffer_disp);
                send(jugadores[turno].socket, mensaje_invalido, strlen(mensaje_invalido)+1, 0);
                // sem_post(semaforo_buffer_disp);
                jugadas--;
                continue;
            } else if (tablero_mostrar[fila][col] != '-') {
                const char* mensaje_repetido = "\033[1;31mServidor: Jugada repetida\033[0m\n\0";
                // sem_wait(semaforo_buffer_disp);
                send(jugadores[turno].socket, mensaje_repetido, strlen(mensaje_repetido)+1, 0);
                // sem_post(semaforo_buffer_disp);
                jugadas--;
                continue;
            } else {

                std::cout << "Se jugó la coordenada: " << fila << "-" << col << std::endl;
                std::cout << "Se jugó la letra: " << tablero[fila][col] << std::endl;
                tablero_mostrar[fila][col] = - tablero[fila][col];
                if(jugadas == 0) {
                    fila_anterior = jugada[0];
                    col_anterior = jugada[1];
                }

                if (jugadas == 1) {
                    mueren = actualizar_y_enviar_tablero(jugadores, tablero_mostrar, "");
                    
                    if(mueren>0){
                        vivos -= mueren;
                        if(vivos<=1){
                            partida_activa = false;
                            for(auto & jugador : jugadores)
                                if(jugador.vivo)
                                    jugador.puntaje += (8 - aciertos);
                            break;
                        }
                    }
                    
                    if (tablero[fila][col] == tablero[fila_anterior][col_anterior]) {
                        tablero_mostrar[fila][col] = tablero[fila][col];
                        tablero_mostrar[fila_anterior][col_anterior] = tablero[fila_anterior][col_anterior];
                        const char* mensaje_acierto = "\033[1;32mServidor:  -- ACIERTO -- \033[0m\n\0";
                        jugadores[turno].puntaje+=1;
                        aciertos+=1;
                        // sem_wait(semaforo_buffer_disp);
                        send(jugadores[turno].socket, mensaje_acierto, strlen(mensaje_acierto)+1, 0);

                        if(aciertos>=8) {
                            partida_activa = false;
                        }
                        // sem_post(semaforo_buffer_disp);
                    } else {
                        tablero_mostrar[fila][col] = '-';
                        tablero_mostrar[fila_anterior][col_anterior] = '-';
                        const char* mensaje_fallo = "\033[1;31mServidor:  -- FALLO -- \033[0m\n\0";
                        // sem_wait(semaforo_buffer_disp);
                        send(jugadores[turno].socket, mensaje_fallo, strlen(mensaje_fallo)+1, 0);
                        // sem_post(semaforo_buffer_disp);
                    }
                    fila_anterior = -1;
                    col_anterior = -1;
                    
                }
            }
        }
        // Cambiar de turno
        turno = (turno + 1) % int(jugadores.size());
    }

    actualizar_y_enviar_tablero(jugadores, tablero_mostrar, "Servidor: --- FIN DEL JUEGO ---\0");
    
    std::sort(jugadores.begin(), jugadores.end(), [](const Jugador& a, const Jugador& b) {
        return a.puntaje > b.puntaje;
    });
    
    std::string mensaje_fin = "\n --- FIN DEL JUEGO --- \n";
    mensaje_fin += "Jugador"+ std::string(40 - 7,' ') +"Puntaje\n";
    for (const auto& jugador : jugadores) {
        if(jugador.vivo == false) continue;
    //    std::string msg = "Servidor: Tu puntaje: " + jugador.puntaje;
        auto msg = mensaje_fin;
        for(const auto & jjugador : jugadores){
            if(jjugador.nombre == jugador.nombre){
                msg += "\033[1m" + jugador.nombre + std::string(std::max(0,40-int(jugador.nombre.size())),' ') + std::to_string(jugador.puntaje) + "\n\033[0m";
            }else{
                msg += jjugador.nombre + std::string(std::max(0,40-int(jugador.nombre.size())), ' ') + std::to_string(jjugador.puntaje) + "\n";
            
            }
        }
        msg += '\0';
        send(jugador.socket, msg.c_str(), msg.size(), 0);
    }
    // Cerrar los sockets
    for (const auto& jugador : jugadores) {
        close(jugador.socket);
    }

    // sem_unlink(SEMAFORO_CLIENTE.c_str());
    close(servidor_socket);
    std::cerr<<" socket liberado "<<std::endl;
    return 0;
}


// Inicializa el tablero de juego con pares de letras
void inicializar_tableros(char tablero[4][4], char tablero_mostrar[4][4]) {
    memset(tablero_mostrar, '-', 16);
    std::vector<char> letras = {'A', 'A', 'B', 'B', 'C', 'C', 'D', 'D', 'E', 'E', 'F', 'F', 'G', 'G', 'H', 'H'};
    std::srand(time(0));
    std::random_shuffle(letras.begin(), letras.end());
    int idx = 0;
    for (int i = 0; i < 4; ++i) {
        for (int j = 0; j < 4; ++j) {
            tablero[i][j] = letras[idx++];
        }
    }
}

int actualizar_y_enviar_tablero(std::vector<Jugador>& jugadores, char tablero[4][4], const std::string& mensaje_turno) {
    int mueren = 0;
    for (auto& jugador : jugadores) {
        if(jugador.vivo == false) continue;
        char msg[17];
        for(int a = 0; a < 4; a++) 
            for(int b = 0; b < 4; b++)
                msg[a*4+b] = tablero[a][b];
        msg[16] = '\0';
        int datosEnviados=send(jugador.socket, msg, sizeof(msg), 0);
        if(datosEnviados==-1){
            std::cout << "\033[1;31mError al enviar el tablero al jugador: " << jugador.nombre << "\033[0m" << std::endl;
            jugador.vivo = false;
            mueren++;
        //    exit(1);
        }
        else if(strlen(mensaje_turno.c_str()))
        {
            datosEnviados=send(jugador.socket, mensaje_turno.c_str(), strlen(mensaje_turno.c_str())+1, 0);

            if(datosEnviados==-1){
                std::cout << "\033[1;31mError al enviar el tablero al jugador: " << jugador.nombre << "\033[0m" << std::endl;
                mueren++;
                jugador.vivo = false;
            //    exit(1);
            }
        }
    }
    return mueren;
}

void parse_arguments(int argc, char* argv[], int* puerto, int* max_jugadores) {
    // Parseo de argumentos

    *puerto = -1;
    *max_jugadores = -1;
    for (int i = 1; i < argc; ++i) {
        if (strcmp(argv[i], "--puerto") == 0 or strcmp(argv[i], "-p") == 0) {
            *puerto = atoi(argv[++i]);
        } else if (strcmp(argv[i], "--jugadores") == 0 or strcmp(argv[i], "-j") == 0) {
            *max_jugadores = atoi(argv[++i]);
        } else if(strcmp(argv[i], "--help") == 0 or strcmp(argv[i], "-h") == 0) {
            mostrar_ayuda();
            exit(0);
        } else {
            std::cerr << "Argumento no reconocido: " << argv[i] << std::endl;
            exit(1);
        }
    }

    if (*puerto == -1 or *max_jugadores == -1) {
        if(*puerto == -1)
            std::cerr << "\033[1;31mFalta el puerto\033[0m" << std::endl;
        if(*max_jugadores == -1)
            std::cerr << "\033[1;31mFalta la cantidad de jugadores\033[0m" << std::endl;
        std::cerr << "\033[1;31mUso: " << argv[0] << " --puerto <puerto> --jugadores <cantidad>\033[0m" << std::endl;
        std::cerr << "\033[1;31mUso: " << argv[0] << " -h or --help para ver la ayuda\033[0m" << std::endl;
        exit(1);
    }
}

void crear_conexion(int* servidor_socket, int max_jugadores, int puerto) {
    struct sockaddr_in servidor_addr;

    // Crear socket
    *servidor_socket = socket(AF_INET, SOCK_STREAM, 0);
    if (*servidor_socket < 0) {
        perror("Error al crear el socket");
        exit(1);
    }

    // Configurar TCP_NODELAY
    int flag = 1;
    if (setsockopt(*servidor_socket, SOL_SOCKET, SO_REUSEADDR, &flag, sizeof(int)) < 0) {
        perror("setsockopt");
        exit(1);
    }

    // Configurar la dirección del servidor
    memset(&servidor_addr, 0, sizeof(servidor_addr));
    servidor_addr.sin_family = AF_INET;
    servidor_addr.sin_addr.s_addr = INADDR_ANY;
    servidor_addr.sin_port = htons(puerto);

    // Enlazar el socket
    if (bind(*servidor_socket, (struct sockaddr*)&servidor_addr, sizeof(servidor_addr)) < 0) {
        perror("Error al enlazar el socket");
        exit(1);
    }

    // Escuchar
    if (listen(*servidor_socket, max_jugadores) < 0) {
        perror("Error al escuchar en el socket");
        exit(1);
    }
}

std::vector<Jugador> iniciar_conexion_clientes(int max_jugadores, int servidor_socket) {
    std::vector<Jugador> jugadores;
    int cliente_socket;
    struct sockaddr_in cliente_addr;
    socklen_t cliente_len = sizeof(cliente_addr);
    // Aceptar conexiones de jugadores
    while ((int) jugadores.size() < max_jugadores) {
        cliente_socket = accept(servidor_socket, (struct sockaddr*)&cliente_addr, &cliente_len);
        if (cliente_socket < 0) {
            perror("Error al aceptar la conexión");
            continue;
        }

        char buffer[256];
        memset(buffer, 0, sizeof(buffer));
        int bytes_received = recv(cliente_socket, buffer, sizeof(buffer), 0);
        if (bytes_received > 0) {
            buffer[bytes_received] = '\0';
            jugadores.push_back({cliente_socket, buffer, 0, true});
            std::cout << "Jugador conectado (" << jugadores.size() << "/" << max_jugadores <<"): " << buffer << std::endl;
        }
    }
    return jugadores;
}

void mostrar_ayuda(){
    printf("\n---------------------------------------------------------------------------------------------------------\n");
    printf("\t\t\tFuncion de ayuda del ejercicio 5:\n");
    printf("\nIntegrantes:\n\t-MATHIEU ANDRES SANTAMARIA LOIACONO, MARTIN DIDOLICH, FABRICIO MARTINEZ, LAUTARO LASORSA, MARCOS EMIR QUELALI AMISTOY\n");

    printf("\nPara preparar el entorno de desarrollo ejecutar el siguiente comando:\n");
    printf("\n\t$sudo apt install build-essential\n");
    printf("\nPara compilar los makefile ejecutar el siguiente comando:\n");
    printf("\n\t$make all\n");
    printf("\nPara borrar los makefile ejecutar el siguiente comando:\n");
    printf("\n\t$make clean\n");
    
    printf("\nDescripcion:");
    printf("\n\tEl siguiente programa ejecuta el juego de la memoria Memotest, pero alfabetico \n\n");
    printf("\nEl programa se implementa a travez de de conexiones de red, pudiendo admitir más de un cliente por servidor.");
    printf("\nEl servidor debe tomar por parámetro el puerto y la cantidad de clientes necesarios para iniciar la partida");

    printf("\nParametros\n");
    printf("\n-p/--puerto: Numero del puerto. (Requerido)\n");
    printf("\n-j/--jugadores:Cantidad de jugadores a esperar para iniciar la sala. (Requerido)\n");

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
    printf("\n\t$./servidor -p 8080 -j 2\n");
    printf("\n\t$./servidor --puerto 8080 --jugadores 2\n");

    printf("\n---------------------------------------------------------------------------------------------------------\n");

    printf("\nAclaraciones\n");
    printf("\n\tEl juego de la memoria Memotest consiste en encontrar las parejas de letras en el menor tiempo posible.");
    printf("\n\tEl juego finaliza cuando se encuentran todas las parejas.");
    printf("\n1. Si el servidor se cae (deja de funcionar) o es detenido, los clientes deben seran notificados y se cerrara de forma controlada.\n");
    printf("\n2. Si alguno de los clientes se cae o es detenido, el servidor indentifica el problema ,cierra la conexión de forma controlada y sigue funcionando hasta que solo quede un cliente\n");
    printf("\n3. Los clientes pueden ver el estado actualizado del tablero cuando ocurran aciertos y solo se permitirá una jugada por turno de cada cliente\n");
    printf("\nSe llevara un marcador indicando cuantos aciertos realizó cada jugador y al final mostrara el ganador.\n");
}