open! Base
open Rust_stubs

let reader =
  Stubs_fn.Type.abstract_pointer ~ml_name:"reader" ~rust_name:"super::helpers::Reader"

let parquet_reader =
  Stubs_fn.(
    create
      ~ml_name:"parquet_reader"
      ~rust_name:"super::helpers::parquet_reader"
      ~arg_types:[ Type.string ]
      ~result_type:reader
      ~can_raise:true)

let reader_close =
  Stubs_fn.(
    create
      ~ml_name:"reader_close"
      ~rust_name:"super::helpers::reader_close"
      ~arg_types:[ reader ]
      ~result_type:Type.unit
      ~can_raise:false)

let fields =
  Stubs_fn.(
    create
      ~ml_name:"fields"
      ~rust_name:"super::helpers::fields"
      ~arg_types:[ reader ]
      ~result_type:Type.(array (tuple2 string int))
      ~can_raise:false)

let num_rows =
  Stubs_fn.(
    create
      ~ml_name:"num_rows"
      ~rust_name:"super::helpers::num_rows"
      ~arg_types:[ reader ]
      ~result_type:Type.int
      ~can_raise:false)

let read_int_col =
  Stubs_fn.(
    create
      ~ml_name:"read_int_col"
      ~rust_name:"super::helpers::read_int_col"
      ~arg_types:[ reader; Type.int ]
      ~result_type:Type.(array int)
      ~can_raise:true)

let read_int_col_ba =
  Stubs_fn.(
    create
      ~ml_name:"read_int_col_ba"
      ~rust_name:"super::helpers::read_int_col_ba"
      ~arg_types:[ reader; Type.int ]
      ~result_type:Type.(bigarray `i64)
      ~can_raise:true)

let read_float_col =
  Stubs_fn.(
    create
      ~ml_name:"read_float_col"
      ~rust_name:"super::helpers::read_float_col"
      ~arg_types:[ reader; Type.int ]
      ~result_type:Type.(array float)
      ~can_raise:true)

let read_string_col =
  Stubs_fn.(
    create
      ~ml_name:"read_string_col"
      ~rust_name:"super::helpers::read_string_col"
      ~arg_types:[ reader; Type.int ]
      ~result_type:Type.(array string)
      ~can_raise:true)

let stubs =
  { Stubs_gen.fns =
      [ parquet_reader
      ; reader_close
      ; fields
      ; read_int_col
      ; read_int_col_ba
      ; read_float_col
      ; read_string_col
      ; num_rows
      ]
  ; prefix = "mlparquet_"
  }

let () =
  Stdio.Out_channel.with_file "examples/parquet/src/rs_parquet.rs" ~f:(fun outc ->
      Stubs_gen.write_rs stubs outc);
  Stdio.Out_channel.with_file "examples/parquet/src/rs_parquet.ml" ~f:(fun outc ->
      Stubs_gen.write_ml stubs outc)
