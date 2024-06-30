const std = @import("std");

pub const Graph = struct {
    nodes: std.StringHashMap(Node),
    weights: std.StringHashMap(f64),

    const Self = @This();

    pub fn clone(self: *const Self) Self {
        return Self{
            .nodes = self.nodes.clone() catch unreachable,
            .weights = self.weights.clone() catch unreachable,
        };
    }

    pub fn deinit(self: *Self) void {
        self.nodes.deinit();
        self.weights.deinit();
    }

    pub fn default(ally: std.mem.Allocator) Self {
        var nodes = std.StringHashMap(Node).init(ally);

        for (default_characters, default_points) |character, point| {
            const node = Node{ .point = point };
            nodes.put(character, node) catch unreachable;
        }

        return Self{
            .nodes = nodes,
            .weights = default_weights(ally),
        };
    }

    pub fn update_character(self: Self, old: []const u8, new: []const u8) void {
        const old_node = self.nodes.get(old).?;
        const new_node = self.nodes.get(new).?;

        self.nodes.put(old, new_node) catch unreachable;
        self.nodes.put(new, old_node) catch unreachable;
    }
};

pub const Node = struct {
    point: Point,
};

pub const Point = struct {
    x: f64,
    y: f64,

    pub fn distance(self: Point, other: Point) f64 {
        const dx = other.x - self.x;
        const dy = other.y - self.y;
        return @sqrt((dx * dx) + (dy * dy));
    }
};

