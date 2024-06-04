#Makefile

CC = g++
CFLAGS = -Wall -Wextra

all: cliente servidor

cliente: cliente.cpp config.hpp
	$(CC) $(CFLAGS) -o cliente cliente.cpp

servidor: servidor.cpp config.hpp
	$(CC) $(CFLAGS) -o servidor servidor.cpp

clean:
	rm -f cliente servidor
