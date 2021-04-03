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
      ~with_runtime:true
      ~can_raise:true)

let reader_close =
  Stubs_fn.(
    create
      ~ml_name:"reader_close"
      ~rust_name:"super::helpers::reader_close"
      ~arg_types:[ reader ]
      ~result_type:Type.unit
      ~with_runtime:false
      ~can_raise:false)

let fields =
  Stubs_fn.(
    create
      ~ml_name:"fields"
      ~rust_name:"super::helpers::fields"
      ~arg_types:[ reader ]
      ~result_type:Type.(array (tuple3 string int bool))
      ~with_runtime:false
      ~can_raise:false)

let num_rows =
  Stubs_fn.(
    create
      ~ml_name:"num_rows"
      ~rust_name:"super::helpers::num_rows"
      ~arg_types:[ reader ]
      ~result_type:Type.int
      ~with_runtime:false
      ~can_raise:false)

let read_i64_col =
  Stubs_fn.(
    create
      ~ml_name:"read_i64_col"
      ~rust_name:"super::helpers::read_i64_col"
      ~arg_types:[ reader; Type.int ]
      ~result_type:Type.(array int64)
      ~with_runtime:false
      ~can_raise:true)

let ba_col str kind =
  Stubs_fn.(
    create
      ~ml_name:(Printf.sprintf "read_%s_col_ba" str)
      ~rust_name:(Printf.sprintf "super::helpers::read_%s_col_ba" str)
      ~arg_types:[ reader; Type.int ]
      ~result_type:Type.(bigarray kind)
      ~with_runtime:true
      ~can_raise:true)

let read_f64_col =
  Stubs_fn.(
    create
      ~ml_name:"read_f64_col"
      ~rust_name:"super::helpers::read_f64_col"
      ~arg_types:[ reader; Type.int ]
      ~result_type:Type.(array float)
      ~with_runtime:false
      ~can_raise:true)

let read_string_col =
  Stubs_fn.(
    create
      ~ml_name:"read_string_col"
      ~rust_name:"super::helpers::read_string_col"
      ~arg_types:[ reader; Type.int ]
      ~result_type:Type.(array string)
      ~with_runtime:false
      ~can_raise:true)

let null_count_for_col =
  Stubs_fn.(
    create
      ~ml_name:"null_count_for_col"
      ~rust_name:"super::helpers::null_count_for_col"
      ~arg_types:[ reader; Type.int ]
      ~result_type:Type.int
      ~with_runtime:false
      ~can_raise:true)

let stubs =
  { Stubs_gen.fns =
      [ parquet_reader
      ; reader_close
      ; fields
      ; ba_col "i64" `i64
      ; ba_col "f64" `f64
      ; ba_col "i32" `i32
      ; ba_col "f32" `f32
      ; read_i64_col
      ; read_f64_col
      ; read_string_col
      ; num_rows
      ; null_count_for_col
      ]
  ; prefix = "mlparquet_"
  }

let () =
  Stdio.Out_channel.with_file "examples/parquet/src/rs_parquet.rs" ~f:(fun outc ->
      Stubs_gen.write_rs stubs outc);
  Stdio.Out_channel.with_file "examples/parquet/src/rs_parquet.ml" ~f:(fun outc ->
      Stubs_gen.write_ml stubs outc)
