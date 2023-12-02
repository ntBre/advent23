#! /usr/bin/awk -f

BEGIN { max_red = 12; max_green = 13; max_blue = 14 }

{
    # Input like:
    # Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green

    # Extract the game number and then remove game prefix
    game = substr($2, 1, length($2)-1);
    colon = index($0, ":")
    $0 = substr($0, colon+1)

    print game, $0

    split($0, rounds, ";")
    for (round in rounds) {
	printf "\t%s\n", rounds[round]
	if (!is_valid(rounds[round])) {
	    next
	}
    }
    sum += game
}

END { print sum }

# check if a single round is valid
function is_valid(r,     red, green, blue, buf) {
    red = 0; green = 0; blue = 0
    if (match(r, /([0-9]+) red/, buf)) red = buf[1]
    if (match(r, /([0-9]+) green/, buf)) green = buf[1]
    if (match(r, /([0-9]+) blue/, buf)) blue = buf[1]

    return red <= max_red && green <= max_green && blue <= max_blue
}
