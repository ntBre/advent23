#! /usr/bin/awk -f

{print}
/Time/ { for (i = 2; i<=NF; i++) times[i-1] = $i }
/Distance/ { for (i = 2; i<=NF; i++) dists[i-1] = $i }

END {
	prod = 1
	for (i = 1; i<=NF; i++) {
		c = count(times[i], dists[i])
		print times[i], dists[i], c
		if (c) prod *= c
	}
	print prod
}

# return the number of ways to beat dist
function count(time, dist,    i, got, res) {
	# i is the number of seconds held, skipping both the whole time and zero.
	# this means i is also the speed after holding
	res = 0
	for (i = time-1; i > 0; i--) {
		got = (time - i) * i # distance = speed * time
		if (got > dist) res++
	}
	return res
}
