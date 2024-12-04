import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import gleam/yielder
import simplifile

pub fn main() {
  let assert Ok(file) = simplifile.read("../input/2024/04.txt")
  //   let file =
  //     "MMMSXXMASM
  // MSAMXMSMSA
  // AMXSXMAAMM
  // MSAMASMSMX
  // XMASAMXAMM
  // XXAMMXXAMA
  // SMSMSASXSS
  // SAXAMASAAA
  // MAMMMXMMMM
  // MXMXAXMASX"
  let map = list.map(string.split(file, "\n"), string.to_graphemes)

  part1(map)
  |> io.debug
  part2(map)
  |> io.debug
}

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

fn make_checker(dx: Int, dy: Int) -> fn(List(List(String)), Int, Int) -> Bool {
  fn(map, x, y) {
    case get(map, x + dx, y + dy) {
      Some("M") ->
        case get(map, x + 2 * dx, y + 2 * dy) {
          Some("A") ->
            case get(map, x + 3 * dx, y + 3 * dy) {
              Some("S") -> True
              _ -> False
            }
          _ -> False
        }
      _ -> False
    }
  }
}

fn part1(map: List(List(String))) {
  let checkers =
    yielder.to_list(
      yielder.flat_map(yielder.range(-1, 1), fn(x) {
        yielder.map(yielder.range(-1, 1), fn(y) { make_checker(x, y) })
      }),
    )
  {
    use #(y, count), row <- list.fold(map, #(0, 0))
    #(
      y + 1,
      {
        use #(x, count), cell <- list.fold(row, #(0, count))
        #(x + 1, case cell {
          "X" -> {
            use count, check <- list.fold(checkers, count)
            case check(map, x, y) {
              True -> count + 1
              False -> count
            }
          }
          _ -> count
        })
      }.1,
    )
  }.1
}

fn check_x(map: List(List(String)), x, y) {
  case get(map, x, y) {
    Some("A") -> True
    _ -> False
  }
  && case get(map, x + 1, y + 1), get(map, x - 1, y - 1) {
    Some("M"), Some("S") | Some("S"), Some("M") -> True
    _, _ -> False
  }
  && case get(map, x + 1, y - 1), get(map, x - 1, y + 1) {
    Some("M"), Some("S") | Some("S"), Some("M") -> True
    _, _ -> False
  }
}

fn part2(map) {
  {
    use #(y, count), row <- list.fold(map, #(0, 0))
    #(
      y + 1,
      {
        use #(x, count), cell <- list.fold(row, #(0, count))
        #(x + 1, case cell {
          "A" ->
            case check_x(map, x, y) {
              True -> count + 1
              False -> count
            }
          _ -> count
        })
      }.1,
    )
  }.1
}
