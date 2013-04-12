#!/usr/bin/rdmd

/*
Author: Nathan Perry
Project: 5
Class: Software Design and Development
Instructor: Butler
Purpose: String ALignment
*/

import std.stdio, std.string, std.conv;

//structure for traceback
struct whichWay
{
    bool diagonal, left, up;
};

int main(string [] args)
{
    //error handle checker for args
    if(args.count != 5)
    {
        writeln("Usage: ./p5 filename match_value mismatch_penalty gap_penalty");
        return -1;
    }

    string filename = args[1];
    int match_value = to!int(args[2]);
    int mismatch_penalty = to!int(args[3]);
    int gap_penalty = to!int(args[4]);
    string[] lines;

    auto infile = File(filename, "r");
    foreach(line; infile.byLine())
    {
        line = strip(line);
        if(line[0] != '#')
            lines ~= line.idup;
    }

    //save the length of both lines for later use
    int r_count = lines[1].length + 1;
    int c_count = lines[0].length + 1;

    //local variables
    int temp;
    int[string] tempArr;
    int max;
    int[][] intArr;
    intArr = new int[][r_count];

    whichWay[][] structArr;
    structArr = new whichWay[][r_count];

    int[] sorted;

    for(int i = 0; i < r_count; i++)
    {
        intArr[i] = new int[c_count];
        structArr[i] = new whichWay[c_count];
    }


    for(int i = 1; i < r_count; i++)
    {
        for(int j = 1; j < c_count; j++)
        {
            //find maxi;;
            tempArr.clear;

            //M[i-1][j-1] + match/mismatch
            if(lines[1][i-1] == lines[0][j-1])
            {
                temp = intArr[i-1][j-1] + match_value;
            }
            else
            {
                temp = intArr[i-1][j-1] + mismatch_penalty;
            }
            tempArr["diagonal"] = temp;

            //M[i][j-1] + w
            tempArr["left"] = intArr[i][j-1] + gap_penalty;

            //M[i-1][j] + w
            tempArr["up"] = intArr[i-1][j] + gap_penalty;

            //sort values from highest to lowest
            sorted = tempArr.values.sort.reverse;

            //set up the correct backtracing array
            foreach(key, value; tempArr)
            {
                if(sorted[0] == value)
                {
                    if(key == "diagonal")
                        structArr[i][j].diagonal = true;
                    else if(key == "up")
                        structArr[i][j].up = true;
                    else
                        structArr[i][j].left = true;
                }
            }
            intArr[i][j] = sorted[0];
        }
    }

    int i = r_count - 1;
    int j = c_count - 1;
    string top;
    string bottom;

    while( i > 0 && j > 0)
    {
        if(structArr[i][j].diagonal)
        {
            top ~= lines[0][j-1];
            bottom ~= lines[1][i-1];
            i -= 1;
            j -= 1;
        }
        else if(structArr[i][j].left)
        {
            top ~= lines[0][j-1];
            bottom ~= "_";
            j -= 1;
        }
        else
        {
            top ~= "_";
            bottom ~= lines[1][i-1];
            i-=1;
        }
        if(i == 0)
        {
            while(j != 0)
            {
                top ~= lines[0][j-1];
                bottom ~= "_";
                j-=1;
            }
        }
        else if(j == 0)
        {
            while(i != 0)
            {
                top ~= "_";
                bottom ~= lines[1][i-1];
                i-=1;
            }
        }
    }
    writeln(top.dup.reverse);
    writeln(bottom.dup.reverse);
    writeln();

    return 0;
}
