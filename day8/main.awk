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
	for (node in lefts) {
		if (ends_with(node, "A")) {
			cur[c++] = node
		}
	}
	while (!check(cur)) {
		for (n in cur) {
			switch (steps[res % length(steps)]) {
			case "R":
				cur[n] = rights[cur[n]]
				break
			case "L":
				cur[n] = lefts[cur[n]]
				break
			default:
				print "unexpected input"
				exit 1
			}
		}
		# for (c in cur) printf " %s", cur[c]
		# print ""
		res++
	}
	print res
}

function ends_with(s, c) { return substr(s, 3) == c }

function check(nodes,    n) {
	for (n in nodes) {
		if (!ends_with(nodes[n], "Z")) {
			return 0;
		}
	}
	return 1
}
