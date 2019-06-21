# Notes

The challenge includes a link to a website. Based on the name of the challenge (as determined from the fragment path when linking to that specific challenge) this probably involves XSS.

There is a text area on the page which will POST to the server. This would be an obvious avenue for possible XSS vulnerability.

However, I haven't seen anything to indicate that that the content from that text area sent to the server is actually displayed anywhere. Submitting the form gives back a response with a static message "Your post was submitted for review. Administator will take a look shortly."

There is an "Admin" link which goes to the `/admin` path, but it returns a `303 See Other` response with an empty body and the location being the root path.

I can browse the directories under `/static` which includes the CSS file and two images displayed on the root page, but no other files are present. There is no `static/images/flag.png` or (or `.jpg`).

I might need to come back to this.
