#include <stdbool.h>
#include <stdlib.h>
#include <stdio.h>


static bool cond(int);
static int slow(int);
static int fast(int);
static int x;
static int i;

#ifdef NORMAL

void run() {

    for (;;i++) {
        x = cond(x) ? slow(x) : fast(x);
        printf("iter #%d x %d\n", i, x);
    }

}

#elif defined(DYN_SCHED)

void run() {
static int stage = 0;
static int tmp1, tmp2, tmp3;

    for (;;) {
        switch (stage) {
            case 0:
                i++;
                tmp3 = fast(x);
                // additionally, computing stage #1 of cond & slow
                stage = 1;
                break;
            case 1:
                tmp1 = cond(x);
                if (tmp1) // slow path
                    stage = 2;
                else { // fast path
                    x = tmp3;
                    stage = 0;
                }
                break;
            case 2:
                tmp2 = slow(x);
                x = tmp2;
                stage = 0;
                break;
            default:
                abort();
        }
        printf("iter #%d x %d\n", i, x);
    }

}

#else

/*
    c1 c1 c1 c1 c1 c1
       c2 c2 c2 c2 c2
    s1 s1 s1 s1 s1 s1
       s2 s2 s2 s2 s2
          s3 s3 s3 s3
    f1 f1 f1 f1 f1 f1
*/

void run() {
static bool s_cond1, s_cond2, s_slow1, s_slow2, s_slow3, s_fast1;
static int stall_counter = 0;
static int x_old, x_old_old;

    s_cond1 = true;
    s_slow1 = true;
    s_fast1 = true;

    x_old = x_old_old = x;

    for (;;i++) {
        x_old_old = x_old;
        x_old = x;

        if (!stall_counter && s_cond2 && cond(x)) {
            s_cond1 = false;
            s_fast1 = false;
            s_slow1 = false;
            x = x_old_old;
            stall_counter = 2;
        } else if (!stall_counter) {
            s_cond1 = true;
            s_fast1 = true;
            s_slow1 = true;
        }

        if (s_slow3 && stall_counter == 1)
            x = slow(x);
        else if (s_fast1 && !stall_counter)
            x = fast(x);




        if (stall_counter > 0)
            stall_counter--;

        s_cond2 = s_cond1;
        s_slow3 = s_slow2;
        s_slow2 = s_slow1;

        printf("iter #%d x %d x-1 %d x-2 %d c1 %d c2 %d\n", i, x, x_old, x_old_old, s_cond1, s_cond2);
    }

}

#endif








int main() {

    srand(0xfe654abd);

    x = rand() % 50;
    printf("start x %d\n", x);
    run();

}

static bool cond(int x) {
    return ((x * 32 - x) ^ 0xf654e) & 4;
}

static int slow(int x) {
    return x * 2 - 5;
}

static int fast(int x) {
    return x + 1;
}
