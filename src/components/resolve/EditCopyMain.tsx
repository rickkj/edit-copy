import React, { useState, useEffect, useCallback } from 'react';
import { Header } from './Header';
import { ImageQueue } from './ImageQueue';
import { Settings } from './Settings';
import { Footer } from './Footer';
import { ImageItem } from '@/types/resolve';
import { toast } from 'sonner';
import { pingResolve, getTimelineInfo, applyImages } from '@/api/resolve-api';
import { processClipboardImage } from '@/api/clipboard';

export function EditCopyMain() {
  const [images, setImages] = useState<ImageItem[]>([]);
  const [status, setStatus] = useState<'Connected' | 'Disconnected' | 'Connecting' | 'Error'>('Disconnected');
  const [resolveName, setResolveName] = useState<string>('');
  const [isApplying, setIsApplying] = useState(false);
  const [settings, setSettings] = useState({
    duration: 5.0,
    mode: 'SEQUENCE' as const,
    track: 'V1'
  });

  const checkConnection = useCallback(async () => {
    try {
      const res = await pingResolve();
      if (res.ok) {
        setStatus('Connected');
        const info = await getTimelineInfo();
        if (info.ok && info.data) {
           setResolveName(info.data.name);
        }
      } else {
        setStatus('Disconnected');
      }
    } catch (e) {
      setStatus('Disconnected');
    }
  }, []);

  useEffect(() => {
    checkConnection();
    const interval = setInterval(checkConnection, 10000);
    return () => clearInterval(interval);
  }, [checkConnection]);

  const handlePaste = useCallback(async () => {
    const newImage = await processClipboardImage();
    if (newImage) {
      setImages(prev => [...prev, newImage]);
      toast.success("Imagem adicionada à fila");
    } else {
      toast.error("O clipboard não contém uma imagem válida");
    }
  }, []);

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if ((e.ctrlKey || e.metaKey) && e.key === 'v') {
        handlePaste();
      }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [handlePaste]);


  return (
    <div className="flex flex-col h-screen max-w-4xl mx-auto overflow-hidden border-x border-[#1A1A1A]">
      <Header status={status} onTestConnection={checkConnection} />
      
      <main className="flex-1 flex flex-col overflow-hidden">
        <div className="flex-1 overflow-y-auto p-4 custom-scrollbar">
          <ImageQueue 
            images={images} 
            onRemove={(id: string) => setImages(prev => prev.filter(img => img.id !== id))}
            onClear={() => setImages([])}
          />
        </div>
        
        <div className="p-4 border-t border-[#1A1A1A] bg-[#0F0F0F]">
          <Settings 
            values={settings} 
            onChange={(newSettings: any) => setSettings(prev => ({ ...prev, ...newSettings }))} 
          />
        </div>
      </main>

      <Footer 
        status={status} 
        onApply={async () => {
          setIsApplying(true);
          const paths = images.map(img => img.path);
          const res = await applyImages(paths, settings.duration, settings.track);
          
          if (res.ok) {
            toast.success("Imagens aplicadas com sucesso!");
            setImages([]);
          } else {
            toast.error("Erro ao aplicar imagens", {
              description: res.error
            });
          }
          setIsApplying(false);
        }} 
        canApply={images.length > 0 && status === 'Connected' && !isApplying}
      />

    </div>
  );
}
