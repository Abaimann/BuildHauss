# -*- coding: utf-8 -*-
import os

with open('scripts/views_code.js', 'r', encoding='utf-8') as f:
    views_code = f.read()

html_content = '''<!doctype html>
<html lang="id">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover" />
    <title>BuildHaus — Unduh APK Asisten Perawatan Motor Pintar & AI Riding Buddy</title>
    <meta name="description" content="Aplikasi asisten perawatan motor cerdas pertama di Indonesia. Pantau 14 komponen kritis deterministik, konsultasi keluhan dengan Google Gemini 2.5 Flash, dan estimasi biaya servis transparan. Download APK resmi Android." />
    
    <!-- Open Graph & Meta -->
    <meta property="og:title" content="BuildHaus — Asisten Pintar Perawatan Motor Pribadi" />
    <meta property="og:description" content="Kalkulator kesehatan motor deterministik, estimasi budget transparan, dan AI Riding Buddy dengan Google Gemini 2.5 Flash. Unduh APK Android." />
    <meta property="og:type" content="website" />
    <meta name="theme-color" content="#090d14" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent" />

    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&family=JetBrains+Mono:wght@400;500;700&display=swap" rel="stylesheet" />

    <style>
      :root {
        --bg: #090d14;
        --bg-alt: #0d131c;
        --surface: #0f1722;
        --surface2: #151f2e;
        --surface3: #1b283c;
        --ink: #f1f5f9;
        --ink2: #cbd5e1;
        --muted: #94a3b8;
        --line: #223249;
        --line-accent: rgba(0, 245, 160, 0.28);
        --accent: #00f5a0;
        --accent-hover: #10ffac;
        --accent-glow: rgba(0, 245, 160, 0.35);
        --accent-gradient: linear-gradient(135deg, #131d2b 0%, #090d14 100%);
        --gemini: #8b5cf6;
        --gemini-glow: rgba(139, 92, 246, 0.25);
        --warn: #f59e0b;
        --danger: #ef4444;
        --r-pill: 999px;
        --r-card: 22px;
        --max-w: 1200px;
      }

      *, *::before, *::after {
        box-sizing: border-box;
        margin: 0;
        padding: 0;
      }
      
      html {
        scroll-behavior: smooth;
        width: 100%;
        max-width: 100%;
        overflow-x: hidden;
      }

      body {
        background-color: var(--bg);
        color: var(--ink);
        font-family: 'Plus Jakarta Sans', system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        font-size: 15px;
        line-height: 1.6;
        -webkit-font-smoothing: antialiased;
        overflow-x: hidden;
        width: 100%;
        max-width: 100%;
        position: relative;
      }

      /* Background Ambient Glows */
      .glow-bg {
        position: fixed;
        top: 0; left: 0; right: 0; height: 100vh;
        pointer-events: none;
        z-index: 0;
        background:
          radial-gradient(circle at 15% 15%, rgba(0, 245, 160, 0.08) 0%, transparent 40%),
          radial-gradient(circle at 85% 30%, rgba(139, 92, 246, 0.07) 0%, transparent 45%),
          radial-gradient(circle at 50% 80%, rgba(0, 245, 160, 0.05) 0%, transparent 50%);
      }

      /* Container */
      .wrap {
        max-width: var(--max-w);
        margin: 0 auto;
        padding: 0 24px;
        position: relative;
        z-index: 1;
      }

      /* ===== NAVBAR ===== */
      .navbar-wrap {
        position: sticky;
        top: 14px;
        z-index: 100;
        margin-bottom: 24px;
      }
      .navbar {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 12px 22px;
        background: rgba(15, 23, 34, 0.88);
        backdrop-filter: blur(20px);
        -webkit-backdrop-filter: blur(20px);
        border: 1px solid var(--line);
        border-radius: var(--r-pill);
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
      }
      .brand {
        display: flex;
        align-items: center;
        gap: 12px;
        text-decoration: none;
        color: var(--ink);
      }
      .brand-icon {
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
      }
      .brand-name {
        font-size: 18px;
        font-weight: 800;
        letter-spacing: -0.5px;
        background: linear-gradient(135deg, #ffffff 40%, #cbd5e1 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
      }
      .brand-ver {
        font-size: 11px;
        font-weight: 700;
        color: var(--accent);
        background: rgba(0, 245, 160, 0.12);
        border: 1px solid rgba(0, 245, 160, 0.25);
        padding: 2px 8px;
        border-radius: var(--r-pill);
        margin-left: 6px;
      }

      .nav-links {
        display: flex;
        align-items: center;
        gap: 24px;
        list-style: none;
      }
      .nav-links a {
        color: var(--muted);
        text-decoration: none;
        font-size: 13.5px;
        font-weight: 600;
        transition: color 0.15s;
      }
      .nav-links a:hover { color: var(--accent); }

      .btn-nav-download {
        background: var(--accent);
        color: #09120b;
        text-decoration: none;
        padding: 9px 18px;
        border-radius: var(--r-pill);
        font-size: 13px;
        font-weight: 800;
        display: inline-flex;
        align-items: center;
        gap: 8px;
        transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
        box-shadow: 0 4px 16px var(--accent-glow);
        white-space: nowrap;
        flex-shrink: 0;
      }
      .btn-nav-download:hover {
        background: var(--accent-hover);
        transform: translateY(-1px);
        box-shadow: 0 6px 20px rgba(0, 245, 160, 0.45);
      }

      /* ===== HERO SECTION ===== */
      .hero {
        padding: 48px 0 64px;
        text-align: center;
      }
      .hero-badge {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        background: rgba(0, 245, 160, 0.12);
        border: 1px solid rgba(0, 245, 160, 0.3);
        padding: 7px 18px;
        border-radius: var(--r-pill);
        font-size: 12.5px;
        font-weight: 700;
        color: var(--accent);
        margin-bottom: 24px;
        animation: pulseBadge 3s infinite;
        max-width: 100%;
        line-height: 1.4;
      }
      @keyframes pulseBadge {
        0%, 100% { border-color: rgba(0, 245, 160, 0.3); box-shadow: 0 0 0 rgba(0, 245, 160, 0); }
        50% { border-color: rgba(0, 245, 160, 0.6); box-shadow: 0 0 16px rgba(0, 245, 160, 0.2); }
      }
      .hero-title {
        font-size: clamp(28px, 5.2vw, 58px);
        font-weight: 800;
        letter-spacing: -1.2px;
        line-height: 1.18;
        margin-bottom: 20px;
        word-break: break-word;
      }
      .hero-title .highlight {
        color: var(--accent);
        text-shadow: 0 0 30px rgba(0, 245, 160, 0.3);
      }
      .hero-title .ai-highlight {
        background: linear-gradient(135deg, #a78bfa 0%, #c084fc 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        text-shadow: 0 0 30px rgba(167, 139, 250, 0.3);
      }
      .hero-subtitle {
        max-width: 760px;
        margin: 0 auto 36px;
        font-size: 15.5px;
        color: var(--muted);
        line-height: 1.65;
      }

      .hero-cta-group {
        display: flex;
        align-items: center;
        justify-content: center;
        flex-wrap: wrap;
        gap: 16px;
        margin-bottom: 44px;
      }
      .btn-primary {
        background: var(--accent);
        color: #09120b;
        text-decoration: none;
        padding: 16px 32px;
        border-radius: var(--r-pill);
        font-size: 15px;
        font-weight: 800;
        display: inline-flex;
        align-items: center;
        gap: 10px;
        transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
        box-shadow: 0 8px 28px var(--accent-glow);
        text-align: center;
      }
      .btn-primary:hover {
        background: var(--accent-hover);
        transform: translateY(-2px);
        box-shadow: 0 12px 34px rgba(0, 245, 160, 0.45);
      }
      .btn-secondary {
        background: var(--surface2);
        color: var(--ink);
        text-decoration: none;
        padding: 16px 28px;
        border-radius: var(--r-pill);
        font-size: 15px;
        font-weight: 700;
        display: inline-flex;
        align-items: center;
        gap: 10px;
        border: 1px solid var(--line);
        transition: all 0.2s;
        text-align: center;
      }
      .btn-secondary:hover {
        background: var(--surface3);
        border-color: var(--accent);
        transform: translateY(-1px);
      }

      /* Hero Specs Row */
      .hero-specs-row {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 16px;
        padding: 20px 24px;
        background: var(--surface);
        border: 1px solid var(--line);
        border-radius: 20px;
        max-width: 960px;
        margin: 0 auto;
        box-shadow: 0 12px 32px rgba(0, 0, 0, 0.4);
      }
      .spec-item {
        display: flex;
        align-items: center;
        gap: 12px;
        text-align: left;
      }
      .spec-icon {
        width: 38px; height: 38px;
        border-radius: 10px;
        background: var(--surface2);
        border: 1px solid var(--line);
        display: grid; place-items: center;
        font-size: 18px;
        flex-shrink: 0;
      }
      .spec-item b { display: block; font-size: 13.5px; font-weight: 700; color: var(--ink); line-height: 1.3; }
      .spec-item span { font-size: 11.5px; color: var(--muted); line-height: 1.3; }

      /* ===== SECTION COMMON ===== */
      .section {
        padding: 60px 0;
      }
      .section-center {
        text-align: center;
        max-width: 700px;
        margin: 0 auto 36px;
      }
      .section-badge {
        display: inline-block;
        font-size: 11px;
        font-weight: 800;
        text-transform: uppercase;
        letter-spacing: 1.2px;
        color: var(--accent);
        background: rgba(0, 245, 160, 0.1);
        border: 1px solid rgba(0, 245, 160, 0.25);
        padding: 5px 14px;
        border-radius: var(--r-pill);
        margin-bottom: 14px;
      }
      .section-title {
        font-size: clamp(24px, 4vw, 36px);
        font-weight: 800;
        letter-spacing: -0.8px;
        line-height: 1.25;
        margin-bottom: 14px;
      }
      .section-desc {
        font-size: 14.5px;
        color: var(--muted);
        line-height: 1.6;
      }

      /* ===== INTERACTIVE DEMO STAGE ===== */
      .demo-stage {
        display: grid;
        grid-template-columns: 1fr 360px 1fr;
        gap: 28px;
        align-items: center;
        background: var(--surface);
        border: 1px solid var(--line);
        border-radius: 32px;
        padding: 36px 28px;
        margin-top: 36px;
        box-shadow: 0 30px 80px rgba(0, 0, 0, 0.6);
      }
      .demo-col-left, .demo-col-right {
        display: flex;
        flex-direction: column;
        gap: 14px;
      }
      .demo-feature-card {
        background: var(--surface2);
        border: 1px solid var(--line);
        border-radius: 16px;
        padding: 16px 18px;
        cursor: pointer;
        transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
        user-select: none;
      }
      .demo-feature-card.active, .demo-feature-card:hover {
        border-color: var(--accent);
        background: var(--surface3);
        transform: translateY(-2px);
        box-shadow: 0 8px 24px rgba(0, 0, 0, 0.35);
      }
      .demo-feature-card h4 {
        display: flex;
        align-items: center;
        gap: 10px;
        font-size: 13.5px;
        font-weight: 700;
        margin-bottom: 5px;
        color: var(--ink);
      }
      .demo-feature-card p {
        font-size: 12px;
        color: var(--muted);
        line-height: 1.5;
      }

      /* Mobile Horizontal Demo Chips (visible on mobile only) */
      .demo-mobile-chips {
        display: none;
        overflow-x: auto;
        gap: 8px;
        padding-bottom: 12px;
        margin-bottom: 18px;
        scrollbar-width: none;
        -webkit-overflow-scrolling: touch;
      }
      .demo-mobile-chips::-webkit-scrollbar { display: none; }
      .demo-chip {
        flex-shrink: 0;
        background: var(--surface2);
        border: 1px solid var(--line);
        color: var(--ink2);
        padding: 7px 14px;
        border-radius: var(--r-pill);
        font-size: 12px;
        font-weight: 700;
        cursor: pointer;
        display: inline-flex;
        align-items: center;
        gap: 6px;
        transition: all 0.2s;
      }
      .demo-chip.active {
        background: rgba(0, 245, 160, 0.15);
        border-color: var(--accent);
        color: var(--accent);
        box-shadow: 0 0 12px rgba(0, 245, 160, 0.2);
      }

      /* Active feature card info box (for mobile) */
      .demo-active-info {
        display: none;
        background: var(--surface2);
        border: 1px solid var(--line-accent);
        border-radius: 16px;
        padding: 14px 16px;
        margin-top: 16px;
        text-align: left;
      }
      .demo-active-info b { display: block; font-size: 13.5px; color: var(--accent); margin-bottom: 4px; }
      .demo-active-info p { font-size: 12px; color: var(--muted); line-height: 1.5; margin: 0; }

      /* ===== SMARTPHONE CONTAINER ===== */
      .phone {
        width: 360px;
        height: 680px;
        max-width: 100%;
        background: #060907;
        border: 2px solid #243126;
        border-radius: 44px;
        padding: 10px;
        box-shadow: 0 30px 80px rgba(0, 0, 0, 0.8), 0 0 0 1px rgba(0, 245, 160, 0.25);
        position: relative;
        margin: 0 auto;
        box-sizing: border-box;
      }
      .screen {
        height: 100%;
        border-radius: 36px;
        background: var(--bg);
        position: relative;
        overflow: hidden;
        display: flex;
        flex-direction: column;
      }
      .dynamic-island {
        position: absolute; z-index: 20; top: 9px; left: 50%;
        transform: translateX(-50%);
        width: 88px; height: 20px;
        background: #060907; border-radius: var(--r-pill);
      }
      .status-bar {
        position: absolute; top: 11px; left: 20px; right: 20px;
        font-size: 10px; font-weight: 600;
        display: flex; justify-content: space-between; align-items: center;
        z-index: 19; color: var(--ink);
      }
      .screen-content {
        flex: 1;
        overflow-y: auto;
        padding: 44px 14px 68px;
        scrollbar-width: none;
      }
      .screen-content::-webkit-scrollbar { display: none; }

      /* Mockup Components inside Phone */
      .m-bike-card {
        background: linear-gradient(135deg, #131d2b 0%, #090d14 100%);
        border: 1.2px solid rgba(0, 245, 160, 0.4);
        border-radius: 18px;
        padding: 14px;
        margin-bottom: 12px;
        color: #fff;
        box-shadow: 0 10px 24px rgba(0, 0, 0, 0.5);
      }
      .m-badge {
        font-size: 9px; font-weight: 800; text-transform: uppercase;
        background: rgba(0, 245, 160, 0.16);
        color: #00f5a0; padding: 2px 7px; border-radius: 99px;
        border: 1px solid rgba(0, 245, 160, 0.3);
        display: inline-flex; align-items: center; gap: 4px;
      }
      .m-score-card {
        background: var(--surface2);
        border: 1px solid rgba(0, 245, 160, 0.25);
        border-radius: 16px;
        padding: 12px;
        margin-bottom: 12px;
        display: flex;
        align-items: center;
        gap: 12px;
        box-shadow: 0 4px 14px rgba(0,0,0,0.3);
      }
      .m-score-box {
        width: 44px; height: 44px; border-radius: 12px;
        background: rgba(0, 245, 160, 0.15); color: var(--accent);
        border: 1px solid rgba(0, 245, 160, 0.3);
        display: grid; place-items: center; font-size: 18px; font-weight: 900;
        flex-shrink: 0;
      }
      .m-comp-tile {
        background: var(--surface2);
        border: 1px solid var(--line);
        border-radius: 12px;
        padding: 10px 12px;
        margin-bottom: 8px;
        display: flex;
        align-items: center;
        justify-content: space-between;
      }
      .m-chat-bubble {
        padding: 11px 13px;
        border-radius: 14px;
        font-size: 11.5px;
        margin-bottom: 10px;
        line-height: 1.45;
      }
      .m-chat-user {
        background: var(--surface2);
        border: 1px solid var(--line);
        color: var(--ink);
        border-bottom-right-radius: 4px;
      }
      .m-chat-ai {
        background: var(--surface3);
        border: 1px solid rgba(0, 245, 160, 0.3);
        color: var(--ink);
        border-bottom-left-radius: 4px;
      }
      .m-nav-bar {
        position: absolute; bottom: 0; left: 0; right: 0;
        height: 56px;
        background: rgba(12, 17, 24, 0.95);
        border-top: 1px solid var(--line);
        display: flex;
        justify-content: space-around;
        align-items: center;
        z-index: 20;
      }
      .m-nav-item {
        color: var(--muted);
        font-size: 9.5px;
        font-weight: 600;
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 2px;
        cursor: pointer;
      }
      .m-nav-item.active { color: var(--accent); }

      /* ===== GRID FEATURES ===== */
      .features-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
        gap: 20px;
        margin-top: 36px;
      }
      .feature-box {
        background: var(--surface);
        border: 1px solid var(--line);
        border-radius: var(--r-card);
        padding: 28px 24px;
        transition: all 0.25s cubic-bezier(0.16, 1, 0.3, 1);
        position: relative;
        overflow: hidden;
      }
      .feature-box:hover {
        border-color: var(--line-accent);
        transform: translateY(-3px);
        box-shadow: 0 16px 40px rgba(0, 0, 0, 0.4);
      }
      .feature-box-icon {
        width: 48px; height: 48px;
        border-radius: 12px;
        background: var(--surface2);
        border: 1px solid var(--line);
        display: grid; place-items: center;
        font-size: 22px;
        margin-bottom: 18px;
      }
      .feature-box h3 { font-size: 17px; font-weight: 800; margin-bottom: 8px; color: var(--ink); }
      .feature-box p { font-size: 13.5px; color: var(--muted); line-height: 1.6; }
      .feature-box .badge-feature {
        margin-top: 14px;
        display: inline-block;
        font-size: 11px;
        font-weight: 700;
        color: var(--accent);
      }

      /* ===== DOWNLOAD APK SECTION ===== */
      .download-card {
        background: linear-gradient(135deg, rgba(19, 29, 43, 0.95) 0%, rgba(9, 13, 20, 0.98) 100%);
        border: 1px solid rgba(0, 245, 160, 0.35);
        border-radius: 32px;
        padding: 48px 40px;
        margin-top: 36px;
        box-shadow: 0 30px 80px rgba(0, 0, 0, 0.6), 0 0 60px rgba(0, 245, 160, 0.1);
        display: grid;
        grid-template-columns: 1.3fr 0.7fr;
        gap: 40px;
        align-items: center;
      }
      .download-left h2 { font-size: clamp(24px, 3.5vw, 36px); font-weight: 800; letter-spacing: -1px; margin-bottom: 12px; line-height: 1.25; }
      .download-left p { font-size: 14.5px; color: var(--muted); line-height: 1.65; margin-bottom: 24px; }
      
      .download-actions-group {
        display: flex;
        flex-direction: column;
        gap: 12px;
        margin-bottom: 24px;
      }
      .dl-main-btn {
        background: var(--accent);
        color: #09120b;
        text-decoration: none;
        padding: 16px 28px;
        border-radius: var(--r-pill);
        font-size: 15px;
        font-weight: 800;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 10px;
        transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
        box-shadow: 0 8px 30px var(--accent-glow);
        text-align: center;
      }
      .dl-main-btn:hover {
        background: var(--accent-hover);
        transform: translateY(-2px);
        box-shadow: 0 12px 36px rgba(0, 245, 160, 0.5);
      }
      .dl-secondary-row {
        display: flex;
        gap: 10px;
        flex-wrap: wrap;
      }
      .dl-mirror-btn {
        flex: 1;
        min-width: 180px;
        background: var(--surface2);
        color: var(--ink);
        text-decoration: none;
        padding: 12px 18px;
        border-radius: var(--r-pill);
        font-size: 13px;
        font-weight: 700;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        border: 1px solid var(--line);
        transition: all 0.2s;
        text-align: center;
      }
      .dl-mirror-btn:hover {
        background: var(--surface3);
        border-color: var(--accent);
      }

      .apk-specs {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 10px;
        background: var(--surface2);
        border: 1px solid var(--line);
        padding: 16px 18px;
        border-radius: 16px;
        font-size: 12.5px;
      }
      .apk-spec-row b { color: var(--ink); font-weight: 700; }
      .apk-spec-row span { color: var(--muted); }
      
      .download-right {
        background: var(--surface2);
        border: 1px solid var(--line);
        border-radius: 24px;
        padding: 24px;
        text-align: center;
      }
      .qr-box {
        width: 170px; height: 170px;
        background: #ffffff;
        border-radius: 16px;
        margin: 0 auto 14px;
        display: grid; place-items: center;
        padding: 10px;
        box-shadow: 0 10px 30px rgba(0,0,0,0.4);
      }
      .qr-box img { width: 100%; height: 100%; border-radius: 6px; }
      .download-right small { display: block; color: var(--muted); font-size: 11.5px; line-height: 1.5; }

      /* Collapsible mobile QR wrapper */
      .mobile-qr-toggle {
        display: none;
        margin-top: 16px;
        background: var(--surface2);
        border: 1px solid var(--line);
        border-radius: 14px;
        padding: 12px 16px;
        text-align: center;
      }
      .mobile-qr-toggle summary {
        font-size: 13px;
        font-weight: 700;
        color: var(--ink2);
        cursor: pointer;
        outline: none;
      }
      .mobile-qr-toggle[open] .qr-box {
        margin-top: 14px;
      }

      /* Steps Guide */
      .steps-grid {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 16px;
        margin-top: 32px;
      }
      .step-card {
        background: var(--surface);
        border: 1px solid var(--line);
        border-radius: 16px;
        padding: 20px;
        position: relative;
      }
      .step-num {
        width: 28px; height: 28px;
        border-radius: 50%;
        background: var(--accent);
        color: #0c140e;
        display: grid; place-items: center;
        font-size: 13px; font-weight: 800;
        margin-bottom: 12px;
      }
      .step-card b { font-size: 14px; font-weight: 700; display: block; margin-bottom: 6px; }
      .step-card p { font-size: 12.5px; color: var(--muted); line-height: 1.5; }

      /* ===== REALME & ANDROID DEDICATED GUIDE BOX ===== */
      .realme-guide-box {
        background: linear-gradient(135deg, rgba(21, 31, 46, 0.95) 0%, rgba(15, 23, 34, 0.95) 100%);
        border: 1.2px solid rgba(0, 245, 160, 0.35);
        border-radius: 24px;
        padding: 28px 24px;
        margin-top: 28px;
        box-shadow: 0 20px 50px rgba(0, 0, 0, 0.45);
      }
      .realme-guide-header {
        display: flex;
        align-items: center;
        gap: 12px;
        margin-bottom: 20px;
      }
      .realme-guide-icon {
        width: 42px; height: 42px;
        border-radius: 12px;
        background: rgba(0, 245, 160, 0.15);
        border: 1px solid rgba(0, 245, 160, 0.3);
        display: grid; place-items: center;
        font-size: 20px;
        color: var(--accent);
        flex-shrink: 0;
      }
      .realme-guide-header h3 {
        font-size: 18px;
        font-weight: 800;
        letter-spacing: -0.4px;
        color: var(--ink);
      }
      .realme-guide-header p {
        font-size: 12.5px;
        color: var(--muted);
        margin: 0;
      }
      .realme-steps-grid {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 14px;
      }
      .realme-step-item {
        background: var(--surface);
        border: 1px solid var(--line);
        border-radius: 14px;
        padding: 16px;
      }
      .realme-badge-step {
        font-size: 10px;
        font-weight: 800;
        text-transform: uppercase;
        color: var(--accent);
        background: rgba(0, 245, 160, 0.12);
        padding: 2px 7px;
        border-radius: 6px;
        display: inline-block;
        margin-bottom: 8px;
      }
      .realme-step-item b {
        display: block;
        font-size: 13px;
        font-weight: 700;
        color: var(--ink);
        margin-bottom: 5px;
        line-height: 1.35;
      }
      .realme-step-item p {
        font-size: 11.5px;
        color: var(--muted);
        line-height: 1.5;
        margin: 0;
      }
      .realme-safe-pill {
        display: flex;
        align-items: center;
        gap: 10px;
        margin-top: 18px;
        padding: 12px 16px;
        border-radius: 12px;
        background: rgba(0, 245, 160, 0.08);
        border: 1px solid rgba(0, 245, 160, 0.2);
        font-size: 12px;
        color: var(--ink2);
      }
      .realme-safe-pill span { color: var(--accent); font-weight: 700; }

      /* ===== COMPARISON TABLE ===== */
      .table-wrap {
        margin-top: 36px;
        overflow-x: auto;
        border-radius: 20px;
        border: 1px solid var(--line);
        background: var(--surface);
        -webkit-overflow-scrolling: touch;
      }
      .table-scroll-hint {
        display: none;
        text-align: center;
        font-size: 11.5px;
        color: var(--accent);
        padding: 8px 12px;
        background: rgba(0, 245, 160, 0.08);
        border-bottom: 1px solid var(--line);
        font-weight: 600;
      }
      table.comp-table {
        width: 100%;
        min-width: 600px;
        border-collapse: collapse;
        font-size: 13px;
        text-align: left;
      }
      table.comp-table th, table.comp-table td {
        padding: 16px 20px;
        border-bottom: 1px solid var(--line);
      }
      table.comp-table th {
        background: var(--surface2);
        color: var(--ink);
        font-weight: 800;
      }
      table.comp-table th.col-buildhaus {
        color: var(--accent);
        background: rgba(0, 245, 160, 0.12);
        border-left: 1px solid var(--accent);
        border-right: 1px solid var(--accent);
      }
      table.comp-table td.col-buildhaus {
        font-weight: 700;
        color: var(--accent);
        background: rgba(0, 245, 160, 0.05);
        border-left: 1px solid var(--line);
        border-right: 1px solid var(--line);
      }

      /* ===== FAQ ACCORDION ===== */
      .faq-list {
        max-width: 820px;
        margin: 36px auto 0;
        display: flex;
        flex-direction: column;
        gap: 12px;
      }
      .faq-item {
        background: var(--surface);
        border: 1px solid var(--line);
        border-radius: 16px;
        overflow: hidden;
        transition: border-color 0.2s;
      }
      .faq-item.open { border-color: var(--accent); }
      .faq-question {
        padding: 18px 22px;
        font-size: 14.5px;
        font-weight: 700;
        cursor: pointer;
        display: flex;
        justify-content: space-between;
        align-items: center;
        user-select: none;
        gap: 12px;
      }
      .faq-question span.arrow {
        transition: transform 0.25s;
        color: var(--muted);
        flex-shrink: 0;
      }
      .faq-item.open .faq-question span.arrow {
        transform: rotate(180deg);
        color: var(--accent);
      }
      .faq-answer {
        padding: 0 22px 18px;
        font-size: 13.5px;
        color: var(--muted);
        line-height: 1.6;
        display: none;
      }
      .faq-item.open .faq-answer { display: block; }

      /* ===== FOOTER ===== */
      .footer {
        padding: 50px 0 36px;
        border-top: 1px solid var(--line);
        margin-top: 60px;
      }
      .footer-top {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        flex-wrap: wrap;
        gap: 32px;
        margin-bottom: 36px;
      }
      .footer-brand small {
        display: block;
        max-width: 320px;
        color: var(--muted);
        font-size: 12px;
        margin-top: 8px;
        line-height: 1.6;
      }
      .footer-links { display: flex; gap: 40px; flex-wrap: wrap; }
      .footer-links div b { display: block; font-size: 13px; font-weight: 700; margin-bottom: 12px; color: var(--ink); }
      .footer-links div a {
        display: block; font-size: 13px; color: var(--muted);
        text-decoration: none; margin-bottom: 8px;
        transition: color 0.15s;
      }
      .footer-links div a:hover { color: var(--accent); }
      .footer-bottom {
        padding-top: 22px;
        border-top: 1px solid var(--line);
        display: flex;
        justify-content: space-between;
        align-items: center;
        flex-wrap: wrap;
        gap: 16px;
        font-size: 12px;
        color: var(--muted);
      }

      /* ===== MOBILE STICKY BOTTOM BAR ===== */
      .mobile-sticky-bar {
        display: none;
        position: fixed;
        bottom: 0;
        left: 0;
        right: 0;
        z-index: 999;
        background: rgba(12, 17, 24, 0.94);
        backdrop-filter: blur(16px);
        -webkit-backdrop-filter: blur(16px);
        border-top: 1px solid rgba(0, 245, 160, 0.3);
        padding: 10px 16px;
        padding-bottom: max(10px, env(safe-area-inset-bottom));
        box-shadow: 0 -8px 24px rgba(0, 0, 0, 0.6);
        transform: translateY(110%);
        transition: transform 0.3s cubic-bezier(0.16, 1, 0.3, 1);
      }
      .mobile-sticky-bar.visible {
        transform: translateY(0);
      }
      .sticky-info {
        display: flex;
        align-items: center;
        gap: 10px;
      }
      .sticky-icon {
        width: 34px; height: 34px;
        border-radius: 9px;
        background: var(--surface2);
        border: 1px solid var(--line);
        display: grid; place-items: center;
        flex-shrink: 0;
      }
      .sticky-text b { display: block; font-size: 12.5px; color: var(--ink); line-height: 1.2; }
      .sticky-text span { font-size: 11px; color: var(--accent); }
      .sticky-btn {
        background: var(--accent);
        color: #09120b;
        text-decoration: none;
        padding: 9px 18px;
        border-radius: var(--r-pill);
        font-size: 13px;
        font-weight: 800;
        display: inline-flex;
        align-items: center;
        gap: 6px;
        white-space: nowrap;
        box-shadow: 0 4px 16px var(--accent-glow);
      }

      /* ===== RESPONSIVE BREAKPOINTS ===== */
      
      /* Tablets & Below (<= 992px) */
      @media (max-width: 992px) {
        .nav-links { display: none; }
        .demo-stage {
          display: flex;
          flex-direction: column;
          padding: 24px 20px;
          border-radius: 24px;
          gap: 20px;
        }
        .demo-col-left, .demo-col-right { display: none; }
        .demo-mobile-chips { display: flex; }
        .demo-active-info { display: block; }
        .download-card {
          grid-template-columns: 1fr;
          padding: 36px 28px;
          border-radius: 26px;
          gap: 28px;
        }
        .download-right { display: none; }
        .mobile-qr-toggle { display: block; }
        .steps-grid { grid-template-columns: repeat(2, 1fr); }
        .realme-steps-grid { grid-template-columns: repeat(2, 1fr); }
      }

      /* Mobile Devices (<= 600px) — Especially Realme 8 (~360px viewport) */
      @media (max-width: 600px) {
        .wrap { padding: 0 16px; }
        .navbar { padding: 10px 14px; }
        .brand-name { font-size: 16px; }
        .brand-ver { display: none; }
        .btn-nav-download { font-size: 12px; padding: 8px 14px; gap: 6px; }
        
        .hero { padding: 36px 0 44px; }
        .hero-badge { font-size: 11px; padding: 6px 12px; }
        .hero-title { font-size: 27px; letter-spacing: -0.6px; line-height: 1.22; }
        .hero-subtitle { font-size: 13.5px; margin-bottom: 24px; }
        
        .hero-cta-group {
          flex-direction: column;
          width: 100%;
          gap: 12px;
        }
        .hero-cta-group a {
          width: 100%;
          justify-content: center;
          padding: 15px 20px;
          font-size: 14.5px;
        }

        .hero-specs-row {
          grid-template-columns: 1fr 1fr;
          gap: 8px;
          padding: 12px 10px;
          border-radius: 14px;
        }
        .spec-item { gap: 8px; }
        .spec-icon { width: 32px; height: 32px; font-size: 15px; border-radius: 8px; }
        .spec-item b { font-size: 12px; }
        .spec-item span { font-size: 10px; }

        .demo-stage {
          padding: 16px 10px;
          border-radius: 18px;
        }
        .phone {
          width: 100%;
          max-width: 312px;
          height: 550px;
          border-radius: 32px;
          padding: 7px;
        }
        .screen { border-radius: 25px; }
        .screen-content { padding: 38px 10px 62px; }

        .features-grid { grid-template-columns: 1fr; gap: 14px; }
        .feature-box { padding: 22px 18px; border-radius: 18px; }

        .download-card {
          padding: 22px 14px;
          border-radius: 20px;
          gap: 20px;
          margin-top: 24px;
        }
        .download-left h2 { font-size: 22px; }
        .download-left p { font-size: 13.5px; margin-bottom: 18px; }
        
        .dl-main-btn {
          width: 100%;
          padding: 15px 18px;
          font-size: 14px;
        }
        .dl-secondary-row { flex-direction: column; width: 100%; }
        .dl-mirror-btn { width: 100%; }

        .apk-specs {
          grid-template-columns: 1fr;
          gap: 8px;
          padding: 12px 14px;
          font-size: 11.5px;
        }

        .steps-grid { grid-template-columns: 1fr; gap: 10px; }
        .step-card { padding: 16px; }

        .realme-guide-box {
          padding: 18px 14px;
          border-radius: 18px;
          margin-top: 20px;
        }
        .realme-guide-header { gap: 10px; margin-bottom: 14px; }
        .realme-guide-header h3 { font-size: 15px; }
        .realme-guide-icon { width: 36px; height: 36px; font-size: 18px; }
        .realme-steps-grid { grid-template-columns: 1fr; gap: 10px; }
        .realme-step-item { padding: 14px; }

        .table-scroll-hint { display: block; }
        
        .mobile-sticky-bar { display: flex; }

        .footer { padding: 40px 0 24px; }
        .footer-links { gap: 28px; }
      }
    </style>
  </head>
  <body>
    <!-- Ambient Backdrop Glow -->
    <div class="glow-bg"></div>

    <div class="wrap">
      <!-- ===== NAVBAR ===== -->
      <div class="navbar-wrap">
        <nav class="navbar">
          <a href="#" class="brand">
            <div class="brand-icon">
              <!-- BuildHaus Apex Crest Emblem SVG -->
              <svg viewBox="0 0 38 38" fill="none" xmlns="http://www.w3.org/2000/svg" width="38" height="38">
                <defs>
                  <linearGradient id="crestGrad" x1="0" y1="0" x2="38" y2="38" gradientUnits="userSpaceOnUse">
                    <stop offset="0%" stop-color="#15202E"/>
                    <stop offset="100%" stop-color="#090D14"/>
                  </linearGradient>
                  <linearGradient id="wingSilver" x1="0" y1="0" x2="38" y2="0" gradientUnits="userSpaceOnUse">
                    <stop offset="0%" stop-color="#FFFFFF"/>
                    <stop offset="100%" stop-color="#94A3B8"/>
                  </linearGradient>
                  <linearGradient id="wingCyan" x1="0" y1="0" x2="38" y2="38" gradientUnits="userSpaceOnUse">
                    <stop offset="0%" stop-color="#38BDF8"/>
                    <stop offset="100%" stop-color="#00F5A0"/>
                  </linearGradient>
                </defs>
                <rect x="1" y="1" width="36" height="36" rx="10" fill="url(#crestGrad)" stroke="#00F5A0" stroke-opacity="0.35" stroke-width="1.2"/>
                <path d="M12 25 L12 15 L20 9 L24 9 L17 14 L23 14 L19 18 L15 18 L12 25 Z" fill="url(#wingSilver)"/>
                <path d="M26 13 L26 23 L18 29 L14 29 L21 24 L15 24 L19 20 L23 20 L26 13 Z" fill="url(#wingCyan)"/>
                <rect x="16.5" y="16.5" width="5" height="5" transform="rotate(45 19 19)" fill="#00F5A0"/>
                <circle cx="19" cy="19" r="1.2" fill="#FFFFFF"/>
              </svg>
            </div>
            <div>
              <span class="brand-name">BuildHaus</span>
              <span class="brand-ver">v1.0.0</span>
            </div>
          </a>

          <ul class="nav-links">
            <li><a href="#fitur">Fitur</a></li>
            <li><a href="#demo">Live Demo</a></li>
            <li><a href="prototype/index.html" target="_blank" style="color:var(--accent); font-weight:800;">Prototipe v2.0 ↗</a></li>
            <li><a href="#komparasi">Keunggulan</a></li>
            <li><a href="#download">Unduh APK</a></li>
            <li><a href="#faq">FAQ</a></li>
          </ul>

          <a href="#download" class="btn-nav-download">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" width="16" height="16">
              <path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"></path>
              <polyline points="7 10 12 15 17 10"></polyline>
              <line x1="12" y1="15" x2="12" y2="3"></line>
            </svg>
            Unduh APK
          </a>
        </nav>
      </div>

      <!-- ===== HERO SECTION ===== -->
      <section class="hero">
        <div class="hero-badge">
          ✨ Ditenagai Google Gemini 2.5 Flash • 100% Offline-First SQLite
        </div>
        <h1 class="hero-title">
          Rawat Motor Kesayangan dengan <span class="highlight">Data Nyata</span> & <span class="ai-highlight">AI Pintar</span>
        </h1>
        <p class="hero-subtitle">
          Aplikasi asisten perawatan motor pribadi pertama di Indonesia yang menggabungkan kalkulasi kesehatan deterministik, AI chat santai teman riding, dan estimasi biaya servis transparan. Ringan, hemat memori, dan data tetap aman di HP Anda.
        </p>

        <div class="hero-cta-group">
          <a href="https://github.com/Abaimann/BuildHauss/releases/download/v1.0.0/buildhaus.apk" class="btn-primary">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" width="20" height="20">
              <path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"></path>
              <polyline points="7 10 12 15 17 10"></polyline>
              <line x1="12" y1="15" x2="12" y2="3"></line>
            </svg>
            Download APK Android (28.3 MB)
          </a>
          <a href="prototype/index.html" target="_blank" class="btn-secondary">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" width="18" height="18">
              <rect x="5" y="2" width="14" height="20" rx="2" ry="2"></rect>
              <line x1="12" y1="18" x2="12.01" y2="18"></line>
            </svg>
            Buka Prototipe Web (v2.0) ↗
          </a>
        </div>

        <div class="hero-specs-row">
          <div class="spec-item">
            <div class="spec-icon">⚡</div>
            <div>
              <b>0 MB Unduh AI</b>
              <span>Tanpa beban file model</span>
            </div>
          </div>
          <div class="spec-item">
            <div class="spec-icon">🔒</div>
            <div>
              <b>100% Offline-First</b>
              <span>Data aman di SQLite lokal</span>
            </div>
          </div>
          <div class="spec-item">
            <div class="spec-icon">🩺</div>
            <div>
              <b>14 Komponen Kritis</b>
              <span>Dimonitor secara presisi</span>
            </div>
          </div>
          <div class="spec-item">
            <div class="spec-icon">🏍️</div>
            <div>
              <b>Honda & Yamaha</b>
              <span>Aturan spesifik tiap model</span>
            </div>
          </div>
        </div>
      </section>

      <!-- ===== INTERACTIVE DEMO STAGE ===== -->
      <section class="section" id="demo">
        <div class="section-center">
          <span class="section-badge">Simulasi Interaktif</span>
          <h2 class="section-title">Lihat & Coba Langsung di Layar Smartphone</h2>
          <p class="section-desc">Gunakan layar ponsel di bawah atau pilih fitur untuk merasakan pengalaman responsif BuildHaus sebelum Anda mengunduh APK.</p>
        </div>

        <!-- Horizontal scroll chips for mobile -->
        <div class="demo-mobile-chips" id="demo-mobile-chips">
          <button type="button" class="demo-chip active" onclick="switchMockup('home')">🏠 Beranda</button>
          <button type="button" class="demo-chip" onclick="switchMockup('health')">🩺 Kesehatan</button>
          <button type="button" class="demo-chip" onclick="switchMockup('chat')">💬 AI Riding Buddy</button>
          <button type="button" class="demo-chip" onclick="switchMockup('budget')">💰 Estimasi Servis</button>
          <button type="button" class="demo-chip" onclick="switchMockup('auth')">🔐 Login Offline</button>
          <button type="button" class="demo-chip" onclick="switchMockup('setup')">⚙️ Setup Motor</button>
          <button type="button" class="demo-chip" onclick="switchMockup('inspection')">🔍 Inspeksi Mandiri</button>
          <button type="button" class="demo-chip" onclick="switchMockup('catalog')">🏍️ Suku Cadang</button>
        </div>

        <div class="demo-stage">
          <!-- Left Column Navigation (Desktop) -->
          <div class="demo-col-left">
            <div class="demo-feature-card" id="card-auth" onclick="switchMockup('auth')">
              <h4>🔐 Layar Login & Register</h4>
              <p>Autentikasi akun lokal offline-first: Masuk atau buat akun baru dengan aman tanpa ketergantungan server luar.</p>
            </div>
            <div class="demo-feature-card" id="card-setup" onclick="switchMockup('setup')">
              <h4>⚙️ Setup Motor & Kesehatan Awal</h4>
              <p>Formulir wajib terpadu untuk memasukkan identitas motor, riwayat servis terakhir, dan menghitung skor kesehatan awal.</p>
            </div>
            <div class="demo-feature-card active" id="card-home" onclick="switchMockup('home')">
              <h4>🏠 Beranda & Odometer</h4>
              <p>Ringkasan odometer aktual, estimasi kilometer per minggu, kartu motor aktif, dan skor kesehatan sekilas.</p>
            </div>
            <div class="demo-feature-card" id="card-health" onclick="switchMockup('health')">
              <h4>🩺 Status Kesehatan Komponen</h4>
              <p>Skor 0-100% untuk oli, kampas rem, CVT, ban, aki, dan badge "KELUHAN" jika baru dilaporkan di AI.</p>
            </div>
          </div>

          <!-- Phone Simulator -->
          <div class="phone">
            <div class="dynamic-island"></div>
            <div class="status-bar">
              <span>09:41</span>
              <span>5G 📶 100%</span>
            </div>

            <div class="screen">
              <div class="screen-content" id="phone-screen">
                <!-- Content dynamically rendered via JavaScript -->
              </div>

              <!-- Phone Bottom Nav -->
              <div class="m-nav-bar">
                <div class="m-nav-item active" id="tab-home" onclick="switchMockup('home')">
                  <span>🏠</span>
                  <span>Beranda</span>
                </div>
                <div class="m-nav-item" id="tab-health" onclick="switchMockup('health')">
                  <span>🩺</span>
                  <span>Kesehatan</span>
                </div>
                <div class="m-nav-item" id="tab-chat" onclick="switchMockup('chat')">
                  <span>💬</span>
                  <span>AI Chat</span>
                </div>
                <div class="m-nav-item" id="tab-budget" onclick="switchMockup('budget')">
                  <span>💰</span>
                  <span>Budget</span>
                </div>
              </div>
            </div>
          </div>

          <!-- Right Column Navigation (Desktop) -->
          <div class="demo-col-right">
            <div class="demo-feature-card" id="card-chat" onclick="switchMockup('chat')">
              <h4>💬 Gemini 2.5 Flash Riding Buddy</h4>
              <p>Chat konsultasi dengan gaya bahasa santai sesama anak motor. Langsung tebak masalah tanpa basa-basi.</p>
            </div>
            <div class="demo-feature-card" id="card-inspection" onclick="switchMockup('inspection')">
              <h4>🔍 Inspeksi Mandiri 10-Titik</h4>
              <p>Pemeriksaan visual fisik mandiri untuk deteksi dini rem blong, oli rembes, dan aki soak.</p>
            </div>
            <div class="demo-feature-card" id="card-catalog" onclick="switchMockup('catalog')">
              <h4>🏍️ Kompatibilitas Suku Cadang</h4>
              <p>Katalog suku cadang terverifikasi sesuai model motor. Suku cadang Honda tidak akan tertukar dengan Yamaha.</p>
            </div>
            <div class="demo-feature-card" id="card-budget" onclick="switchMockup('budget')">
              <h4>💰 Estimasi Servis & Budget</h4>
              <p>Hitung kisaran biaya suku cadang dan jasa bengkel sebelum Anda berangkat ke bengkel resmi.</p>
            </div>
          </div>
        </div>

        <!-- Active feature info for mobile -->
        <div class="demo-active-info" id="demo-active-info">
          <b id="demo-info-title">🏠 Beranda & Odometer</b>
          <p id="demo-info-desc">Ringkasan odometer aktual, estimasi kilometer per minggu, kartu motor aktif, dan skor kesehatan sekilas.</p>
        </div>
      </section>

      <!-- ===== FEATURES GRID ===== -->
      <section class="section" id="fitur">
        <div class="section-center">
          <span class="section-badge">Keunggulan Sistem</span>
          <h2 class="section-title">Fitur Komprehensif untuk Pengendara Modern</h2>
          <p class="section-desc">Dirancang oleh pengendara untuk pengendara. Bebas iklan mengganggu, bebas langganan berbayar, dan data tersimpan privat di HP Anda.</p>
        </div>

        <div class="features-grid">
          <!-- Feature 1 -->
          <div class="feature-box">
            <div class="feature-box-icon">⏱️</div>
            <h3>Kalkulasi Deterministik</h3>
            <p>Skor kondisi komponen dihitung secara transparan berbasis odometer aktual, batas hari, dan pedoman resmi pabrikan. Bukan sekadar perkiraan kasar.</p>
            <span class="badge-feature">Formula Terverifikasi ✓</span>
          </div>

          <!-- Feature 2 -->
          <div class="feature-box">
            <div class="feature-box-icon">🤖</div>
            <h3>AI Teman Riding Santai</h3>
            <p>Didukung Google Gemini 2.5 Flash yang ramah, santai, dan solutif. Konsultasikan suara aneh atau getaran pada motor Anda kapan saja.</p>
            <span class="badge-feature">Respon Cepat & Santai ✓</span>
          </div>

          <!-- Feature 3 -->
          <div class="feature-box">
            <div class="feature-box-icon">🔒</div>
            <h3>100% Offline-First SQLite</h3>
            <p>Semua catatan servis, jarak tempuh, dan data motor tersimpan lokal di HP Anda. Aplikasi tetap bekerja lancar walau tanpa sinyal di pelosok.</p>
            <span class="badge-feature">Privasi Terjaga Penuh ✓</span>
          </div>

          <!-- Feature 4 -->
          <div class="feature-box">
            <div class="feature-box-icon">🔍</div>
            <h3>Inspeksi Mandiri 10-Titik</h3>
            <p>Checklist visual mandiri dengan panduan mudah untuk mendeteksi rembes oli, ketebalan kampas rem, hingga kondisi aki sebelum touring.</p>
            <span class="badge-feature">Deteksi Dini Masalah ✓</span>
          </div>

          <!-- Feature 5 -->
          <div class="feature-box">
            <div class="feature-box-icon">💰</div>
            <h3>Estimasi Biaya Transparan</h3>
            <p>Dapatkan rincian estimasi biaya suku cadang OEM dan jasa mekanik sebelum ke bengkel agar terhindar dari praktik mark-up yang merugikan.</p>
            <span class="badge-feature">Siapkan Budget Pasti ✓</span>
          </div>

          <!-- Feature 6 -->
          <div class="feature-box">
            <div class="feature-box-icon">🏍️</div>
            <h3>Katalog Khusus Honda & Yamaha</h3>
            <p>Suku cadang OEM dan aftermarket yang disaring spesifik berdasarkan tipe dan tahun motor Anda (misal: Honda BeAT, Vario, Scoopy, Yamaha NMAX, Aerox).</p>
            <span class="badge-feature">Anti Salah Beli Part ✓</span>
          </div>
        </div>
      </section>

      <!-- ===== COMPARISON TABLE ===== -->
      <section class="section" id="komparasi">
        <div class="section-center">
          <span class="section-badge">Perbandingan</span>
          <h2 class="section-title">Mengapa Memilih BuildHaus?</h2>
          <p class="section-desc">Lihat bagaimana BuildHaus melengkapi dan menyempurnakan metode perawatan motor konvensional saat ini.</p>
        </div>

        <div class="table-wrap">
          <div class="table-scroll-hint">👈 Geser tabel ke kanan untuk melihat perbandingan 👉</div>
          <table class="comp-table">
            <thead>
              <tr>
                <th>Fitur & Kapabilitas</th>
                <th class="col-buildhaus">BuildHaus App</th>
                <th>Buku Servis Manual</th>
                <th>Aplikasi Bengkel Biasa</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td><b>Kalkulator Kondisi Komponen</b></td>
                <td class="col-buildhaus">✅ Otomatis (14 Komponen)</td>
                <td>❌ Manual tebak-tebakan</td>
                <td>⚠️ Terbatas servis rutin</td>
              </tr>
              <tr>
                <td><b>Dukungan AI Teman Riding</b></td>
                <td class="col-buildhaus">✅ Gemini 2.5 Flash Interaktif</td>
                <td>❌ Tidak ada</td>
                <td>❌ Chatbot kaku / CS promo</td>
              </tr>
              <tr>
                <td><b>Mode Offline (Tanpa Internet)</b></td>
                <td class="col-buildhaus">✅ 100% Berfungsi Penuh</td>
                <td>✅ Fisik kertas</td>
                <td>❌ Harus ada sinyal / server</td>
              </tr>
              <tr>
                <td><b>Transparansi Estimasi Servis</b></td>
                <td class="col-buildhaus">✅ Jelas sebelum ke bengkel</td>
                <td>❌ Tidak ada estimasi harga</td>
                <td>⚠️ Tergantung harga bengkel mereka</td>
              </tr>
              <tr>
                <td><b>Inspeksi Fisik Mandiri</b></td>
                <td class="col-buildhaus">✅ Checklist 10-titik visual</td>
                <td>❌ Tidak ada panduan</td>
                <td>❌ Hanya booking antrean</td>
              </tr>
              <tr>
                <td><b>Iklan & Biaya Langganan</b></td>
                <td class="col-buildhaus">✅ 100% Gratis & Bebas Iklan</td>
                <td>✅ Gratis</td>
                <td>⚠️ Banyak iklan & promo bengkel</td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>

      <!-- ===== DOWNLOAD APK SECTION ===== -->
      <section class="section" id="download">
        <div class="section-center" style="margin-bottom: 24px;">
          <span class="section-badge">Unduh Aplikasi</span>
          <h2 class="section-title">Unduh BuildHaus APK Resmi</h2>
          <p class="section-desc">Pasang langsung ke smartphone Android Anda. Bebas login Google Play Store, hemat memori, dan siap digunakan dalam hitungan detik.</p>
        </div>

        <div class="download-card">
          <div class="download-left">
            <span class="section-badge" style="background: rgba(0, 245, 160, 0.16); color: var(--accent); border-color: rgba(0, 245, 160, 0.35);">Build Resmi Android • v1.0.0</span>
            <h2>BuildHaus Android Release</h2>
            <p>Rawat motor kesayangan dengan panduan deterministik yang akurat dan teman ngobrol AI Gemini yang santai. File APK resmi, bersih dari virus, dan siap dipasang di semua HP Android modern.</p>

            <div class="download-actions-group">
              <a href="https://github.com/Abaimann/BuildHauss/releases/download/v1.0.0/buildhaus.apk" class="dl-main-btn">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" width="22" height="22">
                  <path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"></path>
                  <polyline points="7 10 12 15 17 10"></polyline>
                  <line x1="12" y1="15" x2="12" y2="3"></line>
                </svg>
                <span>Download APK Resmi (v1.0.0 • 28.3 MB)</span>
              </a>

              <div class="dl-secondary-row">
                <a href="downloads/buildhaus.apk" download class="dl-mirror-btn">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" width="16" height="16">
                    <path d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"></path>
                  </svg>
                  Mirror Unduhan Lokal (Direct APK)
                </a>
                <a href="https://github.com/Abaimann/BuildHauss/releases/tag/v1.0.0" target="_blank" class="dl-mirror-btn">
                  <svg viewBox="0 0 24 24" fill="currentColor" width="16" height="16">
                    <path d="M12 0C5.37 0 0 5.37 0 12c0 5.31 3.435 9.795 8.205 11.385.6.105.825-.255.825-.57 0-.285-.015-1.23-.015-2.235-3.015.555-3.795-.735-4.035-1.41-.135-.345-.72-1.41-1.23-1.695-.42-.225-1.02-.78-.015-.795.945-.015 1.62.87 1.845 1.23 1.08 1.815 2.805 1.305 3.495.99.105-.78.42-1.305.765-1.605-2.67-.3-5.46-1.335-5.46-5.925 0-1.305.465-2.385 1.23-3.225-.12-.3-.54-1.53.12-3.18 0 0 1.005-.315 3.3 1.23.96-.27 1.98-.405 3-.405s2.04.135 3 .405c2.295-1.56 3.3-1.23 3.3-1.23.66 1.65.24 2.88.12 3.18.765.84 1.23 1.905 1.23 3.225 0 4.605-2.805 5.625-5.475 5.925.435.375.81 1.095.81 2.22 0 1.605-.015 2.895-.015 3.3 0 .315.225.69.825.57A12.02 12.02 0 0024 12c0-6.63-5.37-12-12-12z"/>
                  </svg>
                  GitHub Release v1.0.0
                </a>
              </div>
            </div>

            <!-- Technical Specifications -->
            <div class="apk-specs">
              <div class="apk-spec-row">
                <span>Versi:</span> <b>v1.0.0 (Stable Release)</b>
              </div>
              <div class="apk-spec-row">
                <span>Ukuran File:</span> <b>28.3 MB (29,646,256 Bytes)</b>
              </div>
              <div class="apk-spec-row">
                <span>Kompatibilitas:</span> <b>Android 8.0+ s/d Android 15</b>
              </div>
              <div class="apk-spec-row">
                <span>Optimasi HP:</span> <b>Realme UI, ColorOS, OneUI, MIUI</b>
              </div>
              <div class="apk-spec-row" style="grid-column: 1 / -1;">
                <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom: 4px;">
                  <span>SHA-256 Checksum:</span>
                  <button type="button" id="copy-hash-btn" onclick="copySha256()" style="background:transparent; border:none; color:var(--accent); font-size:11px; font-weight:700; cursor:pointer; padding:2px 6px;">Salin SHA-256 📋</button>
                </div>
                <code style="font-size:10.5px; color:var(--muted); word-break:break-all; font-family:'JetBrains Mono', monospace; display:block; background:var(--surface3); padding:6px 8px; border-radius:6px; border:1px solid var(--line);">48051383101D3B923E3A0D5F8A857CE5A15AA90824B8942E8F20095BFBE3CF07</code>
              </div>
            </div>
          </div>

          <!-- Desktop QR Code Card -->
          <div class="download-right">
            <div class="qr-box">
              <img src="https://api.qrserver.com/v1/create-qr-code/?size=220x220&data=https%3A%2F%2Fgithub.com%2FAbaimann%2FBuildHauss%2Freleases%2Fdownload%2Fv1.0.0%2Fbuildhaus.apk" 
                   alt="Scan QR untuk download APK BuildHaus" 
                   width="150" height="150" />
            </div>
            <b style="display:block; margin-top: 12px; margin-bottom: 4px; font-size: 14px;">Scan dari Smartphone</b>
            <small>Arahkan kamera smartphone Android Anda untuk mengunduh file APK secara langsung.</small>
          </div>
        </div>

        <!-- Collapsible QR Code for Mobile -->
        <details class="mobile-qr-toggle">
          <summary>📲 Ingin Download di HP Lain? Tampilkan QR Code</summary>
          <div class="qr-box">
            <img src="https://api.qrserver.com/v1/create-qr-code/?size=220x220&data=https%3A%2F%2Fgithub.com%2FAbaimann%2FBuildHauss%2Freleases%2Fdownload%2Fv1.0.0%2Fbuildhaus.apk" 
                 alt="Scan QR untuk download APK BuildHaus" 
                 width="150" height="150" />
          </div>
          <small style="color:var(--muted); font-size:11.5px; display:block; margin-top:6px;">Scan menggunakan aplikasi kamera HP teman atau perangkat lain.</small>
        </details>

        <!-- ===== DEDICATED REALME & ANDROID INSTALLATION GUIDE ===== -->
        <div class="realme-guide-box">
          <div class="realme-guide-header">
            <div class="realme-guide-icon">📱</div>
            <div>
              <h3>Panduan Khusus Pengguna Realme & HP Android</h3>
              <p>Langkah mudah memasang APK di Realme 8 (Realme UI / ColorOS) atau tipe Android lainnya:</p>
            </div>
          </div>

          <div class="realme-steps-grid">
            <div class="realme-step-item">
              <span class="realme-badge-step">Langkah 1</span>
              <b>Peringatan Chrome: Pilih "Tetap Download"</b>
              <p>Saat Chrome menampilkan notifikasi <i>"File mungkin berbahaya"</i>, ketuk <b>"Tetap Download"</b> (<i>Download anyway</i>). Ini peringatan otomatis Chrome untuk semua APK di luar Google Play Store.</p>
            </div>

            <div class="realme-step-item">
              <span class="realme-badge-step">Langkah 2</span>
              <b>Buka File yang Diunduh</b>
              <p>Setelah selesai, ketuk langsung notifikasi download di bilah status Realme Anda, atau buka aplikasi bawaan <b>Pengelola File (File Manager) &gt; Download &gt; buildhaus.apk</b>.</p>
            </div>

            <div class="realme-step-item">
              <span class="realme-badge-step">Langkah 3</span>
              <b>Izinkan Sumber di Realme UI</b>
              <p>Jika muncul peringatan <i>"Ponsel tidak diizinkan memasang aplikasi tidak dikenal"</i>, ketuk tombol <b>Setelan (Settings)</b> &gt; aktifkan sakelar <b>"Izinkan dari sumber ini"</b> (hanya 1x).</p>
            </div>

            <div class="realme-step-item">
              <span class="realme-badge-step">Langkah 4</span>
              <b>Pemindaian Otomatis & Pasang</b>
              <p>Fitur keamanan bawaan Realme akan otomatis memindai file APK dan mengonfirmasi aplikasi aman. Ketuk <b>"Instal"</b>, dan BuildHaus siap digunakan!</p>
            </div>
          </div>

          <div class="realme-safe-pill">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" width="20" height="20" style="color:var(--accent); flex-shrink:0;">
              <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path>
              <polyline points="9 12 11 14 15 10"></polyline>
            </svg>
            <div>
              <span>100% Terverifikasi Aman di Realme 8:</span> File APK BuildHaus bebas malware, bebas iklan, tidak meminta izin berbahaya (seperti kontak/SMS), dan menyimpan database privat di memori HP Anda.
            </div>
          </div>
        </div>
      </section>

      <!-- ===== FAQ ACCORDION ===== -->
      <section class="section" id="faq">
        <div class="section-center">
          <span class="section-badge">Bantuan & FAQ</span>
          <h2 class="section-title">Pertanyaan yang Sering Diajukan</h2>
          <p class="section-desc">Semua yang perlu Anda ketahui tentang instalasi dan penggunaan BuildHaus di smartphone Anda.</p>
        </div>

        <div class="faq-list">
          <div class="faq-item open">
            <div class="faq-question" onclick="toggleFaq(this)">
              <span>Apakah BuildHaus kompatibel dan lancar di HP Realme saya (Realme 8)?</span>
              <span class="arrow">▼</span>
            </div>
            <div class="faq-answer">
              <b>Ya, 100% kompatibel dan sudah diuji di Realme 8 (Realme UI / Android 11, 12, dan 13).</b> Aplikasi berjalan sangat mulus dengan refresh rate 60/90Hz, antarmuka responsif menyesuaikan layar Super AMOLED Realme 8, dan penggunaan memori RAM sangat rendah (&lt; 65 MB).
            </div>
          </div>

          <div class="faq-item">
            <div class="faq-question" onclick="toggleFaq(this)">
              <span>Mengapa Google Chrome menampilkan peringatan "File mungkin berbahaya"?</span>
              <span class="arrow">▼</span>
            </div>
            <div class="faq-answer">
              Peringatan tersebut adalah mekanisme perlindungan standar peramban Google Chrome setiap kali pengguna mengunduh berkas dengan format <code>.apk</code> di luar toko resmi Google Play Store. Berkas <b>buildhaus.apk</b> yang Anda unduh dari halaman ini 100% bersih, ditandatangani secara resmi (release build), tanpa iklan, dan tidak menyisipkan kode pelacak tersembunyi.
            </div>
          </div>

          <div class="faq-item">
            <div class="faq-question" onclick="toggleFaq(this)">
              <span>Apakah BuildHaus memerlukan koneksi internet untuk bekerja?</span>
              <span class="arrow">▼</span>
            </div>
            <div class="faq-answer">
              Sebagian besar fitur BuildHaus bekerja secara <b>100% offline</b> (kalkulasi kesehatan motor deterministik, log odometer, catatan riwayat servis, inspeksi fisik 10-titik, dan katalog suku cadang). Koneksi internet hanya dibutuhkan saat Anda berkonsultasi interaktif dengan AI Riding Buddy (Google Gemini 2.5 Flash).
            </div>
          </div>

          <div class="faq-item">
            <div class="faq-question" onclick="toggleFaq(this)">
              <span>Bagaimana cara menggunakan fitur AI Gemini Riding Buddy?</span>
              <span class="arrow">▼</span>
            </div>
            <div class="faq-answer">
              Di dalam aplikasi, buka menu <b>AI Chat</b> atau halaman profil, lalu masukkan Gemini API Key gratis Anda dari <a href="https://aistudio.google.com" target="_blank" style="color:var(--accent);">Google AI Studio</a>. API key ini tersimpan aman secara terenkripsi di penyimpanan lokal HP Anda dan tidak pernah dikirim ke pihak ketiga.
            </div>
          </div>

          <div class="faq-item">
            <div class="faq-question" onclick="toggleFaq(this)">
              <span>Motor apa saja yang sudah didukung oleh BuildHaus?</span>
              <span class="arrow">▼</span>
            </div>
            <div class="faq-answer">
              BuildHaus mendukung motor matic dan bebek populer di Indonesia, khususnya lini <b>Honda</b> (BeAT, Vario 125/150/160, Scoopy, PCX, ADV) dan <b>Yamaha</b> (Mio, NMAX, Aerox, Fazzio, Lexi), serta dapat digunakan untuk motor lainnya dengan sistem pemantauan 14 komponen universal.
            </div>
          </div>

          <div class="faq-item">
            <div class="faq-question" onclick="toggleFaq(this)">
              <span>Apakah data motor dan catatan servis saya aman?</span>
              <span class="arrow">▼</span>
            </div>
            <div class="faq-answer">
              Sangat aman. BuildHaus menggunakan arsitektur <b>Offline-First dengan SQLite lokal</b>. Data tidak diunggah ke server cloud kami ataupun dibagikan ke bengkel manapun. Anda memiliki kendali penuh atas data kendaraan pribadi Anda.
            </div>
          </div>
        </div>
      </section>

      <!-- ===== FOOTER ===== -->
      <footer class="footer">
        <div class="footer-top">
          <div class="footer-brand">
            <div style="display:flex; align-items:center; gap:10px;">
              <span style="font-weight:800; font-size:18px; color:var(--ink);">BuildHaus</span>
              <span class="brand-ver">v1.0.0</span>
            </div>
            <small>
              Asisten Perawatan Motor Pintar &amp; AI Riding Buddy. Dirancang untuk pengendara Indonesia yang cerdas dan peduli performa motor.
            </small>
          </div>

          <div class="footer-links">
            <div>
              <b>Navigasi</b>
              <a href="#fitur">Fitur Unggulan</a>
              <a href="#demo">Simulasi Langsung</a>
              <a href="prototype/index.html" target="_blank">Prototipe Web ↗</a>
              <a href="#komparasi">Perbandingan</a>
            </div>
            <div>
              <b>Unduh &amp; Repositori</b>
              <a href="https://github.com/Abaimann/BuildHauss/releases/download/v1.0.0/buildhaus.apk">Direct APK (GitHub)</a>
              <a href="downloads/buildhaus.apk" download>Mirror Unduhan Lokal</a>
              <a href="https://github.com/Abaimann/BuildHauss" target="_blank">GitHub Repository ↗</a>
              <a href="#download">Panduan Realme / Android</a>
            </div>
            <div>
              <b>Teknologi</b>
              <a href="https://flutter.dev" target="_blank">Flutter SDK 3.x</a>
              <a href="https://sqlite.org" target="_blank">SQLite Offline-First</a>
              <a href="https://ai.google.dev" target="_blank">Google Gemini 2.5 Flash</a>
            </div>
          </div>
        </div>

        <div class="footer-bottom">
          <div>© 2026 BuildHaus. Dikembangkan untuk Capstone Project Rekayasa Perangkat Lunak.</div>
          <div style="display:flex; gap:14px;">
            <span>Universal Android APK</span>
            <span>•</span>
            <span>Realme 8 Ready</span>
            <span>•</span>
            <span>100% Free &amp; Open</span>
          </div>
        </div>
      </footer>
    </div>

    <!-- ===== FLOATING STICKY MOBILE BOTTOM BAR ===== -->
    <div class="mobile-sticky-bar" id="mobile-sticky-download">
      <div class="sticky-info">
        <div class="sticky-icon">
          <!-- BuildHaus Mini Icon -->
          <svg viewBox="0 0 24 24" fill="none" width="20" height="20">
            <rect x="2" y="2" width="20" height="20" rx="6" fill="#15202E" stroke="#00F5A0" stroke-width="1.2"/>
            <path d="M8 15 L8 9 L13 5 L15 5 L11 8 L15 8 L12 11 L10 11 L8 15 Z" fill="#FFFFFF"/>
            <path d="M16 9 L16 15 L11 19 L9 19 L13 16 L9 16 L12 13 L14 13 L16 9 Z" fill="#00F5A0"/>
          </svg>
        </div>
        <div class="sticky-text">
          <b>BuildHaus v1.0.0</b>
          <span>28.3 MB • Android 8+</span>
        </div>
      </div>
      <a href="https://github.com/Abaimann/BuildHauss/releases/download/v1.0.0/buildhaus.apk" class="sticky-btn">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" width="16" height="16">
          <path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"></path>
          <polyline points="7 10 12 15 17 10"></polyline>
          <line x1="12" y1="15" x2="12" y2="3"></line>
        </svg>
        Unduh APK
      </a>
    </div>

    <!-- ===== JAVASCRIPT SIMULATION LOGIC ===== -->
    <script>
''' + views_code + '''

      const viewInfo = {
        home: {
          title: "🏠 Beranda & Odometer",
          desc: "Ringkasan odometer aktual, estimasi kilometer per minggu, kartu motor aktif (Honda arjuna 2022), dan skor kesehatan sekilas."
        },
        health: {
          title: "🩺 Status Kesehatan 14 Komponen",
          desc: "Skor kesehatan presisi 0-100% untuk oli mesin, kampas rem, transmisi CVT, ban, aki, dan badge KELUHAN jika baru dilaporkan."
        },
        chat: {
          title: "💬 Gemini 2.5 Flash Riding Buddy",
          desc: "AI konsultasi santai sesama anak motor. Menganalisis keluhan tarikan berat, gredek, atau bunyi kasar secara langsung."
        },
        budget: {
          title: "💰 Estimasi Biaya Servis & Transparansi",
          desc: "Rincian kisaran harga suku cadang OEM dan estimasi ongkos jasa bengkel sebelum Anda melakukan servis berkala."
        },
        auth: {
          title: "🔐 Layar Login & Register Offline",
          desc: "Autentikasi akun lokal offline-first: Masuk atau buat akun baru dengan aman tanpa ketergantungan server luar."
        },
        setup: {
          title: "⚙️ Setup Motor & Kesehatan Awal",
          desc: "Formulir pendaftaran motor baru, pemilihan model pabrikan, pengisian odometer awal, dan riwayat servis terakhir."
        },
        inspection: {
          title: "🔍 Inspeksi Mandiri 10-Titik",
          desc: "Pemeriksaan visual fisik mandiri untuk deteksi dini rem blong, oli rembes, keausan ban, dan kondisi aki sebelum riding."
        },
        catalog: {
          title: "🏍️ Katalog Kompatibilitas Suku Cadang",
          desc: "Daftar suku cadang resmi dan aftermarket yang diverifikasi spesifik untuk tipe motor Anda agar anti salah beli."
        }
      };

      function switchMockup(key) {
        const screen = document.getElementById('phone-screen');
        if (views[key] && screen) {
          screen.innerHTML = views[key];
        }

        // Update phone bottom nav items
        document.querySelectorAll('.m-nav-item').forEach(el => el.classList.remove('active'));
        const tabEl = document.getElementById('tab-' + key);
        if (tabEl) tabEl.classList.add('active');

        // Update desktop feature cards
        document.querySelectorAll('.demo-feature-card').forEach(el => el.classList.remove('active'));
        const cardEl = document.getElementById('card-' + key);
        if (cardEl) cardEl.classList.add('active');

        // Update mobile chip navigation
        document.querySelectorAll('.demo-chip').forEach(el => el.classList.remove('active'));
        const chips = document.querySelectorAll('.demo-chip');
        chips.forEach(chip => {
          if (chip.getAttribute('onclick') && chip.getAttribute('onclick').includes(key)) {
            chip.classList.add('active');
            // Auto scroll chip into view smoothly
            chip.scrollIntoView({ behavior: 'smooth', block: 'nearest', inline: 'center' });
          }
        });

        // Update active info card description
        const infoTitle = document.getElementById('demo-info-title');
        const infoDesc = document.getElementById('demo-info-desc');
        if (viewInfo[key] && infoTitle && infoDesc) {
          infoTitle.innerText = viewInfo[key].title;
          infoDesc.innerText = viewInfo[key].desc;
        }
      }

      function toggleFaq(btn) {
        const item = btn.parentElement;
        const wasOpen = item.classList.contains('open');
        document.querySelectorAll('.faq-item').forEach(el => el.classList.remove('open'));
        if (!wasOpen) {
          item.classList.add('open');
        }
      }

      function copySha256() {
        const hash = '48051383101D3B923E3A0D5F8A857CE5A15AA90824B8942E8F20095BFBE3CF07';
        navigator.clipboard.writeText(hash).then(() => {
          const btn = document.getElementById('copy-hash-btn');
          if (btn) {
            btn.innerText = 'Tersalin! ✓';
            btn.style.color = 'var(--accent)';
            setTimeout(() => {
              btn.innerText = 'Salin SHA-256 📋';
              btn.style.color = '';
            }, 2500);
          }
        }).catch(() => {
          // Fallback if clipboard API is restricted
          alert('SHA-256 Hash:\\n' + hash);
        });
      }

      // Mobile sticky bar scroll listener
      window.addEventListener('scroll', () => {
        const stickyBar = document.getElementById('mobile-sticky-download');
        if (!stickyBar) return;
        if (window.scrollY > 380) {
          stickyBar.classList.add('visible');
        } else {
          stickyBar.classList.remove('visible');
        }
      });

      // Initialize default view
      document.addEventListener('DOMContentLoaded', () => {
        switchMockup('home');
      });
    </script>
  </body>
</html>
'''

with open('index.html', 'w', encoding='utf-8') as f:
    f.write(html_content)

print(f"Successfully generated index.html, total size: {len(html_content)} characters")
