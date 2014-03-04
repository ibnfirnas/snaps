open Core.Std
open Async.Std

val create
  :  dst: Snaps_object_info.t Pipe.Writer.t
  -> riak_conn:Riak.Conn.t
  -> riak_bucket:string
  -> batch_size:int
  -> unit
  -> unit Deferred.t
