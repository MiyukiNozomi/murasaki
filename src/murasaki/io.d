module murasaki.io;

import std.stdio;
import std.string;
import std.format : format;
import core.stdc.stdio : printf;

auto Format(Char, Args...)(in Char[] fmt, Args args) {
    return format(fmt, args);
}

void Printf(Char, Args...)(in Char[] fmt, Args args) {
    printf(format(fmt, args).toStringz());
}

void Printfln(Char, Args...)(in Char[] fmt, Args args) {
    printf((format(fmt, args)~"\n").toStringz());
}