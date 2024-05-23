#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <signal.h>
#include <sys/prctl.h>

#define NomHijo1 "Hijo1"
#define NomZombie "Zombie"
#define NomHijo3 "Hijo3"
#define NomNieto1 "Nieto1"
#define NomNieto2 "Nieto2"
#define NomNieto3 "Nieto3"
#define NomBiz "Biznieto"
#define NomDemon "Demonio"

void mostrarAyuda(){
    printf("Ayuda");
}

void matarProceso(int signum) {
    exit(0);
}


int main(int argc,char* argv[])
{
    pid_t padre=getpid(),hijo1,zombie,hijo3,nieto1,nieto2,nieto3,biznieto,demonio;

    prctl(PR_SET_NAME, "Padre", NULL, NULL, NULL);
    printf("Soy el proceso padre. Mi PID es: %d\n", padre);

    signal(SIGINT,matarProceso);
    
    hijo1=fork();

    if(hijo1 == 0){
        prctl(PR_SET_NAME, NomHijo1, NULL, NULL, NULL);
        printf("Soy el proceso %s con PID %d, mi padre es %d\n",NomHijo1,getpid(),getppid());

        nieto1=fork();
        if(nieto1 == 0){
            prctl(PR_SET_NAME, NomNieto1, NULL, NULL, NULL);
            printf("Soy el proceso %s con PID %d, mi padre es %d\n",NomNieto1,getpid(),getppid());
            while(1);
        }

        nieto2=fork();
        if(nieto2 == 0){
            prctl(PR_SET_NAME, NomNieto2, NULL, NULL, NULL);
            printf("Soy el proceso %s con PID %d, mi padre es %d\n",NomNieto2,getpid(),getppid());
            while(1);
        }

        nieto3=fork();
        if(nieto3 == 0){
            prctl(PR_SET_NAME, NomNieto3, NULL, NULL, NULL);
            printf("Soy el proceso %s con PID %d, mi padre es %d\n",NomNieto3,getpid(),getppid());

            biznieto=fork();
            if(biznieto == 0){
                prctl(PR_SET_NAME, NomBiz, NULL, NULL, NULL);
                printf("Soy el proceso %s con PID %d, mi padre es %d\n",NomBiz,getpid(),getppid());
                while(1);
            }

            while(1);
        }

        while(1);
    }

    zombie=fork();
    if(zombie==0){
        prctl(PR_SET_NAME, NomZombie, NULL, NULL, NULL);
        printf("Soy el proceso %s con PID %d, mi padre es %d\n",NomZombie,getpid(),getppid());
        exit(0); //Lo termino para que cuando el padre este en sleep no se entere que termino y lo vea en estado zombie.
    }

    hijo3=fork();
    if(hijo3==0){
        prctl(PR_SET_NAME, NomHijo3, NULL, NULL, NULL);
        printf("Soy el proceso %s con PID %d, mi padre es %d\n",NomHijo3,getpid(),getppid());

        demonio=fork();
        if(demonio==0){
            printf("Soy el proceso %s con PID %d, mi padre es %d\n",NomDemon,getpid(),getppid());
            setsid(); // Crear una nueva sesión
            chdir("/"); // Cambiar al directorio raíz
            // Cerrar descriptores de archivo estándar o redirigirlos a /dev/null
            close(STDIN_FILENO);
            close(STDOUT_FILENO);
            close(STDERR_FILENO);
            
            prctl(PR_SET_NAME, NomDemon, NULL, NULL, NULL);
            while(1);
        }

        while(1);
    }

    sleep(1);
    printf("\nPresiona enter para finalizar...\n");
    getchar();

    kill(hijo1,SIGINT);
    kill(zombie,SIGINT);
    kill(nieto1,SIGINT);
    kill(nieto3,SIGINT);
    kill(nieto2,SIGINT);
    kill(biznieto,SIGINT);
    kill(hijo3,SIGINT);

    return 0;
}
