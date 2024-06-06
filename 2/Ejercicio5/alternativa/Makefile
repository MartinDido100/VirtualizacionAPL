#Makefile

CC = g++
CFLAGS = -Wall -Wextra

all: cliente servidor

cliente: cliente.cpp
	$(CC) $(CFLAGS) -g -o cliente cliente.cpp

servidor: servidor.cpp
	$(CC) $(CFLAGS) -g -o servidor servidor.cpp

clean:
	rm -f cliente servidor