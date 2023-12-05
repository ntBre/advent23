#! /usr/bin/awk -f

/seeds/ {
    # part 2
    # for (i = 2; i<=NF; i+=2) seeds[$i " " $i+$(i+1)]
    for (i = 2; i<=NF; i++) seeds[$i" "$i]
}
$2 ~ /map/ { state = $1; next }
/^$/ { next }

state == "seed-to-soil"            { make_map(seed_to_soil)            }
state == "soil-to-fertilizer"      { make_map(soil_to_fertilizer)      }
state == "fertilizer-to-water"     { make_map(fertilizer_to_water)     }
state == "water-to-light"          { make_map(water_to_light)          }
state == "light-to-temperature"    { make_map(light_to_temperature)    }
state == "temperature-to-humidity" { make_map(temperature_to_humidity) }
state == "humidity-to-location"    { make_map(humidity_to_location)    }

function update(seeds, map, new_seeds) {
    for (seed in seeds) {
	split(seed, sp); s1 = sp[1]; s2 = sp[2]
	g1 = get(map, s1)
	dst1 = dst; rng1 = rng # these get reset in each get call
	g2 = get(map, s2)
	print seed, "->", g1, g2
	# actually, let's split them both every time and just deal with
	# overlapping intervals
	end1 = min(g2, dst+rng)
	end2 = min()

	if (g1 - s1 == g2 - s2) { # both endpoints moved the same amount
	    new_seeds[g1" "g2]
	} else {
	    if (g1 - s1) { # s1 moved
		# s2 is the old endpoint, check if dst+rng less than it. if so,
		# that's the new end of the range and dst+rng+1 is the start of
		# the
		print "fst"
	    }
	    if (g2 - s2) {
		print "snd"
	    }
	    print "unhandled case!", src, dst, rng
	    exit 1
	}
	# TODO range could fracture in part 2, but for now it can't because the
	# endpoints are the same
    }
}

END {
    # idea: iteratively transform the seed values based on the mapping
    # functions. hardest part is controlling for splitting the ranges
    update(seeds, seed_to_soil, tmp); delete seeds
    print "==="
    update(tmp, soil_to_fertilizer, seeds); delete tmp
    print "==="
    update(seeds, fertilizer_to_water, tmp); delete seeds
    print "==="
    update(tmp, water_to_light, seeds); delete tmp
    print "==="
    update(seeds, light_to_temperature, tmp); delete seeds
    print "==="
    update(tmp, temperature_to_humidity, seeds); delete tmp
    print "==="
    update(seeds, humidity_to_location, tmp); delete seeds

    for (loc in tmp) {
	split(loc, sp)
	print sp[1] | "sort -n | sed 1q"
    }
}

# reports whether or not the range x1..x2 intersects the range y1..y2
function intersects(x1, x2, y1, y2) {
    # either
    # y1    x1    y2     x2
    # |-----|=====|------|
    # or
    # x1    y1    x2     y2
    # |-----|=====|------|
    if (x1 >= y1 && x1 <= y2) return x1" "min(x2, y2) # case 1
    if (y1 >= x1 && y1 <= x2) return x2" "min(x2, y2) # case 2
    return 0 # no overlap
}

function min(x, y) { return x < y ? x : y }

function get(arr, i,    a, sp) {
    for (a in arr) {
	split(a, sp)
	src = sp[2]; dst = sp[1]; rng = sp[3]
	if (i >= src && i < src+rng) {
	    return dst + (i - src)
	}
    }
    return i
}

function make_map(arr) { arr[$0] }
