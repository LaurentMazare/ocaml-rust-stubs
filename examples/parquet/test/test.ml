open! Base
module Sys = Caml.Sys

let () =
  if Array.length Sys.argv <> 2
  then Printf.sprintf "usage: %s file.parquet" Sys.argv.(0) |> failwith;
  let reader = Parquet_rs.parquet_reader Sys.argv.(1) in
  let fields =
    Parquet_rs.fields reader
    |> Array.map ~f:(fun (name, dt) -> name, Parquet_rs.data_type_of_int dt)
  in
  Stdio.printf
    "%d columns, %d rows\n%!"
    (Array.length fields)
    (Parquet_rs.num_rows reader);
  Array.iteri fields ~f:(fun idx (name, dt) ->
      Stdio.printf "col %d %s %s\n%!" idx name (Parquet_rs.string_of_data_type dt);
      match dt with
      | Int64 ->
        let ba = Parquet_rs.read_i64_col_ba reader idx in
        for i = 0 to Int.min 40 (Bigarray.Array1.dim ba) - 1 do
          Stdio.printf "i64> %d %d\n%!" i (Int64.to_int_exn ba.{i})
        done
      | Int32 ->
        let ba = Parquet_rs.read_i32_col_ba reader idx in
        for i = 0 to Int.min 40 (Bigarray.Array1.dim ba) - 1 do
          Stdio.printf "i32> %d %d\n%!" i (Int32.to_int_exn ba.{i})
        done
      | Float64 ->
        let ba = Parquet_rs.read_f64_col_ba reader idx in
        for i = 0 to Int.min 40 (Bigarray.Array1.dim ba) - 1 do
          Stdio.printf "f64> %d %f\n%!" i ba.{i}
        done
      | Float32 ->
        let ba = Parquet_rs.read_f32_col_ba reader idx in
        for i = 0 to Int.min 40 (Bigarray.Array1.dim ba) - 1 do
          Stdio.printf "f32> %d %f\n%!" i ba.{i}
        done
      | _ -> ());
  Parquet_rs.reader_close reader
