#!/bin/sh
wget -q -O - http://www.cpubenchmark.net/singleThread.html | ./parse.pl > s
wget -q -O - http://www.cpubenchmark.net/mid_range_cpus.html | ./parse.pl > m
wget -q -O - http://www.cpubenchmark.net/high_end_cpus.html | ./parse.pl >> m
cp index.html bak.`date +%s`
./cpu_graph.rb s m > index.html
rm s m
