use std::ops::Range;

fn main() {
    let data = include_str!("../../input");
    let mut seeds: Vec<Range<usize>> = Vec::new();

    let mut seed_to_soil = Vec::new();
    let mut soil_to_fertilizer = Vec::new();
    let mut fertilizer_to_water = Vec::new();
    let mut water_to_light = Vec::new();
    let mut light_to_temperature = Vec::new();
    let mut temperature_to_humidity = Vec::new();
    let mut humidity_to_location = Vec::new();
    let mut state = "";
    for line in data.lines() {
        let sp: Vec<_> = line.split_ascii_whitespace().collect();
        if line.starts_with("seeds") {
            for i in (1..sp.len()).step_by(2) {
                seeds.push(
                    sp[i].parse::<usize>().unwrap()
                        ..sp[i + 1].parse::<usize>().unwrap(),
                );
            }
        } else if line.is_empty() {
            continue;
        } else if sp[1].starts_with("map") {
            state = sp[0];
            continue;
        } else if state == "seed-to-soil" {
            seed_to_soil.push(make_map(sp));
        } else if state == "soil-to-fertilizer" {
            soil_to_fertilizer.push(make_map(sp));
        } else if state == "fertilizer-to-water" {
            fertilizer_to_water.push(make_map(sp));
        } else if state == "water-to-light" {
            water_to_light.push(make_map(sp));
        } else if state == "light-to-temperature" {
            light_to_temperature.push(make_map(sp));
        } else if state == "temperature-to-humidity" {
            temperature_to_humidity.push(make_map(sp));
        } else if state == "humidity-to-location" {
            humidity_to_location.push(make_map(sp));
        }
    }

    let mut res = usize::MAX;
    for (i, s) in seeds.iter().enumerate() {
        for j in s.start..s.start + s.end {
            let x = get(
                &humidity_to_location,
                get(
                    &temperature_to_humidity,
                    get(
                        &light_to_temperature,
                        get(
                            &water_to_light,
                            get(
                                &fertilizer_to_water,
                                get(&soil_to_fertilizer, get(&seed_to_soil, j)),
                            ),
                        ),
                    ),
                ),
            );
            res = res.min(x);
        }
        println!("finished seed {i} / {}", seeds.len());
    }

    dbg!(res);
}

fn get(arr: &Vec<(usize, usize, usize)>, i: usize) -> usize {
    for (dst, src, rng) in arr {
        if i >= *src && i < src + rng {
            return dst + (i - src);
        }
    }
    return i;
}

fn make_map(sp: Vec<&str>) -> (usize, usize, usize) {
    assert_eq!(sp.len(), 3);
    (
        sp[0].parse().unwrap(),
        sp[1].parse().unwrap(),
        sp[2].parse().unwrap(),
    )
}
