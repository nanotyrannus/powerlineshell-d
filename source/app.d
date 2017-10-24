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
    long fg = 7;
    long bg = 0;
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
            enum thin = config["symbols"]["thin_separator"].str;
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
                                .join(` %s `.format(thin));
                } else {
                    result = dirText
                                .strip()
                                .split(`/`)
                                .filter!(s => s.length > 0)
                                .join(` %s `.format(thin));
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
        segment!((out Segment s) {
            import std.regex;

            auto describe = executeShell(`git status --porcelain -b`);
            if (describe.status != 0) {
                return ``;
            }
            auto status = describe.output.splitLines;
            auto branchRegex = regex(r"^## (?P<local>\S+?)''(\.{3}(?P<remote>\S+?)( \[(ahead (?P<ahead>\d+)(, )?)?(behind (?P<behind>\d+))?\])?)?$");
            auto branchInfo = status[0].matchAll(branchRegex);
            // status.join(" ").writeln();
            string result;
            // foreach (i; 1..status.length) {
            //     result ~= status[i];
            // }
            return ``;
        }),
        segment!((out Segment s) {
            s.fg = config["fg_term"].integer;
            s.bg = config["bg_term"].integer;
            return `$`;
        })
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
