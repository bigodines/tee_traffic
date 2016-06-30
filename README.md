tee_traffic
=====

What
----
Replicates TCP traffic to an aditional server and discards its response.


```
                                    ______ [ production ] ---------> response
                                  /
---- request --> [ tee traffic ] <
                                  \ ______ [ test server ]
```

Why
---
Test a new version of your app with production traffic, collect metrics and fix errors before your users face them.


Build
-----

    $ rebar3 compile
