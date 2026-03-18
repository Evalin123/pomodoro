import { Play, Pause, RotateCcw, Coffee, Settings, BarChart3, Clock, Target, Zap, Leaf } from 'lucide-react';
import { useState } from 'react';

interface Session {
  id: number;
  type: 'focus' | 'break';
  duration: number;
  timestamp: Date;
}

interface DesktopLayoutProps {
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

export function DesktopLayout({
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
}: DesktopLayoutProps) {
  const [showSettings, setShowSettings] = useState(false);
  const [tempFocus, setTempFocus] = useState(focusMinutes);
  const [tempBreak, setTempBreak] = useState(breakMinutes);

  const handleSaveSettings = () => {
    onSettingsChange(tempFocus, tempBreak);
    setShowSettings(false);
  };

  const totalFocusTime = sessions
    .filter((s) => s.type === 'focus')
    .reduce((acc, s) => acc + s.duration, 0);

  return (
    <div 
      className="min-h-screen"
      style={{ 
        background: 'linear-gradient(135deg, #F8F7F4 0%, #F0EDE6 50%, #E8E5DC 100%)',
        color: '#2D3748'
      }}
    >
      {/* Menubar */}
      <div 
        className="h-16 flex items-center justify-between px-8"
        style={{ 
          borderBottom: '1px solid #E2E8F0',
          backgroundColor: 'rgba(255, 255, 255, 0.6)',
          backdropFilter: 'blur(12px)'
        }}
      >
        <div className="flex items-center gap-3">
          <div 
            className="w-10 h-10 rounded-xl flex items-center justify-center"
            style={{ 
              background: 'linear-gradient(135deg, #38A169 0%, #2F855A 100%)',
              boxShadow: '0 2px 8px rgba(56, 161, 105, 0.2)'
            }}
          >
            <Leaf className="w-5 h-5" style={{ color: '#FFFFFF' }} />
          </div>
          <h1 style={{ color: '#2D3748' }}>Pomodoro Timer</h1>
        </div>
        <div className="flex items-center gap-2">
          <button
            onClick={() => setShowSettings(!showSettings)}
            className="px-5 py-2 rounded-lg flex items-center gap-2 transition-all"
            style={{ 
              backgroundColor: showSettings ? '#FFFFFF' : 'transparent',
              color: showSettings ? '#2D3748' : '#718096',
              boxShadow: showSettings ? '0 2px 8px rgba(0, 0, 0, 0.06)' : 'none'
            }}
          >
            <Settings className="w-4 h-4" />
            <span className="text-sm">Settings</span>
          </button>
        </div>
      </div>

      <div className="grid grid-cols-[1fr_420px] h-[calc(100vh-64px)]">
        {/* Main Timer Area */}
        <div className="flex flex-col items-center justify-center px-12 py-16">
          {/* Session Indicator */}
          <div 
            className="mb-12 inline-flex items-center gap-3 px-6 py-3 rounded-full"
            style={{ 
              backgroundColor: '#FFFFFF',
              border: '1px solid #E2E8F0',
              boxShadow: '0 2px 8px rgba(0, 0, 0, 0.06)'
            }}
          >
            {isBreak ? (
              <>
                <Coffee className="w-5 h-5" style={{ color: '#38A169' }} />
                <span className="text-base" style={{ color: '#38A169' }}>Break Time</span>
              </>
            ) : (
              <>
                <div 
                  className="w-2.5 h-2.5 rounded-full animate-pulse" 
                  style={{ backgroundColor: '#D69E2E' }}
                />
                <span className="text-base" style={{ color: '#D69E2E' }}>Focus Session</span>
              </>
            )}
          </div>

          {/* Large Circular Timer */}
          <div className="relative mb-16">
            <svg className="w-96 h-96 -rotate-90">
              {/* Background circle */}
              <circle
                cx="192"
                cy="192"
                r="176"
                stroke="#E2E8F0"
                strokeWidth="14"
                fill="none"
              />
              {/* Progress circle */}
              <circle
                cx="192"
                cy="192"
                r="176"
                stroke={isBreak ? "#38A169" : "#D69E2E"}
                strokeWidth="14"
                fill="none"
                strokeDasharray={`${2 * Math.PI * 176}`}
                strokeDashoffset={`${2 * Math.PI * 176 * (1 - progress)}`}
                strokeLinecap="round"
                style={{
                  transition: 'all 1000ms ease-out',
                  filter: `drop-shadow(0 0 20px ${isBreak ? 'rgba(56, 161, 105, 0.4)' : 'rgba(214, 158, 46, 0.4)'})`,
                }}
              />
            </svg>

            {/* Time Display */}
            <div className="absolute inset-0 flex items-center justify-center">
              <div className="text-center">
                <div className="text-8xl font-bold tabular-nums mb-4 tracking-tight" style={{ color: '#2D3748' }}>
                  {String(minutes).padStart(2, '0')}:{String(seconds).padStart(2, '0')}
                </div>
                <div style={{ color: '#718096' }}>
                  {isBreak ? 'Relax and recharge' : 'Stay focused on your task'}
                </div>
              </div>
            </div>
          </div>

          {/* Controls */}
          <div className="flex gap-6">
            <button
              onClick={onReset}
              className="w-16 h-16 rounded-full flex items-center justify-center transition-all active:scale-95 hover:scale-105"
              style={{ 
                backgroundColor: '#FFFFFF',
                border: '1px solid #E2E8F0',
                boxShadow: '0 2px 8px rgba(0, 0, 0, 0.06)',
                color: '#4A5568'
              }}
            >
              <RotateCcw className="w-6 h-6" />
            </button>
            <button
              onClick={isRunning ? onPause : onStart}
              className="w-24 h-24 rounded-full flex items-center justify-center transition-all hover:scale-105 active:scale-95"
              style={{ 
                background: isBreak 
                  ? 'linear-gradient(135deg, #38A169 0%, #2F855A 100%)' 
                  : 'linear-gradient(135deg, #D69E2E 0%, #B7791F 100%)',
                boxShadow: isBreak 
                  ? '0 8px 32px rgba(56, 161, 105, 0.4)' 
                  : '0 8px 32px rgba(214, 158, 46, 0.4)',
                color: '#FFFFFF'
              }}
            >
              {isRunning ? (
                <Pause className="w-10 h-10" fill="white" />
              ) : (
                <Play className="w-10 h-10 ml-1" fill="white" />
              )}
            </button>
          </div>
        </div>

        {/* Sidebar */}
        <div 
          className="flex flex-col overflow-hidden"
          style={{ 
            borderLeft: '1px solid #E2E8F0',
            backgroundColor: 'rgba(255, 255, 255, 0.5)',
            backdropFilter: 'blur(12px)'
          }}
        >
          {/* Settings Panel */}
          {showSettings ? (
            <div 
              className="p-6"
              style={{ borderBottom: '1px solid #E2E8F0' }}
            >
              <h2 className="mb-6" style={{ color: '#2D3748' }}>Timer Settings</h2>
              <div className="space-y-6">
                <div>
                  <label className="text-sm mb-2 block" style={{ color: '#718096' }}>
                    Focus Duration
                  </label>
                  <div className="flex items-center gap-3">
                    <input
                      type="range"
                      min="1"
                      max="60"
                      value={tempFocus}
                      onChange={(e) => setTempFocus(Number(e.target.value))}
                      className="flex-1"
                      style={{ accentColor: '#38A169' }}
                    />
                    <span className="w-16 text-right" style={{ color: '#2D3748' }}>
                      {tempFocus} min
                    </span>
                  </div>
                </div>
                <div>
                  <label className="text-sm mb-2 block" style={{ color: '#718096' }}>
                    Break Duration
                  </label>
                  <div className="flex items-center gap-3">
                    <input
                      type="range"
                      min="1"
                      max="30"
                      value={tempBreak}
                      onChange={(e) => setTempBreak(Number(e.target.value))}
                      className="flex-1"
                      style={{ accentColor: '#38A169' }}
                    />
                    <span className="w-16 text-right" style={{ color: '#2D3748' }}>
                      {tempBreak} min
                    </span>
                  </div>
                </div>
                <button
                  onClick={handleSaveSettings}
                  className="w-full py-3 transition-all active:scale-98"
                  style={{ 
                    background: 'linear-gradient(135deg, #38A169 0%, #2F855A 100%)',
                    borderRadius: '8px',
                    color: '#FFFFFF',
                    boxShadow: '0 4px 16px rgba(56, 161, 105, 0.2)'
                  }}
                >
                  Save Changes
                </button>
              </div>
            </div>
          ) : (
            <div 
              className="p-6"
              style={{ borderBottom: '1px solid #E2E8F0' }}
            >
              <h2 className="mb-6" style={{ color: '#2D3748' }}>Today's Stats</h2>
              <div className="space-y-4">
                <div 
                  className="flex items-center gap-4 p-4 rounded-xl"
                  style={{ 
                    backgroundColor: 'rgba(214, 158, 46, 0.1)',
                    border: '1px solid rgba(214, 158, 46, 0.2)'
                  }}
                >
                  <div 
                    className="w-12 h-12 rounded-lg flex items-center justify-center"
                    style={{ backgroundColor: 'rgba(214, 158, 46, 0.2)' }}
                  >
                    <Target className="w-6 h-6" style={{ color: '#D69E2E' }} />
                  </div>
                  <div>
                    <div className="text-2xl font-bold" style={{ color: '#2D3748' }}>
                      {sessionsCompleted}
                    </div>
                    <div className="text-sm" style={{ color: '#718096' }}>
                      Sessions completed
                    </div>
                  </div>
                </div>
                <div 
                  className="flex items-center gap-4 p-4 rounded-xl"
                  style={{ 
                    backgroundColor: 'rgba(49, 130, 206, 0.1)',
                    border: '1px solid rgba(49, 130, 206, 0.2)'
                  }}
                >
                  <div 
                    className="w-12 h-12 rounded-lg flex items-center justify-center"
                    style={{ backgroundColor: 'rgba(49, 130, 206, 0.2)' }}
                  >
                    <Clock className="w-6 h-6" style={{ color: '#3182CE' }} />
                  </div>
                  <div>
                    <div className="text-2xl font-bold" style={{ color: '#2D3748' }}>
                      {Math.floor(totalFocusTime / 60)}h {totalFocusTime % 60}m
                    </div>
                    <div className="text-sm" style={{ color: '#718096' }}>
                      Focus time
                    </div>
                  </div>
                </div>
                <div 
                  className="flex items-center gap-4 p-4 rounded-xl"
                  style={{ 
                    backgroundColor: 'rgba(56, 161, 105, 0.1)',
                    border: '1px solid rgba(56, 161, 105, 0.2)'
                  }}
                >
                  <div 
                    className="w-12 h-12 rounded-lg flex items-center justify-center"
                    style={{ backgroundColor: 'rgba(56, 161, 105, 0.2)' }}
                  >
                    <Zap className="w-6 h-6" style={{ color: '#38A169' }} />
                  </div>
                  <div>
                    <div className="text-2xl font-bold" style={{ color: '#2D3748' }}>
                      {sessionsCompleted > 0 ? '🔥' : '—'}
                    </div>
                    <div className="text-sm" style={{ color: '#718096' }}>
                      Current streak
                    </div>
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* Session History */}
          <div className="flex-1 overflow-hidden flex flex-col p-6">
            <div className="flex items-center gap-2 mb-4">
              <BarChart3 className="w-5 h-5" style={{ color: '#718096' }} />
              <h3 style={{ color: '#2D3748' }}>Recent Sessions</h3>
            </div>
            <div className="flex-1 overflow-y-auto space-y-2">
              {sessions.length === 0 ? (
                <div className="text-center py-12" style={{ color: '#718096' }}>
                  <p>No sessions yet</p>
                  <p className="text-sm mt-1">Start your first focus session!</p>
                </div>
              ) : (
                sessions.slice(-10).reverse().map((session) => (
                  <div
                    key={session.id}
                    className="p-3 rounded-lg flex items-center gap-3"
                    style={{ 
                      backgroundColor: 'rgba(255, 255, 255, 0.5)',
                      border: '1px solid #E2E8F0'
                    }}
                  >
                    <div
                      className="w-10 h-10 rounded-lg flex items-center justify-center"
                      style={{ 
                        backgroundColor: session.type === 'focus' 
                          ? 'rgba(214, 158, 46, 0.15)' 
                          : 'rgba(56, 161, 105, 0.15)'
                      }}
                    >
                      {session.type === 'focus' ? (
                        <Target className="w-4 h-4" style={{ color: '#D69E2E' }} />
                      ) : (
                        <Coffee className="w-4 h-4" style={{ color: '#38A169' }} />
                      )}
                    </div>
                    <div className="flex-1">
                      <div className="text-sm capitalize" style={{ color: '#2D3748' }}>
                        {session.type} Session
                      </div>
                      <div className="text-xs" style={{ color: '#718096' }}>
                        {session.duration} min • {session.timestamp.toLocaleTimeString()}
                      </div>
                    </div>
                  </div>
                ))
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
