#! /usr/bin/awk -f

/seeds/ { for (i = 2; i<=NF; i++) seeds[$i] }
$2 ~ /map/ { state = $1; next }
/^$/ { next }

state == "seed-to-soil"            { make_map(seed_to_soil)            }
state == "soil-to-fertilizer"      { make_map(soil_to_fertilizer)      }
state == "fertilizer-to-water"     { make_map(fertilizer_to_water)     }
state == "water-to-light"          { make_map(water_to_light)          }
state == "light-to-temperature"    { make_map(light_to_temperature)    }
state == "temperature-to-humidity" { make_map(temperature_to_humidity) }
state == "humidity-to-location"    { make_map(humidity_to_location)    }

END {
    for (s in seeds) {
	x = get(humidity_to_location,
		get(temperature_to_humidity,
		    get(light_to_temperature,
			get(water_to_light,
			    get(fertilizer_to_water,
				get(soil_to_fertilizer,
				    get(seed_to_soil, s)))))))
	print x | " sort -n | sed 1q"
    }
}

function get(arr, i,    a, sp) {
    for (a in arr) {
	split(a, sp)
	src = sp[2]; dst = sp[1]; rng = sp[3]
	if (i >= src && i <= src+rng) {
	    return dst + (i - src)
	}
    }
    return i
}

function make_map(arr) { arr[$0] }
