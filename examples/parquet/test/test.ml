open! Base

let () =
  let reader = Parquet_rs.parquet_reader "/tmp/b.parquet" in
  let col_names = Parquet_rs.col_names reader in
  Stdio.printf
    "%d columns, %d rows\n%!"
    (Array.length col_names)
    (Parquet_rs.num_rows reader);
  Array.iteri col_names ~f:(Stdio.printf "col %d %s\n%!");
  let v = Parquet_rs.read_int_col reader 0 in
  Array.iteri v ~f:(fun index v -> Stdio.printf "> %d %d\n%!" index v);
  let v = Parquet_rs.read_float_col reader 1 in
  Array.iteri v ~f:(fun index v -> Stdio.printf "> %d %f\n%!" index v);
  Parquet_rs.reader_close reader
