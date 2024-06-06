#Makefile

CC = g++
CFLAGS = -Wall -Wextra -Wshadow

all: cliente servidor Makefile

cliente: cliente.cpp Makefile
	$(CC) $(CFLAGS) -g -o cliente cliente.cpp

servidor: servidor.cpp Makefile
	$(CC) $(CFLAGS) -g -o servidor servidor.cpp

clean:
	rm -f cliente servidor