open! Base

type t = Rs_parquet.reader

let with_file filename ~f =
  let t = Rs_parquet.parquet_reader filename in
  Exn.protect ~f:(fun () -> f t) ~finally:(fun () -> Rs_parquet.reader_close t)

let num_rows = Rs_parquet.num_rows

let fields t =
  Rs_parquet.fields t
  |> Array.map ~f:(fun (name, dt_index) -> name, Data_type.of_int dt_index)

let read_string_col = Rs_parquet.read_string_col
let read_i64_col = Rs_parquet.read_i64_col
let read_f64_col = Rs_parquet.read_f64_col
let read_i32_col_ba = Rs_parquet.read_i32_col_ba
let read_f32_col_ba = Rs_parquet.read_f32_col_ba
let read_i64_col_ba = Rs_parquet.read_i64_col_ba
let read_f64_col_ba = Rs_parquet.read_f64_col_ba
