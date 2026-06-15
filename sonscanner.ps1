# =========================================================================================
# CONFIGURATIEBLOK (Example)
# =========================================================================================
$AppName        = "Example"
$PageTitle      = "Example Screen Share"
$PageSubtitle   = "Example Premium Streaming Interface"
$Company        = "Example Inc."
$ContactInfo    = "contact@example.com"
$DefaultPort    = 8080

# =========================================================================================
# HTML / CSS / JAVASCRIPT FRONTEND GENERATIE
# =========================================================================================
$HtmlContent = @"
<!DOCTYPE html>
<html lang="nl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$PageTitle</title>
    <style>
        /* CSS RESET & VARIABLES */
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            user-select: none;
        }
        :root {
            --bg-base: #030712;
            --bg-deep: #020617;
            --glow-color: rgba(30, 64, 175, 0.4);
            --electric-blue: #3b82f6;
            --electric-glow: #1d4ed8;
            --text-main: #f3f4f6;
            --text-muted: #9ca3af;
            --glass-bg: rgba(15, 23, 42, 0.45);
            --glass-border: rgba(255, 255, 255, 0.08);
            --glass-border-active: rgba(59, 130, 246, 0.5);
            --accent-success: #10b981;
            --accent-error: #ef4444;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            background-color: var(--bg-base);
            color: var(--text-main);
            overflow-x: hidden;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            position: relative;
        }

        /* BACKGROUND EFFECTS */
        #canvas-bg {
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            z-index: 0;
            pointer-events: none;
        }
        .noise-overlay {
            position: fixed;
            top: 0; left: 0; width: 100vw; height: 100vh;
            background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noise'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.8' numOctaves='3' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noise)' opacity='0.015'/%3E%3C/svg%3E");
            pointer-events: none;
            z-index: 1;
        }
        .cursor-glow {
            position: fixed;
            width: 400px;
            height: 400px;
            background: radial-gradient(circle, rgba(59, 130, 246, 0.12) 0%, rgba(0,0,0,0) 70%);
            border-radius: 50%;
            pointer-events: none;
            transform: translate(-50%, -50%);
            z-index: 1;
            transition: opacity 0.3s ease;
        }

        /* LAYOUT HOOFDSTRUCTUUR */
        header, main, footer {
            position: relative;
            z-index: 2;
        }

        /* BOVENBALK */
        header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 1rem 2rem;
            background: var(--glass-bg);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            border-bottom: 1px solid var(--glass-border);
        }
        .brand {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            font-weight: 700;
            font-size: 1.2rem;
            letter-spacing: 0.5px;
        }
        .brand svg {
            width: 28px;
            height: 28px;
            fill: none;
            stroke: var(--electric-blue);
            stroke-width: 2;
        }
        .header-status {
            font-size: 0.85rem;
            color: var(--text-muted);
            background: rgba(255,255,255,0.04);
            padding: 0.4rem 1rem;
            border-radius: 20px;
            border: 1px solid var(--glass-border);
        }

        /* HERO INTRO */
        .intro-container {
            text-align: center;
            margin: 2rem auto 1rem auto;
            max-width: 600px;
            padding: 0 1rem;
        }
        .badge {
            display: inline-block;
            font-size: 0.75rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 1.5px;
            background: rgba(59, 130, 246, 0.15);
            color: var(--electric-blue);
            padding: 0.35rem 0.85rem;
            border-radius: 30px;
            margin-bottom: 0.75rem;
            border: 1px solid rgba(59, 130, 246, 0.3);
        }
        h1 {
            font-size: 2.2rem;
            font-weight: 800;
            margin-bottom: 0.5rem;
            background: linear-gradient(135deg, #ffffff 0%, #9ca3af 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        .subtitle {
            color: var(--text-muted);
            font-size: 0.95rem;
        }

        /* MAIN CONTENT & DASHBOARD */
        main {
            flex: 1;
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 1rem 2rem 3rem 2rem;
            max-width: 1200px;
            width: 100%;
            margin: 0 auto;
        }

        /* HOOFDPREVIEW PANEEL */
        .preview-container {
            width: 100%;
            aspect-ratio: 16 / 9;
            background: rgba(2, 6, 23, 0.6);
            border-radius: 24px;
            border: 1px solid var(--glass-border);
            position: relative;
            overflow: hidden;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5), 0 0 40px rgba(30, 64, 175, 0.1);
            transition: border-color 0.4s ease, box-shadow 0.4s ease;
        }
        .preview-container.active-stream {
            border-color: rgba(59, 130, 246, 0.4);
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.6), 0 0 50px rgba(59, 130, 246, 0.15);
        }
        .preview-container::before {
            content: '';
            position: absolute;
            inset: 0;
            background: radial-gradient(circle at 50% 50%, rgba(59, 130, 246, 0.04), transparent 70%);
            pointer-events: none;
        }

        video {
            width: 100%;
            height: 100%;
            object-fit: contain;
            display: none;
        }
        video.visible {
            display: block;
        }

        /* EMPTY STATE OVERLAY */
        .empty-state {
            position: absolute;
            inset: 0;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            text-align: center;
            padding: 2rem;
            transition: opacity 0.3s ease;
        }
        .empty-state.hidden {
            opacity: 0;
            pointer-events: none;
        }
        .empty-icon-wrapper {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            background: rgba(255,255,255,0.02);
            border: 1px solid var(--glass-border);
            display: flex;
            justify-content: center;
            align-items: center;
            margin-bottom: 1.5rem;
            position: relative;
        }
        .empty-icon-wrapper::after {
            content: '';
            position: absolute;
            inset: -4px;
            border-radius: 50%;
            border: 1px solid transparent;
            border-top-color: var(--electric-blue);
            animation: rotateHighlight 4s linear infinite;
        }
        @keyframes rotateHighlight {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        .empty-icon-wrapper svg {
            width: 36px;
            height: 36px;
            stroke: var(--electric-blue);
            fill: none;
            stroke-width: 1.5;
        }
        .empty-state h3 {
            font-size: 1.3rem;
            margin-bottom: 0.5rem;
            font-weight: 600;
        }
        .empty-state p {
            color: var(--text-muted);
            font-size: 0.9rem;
            max-width: 360px;
            margin-bottom: 1.5rem;
        }

        /* STREAM INDICATORS */
        .live-indicator {
            position: absolute;
            top: 1.5rem;
            left: 1.5rem;
            background: rgba(15, 23, 42, 0.75);
            padding: 0.4rem 0.8rem;
            border-radius: 8px;
            border: 1px solid var(--glass-border);
            font-size: 0.75rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            backdrop-filter: blur(8px);
            opacity: 0;
            transition: opacity 0.3s ease;
            z-index: 3;
        }
        .live-indicator.visible {
            opacity: 1;
        }
        .live-dot {
            width: 8px;
            height: 8px;
            background-color: var(--accent-success);
            border-radius: 50%;
            box-shadow: 0 0 8px var(--accent-success);
        }
        .live-indicator.pulse .live-dot {
            animation: pulseGlow 1.5s infinite ease-in-out;
        }
        @keyframes pulseGlow {
            0%, 100% { transform: scale(1); opacity: 1; }
            50% { transform: scale(1.3); opacity: 0.4; }
        }

        /* FLOATING CONTROL DOCK */
        .control-dock {
            margin-top: -2rem;
            background: rgba(15, 23, 42, 0.65);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border: 1px solid var(--glass-border);
            padding: 0.75rem;
            border-radius: 20px;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            box-shadow: 0 20px 40px -15px rgba(0,0,0,0.7);
            z-index: 10;
            transition: border-color 0.3s;
        }
        .control-dock:hover {
            border-color: rgba(255,255,255,0.12);
        }
        .btn {
            background: transparent;
            border: none;
            cursor: pointer;
            width: 44px;
            height: 44px;
            border-radius: 12px;
            display: flex;
            justify-content: center;
            align-items: center;
            color: var(--text-main);
            position: relative;
            transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
        }
        .btn svg {
            width: 20px;
            height: 20px;
            fill: none;
            stroke: currentColor;
            stroke-width: 2;
            transition: transform 0.2s;
        }
        .btn:hover:not(:disabled) {
            background: rgba(255,255,255,0.06);
            color: #ffffff;
        }
        .btn:hover:not(:disabled) svg {
            transform: scale(1.05);
        }
        .btn:active:not(:disabled) {
            transform: scale(0.95);
        }
        .btn:disabled {
            opacity: 0.3;
            cursor: not-allowed;
        }
        .btn-primary {
            background: var(--electric-blue);
            color: #ffffff;
            width: auto;
            padding: 0 1.25rem;
            gap: 0.5rem;
            font-weight: 600;
            font-size: 0.9rem;
        }
        .btn-primary:hover:not(:disabled) {
            background: #2563eb;
            box-shadow: 0 0 15px rgba(59, 130, 246, 0.4);
        }
        .btn-danger {
            background: rgba(239, 68, 110, 0.15);
            color: var(--accent-error);
            border: 1px solid rgba(239, 68, 110, 0.25);
        }
        .btn-danger:hover:not(:disabled) {
            background: var(--accent-error);
            color: white;
        }
        
        /* TOOLTIPS */
        .btn[data-tooltip]::after {
            content: attr(data-tooltip);
            position: absolute;
            bottom: 125%;
            left: 50%;
            transform: translateX(-50%) translateY(5px);
            background: #0f172a;
            border: 1px solid var(--glass-border);
            color: var(--text-main);
            padding: 0.4rem 0.7rem;
            font-size: 0.75rem;
            border-radius: 6px;
            white-space: nowrap;
            opacity: 0;
            pointer-events: none;
            transition: all 0.2s ease;
            box-shadow: 0 10px 15px -3px rgba(0,0,0,0.5);
        }
        .btn[data-tooltip]:hover::after {
            opacity: 1;
            transform: translateX(-50%) translateY(0);
        }

        /* STATUS METRICS DASHBOARD */
        .status-dashboard {
            width: 100%;
            margin-top: 2.5rem;
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
        }
        .status-card {
            background: var(--glass-bg);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            border: 1px solid var(--glass-border);
            padding: 1rem 1.25rem;
            border-radius: 16px;
            display: flex;
            flex-direction: column;
            gap: 0.35rem;
        }
        .status-card .label {
            font-size: 0.75rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: var(--text-muted);
        }
        .status-card .value {
            font-size: 1.1rem;
            font-weight: 600;
            color: var(--text-main);
        }

        /* MODAL DIALOG (SETTINGS) */
        .modal-overlay {
            position: fixed;
            inset: 0;
            background: rgba(2, 6, 23, 0.7);
            backdrop-filter: blur(8px);
            -webkit-backdrop-filter: blur(8px);
            z-index: 100;
            display: flex;
            justify-content: center;
            align-items: center;
            opacity: 0;
            pointer-events: none;
            transition: opacity 0.3s ease;
        }
        .modal-overlay.open {
            opacity: 1;
            pointer-events: auto;
        }
        .modal {
            background: #0f172a;
            border: 1px solid var(--glass-border);
            width: 90%;
            max-width: 450px;
            border-radius: 20px;
            overflow: hidden;
            box-shadow: 0 25px 50px -12px rgba(0,0,0,0.8);
            transform: scale(0.95);
            transition: transform 0.3s ease;
        }
        .modal-overlay.open .modal {
            transform: scale(1);
        }
        .modal-header {
            padding: 1.25rem 1.5rem;
            border-bottom: 1px solid var(--glass-border);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .modal-header h3 {
            font-weight: 600;
            font-size: 1.2rem;
        }
        .modal-body {
            padding: 1.5rem;
            display: flex;
            flex-direction: column;
            gap: 1.25rem;
        }
        .setting-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .setting-info {
            display: flex;
            flex-direction: column;
            gap: 0.15rem;
        }
        .setting-title {
            font-size: 0.95rem;
            font-weight: 500;
        }
        .setting-desc {
            font-size: 0.8rem;
            color: var(--text-muted);
        }
        
        /* TOGGLE SWITCH */
        .switch {
            position: relative;
            display: inline-block;
            width: 44px;
            height: 24px;
        }
        .switch input { opacity: 0; width: 0; height: 0; }
        .slider {
            position: absolute;
            cursor: pointer;
            inset: 0;
            background-color: rgba(255,255,255,0.1);
            transition: .3s;
            border-radius: 24px;
            border: 1px solid var(--glass-border);
        }
        .slider:before {
            position: absolute;
            content: "";
            height: 16px;
            width: 16px;
            left: 3px;
            bottom: 3px;
            background-color: white;
            transition: .3s;
            border-radius: 50%;
        }
        input:checked + .slider {
            background-color: var(--electric-blue);
        }
        input:checked + .slider:before {
            transform: translateX(20px);
        }

        /* TOAST NOTIFICATIONS */
        .toast-container {
            position: fixed;
            bottom: 2rem;
            right: 2rem;
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
            z-index: 200;
        }
        .toast {
            background: rgba(15, 23, 42, 0.9);
            border: 1px solid var(--glass-border);
            padding: 0.85rem 1.25rem;
            border-radius: 12px;
            font-size: 0.9rem;
            box-shadow: 0 10px 25px rgba(0,0,0,0.5);
            display: flex;
            align-items: center;
            gap: 0.75rem;
            transform: translateY(20px);
            opacity: 0;
            animation: toastIn 0.3s forwards cubic-bezier(0.4, 0, 0.2, 1);
            backdrop-filter: blur(10px);
        }
        @keyframes toastIn {
            to { transform: translateY(0); opacity: 1; }
        }
        .toast.error { border-left: 3px solid var(--accent-error); }
        .toast.success { border-left: 3px solid var(--accent-success); }

        /* FOOTER */
        footer {
            padding: 1.5rem;
            text-align: center;
            font-size: 0.8rem;
            color: var(--text-muted);
            border-top: 1px solid var(--glass-border);
            margin-top: auto;
            background: rgba(2,6,23,0.4);
        }

        /* ACCESSIBILITY: REDUCED MOTION */
        @media (prefers-reduced-motion: reduce) {
            *, ::before, ::after {
                animation-delay: -1ms !important;
                animation-duration: -1ms !important;
                animation-iteration-count: 1 !important;
                background-attachment: initial !important;
                scroll-behavior: auto !important;
                transition-duration: 0s !important;
                transition-delay: 0s !important;
            }
            #canvas-bg { display: none; }
        }

        /* RESPONSIVE LAYOUT BREAKPOINTS */
        @media (max-width: 900px) {
            h1 { font-size: 1.8rem; }
            .status-dashboard { grid-template-columns: repeat(2, 1fr); }
        }
        @media (max-width: 600px) {
            header { padding: 1rem; }
            main { padding: 1rem 1rem 2rem 1rem; }
            .control-dock { width: 100%; justify-content: center; flex-wrap: wrap; margin-top: -1rem; }
            .status-dashboard { grid-template-columns: 1fr; }
            .btn-primary span { display: none; }
            .btn-primary { padding: 0; width: 44px; }
        }
    </style>
</head>
<body>

    <canvas id="canvas-bg"></canvas>
    <div class="noise-overlay"></div>
    <div class="cursor-glow" id="js-cursor-glow"></div>

    <header>
        <div class="brand">
            <svg viewBox="0 0 24 24"><path d="M4 6a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6z"/><path d="M8 20h8"/><path d="M12 16v4"/></svg>
            <span>$AppName</span>
        </div>
        <div class="header-status" id="js-nav-status">System Node: Operational</div>
        <button class="btn" id="js-open-settings-nav" data-tooltip="Instellingen">
            <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>
        </button>
    </header>

    <div class="intro-container">
        <div class="badge">Enterprise Gateway</div>
        <h1>$PageTitle</h1>
        <div class="subtitle">$PageSubtitle</div>
    </div>

    <main>
        <div class="preview-container" id="js-preview-container">
            <div class="live-indicator" id="js-live-indicator">
                <div class="live-dot"></div>
                <span>LIVE FEED</span>
            </div>

            <video id="js-video-element" autoplay playsinline></video>

            <div class="empty-state" id="js-empty-state">
                <div class="empty-icon-wrapper">
                    <svg viewBox="0 0 24 24"><path d="M23 7a2 2 0 0 0-2.45-1.45L16 7V5a2 2 0 0 0-2-2H2a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-2l4.55 1.45A2 2 0 0 0 23 17V7z"/></svg>
                </div>
                <h3>Geen actieve stream</h3>
                <p>Start direct met het lokaal delen van uw volledige scherm, applicatievenster of browsertabblad.</p>
                <button class="btn btn-primary" id="js-start-empty-btn">
                    <svg viewBox="0 0 24 24"><polygon points="5 3 19 12 5 21 5 3"/></svg>
                    <span>Start Screen Share</span>
                </button>
            </div>
        </div>

        <div class="control-dock">
            <button class="btn btn-primary" id="js-btn-start" data-tooltip="Start Delen">
                <svg viewBox="0 0 24 24"><polygon points="5 3 19 12 5 21 5 3"/></svg>
                <span>Start</span>
            </button>
            <button class="btn btn-danger" id="js-btn-stop" data-tooltip="Stop Delen" disabled>
                <svg viewBox="0 0 24 24"><rect x="4" y="4" width="16" height="16" rx="2" ry="2"/></svg>
            </button>
            <div style="width: 1px; height: 24px; background: var(--glass-border); margin: 0 0.25rem;"></div>
            <button class="btn" id="js-btn-mute" data-tooltip="Mute Preview" disabled>
                <svg id="js-icon-mute" viewBox="0 0 24 24"><path d="M11 5L6 9H2v6h4l5 4V5z"/></svg>
            </button>
            <button class="btn" id="js-btn-fullscreen" data-tooltip="Volledig Scherm" disabled>
                <svg viewBox="0 0 24 24"><path d="M8 3H5a2 2 0 0 0-2 2v3m18 0V5a2 2 0 0 0-2-2h-3m0 18h3a2 2 0 0 0 2-2v-3M3 16v3a2 2 0 0 0 2 2h3"/></svg>
            </button>
            <button class="btn" id="js-btn-copy" data-tooltip="Kopieer Token">
                <svg viewBox="0 0 24 24"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
            </button>
            <button class="btn" id="js-btn-settings" data-tooltip="Instellingen">
                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>
            </button>
        </div>

        <div class="status-dashboard">
            <div class="status-card">
                <span class="label">Status</span>
                <span class="value" id="js-stat-status">Ready</span>
            </div>
            <div class="status-card">
                <span class="label">Resolutie</span>
                <span class="value" id="js-stat-resolution">Example</span>
            </div>
            <div class="status-card">
                <span class="label">Framerate</span>
                <span class="value" id="js-stat-fps">Example</span>
            </div>
            <div class="status-card">
                <span class="label">Audio status</span>
                <span class="value" id="js-stat-audio">Example</span>
            </div>
        </div>
    </main>

    <div class="modal-overlay" id="js-modal-overlay">
        <div class="modal">
            <div class="modal-header">
                <h3>Systeeminstellingen</h3>
                <button class="btn" id="js-close-settings" style="width:32px; height:32px;">&times;</button>
            </div>
            <div class="modal-body">
                <div class="setting-row">
                    <div class="setting-info">
                        <span class="setting-title">Achtergrondanimaties</span>
                        <span class="setting-desc">Activeer de vloeibare dynamische golven</span>
                    </div>
                    <label class="switch">
                        <input type="checkbox" id="js-toggle-animations" checked>
                        <span class="slider"></span>
                    </label>
                </div>
                <div class="setting-row">
                    <div class="setting-info">
                        <span class="setting-title">Cursor Glow</span>
                        <span class="setting-desc">Subtiele spotlight achter de muiscursor</span>
                    </div>
                    <label class="switch">
                        <input type="checkbox" id="js-toggle-glow" checked>
                        <span class="slider"></span>
                    </label>
                </div>
                <div class="setting-row">
                    <div class="setting-info">
                        <span class="setting-title">Achtergrond Particles</span>
                        <span class="setting-desc">Zwevende interactieve lichtdeeltjes</span>
                    </div>
                    <label class="switch">
                        <input type="checkbox" id="js-toggle-particles" checked>
                        <span class="slider"></span>
                    </label>
                </div>
                <div class="setting-row">
                    <div class="setting-info">
                        <span class="setting-title">Standaard Mute</span>
                        <span class="setting-desc">Demper de preview direct bij start</span>
                    </div>
                    <label class="switch">
                        <input type="checkbox" id="js-toggle-mute">
                        <span class="slider"></span>
                    </label>
                </div>
            </div>
        </div>
    </div>

    <div class="toast-container" id="js-toast-container"></div>

    <footer>
        &copy; 2026 $Company &bull; $AppName Hub &bull; Support: $ContactInfo
    </footer>

    <script>
        // GLOBAL STATE MANAGEMENT
        let localStream = null;
        let animationFrameId = null;
        const config = {
            animations: true,
            glow: true,
            particles: true,
            muteOnStart: false
        };

        // DOM REFERENCES
        const videoEl = document.getElementById('js-video-element');
        const emptyStateEl = document.getElementById('js-empty-state');
        const previewContainer = document.getElementById('js-preview-container');
        const liveIndicator = document.getElementById('js-live-indicator');
        const cursorGlow = document.getElementById('js-cursor-glow');
        const toastContainer = document.getElementById('js-toast-container');
        
        // BUTTONS
        const btnStart = document.getElementById('js-btn-start');
        const btnStartEmpty = document.getElementById('js-start-empty-btn');
        const btnStop = document.getElementById('js-btn-stop');
        const btnMute = document.getElementById('js-btn-mute');
        const btnFullscreen = document.getElementById('js-btn-fullscreen');
        const btnCopy = document.getElementById('js-btn-copy');
        const btnSettings = document.getElementById('js-btn-settings');
        const btnSettingsNav = document.getElementById('js-open-settings-nav');
        const btnCloseSettings = document.getElementById('js-close-settings');
        const modalOverlay = document.getElementById('js-modal-overlay');

        // STATS METRICS
        const statStatus = document.getElementById('js-stat-status');
        const statResolution = document.getElementById('js-stat-resolution');
        const statFps = document.getElementById('js-stat-fps');
        const statAudio = document.getElementById('js-stat-audio');

        // TOAST ENGINE
        function showToast(message, type = 'success') {
            const toast = document.createElement('div');
            toast.className = `toast \${type\}`;
            toast.innerText = message;
            toastContainer.appendChild(toast);
            setTimeout(() => {
                toast.style.animation = 'toastIn 0.3s reverse forwards';
                setTimeout(() => toast.remove(), 300);
            }, 400);
        }

        // LOAD AND SAVE LOCAL STORAGE CONFIG
        function loadSettings() {
            if(localStorage.getItem('example_config')) {
                const stored = JSON.parse(localStorage.getItem('example_config'));
                Object.assign(config, stored);
            }
            document.getElementById('js-toggle-animations').checked = config.animations;
            document.getElementById('js-toggle-glow').checked = config.glow;
            document.getElementById('js-toggle-particles').checked = config.particles;
            document.getElementById('js-toggle-mute').checked = config.muteOnStart;
            
            cursorGlow.style.display = config.glow ? 'block' : 'none';
        }

        function saveSettings() {
            config.animations = document.getElementById('js-toggle-animations').checked;
            config.glow = document.getElementById('js-toggle-glow').checked;
            config.particles = document.getElementById('js-toggle-particles').checked;
            config.muteOnStart = document.getElementById('js-toggle-mute').checked;
            localStorage.setItem('example_config', JSON.stringify(config));
            cursorGlow.style.display = config.glow ? 'block' : 'none';
        }

        // ACCESSIBILITY INTERACTION WATCHER
        const motionQuery = window.matchMedia('(prefers-reduced-motion: reduce)');
        function checkReducedMotion() {
            if (motionQuery.matches) {
                config.animations = false;
                config.particles = false;
                document.getElementById('js-toggle-animations').checked = false;
                document.getElementById('js-toggle-particles').checked = false;
            }
        }
        motionQuery.addEventListener('change', checkReducedMotion);

        // CURSOR MOUSE GLOW TRACKER
        window.addEventListener('mousemove', (e) => {
            if(!config.glow) return;
            cursorGlow.style.left = e.clientX + 'px';
            cursorGlow.style.top = e.clientY + 'px';
        });

        // MODAL TOGGLE ENGINE
        function toggleModal(open) {
            if(open) modalOverlay.classList.add('open');
            else {
                modalOverlay.classList.remove('open');
                saveSettings();
            }
        }
        btnSettings.addEventListener('click', () => toggleModal(true));
        btnSettingsNav.addEventListener('click', () => toggleModal(true));
        btnCloseSettings.addEventListener('click', () => toggleModal(false));
        modalOverlay.addEventListener('click', (e) => { if(e.target === modalOverlay) toggleModal(false); });
        window.addEventListener('keydown', (e) => { if(e.key === 'Escape') toggleModal(false); });

        // SCREENSHARE CORE BUSINESS LOGIC
        async function startScreenShare() {
            if (!navigator.mediaDevices || !navigator.mediaDevices.getDisplayMedia) {
                showToast("Screen Capture API wordt niet ondersteund in deze browser.", "error");
                statStatus.innerText = "Error";
                return;
            }

            statStatus.innerText = "Requesting";
            try {
                localStream = await navigator.mediaDevices.getDisplayMedia({
                    video: { displaySurface: "monitor" },
                    audio: true
                });

                videoEl.srcObject = localStream;
                videoEl.classList.add('visible');
                emptyStateEl.classList.add('hidden');
                previewContainer.classList.add('active-stream');
                liveIndicator.classList.add('visible', 'pulse');

                // Apply initial volume configurations
                videoEl.muted = config.muteOnStart;
                updateMuteIcon();

                // UI buttons states toggle
                btnStart.disabled = true;
                btnStartEmpty.disabled = true;
                btnStop.disabled = false;
                btnMute.disabled = false;
                btnFullscreen.disabled = false;

                // Track Metrics Evaluation
                const videoTrack = localStream.getVideoTracks()[0];
                const audioTrack = localStream.getAudioTracks()[0];

                statStatus.innerText = "Live";
                statAudio.innerText = audioTrack ? "Beschikbaar" : "Niet beschikbaar";
                
                if(videoTrack) {
                    const settings = videoTrack.getSettings();
                    statResolution.innerText = `\${settings.width || 'Example'\}x\${settings.height || 'Example'\}`;
                    statFps.innerText = settings.frameRate ? `\${Math.round(settings.frameRate)\} FPS` : "Example";
                    
                    // Bind ended event listener
                    videoTrack.addEventListener('ended', () => {
                        showToast("Stream beëindigd via browser control paneel.", "success");
                        stopScreenShare();
                    });
                }

                showToast("Screenshare succesvol gestart.");

            } catch (err) {
                console.error(err);
                stopScreenShare();
                statStatus.innerText = "Error";
                showToast("Toegang geweigerd of fout opgetreden.", "error");
            }
        }

        function stopScreenShare() {
            if (localStream) {
                localStream.getTracks().forEach(track => track.stop());
                localStream = null;
            }

            videoEl.srcObject = null;
            videoEl.classList.remove('visible');
            emptyStateEl.classList.remove('hidden');
            previewContainer.classList.remove('active-stream');
            liveIndicator.classList.remove('visible', 'pulse');

            btnStart.disabled = false;
            btnStartEmpty.disabled = false;
            btnStop.disabled = true;
            btnMute.disabled = true;
            btnFullscreen.disabled = true;

            statStatus.innerText = "Stopped";
            statResolution.innerText = "Example";
            statFps.innerText = "Example";
            statAudio.innerText = "Example";
        }

        function toggleMute() {
            if(!localStream) return;
            videoEl.muted = !videoEl.muted;
            updateMuteIcon();
            showToast(videoEl.muted ? "Preview gedempt" : "Preview audio actief");
        }

        function updateMuteIcon() {
            const muteIcon = document.getElementById('js-icon-mute');
            if(videoEl.muted) {
                muteIcon.innerHTML = `<path d="M11 5L6 9H2v6h4l5 4V5z"/><line x1="23" y1="9" x2="17" y2="15"/><line x1="17" y1="9" x2="23" y2="15"/>`;
            } else {
                muteIcon.innerHTML = `<path d="M11 5L6 9H2v6h4l5 4V5z"/><path d="M15.54 8.46a5 5 0 0 1 0 7.07"/>`;
            }
        }

        function triggerFullscreen() {
            if(!localStream) return;
            if (previewContainer.requestFullscreen) {
                previewContainer.requestFullscreen();
            } else if (previewContainer.webkitRequestFullscreen) {
                previewContainer.webkitRequestFullscreen();
            }
        }

        // EVENT BINDINGS
        btnStart.addEventListener('click', startScreenShare);
        btnStartEmpty.addEventListener('click', startScreenShare);
        btnStop.addEventListener('click', stopScreenShare);
        btnMute.addEventListener('click', toggleMute);
        btnFullscreen.addEventListener('click', triggerFullscreen);
        
        btnCopy.addEventListener('click', () => {
            navigator.clipboard.writeText("Example-Secure-Connection-Token-XYZ").then(() => {
                showToast("Example token gekopieerd naar klembord!");
            }).catch(() => {
                showToast("Kopiëren mislukt", "error");
            });
        });

        // =========================================================================================
        // HIGH PERFORMANCE CANVAS FLUID LIQUID ANIMATION SYSTEM
        // =========================================================================================
        const canvas = document.getElementById('canvas-bg');
        const ctx = canvas.getContext('2d');

        let width = canvas.width = window.innerWidth;
        let height = canvas.height = window.innerHeight;

        window.addEventListener('resize', () => {
            width = canvas.width = window.innerWidth;
            height = canvas.height = window.innerHeight;
        });

        const particles = [];
        const totalParticles = 40;

        class Particle {
            constructor() {
                this.reset();
            }
            reset() {
                this.x = Math.random() * width;
                this.y = Math.random() * height + height;
                this.size = Math.random() * 4 + 1;
                this.speedY = -(Math.random() * 0.4 + 0.1);
                this.speedX = Math.sin(Math.random() * 2) * 0.15;
                this.alpha = Math.random() * 0.5 + 0.1;
                this.blur = Math.random() * 4;
            }
            update() {
                this.y += this.speedY;
                this.x += this.speedX;
                if (this.y < -20) this.reset();
            }
            draw() {
                ctx.save();
                ctx.shadowBlur = this.blur;
                ctx.shadowColor = '#3b82f6';
                ctx.fillStyle = `rgba(59, 130, 246, \${this.alpha\})`;
                ctx.beginPath();
                ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
                ctx.fill();
                ctx.restore();
            }
        }

        for (let i = 0; i < totalParticles; i++) {
            particles.push(new Particle());
            // Randomly spread initialization vertical coordinate
            particles[i].y = Math.random() * height;
        }

        let waveTick = 0;
        function renderLoop() {
            ctx.fillStyle = 'rgba(2, 6, 23, 1)';
            ctx.fillRect(0, 0, width, height);

            if (config.animations) {
                waveTick += 0.002;
                
                // Render Abstract Silk Energy Flow Base Layer
                const grad = ctx.createRadialGradient(width/2, height*1.3, 10, width/2, height/2, Math.max(width, height));
                grad.addColorStop(0, 'rgba(29, 78, 216, 0.15)');
                grad.addColorStop(0.5, 'rgba(30, 58, 138, 0.05)');
                grad.addColorStop(1, 'rgba(0, 0, 0, 0)');
                ctx.fillStyle = grad;
                ctx.fillRect(0, 0, width, height);

                // Render dynamic mathematical vector wave line
                ctx.strokeStyle = 'rgba(59, 130, 246, 0.08)';
                ctx.lineWidth = 2;
                ctx.beginPath();
                for (let x = 0; x < width; x += 10) {
                    const y = height * 0.8 + Math.sin(x * 0.003 + waveTick) * 40 + Math.cos(x * 0.001 + waveTick * 2) * 20;
                    if (x === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
                }
                ctx.stroke();
            }

            if (config.particles) {
                particles.forEach(p => {
                    p.update();
                    p.draw();
                });
            }

            animationFrameId = requestAnimationFrame(renderLoop);
        }

        // INITIALIZATION
        document.addEventListener('DOMContentLoaded', () => {
            loadSettings();
            checkReducedMotion();
            renderLoop();
        });

        // Visibility lifecycle monitor for execution preservation
        document.addEventListener('visibilitychange', () => {
            if (document.hidden) {
                cancelAnimationFrame(animationFrameId);
            } else {
                renderLoop();
            }
        });
    </script>
</body>
</html>
"@

# =========================================================================================
# SYSTEM PORT AUTOMATIC RESOLUTION DISCOVERY ENGINE
# =========================================================================================
$ServerPort = $DefaultPort
$PortFound = $false

while (-not $PortFound) {
    $ListenerCheck = New-Object System.Net.Sockets.TcpListener([System.Net.IPAddress]::Loopback, $ServerPort)
    try {
        $ListenerCheck.Start()
        $ListenerCheck.Stop()
        $PortFound = $true
    } catch {
        $ServerPort++
    }
}

$ListenUrl = "http://localhost:$ServerPort/"

# =========================================================================================
# HTTP SERVER SYSTEM CORE PROCESS
# =========================================================================================
$HttpListener = New-Object System.Net.HttpListener
$HttpListener.Prefixes.Add($ListenUrl)

Clear-Host
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "             $AppName ENTERPRISE SHELL CORE          " -ForegroundColor White -BackgroundColor Blue
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "Local network server initialization initialized..." -ForegroundColor Gray
Write-Host "Server Listening Hub: " -NoNewline -ForegroundColor Gray
Write-Host $ListenUrl -ForegroundColor Green
Write-Host "System Runtime Status: OPERATIONAL" -ForegroundColor Cyan
Write-Host "Press [Ctrl + C] to terminate processing execution loop safely." -ForegroundColor Yellow
Write-Host "----------------------------------------------------" -ForegroundColor Gray

try {
    $HttpListener.Start()
    
    # Auto launch default workstation browser session thread asynchronously
    Start-Process $ListenUrl

    # Infinite request loop orchestration
    while ($HttpListener.IsListening) {
        $ContextAsyncResult = $HttpListener.BeginGetContext($null, $null)
        
        # CPU resource preservation backoff monitoring loop
        while (-not $ContextAsyncResult.IsCompleted) {
            Start-Sleep -Milliseconds 100
        }
        
        try {
            $Context = $HttpListener.EndGetContext($ContextAsyncResult)
            $Request = $Context.Request
            $Response = $Context.Response

            $Path = $Request.Url.AbsolutePath
            
            # Application routing strategy switches
            if ($Path -eq "/" -or $Path -eq "/index.html") {
                $Buffer = [System.Text.Encoding]::UTF8.GetBytes($HtmlContent)
                $Response.ContentType = "text/html; charset=utf-8"
                $Response.ContentLength64 = $Buffer.Length
                $Response.OutputStream.Write($Buffer, 0, $Buffer.Length)
            } 
            elseif ($Path -eq "/health") {
                $HealthBuffer = [System.Text.Encoding]::UTF8.GetBytes("OK")
                $Response.ContentType = "text/plain; charset=utf-8"
                $Response.ContentLength64 = $HealthBuffer.Length
                $Response.OutputStream.Write($HealthBuffer, 0, $HealthBuffer.Length)
            } 
            else {
                $Response.StatusCode = 404
                $NotFoundBuffer = [System.Text.Encoding]::UTF8.GetBytes("404 Resource Not Found - Example Application Context Error")
                $Response.ContentLength64 = $NotFoundBuffer.Length
                $Response.OutputStream.Write($NotFoundBuffer, 0, $NotFoundBuffer.Length)
            }
            
            $Response.OutputStream.Close()
        } catch {
            # Catch and pass asynchronous networking execution faults gracefully
        }
    }
} catch [System.Exception] {
    Write-Host "[ERROR] System execution encountered exception: $_" -ForegroundColor Red
} finally {
    # Perform total system stack garbage collection cleanup
    if ($HttpListener -ne $null) {
        if ($HttpListener.IsListening) {
            $HttpListener.Stop()
        }
        $HttpListener.Close()
    }
    Write-Host "`n[INFO] Microserver engine listener terminated completely. Socket resources cleared." -ForegroundColor Yellow
    Write-Host "====================================================" -ForegroundColor Cyan
}
