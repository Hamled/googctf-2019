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

One thing I didn't mention earlier, is that I had examined the resulting code after transforming it from the emoji version. I got a sense of what each block was doing -- specifically, it was loading a sequence of integers onto the stack and then cycling through them, doing an xor operation and printing out the result.

The interesting thing, after examining the xor operations, was the value being xor'd with the number on the stack. It was not the same value each time, like a very simple key, nor was it repeating.

Instead, it appeared to be following a specific pattern: 3, 5, 7, 11, 101, 131, 151, 181, ... Luckily there's a website which can help identify specific sequences of integers, [the on-line encyclopedia of integer sequences](https://oeis.org/). Putting just the first six values into there, it found the sequence right away -- the palindromic primes.

This probably explained why the program is taking so long, rather than have this sequence encoded into the data it was likely calculating primes at run-time and checking them for palindrome...ism? palindromity? Whatever.

Thankfully I can speed the process along because I can get a long list of them online and run through the xor process much quicker.

I put all of the primes I found online (118) into a text file, and each value from the "ciphertext" into another text file. I wrote a simple Python script to read them in and xor each of them together, but quickly ran into some trouble.

```python
def decipher(primes, ciphertext, debug=True):
  plaintext = ''
  for i in range(0, min(len(ciphertext), len(primes))):
    p, t = primes[i], ciphertext[i]
    x = p ^ t
    c = ''
    try:
      c = chr(x)
    except ValueError:
      pass
    plaintext += c
    
    if debug:
      print("%d ^ %d = %d (%s)" % (p, t, x, c))
  
  print(plaintext)
```

It appears there's as a jump between each of the the three sections, where a certain number of primes is skipped. My guess is that's what the final number in each block of integers loaded onto the stack is for. At least for the second block I can identify the first prime it uses, because I can reliably guess what the next character should be (the string so far ends with "web.ctfco" so I know it should be followed by m). This allows me to remove the unused prime entries from my text file and continue on... until I hit the next gap.

Okay, that was only enough to get the original URL from before. The remainder of any path component (assuming there is one, and it's not just a red-herring) is in the last block, which has significantly larger (two factors) values. This means I'll need to find even more primes, since my list of primes is running out. I also need to write some code that tries a bunch of primes until it finds one which xor's with 9,916,239 to create a valid character.

I found [a page with seven digit primes]() (so far all of the largish primes have been the same number of digits as the value they're xor'd with so this is a good place to start). The page also includes a program to find those primes, so if this list doesn't include the ones I need I can run that program to generate more (hopefully it doesn't take too long...)

Okay that worked well, but I still don't have enough primes. I have enough to probably guess the remainder of the URL (right now I have "http://emoji-t0anaxnr3nacpt4na.web.ctfcompetition.com/humans_and_caulif" which probably ends with "lower", but just in case I should finish the primes list.)

This list now is 9 digit primes, and I was able to find a page from the same website (perhaps they're automatically generated) with the list of those. Judging by the values in the program, and how up until now all of the primes have been numerically very similar (I suppose they must be to zero out any high bits leaving a number < 256), I should only need to test the list of primes between 100,000,000 and 110,000,000.

Turns out it was the first 15 9-digit primes, and adding those to the list and re-running my decipher function resulted in the following URL: http://emoji-t0anaxnr3nacpt4na.web.ctfcompetition.com/humans_and_cauliflowers_network/

Browsing around on that site, I found the flag in an image file:
```
CTF{Peace_from_Cauli!}
```

### Side note
The flavor text here indicates to me that maybe the way to access the Admin panel for the gov-xss challenge is to find a persisted HTTP cookie within the NTFS archive from the family-computer challenge.
