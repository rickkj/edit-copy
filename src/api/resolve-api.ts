import { invoke } from "@tauri-apps/api/core";
import { ResolveResponse, ResolveInfo, TimelineInfo, ImageItem } from "../types/resolve";
import { RESOLVE_CONFIG } from "../config/resolve";

export async function callResolve<T>(func: string, payload: any = {}, timeoutSecs?: number): Promise<ResolveResponse<T>> {
  const defaultTimeout = func === "Ping" ? RESOLVE_CONFIG.TIMEOUTS.PING : 
                        func === "GetResolveInfo" ? RESOLVE_CONFIG.TIMEOUTS.GET_INFO :
                        func === "GetTimelineInfo" ? RESOLVE_CONFIG.TIMEOUTS.GET_TIMELINE : 
                        RESOLVE_CONFIG.TIMEOUTS.APPLY;

  try {
    const response = await invoke<any>("resolve_bridge", {
      payload: { ...payload, func },
      timeoutSecs: timeoutSecs || defaultTimeout,
    });
    return response as ResolveResponse<T>;
  } catch (error: any) {
    console.error(`[EditCOPY UI] Error calling ${func}:`, error);
    return {
      ok: false,
      error: typeof error === 'string' ? error : (error.message || "O DaVinci Resolve não respondeu dentro do tempo esperado."),
      detail: JSON.stringify(error),
      func,
    };
  }
}

export const pingResolve = () => callResolve<{ message: string }>("Ping");
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
