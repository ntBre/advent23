use std::fs::read_to_string;

fn main() {
    let inp = std::env::args().nth(1).unwrap();
    let sum = part2(&inp);
    dbg!(sum);
}

#[allow(unused)]
fn part1(inp: &str) -> isize {
    let lines = load(inp);

    let mut sum = 0;
    for line in lines {
        let mut rows = reduce(line);
        let mut a;
        for r in (1..rows.len()).rev() {
            let x = rows[r].last().unwrap();
            let y = rows[r - 1].last().unwrap();
            a = x + y;
            rows[r - 1].push(a);
        }
        sum += rows[0].last().unwrap();
    }
    sum
}

fn part2(inp: &str) -> isize {
    let lines = load(inp);

    let mut sum = 0;
    for line in lines {
        let mut rows = reduce(line);
        let mut a;
        for r in (1..rows.len()).rev() {
            let x = rows[r].first().unwrap();
            let y = rows[r - 1].first().unwrap();
            a = y - x;
            rows[r - 1].insert(0, a);
        }
        sum += rows[0].first().unwrap();
    }
    sum
}

fn load(inp: &str) -> Vec<Vec<isize>> {
    let s = read_to_string(inp).unwrap();

    let mut lines = Vec::new();
    for line in s.lines() {
        let l: Vec<_> = line
            .split_ascii_whitespace()
            .map(|s| s.parse::<isize>().unwrap())
            .collect();
        lines.push(l);
    }
    lines
}

fn reduce(mut line: Vec<isize>) -> Vec<Vec<isize>> {
    let mut ret = Vec::new();
    ret.push(line.clone());
    while !line.iter().all(|&x| x == 0) {
        let mut buf = Vec::new();
        for i in 1..line.len() {
            let d = line[i] - line[i - 1];
            buf.push(d);
        }
        line = buf.clone();
        ret.push(buf);
    }
    ret
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn p1() {
        assert_eq!(part1("input"), 1479011877);
    }

    #[test]
    fn p2() {
        assert_eq!(part2("input"), 973);
    }
}
