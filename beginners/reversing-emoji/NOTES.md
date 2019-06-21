# Notes

Unzipped the archive and found the following files:
* `program` - UTF-8 Unicode text
* `vm.py` - Python script, UTF-8 Unicode text executable

My Emacs configuration doesn't seem to like the emoji characters in the `program` file... Firefox is okay with them, though.

At first glance, the Python code in `vm.py` is some kind of interpreter for a language written using emoji characters and digits. Presumably the contents of `program` are the code for this VM, I guess with the flag in it somehow.

Running `python vm.py program` shows that it's starting to print out text, but getting slower as it goes. Maybe I can modify the VM code to speed it up...

Okay, the use of emojis is rather taxing on my mental energy, and various parts of my system are clearly not well set up for displaying them anyways. My first challenge will be to convert the file to non-emoji characters for each operation.

#### OPERATIONS:
| Operation    | Emoji bytes | ASCII byte |
|--------------|-------------|------------|
| add          | F0 9F 8D A1 | +          |
| clone        | F0 9F A4 A1 | c          |
| divide       | F0 9F 93 90 | /          |
| if_zero      | F0 9F 98 B2 | ?          |
| if_not_zero  | F0 9F 98 84 | !          |
| jump_to      | F0 9F 8F 80 | j          |
| load         | F0 9F 9A 9B | l          |
| modulo       | F0 9F 93 AC | %          |
| multiply     | E2 AD 90    | *          |
| pop          | F0 9F 8D BF | >          |
| pop_out      | F0 9F 93 A4 | o          |
| print_top    | F0 9F 8E A4 | p          |
| push         | F0 9F 93 A5 | <          |
| sub          | F0 9F 94 AA | -          |
| xor          | F0 9F 8C 93 | ^          |
| jump_top     | E2 9B B0    | @          |
| exit         | E2 8C 9B    | $          |

#### Other values:
| Value        | Emoji bytes | ASCII byte |
|--------------+-------------+------------|
| accumulator1 | F0 9F A5 87 | [          |
| accumulator2 | F0 9F A5 88 | ]          |
| number stop  | E2 9C 8B    | #          |
| if end       | F0 9F 98 90 | &          |
| marker goto  | F0 9F 92 B0 | =          |
| market label | F0 9F 96 8B | :          |

#### Markers:
| Marker     | Emoji bytes                                                 | ASCII byte |
| 💠🔶🎌🚩🏁 | F0 9F 92 A0 F0 9F 94 B6 F0 9F 8E 8C F0 9F 9A A9 F0 9F 8F 81 | mrk01      |
| 💠🏁🎌🔶🚩 | F0 9F 92 A0 F0 9F 8F 81 F0 9F 8E 8C F0 9F 94 B6 F0 9F 9A A9 | mrk02      |
| 🚩💠🎌🔶🏁 | F0 9F 9A A9 F0 9F 92 A0 F0 9F 8E 8C F0 9F 94 B6 F0 9F 8F 81 | mrk03      |
| 🏁🚩🎌💠🔶 | F0 9F 8F 81 F0 9F 9A A9 F0 9F 8E 8C F0 9F 92 A0 F0 9F 94 B6 | mrk04      |
| 💠🎌🏁🚩🔶 | F0 9F 92 A0 F0 9F 8E 8C F0 9F 8F 81 F0 9F 9A A9 F0 9F 94 B6 | mrk05      |
| 🔶🎌🚩💠🏁 | F0 9F 94 B6 F0 9F 8E 8C F0 9F 9A A9 F0 9F 92 A0 F0 9F 8F 81 | mrk06      |
| 🎌🏁🚩🔶💠 | F0 9F 8E 8C F0 9F 8F 81 F0 9F 9A A9 F0 9F 94 B6 F0 9F 92 A0 | mrk07      |
| 🔶🚩💠🏁🎌 | F0 9F 94 B6 F0 9F 9A A9 F0 9F 92 A0 F0 9F 8F 81 F0 9F 8E 8C | mrk08      |
| 🚩🔶🏁🎌💠 | F0 9F 9A A9 F0 9F 94 B6 F0 9F 8F 81 F0 9F 8E 8C F0 9F 92 A0 | mrk09      |
| 🎌🚩💠🔶🏁 | F0 9F 8E 8C F0 9F 9A A9 F0 9F 92 A0 F0 9F 94 B6 F0 9F 8F 81 | mrk10      |
| 🎌🏁💠🔶🚩 | F0 9F 8E 8C F0 9F 8F 81 F0 9F 92 A0 F0 9F 94 B6 F0 9F 9A A9 | mrk11      |
| 🏁💠🔶🚩🎌 | F0 9F 8F 81 F0 9F 92 A0 F0 9F 94 B6 F0 9F 9A A9 F0 9F 8E 8C | mrk12      |

That took a lot longer than I hoped, but the code is definitely easier to look at and work with now.

Took a break to get some lunch, but I decided to leave the program running, since it might have outputted more useful stuff (I also instrumented it a bit to display the XOR operations and their results). This is how far it got by the time I got back:
```
http://emoji-t0anaxnr3nacpt4na.we
```

Given the earlier challenge (work computer) which had a website to visit, I completed the domain name to get the url http://emoji-t0anaxnr3nacpt4na.web.ctfcompetition.com/. Visiting that URL however, didn't lead me to anything useful.

### Side note
The flavor text here indicates to me that maybe the way to access the Admin panel for the gov-xss challenge is to find a persisted HTTP cookie within the NTFS archive from the family-computer challenge.
