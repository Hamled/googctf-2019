# Notes

I was given some files and a link to a remote service, as is typical of a pwn challenge.

`file` output for the two files:
* `bof` - `ELF 32-bit LSB executable, MIPS, MIPS32 rel2 version 1 (SYSV), statically linked, for GNU/Linux 3.2.0, BuildID[sha1]=a31c48679f10dc6945e7b5e3a88b979bebe752e3, not stripped`
* `console.c` - `C source, ASCII text`

So, this is a MIPS executable. Hopefully I won't have to go to the trouble of actually running it... but in my previous attempts to solve pwn challenges I've often found that useful when fiddling with the exact values to use in the exploit input or shellcode.

The `console.c` file appears to be the code for the program I connect to on the remote service -- not the `bof` program. The message output when you first connect to the console program indicates that crashing the service is sufficient for it to print the flag (and a second is available for a real buffer overflow attack).

I connected to the remote service and tried the usual trick for crashing (a whole lot of A's) but nothing doing. Time to analyze it with r2. Looks like the input is put at `sp+0x10` and return pointer is at `sp+0x124` so my input string needs to be 0x114 + 4 (280) characters long to overwrite the return pointer and trigger a crash.

Trying it, that worked. I was provided the first flag:
```
CTF{Why_does_cauliflower_threaten_us}
```
