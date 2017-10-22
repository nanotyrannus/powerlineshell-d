import std.stdio;
import std.string;
import std.array;
import std.socket;
import std.process;
import std.file;
import std.algorithm;

enum int[string] config = [
        "bg_1" : 255, "bg_2" : 0, "bg_3" : 0, "bg_home" : 27, "fg_1" : 246, "fg_2"
        : 81, "fg_3" : 0, "fg_home" : 254
    ];

struct Foo {
    int function(int) f;
}

string colorSequence(int fg, int bg)
{
    return `\[\033[38;5;%s;48;5;%sm\]`.format(fg, bg);
}

immutable string separator = "";
immutable string dirSeparator= "";

void main(string[] args)
{

    auto segments = [
        new Segment((Segment s) {
            s.fg = config["fg_home"];
            s.bg = config["bg_home"];
            return ` %s `.format(executeShell(`date "+%d %b %r"`).output.strip); 
        }),
        new Segment((Segment s) {
            s.fg = config["fg_1"];
            s.bg = config["bg_1"];
            return ` %s `.format(`\u`);
        }),
        new Segment((Segment s) {
            s.fg = config["fg_2"];
            s.bg = config["bg_2"];
            return ` %s `.format(Socket.hostName);
        }),
        new Segment((Segment s) {
            // path
            s.fg = config["fg_1"];
            s.bg = config["bg_1"];
            auto pwd = executeShell("pwd");
            string result;
            if (pwd.status == 0) {
                result = pwd.output
                            .strip()
                            .split(`/`)[3..$]
                            .map!(str => ` %s `.format(str))
                            .join(dirSeparator);
                if ( result.length < 1) {
                    result = "";
                }
            } else {
                `Something went wrong (%s)`.format(pwd.output).writeln;
                result = `error`;
            }

            return result;
        })
    ];
    segments = filter!(s => s.show)(segments).array();
    // auto git = new Segment(() {
    //     return `git`;
    // });
    string terminator = `\[\e[m\]` ~ `\[\033[38;5;%sm\]%s`.format(config["bg_1"],
            separator) ~ `\[\e[m\]`;

    string result;
    foreach (int i, Segment s; segments) {
        if (i == segments.length - 1) {
            s.point = `\[\e[m\]` ~ `\[\033[38;5;%sm\]%s`.format(s.bg, separator) ~ `\[\e[m\]`;
        } else {
            s.point = colorSequence(segments[i].bg, segments[i+1].bg) ~ separator;
        }
        result ~= segments[i].toString();
    }
    result ~= " ";
    // result ~= terminator;

    result.writeln();
    //`\[\e[31;40m\]\u@\h>\[\e[m\]`.writeln();
}

class Segment
{

    public string segmentText;
    public string point;
    public int bg;
    public int fg;
    public bool show = true;

    this(string function(Segment) action)
    {
        segmentText = action(this);
        if (segmentText.length < 1) {
            show = false;
        }
    }

    override string toString()
    {
        return colorSequence(fg, bg) ~ segmentText ~ point;
    }
}
