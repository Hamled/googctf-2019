# Notes

Another zip archive, I decompressed it to find:
* `README.pdf` - PDF document, version 1.5
* `init_sat` - 64-bit ELF executable built with Go(I think?)

After reading the PDF (more flavor text) I analyzed the binary in R2. Because it's a Go binary, there were lots of functions, so I just started with `sym.main.main`.

Eventually that function calls to `sym.main.connectToSat` which seems like the "correct" path. In there, just by browsing in visual mode, I found a string reference to a host and port: `satellite.ctfcompetition.com:1337`.

I connected to that machine with:
```bash
netcat satellite.ctfcompetition.com 1337
```

and it provided a prompt with three options:
```
Welcome. Enter (a) to display config data, (b) to erase all data or (c) to disconnect
```

Choosing the first option, `a`, I received the following text back, which contained the flag:
```
Username: brewtoot password: CTF{4efcc72090af28fd33a2118985541f92e793477f}	166.00 IS-19 2019/05/09 00:00:00	Swath 640km	Revisit capacity twice daily, anywhere Resolution panchromatic: 30cm multispectral: 1.2m	Daily acquisition capacity: 220,000km²	Remaining config data written to: https://docs.google.com/document/d/14eYPluD_pi3824GAFanS29tWdTcKxP_XUxx7e303-3E
```
