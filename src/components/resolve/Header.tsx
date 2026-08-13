import React from 'react';
import { cn } from '@/lib/utils';
import { RefreshCw } from 'lucide-react';

interface HeaderProps {
  status: 'Connected' | 'Disconnected' | 'Connecting' | 'Error';
  onTestConnection: () => void;
}

export function Header({ status, onTestConnection }: HeaderProps) {
  const statusColors = {
    Connected: 'bg-green-500',
    Disconnected: 'bg-gray-500',
    Connecting: 'bg-yellow-500 animate-pulse',
    Error: 'bg-red-500'
  };

  return (
    <header className="flex items-center justify-between px-6 py-4 bg-[#0F0F0F] border-b border-[#1A1A1A]">
      <div className="flex items-center gap-3">
        <div className="w-8 h-8 bg-primary rounded flex items-center justify-center font-bold text-black text-xs">
          EC
        </div>
        <h1 className="text-lg font-bold tracking-tight uppercase tracking-widest text-[#F5F5F5]">
          Edit<span className="text-primary">COPY</span>
        </h1>
      </div>

      <div className="flex items-center gap-4">
        <div className="flex items-center gap-2 px-3 py-1.5 bg-[#1A1A1A] rounded-full border border-[#2A2A2A]">
          <div className={cn("w-2 h-2 rounded-full", statusColors[status])} />
          <span className="text-xs font-medium text-[#A0A0A0]">{status}</span>
        </div>
        
        <button 
          onClick={onTestConnection}
          className="p-2 hover:bg-[#1A1A1A] rounded-md transition-colors text-[#A0A0A0] hover:text-[#F5F5F5]"
          title="Test Connection"
        >
          <RefreshCw size={16} />
        </button>
      </div>
    </header>
  );
}
