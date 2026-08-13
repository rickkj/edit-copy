import React from 'react';

interface SettingsValues {
  duration: number;
  mode: 'SEQUENCE';
  track: string;
}

interface SettingsProps {
  values: SettingsValues;
  onChange: (values: Partial<SettingsValues>) => void;
}

export function Settings({ values, onChange }: SettingsProps) {
  return (
    <div className="grid grid-cols-3 gap-6">
      <div className="space-y-2">
        <label className="text-[10px] font-bold uppercase tracking-widest text-[#606060]">Duração (sec)</label>
        <div className="relative">
          <input 
            type="number" 
            step="0.1"
            min="0.1"
            value={values.duration}
            onChange={(e) => onChange({ duration: parseFloat(e.target.value) || 0.1 })}
            className="w-full bg-[#151515] border border-[#2A2A2A] rounded-md px-3 py-2 text-sm focus:border-primary focus:ring-1 focus:ring-primary outline-none transition-all"
          />
        </div>
      </div>

      <div className="space-y-2">
        <label className="text-[10px] font-bold uppercase tracking-widest text-[#606060]">Modo</label>
        <select 
          value={values.mode}
          onChange={(e) => onChange({ mode: e.target.value as 'SEQUENCE' })}
          className="w-full bg-[#151515] border border-[#2A2A2A] rounded-md px-3 py-2 text-sm focus:border-primary outline-none appearance-none cursor-pointer"
        >
          <option value="SEQUENCE">SEQUENCE</option>
        </select>
      </div>

      <div className="space-y-2">
        <label className="text-[10px] font-bold uppercase tracking-widest text-[#606060]">Track</label>
        <select 
          value={values.track}
          onChange={(e) => onChange({ track: e.target.value })}
          className="w-full bg-[#151515] border border-[#2A2A2A] rounded-md px-3 py-2 text-sm focus:border-primary outline-none appearance-none cursor-pointer"
        >
          <option value="V1">V1</option>
          <option value="V2">V2</option>
          <option value="V3">V3</option>
          <option value="V4">V4</option>
        </select>
      </div>
    </div>
  );
}
