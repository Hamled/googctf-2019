#include <gmp.h>
#include <stdio.h>

int main(int argc, char **argv) {
  if(argc < 2) {
    fprintf(stderr, "Usage: %s <modulus to factor in decimal>\n", argv[0]);
    return 1;
  }

  // Get the n to factor
  mpz_t n;
  mpz_init_set_str(n, argv[1], 10);

  // Loop through all possible combinations of A and B
  // where 1 <= A, B <= 1,000
  mpz_t a, b, p, q, scratch;
  mpz_init_set_ui(a, 1);
  mpz_init_set_ui(b, 1000);
  mpz_inits(p, q, scratch, NULL);

  setbuf(stdout, NULL);
  printf("  0.0%% done.\b\b\b\b\b\b\b\b\b\b\b\b\b");
  for(int ib = 1000; ib >= 1; ib--, mpz_sub_ui(b, b, 1)) {
    for(int ia = 1; ia <= ib; ia++, mpz_add_ui(a, a, 1)) {
      // Calculate a p for every value within 10,000 of sqrt(n * b/a)
      mpz_mul(p, n, b);
      mpz_fdiv_q(p, p, a);
      mpz_sqrt(p, p);
      mpz_sub_ui(p, p, 10000);

      for(int ip = 0; ip < 20000; ip++, mpz_add_ui(p, p, 1)) {
        mpz_mod(scratch, n, p);
        if(mpz_sgn(scratch) == 0) {
          mpz_divexact(q, n, p);

          printf("\n");
          gmp_printf("p = %Zd\n", p);
          gmp_printf("q = %Zd\n", q);
          goto done;
        }
      }
    }

    mpz_set_ui(a, 1);
    printf("%5.1f\b\b\b\b\b", (float)(1000 - ib) / 10.0f);
  }

  printf("\nDidn't find factors??? :(\n");

 done:
  mpz_clears(n, a, b, p, q, scratch, NULL);
  return 0;
}
