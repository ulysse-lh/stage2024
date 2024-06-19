#include <stdio.h>

static int foo(int);
static int bar(int);
static int baz(int);

#define N 20

static int in[N], A[N], B[N], out[N];
static int i;


// spec version
#ifdef NORMAL

void run() {
    for (i = 0; i < N; i++) {
        A[i] = foo(in[i]);
        B[i] = bar(A[i]);
        out[i] = baz(B[i]);
    }
}

// static schedule version (loop distance II = 3)
#elif defined(STATIC_SCHED)


void run() {
static int stage = 0;

    for (i = 0; i < N;) {
        switch (stage) {
            case 0:
                A[i] = foo(in[i]);
                break;
            case 1:
                B[i] = bar(A[i]);
                break;
            case 2:
                out[i] = baz(B[i]);
                i++;
                break;
        }
        stage = (stage + 1) % 3;
    }
}

// actual pipelining
#else


void run() {

    for (i = 0; i < N + 2; i++) {

        if (i < N)
            A[i] = foo(in[i]);
        if (1 <= i && i < N + 1)
            B[i - 1] = bar(A[i - 1]);
        if (2 < i)
            out[i - 2] = baz(B[i - 2]);

    }
}



#endif


int main() {

    for (int j = 0; j < N; j++)
        in[j] = j * 3 - 2;

    run();

    for (int j = 0; j < N; j++)
        printf("i #%d in_i %d A_i %d B_i %d out_i %d\n", j, in[j], A[j], B[j], out[j]);

}









static int foo(int x) {return x + 5;}
static int bar(int x) {return x / 3;}
static int baz(int x) {return (x - 2) % 23;}
