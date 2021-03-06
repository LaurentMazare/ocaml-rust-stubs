// THIS FILE IS AUTOMATICALLY GENERATED, DO NOT EDIT BY HAND!
use ocaml::IntoValue;

#[ocaml::native_func]
pub fn mlparquet__ml_rs1(v1: ocaml::Value) -> ocaml::Value {
    let v1: &str =  ocaml::FromValue::from_value(v1);
    let res: Result<ocaml::Pointer<super::helpers::Reader>, ocaml::Error> = super::helpers::parquet_reader(gc, v1);
    res.into_value(gc)
}
#[ocaml::native_func]
pub fn mlparquet__ml_rs2(v1: ocaml::Value) -> ocaml::Value {
    let v1: ocaml::Pointer<super::helpers::Reader> =  ocaml::FromValue::from_value(v1);
    let res: () = super::helpers::reader_close(v1);
    res.into_value(gc)
}
#[ocaml::native_func]
pub fn mlparquet__ml_rs3(v1: ocaml::Value) -> ocaml::Value {
    let v1: ocaml::Pointer<super::helpers::Reader> =  ocaml::FromValue::from_value(v1);
    let res: Vec<(String, isize, bool)> = super::helpers::fields(v1);
    res.into_value(gc)
}
#[ocaml::native_func]
pub fn mlparquet__ml_rs4(v1: ocaml::Value, v2: ocaml::Value) -> ocaml::Value {
    let v1: ocaml::Pointer<super::helpers::Reader> =  ocaml::FromValue::from_value(v1);
    let v2: isize =  ocaml::FromValue::from_value(v2);
    let res: Result<ocaml::bigarray::Array1<i64>, ocaml::Error> = super::helpers::read_i64_col_ba(gc, v1, v2);
    res.into_value(gc)
}
#[ocaml::native_func]
pub fn mlparquet__ml_rs5(v1: ocaml::Value, v2: ocaml::Value) -> ocaml::Value {
    let v1: ocaml::Pointer<super::helpers::Reader> =  ocaml::FromValue::from_value(v1);
    let v2: isize =  ocaml::FromValue::from_value(v2);
    let res: Result<ocaml::bigarray::Array1<f64>, ocaml::Error> = super::helpers::read_f64_col_ba(gc, v1, v2);
    res.into_value(gc)
}
#[ocaml::native_func]
pub fn mlparquet__ml_rs6(v1: ocaml::Value, v2: ocaml::Value) -> ocaml::Value {
    let v1: ocaml::Pointer<super::helpers::Reader> =  ocaml::FromValue::from_value(v1);
    let v2: isize =  ocaml::FromValue::from_value(v2);
    let res: Result<ocaml::bigarray::Array1<i32>, ocaml::Error> = super::helpers::read_i32_col_ba(gc, v1, v2);
    res.into_value(gc)
}
#[ocaml::native_func]
pub fn mlparquet__ml_rs7(v1: ocaml::Value, v2: ocaml::Value) -> ocaml::Value {
    let v1: ocaml::Pointer<super::helpers::Reader> =  ocaml::FromValue::from_value(v1);
    let v2: isize =  ocaml::FromValue::from_value(v2);
    let res: Result<ocaml::bigarray::Array1<f32>, ocaml::Error> = super::helpers::read_f32_col_ba(gc, v1, v2);
    res.into_value(gc)
}
#[ocaml::native_func]
pub fn mlparquet__ml_rs8(v1: ocaml::Value, v2: ocaml::Value) -> ocaml::Value {
    let v1: ocaml::Pointer<super::helpers::Reader> =  ocaml::FromValue::from_value(v1);
    let v2: isize =  ocaml::FromValue::from_value(v2);
    let res: Result<Vec<i64>, ocaml::Error> = super::helpers::read_i64_col(v1, v2);
    res.into_value(gc)
}
#[ocaml::native_func]
pub fn mlparquet__ml_rs9(v1: ocaml::Value, v2: ocaml::Value) -> ocaml::Value {
    let v1: ocaml::Pointer<super::helpers::Reader> =  ocaml::FromValue::from_value(v1);
    let v2: isize =  ocaml::FromValue::from_value(v2);
    let res: Result<Vec<f64>, ocaml::Error> = super::helpers::read_f64_col(v1, v2);
    res.into_value(gc)
}
#[ocaml::native_func]
pub fn mlparquet__ml_rs10(v1: ocaml::Value, v2: ocaml::Value) -> ocaml::Value {
    let v1: ocaml::Pointer<super::helpers::Reader> =  ocaml::FromValue::from_value(v1);
    let v2: isize =  ocaml::FromValue::from_value(v2);
    let res: Result<Vec<String>, ocaml::Error> = super::helpers::read_string_col(v1, v2);
    res.into_value(gc)
}
#[ocaml::native_func]
pub fn mlparquet__ml_rs11(v1: ocaml::Value) -> ocaml::Value {
    let v1: ocaml::Pointer<super::helpers::Reader> =  ocaml::FromValue::from_value(v1);
    let res: isize = super::helpers::num_rows(v1);
    res.into_value(gc)
}
#[ocaml::native_func]
pub fn mlparquet__ml_rs12(v1: ocaml::Value, v2: ocaml::Value) -> ocaml::Value {
    let v1: ocaml::Pointer<super::helpers::Reader> =  ocaml::FromValue::from_value(v1);
    let v2: isize =  ocaml::FromValue::from_value(v2);
    let res: Result<isize, ocaml::Error> = super::helpers::null_count_for_col(v1, v2);
    res.into_value(gc)
}
