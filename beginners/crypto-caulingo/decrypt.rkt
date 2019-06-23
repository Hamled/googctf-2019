#lang racket

(require crypto crypto/libcrypto asn1)
(require crypto/private/libcrypto/ffi
         (only-in crypto/private/common/common
                  shrink-bytes))
(require (only-in file/sha1
                  hex-string->bytes))

(crypto-factories libcrypto-factory)

(define (read-values path)
  (let* ([lines (file->lines path)]

         [n-line (list-ref lines 1)]
         [e-line (list-ref lines 4)]
         [m-line (list-ref lines 7)]

         [n (string->number n-line 10)]
         [e (string->number e-line 10)]
         [m (hex-string->bytes m-line)])
    (cons (cons n e) m)))

(define (rsa-params->pub-key params)
  (datum->pk-key (list 'rsa 'public (car params) (cdr params))
                 'rkt-public))

(define (libcrypto-pub-key-decrypt evp buf pad)
  (define ctx (EVP_PKEY_CTX_new evp))
  (EVP_PKEY_decrypt_init ctx)
  (define outlen (EVP_PKEY_decrypt ctx #f 0 buf (bytes-length buf)))
  (define outbuf (make-bytes outlen))
  (define outlen2 (EVP_PKEY_decrypt ctx outbuf outlen buf (bytes-length buf)))
  (EVP_PKEY_CTX_free ctx)
  (shrink-bytes outbuf outlen2))

(define (rsa-pub-key-decrypt pk buf #:pad [pad #f])
  (let ([evp (get-field evp pk)])
    (libcrypto-pub-key-decrypt evp buf pad)))

(define (main)
  (let* ([values (read-values "msg.txt")]
         [key-params (car values)]
         [msg (cdr values)]

         [pub-key (rsa-params->pub-key key-params)]
         [der-data (pk-key->datum pub-key 'SubjectPublicKeyInfo)]
         #;[plaintext (rsa-pub-key-decrypt pub-key msg)])
    (displayln der-data)))

(main)
