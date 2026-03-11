'use strict';

// ─── Configuration ────────────────────────────────────────────────────────────
const MODES = {
  pomodoro:    { label: 'Focus Time',  seconds: 25 * 60, bodyClass: '' },
  'short-break': { label: 'Short Break', seconds:  5 * 60, bodyClass: 'mode-short-break' },
  'long-break':  { label: 'Long Break',  seconds: 15 * 60, bodyClass: 'mode-long-break'  },
};

const LONG_BREAK_INTERVAL = 4; // long break after every 4 pomodoros
const CIRCUMFERENCE = 2 * Math.PI * 100; // matches r="100" in SVG

// ─── State ────────────────────────────────────────────────────────────────────
let currentMode   = 'pomodoro';
let secondsLeft   = MODES.pomodoro.seconds;
let totalSeconds  = MODES.pomodoro.seconds;
let isRunning     = false;
let timerId       = null;
let completedSessions = 0;  // completed pomodoro rounds
let notifTimer    = null;

// ─── DOM Refs ─────────────────────────────────────────────────────────────────
const timerDisplay  = document.getElementById('timerDisplay');
const progressCircle = document.getElementById('progressCircle');
const startBtn      = document.getElementById('startBtn');
const startIcon     = document.getElementById('startIcon');
const pauseIcon     = document.getElementById('pauseIcon');
const resetBtn      = document.getElementById('resetBtn');
const skipBtn       = document.getElementById('skipBtn');
const modeButtons   = document.querySelectorAll('.mode-btn');
const sessionCount  = document.getElementById('sessionCount');
const modeLabel     = document.getElementById('modeLabel');
const pomodoroDots  = document.querySelectorAll('.dot');
const notification  = document.getElementById('notification');

// ─── Timer Logic ──────────────────────────────────────────────────────────────
function startTimer() {
  if (isRunning) return;
  isRunning = true;
  updateStartBtn();
  timerId = setInterval(tick, 1000);
}

function pauseTimer() {
  if (!isRunning) return;
  isRunning = false;
  clearInterval(timerId);
  timerId = null;
  updateStartBtn();
}

function resetTimer() {
  pauseTimer();
  secondsLeft  = totalSeconds;
  updateDisplay();
  updateProgress();
}

function tick() {
  if (secondsLeft <= 0) {
    handleSessionComplete();
    return;
  }
  secondsLeft--;
  updateDisplay();
  updateProgress();
}

function handleSessionComplete() {
  pauseTimer();
  playBeep();

  if (currentMode === 'pomodoro') {
    completedSessions++;
    updateDots();

    if (completedSessions % LONG_BREAK_INTERVAL === 0) {
      showNotification('Great work! Time for a long break 🎉');
      switchMode('long-break');
    } else {
      showNotification('Pomodoro complete! Take a short break ☕');
      switchMode('short-break');
    }
  } else {
    showNotification('Break over! Back to focus 💪');
    switchMode('pomodoro');
  }
}

// ─── Mode Switching ───────────────────────────────────────────────────────────
function switchMode(mode) {
  pauseTimer();
  currentMode   = mode;
  totalSeconds  = MODES[mode].seconds;
  secondsLeft   = totalSeconds;

  // update body class for theme colour
  document.body.className = MODES[mode].bodyClass;

  // update active button
  modeButtons.forEach(btn => {
    btn.classList.toggle('active', btn.dataset.mode === mode);
  });

  // update label
  modeLabel.textContent = MODES[mode].label;

  // session counter shown only for pomodoro
  sessionCount.textContent = currentMode === 'pomodoro'
    ? completedSessions + 1
    : completedSessions;

  updateDisplay();
  updateProgress();
  updateStartBtn();
}

// ─── Rendering ────────────────────────────────────────────────────────────────
function formatTime(secs) {
  const m = Math.floor(secs / 60).toString().padStart(2, '0');
  const s = (secs % 60).toString().padStart(2, '0');
  return `${m}:${s}`;
}

function updateDisplay() {
  timerDisplay.textContent = formatTime(secondsLeft);
  document.title = `${formatTime(secondsLeft)} — Pomodoro`;
}

function updateProgress() {
  const fraction = secondsLeft / totalSeconds;
  const offset   = CIRCUMFERENCE * (1 - fraction);
  progressCircle.style.strokeDashoffset = offset;
}

function updateStartBtn() {
  if (isRunning) {
    startIcon.style.display  = 'none';
    pauseIcon.style.display  = '';
    startBtn.setAttribute('aria-label', 'Pause timer');
  } else {
    startIcon.style.display  = '';
    pauseIcon.style.display  = 'none';
    startBtn.setAttribute('aria-label', 'Start timer');
  }
}

function updateDots() {
  const filled = completedSessions % LONG_BREAK_INTERVAL === 0
    ? LONG_BREAK_INTERVAL
    : completedSessions % LONG_BREAK_INTERVAL;
  pomodoroDots.forEach((dot, i) => {
    dot.classList.toggle('completed', i < filled);
  });
}

// ─── Notification Toast ───────────────────────────────────────────────────────
function showNotification(message) {
  clearTimeout(notifTimer);
  notification.textContent = message;
  notification.classList.add('show');
  notifTimer = setTimeout(() => notification.classList.remove('show'), 3000);
}

// ─── Audio Beep (Web Audio API) ───────────────────────────────────────────────
function playBeep() {
  try {
    const ctx = new (window.AudioContext || window.webkitAudioContext)();
    const osc = ctx.createOscillator();
    const gain = ctx.createGain();
    osc.connect(gain);
    gain.connect(ctx.destination);
    osc.type = 'sine';
    osc.frequency.setValueAtTime(880, ctx.currentTime);
    gain.gain.setValueAtTime(0.4, ctx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.8);
    osc.start(ctx.currentTime);
    osc.stop(ctx.currentTime + 0.8);
  } catch (_) {
    // Audio not available – silently ignore
  }
}

// ─── Event Listeners ──────────────────────────────────────────────────────────
startBtn.addEventListener('click', () => {
  isRunning ? pauseTimer() : startTimer();
});

resetBtn.addEventListener('click', resetTimer);

skipBtn.addEventListener('click', () => {
  handleSessionComplete();
});

modeButtons.forEach(btn => {
  btn.addEventListener('click', () => switchMode(btn.dataset.mode));
});

// Keyboard shortcut: Space to start/pause, R to reset
document.addEventListener('keydown', e => {
  if (e.target.tagName === 'BUTTON') return;
  if (e.code === 'Space') {
    e.preventDefault();
    isRunning ? pauseTimer() : startTimer();
  } else if (e.code === 'KeyR') {
    resetTimer();
  }
});

// ─── Initialise ───────────────────────────────────────────────────────────────
updateDisplay();
updateProgress();
updateStartBtn();
