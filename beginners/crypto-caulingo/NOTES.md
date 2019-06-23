# Notes

I was given two files:
* `msg.txt` - `ASCII text, with very long lines`
* `project_dc.pdf` - `PDF document, version 1.5`

Looking at the text file, it presents three variables:
* `n` - a very large decimal number (617 digits)
* `e` - the number 65537
* `msg` - a long hex string (512 characters / 256 bytes)

Right off the bat the naming of these variables, and especially the value 65537 for `e` makes me think RSA encryption.

I've done a very simple version of RSA with small primes and small encrypted messages (could fit in a single byte) by hand for a previous CTF, but I don't remember it well enough so I'll need to refresh myself and see if I can quickly load this stuff into some existing RSA code.

I found this implementation of RSA in Python: https://gist.github.com/JonCooperWorks/5314103 which seems like all I should need. A quick review through it makes me think from the variable names that I probably have the components to the public key, and the message itself has been encrypted with a separate private key.

Looking specifically at the `decrypt` function, it seems pretty straight forward to implement along with some code to read values out of the `msg.txt` file.

I tried going through the decryption algorithm once for the first byte (0x50) from the message with the given values of n and e, but the result was a really huge number that wouldn't be possible to convert into a single character:
```
777562824323034043402797711382541545628759022091835438353946712873127050099398776204527370954903717527455599105796953444595899862887371906086502982827617686278253303077044537065002057487844755040136985000464215096859065552990877516455445599020406864194684963544212595947195484388576127449049878551538011370367681317453067685731575495883314849805751602204748174217807413211954446037657535168906239896022056377105150744499411197574369305114000317612407570492799520560642810557656157157378338618789265938130053389321191513743663982857117268548648315509237020761434597655182753230274641355702658213695423200150198179877
```

I also confirmed this in Racket in case somehow I had not used Python properly, but I got the same result. My new plan is to do the decryption proces for the entire msg value, treated as a single integer, and then see if the result can be understood as the bytes of the plaintext...

Okay that may have worked, but it's hard to tell because I can't easily turn the resulting huge integer into a sequence of bytes. Instead, I'm going to try Racket's crypto library, which has a simple function `datum->pk-key` for converting a list `(list 'rsa 'public n e)` into a public key structure to pass into other parts of the public key crypto library to decrypt a byte string.