use std::fs::read_to_string;

fn main() {
    let inp = std::env::args().nth(1).unwrap();
    dbg!(part1(&inp), part2(&inp));
}

fn inner(
    inp: &str,
    get: fn(v: &Vec<isize>) -> isize,
    add: fn(v: &mut Vec<isize>, x: isize, y: isize),
) -> isize {
    load(inp).into_iter().fold(0, |acc, line| {
        let mut rows = reduce(line);
        for r in (1..rows.len()).rev() {
            let x = get(&rows[r]);
            let y = get(&rows[r - 1]);
            add(&mut rows[r - 1], x, y);
        }
        acc + get(&rows[0])
    })
}

fn part1(inp: &str) -> isize {
    inner(inp, |v| v[v.len() - 1], |v, x, y| v.push(x + y))
}

fn part2(inp: &str) -> isize {
    inner(inp, |v| v[0], |v, x, y| v.insert(0, y - x))
}

fn load(inp: &str) -> Vec<Vec<isize>> {
    read_to_string(inp)
        .unwrap()
        .lines()
        .map(|line| {
            line.split_ascii_whitespace().flat_map(str::parse).collect()
        })
        .collect()
}

fn reduce(mut line: Vec<isize>) -> Vec<Vec<isize>> {
    let mut ret = vec![line.clone()];
    while !line.iter().all(|&x| x == 0) {
        let buf: Vec<_> =
            (1..line.len()).map(|i| line[i] - line[i - 1]).collect();
        line = buf.clone();
        ret.push(buf);
    }
    ret
}

#[test]
fn check() {
    assert_eq!(part1("input"), 1479011877);
    assert_eq!(part2("input"), 973);
}
