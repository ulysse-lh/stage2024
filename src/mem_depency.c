#include <stdio.h>

#define N 20

static int pixel[N];
static int hist[N];
static int i;

#ifdef NORMAL

void run() {
    for (i = 0; i < N; i++)
        hist[pixel[i]]++;
}

// static schedule version (loop distance II = 3)
#elif STATIC_SCHED

void run() {
static int stage = 0;
static int tmp1;
static int tmp2;

    for (i = 0; i < N; ) {
        switch (stage) {
            case 0:
                tmp1 = pixel[i];
                break;
            case 1:
                tmp2 = hist[tmp1];
                break;
            case 2:
                hist[tmp1] = tmp2 + 1;
                i++;
                break;
        }
        stage = (stage + 1) % 3;
    }
}

// proper speculative dynamic-scheduled pipelining
/*

ooooxo
 pppxp
  mmmxm

*/
#else

#include <stdbool.h>

void run() {
static bool stage1, stage2, stage3;
static int payload_stage1_2, payload_stage2_3, payload_stage2_3bis;
static bool stall = false;
static bool was_stalled = false;


    for (i = 0; i < N + 2; ) {
        stage1 = i < N;
        stage2 = 1 <= i && i < N + 1;
        stage3 = 2 <= i;
        was_stalled = stall;

        if (was_stalled)
            stall = false;
        else if (2 <= i && i < N + 1 && pixel[i - 2] == pixel[i - 1])
            stall = true;


        if (stage3 && !was_stalled)
            hist[payload_stage2_3] = payload_stage2_3bis + 1;

        if (stage2 && !stall) {
            payload_stage2_3    = payload_stage1_2;
            payload_stage2_3bis = hist[payload_stage1_2];
        }


        if (stage1 && !stall)
            payload_stage1_2 = pixel[i];


        if (!stall)
            i++;
    }
}

#endif

#include <stdlib.h>

int main() {

    srand(0xfe654abd);


    for (int j = 0; j < N; j++) {
        hist [j] = rand() % 1000;
        pixel[j] = rand() % N;
    }

    run();

    for (int j = 0; j < N; j++) {
        printf("pixel[i] = %d; hist[i] = %d\n", pixel[j], hist[j]);
    }

}
