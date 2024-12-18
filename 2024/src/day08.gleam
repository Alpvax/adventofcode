import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/set
import gleam/string
import gleam/yielder
import simplifile

pub fn main() {
  let assert Ok(file) = simplifile.read("../input/2024/08.txt")
  //   let file =
  //     "............
  // ........0...
  // .....0......
  // .......0....
  // ....0.......
  // ......A.....
  // ............
  // ............
  // ........A...
  // .........A..
  // ............
  // ............"
  let #(height, width, antennae) =
    list.fold(string.split(file, "\n"), #(0, 0, dict.new()), fn(acc, line) {
      let #(y, width, map) = acc
      let #(w, map) =
        list.fold(string.to_graphemes(line), #(0, map), fn(row_acc, char) {
          let #(x, map) = row_acc
          #(x + 1, case char {
            "." -> map
            _ ->
              dict.upsert(map, char, fn(cell) {
                option.unwrap(cell, set.new()) |> set.insert(#(x, y))
              })
          })
        })
      #(y + 1, int.max(width, w), map)
    })
  part1(height, width, antennae)
  // |> io.debug
  |> set.size
  |> io.debug
  part2(height, width, antennae)
  |> set.size
  |> io.debug
}

fn part1(
  height: Int,
  width: Int,
  antennae: dict.Dict(String, set.Set(#(Int, Int))),
) {
  use nodes, _char, positions <- dict.fold(antennae, set.new())
  use nodes, #(#(x1, y1), #(x2, y2)) <- list.fold(
    set.to_list(positions) |> list.combination_pairs,
    nodes,
  )
  let dx = x1 - x2
  let dy = y1 - y2
  // let _ =
  //   io.debug(
  //     #("Calculating for: " <> char, #(x1, y1), #(x2, y2), [
  //       #(x1 - 2 * dx, y1 - 2 * dy),
  //       #(x1 + dx, y1 + dy),
  //     ]),
  //   )
  use nodes, #(x, y) <- list.fold(
    [#(x1 - 2 * dx, y1 - 2 * dy), #(x1 + dx, y1 + dy)],
    nodes,
  )
  case x >= 0 && x < width && y >= 0 && y < height {
    True -> set.insert(nodes, #(x, y))
    _ -> nodes
  }
}

fn yield_until(
  yield: yielder.Yielder(#(Int, Int)),
  x: Int,
  y: Int,
  dx: Int,
  dy: Int,
  width: Int,
  height: Int,
) -> yielder.Yielder(#(Int, Int)) {
  let x1 = x + dx
  let y1 = y + dy
  case x1 < 0 || x1 >= width || y1 < 0 || y1 >= height {
    True -> yield
    _ ->
      yield_until(
        yielder.yield(#(x1, y1), fn() { yield }),
        x1,
        y1,
        dx,
        dy,
        width,
        height,
      )
  }
}

fn part2(
  height: Int,
  width: Int,
  antennae: dict.Dict(String, set.Set(#(Int, Int))),
) {
  use nodes, _char, positions <- dict.fold(antennae, set.new())
  use nodes, #(#(x1, y1), #(x2, y2)) <- list.fold(
    set.to_list(positions) |> list.combination_pairs,
    nodes,
  )
  let dx = x1 - x2
  let dy = y1 - y2
  use nodes, #(x, y) <- yielder.fold(
    yielder.append(
      yield_until(yielder.empty(), x1, y1, -dx, -dy, width, height),
      yield_until(yielder.empty(), x2, y2, dx, dy, width, height),
    ),
    nodes,
  )
  set.insert(nodes, #(x, y))
}
