https://glotto.web.ctfcompetition.com/?src gives the source of the php server code

importantly, `$db->query("SET @lotto = '$winner'");` puts the next winner in the database, and the the code executes a sql query using a string from the query params, which can be used to do a sql injection.

something like this might work:
`https://glotto.web.ctfcompetition.com/?order0=winner%E7%B8%97%27;%20SELECT%20@lotto;/*`

we need to `SELECT @lotto` and display it, then submit that as the code.
this might also be a multi-byte injection thingy.

`openssl_random_pseudo_bytes` is also cryptographically insecure, but I don't think that's a viable attack route here.
