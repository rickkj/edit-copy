import React, { useState, useEffect, useCallback } from 'react';
import { Header } from './Header';
import { ImageQueue } from './ImageQueue';
import { Settings } from './Settings';
import { Footer } from './Footer';
import { ImageItem } from '@/types/resolve';
import { toast } from 'sonner';
import { pingResolve, getTimelineInfo } from '@/api/resolve-api';

export function EditCopyMain() {
  const [images, setImages] = useState<ImageItem[]>([]);
  const [status, setStatus] = useState<'Connected' | 'Disconnected' | 'Connecting' | 'Error'>('Disconnected');
  const [resolveName, setResolveName] = useState<string>('');
  const [settings, setSettings] = useState({
    duration: 5.0,
    mode: 'SEQUENCE' as const,
    track: 'V1'
  });

  const checkConnection = useCallback(async () => {
    setStatus('Connecting');
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
        toast.error("DaVinci Resolve não conectado", {
          description: "Certifique-se que o script EditCOPY está rodando no Resolve."
        });
      }
    } catch (e) {
      setStatus('Error');
    }
  }, []);

  useEffect(() => {
    checkConnection();
    const interval = setInterval(checkConnection, 30000);
    return () => clearInterval(interval);
  }, [checkConnection]);

  const handlePaste = useCallback((e: ClipboardEvent) => {
    // A ser implementado com o plugin de clipboard do Tauri
    console.log('[EditCOPY] Paste detected');
    toast.info("Imagem detectada no clipboard (Simulação)");
  }, []);

  useEffect(() => {
    window.addEventListener('paste', handlePaste);
    return () => window.removeEventListener('paste', handlePaste);
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
        onApply={() => toast.promise(
          new Promise((resolve) => setTimeout(resolve, 2000)),
          {
            loading: 'Enviando para o Resolve...',
            success: 'Imagens inseridas na timeline!',
            error: 'Erro ao inserir imagens.'
          }
        )} 
        canApply={images.length > 0 && status === 'Connected'}
      />
    </div>
  );
}
