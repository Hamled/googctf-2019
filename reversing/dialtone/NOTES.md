# Notes

I was given a 64-bit ELF executable. `file` output is:
```
a.out: ELF 64-bit LSB pie executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, for GNU/Linux 2.6.32, BuildID[sha1]=9cc759438a1edd4207f7d6b9b623985415589928, not stripped
```

I started taking a look at it in radare2. It was using the PulseAudio simple interface. To more easily browse through the code I also loaded it up in Ghidra.

Ghidra helped a lot because it's easy enough to start defining structures and renaming variables in the decompiled output. Going through this a bit I was able to determine some of what the program is doing:

1. Setup libpulse using the simple API
1. In a loop:
    1. Record 32kb of audio into a buffer on the stack
    1. Do ??? with the buffer
    1. Check the results, print failure and exit(1)
1. Print success and exit(0)
