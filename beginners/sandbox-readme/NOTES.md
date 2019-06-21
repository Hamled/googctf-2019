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