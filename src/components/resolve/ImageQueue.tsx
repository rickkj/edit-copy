import React from 'react';
import { ImageItem } from '@/types/resolve';
import { X, Trash2, ImageIcon } from 'lucide-react';

interface ImageQueueProps {
  images: ImageItem[];
  onRemove: (id: string) => void;
  onClear: () => void;
}

export function ImageQueue({ images, onRemove, onClear }: ImageQueueProps) {
  if (images.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center h-full min-h-[300px] border-2 border-dashed border-[#1A1A1A] rounded-xl text-[#404040]">
        <ImageIcon size={48} strokeWidth={1} className="mb-4 opacity-20" />
        <p className="text-sm font-medium">Fila vazia</p>
        <p className="text-xs opacity-60 mt-1">Copie uma imagem (CTRL+C) e cole aqui (CTRL+V)</p>
      </div>
    );
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between mb-4">
        <h2 className="text-xs font-bold uppercase tracking-widest text-[#606060]">Image Queue ({images.length})</h2>
        <button 
          onClick={onClear}
          className="text-[10px] uppercase tracking-widest text-red-500/70 hover:text-red-500 flex items-center gap-1.5 transition-colors font-bold"
        >
          <Trash2 size={12} /> Limpar Tudo
        </button>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
        {images.map((img) => (
          <div 
            key={img.id} 
            className="group relative bg-[#0F0F0F] border border-[#1A1A1A] rounded-lg overflow-hidden hover:border-primary/50 transition-all duration-300"
          >
            <div className="aspect-video relative overflow-hidden bg-[#050505]">
              <img 
                src={img.thumbnail} 
                alt={img.name} 
                className="w-full h-full object-contain transition-transform duration-500 group-hover:scale-105" 
              />
              <button 
                onClick={() => onRemove(img.id)}
                className="absolute top-2 right-2 p-1.5 bg-black/60 rounded-md text-white opacity-0 group-hover:opacity-100 transition-opacity hover:bg-red-500"
              >
                <X size={14} />
              </button>
            </div>
            
            <div className="p-3">
              <p className="text-xs font-medium truncate text-[#D0D0D0] mb-1">{img.name}</p>
              <div className="flex items-center justify-between">
                <span className="text-[10px] text-[#606060] font-mono uppercase">
                  PNG • {img.width}×{img.height}
                </span>
                <span className="text-[10px] text-[#606060] font-mono">
                  {(img.size / 1024).toFixed(1)} KB
                </span>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
