module powerlineshell.path;
import powerlineshell.segment;
import powerlineshell.config;

import std.string;
import std.process;
import std.algorithm;
import std.array;

Segment pathPrefixSegment()
{
    return segment!((out Segment s) {
        s.fg = home_fg;
        s.bg = home_bg;
        auto pwd = executeShell("pwd");
        if (pwd.status == 0)
        {
            if (pwd.output.startsWith("/home/"))
            {
                return `~`;
            }
            else
            {
                return ``;
            }
        }
        else
        {
            return ` ERROR `;
        }
    });
}

Segment pathSegment()
{
    return segment!((out Segment s) {
        // path
        auto thin = thin_separator;
        auto maxCount = path_max_depth;
        s.fg = fg_1;
        s.bg = bg_1;
        const pwd = executeShell("pwd");
        string result;
        if (pwd.status == 0)
        {
            auto dirText = pwd.output;
            if (dirText.startsWith("/home/"))
            {
                auto temp = dirText.strip().split(`/`)[3 .. $];
                if (temp.length > maxCount)
                {
                    temp = "..." ~ temp[$ - maxCount .. $];
                }
                result = temp.join(` %s `.format(thin));
            }
            else
            {
                auto temp = dirText.strip().split(`/`).filter!(s => s.length > 0).array;
                if (temp.length > maxCount)
                {
                    temp = "..." ~ temp[$ - maxCount .. $];
                }
                result = temp.join(` %s `.format(thin));
            }

        }
        else
        {
            result = `error`;
        }
        return result;
    });
}

// Segment pathSegment = segment!((out Segment s) {
//                 // path
//                 auto thin = thin_separator;
//                 auto maxCount = path_max_depth;
//                 s.fg = fg_1;
//                 s.bg = bg_1;
//                 const pwd = executeShell("pwd");
//                 string result;
//                 if (pwd.status == 0) {
//                     auto dirText = pwd.output;
//                     if (dirText.startsWith("/home/")) {
//                         auto temp = dirText
//                                     .strip()
//                                     .split(`/`)[3..$];
//                         if (temp.length > maxCount) {
//                             temp = "..." ~ temp[$-maxCount..$];
//                         }
//                         result = temp.join(` %s `.format(thin));
//                     } else {
//                         auto temp = dirText
//                                     .strip()
//                                     .split(`/`)
//                                     .filter!(s => s.length > 0)
//                                     .array;          
//                         if (temp.length > maxCount) {
//                             temp = "..." ~ temp[$-maxCount..$];
//                         }
//                         result = temp.join(` %s `.format(thin));
//                     }

//                 } else {
//                     result = `error`;
//                 }
//                 return result;
//             });
