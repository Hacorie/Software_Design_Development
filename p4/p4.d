#!/usr/bin/rdmd

/*
Author: Nathan Perry
Project: 4
Class: Software Design and Development
Instructor: Butler
*/

//./p4 8_gid_fid p1out.txt p3Matches

import std.stdio, std.string, std.getopt, std.conv;
import std.parallelism, core.thread, core.sync.barrier;
import std.algorithm, std.concurrency, core.sync.mutex;

string[string] locsDatabase;
string[string] locsUnknown;
string[string] kPeg2Function;
string[][string] uPeg2matches;
string[] p3Matches;

void read_8_gid_file(string filename, bool type)
{
    auto infile = File(filename, "r");

    foreach(line; infile.byLine())
        if(type)
        {
            locsDatabase[line.split()[2].idup] = line.split()[1].idup;
            kPeg2Function[line.split("\t")[1].idup] = line.split("\t")[3].idup;
        }
        else
            locsUnknown[line.split()[1].idup] = line.split()[2].idup;
    infile.close();
    return;
}

void read_p3_out_file(string filename)
{
    auto infile = File(filename, "r");

    string uid;
    string[] matches;
    foreach(line; infile.byLine())
    {
        if(line[0] == '>')
        {
            uid = line[1 .. $].idup;
            matches.clear();
        }
        else
            matches ~= line.idup;
        if( matches.length != 0 && matches[matches.length-1].split()[0] == "Count:")
        {
            if(matches[matches.length-1].split()[1] == "0")
                continue;
            else
            {
                //writeln(uid);
                p3Matches ~= uid;
                uPeg2matches[uid] = matches;

            }
        }
    }
    infile.close;
    return;
}

int main(string[] args)
{
    //command line args
        //1)8_*fid_file
        //2)p1Output
        //3)p3 output
    //Files
    string _8_gid_file = args[1];
    string p1_output_file = args[2];
    string p3_output_file = args[3];

    int successful = 0;
    int falsePos = 0;

    //read and store data for fast look up in positional data
    read_8_gid_file(_8_gid_file, true);
    read_8_gid_file(p1_output_file, false);
    read_p3_out_file(p3_output_file);

    //writeln(p3Matches.length);
    //writeln(p3Matches);
    //p3Matches.sort;
    foreach(item; p3Matches) //taskPool.parallel(p3Matches))
    {
        //writeln(uPeg2matches[item]);
        string uLoc;
        try
            uLoc = locsUnknown[item];
        catch
            continue;
        if(locsDatabase.get(uLoc, "") != "")
        {
            writefln( "%s\t Successful Annotation \t %s", item, uLoc);
            foreach(item2; uPeg2matches[item])
            {
                if(item2[0]== '\t')
                {
                    //writeln(item2.split("\t"));
                    writefln( "\t%s\t%s\t(%s)", item2.split("\t")[1], item2.split("\t")[2], kPeg2Function[item2.split("\t")[1]]);
                    //writefln(item2 ~ '\t' ~ kPeg2Function[item2.stripLeft()]);
                }
                else
                {
                    writeln(item2);
                }
            }
            successful += 1;
        }
        else
        {
            writefln( "%s\t False Positive \t %s", item, uLoc);
            //writeln(item ~ " FALSE POSITIVE");

            foreach(item2; uPeg2matches[item])
            {
                if(item2[0]== '\t')
                {
                    //writeln(item2.split("\t"));
                    writefln( "\t%s\t%s\t(%s)", item2.split("\t")[1], item2.split("\t")[2], kPeg2Function[item2.split("\t")[1]]);
                    //writefln(item2 ~ '\t' ~ kPeg2Function[item2.stripLeft()]);
                }
                else
                {
                    writeln(item2);
                }
            }
            falsePos += 1;
        }
        writeln();
    }

    writefln("\nTotal Number of Successfully Called Genes: %d", successful);
    writefln("Total Number of False Positives: %d", falsePos);

    return 0;
}
