#! /usr/bin/awk -f

BEGIN { FS = "" }

NR == 1 {
	for (i = 1; i<=NF; i++)
		steps[i-1] = $i
	FS = " "
}

NR > 2 {
	left = substr($3, 2, 3)
	right = substr($4, 1, 3)
	lefts[$1] = left
	rights[$1] = right
}

END {
	cur = "AAA"
	while (cur != "ZZZ") {
		switch (steps[s++ % length(steps)]) {
		case "R":
			cur = rights[cur]
			break
		case "L":
			cur = lefts[cur]
			break
		default:
			print "unexpected input"
			exit 1
		}
	}
	print s
}
