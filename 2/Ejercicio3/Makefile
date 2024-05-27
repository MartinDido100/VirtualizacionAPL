#Makefile

CC = gcc
CFLAGS = -Wall -Wextra

all: sensor centralizado

sensor: sensor.c
	$(CC) $(CFLAGS) -o sensor sensor.c

centralizado: centralizado.c
	$(CC) $(CFLAGS) -o centralizado centralizado.c

clean:
	rm -f sensor centralizado