import { invoke } from "@tauri-apps/api/core";
import { ResolveResponse, ResolveInfo, TimelineInfo } from "../types/resolve";

export async function callResolve<T>(func: string, payload: any = {}, timeoutSecs: number = 15): Promise<ResolveResponse<T>> {
  try {
    const response = await invoke<ResolveResponse<T>>("resolve_bridge", {
      payload: { ...payload, func },
      timeoutSecs,
    });
    return response;
  } catch (error: any) {
    console.error(`[EditCOPY] Error calling ${func}:`, error);
    return {
      ok: false,
      error: error.message || "Erro desconhecido na comunicação com o bridge.",
      detail: error.toString(),
      func,
    };
  }
}

export const pingResolve = () => callResolve<{ ok: boolean }>("Ping");
export const getResolveInfo = () => callResolve<ResolveInfo>("GetResolveInfo");
export const getTimelineInfo = () => callResolve<TimelineInfo>("GetTimelineInfo");
export const importImages = (paths: string[]) => callResolve("ImportImages", { paths }, 60);
export const applyImages = (data: { paths: string[], duration: number, track: string }) => 
  callResolve("ApplyImages", data, 60);
