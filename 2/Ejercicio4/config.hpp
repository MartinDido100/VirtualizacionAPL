#ifndef CONFIG_HPP
#define CONFIG_HPP

#include <iostream>
using namespace std;

const string MEMORIA_COMPARTIDA = "memoria_compartida";
const string SEMAFORO_CLIENTE = "semaforo_clientes";
const string SEMAFORO_SERVIDOR = "semaforo_servidor";
const string SEMAFORO_JUGADA_A = "semaforo_jugada_a";
const string SEMAFORO_JUGADA_B = "semaforo_jugada_b";
const string SEMAFORO_JUGADA_C = "semaforo_jugada_c";
const string SEMAFORO_NO_CLIENTE = "semaforo_fin";

/*
 '-' mostrar blanco
 'A' mostrar verde
 -'A' mostrar amarillo
*/
struct datos_compartidos{
    char mostrar[4][4];
    char last_jugada[2];
    char jugada[2];
    int aciertos, num_jugadas;
    char mensaje[40];
    bool fin;
};

#endif
