open! Base
module Sys = Caml.Sys

type t =
  { x : int
  ; y : float
  }
[@@deriving sexp, fields]

let read =
  let open Parquet_rs.F in
  read (Fields.make_creator ~x:i64 ~y:f64)

let print_n a ~kind ~len ~get =
  for i = 0 to Int.min 40 (len a) - 1 do
    Stdio.printf "%s> %d %s\n%!" kind i (get a i)
  done

let print_n_ba a ~kind ~conv =
  print_n a ~kind ~len:Bigarray.Array1.dim ~get:(fun ba i -> ba.{i} |> conv)

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
      | Utf8 ->
        Parquet_rs.read_string_col reader idx
        |> print_n ~kind:"str" ~len:Array.length ~get:Array.get
      | Int64 ->
        Parquet_rs.read_i64_col_ba reader idx
        |> print_n_ba ~kind:"i64" ~conv:Int64.to_string
      | Int32 ->
        Parquet_rs.read_i32_col_ba reader idx
        |> print_n_ba ~kind:"i32" ~conv:Int32.to_string
      | Float64 ->
        Parquet_rs.read_f64_col_ba reader idx
        |> print_n_ba ~kind:"f64" ~conv:Float.to_string
      | Float32 ->
        Parquet_rs.read_f32_col_ba reader idx
        |> print_n_ba ~kind:"f32" ~conv:Float.to_string
      | _ -> ());
  Parquet_rs.reader_close reader;
  let ts = read Sys.argv.(1) in
  List.iteri ts ~f:(fun i t ->
      Stdio.printf "%d %s\n%!" i (sexp_of_t t |> Sexp.to_string_mach))
