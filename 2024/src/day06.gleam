import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/set
import gleam/string
import gleam/yielder
import simplifile

pub fn main() {
  let assert Ok(file) = simplifile.read("../input/2024/06.txt")
  let file =
    "....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#..."
  let map = list.map(string.split(file, "\n"), string.to_graphemes)
  let assert Ok(guard) =
    yielder.from_list(map)
    |> yielder.map(fn(row) { yielder.from_list(row) |> yielder.index })
    |> yielder.index
    |> yielder.flat_map(fn(r) {
      let #(row, y) = r
      use #(c, x) <- yielder.map(row)
      #(x, y, c)
    })
    |> yielder.find_map(fn(cell) {
      case cell {
        #(x, y, "^") -> Ok(#(x, y))
        _ -> Error(Nil)
      }
    })

  part1(map, guard)
  |> io.debug
  part2(map, guard)
  |> io.debug
}

// fn find_guard(map: List(List(String))) -> Option(#(Int, Int)) {
//   case list {
//     [] -> None
//     [row, ..rest] -> 
//   }
// }

fn get(map: List(List(String)), x: Int, y: Int) -> Option(String) {
  case y >= 0, list.split(map, y) {
    True, #(_, [row, ..]) ->
      case x >= 0, list.split(row, x) {
        True, #(_, [val, ..]) -> Some(val)
        _, _ -> None
      }
    _, _ -> None
  }
}

fn display_map(map: List(List(String)), visited: set.Set(#(Int, Int))) {
  io.print("\n\n")
  use _, row, y <- list.index_fold(map, map)
  {
    use _, c, x <- list.index_fold(row, Nil)
    case c {
      "#" -> io.print("#")
      _ ->
        case set.contains(visited, #(x, y)) {
          True -> io.print("X")
          _ -> io.print(".")
        }
    }
  }
  io.print("\n")
  map
}

fn turn_right(dir: #(Int, Int)) -> #(Int, Int) {
  case dir {
    // Down -> Left
    #(0, 1) -> #(-1, 0)
    // Left -> Up
    #(-1, 0) -> #(0, -1)
    // Up -> Right
    #(0, -1) -> #(1, 0)
    // Right -> Down
    #(1, 0) -> #(0, 1)
    _ -> panic
  }
}

fn walk(
  map: List(List(String)),
  guard: #(Int, Int),
  dir: #(Int, Int),
  walked: set.Set(#(Int, Int)),
) -> set.Set(#(Int, Int)) {
  let x = guard.0 + dir.0
  let y = guard.1 + dir.1
  let walked = set.insert(walked, guard)
  case get(map, x, y) {
    Some("#") -> walk(map, guard, turn_right(dir), walked)
    Some(_) -> walk(map, #(x, y), dir, walked)
    None -> walked
  }
}

fn part1(map: List(List(String)), guard: #(Int, Int)) {
  walk(map, guard, #(0, -1), set.new())
  |> set.size
}

fn walk_obstacle(
  map: List(List(String)),
  guard: #(Int, Int),
  dir: #(Int, Int),
  walked: set.Set(#(Int, Int)),
  obstacles: set.Set(#(Int, Int)),
) -> set.Set(#(Int, Int)) {
  let x = guard.0 + dir.0
  let y = guard.1 + dir.1
  let walked = set.insert(walked, guard)
  case get(map, x, y) {
    Some("#") -> walk_obstacle(map, guard, turn_right(dir), walked, obstacles)
    Some(_) ->
      walk_obstacle(map, #(x, y), dir, walked, case
        set.contains(walked, #(x, y))
      {
        True -> set.insert(obstacles, #(x + dir.0, y + dir.1))
        False -> obstacles
      })
    None -> obstacles
  }
}

fn part2(map: List(List(String)), guard: #(Int, Int)) {
  walk_obstacle(map, guard, #(0, -1), set.new(), set.new())
  |> set.size
  // {
  //   use #(y, count), row <- list.fold(map, #(0, 0))
  //   #(
  //     y + 1,
  //     {
  //       use #(x, count), cell <- list.fold(row, #(0, count))
  //       #(x + 1, case cell {
  //         "A" ->
  //           case check_x(map, x, y) {
  //             True -> count + 1
  //             False -> count
  //           }
  //         _ -> count
  //       })
  //     }.1,
  //   )
  // }.1
}
