type t =
  | Boolean
  | Int8
  | Int16
  | Int32
  | Int64
  | UInt8
  | UInt16
  | UInt32
  | UInt64
  | Float16
  | Float32
  | Float64
  | Utf8
  | Unknown of int

val of_int : int -> t
val to_string : t -> string
