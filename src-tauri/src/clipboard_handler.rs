use serde::{Deserialize, Serialize};
use tauri::{command, AppHandle, Runtime, Manager};
use std::fs;
use std::path::PathBuf;
use image::{ImageBuffer, Rgba};

#[command]
pub async fn save_clipboard_image<R: Runtime>(
    app: AppHandle<R>,
    rgba: Vec<u8>,
    width: u32,
    height: u32,
    file_name: String,
) -> Result<String, String> {
    let app_dir = app.path().app_data_dir()
        .map_err(|e| format!("Falha ao obter pasta de dados: {}", e))?;
    
    let temp_dir = app_dir.join("temp");
    if !temp_dir.exists() {
        fs::create_dir_all(&temp_dir).map_err(|e| format!("Falha ao criar pasta temp: {}", e))?;
    }

    let file_path = temp_dir.join(file_name);
    
    let img: ImageBuffer<Rgba<u8>, Vec<u8>> = ImageBuffer::from_raw(width, height, rgba)
        .ok_or("Falha ao criar buffer de imagem".to_string())?;
    
    img.save(&file_path).map_err(|e| format!("Falha ao salvar PNG: {}", e))?;

    Ok(file_path.to_string_lossy().into_owned())
}
