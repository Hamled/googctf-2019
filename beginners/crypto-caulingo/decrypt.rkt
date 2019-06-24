#lang racket

(require crypto crypto/libcrypto math)
(require (only-in file/sha1
                  hex-string->bytes))

(define rsa-factory libcrypto-factory)

(define (read-values path)
  (let* ([lines (file->lines path)]

         [n-line (list-ref lines 1)]
         [e-line (list-ref lines 4)]
         [p-line (list-ref lines 7)]
         [q-line (list-ref lines 10)]
         [m-line (list-ref lines 13)]

         [n (string->number n-line 10)]
         [e (string->number e-line 10)]
         [p (string->number p-line 10)]
         [q (string->number q-line 10)]
         [m (hex-string->bytes m-line)])
    (values (list n e p q) m)))

(define (rsa-params->pk-key key-params)
  (let*-values ([(n e p q) (apply values key-params)]
                [(ctot) (lcm (sub1 p) (sub1 q))]
                [(d) (modular-inverse e ctot)]
                [(dp) (modular-inverse e (sub1 p))]
                [(dq) (modular-inverse e (sub1 q))]
                [(qInv) (modular-inverse q p)])
    (datum->pk-key (list 'rsa 'private 0 n e d p q dp dq qInv)
                   'rkt-private rsa-factory)))

(define (main)
  (crypto-factories rsa-factory)
  (let*-values ([(key-params msg) (read-values "msg.txt")]

                [(key) (rsa-params->pk-key key-params)]
                [(key-der) (pk-key->datum key 'RSAPrivateKey)]
                #;[(plaintext) (pk-decrypt key msg)])
    ;#(displayln (bytes->string/utf-8 plaintext))
    (display key-der)))

(main)
