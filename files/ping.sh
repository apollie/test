#!/bin/sh
index=$(curl -s http://169.254.169.254/latest/meta-data/tags/instance/index)
total=$(curl -s http://169.254.169.254/latest/meta-data/tags/instance/count)
name=$(curl -s http://169.254.169.254/latest/meta-data/tags/instance/Name)
zone="awesomeness-zone.com"

if [ "$index" -lt "$total" ]; then
        i=$((index+1))
else
        i=1
fi

x=$(echo $name | sed "s/.$/$i/g")
ping -c3 $x.$zone > ping.results