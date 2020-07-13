use arrow::record_batch::RecordBatchReader;
use parquet::arrow::{ArrowReader, ParquetFileArrowReader};
use parquet::file::reader::{FileReader, SerializedFileReader};
use std::fs::File;
use std::rc::Rc;

pub struct Reader {
    reader: parquet::arrow::ParquetFileArrowReader,
    schema: arrow::datatypes::Schema,
    num_rows: i64,
}
ocaml::custom!(Reader);
type ReaderPtr = ocaml::Pointer<Reader>;

pub fn parquet_reader(filename: &'static str) -> Result<ReaderPtr, ocaml::Error> {
    let file = File::open(filename)?;
    let reader = SerializedFileReader::new(file)?;
    let num_rows = reader.metadata().file_metadata().num_rows();
    let mut reader = ParquetFileArrowReader::new(Rc::new(reader));
    let schema = reader.get_schema()?;
    Ok(ocaml::Pointer::alloc_custom(Reader {
        reader,
        schema,
        num_rows,
    }))
}

pub fn reader_close(reader: ReaderPtr) {
    // This will result in a segfault if being called twice.
    unsafe { reader.drop_in_place() }
}

pub fn datatype_to_int(datatype: &arrow::datatypes::DataType) -> isize {
    match datatype {
        arrow::datatypes::DataType::Boolean => 0,
        arrow::datatypes::DataType::Int8 => 1,
        arrow::datatypes::DataType::Int16 => 2,
        arrow::datatypes::DataType::Int32 => 3,
        arrow::datatypes::DataType::Int64 => 4,
        arrow::datatypes::DataType::UInt8 => 5,
        arrow::datatypes::DataType::UInt16 => 6,
        arrow::datatypes::DataType::UInt32 => 7,
        arrow::datatypes::DataType::UInt64 => 8,
        arrow::datatypes::DataType::Float16 => 9,
        arrow::datatypes::DataType::Float32 => 10,
        arrow::datatypes::DataType::Float64 => 11,
        arrow::datatypes::DataType::Utf8 => 12,
        _ => -1,
    }
}

pub fn fields(reader: ReaderPtr) -> Vec<(String, isize)> {
    reader
        .as_ref()
        .schema
        .fields()
        .into_iter()
        .map(|x| (x.name().to_owned(), datatype_to_int(x.data_type())))
        .collect()
}

pub fn num_rows(reader: ReaderPtr) -> isize {
    reader.as_ref().num_rows as isize
}

macro_rules! read_col {
    ($t:ty, $a:ident, $fn:ident, $fn_ba:ident) => {
        pub fn $fn(mut reader: ReaderPtr, idx: isize) -> Result<Vec<$t>, ocaml::Error> {
            let num_rows = reader.as_ref().num_rows as usize;
            let mut record_batch_reader = reader.as_mut().reader.get_record_reader_by_columns(
                std::iter::once(idx as usize),
                std::cmp::min(num_rows, 32768),
            )?;
            let mut vec = Vec::with_capacity(num_rows);
            while let Some(batch) = record_batch_reader.next_batch()? {
                let array_data = batch.column(0);
                let array_data = match (*array_data).as_any().downcast_ref::<arrow::array::$a>() {
                    Some(array_data) => array_data,
                    None => {
                        let msg = format!("cannot downcast {:?} to $a", array_data.data_type());
                        return Err(ocaml::Error::Error(msg.into()));
                    }
                };
                for i in 0..array_data.len() {
                    vec.push(array_data.value(i) as $t)
                }
            }
            Ok(vec)
        }

        pub fn $fn_ba(
            mut r: ReaderPtr,
            idx: isize,
        ) -> Result<ocaml::bigarray::Array1<$t>, ocaml::Error> {
            let num_rows = r.as_ref().num_rows as usize;
            let mut r = r.as_mut().reader.get_record_reader_by_columns(
                std::iter::once(idx as usize),
                std::cmp::min(num_rows, 32768),
            )?;
            let mut ba = ocaml::bigarray::Array1::<$t>::create(num_rows);
            let ba_data = ba.data_mut();
            let mut offset = 0usize;
            while let Some(batch) = r.next_batch()? {
                let array_data = batch.column(0);
                let array_data = match (*array_data).as_any().downcast_ref::<arrow::array::$a>() {
                    Some(array_data) => array_data,
                    None => {
                        let msg = format!(
                            "cannot downcast {:?} to {}",
                            array_data.data_type(),
                            std::stringify!($a)
                        );
                        return Err(ocaml::Error::Error(msg.into()));
                    }
                };
                let len = array_data.len();
                ba_data[offset..offset + len].copy_from_slice(array_data.value_slice(0, len));
                offset += len;
            }
            Ok(ba)
        }
    };
}

read_col!(i32, Int32Array, read_i32_col, read_i32_col_ba);
read_col!(f32, Float32Array, read_f32_col, read_f32_col_ba);
read_col!(i64, Int64Array, read_i64_col, read_i64_col_ba);
read_col!(f64, Float64Array, read_f64_col, read_f64_col_ba);

pub fn read_string_col(mut reader: ReaderPtr, idx: isize) -> Result<Vec<String>, ocaml::Error> {
    let num_rows = reader.as_ref().num_rows as usize;
    let mut record_batch_reader = reader.as_mut().reader.get_record_reader_by_columns(
        std::iter::once(idx as usize),
        std::cmp::min(num_rows, 32768),
    )?;
    let mut vec = Vec::with_capacity(num_rows);
    while let Some(batch) = record_batch_reader.next_batch()? {
        let array_data = batch.column(0);
        let array_data = match (*array_data)
            .as_any()
            .downcast_ref::<arrow::array::StringArray>()
        {
            Some(array_data) => array_data,
            None => {
                let msg = format!(
                    "cannot downcast {:?} to StringArray",
                    array_data.data_type()
                );
                return Err(ocaml::Error::Error(msg.into()));
            }
        };
        for i in 0..batch.num_rows() {
            vec.push(array_data.value(i).to_owned())
        }
    }
    Ok(vec)
}
