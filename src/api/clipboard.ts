import { readImage } from "@tauri-apps/plugin-clipboard-manager";
import { writeFile, mkdir, BaseDirectory } from "@tauri-apps/plugin-fs";
import { ImageItem } from "../types/resolve";
import { invoke } from "@tauri-apps/api/core";

export async function processClipboardImage(): Promise<ImageItem | null> {
  try {
    const clipboardImage = await readImage();
    if (!clipboardImage) return null;

    const rgba = await clipboardImage.rgba();
    const width = clipboardImage.width;
    const height = clipboardImage.height;
    
    // Gerar nome único
    const timestamp = new Date().getTime();
    const fileName = `editcopy_${timestamp}.png`;
    
    // Garantir pasta temporária
    await mkdir("temp", { baseDir: BaseDirectory.AppData, recursive: true });
    
    // Em uma implementação real do Tauri, converteríamos o RGBA para PNG via Rust
    // Para o MVP, usaremos um comando Tauri customizado 'save_clipboard_image'
    const filePath = await invoke<string>("save_clipboard_image", {
      rgba: Array.from(rgba),
      width,
      height,
      fileName
    });

    return {
      id: crypto.randomUUID(),
      path: filePath,
      name: fileName,
      thumbnail: `asset://${filePath}`, // Protocolo asset do Tauri v2
      width,
      height,
      size: rgba.length // Estimativa simples
    };
  } catch (error) {
    console.error("[EditCOPY] Clipboard error:", error);
    return null;
  }
}
