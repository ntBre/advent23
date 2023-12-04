#! /usr/bin/awk -f

{
    print
    check = 0; n = 0
    delete found
    for (i = 3; i <= NF; i++) {
	if ($i ~ /[|]/) {
	    check = 1
	    continue
	}
	if (!check) found[$i]
	if (check && $i in found) n++
    }
    score = n > 0 ? 2^(n-1) : 0
    tot += score
    print score
}

END { print tot }
