#!/usr/bin/rdmd

//Author: Nathan Perry
//Program: SDD p2
//Command line args: 1 --> 8_* file     2-->Contig file
//Description: Computer protein sequences from all encoding genes(pegs) listed in command line arg file.
//      Third field is the loc of the gene to encode.

//protein sequence map.

import std.stdio, std.string, std.getopt, std.conv;

//global variables for holding data
string[string] encodeSeq;           //holds dna->protein conversion chart
string[string] fasta_data;          //holds fasta data
string[string] locs;                //holds positional data

//Function to set up the conversion table for dna->protein sequence
void init_encodeSeq()
{
    encodeSeq["ttt"] = "F";     encodeSeq["tct"] = "S";     encodeSeq["tat"] = "Y";     encodeSeq["tgt"] = "C";
    encodeSeq["ttc"] = "F";     encodeSeq["tcc"] = "S";     encodeSeq["tac"] = "Y";     encodeSeq["tgc"] = "C";
    encodeSeq["tta"] = "L";     encodeSeq["tca"] = "S";     encodeSeq["taa"] = ".";     encodeSeq["tga"] = ".";
    encodeSeq["ttg"] = "L";     encodeSeq["tcg"] = "S";     encodeSeq["tag"] = ".";     encodeSeq["tgg"] = "W";

    encodeSeq["ctt"] = "L";     encodeSeq["cct"] = "P";     encodeSeq["cat"] = "H";     encodeSeq["cgt"] = "R";
    encodeSeq["ctc"] = "L";     encodeSeq["ccc"] = "P";     encodeSeq["cac"] = "H";     encodeSeq["cgc"] = "R";
    encodeSeq["cta"] = "L";     encodeSeq["cca"] = "P";     encodeSeq["caa"] = "Q";     encodeSeq["cga"] = "R";
    encodeSeq["ctg"] = "L";     encodeSeq["ccg"] = "P";     encodeSeq["cag"] = "Q";     encodeSeq["cgg"] = "R";

    encodeSeq["att"] = "I";     encodeSeq["act"] = "T";     encodeSeq["aat"] = "N";     encodeSeq["agt"] = "S";
    encodeSeq["atc"] = "I";     encodeSeq["acc"] = "T";     encodeSeq["aac"] = "N";     encodeSeq["agc"] = "S";
    encodeSeq["ata"] = "I";     encodeSeq["aca"] = "T";     encodeSeq["aaa"] = "K";     encodeSeq["aga"] = "R";
    encodeSeq["atg"] = "M";     encodeSeq["acg"] = "T";     encodeSeq["aag"] = "K";     encodeSeq["agg"] = "R";

    encodeSeq["gtt"] = "V";     encodeSeq["gct"] = "A";     encodeSeq["gat"] = "D";     encodeSeq["ggt"] = "G";
    encodeSeq["gtc"] = "V";     encodeSeq["gcc"] = "A";     encodeSeq["gac"] = "D";     encodeSeq["ggc"] = "G";
    encodeSeq["gta"] = "V";     encodeSeq["gca"] = "A";     encodeSeq["gaa"] = "E";     encodeSeq["gga"] = "G";
    encodeSeq["gtg"] = "V";     encodeSeq["gcg"] = "A";     encodeSeq["gag"] = "E";     encodeSeq["ggg"] = "G";

    return;
}

//Function to read the positional data file and extracts columns 2 and 3 and save them
void read_8_gid_file(string filename)
{
    //open the positional data file
    auto infile = File(filename, "r");

    //for each line in the file, extract column 2 and 3 and
    //put them into a dictionary for easy data lookup
    foreach(line; infile.byLine())
    {
        locs[line.split()[2].idup] = line.split()[1].idup;
    }
 
    return;
}

//Function provided by Dr. Butler from project 1
//Reads a fasta file and saves the data in an easy to use format
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
    //writeln(key2val["kb|g.219.c.0"].length);
    return key2val;
}

//Reverses a gene and complements a gene
string geneFlip(char[] gene)
{
    //reverse the gene
    gene = gene.reverse;

    //compute and save its complement
    for(int i = 0; i < gene.length; i++)
    {
        if(gene[i] == 'a')
            gene[i] = 't';
        else if(gene[i] == 't')
            gene[i] = 'a';
        else if(gene[i] == 'g')
            gene[i] = 'c';
        else if(gene[i] == 'c')
            gene[i] = 'g';
    }

    return gene.idup;
}

//Changes a dna strand to a protein sequence
string toProtein(string gene)
{
    string protein;
    string grab_3;

    //grab 3 characters from the gene and convert to a protein
    //until no more are left
    for(int i = 0; i < gene.length; i+=3)
    {
        grab_3 = gene[i..i+3];
        try
        {
            grab_3 = encodeSeq[grab_3].idup;
        }
        catch
        {
            grab_3 = "-";
        }
        protein ~= grab_3;
    }

    return protein;
}

int main(string[] args)
{
    string _8_gid_file = args[1];   //file with all the positional data
    string contig_file = args[2];   //file with all the contig/gene info
    string key, value;              //key,value loopers
    string[4] contig_info;          //array to hold contig data
    string holder;                  //temp variable for cutting up data correctly
    string geneseq;                 //the extracted gene
    int start, end;                 //slicing variables for gene extraction

    //Set up global gene_data->protein_data dictionary
    init_encodeSeq();

    //extract column 2 and 3 from positional data file
    read_8_gid_file(_8_gid_file);

    //extract gene information in fasta file
    fasta_data = read_fasta_file(contig_file);

    //loop over every key in locs
    foreach( key, value; locs)
    {
        //make sure there is not a comma in the key
        if(key.split(",").length == 1 )
        {
            //extract everything up to the _ and save as contig ID
            contig_info[0] = key.split("_")[0].idup;
            holder = key.split("_")[1].idup;
            //everything after the _ should be split into three pieces
            foreach(char x; key)
            {
                if(x == '+')
                {
                    contig_info[1] = holder.split("+")[0].idup; //gene start pos
                    contig_info[2] = "+";                       //+ or -
                    contig_info[3] = holder.split("+")[1].idup; //length of gene
                    break;
                }
                else if(x == '-')
                {
                    contig_info[1] = holder.split("-")[0].idup;
                    contig_info[2] = "-";
                    contig_info[3] = holder.split("-")[1].idup;
                    break;
                }
            }
            //The gene name should then be looked up in fasta_data table
            if(!(contig_info[0] in fasta_data))
                continue;
            geneseq = fasta_data[contig_info[0]];
            start = (to!int(contig_info[1]))-1;

            //once found check positional data and find gene.
            if(contig_info[2] == "+")
            {
                end = (start + to!int(contig_info[3]));
                //writefln("%s  length: %s\tstart: %d\tend:%d",contig_info[0], geneseq.length, start, end);
                try
                    geneseq = geneseq[start..end];
                catch
                    continue;
            }
            else
            {
                end = (start - to!int(contig_info[3]));
                //writefln("length: %s\tstart: %d\tend:%d",geneseq.length, start, end);

                try
                    geneseq = geneseq[end+1..start+1];
                catch
                    continue;
                geneseq = geneFlip(geneseq.dup);
            }

            //extract it. and transpose to Protein sequences
            geneseq = toProtein(geneseq);

            //print out locs[key]((this prints out the contig and peg)  and protein sequence
            writefln(">%s\n%s", value, geneseq);

        }
    }

    return 0;
}

