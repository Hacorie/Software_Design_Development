#!/usr/bin/env python

infile = file("8_gid_fid_loc_func_buchnera.txt")

totalLen = 0
numLines = 0
minLen = 999999
maxLen = 0
for line in infile:
    if "," in line:
        continue
    # print line
    (gid,fid,loc,fun) = line.split("\t")
    if "+" in loc:
        (uu,intLen) = loc.split("+")
    else:
        (uu,intLen) = loc.split("-")
    intLen = int(intLen)
    totalLen += intLen
    numLines += 1
    if intLen < minLen:
        minLen = intLen
    if intLen > maxLen:
        maxLen = intLen

print totalLen / numLines, minLen, maxLen
