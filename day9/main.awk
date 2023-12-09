#! /usr/bin/awk -f

NR == 1 {
	for (i = 1; i <= NF; i++) {
		lines[NR, i] = $i
	}
}

END {
	for (l = 1; l <= NR; l++) {
		for (i = 1; i <= NF; i++) {
			print lines[l, i]
		}
	}
}
