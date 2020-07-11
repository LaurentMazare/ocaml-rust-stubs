open! Base

module Type : sig
  type t

  val int : t
  val int64 : t
  val float : t
  val unit : t
  val string : t
  val abstract_pointer : ml_name:string -> rust_name:string -> t
  val list : t -> t
  val array : t -> t
  val tuple2 : t -> t -> t
  val tuple3 : t -> t -> t -> t
  val bigarray : [ `i64 | `f64 ] -> t
  val ml_type : t -> string
  val rust_type : t -> str:[ `slice | `string ] -> string
end

type t

val create
  :  ml_name:string
  -> rust_name:string
  -> arg_types:Type.t list
  -> result_type:Type.t
  -> can_raise:bool
  -> t

val ml_name : t -> string
val rust_name : t -> string
val ml_type : t -> string
val arg_count : t -> int
val arg_types : t -> Type.t list
val result_type : t -> Type.t
val rust_result_type : t -> string
val abstract_ml_types : t -> string list
