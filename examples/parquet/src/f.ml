open Base

type reader = Reader.t * (string, int, String.comparator_witness) Map.t

type ('a, 'b, 'c, 'v) col =
  ('a, 'b, 'c) Field.t_with_perm -> reader -> (int -> 'v) * reader

let get_idx fields field =
  match Map.find fields (Field.name field) with
  | Some idx -> idx
  | None -> Printf.failwithf "cannot find column %s" (Field.name field) ()

let i64 field reader_and_fields =
  let reader, fields = reader_and_fields in
  let idx = get_idx fields field in
  let ba = Reader.read_i64_col_ba reader idx in
  let get i = Int64.to_int_exn ba.{i} in
  get, reader_and_fields

let f64 field reader_and_fields =
  let reader, fields = reader_and_fields in
  let idx = get_idx fields field in
  let ba = Reader.read_f64_col_ba reader idx in
  let get i = ba.{i} in
  get, reader_and_fields

let str field reader_and_fields =
  let reader, fields = reader_and_fields in
  let idx = get_idx fields field in
  let ba = Reader.read_string_col reader idx in
  let get i = ba.(i) in
  get, reader_and_fields

let const v _field reader_and_fields = (fun _idx -> v), reader_and_fields

let read creator filename =
  Reader.with_file filename ~f:(fun reader ->
      let fields =
        Reader.fields reader
        |> Array.mapi ~f:(fun i field -> field.Field_.name, i)
        |> Array.to_list
        |> Map.of_alist_exn (module String)
      in
      let get_one, _ = creator (reader, fields) in
      List.init (Reader.num_rows reader) ~f:get_one)
