cpu_graph
=========

So you're in the market for a CPU, how do you determine the best value
at various price points?  Do you care most about single-threaded performance
or overall multi-core performance?  This scatter plot of CPU price vs
performance has you covered!

I wrote about the features of this on [my blog](http://jcward.com/CPU+Performance+AMD+is+MIA), and you can find a live version of the graph at [jcward.com/cpu_graph](http://jcward.com/cpu_graph)

Data is downloaded from the fabulous
[cpubenchmark.net](http://www.cpubenchmark.net/) - if you're buying a CPU,
please click through one of their referral links to Amazon or Newegg as
thanks for the service they provide.

Usage
=====

`./refresh.sh`

Grabs the data, parses it, and writes `index.html` for your browsing enjoyment.

On the page you can type a comma-separated list of search terms into the box to highlight certain CPUs (e.g. `3770,4770` to search for those CPU families.)

Screenshot
==========

<img src="http://jcward.com/posts/CPU+Performance+AMD+is+MIA/cpu_graph.jpg"/>

Disclaimer
==========

I am not affiliated with cpubenchmark.net, and the code is about the quick and
dirtiest of scripts you can imagine.  I wrote this when I was shopping for a
CPU and am merely publishing it as others may find it useful.  Use at your
own risk - no warranty is given or implied.  Also see the LICENSE file.
