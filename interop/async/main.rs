use std::ffi::{c_char, c_void, CString};
use std::io;

extern "C" {
    pub fn startNode(
        ctx: *const c_char,
        user: u64,
        callback: extern "C" fn(*mut c_void, *const u8, u64),
    ) -> *mut c_void;
    pub fn stopNode(ctx: *mut *mut c_void);
}

extern "C" fn callback(_user: *mut c_void, _data: *const u8, len: u64) {
    println!("Callback! {len}");
}

fn main() {
    print!("Starting node\n");

    let address = CString::new("127.0.0.1:60000").expect("CString::new failed");

    let mut ctx = unsafe { startNode(address.into_raw(), 0, callback) };
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
