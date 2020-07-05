open! Base
open! Stdio

type t =
  { fns : Stubs_fn.t list
  ; prefix : string
  }

val write_rs : t -> Out_channel.t -> unit
val write_ml : t -> Out_channel.t -> unit
