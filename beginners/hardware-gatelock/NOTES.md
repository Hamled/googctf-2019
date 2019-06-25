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
