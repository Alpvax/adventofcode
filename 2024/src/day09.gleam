import gleam/deque
import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/string
import simplifile

pub fn main() {
  let assert Ok(file) = simplifile.read("../input/2024/09.txt")
  // let file = "12345"
  // let file = "2333133121414131402"
  let #(_file_count, files, rev_spaces, _) = {
    use #(id, files, spaces, is_file), c <- list.fold(
      string.to_graphemes(file),
      #(0, deque.new(), [], True),
    )
    let assert Ok(len) = int.parse(c)
    case is_file {
      True -> {
        #(id + 1, deque.push_back(files, #(id, len)), spaces, False)
      }
      _ -> #(id, files, [len, ..spaces], True)
    }
  }
  let spaces = list.reverse(rev_spaces)
  let _ = io.debug(#("Files:", files, "Spaces:", spaces))
  let _ = io.println_error("")
  part1(files, spaces).0
  |> io.debug
  part2(files, spaces)
  |> io.debug
}

fn fill_space1(
  segments: List(#(Int, Int)),
  files: deque.Deque(#(Int, Int)),
  spaces: List(Int),
) {
  // let _ = io.debug(#("fill_space", segments, deque.to_list(files), spaces))
  case spaces {
    [] -> list.reverse(segments) |> list.append(deque.to_list(files))
    [space, ..spaces] -> {
      // let _ =
      //   io.println_error(
      //     "Processing space with length: " <> int.to_string(space),
      //   )
      case deque.pop_back(files) {
        Error(_) -> list.reverse(segments)
        Ok(#(#(id, len), files)) -> {
          // let _ = io.debug(#("File:", #(id, len)))
          case int.compare(space, len) {
            order.Eq ->
              case deque.pop_front(files) {
                Ok(#(#(id1, len1), files)) ->
                  fill_space1(
                    [#(id1, len1), #(id, len), ..segments],
                    files,
                    spaces,
                  )
                Error(_) -> list.reverse(segments)
              }
            order.Gt ->
              fill_space1([#(id, len), ..segments], files, [
                space - len,
                ..spaces
              ])
            order.Lt ->
              case deque.pop_front(files) {
                Ok(#(#(id1, len1), files)) ->
                  fill_space1(
                    [#(id1, len1), #(id, space), ..segments],
                    deque.push_back(files, #(id, len - space)),
                    spaces,
                  )
                Error(_) -> list.reverse([#(id, len), ..segments])
              }
          }
        }
      }
    }
  }
}

fn display(compact: List(#(Int, Int))) {
  {
    use #(id, len) <- list.each(compact)
    io.print(int.to_string(id) |> string.repeat(len))
  }
  io.println("")
  compact
}

fn part1(files: deque.Deque(#(Int, Int)), spaces: List(Int)) {
  let assert Ok(#(file, files)) = deque.pop_front(files)
  let compact = fill_space1([file], files, spaces)
  use #(total, idx), #(id, len) <- list.fold(compact, #(0, 0))
  #(total + id * len * { idx * 2 + len - 1 } / 2, idx + len)
}

fn fill_space2(
  segments: List(#(Int, Int)),
  files: deque.Deque(#(Int, Int)),
  spaces: List(Int),
) {
  case deque.pop_back(files) {
    Error(_) -> list.reverse(segments)
    Ok(#(#(id, len), files)) -> {
      let insert_idx =
        list.fold_until(spaces, 0, fn(i, space) {
          case space >= len {
            // Add after (i+1)th file, i.e. in space i
            True -> list.Stop(i + 1)
            // Should be the end of the list, i.e. files.length
            _ -> list.Continue(i + 1)
          }
        })
      let #(pre, post) = list.split(segments, insert_idx)
      let assert #(pre_s, [space, ..post_s]) =
        list.split(spaces, insert_idx - 1)
      fill_space2(
        list.flatten([pre, [#(id, len)], post]),
        files,
        list.flatten([pre_s, [0, space], post_s]),
      )
    }
  }
}

fn part2(files: deque.Deque(#(Int, Int)), spaces: List(Int)) {
  let assert Ok(#(file, files)) = deque.pop_front(files)
  let compact = fill_space2([file], files, spaces)
  use #(total, idx), #(id, len) <- list.fold(compact, #(0, 0))
  #(total + id * len * { idx * 2 + len - 1 } / 2, idx + len)
}
