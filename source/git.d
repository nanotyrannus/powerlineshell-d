module powerlineshell.git;

import powerlineshell.segment;
import powerlineshell.config;
import std.string;
import std.process;

Segment gitSegment()
{
    return segment!((out Segment s) {
        import std.regex;

        auto describe = executeShell(`git status --porcelain -b`);
        if (describe.status != 0)
        {
            return ``;
        }
        auto status = describe.output.splitLines;
        auto branchRegex = ctRegex!(
            r"^## (?P<local>\S+?)(\.{3}(?P<remote>\S+?)( \[(ahead (?P<ahead>\d+)(, )?)?(behind (?P<behind>\d+))?\])?)?$");
        auto binfo = status[0].matchFirst(branchRegex);

        // // "local: %s, remote: %s, ahead: %s, behind: %s".format(binfo["local"], binfo["remote"], binfo["ahead"], binfo["behind"]).writeln();
        string result;
        if (binfo["behind"] != null)
        {
            // s.children ~= segment!((out Segment s) {
            //     string text = "%s %s".format(binfo["behind"], config["segments"]["git"]["behind"].str);
            //     return "";
            // });
        }
        else if (binfo["ahead"] != null)
        {
            // s.children ~= segment!((out Segment s){
            //     return "%s %s".format(binfo["ahead"], config["segments"]["git"]["behind"].str);
            // });
        }
        s.fg = git_fg_master;
        s.bg = git_bg_master;
        return "%s".format(binfo["local"]);
    });
}
