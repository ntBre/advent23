#! /usr/bin/awk -f

{
    print
    check = 0; n = 0; delete found # reset for each line
    for (i = 3; i <= NF; i++) {
	if ($i ~ /[|]/) {
	    check = 1
	    continue
	}
	if (!check) found[$i]
	if (check && $i in found) n++
    }
    cards[NR]++ # instances of the NRth card generated
    for (; n > 0; n--) cards[NR+n] += cards[NR]
}

END {
    for (i = 1; i<=NR; i++) tot += cards[i]
    print tot
}

function max(n, m) { return n > m ? n : m }
