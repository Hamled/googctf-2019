logo.png translates to 

`Welcome to the official site of the association of the people who are blind`

post.js has some logic for translating the english names of cities to a braille encoding that works like:
```
1 4
2 5
3 6
```
with 0 endings for each character.


my first thought was to try some other cities, but 'seattle' and 'mountain view' don't give any results.
the encoding included in post.js supports the 26 english lowercase alphabet, but potentially the server has a larger encoding?
we might be able to encode some kind of sql injection into the braille encoding.

`' OR '1'='1` should be `30030103050235603010` but this just results in "no results". I think it is being escaped, or stored on the server without un-translating it from braille.

putting a multibyte character in the message breaks the server (500):
`縗'`

they make a point of emphasizing `charset=utf-8`

check here next: https://security.stackexchange.com/questions/9908/multibyte-character-exploits-php-mysql
