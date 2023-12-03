#! /usr/bin/awk -f

BEGIN { FS = "" }

{
    for (i = 1; i <= NF; i++) grid[NR, i] = $i
    full[NR] = $0
    fields = NF # assume all the same
}

END {
    for (row = 1; row <= NR; row++) {
	for (col = 1; col <= fields; col++) {
	    if (grid[row, col] ~ /[*]/ && check()) {
		tot += PROD
	    }
	}
    }
    print tot
}

# grid search for symbols from [row-1..row+1] and [col-1..col+1], skipping row
# and col themselves
function check(    j, k, n) {
    n = 0
    PROD = 1
    for (j = row-1; j <= row+1; j++) {
	for (k = col-1; k <= col+1; k++) {
	    if (j == row && k == col) continue
	    if ((j, k) in grid && grid[j, k] ~ /[0-9]/) {
		cur = current(j, k)
		PROD *= cur
		k = JMP
		n += 1
	    }
	}
    }
    return n == 2
}

# find the whole number the digit starting at grid[r, c] is part of
function current(r, c,    j, k, buf) {
    for (j = c; grid[r, j] ~ /[0-9]/; j--); # search left first
    for (k = c; grid[r, k] ~ /[0-9]/ && k <= fields; k++); # search right
    JMP = k # use a global to advance
    return substr(full[r], j+1, k-(j+1))
}
