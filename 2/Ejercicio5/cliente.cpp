#include <iostream>
#include <string>
#include <unistd.h>
#include <arpa/inet.h>
#include <cstring>

using namespace std;

void mostrar(char memoria[4][4]);
void mostrar_ayuda();

int main(int argc, char *argv[]) {
    string nickname;
    string server_ip;
    int server_port = -1;

    for (int i = 1; i < argc; i += 2) {
        string arg = argv[i];
        if (arg == "-n" || arg == "--nickname") {
            nickname = argv[i + 1];
        } else if (arg == "-s" || arg == "--servidor") {
            server_ip = argv[i + 1];
        } else if (arg == "-p" || arg == "--puerto") {
            server_port = stoi(argv[i + 1]);
        } else if(arg == "-h" || arg == "--help"){
            mostrar_ayuda();
            return 0;
        } else {
            cerr << "Argumento no reconocido: " << arg << endl;
            return 1;
        }
    }

    if (nickname.empty() || server_ip.empty() || server_port == 0) {
        if(nickname.empty())
            cerr << "\033[1;31mNickname no especificado\033[0m" << endl;
        if(server_ip.empty())
            cerr << "\033[1;31mDirección IP del servidor no especificada\033[0m" << endl;
        if(server_port == -1)
            cerr << "\033[1;31mPuerto del servidor no especificado\033[0m" << endl;

        cerr << "\033[1;31mUso: " << argv[0] << " -n <nickname> -s <server_ip> -p <server_port>\033[0m" << endl;
        cerr << "\033[1;31mUse -h o --help para obtener más información\033[0m" << endl;
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

    char buffer[2048];
    char jugada[2];
    bool jugando = true;

    while (jugando) {
        
        // Check if the connection with sock is still active
        int error = 0;
        socklen_t len = sizeof(error);
        int status = getsockopt(sock, SOL_SOCKET, SO_ERROR, &error, &len);
        if (status != 0 || error != 0) {
            cerr << "\033[1;31mSe perdió conexión con el servidor\033[0m" << endl;
            break;
        }

        // Recibir actualización del tablero
        int bytes_received = recv(sock, buffer, sizeof(buffer), 0);
        
        if(((std::string) buffer).find("--- FIN DEL JUEGO ---") != std::string::npos){
            cout<<buffer<<endl;
            jugando = false;
            break;
        }
        
        // std::cout << "Se recibieron en total: " << bytes_received << std::endl;
        if (bytes_received <= 0) {
            cerr << "\033[1;31mSe perdió conexión con el servidor\033[0m" << endl;
            break;
        }

        buffer[bytes_received] = '\0';

        //cout << "\n Acá arranca el buffer -> " << buffer << " <-Este es el buffer" << endl;
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

void mostrar_ayuda(){
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
    printf("\n\tRecordar que puede utilizar la ip 127.0.0.1 para acceder a un servidor local\n");
    printf("\n---------------------------------------------------------------------------------------------------------\n");

    printf("\nAclaraciones\n");
    printf("\n\tEl juego de la memoria Memotest consiste en encontrar las parejas de letras en el menor tiempo posible.");
    printf("\n\tEl juego finaliza cuando se encuentran todas las parejas.");
    printf("\n1. Si el servidor se cae (deja de funcionar) o es detenido, los clientes deben seran notificados y se cerrara de forma controlada.\n");
    printf("\n2. Si alguno de los clientes se cae o es detenido, el servidor indentifica el problema ,cierra la conexión de forma controlada y sigue funcionando hasta que solo quede un cliente\n");
    printf("\n3. Los clientes pueden ver el estado actualizado del tablero cuando ocurran aciertos y solo se permitirá una jugada por turno de cada cliente\n");
    printf("\nSe llevara un marcador indicando cuantos aciertos realizó cada jugador y al final mostrara el ganador.\n");

}