open! Base

let () =
  let reader = Parquet_rs.parquet_reader "/tmp/b.parquet" in
  let fields =
    Parquet_rs.fields reader
    |> Array.map ~f:(fun (name, dt) -> name, Parquet_rs.data_type_of_int dt)
  in
  Stdio.printf
    "%d columns, %d rows\n%!"
    (Array.length fields)
    (Parquet_rs.num_rows reader);
  Array.iteri fields ~f:(fun idx (name, dt) ->
      let dt = Parquet_rs.string_of_data_type dt in
      Stdio.printf "col %d %s %s\n%!" idx name dt);
  let v = Parquet_rs.read_int_col reader 0 in
  Array.iteri v ~f:(fun index v -> Stdio.printf "> %d %d\n%!" index v);
  let v = Parquet_rs.read_float_col reader 1 in
  Array.iteri v ~f:(fun index v -> Stdio.printf "> %d %f\n%!" index v);
  Parquet_rs.reader_close reader
