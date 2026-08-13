export interface ResolveResponse<T = unknown> {
  ok: boolean;
  func?: string;
  error?: string;
  detail?: string;
  data?: T;
}

export interface ResolveInfo {
  product: string;
  version: string;
}

export interface TimelineInfo {
  name: string;
  frameRate: number;
  currentTimecode: string;
  duration: string;
  videoTrackCount: number;
}

export interface ImageItem {
  id: string;
  path: string;
  name: string;
  thumbnail: string;
  width: number;
  height: number;
  size: number;
}
