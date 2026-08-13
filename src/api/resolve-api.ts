import { invoke } from "@tauri-apps/api/core";
import { ResolveResponse, ResolveInfo, TimelineInfo, ImageItem } from "../types/resolve";

export async function callResolve<T>(func: string, payload: any = {}, timeoutSecs: number = 15): Promise<ResolveResponse<T>> {
  try {
    const response = await invoke<any>("resolve_bridge", {
      payload: { ...payload, func },
      timeoutSecs,
    });
    return response as ResolveResponse<T>;
  } catch (error: any) {
    console.error(`[EditCOPY] Error calling ${func}:`, error);
    return {
      ok: false,
      error: typeof error === 'string' ? error : (error.message || "Erro na comunicação com o bridge."),
      detail: JSON.stringify(error),
      func,
    };
  }
}

export const pingResolve = () => callResolve<{ ok: boolean }>("Ping");
export const getResolveInfo = () => callResolve<ResolveInfo>("GetResolveInfo");
export const getTimelineInfo = () => callResolve<TimelineInfo>("GetTimelineInfo");

export async function importImages(paths: string[]): Promise<ResolveResponse> {
  return callResolve("ImportImages", { paths }, 60);
}

export async function applyImages(paths: string[], duration: number, track: string): Promise<ResolveResponse> {
  return callResolve("ApplyImages", { paths, duration, track }, 60);
}

export async function processClipboardImage(): Promise<ImageItem | null> {
    // Esta função usará o plugin de clipboard do Tauri e o sistema de arquivos
    // para salvar a imagem localmente e retornar o objeto ImageItem.
    // Implementação detalhada na Fase 4.
    return null;
}
