#!/usr/bin/env python

def read_fasta_file(filename):
    key2val = {}
    filein = file(filename, "r")
    for line in filein:
        if line[0] == ">":
            key = line.rstrip()[1:]
            key2val[key] = ""
        else:
            key2val[key] += line.rstrip()
    filein.close()
    return key2val


cid2seq = read_fasta_file("cid_seq_buchnera.fasta");
# print cid2seq

print "---- data loaded ----"

starts = {}
stops  = {}
infile = file("8_gid_fid_loc_func_buchnera.txt")
for line in infile:
    if "," in line:
        continue
    (gid,fid,loc,fun) = line.split("\t")
    (cid,locStartAndLen) = loc.split("_")
    if "+" in locStartAndLen:
        strand = "+"
        (locStart,locLen) = locStartAndLen.split("+")
        locStart,locLen = int(locStart),int(locLen)
        start = cid2seq[cid][locStart-1:locStart+2]
        if start not in starts:
            starts[start] = 1
        else:
            starts[start] += 1
        locEnd = locStart + locLen - 4  ## account for start at 1 also
        stop = cid2seq[cid][locEnd:locEnd+3]
        if stop not in stops:
            stops[stop] = 1
        else:
            stops[stop] += 1
    else:
        strand = "-"
        (locStart,locLen) = locStartAndLen.split("-")
        ## handle - strand here (reverse the string and invert values)
print starts
print stops
