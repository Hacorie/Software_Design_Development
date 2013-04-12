#!/usr/bin/rdmd

import std.stdio, std.string, std.conv;

string[string] read_fasta_file(string filename)
{
    string key;
    string[string] key2val;

    auto infile = File(filename, "r");
    foreach (line; infile.byLine())
    {
        if (line[0..1] == ">")
        {
            // key = to!(string)(line[1..$]);
            key = line[1..$].idup;
            key2val[key] = "";
        }
        else
        {
            key2val[key] ~= line;  // nl stripped by byLine
        }
    }
    infile.close();
    return key2val;
}

void main(string[] argv)
{
    string cid;
    string start, stop;
    int[string] starts, stops;
    string[string] cid2seq;

    cid2seq = read_fasta_file("cid_seq_buchnera.fasta");

    auto infile = File("8_gid_fid_loc_func_buchnera.txt","r");
    foreach (line; infile.byLine())
    {
        if (std.string.indexOf(line,",") > 0)
            continue;
        auto sline = std.string.split(line,"\t");  // gid fid loc func
        auto cid_locStartAndLen = std.string.split(sline[2],"_");  // unused_line_to_loc loc
        cid = cid_locStartAndLen[0].idup;
        if (std.string.indexOf(cid_locStartAndLen[1],"+") > 0)
        {
            auto locStartAndLen = cid_locStartAndLen[1].split("+");
            auto locStart = to!(int)(locStartAndLen[0]);
            auto locLen = to!(int)(locStartAndLen[1]);
            start = cid2seq[cid][locStart-1..locStart+2];
            if (start ! in starts)
            {
                starts[start] = 1;
            }
            else
            {
                starts[start]++;
            }
            auto locEnd = locStart + locLen - 4;  // account for start at 1 also
            stop = cid2seq[cid][locEnd..locEnd+3];
            if (stop ! in stops)
            {
                stops[stop] = 1;
            }
            else
            {
                stops[stop]++;
            }
        }
        else
        {
            //  handle - strand in same basic way
        }
    }
    writeln(starts);
    writeln(stops);
}
