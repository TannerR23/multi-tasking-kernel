#include "wramp.h"


void base10SSD(int switches){
    int switchMask = 0;

    switchMask = switches % 10;
    WrampParallel -> LowerRightSSD = switchMask;
    switchMask = switches / 10;
    switchMask = switchMask % 10;
    WrampParallel -> LowerLeftSSD = switchMask;
    switchMask = switches / 100;
    switchMask = switchMask % 10;
    WrampParallel -> UpperRightSSD = switchMask;
    switchMask = switches / 1000;
    switchMask = switchMask % 10;
    WrampParallel -> UpperLeftSSD = switchMask;
}

void hexSSD(int switches){
    WrampParallel -> LowerRightSSD = switches;
    switches = switches >> 4;
    WrampParallel -> LowerLeftSSD = switches;
    switches = switches >> 4;
    WrampParallel -> UpperRightSSD = switches;
    switches = switches >> 4;
    WrampParallel -> UpperLeftSSD = switches;
}

void main(){
    int switches = 0;
    int buttonValue = 0;

    while (1){
        switches = WrampParallel->Switches;
        buttonValue = WrampParallel->Buttons;

        if(buttonValue == 1){
            base10SSD(switches);
        }
        else if(buttonValue == 2){
            hexSSD(switches);
        }
        else if(buttonValue == 4){
            return;
        }
    }
}
