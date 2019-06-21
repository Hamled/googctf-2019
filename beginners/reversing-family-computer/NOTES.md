# Notes

Unzipped the archive, found two files:
* `note.txt` - text doc with advice for macOS users
* `family.ntfs` - DOS/MBR boot sector, code offset 0x52+2, OEM-ID "NTFS    ", sectors/cluster 8, Media descriptor 0xf8, sectors/track 0, dos < 4.0 BootSector (0x80), FAT (1Y bit by descriptor); NTFS, sectors 51199, $MFT start cluster 4, $MFTMirror start cluster 3199, bytes/RecordSegment 2^(-1*246), clusters/index block 1, serial number 072643f694104cb6f

I tried to mount the NTFS file, but mount said "unknown filesystem type 'ntfs'", so I'll have to get a module for that, maybe a FUSE plugin?
```bash
yay -S ntfs-3g
mkdir mnt/
sudo mount -o ro family.ntfs mnt/
```

Now I need to search through this filesystem for something interesting? Lets start in the `Users` directory...

There's a file, `Users\Family\Documents\credentials.txt` which has the following text:
```
I keep pictures of my credentials in extended attributes.
```

So probably I'll need to figure out how to see extended attributes from the NTFS volume...
Looks like, with `ntfs-3g` I can use `getfattr -d` to dump all extended attributes for a particular path:
```
getfattr -d mnt/Users/Family/Documents/credentials.txt
# file: mnt/Users/Family/Documents/credentials.txt
user.FILE0=<long base64 encoded data, presumably an image>
```

I then dumped the specific attribute to a file (turns out this does it as binary, rather than base64):
```
getfattr -n user.FILE0 --only-values mnt/Users/Family/Documents/credentials.txt > credentials.b64
```

`file` said it was a PNG image, so I renamed to `credentials.png` and opened in Firefox to find the flag:
```
```
