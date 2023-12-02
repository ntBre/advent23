#! /usr/bin/awk -f

{
    # Input like:
    # Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green

    # Extract the game number and then remove game prefix
    game = substr($2, 1, length($2)-1);
    colon = index($0, ":")
    $0 = substr($0, colon+1)

    print game, $0

    split($0, rounds, ";")
    max_red = 0; max_green = 0; max_blue = 0
    for (round in rounds) {
	is_valid(rounds[round]); # reuse to set global colors
	max_red = max(max_red, red)
	max_green = max(max_green, green)
	max_blue = max(max_blue, blue)
    }
    power = max_red * max_green * max_blue
    sum += power
}

END { print sum }

# check if a single round is valid
function is_valid(r,     buf) {
    red = 0; green = 0; blue = 0
    if (match(r, /([0-9]+) red/, buf)) red = buf[1]
    if (match(r, /([0-9]+) green/, buf)) green = buf[1]
    if (match(r, /([0-9]+) blue/, buf)) blue = buf[1]

    return red <= max_red && green <= max_green && blue <= max_blue
}

function max(n, m) { return n > m ? n : m }
