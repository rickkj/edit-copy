export interface ResolveResponse<T = any> {
  ok: boolean;
  error?: string;
  detail?: string;
  func?: string;
  data?: T;
}

export interface TimelineInfo {
  name: string;
  frameRate: number;
  currentTimecode: string;
  duration: string;
  videoTrackCount: number;
}

export interface ResolveInfo {
  product: string;
  version: string;
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
