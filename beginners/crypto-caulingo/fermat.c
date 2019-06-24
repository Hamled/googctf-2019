// This code is from https://wiremask.eu/articles/fermats-prime-numbers-factorization/
#include <gmp.h>
#include <time.h>

// How many attempts before checking the clock again to estimate speed
#define ATTEMPTS_PER_MEASURE 100000000

void fermat_factor(mpz_t p, mpz_t q, mpz_t N);

int main()
{
    mpz_t N;
    mpz_t p, q;

    mpz_init(N);
    mpz_init(p);
    mpz_init(q);

    mpz_set_str(N, "2345678917", 10); // test "worst case" from Wikipedia
    //mpz_set_str(N, "4E733FEBB94DB17CA3E6AA26EC33B4960C150C52300E06C60B3318F0744FEF2D687A8F5BF598894A22EEC4ABDAE01B197E4CC5603DE67EB670E261EB4E4CC5E26241EDCDE494CCE415BBC5A410ABCEFDFF6199BBCDF62E9D434FAA88A1D16012520F80D126208206FF80191E20ED7423CDCE5B8A555B4161534E789A74F0A701", 16); // example n from original code (RSA 1024-bit key I think)

    //mpz_set_str(N, "17450892350509567071590987572582143158927907441748820483575144211411640241849663641180283816984167447652133133054833591585389505754635416604577584488321462013117163124742030681698693455489404696371546386866372290759608301392572928615767980244699473803730080008332364994345680261823712464595329369719516212105135055607592676087287980208987076052877442747436020751549591608244950255761481664468992126299001817410516694015560044888704699389291971764957871922598761298482950811618390145762835363357354812871474680543182075024126064364949000115542650091904557502192704672930197172086048687333172564520657739528469975770627", 10);
    fermat_factor(p, q, N);

    gmp_printf("p = %Zd\n", p);
    gmp_printf("q = %Zd\n", q);

    mpz_clear(p);
    mpz_clear(q);
    mpz_clear(N);

    return 0;
}

void fermat_factor(mpz_t p, mpz_t q, mpz_t N)
{
    mpz_t a, b,
          n_attempts, n_measures, total_seconds;

    mpz_init(a);
    mpz_init(b);

    mpz_init(n_attempts);
    mpz_init(n_measures);
    mpz_init(total_seconds);

    mpz_sub_ui(a, N, 1);
    mpz_sqrt(a, a);
    mpz_add_ui(a, a, 1);

    // Figure out max number of attempts
    mpz_sub(n_attempts, N, a);
    gmp_printf("Max attempts needed: %Zd\n", n_attempts);
    mpz_div_ui(n_measures, n_attempts, ATTEMPTS_PER_MEASURE);

    // Calculate how long this will take at most
    clock_t start = clock(), last_measure = start, now;
    size_t attempt = 0;

    while (1)
    {
        mpz_mul(b, a, a);
        mpz_sub(b, b, N);

        if (mpz_perfect_square_p(b))
            break;

        mpz_add_ui(a, a, 1);

        // If we've hit another measurement cycle, do it
        if(__builtin_expect((++attempt >= ATTEMPTS_PER_MEASURE), 0))
        {
            now = clock();
            int msec = (now - last_measure) * 1000 / CLOCKS_PER_SEC;
            gmp_printf("%d attempts in %d.%03d seconds, ", ATTEMPTS_PER_MEASURE, msec/1000, msec%1000);

            /*
            mpz_sub_ui(n_measures, n_measures, 1);
            mpz_mul_ui(total_seconds, n_measures, msec);
            mpz_div_ui(total_seconds, total_seconds, 1000);
            gmp_printf("estimate time remaining is %5.Zd seconds\n", total_seconds);
            */

            // Reset
            last_measure = now;
            attempt = 0;
        }
    }

    mpz_sqrt(p, b);
    mpz_sqrt(q, b);
    mpz_add(p, a, p);
    mpz_sub(q, a, q);

    mpz_clear(a);
    mpz_clear(b);
    mpz_clear(n_attempts);
}
