open! Base
module Sys = Caml.Sys
open Parquet_rs

type t =
  { x : int
  ; y : float
  }
[@@deriving sexp, fields]

let read = F.read (Fields.make_creator ~x:F.i64 ~y:F.f64)

let print_n a ~kind ~len ~get =
  for i = 0 to Int.min 40 (len a) - 1 do
    Stdio.printf "%s> %d %s\n%!" kind i (get a i)
  done

let print_n_ba a ~kind ~conv =
  print_n a ~kind ~len:Bigarray.Array1.dim ~get:(fun ba i -> ba.{i} |> conv)

let () =
  if Array.length Sys.argv <> 2
  then Printf.sprintf "usage: %s file.parquet" Sys.argv.(0) |> failwith;
  Reader.with_file Sys.argv.(1) ~f:(fun reader ->
      let fields = Reader.fields reader in
      Stdio.printf
        "%d columns, %d rows\n%!"
        (Array.length fields)
        (Reader.num_rows reader);
      Array.iteri fields ~f:(fun idx field ->
          Stdio.printf "col %d %s\n%!" idx (Field.to_string field);
          match field.data_type with
          | Utf8 ->
            Reader.read_string_col reader idx
            |> print_n ~kind:"str" ~len:Array.length ~get:Array.get
          | Int64 ->
            Reader.read_i64_col_ba reader idx
            |> print_n_ba ~kind:"i64" ~conv:Int64.to_string
          | Int32 ->
            Reader.read_i32_col_ba reader idx
            |> print_n_ba ~kind:"i32" ~conv:Int32.to_string
          | Float64 ->
            Reader.read_f64_col_ba reader idx
            |> print_n_ba ~kind:"f64" ~conv:Float.to_string
          | Float32 ->
            Reader.read_f32_col_ba reader idx
            |> print_n_ba ~kind:"f32" ~conv:Float.to_string
          | _ -> ()));
  let ts = read Sys.argv.(1) in
  List.iteri ts ~f:(fun i t ->
      Stdio.printf "%d %s\n%!" i (sexp_of_t t |> Sexp.to_string_mach))