// ion232: A grid of 5x5 makes for a better shorthand, hence we remove 'q' which is often an implicit letter.
pub const default_width: usize = 5;
pub const default_height: usize = 5;
pub const default_characters = [default_width * default_height][]const u8{ "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "r", "s", "t", "u", "v", "w", "x", "y", "z" };
pub const default_points = blk: {
    var points: [default_characters.len]Point = undefined;

    for (0..default_height) |y| {
        for (0..default_width) |x| {
            points[(y * default_width) + x] = Point{
                .x = @floatFromInt(x),
                .y = @floatFromInt(y),
            };
        }
    }

    break :blk points;
};

// ion232: Modified from https://gist.github.com/lydell/c439049abac2c9226e53
// ion232: The bigrams containing 'q' have been taken out.
pub const default_weights = std.StaticStringMap(f64).initComptime(.{
    .{ "th", 1.0 / 100272945963 },
    .{ "he", 1.0 / 86697336727 },
    .{ "in", 1.0 / 68595215308 },
    .{ "er", 1.0 / 57754162106 },
    .{ "an", 1.0 / 55974567611 },
    .{ "re", 1.0 / 52285662239 },
    .{ "on", 1.0 / 49570981965 },
    .{ "at", 1.0 / 41920838452 },
    .{ "en", 1.0 / 41004903554 },
    .{ "nd", 1.0 / 38129777631 },
    .{ "ti", 1.0 / 37856196209 },
    .{ "es", 1.0 / 37766388079 },
    .{ "or", 1.0 / 35994097756 },
    .{ "te", 1.0 / 33973261529 },
    .{ "of", 1.0 / 33130341561 },
    .{ "ed", 1.0 / 32937140633 },
    .{ "is", 1.0 / 31817918249 },
    .{ "it", 1.0 / 31672532308 },
    .{ "al", 1.0 / 30662410438 },
    .{ "ar", 1.0 / 30308513014 },
    .{ "st", 1.0 / 29704461829 },
    .{ "to", 1.0 / 29360205581 },
    .{ "nt", 1.0 / 29359771944 },
    .{ "ng", 1.0 / 26871805511 },
    .{ "se", 1.0 / 26282488562 },
    .{ "ha", 1.0 / 26103411208 },
    .{ "as", 1.0 / 24561944198 },
    .{ "ou", 1.0 / 24531132241 },
    .{ "io", 1.0 / 23542263265 },
    .{ "le", 1.0 / 23382173640 },
    .{ "ve", 1.0 / 23270129573 },
    .{ "co", 1.0 / 22384167777 },
    .{ "me", 1.0 / 22360109325 },
    .{ "de", 1.0 / 21565300071 },
    .{ "hi", 1.0 / 21520845924 },
    .{ "ri", 1.0 / 20516398905 },
    .{ "ro", 1.0 / 20491179118 },
    .{ "ic", 1.0 / 19701195496 },
    .{ "ne", 1.0 / 19504235770 },
    .{ "ea", 1.0 / 19403941063 },
    .{ "ra", 1.0 / 19332539912 },
    .{ "ce", 1.0 / 18367773425 },
    .{ "li", 1.0 / 17604626629 },
    .{ "ch", 1.0 / 16854985236 },
    .{ "ll", 1.0 / 16257360474 },
    .{ "be", 1.0 / 16249257887 },
    .{ "ma", 1.0 / 15938689768 },
    .{ "si", 1.0 / 15509759748 },
    .{ "om", 1.0 / 15402602484 },
    .{ "ur", 1.0 / 15303657594 },
    .{ "ca", 1.0 / 15174413181 },
    .{ "el", 1.0 / 14952716079 },
    .{ "ta", 1.0 / 14941000711 },
    .{ "la", 1.0 / 14874551789 },
    .{ "ns", 1.0 / 14350320288 },
    .{ "di", 1.0 / 13899990598 },
    .{ "fo", 1.0 / 13753006196 },
    .{ "ho", 1.0 / 13672603513 },
    .{ "pe", 1.0 / 13477683504 },
    .{ "ec", 1.0 / 13457763533 },
    .{ "pr", 1.0 / 13378480175 },
    .{ "no", 1.0 / 13099447521 },
    .{ "ct", 1.0 / 12997849406 },
    .{ "us", 1.0 / 12808517567 },
    .{ "ac", 1.0 / 12625666388 },
    .{ "ot", 1.0 / 12465822481 },
    .{ "il", 1.0 / 12167821320 },
    .{ "tr", 1.0 / 12006693396 },
    .{ "ly", 1.0 / 11983948242 },
    .{ "nc", 1.0 / 11722631112 },
    .{ "et", 1.0 / 11634161334 },
    .{ "ut", 1.0 / 11423899818 },
    .{ "ss", 1.0 / 11421755201 },
    .{ "so", 1.0 / 11214705934 },
    .{ "rs", 1.0 / 11180732354 },
    .{ "un", 1.0 / 11121118166 },
    .{ "lo", 1.0 / 10908830081 },
    .{ "wa", 1.0 / 10865206430 },
    .{ "ge", 1.0 / 10861045622 },
    .{ "ie", 1.0 / 10845731320 },
    .{ "wh", 1.0 / 10680697684 },
    .{ "ee", 1.0 / 10647199443 },
    .{ "wi", 1.0 / 10557401491 },
    .{ "em", 1.0 / 10536054813 },
    .{ "ad", 1.0 / 10375130449 },
    .{ "ol", 1.0 / 10305660447 },
    .{ "rt", 1.0 / 10198055461 },
    .{ "po", 1.0 / 10189505383 },
    .{ "we", 1.0 / 10176141608 },
    .{ "na", 1.0 / 9790855551 },
    .{ "ul", 1.0 / 9751225781 },
    .{ "ni", 1.0 / 9564648232 },
    .{ "ts", 1.0 / 9516029773 },
    .{ "mo", 1.0 / 9498813191 },
    .{ "ow", 1.0 / 9318366591 },
    .{ "pa", 1.0 / 9123652775 },
    .{ "im", 1.0 / 8959759181 },
    .{ "mi", 1.0 / 8957825538 },
    .{ "ai", 1.0 / 8922759715 },
    .{ "sh", 1.0 / 8888705287 },
    .{ "ir", 1.0 / 8886799024 },
    .{ "su", 1.0 / 8774129154 },
    .{ "id", 1.0 / 8332214014 },
    .{ "os", 1.0 / 8176085241 },
    .{ "iv", 1.0 / 8116349309 },
    .{ "ia", 1.0 / 8072199471 },
    .{ "am", 1.0 / 8032259916 },
    .{ "fi", 1.0 / 8024355222 },
    .{ "ci", 1.0 / 7936922442 },
    .{ "vi", 1.0 / 7600241898 },
    .{ "pl", 1.0 / 7415349106 },
    .{ "ig", 1.0 / 7189051323 },
    .{ "tu", 1.0 / 7187510085 },
    .{ "ev", 1.0 / 7184041787 },
    .{ "ld", 1.0 / 7122648226 },
    .{ "ry", 1.0 / 6985436186 },
    .{ "mp", 1.0 / 6743935008 },
    .{ "fe", 1.0 / 6670566518 },
    .{ "bl", 1.0 / 6581097936 },
    .{ "ab", 1.0 / 6479202253 },
    .{ "gh", 1.0 / 6414827751 },
    .{ "ty", 1.0 / 6408447994 },
    .{ "op", 1.0 / 6313536754 },
    .{ "wo", 1.0 / 6252724050 },
    .{ "sa", 1.0 / 6147356936 },
    .{ "ay", 1.0 / 6128842727 },
    .{ "ex", 1.0 / 6035335807 },
    .{ "ke", 1.0 / 6027536039 },
    .{ "fr", 1.0 / 6011200185 },
    .{ "oo", 1.0 / 5928601045 },
    .{ "av", 1.0 / 5778409728 },
    .{ "ag", 1.0 / 5772552144 },
    .{ "if", 1.0 / 5731148470 },
    .{ "ap", 1.0 / 5719570727 },
    .{ "gr", 1.0 / 5548472398 },
    .{ "od", 1.0 / 5511014957 },
    .{ "bo", 1.0 / 5509918152 },
    .{ "sp", 1.0 / 5392724233 },
    .{ "rd", 1.0 / 5338083783 },
    .{ "do", 1.0 / 5307591560 },
    .{ "uc", 1.0 / 5291161134 },
    .{ "bu", 1.0 / 5214802738 },
    .{ "ei", 1.0 / 5169898489 },
    .{ "ov", 1.0 / 5021440160 },
    .{ "by", 1.0 / 4975814759 },
    .{ "rm", 1.0 / 4938158020 },
    .{ "ep", 1.0 / 4837800987 },
    .{ "tt", 1.0 / 4812693687 },
    .{ "oc", 1.0 / 4692062395 },
    .{ "fa", 1.0 / 4624241031 },
    .{ "ef", 1.0 / 4588497002 },
    .{ "cu", 1.0 / 4585165906 },
    .{ "rn", 1.0 / 4521640992 },
    .{ "sc", 1.0 / 4363410770 },
    .{ "gi", 1.0 / 4275639800 },
    .{ "da", 1.0 / 4259590348 },
    .{ "yo", 1.0 / 4226720021 },
    .{ "cr", 1.0 / 4214150542 },
    .{ "cl", 1.0 / 4201617719 },
    .{ "du", 1.0 / 4186093215 },
    .{ "ga", 1.0 / 4175274057 },
    .{ "ue", 1.0 / 4158448570 },
    .{ "ff", 1.0 / 4125634219 },
    .{ "ba", 1.0 / 4122472992 },
    .{ "ey", 1.0 / 4053144855 },
    .{ "ls", 1.0 / 3990203351 },
    .{ "va", 1.0 / 3946966167 },
    .{ "um", 1.0 / 3901923211 },
    .{ "pp", 1.0 / 3850125519 },
    .{ "ua", 1.0 / 3844138094 },
    .{ "up", 1.0 / 3835093459 },
    .{ "lu", 1.0 / 3811884104 },
    .{ "go", 1.0 / 3725558729 },
    .{ "ht", 1.0 / 3670802795 },
    .{ "ru", 1.0 / 3618438291 },
    .{ "ug", 1.0 / 3606562400 },
    .{ "ds", 1.0 / 3560125353 },
    .{ "lt", 1.0 / 3486149365 },
    .{ "pi", 1.0 / 3470838749 },
    .{ "rc", 1.0 / 3422694015 },
    .{ "rr", 1.0 / 3404547067 },
    .{ "eg", 1.0 / 3370515965 },
    .{ "au", 1.0 / 3356322923 },
    .{ "ck", 1.0 / 3316660134 },
    .{ "ew", 1.0 / 3293529190 },
    .{ "mu", 1.0 / 3231856188 },
    .{ "br", 1.0 / 3145611704 },
    .{ "bi", 1.0 / 3005679357 },
    .{ "pt", 1.0 / 2982699529 },
    .{ "ak", 1.0 / 2952167845 },
    .{ "pu", 1.0 / 2947681332 },
    .{ "ui", 1.0 / 2852182384 },
    .{ "rg", 1.0 / 2813274913 },
    .{ "ib", 1.0 / 2780268452 },
    .{ "tl", 1.0 / 2775935006 },
    .{ "ny", 1.0 / 2760941827 },
    .{ "ki", 1.0 / 2759841743 },
    .{ "rk", 1.0 / 2736041446 },
    .{ "ys", 1.0 / 2730343336 },
    .{ "ob", 1.0 / 2725791138 },
    .{ "mm", 1.0 / 2708822249 },
    .{ "fu", 1.0 / 2706168901 },
    .{ "ph", 1.0 / 2661480326 },
    .{ "og", 1.0 / 2651165734 },
    .{ "ms", 1.0 / 2617582287 },
    .{ "ye", 1.0 / 2612941418 },
    .{ "ud", 1.0 / 2577213760 },
    .{ "mb", 1.0 / 2544901434 },
    .{ "ip", 1.0 / 2515455253 },
    .{ "ub", 1.0 / 2497666762 },
    .{ "oi", 1.0 / 2474275212 },
    .{ "rl", 1.0 / 2432373251 },
    .{ "gu", 1.0 / 2418410978 },
    .{ "dr", 1.0 / 2409399231 },
    .{ "hr", 1.0 / 2379584978 },
    .{ "cc", 1.0 / 2344219345 },
    .{ "tw", 1.0 / 2322619238 },
    .{ "ft", 1.0 / 2302659749 },
    .{ "wn", 1.0 / 2227183930 },
    .{ "nu", 1.0 / 2217508482 },
    .{ "af", 1.0 / 2092395523 },
    .{ "hu", 1.0 / 2077887429 },
    .{ "nn", 1.0 / 2051719074 },
    .{ "eo", 1.0 / 2044268477 },
    .{ "vo", 1.0 / 2004982879 },
    .{ "rv", 1.0 / 1953555667 },
    .{ "nf", 1.0 / 1894270041 },
    .{ "xp", 1.0 / 1885334638 },
    .{ "gn", 1.0 / 1850801359 },
    .{ "sm", 1.0 / 1838392669 },
    .{ "fl", 1.0 / 1830098844 },
    .{ "iz", 1.0 / 1814164135 },
    .{ "ok", 1.0 / 1813376076 },
    .{ "nl", 1.0 / 1798491132 },
    .{ "my", 1.0 / 1753447198 },
    .{ "gl", 1.0 / 1709752272 },
    .{ "aw", 1.0 / 1689436638 },
    .{ "ju", 1.0 / 1655210582 },
    .{ "oa", 1.0 / 1620913259 },
    .{ "sy", 1.0 / 1602829285 },
    .{ "sl", 1.0 / 1575646777 },
    .{ "ps", 1.0 / 1538723474 },
    .{ "jo", 1.0 / 1516687319 },
    .{ "lf", 1.0 / 1507867867 },
    .{ "nv", 1.0 / 1466426243 },
    .{ "je", 1.0 / 1463052212 },
    .{ "nk", 1.0 / 1455100124 },
    .{ "kn", 1.0 / 1450401608 },
    .{ "gs", 1.0 / 1443474876 },
    .{ "dy", 1.0 / 1421751251 },
    .{ "hy", 1.0 / 1412343465 },
    .{ "ze", 1.0 / 1402290616 },
    .{ "ks", 1.0 / 1339590722 },
    .{ "xt", 1.0 / 1315669490 },
    .{ "bs", 1.0 / 1292319275 },
    .{ "ik", 1.0 / 1209994695 },
    .{ "dd", 1.0 / 1205446875 },
    .{ "cy", 1.0 / 1176324279 },
    .{ "rp", 1.0 / 1173542093 },
    .{ "sk", 1.0 / 1112771273 },
    .{ "xi", 1.0 / 1111463633 },
    .{ "oe", 1.0 / 1089254517 },
    .{ "oy", 1.0 / 1020190223 },
    .{ "ws", 1.0 / 989253674 },
    .{ "lv", 1.0 / 984229060 },
    .{ "dl", 1.0 / 911886482 },
    .{ "rf", 1.0 / 909634941 },
    .{ "eu", 1.0 / 878402090 },
    .{ "dg", 1.0 / 874188188 },
    .{ "wr", 1.0 / 867361010 },
    .{ "xa", 1.0 / 834649781 },
    .{ "yi", 1.0 / 812619095 },
    .{ "nm", 1.0 / 782441941 },
    .{ "eb", 1.0 / 763383542 },
    .{ "rb", 1.0 / 753194669 },
    .{ "tm", 1.0 / 746621025 },
    .{ "xc", 1.0 / 746076293 },
    .{ "eh", 1.0 / 742240059 },
    .{ "tc", 1.0 / 736955048 },
    .{ "gy", 1.0 / 731420025 },
    .{ "ja", 1.0 / 729206855 },
    .{ "hn", 1.0 / 726288117 },
    .{ "yp", 1.0 / 702499946 },
    .{ "za", 1.0 / 702199296 },
    .{ "gg", 1.0 / 697999944 },
    .{ "ym", 1.0 / 667551857 },
    .{ "sw", 1.0 / 663415953 },
    .{ "bj", 1.0 / 654853039 },
    .{ "lm", 1.0 / 649112313 },
    .{ "cs", 1.0 / 643530723 },
    .{ "ii", 1.0 / 642384029 },
    .{ "ix", 1.0 / 621227893 },
    .{ "xe", 1.0 / 614533122 },
    .{ "oh", 1.0 / 602121281 },
    .{ "lk", 1.0 / 555883002 },
    .{ "dv", 1.0 / 537221821 },
    .{ "lp", 1.0 / 536595562 },
    .{ "ax", 1.0 / 531206960 },
    .{ "ox", 1.0 / 523764012 },
    .{ "uf", 1.0 / 522547858 },
    .{ "dm", 1.0 / 512522701 },
    .{ "iu", 1.0 / 490874936 },
    .{ "sf", 1.0 / 483979931 },
    .{ "bt", 1.0 / 482272940 },
    .{ "ka", 1.0 / 478095427 },
    .{ "yt", 1.0 / 470429861 },
    .{ "ek", 1.0 / 464449289 },
    .{ "pm", 1.0 / 449910017 },
    .{ "ya", 1.0 / 444542870 },
    .{ "gt", 1.0 / 434302509 },
    .{ "wl", 1.0 / 429185823 },
    .{ "rh", 1.0 / 426095630 },
    .{ "yl", 1.0 / 416082307 },
    .{ "hs", 1.0 / 414044112 },
    .{ "ah", 1.0 / 384694919 },
    .{ "yc", 1.0 / 380670476 },
    .{ "yn", 1.0 / 372595315 },
    .{ "rw", 1.0 / 359714599 },
    .{ "hm", 1.0 / 359316447 },
    .{ "lw", 1.0 / 356374125 },
    .{ "hl", 1.0 / 355049620 },
    .{ "ae", 1.0 / 349540062 },
    .{ "zi", 1.0 / 341671190 },
    .{ "az", 1.0 / 334669428 },
    .{ "lc", 1.0 / 333338045 },
    .{ "py", 1.0 / 331698156 },
    .{ "aj", 1.0 / 331384552 },
    .{ "nj", 1.0 / 312598990 },
    .{ "bb", 1.0 / 308276690 },
    .{ "nh", 1.0 / 306883963 },
    .{ "uo", 1.0 / 300484143 },
    .{ "kl", 1.0 / 298033281 },
    .{ "lr", 1.0 / 283411884 },
    .{ "tn", 1.0 / 282266629 },
    .{ "gm", 1.0 / 277966576 },
    .{ "sn", 1.0 / 258702825 },
    .{ "nr", 1.0 / 258048421 },
    .{ "fy", 1.0 / 256535008 },
    .{ "mn", 1.0 / 247850339 },
    .{ "dw", 1.0 / 230152384 },
    .{ "sb", 1.0 / 223212317 },
    .{ "yr", 1.0 / 219696469 },
    .{ "dn", 1.0 / 213431654 },
    .{ "zo", 1.0 / 202480511 },
    .{ "oj", 1.0 / 196696657 },
    .{ "yd", 1.0 / 192245315 },
    .{ "lb", 1.0 / 188643782 },
    .{ "wt", 1.0 / 184446342 },
    .{ "lg", 1.0 / 171657388 },
    .{ "ko", 1.0 / 171324962 },
    .{ "np", 1.0 / 170186564 },
    .{ "sr", 1.0 / 168896339 },
    .{ "ky", 1.0 / 167761726 },
    .{ "ln", 1.0 / 165509578 },
    .{ "nw", 1.0 / 163456000 },
    .{ "tf", 1.0 / 159626603 },
    .{ "fs", 1.0 / 155349948 },
    .{ "dh", 1.0 / 153344431 },
    .{ "sd", 1.0 / 148275222 },
    .{ "vy", 1.0 / 138085211 },
    .{ "dj", 1.0 / 134832736 },
    .{ "hw", 1.0 / 134615178 },
    .{ "xu", 1.0 / 134528161 },
    .{ "ao", 1.0 / 130442323 },
    .{ "ml", 1.0 / 129888836 },
    .{ "uk", 1.0 / 129819900 },
    .{ "uy", 1.0 / 128782521 },
    .{ "ej", 1.0 / 128194584 },
    .{ "ez", 1.0 / 127540198 },
    .{ "hb", 1.0 / 123778334 },
    .{ "nz", 1.0 / 123192934 },
    .{ "nb", 1.0 / 122258836 },
    .{ "mc", 1.0 / 121591374 },
    .{ "yb", 1.0 / 121220723 },
    .{ "tp", 1.0 / 121089391 },
    .{ "xh", 1.0 / 117618666 },
    .{ "ux", 1.0 / 110947766 },
    .{ "tz", 1.0 / 108527540 },
    .{ "bv", 1.0 / 108385069 },
    .{ "mf", 1.0 / 107664447 },
    .{ "wd", 1.0 / 99767462 },
    .{ "oz", 1.0 / 97904996 },
    .{ "yw", 1.0 / 95070267 },
    .{ "kh", 1.0 / 89811517 },
    .{ "gd", 1.0 / 89087728 },
    .{ "bm", 1.0 / 88228719 },
    .{ "mr", 1.0 / 87580303 },
    .{ "ku", 1.0 / 85313841 },
    .{ "uv", 1.0 / 82252351 },
    .{ "dt", 1.0 / 81648332 },
    .{ "hd", 1.0 / 80544316 },
    .{ "aa", 1.0 / 79794787 },
    .{ "xx", 1.0 / 79068246 },
    .{ "df", 1.0 / 78347492 },
    .{ "db", 1.0 / 78190243 },
    .{ "ji", 1.0 / 77899882 },
    .{ "kr", 1.0 / 76743394 },
    .{ "xo", 1.0 / 76097183 },
    .{ "cm", 1.0 / 75144874 },
    .{ "zz", 1.0 / 75012595 },
    .{ "nx", 1.0 / 73899576 },
    .{ "yg", 1.0 / 73102462 },
    .{ "xy", 1.0 / 72645837 },
    .{ "kg", 1.0 / 72267691 },
    .{ "tb", 1.0 / 71746167 },
    .{ "dc", 1.0 / 71030077 },
    .{ "bd", 1.0 / 69761165 },
    .{ "sg", 1.0 / 69588685 },
    .{ "wy", 1.0 / 68368953 },
    .{ "zy", 1.0 / 66473188 },
    .{ "hf", 1.0 / 63249924 },
    .{ "cd", 1.0 / 62905910 },
    .{ "vu", 1.0 / 62384927 },
    .{ "kw", 1.0 / 61416538 },
    .{ "zu", 1.0 / 60692846 },
    .{ "bn", 1.0 / 59062122 },
    .{ "ih", 1.0 / 58966344 },
    .{ "tg", 1.0 / 55522877 },
    .{ "xv", 1.0 / 55076715 },
    .{ "uz", 1.0 / 53873803 },
    .{ "bc", 1.0 / 53278096 },
    .{ "xf", 1.0 / 52374239 },
    .{ "yz", 1.0 / 51097953 },
    .{ "km", 1.0 / 50449220 },
    .{ "dp", 1.0 / 48855638 },
    .{ "lh", 1.0 / 45643026 },
    .{ "wf", 1.0 / 45330551 },
    .{ "kf", 1.0 / 44759608 },
    .{ "pf", 1.0 / 41022263 },
    .{ "cf", 1.0 / 39704311 },
    .{ "mt", 1.0 / 38538709 },
    .{ "yu", 1.0 / 37436235 },
    .{ "cp", 1.0 / 37067423 },
    .{ "pb", 1.0 / 36901495 },
    .{ "td", 1.0 / 36539510 },
    .{ "zl", 1.0 / 35456851 },
    .{ "sv", 1.0 / 35005005 },
    .{ "hc", 1.0 / 34631551 },
    .{ "mg", 1.0 / 34537023 },
    .{ "pw", 1.0 / 34037460 },
    .{ "gf", 1.0 / 33962536 },
    .{ "pd", 1.0 / 33798376 },
    .{ "pn", 1.0 / 33536129 },
    .{ "pc", 1.0 / 33156666 },
    .{ "rx", 1.0 / 32990613 },
    .{ "tv", 1.0 / 32805751 },
    .{ "ij", 1.0 / 31324465 },
    .{ "wm", 1.0 / 30732232 },
    .{ "uh", 1.0 / 30097154 },
    .{ "wk", 1.0 / 30095733 },
    .{ "wb", 1.0 / 29929113 },
    .{ "bh", 1.0 / 29797934 },
    .{ "kt", 1.0 / 29132180 },
    .{ "kb", 1.0 / 25406204 },
    .{ "cg", 1.0 / 24975673 },
    .{ "vr", 1.0 / 24701238 },
    .{ "cn", 1.0 / 24249641 },
    .{ "pk", 1.0 / 23099462 },
    .{ "uu", 1.0 / 22006895 },
    .{ "yf", 1.0 / 21246637 },
    .{ "wp", 1.0 / 20982546 },
    .{ "cz", 1.0 / 20601701 },
    .{ "kp", 1.0 / 20492678 },
    .{ "wu", 1.0 / 19601657 },
    .{ "fm", 1.0 / 19340776 },
    .{ "wc", 1.0 / 19008254 },
    .{ "md", 1.0 / 18929019 },
    .{ "kd", 1.0 / 18894758 },
    .{ "zh", 1.0 / 18782710 },
    .{ "gw", 1.0 / 18260884 },
    .{ "rz", 1.0 / 17993128 },
    .{ "cb", 1.0 / 17751935 },
    .{ "iw", 1.0 / 17611969 },
    .{ "xl", 1.0 / 16728256 },
    .{ "hp", 1.0 / 16696129 },
    .{ "mw", 1.0 / 16465357 },
    .{ "vs", 1.0 / 16263248 },
    .{ "fc", 1.0 / 16254390 },
    .{ "rj", 1.0 / 15598009 },
    .{ "bp", 1.0 / 15427250 },
    .{ "mh", 1.0 / 15033898 },
    .{ "hh", 1.0 / 14730425 },
    .{ "yh", 1.0 / 14682887 },
    .{ "uj", 1.0 / 14548024 },
    .{ "fg", 1.0 / 14424524 },
    .{ "fd", 1.0 / 13966832 },
    .{ "gb", 1.0 / 13944852 },
    .{ "pg", 1.0 / 13354952 },
    .{ "tk", 1.0 / 13081991 },
    .{ "kk", 1.0 / 12782664 },
    .{ "fn", 1.0 / 11823066 },
    .{ "lz", 1.0 / 11767790 },
    .{ "vl", 1.0 / 11621019 },
    .{ "gp", 1.0 / 11612944 },
    .{ "hz", 1.0 / 10729982 },
    .{ "dk", 1.0 / 9494027 },
    .{ "yk", 1.0 / 9292584 },
    .{ "lx", 1.0 / 8612462 },
    .{ "vd", 1.0 / 8430332 },
    .{ "zs", 1.0 / 8395904 },
    .{ "bw", 1.0 / 8319869 },
    .{ "mv", 1.0 / 8172535 },
    .{ "uw", 1.0 / 7824504 },
    .{ "hg", 1.0 / 7789748 },
    .{ "fb", 1.0 / 7730842 },
    .{ "sj", 1.0 / 7621847 },
    .{ "ww", 1.0 / 7377619 },
    .{ "gk", 1.0 / 7338894 },
    .{ "bg", 1.0 / 7203255 },
    .{ "sz", 1.0 / 7041052 },
    .{ "jr", 1.0 / 6846578 },
    .{ "zt", 1.0 / 6627349 },
    .{ "hk", 1.0 / 6595610 },
    .{ "vc", 1.0 / 6570845 },
    .{ "xm", 1.0 / 6569222 },
    .{ "gc", 1.0 / 6455066 },
    .{ "fw", 1.0 / 6451511 },
    .{ "pz", 1.0 / 6382200 },
    .{ "kc", 1.0 / 6326022 },
    .{ "hv", 1.0 / 6292998 },
    .{ "xw", 1.0 / 6292525 },
    .{ "zw", 1.0 / 6279286 },
    .{ "fp", 1.0 / 6262895 },
    .{ "iy", 1.0 / 6247588 },
    .{ "pv", 1.0 / 6222096 },
    .{ "vt", 1.0 / 6181932 },
    .{ "jp", 1.0 / 6129447 },
    .{ "cv", 1.0 / 5869407 },
    .{ "zb", 1.0 / 5858211 },
    .{ "vp", 1.0 / 5510046 },
    .{ "zr", 1.0 / 5320518 },
    .{ "fh", 1.0 / 5166165 },
    .{ "yv", 1.0 / 5115763 },
    .{ "zg", 1.0 / 4726653 },
    .{ "zm", 1.0 / 4713608 },
    .{ "zv", 1.0 / 4618705 },
    .{ "kv", 1.0 / 4414960 },
    .{ "vn", 1.0 / 4317772 },
    .{ "zn", 1.0 / 4300522 },
    .{ "yx", 1.0 / 4211192 },
    .{ "jn", 1.0 / 4150888 },
    .{ "bf", 1.0 / 4108696 },
    .{ "mk", 1.0 / 3956883 },
    .{ "cw", 1.0 / 3909223 },
    .{ "jm", 1.0 / 3659540 },
    .{ "jh", 1.0 / 3541869 },
    .{ "kj", 1.0 / 3471162 },
    .{ "jc", 1.0 / 3447571 },
    .{ "gz", 1.0 / 3431194 },
    .{ "js", 1.0 / 3329038 },
    .{ "tx", 1.0 / 3328898 },
    .{ "fk", 1.0 / 3293208 },
    .{ "jl", 1.0 / 3192327 },
    .{ "vm", 1.0 / 3178223 },
    .{ "lj", 1.0 / 3169833 },
    .{ "tj", 1.0 / 3169658 },
    .{ "jj", 1.0 / 2979950 },
    .{ "cj", 1.0 / 2962048 },
    .{ "vg", 1.0 / 2960268 },
    .{ "mj", 1.0 / 2923325 },
    .{ "jt", 1.0 / 2917850 },
    .{ "pj", 1.0 / 2810773 },
    .{ "wg", 1.0 / 2751783 },
    .{ "vh", 1.0 / 2691078 },
    .{ "bk", 1.0 / 2639491 },
    .{ "vv", 1.0 / 2622571 },
    .{ "jd", 1.0 / 2615147 },
    .{ "vb", 1.0 / 2496014 },
    .{ "jf", 1.0 / 2421784 },
    .{ "dz", 1.0 / 2200704 },
    .{ "xb", 1.0 / 2164724 },
    .{ "jb", 1.0 / 2126115 },
    .{ "zc", 1.0 / 2100797 },
    .{ "fj", 1.0 / 2065436 },
    .{ "yy", 1.0 / 1993017 },
    .{ "xs", 1.0 / 1804740 },
    .{ "jk", 1.0 / 1740133 },
    .{ "jv", 1.0 / 1719726 },
    .{ "xn", 1.0 / 1613611 },
    .{ "vf", 1.0 / 1550317 },
    .{ "px", 1.0 / 1473468 },
    .{ "zd", 1.0 / 1415016 },
    .{ "zp", 1.0 / 1361846 },
    .{ "dx", 1.0 / 1296277 },
    .{ "hj", 1.0 / 1282370 },
    .{ "gv", 1.0 / 1192366 },
    .{ "jw", 1.0 / 1165914 },
    .{ "jy", 1.0 / 1120221 },
    .{ "gj", 1.0 / 1093028 },
    .{ "jg", 1.0 / 1034900 },
    .{ "bz", 1.0 / 1007374 },
    .{ "mx", 1.0 / 994334 },
    .{ "mz", 1.0 / 970282 },
    .{ "wj", 1.0 / 914179 },
    .{ "xr", 1.0 / 907409 },
    .{ "zk", 1.0 / 906537 },
    .{ "cx", 1.0 / 876736 },
    .{ "fx", 1.0 / 812116 },
    .{ "fv", 1.0 / 807297 },
    .{ "bx", 1.0 / 778622 },
    .{ "vw", 1.0 / 742188 },
    .{ "vj", 1.0 / 724370 },
    .{ "zf", 1.0 / 608389 },
    .{ "yj", 1.0 / 561334 },
    .{ "gx", 1.0 / 557030 },
    .{ "kx", 1.0 / 555422 },
    .{ "xg", 1.0 / 542548 },
    .{ "xj", 1.0 / 511074 },
    .{ "sx", 1.0 / 503772 },
    .{ "vz", 1.0 / 501189 },
    .{ "vx", 1.0 / 449854 },
    .{ "wv", 1.0 / 389123 },
    .{ "vk", 1.0 / 337545 },
    .{ "zj", 1.0 / 309029 },
    .{ "xk", 1.0 / 281255 },
    .{ "hx", 1.0 / 263997 },
    .{ "fz", 1.0 / 263860 },
    .{ "jz", 1.0 / 220675 },
    .{ "xd", 1.0 / 168263 },
    .{ "jx", 1.0 / 161750 },
    .{ "kz", 1.0 / 150760 },
    .{ "wx", 1.0 / 150637 },
    .{ "xz", 1.0 / 136521 },
    .{ "zx", 1.0 / 108224 },
    .{ "wz", 1.0 / 0 },
});