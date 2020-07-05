open! Base

let () =
  let reader = Parquet_rs.parquet_reader "/tmp/b.parquet" in
  Parquet_rs.col_names reader
  |> Array.iter ~f:(fun name -> Stdio.printf ">>>>> %s\n%!" name);
  let v = Parquet_rs.read_int_col reader 0 in
  Array.iteri v ~f:(fun index v -> Stdio.printf "> %d %d\n%!" index v);
  let v = Parquet_rs.read_float_col reader 1 in
  Array.iteri v ~f:(fun index v -> Stdio.printf "> %d %f\n%!" index v);
  Parquet_rs.reader_close reader
