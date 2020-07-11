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
      Stdio.printf "col %d %s %s\n%!" idx name (Parquet_rs.string_of_data_type dt);
      match dt with
      | Int64 ->
        Parquet_rs.read_int_col reader idx
        |> Array.iteri ~f:(fun index v -> Stdio.printf "> %d %d\n%!" index v);
        let ba = Parquet_rs.read_int_col_ba reader idx in
        for i = 0 to Bigarray.Array1.dim ba - 1 do
          Stdio.printf ">> %d %d\n%!" i (Int64.to_int_exn ba.{i})
        done
      | Float64 ->
        Parquet_rs.read_float_col reader idx
        |> Array.iteri ~f:(fun index v -> Stdio.printf "> %d %f\n%!" index v)
      | _ -> ());
  Parquet_rs.reader_close reader
