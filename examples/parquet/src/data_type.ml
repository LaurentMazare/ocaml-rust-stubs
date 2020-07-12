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

let of_int = function
  | 0 -> Boolean
  | 1 -> Int8
  | 2 -> Int16
  | 3 -> Int32
  | 4 -> Int64
  | 5 -> UInt8
  | 6 -> UInt16
  | 7 -> UInt32
  | 8 -> UInt64
  | 9 -> Float16
  | 10 -> Float32
  | 11 -> Float64
  | 12 -> Utf8
  | d -> Unknown d

let to_string = function
  | Boolean -> "Boolean"
  | Int8 -> "Int8"
  | Int16 -> "Int16"
  | Int32 -> "Int32"
  | Int64 -> "Int64"
  | UInt8 -> "UInt8"
  | UInt16 -> "UInt16"
  | UInt32 -> "UInt32"
  | UInt64 -> "UInt64"
  | Float16 -> "Float16"
  | Float32 -> "Float32"
  | Float64 -> "Float64"
  | Utf8 -> "Utf8"
  | Unknown d -> Printf.sprintf "Unknown<%d>" d
