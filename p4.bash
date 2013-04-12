#!/bin/bash

./p1.d $1 > p1out.txt

./p2.d $2 $1 > p2KnownProtein
./p2.d p1out.txt $1 > p2UnknownProtein

./p3.d p2KnownProtein p2UnknownProtein -v > p3matches

./p4.d $2 p1out.txt p3matches > noms.txt
