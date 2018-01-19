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
    Segment[] children;
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
    auto test = segment!((out Segment s) {
        s.children ~= segment!((out Segment s) {
            s.children ~= segment!((out Segment s) {
                return "";
            });
            return "";
        });
        return "";
    });

    auto root = segment!((out Segment s) {
            s.children = [
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
                enum maxCount =3;
                s.fg = config["fg_1"].integer;
                s.bg = config["bg_1"].integer;
                auto pwd = executeShell("pwd");
                string result;
                if (pwd.status == 0) {
                    auto dirText = pwd.output;
                    if (dirText.startsWith("/home/")) {
                        auto temp = dirText
                                    .strip()
                                    .split(`/`)[3..$];
                        if (temp.length > maxCount) {
                            temp = "..." ~ temp[$-maxCount..$];
                        }
                        result = temp.join(` %s `.format(thin));
                    } else {
                        auto temp = dirText
                                    .strip()
                                    .split(`/`)
                                    .filter!(s => s.length > 0)
                                    .array;          
                        if (temp.length > maxCount) {
                            temp = "..." ~ temp[$-maxCount..$];
                        }
                        result = temp.join(` %s `.format(thin));
                    }

                } else {
                    result = `error`;
                }
                return result;
            }), 
            segment!((out Segment s) {
                import std.regex;

                auto describe = executeShell(`git status --porcelain -b`);
                if (describe.status != 0) {
                    return ``;
                }

                auto status = describe.output.splitLines;
                auto branchRegex = ctRegex!(r"^## (?P<local>\S+?)(\.{3}(?P<remote>\S+?)( \[(ahead (?P<ahead>\d+)(, )?)?(behind (?P<behind>\d+))?\])?)?$");
                auto binfo = status[0].matchFirst(branchRegex);
                if (binfo.length < 1) {
                    // Calling 'local' parameter from binfo causes 'range violation' error
                    // in a freshly initialized git repo for some reason. The other parameters
                    // don't cause this error.
                    return `init`;
                }
                string result;
                if (binfo["behind"] != null) {
                    string text = "%s %s".format(binfo["behind"], config["segments"]["git"]["behind"].str);
                    result ~= text;
                } else if (binfo["ahead"] != null) {
                    result ~= "%s %s".format(binfo["ahead"], config["segments"]["git"]["behind"].str);
                } else if (binfo["remote"] != null) {
                }
                s.fg = config["segments"]["git"]["fg_master"].integer;
                s.bg = config["segments"]["git"]["bg_master"].integer;
                result ~= `%s`.format(binfo["local"]);
                return result;
            }),           
            segment!((out Segment s) {
                s.fg = config["fg_term"].integer;
                s.bg = config["bg_term"].integer;
                return `$`;
            })
        ];
        return ``;
    });

    auto segments = filter!(s => s.text.length > 0)(root.children).array();

    string result;

    for (int i = 0; i < segments.length - 1; i++) {
        segments[i].point = colorSequence(segments[i].bg, segments[i+1].bg) ~ separator;
        result ~= segments[i].toString();
    }

    result ~= segments[$-1].toString();
    result ~= reset ~ `\[\033[38;5;%sm\]%s`.format(segments[$-1].bg, separator) ~ reset ~ ` `;

    result.writeln();
}

// string expand(Segment[] segments) {
//     string result;
//     Segment cursor;
//     while (segments.length > 0) {
        
//     }
// }