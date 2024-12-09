import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/result
import gleam/set
import gleam/string
import simplifile

pub fn main() {
  let assert Ok(file) = simplifile.read("../input/2024/07.txt")
  //   let file =
  //     "190: 10 19
  // 3267: 81 40 27
  // 83: 17 5
  // 156: 15 6
  // 7290: 6 8 6 15
  // 161011: 16 10 13
  // 192: 17 8 14
  // 21037: 9 7 18 13
  // 292: 11 6 16 20"
  let equations: List(#(Int, List(Int))) = {
    use line <- list.filter_map(string.split(file, "\n"))
    use #(l, r) <- result.try(string.split_once(line, ": "))
    use target <- result.map(int.parse(l))
    #(target, {
      use s <- list.filter_map(string.split(r, " "))
      string.trim(s)
      |> int.parse
    })
  }
  part1(equations)
  |> io.debug
  part2(equations)
  |> io.debug
  // part2([3, 4, 2, 1, 3, 3], [4, 3, 5, 3, 9, 3]) |> io.debug
}

fn combine_list_1(
  target: Int,
  calcs: set.Set(Int),
  values: List(Int),
) -> Result(Int, Nil) {
  case values {
    [] -> Error(Nil)
    [next, ..rest] ->
      case
        {
          use res, v <- set.fold(calcs, Error(set.new()))
          let add = v + next
          // io.debug(#("Add:", v, next, add))
          let mul = v * next
          // io.debug(#("Mul:", v, next, mul))
          case res, int.compare(target, add), int.compare(target, mul) {
            Ok(_), _, _ | _, order.Eq, _ | _, _, order.Eq -> Ok(target)
            Error(calcs), order.Gt, order.Gt if mul > 0 ->
              Error(set.insert(calcs, add) |> set.insert(mul))
            Error(calcs), order.Gt, _ -> Error(set.insert(calcs, add))
            Error(calcs), order.Lt, order.Gt if mul > 0 ->
              Error(set.insert(calcs, mul))
            Error(calcs), _, _ -> Error(calcs)
          }
        }
      {
        Ok(t) -> Ok(t)
        Error(calcs) -> combine_list_1(target, calcs, rest)
      }
  }
}

fn part1(equations) {
  {
    use #(target, operands) <- list.filter_map(equations)
    // io.debug(#("Target:", target, operands))
    combine_list_1(target, set.from_list([0]), operands)
  }
  |> int.sum
}

fn combine_list_2(
  target: Int,
  calcs: set.Set(Int),
  values: List(Int),
) -> Result(Int, Nil) {
  case values {
    [] -> Error(Nil)
    [next, ..rest] ->
      case
        {
          use res, v <- set.fold(calcs, Error(set.new()))
          case res {
            Ok(t) -> Ok(t)
            Error(calcs) -> {
              let add = v + next
              // io.debug(#("Add:", v, next, add))
              case int.compare(target, add) {
                order.Eq -> Ok(target)
                order.Gt -> Error(set.insert(calcs, add))
                _ -> Error(calcs)
              }
              |> result.try_recover(fn(calcs) {
                let mul = v * next
                // io.debug(#("Mul:", v, next, mul))
                case int.compare(target, mul) {
                  order.Eq -> Ok(target)
                  order.Gt if mul > 0 -> Error(set.insert(calcs, mul))
                  _ -> Error(calcs)
                }
              })
              |> result.try_recover(fn(calcs) {
                let assert Ok(cat) =
                  int.parse(int.to_string(v) <> int.to_string(next))
                // io.debug(#("Cat:", v, next, cat))
                case int.compare(target, cat) {
                  order.Eq -> Ok(target)
                  order.Gt -> Error(set.insert(calcs, cat))
                  _ -> Error(calcs)
                }
              })
            }
          }
        }
      {
        Ok(t) -> Ok(t)
        Error(calcs) -> combine_list_2(target, calcs, rest)
      }
  }
}

fn part2(equations) {
  {
    use #(target, operands) <- list.filter_map(equations)
    // io.debug(#("Target:", target, operands))
    case combine_list_2(target, set.from_list([0]), operands) {
      Ok(t) -> Ok(io.debug(#(t, operands)).0)
      _ -> Error(Nil)
    }
  }
  |> int.sum
}
