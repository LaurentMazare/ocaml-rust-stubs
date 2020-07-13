type t =
  { name : string
  ; data_type : Data_type.t
  ; is_nullable : bool
  }

val to_string : t -> string
