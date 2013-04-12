#!/usr/bin/rdmd

import std.stdio, std.string, std.getopt;

int main()
{
    string hello = "hello world";
    writeln(hello.split(","));
    return 0;
}
