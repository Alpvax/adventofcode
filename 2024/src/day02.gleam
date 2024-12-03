import gleam/int
import gleam/io
import gleam/list
import gleam/string
import gleam/yielder
import simplifile

type ReportVal {
  Initial1(Int)
  Ascending1(Int)
  Descending1(Int)
  Invalid1
}

pub fn main() {
  let assert Ok(file) = simplifile.read("../input/2024/02.txt")
  //   let file =
  //     "7 6 4 2 1
  // 1 2 7 8 9
  // 9 7 6 2 1
  // 1 3 2 4 5
  // 8 6 4 4 1
  // 1 3 6 7 9"
  {
    use #(p1, p2), line <- list.fold(string.split(file, "\n"), #(0, 0))
    let report = list.filter_map(string.split(line, " "), int.parse)
    case validate_report(report) {
      True -> #(p1 + 1, p2 + 1)
      False -> {
        case
          {
            use _, idx <- yielder.fold_until(
              yielder.range(0, list.length(report)),
              False,
            )
            case list.split(report, idx) {
              #(_, []) -> list.Stop(False)
              #(pre, [_, ..rest]) ->
                case validate_report(list.append(pre, rest)) {
                  True -> list.Stop(True)
                  False -> list.Continue(False)
                }
            }
          }
        {
          True -> #(p1, p2 + 1)
          False -> #(p1, p2)
        }
      }
    }
  }
  |> io.debug
}

fn validate_report(report: List(Int)) -> Bool {
  let assert [init, ..report] = report
  case
    list.fold_until(report, Initial1(init), fn(acc, i) {
      case acc {
        Initial1(v) | Ascending1(v) if i > v && i < v + 4 ->
          list.Continue(Ascending1(i))
        Initial1(v) | Descending1(v) if i < v && i > v - 4 ->
          list.Continue(Descending1(i))
        _ -> list.Stop(Invalid1)
      }
    })
  {
    Ascending1(..) | Descending1(..) -> True
    _ -> False
  }
}
