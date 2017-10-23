import std.stdio;
import std.string;
import std.process;
import std.array;
import std.algorithm;
import std.socket;
import std.json;
import std.conv;

enum string foo = import("config.json");
enum config = parseJSON(foo);

struct Segment
{
    string text;
    string colorControl;
    string point;
    long fg;
    long bg;
    string toString()
    {
        if (text.length > 0)
        {
            return colorSequence(fg, bg) ~ ` %s `.format(text) ~ point;
        }
        else
        {
            return ``;
        }
    }

}

/// Returns ANSI sequence that resets color on
/// subsequent characters.
string reset()
{
    return `\[\e[m\]`;
}

string colorSequence(long fg, long bg)
{
    return `\[\033[38;5;%s;48;5;%sm\]`.format(fg, bg);
}



immutable string separator = "";
immutable string thinSeparator = "";

Segment segment(string function(out Segment s) action)()
{
    Segment s;
    s.text = action(s);
    return s;
}

void main(string[] args)
{
    auto segments = [
        segment!((out Segment s) { 
            s.fg = config["fg_1"].integer;
            s.bg = config["bg_1"].integer;
            return `\u`;
        }), segment!((out Segment s) {
            s.fg = config["fg_2"].integer;
            s.bg = config["bg_2"].integer;
            return Socket.hostName;
        }), segment!((out Segment s){
            s.fg = config["fg_home"].integer;
            s.bg = config["bg_home"].integer;
            auto pwd = executeShell("pwd");
            if (pwd.status == 0) {
                if (pwd.output.startsWith("/home/")) {
                    return `~`;
                } else {
                    return ``;
                }
            } else {
                return ` ERROR `;
            }
        }),segment!((out Segment s) {
            // path
            s.fg = config["fg_1"].integer;
            s.bg = config["bg_1"].integer;
            auto pwd = executeShell("pwd");
            string result;
            if (pwd.status == 0) {
                auto dirText = pwd.output;
                if (dirText.startsWith("/home/")) {
                    result = dirText
                                .strip()
                                .split(`/`)[3..$]
                                .join(` %s `.format(thinSeparator));
                } else {
                    result = dirText
                                .strip()
                                .split(`/`)
                                .filter!(s => s.length > 0)
                                .join(` %s `.format(thinSeparator));
                }
            } else {
                result = `error`;
            }
            return result;
        }), 
        // segment!((out Segment s) {
        //     s.fg = config["fg_2"].integer;
        //     s.bg = config["bg_2"].integer;
        //     return `git`;
        // })
    ];

    segments = filter!(s => s.text.length > 0)(segments).array();

    string result;

    for (int i = 0; i < segments.length - 1; i++) {
        segments[i].point = colorSequence(segments[i].bg, segments[i+1].bg) ~ separator;
        result ~= segments[i].toString();
    }

    result ~= segments[$-1].toString();
    result ~= reset ~ `\[\033[38;5;%sm\]%s`.format(segments[$-1].bg, separator) ~ reset ~ ` `;

    result.writeln();
}
