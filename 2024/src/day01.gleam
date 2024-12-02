import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/string
import simplifile

pub fn main() {
  let assert Ok(file) = simplifile.read("../input/2024/01.txt")
  let #(a, b) = {
    use #(a, b), line <- list.fold(string.split(file, "\n"), #([], []))
    case string.split_once(line, "   ") {
      Ok(#(l, r)) -> {
        let assert Ok(l) = int.parse(l)
        let assert Ok(r) = int.parse(r)
        #([l, ..a], [r, ..b])
      }
      Error(_) -> #(a, b)
    }
  }
  part1(a, b)
  |> io.debug
  part2(a, b)
  |> io.debug
  // part2([3, 4, 2, 1, 3, 3], [4, 3, 5, 3, 9, 3]) |> io.debug
}

fn part1(a, b) {
  {
    use a, b <- list.map2(list.sort(a, int.compare), list.sort(b, int.compare))
    int.absolute_value(a - b)
  }
  |> int.sum
}

fn part2(a, b) {
  let counts =
    list.fold(b, dict.new(), fn(d, i) {
      dict.upsert(d, i, fn(o) { option.unwrap(o, 0) + 1 })
    })
  {
    use a <- list.map(a)
    case dict.get(counts, a) {
      Ok(c) -> a * c
      Error(_) -> 0
    }
  }
  |> int.sum
}
