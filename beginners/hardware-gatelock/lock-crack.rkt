#lang racket

(require (only-in srfi/60
                  integer->list))

(define (switches->inputs switches)
  ; Translates each of 20 switches to 38 inputs to the lock circuit
  ; The numbering scheme is higher numbers to the left, when facing levers
  ;  1 -> 30      ; 11 -> 17, 22
  ;  2 -> 28      ; 12 -> 32
  ;  3 -> 29      ; 13 -> 23
  ;  4 -> 27      ; 14 ->  3,  5, 26
  ;  5 -> 24      ; 15 ->  7, 25, 33
  ;  6 ->  4,  6  ; 16 -> 11, 16, 35
  ;  7 ->  8, 34  ; 17 -> 10, 19, 36
  ;  8 -> 12, 15  ; 18 ->  1, 13, 37
  ;  9 ->  9, 20  ; 19 -> 18, 21, 38
  ; 10 ->  2, 14  ; 20 -> 31
 (map (λ (s) (list-ref switches (sub1 s)))
       (list 18 10 14  6 14  6 15  7  9 17 ;  1 - 10
             16  8 18 10  8 16 11 19 17  9 ; 11 - 20
             19 11 13  5 15 14  4  2  3  1 ; 21 - 30
             20 12 15  7 16 17 18 19)))    ; 31 - 38

(define (lock-circuit switches)
  (let* ([inputs (switches->inputs switches)]
         [i (λ (n) (list-ref inputs (sub1 n)))]

         [iand  (λ (n) (and (i n) (i (add1 n))))]
         [ior   (λ (n) (or  (i n) (i (add1 n))))]
         [inand (λ (n) (and (not (i n)) (i (add1 n))))]
         [inor  (λ (n) (or  (not (i n)) (i (add1 n))))])

    (and (and (and (not (or (not (and (ior 1) (ior 3)))
                            (or (iand 5) (iand 7))))
                   (and (and (inor 9) (inor 11))
                        (and (not (iand 13)) (inor 15))))
              (and (and (inor 17) (inor 19)) (inor 21)))
         (and (and (and (not (ior 23)) (inand 25))
                   (and (not (ior 27)) (inand 29)))
              (and (and (inand 31) (ior 33))
                   (and (not (ior 35)) (inand 37)))))))

(define key-len 20)

(define (crack-lock)
  (for/or ([n (in-range (expt 2 key-len))])
    (let ([key (integer->list n key-len)])
      (and (lock-circuit key) key))))
