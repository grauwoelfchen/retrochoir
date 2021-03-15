extern crate leptess;
extern crate exif;

use std::env;
use std::fs::File;
use std::io::BufReader;
use std::path::Path;

use leptess::{leptonica, tesseract};

fn main() {
    let args: Vec<String> = env::args().collect();
    let path = &args[1];

    // EXIF
    let file = File::open(path).unwrap();
    let mut buf = BufReader::new(&file);
    let reader = exif::Reader::new();
    let exif = reader.read_from_container(&mut buf).unwrap();

    for f in exif.fields() {
        println!("{}: {}", f.tag, f.display_value().with_unit(&exif));
    }

    println!("--");

    // OCR
    let mut api = tesseract::TessApi::new(None, "eng").unwrap();

    let pix = leptonica::pix_read(Path::new(path)).unwrap();
    api.set_image(&pix);

    println!("y: {}", api.get_source_y_resolution());

    let boxes = api
        .get_component_images(
            leptess::capi::TessPageIteratorLevel_RIL_WORD,
            true,
        )
        .unwrap();
    println!("boxes count: {}", boxes.get_n());

    // TODO
    // println!("result: {}", api.get_utf8_text().unwrap());
}
