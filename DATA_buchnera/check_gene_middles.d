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
    int numWith = 0, numWithout = 0;
    int[string] fid2cnt;
    int[int] end2cnt;
    string cid, midseq;
    string[string] cid2seq;

    cid2seq = read_fasta_file("cid_seq_buchnera.fasta");

    auto infile = File("8_gid_fid_loc_func_buchnera.txt","r");
    foreach (line; infile.byLine())
    {
        if (std.string.indexOf(line,",") > 0)
            continue;
        auto sline = std.string.split(line,"\t");  // gid fid loc func
        auto cid_locStartAndLen = std.string.split(sline[2],"_");
        cid = cid_locStartAndLen[0].idup;
        if (std.string.indexOf(cid_locStartAndLen[1],"+") > 0)
        {
            auto locStartAndLen = cid_locStartAndLen[1].split("+");
            auto locStart = to!(int)(locStartAndLen[0]);
            auto locLen = to!(int)(locStartAndLen[1]);
            auto locEnd = locStart + locLen;  // just past
            if (locEnd ! in end2cnt)
                end2cnt[locEnd] = 0;
            else
                end2cnt[locEnd]++;
            midseq = cid2seq[cid][locStart+2..locStart+locLen-4];
            auto fid = sline[1].idup;
            fid2cnt[fid] = 0;
            for (int i=0; i < midseq.length-3; i+=3)
            {
                auto tmpseq = midseq[i..i+3];
                if (tmpseq == "atg" || tmpseq == "taa" || tmpseq == "tag" || tmpseq == "tga")
                {
                    // writeln(cid);
                    // writeln(midseq);
                    // writeln(tmpseq);
                    // writefln("%d %d %d",locStart,locLen,i);
                    writefln("%s %s %d %d %d",cid,tmpseq,locStart,locLen,i);
                    // throw new Exception("DONE");
                    fid2cnt[fid]++;
                }
            }
        }
        else
        {
            //  handle - strand in same basic way
        }
    }
    writeln("--------");
    foreach (fid,cnt; fid2cnt)
    {
        if (cnt == 0)
            numWithout++;
        else
        {
            numWith++;
            // writefln("%s %d",fid,cnt);
        }
    }
    writefln("numWith multiple start/stop %d numWithout %d",numWith,numWithout);
    writeln("--------");
    foreach (locend,cnt; fid2cnt)
    {
        if (cnt == 0)
            numWithout++;
        else
        {
            numWith++;
            // writefln("%s %d",locend,cnt);
        }
    }
    writefln("numWith same end %d numWithout %d",numWith,numWithout);
}
