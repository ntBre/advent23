#!/usr/bin/awk -f

# locate all the symbols in the input
BEGIN { FS = "" }

{
    for (i = 1; i <= NF; i++) {
	if ($i !~ /[0-9.]/) {
	    print $i | "sort -u | paste -sd'.' | sed 's/\\.//g'"
	}
    }
}
