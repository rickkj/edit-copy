import React, { useState, useEffect, useCallback } from 'react';
import { Header } from './Header';
import { ImageQueue } from './ImageQueue';
import { Settings } from './Settings';
import { Footer } from './Footer';
import { ImageItem } from '@/types/resolve';
import { toast } from 'sonner';

export function EditCopyMain() {
  const [images, setImages] = useState<ImageItem[]>([]);
  const [status, setStatus] = useState<'Connected' | 'Disconnected' | 'Connecting' | 'Error'>('Disconnected');
  const [settings, setSettings] = useState({
    duration: 5.0,
    mode: 'SEQUENCE' as const,
    track: 'V1'
  });

  const handlePaste = useCallback((e: ClipboardEvent) => {
    // Implementação real do clipboard via Tauri/Rust virá na Fase 4
    console.log('[EditCOPY] Paste detected');
  }, []);

  useEffect(() => {
    window.addEventListener('paste', handlePaste);
    return () => window.removeEventListener('paste', handlePaste);
  }, [handlePaste]);

  return (
    <div className="flex flex-col h-screen max-w-4xl mx-auto overflow-hidden border-x border-[#1A1A1A]">
      <Header status={status} onTestConnection={() => console.log('Ping...')} />
      
      <main className="flex-1 flex flex-col overflow-hidden">
        <div className="flex-1 overflow-y-auto p-4 custom-scrollbar">
          <ImageQueue 
            images={images} 
            onRemove={(id) => setImages(prev => prev.filter(img => img.id !== id))}
            onClear={() => setImages([])}
          />
        </div>
        
        <div className="p-4 border-t border-[#1A1A1A] bg-[#0F0F0F]">
          <Settings 
            values={settings} 
            onChange={(newSettings) => setSettings(prev => ({ ...prev, ...newSettings }))} 
          />
        </div>
      </main>

      <Footer 
        status={status} 
        onApply={() => toast.info('Applying to Resolve...')} 
        canApply={images.length > 0 && status === 'Connected'}
      />
    </div>
  );
}
