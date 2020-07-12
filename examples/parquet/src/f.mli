(* A typical use of this module goes as follows:
  {|
    type t =
      { x : int
      ; y : float
      }
    [@@deriving sexp, fields]

    let read =
      F.read (Fields.make_creator ~x:F.i64 ~y:F.f64)

    let ts = read "/path/to/filename.parquet"
  |}
*)

open! Base

type reader

type ('a, 'b, 'c, 'v) col =
  ('a, 'b, 'c) Field.t_with_perm -> reader -> (int -> 'v) * reader

val i64 : ('a, 'b, 'c, int) col
val f64 : ('a, 'b, 'c, float) col
val str : ('a, 'b, 'c, string) col
val const : 'v -> ('a, 'b, 'c, 'v) col
val read : (reader -> (int -> 'v) * reader) -> string -> 'v list
