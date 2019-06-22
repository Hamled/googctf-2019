# Notes

This one has no files, just the host and port name. Time to connect with `netcat`...

I'm presented with a command prompt, which seems pretty minimal. `ls` shows to `.flag` files in the current directory. The `cat` command is not there, however. The `help` command says to get additional help using `man`, but that command (which allows arbitrary file reading) is also not available.

The `split` command is available, which on my Archlinux distro has the `-n` option which, in some configurations, allows outputting to stdout. Unfortunately, that does not appear to be the case for the BusyBox version.

I saw the `cpio` command is available, which does file compression. With enough futzing about, I figured out that I could get it to create an archive and print out the file contents uncompressed (I'm still not quite sure what the command is trying to do, sometime to sort out later):
```
cpio -o -H newc
```
(and then type `README.flag` in the terminal. Apparently this shell doesn't support piping, so you can't use `echo` to get a one-liner.)

The flag is:
```
CTF{4ll_D474_5h4ll_B3_Fr33}
```

Later after talking to some people on the John Hammond discord, I got a hint about using `env` to run the `busybox` program, which I hadn't even bothered to try originally. It turns out `busybox` would give me a shell, or something equivalent to it, but it's magically disabled. Except if you run it through `env`.

With that knowledge I was able to set the read permissions on `ORME.flag` and print out the second flag from this challenge:
```
CTF{Th3r3_1s_4lw4y5_4N07h3r_W4y}
```
