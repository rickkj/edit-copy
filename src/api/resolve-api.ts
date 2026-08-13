import { invoke } from "@tauri-apps/api/core";

import {
  ResolveResponse,
  ResolveInfo,
  TimelineInfo,
} from "../types/resolve";

export async function callResolve<T = unknown>(
  func: string,
  payload: Record<string, unknown> = {},
  timeoutSecs = 15
): Promise<ResolveResponse<T>> {

  try {

    const raw = await invoke<string>(
      "resolve_bridge",
      {
        args: {
          payload: {
            ...payload,
            func,
          },
          timeoutSecs,
        },
      }
    );

    const response =
      JSON.parse(raw) as ResolveResponse<T>;

    return response;

  } catch (error) {

    console.error(
      `[EditCOPY] ${func} failed:`,
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
            : "Erro na comunicação com o DaVinci Resolve.",
    };
  }
}

export function pingResolve() {
  return callResolve<{ message: string }>(
    "Ping",
    {},
    10
  );
}

export function getResolveInfo() {
  return callResolve<ResolveInfo>(
    "GetResolveInfo",
    {},
    10
  );
}

export function getTimelineInfo() {
  return callResolve<TimelineInfo>(
    "GetTimelineInfo",
    {},
    10
  );
}
