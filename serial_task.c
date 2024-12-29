#include "wramp.h"
int counter = 0;

void printChar(char character){
    while(!(WrampSp2 -> Stat & 2));

    WrampSp2 -> Tx = character;
}

void main(){
    char characterRecieved = '1';

    while(1){
        if((WrampSp2 -> Stat & 1)){
            characterRecieved = WrampSp2 -> Rx;
        }

        if(characterRecieved == '1'){
            printChar('\r');
            printChar(((counter / 100000) % 10) + 48);
            printChar(((counter / 10000) % 10) + 48);
            printChar(((counter / 1000) % 10) + 48);
            printChar(((counter / 100) % 10) + 48);
            printChar('.');
            printChar(((counter / 10) % 10) + 48);
            printChar((counter % 10) + 48);
        }
        else if(characterRecieved == '2'){
            int seconds = counter / 100;
            int minutes = seconds / 60;
            seconds = seconds % 60;

            printChar('\r');
            printChar((((minutes / 10)) % 10) + 48);
            printChar((minutes % 10) + 48);
            printChar(':');
            printChar((((seconds / 10)) % 10) + 48);
            printChar((seconds % 10) + 48);
            printChar(' ');
            printChar(' ');
        }
        else if(characterRecieved == '3'){
            printChar('\r');
            printChar(((counter / 100000) % 10) + 48);
            printChar(((counter / 10000) % 10) + 48);
            printChar(((counter / 1000) % 10) + 48);
            printChar(((counter / 100) % 10) + 48);
            printChar(((counter / 10) % 10) + 48);
            printChar((counter % 10) + 48);
        }
        else if(characterRecieved == 'q'){
            return;
        }
    }
}
