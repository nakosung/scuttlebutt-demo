[Scuttlebutt](https://github.com/dominictarr/scuttlebutt) demo
==

Tiny project to demonstrate what scuttlebutt can offer. 

[Check heroku app](http://scuttlebutt-demo.herokuapp.com)

```
server -l [tcp-port] -c [tcp-port] -w [http-port]
```

| Option | desc |
| ------ | --- |
| -l | listens at |
| -c | connects to |
| -w | host web server |

How to run
--

```
grunt
```

Test configuration
--

```
server -w 1337 -l 4000 # http-server : 1337, net-server : 4000
server -l 4001 -c 4000 # relay between 4000 and 4001
server -w 1338 -c 4001 # http-server : 1338, connecting to 4001
```

There are three node running, all of the states are *eventually* synced.

