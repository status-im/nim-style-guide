use std::ffi::{c_char, c_void, CString};
use std::{io, ptr, slice};

extern "C" {
    // Functions exported by `asynclib`
    pub fn startNode(
        address: *const c_char,
        on_headers: extern "C" fn(*mut c_void, *const c_char, usize),
        user: *mut c_void,
    ) -> *mut c_void;
    pub fn stopNode(ctx: *mut *mut c_void);
}

extern "C" fn on_headers(_user: *mut c_void, data: *const c_char, len: usize) {
    println!("Received headers! {len}");
    let data = String::from_utf8(unsafe { slice::from_raw_parts(data as *const u8, len) }.to_vec())
        .expect("valid utf8");
    println!("{data}\n\n");
}

fn main() {
    print!("Starting node\n");

    let address = CString::new("127.0.0.1:60000").expect("CString::new failed");

    let mut ctx = unsafe { startNode(address.into_raw(), on_headers, ptr::null_mut()) };
    print!("Node is listening on http://127.0.0.1:60000\nType `q` and press enter to stop\n");

    let mut input = String::new();
    loop {
        match io::stdin().read_line(&mut input) {
            Ok(n) if n > 0 => {
                break;
            }
            _ => {}
        }
    }

    print!("Stopping node\n");

    unsafe { stopNode(&mut ctx) };
}
