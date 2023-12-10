use std::{fs::read_to_string, ops::Index};

struct Grid(Vec<Vec<char>>);

impl Grid {
    fn shape(&self) -> (usize, usize) {
        (self.0.len(), self.0[0].len())
    }

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
    let s = read_to_string("../sample").unwrap();
    let grid = Grid(s.lines().map(|s| s.chars().collect()).collect());

    let mut start = None;
    'outer: for (i, row) in grid.0.iter().enumerate() {
        for (j, tile) in row.iter().enumerate() {
            if *tile == 'S' {
                start = Some((i, j));
                break 'outer;
            }
        }
    }

    let start = start.unwrap();
    let mut start = Node::new(0, start, start);
    grid.dump();
    let done = start.update_children(&grid, start.pos);
    dbg!(done);

    dbg!(start);
}

#[derive(Clone, Debug)]
struct Node {
    dist: usize,
    pos: Point,
    parent: Point,
    children: Vec<Node>,
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
}

/// returns a list of pipes adjacent to `p`, including the parent
fn adjacent(grid: &Grid, p: Point) -> Vec<Point> {
    let (x, y) = p; // x is actually the vertical direction, oops
    let (r, c) = grid.shape();
    let mut ret = Vec::new();
    // from south
    if x > 0 && is_pipe(grid[(x - 1, y)], "|F7S") {
        ret.push((x - 1, y));
    }
    // from north
    if x < c - 2 && is_pipe(grid[(x + 1, y)], "|LJS") {
        ret.push((x + 1, y));
    }
    // from east
    if y > 0 && is_pipe(grid[(x, y - 1)], "-FLS") {
        ret.push((x, y - 1));
    }
    // from west
    if y < r - 2 && is_pipe(grid[(x, y + 1)], "-J7S") {
        ret.push((x, y + 1));
    }
    ret
}

fn is_pipe(c: char, typ: &str) -> bool {
    typ.contains(c)
}

#[test]
fn adj() {
    let s = read_to_string("sample").unwrap();
    let grid = Grid(s.lines().map(|s| s.chars().collect()).collect());
    grid.dump();
    let tests = [
        ((1, 1), vec![(2, 1), (1, 2)]),
        ((2, 1), vec![(1, 1), (3, 1)]),
        ((1, 2), vec![(1, 1), (1, 3)]),
        ((1, 3), vec![(2, 3), (1, 2)]),
        ((3, 1), vec![(2, 1), (3, 2)]),
    ];

    for (p, want) in tests {
        let got = adjacent(&grid, p);
        assert_eq!(got, want);
    }
}
