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

Okay that may have worked, but it's hard to tell because I can't easily turn the resulting huge integer into a sequence of bytes. Instead, I'm going to try Racket's crypto collection, which has a simple function `datum->pk-key` for converting a list `(list 'rsa 'public n e)` into a public key structure to pass into other parts of the public key crypto collection to decrypt a byte string.

So after writing out the code, taking a break for lunch and helping various people with earlier beginner challenges, I'm back to working on this. It turns out the `datum->pk-key` function does not want a list with `n` and `e` parameters, but instead a byte-string with the raw key info. In all the examples this is something resulting from generating a private key or public key in one of the supported cryptosystems.

Looks like I'm back to square one. I need to manually convert the e and n values into a binary format that is acceptable to one of the cryptosystems like OpenSSL. Previously I've only converted between existing key formats, not had to generate one from scratch with the un-encoded values...

Further examination of the crypto collection code shows that when the datum provided to `datum->pk-key` is `'rkt-public` it tries to decode the final parameter as a bye-string which is in the format specified by ASN.1 SubjectPublicKeyInfo (it does this using OpenSSL's `d2i_PUBKEY` function). Looks like that's the structure I need to learn about. 

After a bit more testing, I think I've figured out that actually I was on the correct path before and I was just missing some obvious stuff because I hadn't followed the introductory text in the crypto collection's documentation.

I was going to generate a private key the normal way, pull out the public key bit, and then use the asn1 collection's methods to decode it and see what structure it had, then duplicate that and encode it using the same library. However, in doing so I noticed that the datum form of the public key I got from the generated private key.... was exactly the shape I expected.

Turns out I just needed to directly require the libcrypto system and setup its factory in the list of crypto-factories. My next challenge is that the `pk-decrypt` function is defined to require a private key, even though it should be possible to use it with a public key. Thankfully, I can just substitute the code it uses, since the issue is a contract violation.

...Okay that caused a segfault. Perhaps the OpenSSL functions `pk-decrypt` is connected to is actually private key specific... I'm *so* sure you can decrypt with a public key... like the public/private distinction is purely in how they should be treated by people, not in the math. In fact, signing and verifying should work by encrypting w/ private and decrypting w/ public...

Okay fuck it. I spent over an hour just trying to get some additional FFI calls to OpenSSL to work so I could use Racket to do the actual decryption. No luck, and I don't want to waste more time debugging it. So I used the crypto library to output the public key in DER form and then use the `openssl` command to convert it to PEM.

So it was very easy to get the public key as a PEM file, but that doesn't help me one bit because there's no software out there designed to attempt decryption with a standard public key file. Everything is written specifically for decrypting with a private key file. It still seems like this should be doable, but I'm starting to think that maybe I'm just going down the wrong track.

Someone mentioned that maybe the key is actually weak and you can factor it somehow, and we can get the private key from that. I really hope that's not what I have to do because that sounds like it would be slow. I'm going to take one last stab at getting something to to attempt decryption using only the public key data, and if that doesn't go I'll switch over to factoring. I'm going to look for a pure Python implementation of RSA because I might be able to fudge it to take the public key components and use n instead of d when decrypting.

Okay, I finally decided to look at the PDF file. Of course that's where the clear hint to just do factoring was. Curse my over-eager racing towards a solution....

So after talking wih some friends and puzzling over the math in section 3 of the PDF I was led to two conclusions (largely by the two friends helping, I'm pretty bad at math):
* The two primes are going to be close-ish to sqrt(n)
* Their two lengths in decimal digits are going to be 6 apart of less.

I spent some time looking for such primes (sqrt(n) is 309 digits** online, but only found a few and none were correct. I think I need to just do my own searching for them. I've downloaded the primesieve application to help with that.

Okay, so primesieve only works to search for primes < 2**64, too bad. I ended up getting a hint from Gynvael Coldwind (a true inspiration) in the John Hammond Discord channel, he mentioned "Fermat's factorization method". Turns out that's a useful speedup to normal integer factorization methods that applies when the two factors are rather close to each other (less than sqrt(n) apart) -- exactly our case.

Some more searching online and I found this incredibly helpful page: https://wiremask.eu/articles/fermats-prime-numbers-factorization/ which talks about using Fermat's method to factor RSA keys. It even specifically mentions this being used in certain CTF challenges, heh.

Long story short, I spent a very small amount of time transcribing the Python code into Racket since I wanted more practice with it. That went well, and I do like the Racket code... but when I ran it on their example RSA modulus number, it took about two minutes. I was worried it might end up being unacceptably slow because the number in this challenge is twice as many digits.

Being the software developer that I am, I noticed that their Python code was using gmpy2 to hopefully speed up the math calculations while maintaining arbitrary precision. I decided to try a version of my Racket coding using their GMP wrapper collection. I also built the C code that they provided for good measure.

It turns out somehow my Racket w/ GMP code is about slower 30% than the pure Racket code, for their example RSA value. Additionally, when I tried a worst-case value (2345678917, which is prime) from Wikipedia it took more than 10 minutes and then Racket segfaulted.

So, I guess that option is out. I ended up timing the Python and C implementations provided from the website as well, and the C version was anywhere from 7.5 - 10 times faster for my small set of test cases. I chose to go with the C version for calculating the actual factors with the challenge's 2048-bit RSA public key modulus.

Alright so the C version has been calculating away for nearly an hour and I'm starting to think I'll need a better solution. Time to practice my multithreading skills. Honestly, based on the algorithm this should fall into the category of "embarassingly parallel" problems. Each check for a valid `a` value can be done independently, and it's a simple process of incrementing `a` on each loop, so we can just split that up by changing the step number and starting each thread off on its own offset.

The real difficulty is re-leaning pthreads. Of course, I'm going to leave my original version running in the background while I do this, because I didn't bother to code in a way to persist the progress, and hey maybe it'll finish soon. I also didn't code in any progress meter.

I added some code to indicate how quickly the C program was calculating new possible factors, and even at one point an attempt to estimate the total time remaining. That bit was pointless because the idea with using Fermat's method here is that it doesn't take nearly as long as the total time it *could* take, because the prime factors are very close to each other (and thus close to the starting point, sqrt(n)).

Even still, the fact that I was only calculating 35 million factor combinations per second (single-threaded) and it had gone for multiple hours started to make me worry that either I was going down the wrong path with factoring at all, or I needed to come up with a much better strategy for doing it.
