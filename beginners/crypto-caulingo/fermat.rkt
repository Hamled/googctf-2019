#lang racket

(require math gmp)

; Translated from Python source at https://wiremask.eu/articles/fermats-prime-numbers-factorization/
(define (fermat-factor n)
  (when (= (modulo n 2) 0)
      (error "Can only use fermat's factorization on odd numbers"))
  (let loop ([a (integer-sqrt n)])
    (let ([b**2 (- (sqr a) n)])
      (if (false? (and (<= 0 b**2) (perfect-square b**2)))
          (loop (add1 a))
          (list
           (+ a (integer-sqrt b**2))
           (- a (integer-sqrt b**2)))))))

(define (fermat-factor-gmp n)
  (when (= (modulo n 2) 0)
    (error "Can only use fermat's factorization on odd numbers"))

  (define zn (mpz n))
  (define za (mpz 0))
  (define zb (mpz 0))
  (define zp (mpz 0))
  (define zq (mpz 0))

  (begin
    (mpz_sqrt za zn) ; (integer-sqrt n)
    (let loop ([za za])
      (begin
        (mpz_mul zb za za) ; (sqr a)
        (mpz_sub zb zb zn) ; (- ^^^ n)
        (when (= 0 (mpz_perfect_square_p zb)) ; (if (false? (perfect-square b)))
          (begin
            (mpz_add_ui za za 1) ; (add1 a)
            (loop za))))) ; (loop       ^^^^^)
    (mpz_sqrt zb zb) ; (integer-sqrt b)
    (mpz_add zp za zb) ; (+ a ^^^^^)
    (mpz_sub zq za zb) ; (- a ^^^^^)
    (list (mpz->number zp) (mpz->number zq))))
