type t =
  { name : string
  ; data_type : Data_type.t
  ; is_nullable : bool
  }

let to_string { name; data_type; is_nullable } =
  Printf.sprintf "%s: %s (nullable: %b)" name (Data_type.to_string data_type) is_nullable
