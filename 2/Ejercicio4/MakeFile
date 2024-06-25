#Makefile

CC = g++
CFLAGS = -Wall -Wextra -Wshadow

all: cliente servidor Makefile

cliente: cliente.cpp config.hpp Makefile
	$(CC) $(CFLAGS) -o cliente cliente.cpp

servidor: servidor.cpp config.hpp Makefile
	$(CC) $(CFLAGS) -o servidor servidor.cpp

clean:
	rm -f cliente servidor