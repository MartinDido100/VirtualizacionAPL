#include <iostream>
#include <string>
#include <unistd.h>
#include <arpa/inet.h>
#include <cstring>

using namespace std;

void mostrar(char memoria[4][4]);

int main(int argc, char *argv[]) {
    string nickname;
    string server_ip;
    int server_port;

    for (int i = 1; i < argc; i += 2) {
        string arg = argv[i];
        if (arg == "-n" || arg == "--nickname") {
            nickname = argv[i + 1];
        } else if (arg == "-s" || arg == "--servidor") {
            server_ip = argv[i + 1];
        } else if (arg == "-p" || arg == "--puerto") {
            server_port = stoi(argv[i + 1]);
        }
    }

    if (nickname.empty() || server_ip.empty() || server_port == 0) {
        cerr << "Usage: " << argv[0] << " -n <nickname> -s <server_ip> -p <server_port>" << endl;
        return 1;
    }

    int sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock < 0) {
        perror("socket");
        return 1;
    }

    sockaddr_in server_addr;
    memset(&server_addr, 0, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(server_port);
    if (inet_pton(AF_INET, server_ip.c_str(), &server_addr.sin_addr) <= 0) {
        cerr << "Invalid address: " << server_ip << endl;
        return 1;
    }

    if (connect(sock, (struct sockaddr*)&server_addr, sizeof(server_addr)) < 0) {
        perror("connect");
        return 1;
    }

    send(sock, nickname.c_str(), nickname.size(), 0);

    char buffer[256];
    char jugada[2];
    bool jugando = true;

    while (jugando) {
        // Recibir actualización del tablero
        int bytes_received = recv(sock, buffer, sizeof(buffer), 0);
        std::cout << "Se recibieron en total: " << bytes_received << std::endl;
        if (bytes_received <= 0) {
            cerr << "Connection closed or error." << endl;
            break;
        }

        buffer[bytes_received] = '\0';

        cout << "\n Acá arranca el buffer -> " << buffer << " <-Este es el buffer" << endl;
        int esJugada = ((std::string) buffer).find("jugador") == std::string::npos &&
        ((std::string) buffer).find("ACIERTO") == std::string::npos &&
        ((std::string) buffer).find("FALLO") == std::string::npos &&
        ((std::string) buffer).find("turno") == std::string::npos &&
        ((std::string) buffer).find("Servidor:") == std::string::npos;

        if (esJugada) {
            mostrar((char(*)[4])buffer);
        } else {
            int miTurno = 0;
            miTurno = (((std::string) buffer).find("tu turno") != std::string::npos);
            if (miTurno) {
                cout << "\033[1;31m" << buffer << "\033[0m" << endl;

                int i, j;
                cout << "Ingrese las coordenadas de fila y columna (0 - 3) de la celda que desea seleccionar: ";
                cin >> i >> j;

                jugada[0] = char(i);
                jugada[1] = char(j);

                send(sock, jugada, sizeof(jugada), 0);
            } else {
                cout << buffer << endl;
            }
        }
    }

    cout << "Juego Finalizado" << endl;

    close(sock);
    return 0;
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