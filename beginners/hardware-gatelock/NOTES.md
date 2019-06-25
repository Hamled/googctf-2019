# Notes

I unzipped the download to find a single file:
* `challenge.tgz` - `POSIX tar archive (GNU) (gzip compressed data, from Unix)`

Extracting that compressed archive I got a directory named `beginner` with several files:
```
auth.sqlite:          SQLite 3.x database, last written using SQLite version 3028000
env_meta.txt:         ASCII text, with very long lines
force_loaded.txt:     ASCII text, with no line terminators
ipban.txt:            empty
map_meta.txt:         ASCII text
map.sqlite:           SQLite 3.x database, last written using SQLite version 3028000
mesecon_actionqueue:  ASCII text, with no line terminators
players.sqlite:       SQLite 3.x database, last written using SQLite version 3028000
world.mt:             ASCII text
schems:               directory
schems/challenge.mts: data
```

So right off the bat, this appears to be some code related to a game. The fact that there's a `players.sqlite` file, and terms like `world` and `map` give me that impression, at least. The `ipban.txt` file also indicates its likely part of the server component of an online game.

I looked in `map_meta.txt` first and saw some configuration data. The data was... "complete" or "deep" enough to make me think this perhaps wasn't made up entirely for the CTF. A quick google search for one of the filenames confirmed this. I chose to search for `mesecon_actionqueue` because that seemed most unique vs. say `auth.sqlite`.

It turns out these files are related to an open source voxel game in the vein of Infiniminer or Minecraft, called [Minetest](https://www.minetest.net/). I checked out the file list [the relevant package](https://www.archlinux.org/packages/community/x86_64/minetest-common/) for (also the `minetest-server` package) in Arch Linux's repository but none of them contained the files from this challenge.

Some additional investigation in the [Minetest repo](https://github.com/minetest/minetest/) confirmed that these are basically generated per-world when you run the game (possibly just the server). Notably absent however, was the file `mesecon_actionqueue`. Searching more on Google I was able to determine that this file is actually related to a specific Minetest mod, [Mesecons](https://github.com/minetest-mods/mesecons).

The description for that mod talks about the "Mesecons" objects that the mod adds to the game being used to create digital circuitry. My guess is that the world database I've been given has some of these mesecons configured already and that's circuit represents the door lock from the challenge's flavor text.

There's probably a bit sequence to represent the key, which will be the flag. In fact, this is probably a very small-scale implementation of how some card-based digital door locks work. Hopefully with less cryptography to crack.

Another thing I wanted to investigate was the `challenge.mts` file. There are two reasons for this. First, it's the only file that `file` wasn't able to identify, it's just listed as "data", and second the name "challenge" is unlikely to be a standard name.

Some searching through the Minetest repo for the `mts` extension helped me discover that this file is a "Schematic" in Minetest parlance (thus the `schems/` directory location). Because this is open source and seems to be developed with pretty good standards, the creators have helpfully supplied documentation about the [Schematic file format](https://github.com/minetest/minetest/blob/b298b0339c79db7f5b3873e73ff9ea0130f05a8a/src/mapgen/mg_schematic.h#L36).

Coming to an understanding of what a Schematic is (it might be called a "prefab" in Unity and some other game editors, for example), it seems verly likely that the digital circuitry composed of Mesecons (I noticed that name when viewing the file in a hex editor) is defined within here, so it can easily be placed as a single package into a game world.

Minetest is a C++ core for the game engine and data loading, with Lua being used for scripting and probably implementing most game logic. To this end, the Schematic file also has a Lua form, and I think my first task will be figuring out if I can convert the binary file to a Lua table which should be easier to browse through (even though I'm not well versed with Lua).

Okay, I didn't find any standalone tools that seemed like they would really help me out in this area. There are a few mods for working with Schematics, but none really seem focused on the file format, which makes sense. I think at this point my best path forward is to just install the game and try to load up the world.

I installed the game with `pacman -S minetest` and loaded it up to create a test world, so I could find the path where world data is stored (`~/.minetest/worlds` on Linux). I then copied the provided world directory there, started the game and loaded into it. It's a very minimal map with a bunch of red squiggly blocks and a cage that they connect to. I assume those are the Mesecons, and the cage unlocking represents the gate lock whose key I must reverse engineer. First though, I'll need to install the Mesecons mod.

With the Mesecons mod installed and enabled for the "beginner" world, I was able to load it up again and see that the blocks had transformed into several distinct types which much more resembled a circuit. I also turned on flying mode in the settings so that I could get a nice aerial overview, much like a circuit diagram.

There appear to be some blocks which function as standard logic gates (and, or, not) and the rest are the circuits. Some circuit blocks are bright blue indicating that they're currently on, and others are darkened because they're off. Finally, at the far edge of the map, all of the circuits ultimately stem from a set of 20 switches, which will be the bits I need to figure out for unlocking the gate. There's one final switch connecting to the last logic gate before the circuit goes to the gate lock, presumably once I've figured out the key that switch represents the open/close action.

It has become dark (in the game, and in real life) so I will wait before taking screenshots of the overall circuit layout and specific sections (viewed far enough away to see the whole circuit, the logic gates cannot be distinguished).
