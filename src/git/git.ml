open Core.Std
open Async.Std


type error = Unable_to_create_file of string
           | Unexpected_stderr     of string


let init () =
  Async_shell.run "git" ["init"]

let parse_stderr stderr =
  try
    let msg = List.hd_exn (Str.split (Str.regexp "\n+") stderr) in
    let f = Scanf.sscanf msg "fatal: Unable to create '%s@': File exists." Fn.id in
    Unable_to_create_file f
  with
  | Failure "hd" | Scanf.Scan_failure _ ->
    Unexpected_stderr stderr

let try_with_parse_stderr f =
  let module P = Async_shell.Process in
  try_with ~extract_exn:true f
  >>| function
    | Ok ok                       -> Ok ok
    | Error (P.Failed {P.stderr; _}) -> Error (parse_stderr stderr)
    | Error _                     -> assert false

let status ~filepath =
  Async_shell.run_full "git" ["status"; "--porcelain"; filepath]
  >>| fun output ->
  Git_status_parser.parse output

let add_exn ~filepath =
  Async_shell.run "git" ["add"; filepath]

let add ~filepath =
  try_with_parse_stderr (fun () -> add_exn ~filepath)

let commit_exn ~msg =
  Async_shell.run "git" ["commit"; "-m"; msg]

let commit ~msg =
  try_with_parse_stderr (fun () -> commit_exn ~msg)

let gc ?(aggressive=false) () =
  let aggressive_flag = if aggressive then ["--aggressive"] else [] in
  Async_shell.run "git" ("gc" :: "--prune=now" :: aggressive_flag)
