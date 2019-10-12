import std.stdio;
import std.string;
import std.process;
import std.array;
import std.algorithm;
import std.socket;
import std.json;
import std.conv;

// enum string foo = import("config.json");
// enum config = parseJSON(foo);

import powerlineshell.config;
import powerlineshell.segment;
import powerlineshell.path;
import powerlineshell.git;
import powerlineshell.user;
import powerlineshell.hostname;
import powerlineshell.prompt;

// immutable string separator = config["symbols"]["separator"].str;
immutable string thinSeparator = "";

void main(string[] args)
{
    auto root = segment!((out Segment s) {
        s.children = [
            userSegment(),
            hostnameSegment(), 
            pathPrefixSegment(), 
            pathSegment(), 
            gitSegment(), 
            promptEnd()
        ];
        return ``;
    });

    auto segments = filter!(s => s.text.length > 0)(root.children).array();

    string result;

    for (int i = 0; i < segments.length - 1; i++)
    {
        segments[i].point = colorSequence(segments[i].bg, segments[i + 1].bg) ~ separator;
        result ~= segments[i].toString();
    }

    result ~= segments[$ - 1].toString();
    result ~= reset ~ `\[\033[38;5;%sm\]%s`.format(segments[$ - 1].bg, separator) ~ reset ~ ` `;

    result.writeln();
}

// string expand(Segment[] segments) {
//     string result;
//     Segment cursor;
//     while (segments.length > 0) {

//     }
// }
