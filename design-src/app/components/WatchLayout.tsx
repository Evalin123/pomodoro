import { Play, Pause, RotateCcw, Coffee, Settings, Leaf, History, ChevronLeft } from 'lucide-react';
import { useState } from 'react';

interface Session {
  id: number;
  type: 'focus' | 'break';
  duration: number;
  timestamp: Date;
}

interface WatchLayoutProps {
  minutes: number;
  seconds: number;
  isRunning: boolean;
  isBreak: boolean;
  onStart: () => void;
  onPause: () => void;
  onReset: () => void;
  progress: number;
  sessionsCompleted: number;
  focusMinutes: number;
  breakMinutes: number;
  onSettingsChange: (focus: number, breakTime: number) => void;
  sessions: Session[];
}

export function WatchLayout({
  minutes,
  seconds,
  isRunning,
  isBreak,
  onStart,
  onPause,
  onReset,
  progress,
  sessionsCompleted,
  focusMinutes,
  breakMinutes,
  onSettingsChange,
  sessions,
}: WatchLayoutProps) {
  const [activeView, setActiveView] = useState<'timer' | 'settings' | 'history'>('timer');
  const [tempFocus, setTempFocus] = useState(focusMinutes);
  const [tempBreak, setTempBreak] = useState(breakMinutes);

  const handleSaveSettings = () => {
    onSettingsChange(tempFocus, tempBreak);
    setActiveView('timer');
  };

  const renderTimer = () => (
    <div className="flex flex-col items-center justify-between h-full w-full py-4 px-2 relative animate-in fade-in zoom-in-95 duration-300">
      {/* Top Nav */}
      <div className="flex items-center justify-between w-full px-4 mb-1 z-10">
        <button onClick={() => setActiveView('history')} className="text-[#718096] hover:text-[#38A169] transition-colors">
          <History className="w-3.5 h-3.5" />
        </button>
        <div className="flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-white/60 shadow-sm border border-white/40">
          {isBreak ? (
            <Coffee className="w-2.5 h-2.5" style={{ color: '#38A169' }} />
          ) : (
            <Leaf className="w-2.5 h-2.5" style={{ color: '#D69E2E' }} />
          )}
          <span className="text-[9px] font-bold tracking-wider uppercase" style={{ color: isBreak ? '#38A169' : '#D69E2E' }}>
            {isBreak ? 'REST' : 'FLOW'}
          </span>
        </div>
        <button onClick={() => setActiveView('settings')} className="text-[#718096] hover:text-[#D69E2E] transition-colors">
          <Settings className="w-3.5 h-3.5" />
        </button>
      </div>

      {/* Circular timer */}
      <div className="relative flex items-center justify-center flex-1 w-full scale-110">
        {/* Progress circle SVG */}
        <svg className="w-[140px] h-[140px] -rotate-90">
          <circle
            cx="70"
            cy="70"
            r="62"
            stroke="rgba(226, 232, 240, 0.5)"
            strokeWidth="8"
            fill="none"
          />
          <circle
            cx="70"
            cy="70"
            r="62"
            stroke={isBreak ? "#38A169" : "#D69E2E"}
            strokeWidth="8"
            fill="none"
            strokeDasharray={`${2 * Math.PI * 62}`}
            strokeDashoffset={`${2 * Math.PI * 62 * (1 - progress)}`}
            strokeLinecap="round"
            style={{ 
              transition: 'all 1000ms ease-out',
              filter: `drop-shadow(0 2px 8px ${isBreak ? 'rgba(56, 161, 105, 0.4)' : 'rgba(214, 158, 46, 0.4)'})`
            }}
          />
        </svg>

        {/* Time display */}
        <div className="absolute inset-0 flex flex-col items-center justify-center pointer-events-none mt-1">
          <div className="text-4xl font-light tabular-nums tracking-tighter" style={{ color: '#2D3748', lineHeight: 1 }}>
            {String(minutes).padStart(2, '0')}<span className="text-3xl opacity-80 animate-pulse">:</span>{String(seconds).padStart(2, '0')}
          </div>
        </div>
      </div>

      {/* Controls */}
      <div className="flex gap-4 items-center z-10 mt-1 pb-1">
        <button
          onClick={onReset}
          className="w-9 h-9 rounded-full flex items-center justify-center transition-all active:scale-95 bg-white/80 backdrop-blur-md border border-white/50"
          style={{ 
            boxShadow: '0 2px 8px rgba(0, 0, 0, 0.04)',
            color: '#4A5568'
          }}
        >
          <RotateCcw className="w-3.5 h-3.5" />
        </button>
        <button
          onClick={isRunning ? onPause : onStart}
          className="w-11 h-11 rounded-full flex items-center justify-center transition-all active:scale-95 border border-white/20"
          style={{ 
            background: isBreak ? 'linear-gradient(135deg, #38A169 0%, #2F855A 100%)' : 'linear-gradient(135deg, #D69E2E 0%, #B7791F 100%)',
            boxShadow: isBreak ? '0 4px 12px rgba(56, 161, 105, 0.3)' : '0 4px 12px rgba(214, 158, 46, 0.3)',
            color: '#FFFFFF'
          }}
        >
          {isRunning ? <Pause className="w-4 h-4" fill="white" /> : <Play className="w-4 h-4 ml-0.5" fill="white" />}
        </button>
      </div>
    </div>
  );

  const renderSettings = () => (
    <div className="flex flex-col h-full w-full p-4 relative animate-in fade-in slide-in-from-right-2 duration-300 bg-white/40 backdrop-blur-md">
      <div className="flex items-center mb-3">
        <button onClick={() => setActiveView('timer')} className="mr-2 text-[#718096] hover:text-[#2D3748]">
          <ChevronLeft className="w-4 h-4" />
        </button>
        <h2 className="text-[13px] font-semibold tracking-wide uppercase" style={{ color: '#2D3748' }}>Settings</h2>
      </div>

      <div className="flex-1 flex flex-col justify-center gap-3">
        <div className="bg-white/60 p-2.5 rounded-2xl shadow-sm border border-white/50">
          <div className="flex justify-between items-center mb-1.5">
            <span className="text-[10px] font-medium text-[#718096] uppercase tracking-wide">Focus</span>
            <span className="text-[11px] font-bold text-[#D69E2E]">{tempFocus}m</span>
          </div>
          <input
            type="range"
            min="1"
            max="60"
            value={tempFocus}
            onChange={(e) => setTempFocus(Number(e.target.value))}
            className="w-full h-1 bg-[#E2E8F0] rounded-full appearance-none accent-[#D69E2E]"
          />
        </div>

        <div className="bg-white/60 p-2.5 rounded-2xl shadow-sm border border-white/50">
          <div className="flex justify-between items-center mb-1.5">
            <span className="text-[10px] font-medium text-[#718096] uppercase tracking-wide">Break</span>
            <span className="text-[11px] font-bold text-[#38A169]">{tempBreak}m</span>
          </div>
          <input
            type="range"
            min="1"
            max="30"
            value={tempBreak}
            onChange={(e) => setTempBreak(Number(e.target.value))}
            className="w-full h-1 bg-[#E2E8F0] rounded-full appearance-none accent-[#38A169]"
          />
        </div>
      </div>

      <button
        onClick={handleSaveSettings}
        className="mt-3 py-2 w-full rounded-full text-[11px] font-bold tracking-wide uppercase shadow-sm active:scale-95 transition-all"
        style={{ background: 'linear-gradient(135deg, #38A169 0%, #2F855A 100%)', color: 'white' }}
      >
        Save
      </button>
    </div>
  );

  const renderHistory = () => (
    <div className="flex flex-col h-full w-full p-4 relative animate-in fade-in slide-in-from-left-2 duration-300 bg-white/40 backdrop-blur-md">
      <div className="flex items-center justify-between mb-3">
        <h2 className="text-[13px] font-semibold tracking-wide uppercase" style={{ color: '#2D3748' }}>History</h2>
        <button onClick={() => setActiveView('timer')} className="text-[#718096] hover:text-[#2D3748]">
          <ChevronLeft className="w-4 h-4 rotate-180" />
        </button>
      </div>

      <div className="flex-1 overflow-y-auto pr-1 space-y-2 scrollbar-hide flex flex-col items-center">
        {sessions.length === 0 ? (
          <div className="m-auto text-center opacity-70">
            <Leaf className="w-6 h-6 mx-auto mb-1 text-[#718096]" />
            <p className="text-[10px] font-medium text-[#4A5568]">No sessions</p>
          </div>
        ) : (
          [...sessions].reverse().map((session) => (
            <div 
              key={session.id}
              className="w-full flex items-center justify-between p-2 rounded-xl bg-white/70 shadow-sm border border-white/50"
            >
              <div className="flex items-center gap-2">
                <div 
                  className="w-6 h-6 rounded-full flex items-center justify-center"
                  style={{ backgroundColor: session.type === 'focus' ? 'rgba(214, 158, 46, 0.15)' : 'rgba(56, 161, 105, 0.15)' }}
                >
                  {session.type === 'focus' ? (
                    <Leaf className="w-3 h-3 text-[#D69E2E]" />
                  ) : (
                    <Coffee className="w-3 h-3 text-[#38A169]" />
                  )}
                </div>
                <span className="text-[11px] font-semibold capitalize text-[#2D3748]">
                  {session.type}
                </span>
              </div>
              <span className="text-[11px] font-bold tabular-nums" style={{ color: session.type === 'focus' ? '#D69E2E' : '#38A169' }}>
                {session.duration}m
              </span>
            </div>
          ))
        )}
      </div>
    </div>
  );

  return (
    <div 
      className="flex flex-col h-full w-full font-sans relative overflow-hidden text-[#2D3748]"
      style={{ 
        background: 'linear-gradient(160deg, #F8F7F4 0%, #F0EDE6 50%, #E8E5DC 100%)',
      }}
    >
      {/* Tiny decorative background blobs */}
      <div 
        className="absolute -top-12 -right-12 w-24 h-24 rounded-full mix-blend-multiply filter blur-2xl opacity-30 pointer-events-none"
        style={{ backgroundColor: '#D69E2E' }}
      />
      <div 
        className="absolute -bottom-12 -left-12 w-24 h-24 rounded-full mix-blend-multiply filter blur-2xl opacity-30 pointer-events-none"
        style={{ backgroundColor: '#38A169' }}
      />

      {activeView === 'timer' && renderTimer()}
      {activeView === 'settings' && renderSettings()}
      {activeView === 'history' && renderHistory()}
    </div>
  );
}
