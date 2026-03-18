import { useEffect, useState, useCallback } from 'react';
import { WatchLayout } from './components/WatchLayout';
import { PhoneLayout } from './components/PhoneLayout';
import { DesktopLayout } from './components/DesktopLayout';

interface Session {
  id: number;
  type: 'focus' | 'break';
  duration: number;
  timestamp: Date;
}

export default function App() {
  // Responsive layout detection
  const [layout, setLayout] = useState<'watch' | 'phone' | 'desktop'>('desktop');

  // Timer state
  const [focusMinutes, setFocusMinutes] = useState(25);
  const [breakMinutes, setBreakMinutes] = useState(5);
  const [minutes, setMinutes] = useState(focusMinutes);
  const [seconds, setSeconds] = useState(0);
  const [isRunning, setIsRunning] = useState(false);
  const [isBreak, setIsBreak] = useState(false);
  const [sessionsCompleted, setSessionsCompleted] = useState(0);
  const [sessions, setSessions] = useState<Session[]>([]);

  // Detect screen size
  useEffect(() => {
    const handleResize = () => {
      const width = window.innerWidth;
      const height = window.innerHeight;
      const aspectRatio = width / height;

      // Apple Watch-like layout (square, small)
      if (width <= 250 && height <= 250) {
        setLayout('watch');
      }
      // iPhone-like layout (portrait, narrow)
      else if (width <= 768 || (width <= 1024 && aspectRatio < 0.75)) {
        setLayout('phone');
      }
      // MacBook/Desktop layout
      else {
        setLayout('desktop');
      }
    };

    handleResize();
    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  // Timer logic
  useEffect(() => {
    let interval: number | undefined;

    if (isRunning) {
      interval = window.setInterval(() => {
        setSeconds((prevSeconds) => {
          if (prevSeconds === 0) {
            setMinutes((prevMinutes) => {
              if (prevMinutes === 0) {
                // Timer completed
                handleTimerComplete();
                return isBreak ? focusMinutes : breakMinutes;
              }
              return prevMinutes - 1;
            });
            return 59;
          }
          return prevSeconds - 1;
        });
      }, 1000);
    }

    return () => {
      if (interval) clearInterval(interval);
    };
  }, [isRunning, isBreak, focusMinutes, breakMinutes]);

  const handleTimerComplete = useCallback(() => {
    // Play notification sound (in a real app)
    setIsRunning(false);

    // Log session
    const newSession: Session = {
      id: Date.now(),
      type: isBreak ? 'break' : 'focus',
      duration: isBreak ? breakMinutes : focusMinutes,
      timestamp: new Date(),
    };
    setSessions((prev) => [...prev, newSession]);

    // Update sessions completed count
    if (!isBreak) {
      setSessionsCompleted((prev) => prev + 1);
    }

    // Toggle between focus and break
    setIsBreak(!isBreak);
  }, [isBreak, focusMinutes, breakMinutes]);

  const handleStart = () => {
    setIsRunning(true);
  };

  const handlePause = () => {
    setIsRunning(false);
  };

  const handleReset = () => {
    setIsRunning(false);
    setMinutes(isBreak ? breakMinutes : focusMinutes);
    setSeconds(0);
  };

  const handleSettingsChange = (focus: number, breakTime: number) => {
    setFocusMinutes(focus);
    setBreakMinutes(breakTime);
    if (!isRunning) {
      setMinutes(isBreak ? breakTime : focus);
      setSeconds(0);
    }
  };

  // Calculate progress (0 to 1)
  const totalSeconds = (isBreak ? breakMinutes : focusMinutes) * 60;
  const remainingSeconds = minutes * 60 + seconds;
  const progress = 1 - remainingSeconds / totalSeconds;

  const commonProps = {
    minutes,
    seconds,
    isRunning,
    isBreak,
    onStart: handleStart,
    onPause: handlePause,
    onReset: handleReset,
    progress,
    sessionsCompleted,
    focusMinutes,
    breakMinutes,
    onSettingsChange: handleSettingsChange,
  };

  return (
    <div className="size-full">
      {layout === 'watch' && (
        <div 
          className="w-full h-full max-w-[250px] max-h-[250px] mx-auto rounded-[50px] overflow-hidden"
          style={{ 
            border: '4px solid #CBD5E0',
            backgroundColor: '#F8F7F4'
          }}
        >
          <WatchLayout {...commonProps} sessions={sessions} />
        </div>
      )}
      {layout === 'phone' && (
        <div 
          className="w-full h-full max-w-[430px] mx-auto"
          style={{ backgroundColor: '#F8F7F4' }}
        >
          <PhoneLayout {...commonProps} sessions={sessions} />
        </div>
      )}
      {layout === 'desktop' && <DesktopLayout {...commonProps} sessions={sessions} />}
    </div>
  );
}