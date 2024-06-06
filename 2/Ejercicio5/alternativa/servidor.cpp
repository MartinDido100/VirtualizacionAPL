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

struct Jugador {
    int socket;
    std::string nombre;
    int puntaje;
};

// Inicializa el tablero oculto del juego con pares de letras
void inicializar_tableros(char tablero[4][4], char tablero_mostrar[4][4]);

//Envía el tablero que se muestra y status a los jugadores
void actualizar_y_enviar_tablero(const std::vector<Jugador>& jugadores, char tablero[4][4], const std::string& mensaje_turno);

void parse_arguments(int argc, char* argv[], int* puerto, int* max_jugadores);

void crear_conexion(int* servidor_socket, int max_jugadores, int puerto);

std::vector<Jugador> iniciar_conexion_clientes(int max_jugadores, int servidor_socket);

int main(int argc, char *argv[]) {
    const std::string SEMAFORO_CLIENTE = "semaforo_clientes";
    int puerto = 27018;
    int max_jugadores = 2;
    std::vector<Jugador> jugadores;
    int servidor_socket;
    char tablero[4][4];
    char tablero_mostrar[4][4];
    int aciertos=0;


    auto semaforo_buffer_disp = sem_open(
            SEMAFORO_CLIENTE.c_str(),
            O_CREAT,
            0600,
            1
    );

    // Inicializar el tablero de juego
    inicializar_tableros(tablero, tablero_mostrar);

    parse_arguments(argc, argv, &puerto, &max_jugadores);

    crear_conexion(&servidor_socket, max_jugadores, puerto);

    std::cout << "Esperando a que se conecten todos los jugadores..." << std::endl;

    jugadores=iniciar_conexion_clientes(max_jugadores, servidor_socket);

    std::cout << "Inicia la partida!" << std::endl;

    // Lógica del juego
    int turno = 0;
    bool partida_activa = true;
    char jugada[2];
    int fila_anterior, col_anterior;

    while (partida_activa) {
        std::string mensaje_turno = "Servidor: Turno del jugador: " + jugadores[turno].nombre + " con puntaje: " + std::to_string(jugadores[turno].puntaje) + "\n";

        for (int jugadas = 0; jugadas < 2; ++jugadas) {
            std::cout << "Servidor: Esperando jugadada del jugador: " << jugadores[turno].nombre << "\n" << std::endl;

            // Enviar mensaje indicando que es el turno del jugador actual
            actualizar_y_enviar_tablero(jugadores, tablero_mostrar, mensaje_turno);
            const char* mensaje_tu_turno = "Servidor: Es tu turno";
            // sem_wait(semaforo_buffer_disp);
            send(jugadores[turno].socket, mensaje_tu_turno, strlen(mensaje_tu_turno)+1, 0);
            // sem_post(semaforo_buffer_disp);

            int bytes_received = recv(jugadores[turno].socket, jugada, sizeof(jugada), 0);
            if (bytes_received <= 0) {
                std::cout << "Servidor: Jugador desconectado: " << jugadores[turno].nombre << std::endl;
                partida_activa = false;
                break;
            }

            int fila = jugada[0];
            int col = jugada[1];

            if (fila < 0 || fila > 3 || col < 0 || col > 3) {
                const char* mensaje_invalido = "\033[1;31mServidor: Jugada invalida\033[0m\n";
                // sem_wait(semaforo_buffer_disp);
                send(jugadores[turno].socket, mensaje_invalido, strlen(mensaje_invalido)+1, 0);
                // sem_post(semaforo_buffer_disp);
                jugadas--;
                continue;
            } else if (tablero_mostrar[fila][col] != '-') {
                const char* mensaje_repetido = "\033[1;31mServidor: Jugada repetida\033[0m\n";
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
                    actualizar_y_enviar_tablero(jugadores, tablero_mostrar, "");
                    if (tablero[fila][col] == tablero[fila_anterior][col_anterior]) {
                        tablero_mostrar[fila][col] = tablero[fila][col];
                        tablero_mostrar[fila_anterior][col_anterior] = tablero[fila_anterior][col_anterior];
                        const char* mensaje_acierto = "\033[1;32mServidor:  -- ACIERTO -- \033[0m\n";
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
                        const char* mensaje_fallo = "\033[1;31mServidor:  -- FALLO -- \033[0m\n";
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
        turno = (turno + 1) % max_jugadores;
    }

    actualizar_y_enviar_tablero(jugadores, tablero_mostrar, "Servidor: --- FIN DEL JUEGO ---");
    for (const auto& jugador : jugadores) {
        std::string msg = "Servidor: Tu puntaje: " + jugador.puntaje;
        send(jugador.socket, msg.c_str(), msg.size(), 0);
    }
    // Cerrar los sockets
    for (const auto& jugador : jugadores) {
        close(jugador.socket);
    }
    sem_unlink(SEMAFORO_CLIENTE.c_str());
    close(servidor_socket);

    return 0;
}


// Inicializa el tablero de juego con pares de letras
void inicializar_tableros(char tablero[4][4], char tablero_mostrar[4][4]) {
    memset(tablero_mostrar, '-', 16);
    std::vector<char> letras = {'A', 'A', 'B', 'B', 'C', 'C', 'D', 'D', 'E', 'E', 'F', 'F', 'G', 'G', 'H', 'H'};
    std::random_shuffle(letras.begin(), letras.end());
    int idx = 0;
    for (int i = 0; i < 4; ++i) {
        for (int j = 0; j < 4; ++j) {
            tablero[i][j] = letras[idx++];
        }
    }
}

void actualizar_y_enviar_tablero(const std::vector<Jugador>& jugadores, char tablero[4][4], const std::string& mensaje_turno) {
    for (const auto& jugador : jugadores) {
        char msg[17];
        for(int a = 0; a < 4; a++) 
            for(int b = 0; b < 4; b++)
                msg[a*4+b] = tablero[a][b];
        msg[16] = '\0';
        int datosEnviados=send(jugador.socket, msg, sizeof(msg), 0);
        datosEnviados=send(jugador.socket, mensaje_turno.c_str(), mensaje_turno.size(), 0);
    }
}

void parse_arguments(int argc, char* argv[], int* puerto, int* max_jugadores) {
    // Parseo de argumentos
    for (int i = 1; i < argc; ++i) {
        if (strcmp(argv[i], "--puerto") == 0) {
            *puerto = atoi(argv[++i]);
        } else if (strcmp(argv[i], "--jugadores") == 0) {
            *max_jugadores = atoi(argv[++i]);
        }
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
    if (setsockopt(*servidor_socket, IPPROTO_TCP, TCP_NODELAY, &flag, sizeof(int)) < 0) {
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
    while (jugadores.size() < max_jugadores) {
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
            jugadores.push_back({cliente_socket, buffer, 0});
            std::cout << "Jugador conectado (" << jugadores.size() << "/" << max_jugadores <<"): " << buffer << std::endl;
        }
    }
    return jugadores;
}