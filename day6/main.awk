#! /usr/bin/awk -f

{print}
/Time/ { for (i = 2; i<=NF; i++) time = time $i }
/Distance/ { for (i = 2; i<=NF; i++) dist = dist $i }

END {
	prod = 1
	print(time, dist)
	c = count(int(time), int(dist))
	print c
}

# return the number of ways to beat dist
function count(time, dist,    i, j, got, res) {
	# i is the number of seconds held, skipping both the whole time and zero.
	# this means i is also the speed after holding
	res = 0
	j = 0
	for (i = time-1; i > j; i--) {
		got = (time - i) * i # distance = speed * time
		if (got > dist) res+=2
		j++
	}
	return res
}
