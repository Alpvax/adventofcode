import gleam/int
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/regexp
import simplifile

pub fn main() {
  let assert Ok(file) = simplifile.read("../input/2024/03.txt")
  part1(file)
  |> io.debug
  part2(file)
  |> io.debug
}

pub fn part1(file) {
  let assert Ok(re) = regexp.from_string("mul\\((\\d{1,3}),(\\d{1,3})\\)")
  {
    use acc, match <- list.fold(regexp.scan(re, file), 0)
    case match {
      regexp.Match(_, [Some(a), Some(b)]) -> {
        let assert Ok(a) = int.parse(a)
        let assert Ok(b) = int.parse(b)
        acc + a * b
      }
      regexp.Match(s, _) -> {
        io.println_error("Non matching: " <> s)
        acc
      }
    }
  }
}

pub fn part2(file) {
  let assert Ok(re) =
    regexp.from_string("(?:(do)|(don't))\\(\\)|mul\\((\\d{1,3}),(\\d{1,3})\\)")
  {
    use #(total, do), match <- list.fold(regexp.scan(re, file), #(0, True))
    case match, do {
      regexp.Match(_, [Some(_), ..]), _ -> #(total, True)
      regexp.Match(_, [_, Some(_), ..]), _ -> #(total, False)
      regexp.Match(_, [_, _, Some(a), Some(b)]), True -> {
        let assert Ok(a) = int.parse(a)
        let assert Ok(b) = int.parse(b)
        #(total + a * b, True)
      }
      _, _ -> #(total, do)
    }
  }
}
