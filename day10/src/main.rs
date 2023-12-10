use std::{
    cmp::max,
    fmt::{Debug, Display},
    fs::read_to_string,
    ops::Index,
    path::Path,
};

struct Grid(Vec<Vec<char>>);

impl Grid {
    fn load(path: impl AsRef<Path>) -> Self {
        Grid(
            read_to_string(path)
                .unwrap()
                .lines()
                .map(|s| s.chars().collect())
                .collect(),
        )
    }

    fn find_start(&self) -> Point {
        for (i, row) in self.0.iter().enumerate() {
            for (j, tile) in row.iter().enumerate() {
                if *tile == 'S' {
                    return (i, j);
                }
            }
        }
        unreachable!()
    }

    fn shape(&self) -> (usize, usize) {
        (self.0.len(), self.0[0].len())
    }

    #[allow(unused)]
    fn dump(&self) {
        for row in &self.0 {
            for tile in row {
                print!("{tile}");
            }
            println!();
        }
    }
}

impl Index<Point> for Grid {
    type Output = char;

    fn index(&self, (x, y): Point) -> &Self::Output {
        &self.0[x][y]
    }
}

type Point = (usize, usize);

fn main() {
    let grid = Grid::load("../input");
    let start = grid.find_start();
    let mut start = Node::new(0, start, start);
    assert!(start.update_children(&grid, start.pos));
    dbg!(start.max_dist() / 2);
}

#[derive(Clone)]
struct Node {
    dist: usize,
    pos: Point,
    parent: Point,
    children: Vec<Node>,
}

impl Debug for Node {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self)
    }
}

impl Display for Node {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let w = f.width().unwrap_or(0);
        write!(
            f,
            "Node(dist: {}, pos: {:?}, parent: {:?}, children: [",
            self.dist, self.pos, self.parent
        )?;
        for c in &self.children {
            write!(f, "\n")?;
            for _ in 0..w + 1 {
                write!(f, "\t")?;
            }
            write!(f, "{c:w$}", w = w + 2)?;
        }
        if !self.children.is_empty() {
            for _ in 0..w + 1 {
                write!(f, "\t")?;
            }
        }
        writeln!(f, "])")
    }
}

impl Node {
    fn new(dist: usize, pos: Point, parent: Point) -> Self {
        Self {
            dist,
            pos,
            parent,
            children: Vec::new(),
        }
    }

    fn update_children(&mut self, grid: &Grid, start: Point) -> bool {
        for pos in adjacent(&grid, self.pos) {
            if pos != self.parent {
                self.children.push(Node::new(self.dist + 1, pos, self.pos));
            }
        }
        let done = self.children.iter().any(|p| p.pos == start);
        if done {
            return done;
        }
        for child in self.children.iter_mut() {
            let done = child.update_children(grid, start);
            if done {
                return done;
            }
        }
        false
    }

    fn max_dist(&self) -> usize {
        max(
            self.dist,
            self.children
                .iter()
                .map(|c| c.max_dist())
                .max()
                .unwrap_or(0),
        )
    }
}

#[derive(PartialEq)]
enum Dir {
    N,
    S,
    E,
    W,
}

/// returns a list of pipes adjacent to `p`, including the parent
fn adjacent(grid: &Grid, p: Point) -> Vec<Point> {
    let (x, y) = p; // x is actually the vertical direction, oops
    let (r, c) = grid.shape();
    // TODO I'm not checking if the source pipe (pipe at p) can actually go in
    // all of these directions
    let pipe = grid[p];
    let mut ret = Vec::new();
    use Dir::*;
    let checks = match pipe {
        '|' => vec![N, S],
        '-' => vec![E, W],
        'L' => vec![N, E],
        'J' => vec![N, W],
        '7' => vec![S, W],
        'F' => vec![S, E],
        'S' => vec![N, S, E, W],
        _ => unreachable!(),
    };
    // from south
    if x > 0 && is_pipe(grid[(x - 1, y)], "|F7S") && checks.contains(&N) {
        ret.push((x - 1, y));
    }
    // from north
    if x < c - 1 && is_pipe(grid[(x + 1, y)], "|LJS") && checks.contains(&S) {
        ret.push((x + 1, y));
    }
    // from east
    if y > 0 && is_pipe(grid[(x, y - 1)], "-FLS") && checks.contains(&W) {
        ret.push((x, y - 1));
    }
    // from west
    if y < r - 1 && is_pipe(grid[(x, y + 1)], "-J7S") && checks.contains(&E) {
        ret.push((x, y + 1));
    }
    ret
}

fn is_pipe(c: char, typ: &str) -> bool {
    typ.contains(c)
}

#[test]
fn adj() {
    let tests = [
        ("sample", (1, 1), vec![(2, 1), (1, 2)]),
        ("sample", (2, 1), vec![(1, 1), (3, 1)]),
        ("sample", (1, 2), vec![(1, 1), (1, 3)]),
        ("sample", (1, 3), vec![(2, 3), (1, 2)]),
        ("sample", (3, 1), vec![(2, 1), (3, 2)]),
        //
        ("sample2", (1, 2), vec![(1, 1), (1, 3)]),
    ];

    for (t, (file, p, want)) in tests.into_iter().enumerate() {
        let grid = Grid::load(file);
        println!();
        grid.dump();
        let got = adjacent(&grid, p);
        assert_eq!(
            got, want,
            "test {t} failed on `{file}` and {p:?}:\ngot {got:?}, want {want:?}",
        );
    }
}

#[test]
fn full() {
    let tests = [
        ("sample", 4),  // simple short loop
        ("sample2", 4), // complex short loop
        ("sample3", 8), // simple long loop
        ("sample4", 8), // complex long loop
    ];
    for (file, want) in tests {
        let grid = Grid::load(file);
        let start = grid.find_start();
        let mut start = Node::new(0, start, start);
        let done = start.update_children(&grid, start.pos);
        // dbg!(&start);
        assert!(done);
        let got = start.max_dist() / 2;
        assert_eq!(got, want);
    }
}
