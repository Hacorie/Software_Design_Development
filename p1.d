#!/usr/bin/rdmd

/*
Author: Nathan Perry
Project: 1
Class: Software Design and Development
Instructor: Butler
*/

import std.stdio, std.string, std.getopt;

//Structure to hold a potential genes information.
struct geneInfo
{
    int StartPos;
    int Length;
    char [] contigID;
};

//function to read a fasta file
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
        else if(line[0..1] == "#")
        {
            continue;
        }
        else
        {
            key2val[key] ~= line;  // nl stripped by byLine
        }
    }
    infile.close();
    return key2val;
}

int main(string[] args)
{
    string  filename;

    geneInfo[] posGenes;
    geneInfo[] negGenes;
    geneInfo gene;

    if(args.length <= 1)
        return -1;
    else
        filename = args[1];

    string[string] pos_strand_data;
    pos_strand_data = read_fasta_file(filename);
    string[string] neg_strand_data;

    string key;
    string value;
    char[] newVal;
    char temp;
    foreach(key, value; pos_strand_data)
    {
        newVal = value.dup;
        newVal = newVal.reverse;
        for(int i = 0; i < newVal.length; i++)
        {
            if(newVal[i] == 'a')
                newVal[i] = 't';
            else if(newVal[i] == 'c')
                newVal[i] = 'g';
            else if(newVal[i] == 't')
                newVal[i] = 'a';
            else if(newVal[i] == 'g')
                newVal[i] = 'c';
        }
        neg_strand_data[key] = cast(string)newVal;
    }

    // Check to make sure the data is correct    
    int startPos;
    char[] rFrame;
    string genes;
    char[] geneFrame;
    int num;
    int geneStart;

    //search through the arrays using readingframes
    for(int i = 0; i < 3; i++)
    {
        num = 0;
        foreach(key, value; pos_strand_data)
        {
            startPos = i;
            while(startPos < value.length-3)
            {
                rFrame = value[startPos..startPos+3].dup;
                if(rFrame == "atg")
                {
                    genes  = "" ;
                    geneStart = startPos;
                    gene.StartPos =  geneStart+1;

                    while(geneStart < value.length-2)
                    {
                        geneFrame = value[geneStart..geneStart+3].dup;
                        if( geneFrame == "taa" || geneFrame == "tag" ||
                            geneFrame == "tga")
                        {
                            genes ~= geneFrame;
                            break;
                        }
                        else
                        {
                            genes ~= geneFrame;
                            geneStart +=3;

                        }
                    }
                    if(genes.length >=  99 &&  genes.length <= 1500)
                    {
                        gene.Length = genes.length;
                        gene.contigID = key.dup;
                        posGenes ~= gene;
                        num +=1;
                        startPos += genes.length;
                        continue;
                    }

                }
                startPos += 3;
            }
        }

        num = 0;
        foreach(key, value; neg_strand_data)
        {
            startPos = i;
            while(startPos < value.length-3)
            {
                rFrame = value[startPos..startPos+3].dup;
                if(rFrame == "atg")
                {
                    genes = "";
                    geneStart = startPos;
                    gene.StartPos = value.length - geneStart;

                    while(geneStart < value.length-2)
                    {
                        geneFrame = value[geneStart..geneStart+3].dup;
                        if( geneFrame == "taa" || geneFrame == "tag" ||
                            geneFrame == "tga")
                        {
                            genes ~= geneFrame;
                            break;
                        }
                        else
                        {
                            genes ~= geneFrame;
                            geneStart +=3;

                        }
                    }
                    if(genes.length >=  99 &&  genes.length <= 1500)
                    {
                        gene.Length = genes.length;
                        gene.contigID = key.dup;
                        negGenes ~= gene;
                        num +=1;
                        startPos += genes.length;
                        continue;
                    }
                }
                startPos +=3;
            }
        }
    }

    //write out every potential gene found
    int peg = 1;
    foreach(geneInfo g; posGenes)
    {
        writefln("%s\t%s.peg.%d\t%s_%d+%d", g.contigID[0..$-4], g.contigID, peg, g.contigID, g.StartPos, g.Length);
        //writefln("%s_%d+%d", g.contigID, g.StartPos, g.Length);
        peg +=1;
    }
    foreach(geneInfo g; negGenes)
    {
        writefln("%s\t%s.peg.%d\t%s_%d-%d", g.contigID[0..$-4], g.contigID, peg, g.contigID, g.StartPos, g.Length);
        //writefln("%s_%d-%d", g.contigID,g.StartPos, g.Length);
        peg+=1;
    }
    return 0;
}
