import React from 'react';
import { cn } from '@/lib/utils';
import { Send } from 'lucide-react';

interface FooterProps {
  status: 'Connected' | 'Disconnected' | 'Connecting' | 'Error';
  onApply: () => void;
  canApply: boolean;
}

export function Footer({ status, onApply, canApply }: FooterProps) {
  return (
    <footer className="px-6 py-4 bg-[#0A0A0A] border-t border-[#1A1A1A] flex items-center justify-between">
      <div className="flex flex-col">
        <span className="text-[10px] uppercase tracking-widest text-[#606060] font-bold">System Status</span>
        <span className={cn(
          "text-xs font-medium",
          status === 'Connected' ? "text-green-500" : "text-[#A0A0A0]"
        )}>
          {status === 'Connected' ? 'Ready to import' : 'Waiting for DaVinci Resolve...'}
        </span>
      </div>

      <button
        disabled={!canApply}
        onClick={onApply}
        className={cn(
          "flex items-center gap-2 px-8 py-2.5 rounded-md font-bold text-sm transition-all duration-300",
          canApply 
            ? "bg-primary text-black hover:bg-primary/90 shadow-[0_0_20px_rgba(var(--primary),0.2)]" 
            : "bg-[#1A1A1A] text-[#404040] cursor-not-allowed border border-[#2A2A2A]"
        )}
      >
        <Send size={16} />
        APPLY TO TIMELINE
      </button>
    </footer>
  );
}
