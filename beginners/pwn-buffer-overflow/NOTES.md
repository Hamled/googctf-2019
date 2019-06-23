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

Actually, reviewing the code some more, it appears to trigger the flag printing function if the value at `fp+0x18` is overwritten. All this tells me is that I really don't understand the stack structure or register purposes on MIPS...

Okay after reviewing a bit of documentation about MIPS (seems very popular with university courses...) it looks like `$sp` and `$fp` work how I kind of assumed they did, same as `SP` and `BP` on x86. Reviewing the `main` function a bit more closely, it seems that the stack frame is 0x128 bytes. The return address is stored in the top 4 bytes, followed by the previous frame pointer. So maybe I only need 0x110 + 4 (276) bytes to trigger a crash...

No, it still crashed. Doing a bit of manual testing, it appears to not crash if I send 264 (0x108) characters. It turns out I was reading the assembly wrong, and the string was not being placd at `sp+0x10` but instead at `fp+0x1c`, which when added to 264 gives 0x124, meaning 264 characters would write up to, but not overwrite the return address stored on the stack.

I was able to confirm control over the return address with the following command:
```
printf "run\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\x40\x08\x40\x00\x0A" | netcat buffer-overflow.ctfcompetition.com 1337
```

Now I need to find some functionality that is exploitable. There are a lot of functions in this binary (it looks like libc and possibly other stuff are statically linked).

Actually, it looks like I might be able to just jump onto the stack and execute some shellcode, specifically instructions to overwrite the "flag1" string in memory and then return into the `local_flag` function (which prints the file named by that string). Time to debug the binary in QEMU (as the console program does) to see if I get a consistent stack address.

When trying to get my exploit working to run locally under QEMU, I found out that I was actually never controlling the return address as I thought I had been. It looks like instead I was triggering the crash handler, called `write_out` which prints the `flag0` file instead of `flag1`. This means it should be sufficient to return into the `local_flag` function, without modifying anything on in the data segment or writing shellcode to execute on the stack.

However, I still don't have a clear sense of what exploit input I need to craft. Time to get GDB to work with my QEMU for MIPS.

Well... that took a long time. I'm glad I didn't give up, though. All my attempts to do actual debugging on the program through QEMU were for naught (despite a significant investment of time just building the static QEMU binaries and gdb-multiarch). I'll need to keep working on how to get that setup properly -- it seems like a known issue with radare2 not being able to rebase its analysis data, and QEMU loading the MIPS binary at a different location on each run due to ASLR. Of course, perhaps I'm just debugging QEMU itself? Even using QEMU's GDB stub and connecting remotely didn't work, though.

Anyways, I fell back to good ol' `strace` (specifically `qemu-mipsel -strace bof`) and it was able to print the `$ip` address when the seg fault was triggered, which allowed me to locate the correct portion of my exploit string to place the new return target.

However, my earlier thought that I could simply return to the `flag_local` function was incorrect, as that caused a seg fault later on in some other part of the code (or maybe I was jumping to the wrong place and didn't realize??). In a fit of desperation, I decided to jump to the exact instruction that started the process of putting the "flag1" string address in a register and calling `print_file`. It turns out this worked. It still crashed, of course, but not before printing out the second flag:
```
CTF{controlled_crash_causes_conditional_correspondence}
```

The final command to trigger this was:
```
printf "run\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\x60\x08\x40\x00\n" | netcat buffer-overflow.ctfcompetition.com 1337
```

So it turns out I did have the correct location to put the address, but my jump/return target was not good for other reasons.
