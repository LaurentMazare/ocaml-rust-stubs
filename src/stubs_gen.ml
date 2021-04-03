open Base
open Stdio

type t =
  { fns : Stubs_fn.t list
  ; prefix : string
  }

let abstract_ml_types t =
  List.fold
    t.fns
    ~init:(Set.empty (module String))
    ~f:(fun acc fn -> Stubs_fn.abstract_ml_types fn |> List.fold ~init:acc ~f:Set.add)
  |> Set.to_list

let p outc s =
  Printf.ksprintf
    (fun line ->
      Out_channel.output_string outc line;
      Out_channel.output_char outc '\n')
    s

let c_name t ~fn_idx = Printf.sprintf "%s_ml_rs%d" t.prefix (1 + fn_idx)
let rust_arg i = Printf.sprintf "v%d" (1 + i)

let write_rs t outc =
  let p s = p outc s in
  p "// THIS FILE IS AUTOMATICALLY GENERATED, DO NOT EDIT BY HAND!";
  p "use ocaml::IntoValue;";
  p "";
  List.iteri t.fns ~f:(fun fn_idx fn ->
      let c_name = c_name t ~fn_idx in
      let rust_name = Stubs_fn.rust_name fn in
      let rust_args = List.init (Stubs_fn.arg_count fn) ~f:rust_arg in
      let values =
        List.map rust_args ~f:(Printf.sprintf "%s: ocaml::Value")
        |> String.concat ~sep:", "
      in
      let rust_args = if Stubs_fn.with_runtime fn then "gc" :: rust_args else rust_args in
      let rust_args = String.concat rust_args ~sep:", " in
      let rust_result_type = Stubs_fn.rust_result_type fn in
      p "#[ocaml::native_func]";
      p "pub fn %s(%s) -> ocaml::Value {" c_name values;
      List.iteri (Stubs_fn.arg_types fn) ~f:(fun i arg ->
          let v = rust_arg i in
          let rust_type = Stubs_fn.Type.rust_type arg ~str:`slice in
          p "    let %s: %s =  ocaml::FromValue::from_value(%s);" v rust_type v);
      p "    let res: %s = %s(%s);" rust_result_type rust_name rust_args;
      p "    res.into_value(gc)";
      p "}")

let write_ml t outc =
  let p s = p outc s in
  p "(* THIS FILE IS AUTOMATICALLY GENERATED, DO NOT EDIT BY HAND! *)";
  p "";
  List.iter (abstract_ml_types t) ~f:(fun ml_type -> p "type %s" ml_type);
  List.iteri t.fns ~f:(fun fn_idx fn ->
      let c_name = c_name t ~fn_idx in
      let ml_name = Stubs_fn.ml_name fn in
      let ml_type = Stubs_fn.ml_type fn in
      p "external %s : %s = \"%s\"" ml_name ml_type c_name)
