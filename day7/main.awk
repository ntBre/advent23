#! /bin/bash

awk '
BEGIN { FS = "" }
{
	delete hand; buf = ""
	for (i = 1; i<=5; i++) {
		switch ($i) {
		case "T": v = 10; break
		case "J": v = 11; break
		case "Q": v = 12; break
		case "K": v = 13; break
		case "A": v = 14; break
		default:  v = $i; break
		}
		buf = buf " " v
		hand[$i]++
	}
	switch (length(hand)) {
	case 1:
		score = 7
		break
	case 2:
		if (is_full_house(hand))
			score = 5
		else
			score = 6
		break
	case 3:
		if (is_two_pair(hand))
			score = 3
		else
			score = 4
		break
	case 4:
		score = 2
		break
	case 5:
		score = 1
		break
	default: print "disaster"; exit 1
	}
	buf = score " " buf

	bid = substr($0, 6)
	print buf, bid, $0
}

function is_full_house(hand) {
	for (h in hand)
		if (hand[h] == 4)
			return 0
	return 1
}

function is_two_pair(hand) {
	for (h in hand)
		if (hand[h] == 3)
			return 0
	return 1
}
' input | sort -n -k1 -k2 -k3 -k4 -k5 -k6 | awk '{print} {sum += NR * $NF} END { print sum }'

# solution 250946742
