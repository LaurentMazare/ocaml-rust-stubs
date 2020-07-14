type t

val with_file : string -> f:(t -> 'a) -> 'a
val num_rows : t -> int
val fields : t -> Field_.t array
val read_string_col : t -> int -> string array
val read_i64_col : t -> int -> int64 array
val read_f64_col : t -> int -> float array

val read_i32_col_ba
  :  t
  -> int
  -> (int32, Bigarray.int32_elt, Bigarray.c_layout) Bigarray.Array1.t

val read_f32_col_ba
  :  t
  -> int
  -> (float, Bigarray.float32_elt, Bigarray.c_layout) Bigarray.Array1.t

val read_i64_col_ba
  :  t
  -> int
  -> (int64, Bigarray.int64_elt, Bigarray.c_layout) Bigarray.Array1.t

val read_f64_col_ba
  :  t
  -> int
  -> (float, Bigarray.float64_elt, Bigarray.c_layout) Bigarray.Array1.t

val null_count_for_col : t -> int -> int
