import { invoke } from "@tauri-apps/api/core";
import {
  ResolveResponse,
  ResolveInfo,
  TimelineInfo,
  ImageItem,
} from "../types/resolve";

export async function callResolve<T = unknown>(
  func: string,
  payload: Record<string, unknown> = {},
  timeoutSecs = 15
): Promise<ResolveResponse<T>> {

  try {
    const raw = await invoke<string>("resolve_bridge", {
      payload: {
        ...payload,
        func,
      },
      timeoutSecs,
    });

    const parsed = JSON.parse(raw) as ResolveResponse<T>;

    return parsed;

  } catch (error) {

    console.error(
      `[EditCOPY] Error calling ${func}:`,
      error
    );

    return {
      ok: false,
      func,
      error:
        typeof error === "string"
          ? error
          : error instanceof Error
          ? error.message
          : "Erro na comunicação com o bridge.",
    };
  }
}

export const pingResolve = () =>
  callResolve<{ message: string }>("Ping", {}, 10);

export const getResolveInfo = () =>
  callResolve<ResolveInfo>("GetResolveInfo", {}, 10);

export const getTimelineInfo = () =>
  callResolve<TimelineInfo>("GetTimelineInfo", {}, 10);
