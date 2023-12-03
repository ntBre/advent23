#! /usr/bin/awk -f

BEGIN { FS = "" }

{
    for (i = 1; i <= NF; i++) grid[NR, i] = $i
    full[NR] = $0
    fields = NF # assume all the same
}

END {
    for (row = 1; row <= NR; row++) {
	for (i = 1; i <= fields; i++) {
	    c = check()
	    if (grid[row, i] ~ /[0-9]/ && c) {
		cur = current()
		tot += cur
	    }
	}
    }
    print tot
}

# grid search for symbols from [row-1..row+1] and [i-1..i+1], skipping row and i
# themselves
function check(    j, k) {
    for (j = row-1; j <= row+1; j++) {
	for (k = i-1; k <= i+1; k++) {
	    if (j == row && k == i) continue
	    if ((j, k) in grid && grid[j, k] ~ /[#$%&*+/=@-]/) {
		return grid[j, k];
	    }
	}
    }
    return 0
}

# find the whole number the current digit is part of
function current(    j, k, buf) {
    for (j = i; grid[row, j] ~ /[0-9]/; j--) # search left first
    for (k = i; grid[row, k] ~ /[0-9]/ && k <= fields; k++); # search right
    i = k # advance i beyond the current digit
    return substr(full[row], j+1, k-(j+1))
}
