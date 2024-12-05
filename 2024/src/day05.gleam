import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/set
import gleam/string
import simplifile

pub fn main() {
  let assert Ok(file) = simplifile.read("../input/2024/05.txt")
  //   let file =
  //     "47|53
  // 97|13
  // 97|61
  // 97|47
  // 75|29
  // 61|13
  // 75|53
  // 29|13
  // 97|29
  // 53|29
  // 61|53
  // 97|53
  // 61|29
  // 47|13
  // 75|47
  // 97|75
  // 47|61
  // 75|61
  // 47|29
  // 75|13
  // 53|13

  // 75,47,61,53,29
  // 97,61,53,29,13
  // 75,29,13
  // 75,97,47,61,53
  // 61,13,29
  // 97,13,75,29,47"
  let assert Ok(#(ordering, updates)) = string.split_once(file, "\n\n")
  let #(order_before, order_after) = {
    use #(order_before, order_after), line <- list.fold(
      string.split(ordering, "\n"),
      #(dict.new(), dict.new()),
    )
    case string.split_once(line, "|") {
      Ok(#(before, after)) -> #(
        dict.upsert(order_before, after, fn(prev) {
          case prev {
            Some(prev) -> set.insert(prev, before)
            None -> set.from_list([before])
          }
        }),
        dict.upsert(order_after, before, fn(prev) {
          case prev {
            Some(prev) -> set.insert(prev, after)
            None -> set.from_list([after])
          }
        }),
      )
      _ -> #(order_before, order_after)
    }
  }
  {
    use #(p1, p2), update <- list.fold(
      string.split(updates, "\n") |> list.map(string.split(_, ",")),
      #(0, 0),
    )
    case check_order(order_before, update).0 {
      True -> #(p1 + mid(update), p2)
      False -> #(p1, p2 + mid(fix_order(order_after, update)))
    }
  }
  |> io.debug
  // part2(map)
  // |> io.debug
}

fn check_order(
  ordering: dict.Dict(String, set.Set(String)),
  update: List(String),
) -> #(Bool, set.Set(String), set.Set(String)) {
  use #(_, processed, not_present), page <- list.fold_until(update, #(
    True,
    set.new(),
    set.new(),
  ))
  // let _ =
  //   io.debug(#(
  //     "Processed:",
  //     processed,
  //     "Not_present:",
  //     not_present,
  //     "Page:",
  //     page,
  //   ))
  case set.contains(not_present, page) {
    True -> list.Stop(#(False, processed, not_present))
    False ->
      list.Continue(
        #(True, set.insert(processed, page), case dict.get(ordering, page) {
          Ok(before) ->
            set.union(not_present, set.difference(before, processed))
          _ -> not_present
        }),
      )
  }
}

fn mid(update: List(String)) -> Int {
  case list.split(update, list.length(update) / 2) {
    #(_, [mid, ..]) -> int.parse(mid)
    _ -> Error(Nil)
  }
  |> result.unwrap(0)
}

fn fix_order(
  ordering: dict.Dict(String, set.Set(String)),
  update: List(String),
) -> List(String) {
  // Filter to only relevant entries
  let update_set = set.from_list(update)
  let order_after = {
    use page <- list.map(update)
    #(page, case dict.get(ordering, page) {
      Ok(after) -> set.intersection(update_set, after)
      _ -> set.new()
    })
  }
  do_fix(order_after, [])
}

fn do_fix(processing: List(#(String, set.Set(String))), processed: List(String)) {
  case list.find(processing, fn(p) { set.is_empty(p.1) }) {
    Ok(#(page, _)) -> {
      do_fix(
        {
          use #(p, after) <- list.filter_map(processing)
          case p == page {
            True -> Error(Nil)
            False -> Ok(#(p, set.delete(after, page)))
          }
        },
        [page, ..processed],
      )
    }
    _ ->
      case list.length(processing) > 0 {
        True -> {
          let _ = io.print_error("Ran out of valid pages:")
          let _ =
            io.debug(#(
              "Processing:",
              list.map(processing, fn(item) { #(item.0, set.to_list(item.1)) }),
              "Processed:",
              processed,
            ))
          panic
        }
        False -> processed
      }
  }
}
