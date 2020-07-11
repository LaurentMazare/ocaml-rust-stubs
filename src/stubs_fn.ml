open! Base

module Type = struct
  type t =
    | Int
    | Int64
    | Float
    | Unit
    | String
    | Abstract_pointer of
        { ml_name : string
        ; rust_name : string
        }
    | List of t
    | Array of t
    | Tuple2 of t * t
    | Tuple3 of t * t * t
    | Bigarray of [ `i64 | `f64 ]

  let int = Int
  let int64 = Int64
  let float = Float
  let unit = Unit
  let string = String
  let abstract_pointer ~ml_name ~rust_name = Abstract_pointer { ml_name; rust_name }
  let list t = List t
  let array t = Array t
  let tuple2 t1 t2 = Tuple2 (t1, t2)
  let tuple3 t1 t2 t3 = Tuple3 (t1, t2, t3)
  let bigarray kind = Bigarray kind

  let ml_type =
    let rec loop = function
      | Int -> "int"
      | Int64 -> "int64"
      | Float -> "float"
      | Unit -> "unit"
      | String -> "string"
      | Abstract_pointer { ml_name; rust_name = _ } -> ml_name
      | List t -> Printf.sprintf "(%s) list" (loop t)
      | Array t -> Printf.sprintf "(%s) array" (loop t)
      | Tuple2 (t1, t2) -> Printf.sprintf "(%s * %s)" (loop t1) (loop t2)
      | Tuple3 (t1, t2, t3) ->
        Printf.sprintf "(%s * %s * %s)" (loop t1) (loop t2) (loop t3)
      | Bigarray `i64 ->
        "(int64, Bigarray.int64_elt, Bigarray.c_layout) Bigarray.Array1.t"
      | Bigarray `f64 ->
        "(float, Bigarray.float64_elt, Bigarray.c_layout) Bigarray.Array1.t"
    in
    loop

  let rust_type t ~str =
    let rec loop = function
      | Int -> "isize"
      | Int64 -> "i64"
      | Float -> "f64"
      | Unit -> "()"
      | String ->
        (match str with
        | `slice -> "&str"
        | `string -> "String")
      | Abstract_pointer { ml_name = _; rust_name } ->
        Printf.sprintf "ocaml::Pointer<%s>" rust_name
      | List t -> Printf.sprintf "std::collections::LinkedList<%s>" (loop t)
      | Array t -> Printf.sprintf "Vec<%s>" (loop t)
      | Tuple2 (t1, t2) -> Printf.sprintf "(%s, %s)" (loop t1) (loop t2)
      | Tuple3 (t1, t2, t3) -> Printf.sprintf "(%s, %s, %s)" (loop t1) (loop t2) (loop t3)
      | Bigarray `i64 -> "ocaml::bigarray::Array1<i64>"
      | Bigarray `f64 -> "ocaml::bigarray::Array1<f64>"
    in
    loop t
end

(* Maybe we could support named and optional types? *)
type t =
  { ml_name : string
  ; rust_name : string
  ; arg_types : Type.t list
  ; result_type : Type.t
  ; can_raise : bool
  }

let create ~ml_name ~rust_name ~arg_types ~result_type ~can_raise =
  { ml_name; rust_name; arg_types; result_type; can_raise }

let ml_name t = t.ml_name
let rust_name t = t.rust_name
let arg_types t = t.arg_types
let result_type t = t.result_type

let rust_result_type t =
  let result_type = Type.rust_type t.result_type ~str:`string in
  if t.can_raise
  then Printf.sprintf "Result<%s, ocaml::Error>" result_type
  else result_type

let ml_type t =
  t.arg_types @ [ t.result_type ] |> List.map ~f:Type.ml_type |> String.concat ~sep:" -> "

let arg_count t = List.length t.arg_types

let abstract_ml_types t =
  let ml_types = Hash_set.create (module String) in
  let rec loop = function
    | Type.Int | Int64 | Float | Unit | String | Bigarray _ -> ()
    | Abstract_pointer { ml_name; rust_name = _ } -> Hash_set.add ml_types ml_name
    | List t | Array t -> loop t
    | Tuple2 (t1, t2) ->
      loop t1;
      loop t2
    | Tuple3 (t1, t2, t3) ->
      loop t1;
      loop t2;
      loop t3
  in
  List.iter (t.result_type :: t.arg_types) ~f:loop;
  Hash_set.to_list ml_types
