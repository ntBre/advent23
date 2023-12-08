use std::{
    cmp::{max, min},
    fs::read_to_string,
};

const A: u16 = 10;
const Z: u16 = 35;

fn main() {
    let inp = std::env::args().nth(1).unwrap();
    let s = read_to_string(inp).unwrap();
    let mut steps = Vec::new();
    let mut labels = Vec::new();
    let mut lefts = [0; 36 * 36 * 36];
    let mut rights = [0; 36 * 36 * 36];
    for (nr, line) in s.lines().enumerate() {
        if nr == 0 {
            steps = line.chars().map(|c| c == 'R').collect();
        } else if nr > 1 {
            let mut sp = line.split_ascii_whitespace();
            let label = sp.next().unwrap();
            let left = &sp.nth(1).unwrap()[1..4];
            let right = &sp.next().unwrap()[0..3];
            let label = usize::from_str_radix(label, 36).unwrap();
            let left = u16::from_str_radix(left, 36).unwrap();
            let right = u16::from_str_radix(right, 36).unwrap();
            labels.push(label);
            lefts[label] = left;
            rights[label] = right;
        }
    }

    let mut cur = Vec::new();
    for node in labels {
        if ends_with(node as u16, A) {
            cur.push(node as u16);
        }
    }

    let sl = steps.len();
    let mut res = Vec::new();
    for n in cur.iter_mut() {
        let mut i = 0;
        while !ends_with(*n, Z) {
            let t = if steps[i % sl] { &rights } else { &lefts };
            *n = t[*n as usize];
            i += 1;
        }
        res.push(i);
    }
    let ret = lcm(res);
    dbg!(ret);
}

fn lcm(res: Vec<usize>) -> usize {
    let mut ret = res[0];
    for r in &res[1..] {
        ret = ret * r / gcd(ret, *r);
    }
    ret
}

fn gcd(a: usize, b: usize) -> usize {
    let mut ks = vec![max(a, b), min(a, b)];
    for k in 2.. {
        let rk = ks[k - 2] % ks[k - 1];
        if rk == 0 {
            return ks[k - 1];
        }
        ks.push(rk);
    }
    unreachable!()
}

#[inline]
const fn ends_with(s: u16, c: u16) -> bool {
    s % 36 == c
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn ending() {
        let tests = [
            ("11A", A, true),
            ("11B", A, false),
            ("11Z", A, false),
            ("11Z", Z, true),
            ("22A", A, true),
            ("22B", A, false),
            ("22C", A, false),
            ("22Z", A, false),
            ("22Z", Z, true),
            ("XXX", A, false),
            ("XXX", Z, false),
        ];

        for (s, c, want) in tests {
            let s = u16::from_str_radix(s, 36).unwrap();
            assert_eq!(ends_with(s, c), want);
        }
    }
}
