# Notes

I was given a URL to visit for this challenge. The page has a form with two fields, one for latitutde and one for longitude.

Playing around with it a bit, it looks like the server takes these values, calculates a distance from the original values, and then outputs some text which tells you if you're closer or farther away from the goal location.

The rub is that you are not allowed to move too quickly. It seems like your velocity is calculated based on the actual time between requests to the server.

My challenge, then, is to create a script which automatically navigates along two different axes, while obeying the server's "speed limit".

Important things:
* I need to make GET requests, not POST requests. This means I need to encode the parameters into the query string.
* There are three parameters: `lat`, `lon` and `token`. The first two parameters are the location I wish to travel to, and the last is a token that I was provided from the previous request. It appears to be how state is tracked, such as when my last request was submitted (for calculating velocity).
* If I leave off the token it assumes that I'm making the initial request, and does not calculate any distance but instead presents the form with the initial values.

Because I've been using Ruby more recently than Python, and because I happen to like HTTParty, I'm going to use it for coding this challenge.

I spent a while building the script, and then ran it for quite a long time. And then lost internet connection at my coffee shop. So then I added the feature that I really should have added at first, which persists the various requests I've made into a file, and allows me to restart from that file by initializing parameters from the most recent request.

After disconnecting again (I'm thinking maybe the ISP is killing the coffee shop's connection due to the high number of requests... or it's just bad luck), I setup a server on GCP and started my script running on there in tmux. If I disconnect again it should be all good.

I've also added a 1.4x multiplier to the velocity which seems to be around the max I can do without getting speed limit errors. Hopefully this will eventually work...

Finally got to the point where my script was turning around because it overshot. I've updated the script to allow me to set a direction (se/sw/ne/nw). Hopefully I can manually drive it around a bit until we hone in on the specific location.
