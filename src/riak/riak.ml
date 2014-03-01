open Core.Std
open Async.Std

type t =
  { hostname : string
  ; port     : int
  }

let make ?(hostname="localhost") ?(port=8098) () =
  { hostname
  ; port
  }

let curl ~uri =
  Async_shell.run_full "curl" [uri]

let fetch_keys ~uri =
  curl ~uri >>= fun data ->
  let json = Ezjsonm.from_string data in
  return Ezjsonm.(get_list get_string (find json ["keys"]))

let fetch_keys_2i {hostname; port} ~bucket =
  Log.Global.info "Fetch  : keys of %s. Via 2i" bucket;
  Log.Global.flushed () >>= fun () ->
  let uri =
    sprintf
      "http://%s:%d/buckets/%s/index/bucket_bin/%s"
      hostname
      port
      bucket
      bucket
  in
  fetch_keys ~uri

let fetch_keys_brutally {hostname; port} ~bucket =
  Log.Global.info "Fetch  : keys of %s. Via brute force listing!" bucket;
  Log.Global.flushed () >>= fun () ->
  let uri = sprintf "http://%s:%d/riak/%s?keys=true" hostname port bucket in
  fetch_keys ~uri

let fetch_value {hostname; port} ~bucket key =
  Log.Global.info "Fetch  : %S" (bucket ^ "/" ^ key);
  Log.Global.flushed () >>= fun () ->
  let uri = sprintf "http://%s:%d/riak/%s/%s" hostname port bucket key in
  curl ~uri >>= fun value ->
  return (key, value)
