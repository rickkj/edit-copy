#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

mod resolve_bridge;
mod clipboard_handler;

use resolve_bridge::resolve_bridge;
use clipboard_handler::save_clipboard_image;

fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_shell::init())
        .plugin(tauri_plugin_fs::init())
        .plugin(tauri_plugin_clipboard_manager::init())
        .invoke_handler(tauri::generate_handler![
            resolve_bridge,
            save_clipboard_image
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}

