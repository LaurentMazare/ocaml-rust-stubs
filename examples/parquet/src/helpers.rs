use arrow::array::{Float64Array, Int64Array, StringArray};
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

pub fn col_names(reader: ReaderPtr) -> Vec<String> {
    reader
        .as_ref()
        .schema
        .fields()
        .into_iter()
        .map(|x| x.name().to_owned())
        .collect()
}

pub fn num_rows(reader: ReaderPtr) -> isize {
    reader.as_ref().num_rows as isize
}

pub fn read_int_col(mut reader: ReaderPtr, idx: isize) -> Result<Vec<isize>, ocaml::Error> {
    let num_rows = reader.as_ref().num_rows as usize;
    let mut record_batch_reader = reader
        .as_mut()
        .reader
        .get_record_reader(std::cmp::min(num_rows, 512))?;
    let mut vec = Vec::with_capacity(num_rows);
    while let Some(batch) = record_batch_reader.next_batch()? {
        let array_data = batch.column(idx as usize);
        let array_data = match (*array_data).as_any().downcast_ref::<Int64Array>() {
            Some(array_data) => array_data,
            None => {
                let msg = format!("cannot downcast {:?} to Int64", array_data.data_type());
                return Err(ocaml::Error::Error(msg.into()));
            }
        };
        for i in 0..array_data.len() {
            vec.push(array_data.value(i) as isize)
        }
    }
    Ok(vec)
}

pub fn read_float_col(mut reader: ReaderPtr, idx: isize) -> Result<Vec<f64>, ocaml::Error> {
    let num_rows = reader.as_ref().num_rows as usize;
    let mut record_batch_reader = reader
        .as_mut()
        .reader
        .get_record_reader(std::cmp::min(num_rows, 512))?;
    let mut vec = Vec::with_capacity(num_rows);
    while let Some(batch) = record_batch_reader.next_batch()? {
        let array_data = batch.column(idx as usize);
        let array_data = match (*array_data).as_any().downcast_ref::<Float64Array>() {
            Some(array_data) => array_data,
            None => {
                let msg = format!("cannot downcast {:?} to Float64", array_data.data_type());
                return Err(ocaml::Error::Error(msg.into()));
            }
        };
        for i in 0..array_data.len() {
            vec.push(array_data.value(i))
        }
    }
    Ok(vec)
}

pub fn read_string_col(mut reader: ReaderPtr, idx: isize) -> Result<Vec<String>, ocaml::Error> {
    let num_rows = reader.as_ref().num_rows as usize;
    let mut record_batch_reader = reader
        .as_mut()
        .reader
        .get_record_reader(std::cmp::min(num_rows, 512))?;
    let mut vec = Vec::with_capacity(num_rows);
    while let Some(batch) = record_batch_reader.next_batch()? {
        let array_data = batch.column(idx as usize);
        let array_data = match (*array_data).as_any().downcast_ref::<StringArray>() {
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
