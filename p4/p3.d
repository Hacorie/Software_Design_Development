#!/usr/bin/rdmd

//Author: Nathan Perry
//Program: SDD p3
//Command Line Args 1->Known Protein Seq.   2->Unknown Protein Seq.
//Description: For each hypo gene, compute 9-mers and compare them to
//      those i nthe first set to determine the best match for 
//      each hypo gene.

import std.stdio, std.string, std.getopt, std.conv;
import std.parallelism, core.thread, core.sync.barrier;
import std.algorithm, std.concurrency, core.sync.mutex;

//global variables

shared string[] [string] k_kmer2fid;
shared string[] [string] k_fid2kmer;

//shared  bool[string][string] h_kmer2fid;
shared string[] [string] h_fid2kmer;


void compute_9mer(string filename, bool type)
                    //out bool[string][string] kmer2fids,
                    //out bool[string][string] fid2kmers)
{
    auto infile = File(filename, "r");//.byLine();
    string fid;
    int i;
    foreach(ref line; infile.byLine())
    {
        if(line[0..1] == ">")
        {
            fid = line[1..$].idup;
        }
        else if(line[0..1] == "#")
        {
            continue;
        }
        else
        {
            for(i = 0; i <= line.length-9; i+=1)
            {
                if(type)
                {
                    k_kmer2fid[line[i..i+9].idup] ~= fid;
                    k_fid2kmer[fid] ~= line[i..i+9].idup;
                }
                else
                {
                    //h_kmer2fid[kmer][fid] = true;
                    h_fid2kmer[fid] ~= line[i..i+9].idup;
                }
            }
        }
    }
    infile.close;
    return;
}

int main(string[] args)
{
    string k_protein_seq = args[1];
    string h_protein_seq = args[2];
    bool verbose = false;
    if(args.length == 4 && args[3] == "-v")
        verbose = true;

    compute_9mer(h_protein_seq, false);
    compute_9mer(k_protein_seq, true);
    foreach(ref h_fid; taskPool.parallel(h_fid2kmer.byKey(), 100))
    {
        //writeln(taskPool.workerIndex);
        string toPrint;
        toPrint = ">" ~  h_fid ~ "\n";
        int matches;
        float percent = 0;
        int count;
        int[string] k_fid_count;

        foreach(h_kmer; h_fid2kmer[h_fid])
        {
            if(k_kmer2fid.get(h_kmer, null))
            {
                foreach(k_fid; k_kmer2fid[h_kmer])
                {
                    if(k_fid_count.get(k_fid, 0))
                    {
                        k_fid_count[k_fid] += 1;
                    }
                    else
                        k_fid_count[k_fid] = 1;
                }
            }
        }

        count = 0;
        foreach(k_fid, value; k_fid_count)
        {
            percent = to!float(value) / k_fid2kmer[k_fid].length;
            if(percent >= .7)
            {
                count += 1;
                //writeln("nom"); 
                if(verbose)
                    toPrint = toPrint ~  "\t" ~ k_fid ~ "\t" ~ to!string(percent*100)~ "%\n";
            }
        }
        toPrint = toPrint ~ "Count: " ~ to!string(count);
        writeln(toPrint);
    }

    return 0;
}
