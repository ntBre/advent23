#! /usr/bin/awk -f

BEGIN { FS = ""; part2 = 1 }

function is_number(b) {
    if      (b ~   /one/) { idx = index(b,   "one"); return 1 }
    else if (b ~   /two/) { idx = index(b,   "two"); return 2 }
    else if (b ~ /three/) { idx = index(b, "three"); return 3 }
    else if (b ~  /four/) { idx = index(b,  "four"); return 4 }
    else if (b ~  /five/) { idx = index(b,  "five"); return 5 }
    else if (b ~   /six/) { idx = index(b,   "six"); return 6 }
    else if (b ~ /seven/) { idx = index(b, "seven"); return 7 }
    else if (b ~ /eight/) { idx = index(b, "eight"); return 8 }
    else if (b ~  /nine/) { idx = index(b,  "nine"); return 9 }
    else                  { idx = 0; return 0 }
}

{
    buf = ""
    len = 0
    for (i = 1; i<=NF; i++) {
	if ($i ~ /[1-9]/) {
	    nums[len++] = $i
	    buf = ""
	} else if (part2) {
	    buf = buf $i
	    test = is_number(buf)
	    if (test) {
		nums[len++] = test
		buf = substr(buf, idx+1)
	    }
	}
    }
    tot = nums[0] "" nums[len-1]
    sum += tot
}

END { print sum }
