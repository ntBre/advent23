#! /usr/bin/awk -f

/seeds/ {
    if (part2) {
		for (i = 2; i<=NF; i+=2) seeds[$i " " $i+$(i+1)]
    } else {
		for (i = 2; i<=NF; i++) seeds[$i" "$i]
    }
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

# 82, 84, 84, 84, 77, 45, 46, 46

function update(seeds, map, new_seeds,    m, sp) {
    for (seed in seeds) {
		split(seed, sp); s1 = sp[1]; s2 = sp[2]
		found = 0
		printf "seed = %d..%d\n", s1, s2
		for (m in map) {
			split(m, sp); src = sp[2]; dst = sp[1]; rng = sp[3]
			printf "\tsrc = %d..%d->%d..%d ", src, src+rng, dst, dst+rng
			if (src < s1 && src+rng >= s2) { # fully enclosing
				print "case 1:", dst-src
				new_seeds[get(map, s1)" "get(map, s2)]
				found = 1
			} else if (src > s1 && src < s2 && src+rng < s2) { # fully enclosed
				print "case 2"
				new_seeds[s1" "src-1]
				new_seeds[src+rng" "s2]
				new_seeds[dst" "dst+rng]
				found = 1
			} else if (src < s1 && src+rng > s1 && src+rng < s2) { # s1 captured
				print "case 3", src, dst
				g1 = get(map, s1)
				new_seeds[g1" "dst+rng]
				new_seeds[src+rng+1" "s2]
				found = 1
			} else if (src > s1 && src < s2 && src+rng > s2) { # s2 captured
				print "case 4"
				g2 = get(map, s2)
				new_seeds[s1" "src-1]
				new_seeds[dst" "g2]
				found = 1
			} else if (src > s2 || src+rng < s1) { # disjoint
				print "case 5"
			} else {
				exit 6 # unreachable
			}
			if (found) break
		}

		if (!found) new_seeds[seed]
		print ""
    }
}

END {
    # idea: iteratively transform the seed values based on the mapping
    # functions. hardest part is controlling for splitting the ranges

    print "seed->soil"
    update(seeds, seed_to_soil, tmp); delete seeds
    print "soil->fertilizer"
    update(tmp, soil_to_fertilizer, seeds); delete tmp
    print "fertilizer->water"
    update(seeds, fertilizer_to_water, tmp); delete seeds
    print "water->light"
    update(tmp, water_to_light, seeds); delete tmp
    print "light->temperature"
    update(seeds, light_to_temperature, tmp); delete seeds
    print "temperature->humidity"
    update(tmp, temperature_to_humidity, seeds); delete tmp
    print "humidity->location"
    update(seeds, humidity_to_location, tmp); delete seeds

    for (loc in tmp) {
		split(loc, sp)
		print sp[1] | "sort -n | sed 1q"
    }
    print 324724204
}

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

function min(x, y) { return x < y ? x : y }
function max(x, y) { return x > y ? x : y }

# reports whether or not the range x1..x2 intersects the range y1..y2
function intersects(x1, x2, y1, y2,    tmp) {
    # either
    # y1    x1    y2     x2
    # |-----|=====|------|
    # or
    # x1    y1    x2     y2
    # |-----|=====|------|
    if (x1 >= y1 && x1 <= y2) { # case 1
		return x1" "min(x2, y2)
    }
    if (y1 >= x1 && y1 <= x2) { # case 2
		return y1" "min(x2, y2)
    }
    return 0 # no overlap
}
