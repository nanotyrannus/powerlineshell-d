module powerlineshell.git;

import powerlineshell.segment;
import powerlineshell.config;
import std.string;
import std.process;
import std.regex;

Segment gitSegment()
{
    return segment!((out Segment s) {

        auto describe = executeShell(`git status --porcelain -b`);
        if (describe.status != 0)
        {
            return ``;
        }
        auto status = describe.output.splitLines;

        // Debugging regex https://regex101.com/r/c204WA/1/tests
        auto branchRegex = ctRegex!(r"^## (?P<local>[\S]+)((\.{3}(?P<remote>\S+)|\s(?P<detached>\([\S ]+\)))( (\[(?P<ahead>ahead\s\d+)?(, )?(?P<behind>behind\s\d+)?\]))?)?$");
        auto binfo = status[0].matchFirst(branchRegex);

        string result;
        if (binfo["behind"] != null)
        {
            result ~= git_behind;
        }
        else if (binfo["ahead"] != null)
        {
            result ~= git_ahead;
            // s.children ~= segment!((out Segment s){
            //     return "%s %s".format(binfo["ahead"], git_ahead);
            // });
        }
        s.fg = git_fg_master;
        s.bg = git_bg_master;
        if (binfo["detached"] != null) {
            result ~= "detached "; 
        }
        if (binfo["local"] != null)
        {
            result = binfo["local"] ~ " " ~ result;
        }
        return result;
    });
}
