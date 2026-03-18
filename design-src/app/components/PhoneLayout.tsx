import { Play, Pause, RotateCcw, Coffee, Settings, BarChart3, Leaf, History, ChevronLeft, Calendar } from 'lucide-react';
import { useState } from 'react';

interface Session {
  id: number;
  type: 'focus' | 'break';
  duration: number;
  timestamp: Date;
}

interface PhoneLayoutProps {
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

export function PhoneLayout({
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
}: PhoneLayoutProps) {
  const [activeView, setActiveView] = useState<'timer' | 'settings' | 'history'>('timer');
  const [tempFocus, setTempFocus] = useState(focusMinutes);
  const [tempBreak, setTempBreak] = useState(breakMinutes);

  const handleSaveSettings = () => {
    onSettingsChange(tempFocus, tempBreak);
    setActiveView('timer');
  };

  const getFormatDate = (date: Date) => {
    return new Intl.DateTimeFormat('en-US', {
      hour: 'numeric',
      minute: 'numeric',
      hour12: true,
    }).format(date);
  };

  const renderTimer = () => (
    <div className="flex-1 flex flex-col items-center justify-center px-6 py-4 animate-in fade-in zoom-in-95 duration-500">
      {/* Session type */}
      <div 
        className="mb-8 flex items-center gap-3 px-6 py-2 rounded-full"
        style={{
          backgroundColor: 'rgba(255, 255, 255, 0.6)',
          border: '1px solid rgba(226, 232, 240, 0.6)',
          backdropFilter: 'blur(8px)',
        }}
      >
        {isBreak ? (
          <>
            <Coffee className="w-5 h-5" style={{ color: '#38A169' }} />
            <span className="font-medium" style={{ color: '#38A169' }}>Break Time</span>
          </>
        ) : (
          <>
            <div 
              className="w-2.5 h-2.5 rounded-full animate-pulse" 
              style={{ backgroundColor: '#D69E2E', boxShadow: '0 0 8px rgba(214, 158, 46, 0.6)' }}
            />
            <span className="font-medium" style={{ color: '#D69E2E' }}>Focus Flow</span>
          </>
        )}
      </div>

      {/* Circular Progress */}
      <div className="relative mb-12 flex justify-center items-center">
        <svg className="w-72 h-72 -rotate-90">
          <circle
            cx="144"
            cy="144"
            r="132"
            stroke="#E2E8F0"
            strokeWidth="8"
            fill="none"
            className="opacity-50"
          />
          <circle
            cx="144"
            cy="144"
            r="132"
            stroke={isBreak ? "#38A169" : "#D69E2E"}
            strokeWidth="10"
            fill="none"
            strokeDasharray={`${2 * Math.PI * 132}`}
            strokeDashoffset={`${2 * Math.PI * 132 * (1 - progress)}`}
            strokeLinecap="round"
            style={{ 
              transition: 'all 1000ms ease-out',
              filter: `drop-shadow(0 4px 16px ${isBreak ? 'rgba(56, 161, 105, 0.3)' : 'rgba(214, 158, 46, 0.3)'})`
            }}
          />
        </svg>

        {/* Time Display */}
        <div className="absolute inset-0 flex flex-col items-center justify-center">
          <div className="text-7xl font-light tabular-nums tracking-tighter mb-1" style={{ color: '#2D3748' }}>
            {String(minutes).padStart(2, '0')}:{String(seconds).padStart(2, '0')}
          </div>
          <div className="text-sm font-medium tracking-wide uppercase" style={{ color: '#718096' }}>
            {isBreak ? 'Relax & Breathe' : 'Deep Work'}
          </div>
        </div>
      </div>

      {/* Controls */}
      <div className="flex items-center gap-8 mb-10">
        <button
          onClick={onReset}
          className="w-14 h-14 rounded-full flex items-center justify-center transition-all hover:scale-105 active:scale-95"
          style={{ 
            backgroundColor: 'rgba(255,255,255,0.8)',
            border: '1px solid rgba(226, 232, 240, 0.8)',
            boxShadow: '0 4px 12px rgba(0, 0, 0, 0.04)',
            color: '#4A5568'
          }}
        >
          <RotateCcw className="w-6 h-6" />
        </button>
        <button
          onClick={isRunning ? onPause : onStart}
          className="w-20 h-20 rounded-full flex items-center justify-center transition-all hover:scale-105 active:scale-95"
          style={{ 
            background: isBreak 
              ? 'linear-gradient(135deg, #38A169 0%, #2F855A 100%)' 
              : 'linear-gradient(135deg, #D69E2E 0%, #B7791F 100%)',
            boxShadow: isBreak 
              ? '0 8px 24px rgba(56, 161, 105, 0.35)' 
              : '0 8px 24px rgba(214, 158, 46, 0.35)',
            color: '#FFFFFF'
          }}
        >
          {isRunning ? (
            <Pause className="w-8 h-8" fill="white" />
          ) : (
            <Play className="w-8 h-8 ml-1" fill="white" />
          )}
        </button>
      </div>

      {/* Stats Summary */}
      <div 
        className="flex items-center gap-2 px-5 py-3 rounded-2xl" 
        style={{ 
          backgroundColor: 'rgba(255,255,255,0.4)',
          color: '#4A5568',
        }}
      >
        <Leaf className="w-4 h-4" style={{ color: '#38A169' }} />
        <span className="text-sm font-medium">{sessionsCompleted} sessions grown today</span>
      </div>
    </div>
  );

  const renderSettings = () => (
    <div className="flex-1 flex flex-col px-6 py-6 animate-in fade-in slide-in-from-right-4 duration-300">
      <div className="flex items-center mb-8">
        <button 
          onClick={() => setActiveView('timer')}
          className="p-2 -ml-2 rounded-full hover:bg-white/50 transition-colors"
          style={{ color: '#4A5568' }}
        >
          <ChevronLeft className="w-6 h-6" />
        </button>
        <h2 className="text-2xl font-semibold ml-2" style={{ color: '#2D3748' }}>Timer Settings</h2>
      </div>

      <div className="space-y-6">
        <div 
          className="p-6 rounded-3xl"
          style={{ 
            backgroundColor: 'rgba(255, 255, 255, 0.7)',
            boxShadow: '0 8px 32px rgba(0, 0, 0, 0.04)',
            border: '1px solid rgba(255,255,255,0.4)'
          }}
        >
          <label className="text-sm font-medium mb-3 block" style={{ color: '#4A5568' }}>
            Focus Duration (minutes)
          </label>
          <div className="flex items-center gap-4">
            <input
              type="range"
              min="1"
              max="60"
              value={tempFocus}
              onChange={(e) => setTempFocus(Number(e.target.value))}
              className="flex-1 accent-[#D69E2E]"
            />
            <span className="text-xl font-semibold tabular-nums w-10 text-right" style={{ color: '#D69E2E' }}>
              {tempFocus}
            </span>
          </div>
        </div>

        <div 
          className="p-6 rounded-3xl"
          style={{ 
            backgroundColor: 'rgba(255, 255, 255, 0.7)',
            boxShadow: '0 8px 32px rgba(0, 0, 0, 0.04)',
            border: '1px solid rgba(255,255,255,0.4)'
          }}
        >
          <label className="text-sm font-medium mb-3 block" style={{ color: '#4A5568' }}>
            Break Duration (minutes)
          </label>
          <div className="flex items-center gap-4">
            <input
              type="range"
              min="1"
              max="30"
              value={tempBreak}
              onChange={(e) => setTempBreak(Number(e.target.value))}
              className="flex-1 accent-[#38A169]"
            />
            <span className="text-xl font-semibold tabular-nums w-10 text-right" style={{ color: '#38A169' }}>
              {tempBreak}
            </span>
          </div>
        </div>

        <button
          onClick={handleSaveSettings}
          className="w-full py-4 mt-6 text-lg font-medium transition-all hover:scale-[1.02] active:scale-[0.98]"
          style={{ 
            background: 'linear-gradient(135deg, #38A169 0%, #2F855A 100%)',
            borderRadius: '20px',
            color: '#FFFFFF',
            boxShadow: '0 8px 24px rgba(56, 161, 105, 0.3)'
          }}
        >
          Plant Settings
        </button>
      </div>
    </div>
  );

  const renderHistory = () => (
    <div className="flex-1 flex flex-col px-6 py-6 animate-in fade-in slide-in-from-right-4 duration-300">
      <div className="flex items-center mb-8">
        <button 
          onClick={() => setActiveView('timer')}
          className="p-2 -ml-2 rounded-full hover:bg-white/50 transition-colors"
          style={{ color: '#4A5568' }}
        >
          <ChevronLeft className="w-6 h-6" />
        </button>
        <h2 className="text-2xl font-semibold ml-2" style={{ color: '#2D3748' }}>Your Forest</h2>
      </div>

      <div className="flex-1 overflow-y-auto pb-8 pr-2 space-y-4 scrollbar-hide">
        {sessions.length === 0 ? (
          <div className="h-full flex flex-col items-center justify-center text-center opacity-60">
            <Leaf className="w-12 h-12 mb-4" style={{ color: '#718096' }} />
            <p className="text-lg font-medium" style={{ color: '#4A5568' }}>No seeds planted yet</p>
            <p className="text-sm" style={{ color: '#718096' }}>Complete a focus session to grow your forest.</p>
          </div>
        ) : (
          [...sessions].reverse().map((session) => (
            <div 
              key={session.id}
              className="flex items-center justify-between p-4 rounded-2xl"
              style={{ 
                backgroundColor: 'rgba(255, 255, 255, 0.7)',
                boxShadow: '0 4px 12px rgba(0, 0, 0, 0.03)',
                border: '1px solid rgba(255,255,255,0.4)'
              }}
            >
              <div className="flex items-center gap-4">
                <div 
                  className="w-10 h-10 rounded-full flex items-center justify-center"
                  style={{ 
                    backgroundColor: session.type === 'focus' ? 'rgba(214, 158, 46, 0.15)' : 'rgba(56, 161, 105, 0.15)',
                  }}
                >
                  {session.type === 'focus' ? (
                    <Leaf className="w-5 h-5" style={{ color: '#D69E2E' }} />
                  ) : (
                    <Coffee className="w-5 h-5" style={{ color: '#38A169' }} />
                  )}
                </div>
                <div>
                  <h4 className="font-medium capitalize" style={{ color: '#2D3748' }}>
                    {session.type} Session
                  </h4>
                  <div className="text-xs flex items-center gap-1 mt-0.5" style={{ color: '#718096' }}>
                    <Calendar className="w-3 h-3" />
                    <span>{getFormatDate(session.timestamp)}</span>
                  </div>
                </div>
              </div>
              <div className="text-lg font-semibold tabular-nums" style={{ color: session.type === 'focus' ? '#D69E2E' : '#38A169' }}>
                {session.duration}m
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );

  return (
    <div 
      className="flex flex-col h-full font-sans relative overflow-hidden"
      style={{ 
        background: 'linear-gradient(160deg, #F8F7F4 0%, #F0EDE6 50%, #E8E5DC 100%)',
        color: '#2D3748'
      }}
    >
      {/* Decorative organic background blobs */}
      <div 
        className="absolute -top-32 -right-32 w-64 h-64 rounded-full mix-blend-multiply filter blur-3xl opacity-20 pointer-events-none"
        style={{ backgroundColor: '#D69E2E' }}
      />
      <div 
        className="absolute -bottom-32 -left-32 w-64 h-64 rounded-full mix-blend-multiply filter blur-3xl opacity-20 pointer-events-none"
        style={{ backgroundColor: '#38A169' }}
      />

      {/* Header */}
      <div className="flex items-center justify-between px-6 py-5 relative z-10">
        <div className="flex items-center gap-2.5">
          <div 
            className="w-9 h-9 rounded-[14px] flex items-center justify-center"
            style={{ 
              background: 'linear-gradient(135deg, #38A169 0%, #2F855A 100%)',
              boxShadow: '0 4px 12px rgba(56, 161, 105, 0.25)'
            }}
          >
            <Leaf className="w-5 h-5" style={{ color: '#FFFFFF' }} />
          </div>
          <h1 className="text-lg font-semibold tracking-tight" style={{ color: '#2D3748' }}>
            Nature<span style={{ color: '#38A169' }}>Sync</span>
          </h1>
        </div>
        <div className="flex items-center gap-2">
          <button
            onClick={() => setActiveView(activeView === 'history' ? 'timer' : 'history')}
            className="w-10 h-10 rounded-full flex items-center justify-center transition-all active:scale-95 hover:bg-white/40"
            style={{ 
              backgroundColor: activeView === 'history' ? '#FFFFFF' : 'transparent',
              boxShadow: activeView === 'history' ? '0 4px 12px rgba(0,0,0,0.05)' : 'none',
              color: activeView === 'history' ? '#38A169' : '#718096'
            }}
          >
            <History className="w-5 h-5" />
          </button>
          <button
            onClick={() => setActiveView(activeView === 'settings' ? 'timer' : 'settings')}
            className="w-10 h-10 rounded-full flex items-center justify-center transition-all active:scale-95 hover:bg-white/40"
            style={{ 
              backgroundColor: activeView === 'settings' ? '#FFFFFF' : 'transparent',
              boxShadow: activeView === 'settings' ? '0 4px 12px rgba(0,0,0,0.05)' : 'none',
              color: activeView === 'settings' ? '#D69E2E' : '#718096'
            }}
          >
            <Settings className="w-5 h-5" />
          </button>
        </div>
      </div>

      {/* Main Content Area */}
      <div className="flex-1 relative z-10 overflow-hidden">
        {activeView === 'timer' && renderTimer()}
        {activeView === 'settings' && renderSettings()}
        {activeView === 'history' && renderHistory()}
      </div>

      {/* Bottom Safe Area */}
      <div className="h-6" />
    </div>
  );
}
