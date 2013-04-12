#!/bin/bash

time ./p1.d $1 > p1out.txt
echo "p1 complete - p1out.txt created"

time ./p2.d $2 $1 > p2KnownProtein
echo "p2 Completed for Known Genes -- p2KnownProtein created"

time ./p2.d p1out.txt $1 > p2UnknownProtein
echo "p2 Completed for Hypo Genes -- p2UnknownProtein created"

time ./p3.d p2KnownProtein p2UnknownProtein -v > p3matches
echo "p3 Completed -- p3matches created"

time ./p4.d $2 p1out.txt p3matches > p4.out
echo "p4 Completed -- p4.out created"
