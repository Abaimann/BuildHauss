import os
import sys
import docx
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT
import win32com.client
from PIL import Image, ImageDraw, ImageFont
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np

ARTIFACTS_DIR = r"C:\Users\ACER\.gemini\antigravity\brain\29af0b69-f612-4511-b625-b9c14ade5ea6"
OUT_DIR = r"C:\SAVING\GAWEAN GW\Capstone-Project\JOSJIS\baru"
SCRATCH_DIR = r"C:\SAVING\GAWEAN GW\Capstone-Project\BuildHaus\scratch_generated"
os.makedirs(OUT_DIR, exist_ok=True)
os.makedirs(SCRATCH_DIR, exist_ok=True)

def convert_docx_to_pdf(docx_path, pdf_path):
    word = win32com.client.Dispatch('Word.Application')
    word.Visible = False
    try:
        doc = word.Documents.Open(os.path.abspath(docx_path))
        doc.SaveAs(os.path.abspath(pdf_path), FileFormat=17) # 17 = wdFormatPDF
        doc.Close()
    finally:
        word.Quit()
    print(f"Exported PDF: {pdf_path}")

# ==============================================================================
# 1. PRD DOCUMENT GENERATOR
# ==============================================================================
def generate_prd():
    print("Generating PRD_BuildHaus_v2...")
    doc = Document()
    
    # Configure 0.5 inch margins for perfect fit on Letter/A4
    for section in doc.sections:
        section.top_margin = Inches(0.5)
        section.bottom_margin = Inches(0.5)
        section.left_margin = Inches(0.5)
        section.right_margin = Inches(0.5)
        section.page_width = Inches(8.5)
        section.page_height = Inches(11.0)
        
    pages = [
        {
            "num": "01",
            "title": "Beranda",
            "subtitle": "Cockpit telemetri kendaraan, status motor utama, dan pintasan aksi cepat",
            "img": os.path.join(ARTIFACTS_DIR, "emulator_screen_1.png")
        },
        {
            "num": "02",
            "title": "Kesehatan Motor",
            "subtitle": "Telemetri skor kesehatan unit, masa pembelajaran odo, dan status 14 komponen",
            "img": os.path.join(ARTIFACTS_DIR, "emulator_screen_health3.png")
        },
        {
            "num": "03",
            "title": "Pemeriksaan Mandiri",
            "subtitle": "Kuesioner pemeriksaan fisik 8 komponen interaktif dengan navigasi responsif",
            "img": os.path.join(ARTIFACTS_DIR, "emulator_screen_back.png")
        },
        {
            "num": "04",
            "title": "Katalog Sparepart",
            "subtitle": "Rekomendasi suku cadang original Honda/Yamaha berdasarkan budget & kesehatan",
            "img": os.path.join(ARTIFACTS_DIR, "cyber_parts_screen.png")
        },
        {
            "num": "05",
            "title": "Konsultasi Keluhan AI",
            "subtitle": "Asisten cerdas Google Gemini 2.5 Flash untuk analisis keluhan motor secara real-time",
            "img": os.path.join(ARTIFACTS_DIR, "cyber_chat_screen.png")
        },
        {
            "num": "06",
            "title": "Akun & Garasi Motor",
            "subtitle": "Manajemen profil pengguna, garasi multi-motor, dan keamanan data telemetri",
            "img": os.path.join(ARTIFACTS_DIR, "emulator_screen_account.png")
        }
    ]

    for i, p in enumerate(pages):
        if i > 0:
            doc.add_page_break()

        # Header tag
        p_head = doc.add_paragraph()
        p_head.alignment = WD_ALIGN_PARAGRAPH.RIGHT
        p_head.paragraph_format.space_before = Pt(4)
        p_head.paragraph_format.space_after = Pt(8)
        run_head = p_head.add_run("BUILDHAUS / DOKUMENTASI TAMPILAN")
        run_head.font.size = Pt(8.5)
        run_head.font.bold = True
        run_head.font.color.rgb = RGBColor(113, 128, 150)

        # Title
        p_title = doc.add_paragraph()
        p_title.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_title.paragraph_format.space_before = Pt(0)
        p_title.paragraph_format.space_after = Pt(2)
        run_title = p_title.add_run(f"{p['num']}  |  {p['title']}")
        run_title.font.size = Pt(16)
        run_title.font.bold = True
        run_title.font.color.rgb = RGBColor(26, 32, 44)

        # Subtitle
        p_sub = doc.add_paragraph()
        p_sub.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_sub.paragraph_format.space_before = Pt(0)
        p_sub.paragraph_format.space_after = Pt(14)
        run_sub = p_sub.add_run(p['subtitle'])
        run_sub.font.size = Pt(10)
        run_sub.font.color.rgb = RGBColor(113, 128, 150)

        # Image centered
        p_img = doc.add_paragraph()
        p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_img.paragraph_format.space_before = Pt(0)
        p_img.paragraph_format.space_after = Pt(12)
        run_img = p_img.add_run()
        run_img.add_picture(p['img'], width=Inches(3.35))

        # Footer
        p_foot = doc.add_paragraph()
        p_foot.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_foot.paragraph_format.space_before = Pt(6)
        p_foot.paragraph_format.space_after = Pt(0)
        run_foot = p_foot.add_run("BuildHaus • Dokumentasi Antarmuka v2.0")
        run_foot.font.size = Pt(8)
        run_foot.font.color.rgb = RGBColor(160, 174, 192)

    docx_path = os.path.join(OUT_DIR, "PRD_BuildHaus_v2.docx")
    pdf_path = os.path.join(OUT_DIR, "PRD_BuildHaus_v2.docx.pdf")
    doc.save(docx_path)
    print(f"Saved: {docx_path}")
    convert_docx_to_pdf(docx_path, pdf_path)

# ==============================================================================
# 2. USER FLOW GENERATOR
# ==============================================================================
def generate_user_flow():
    print("Generating USER_FLOW_v2...")
    fig, ax = plt.subplots(figsize=(16, 16), facecolor="#090D14")
    ax.set_facecolor("#090D14")
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 100)
    ax.axis('off')

    # Title
    ax.text(50, 95, "USER FLOW - BUILDHAUS v2.0", fontsize=24, fontweight='bold',
            color='#F1F5F9', ha='center', va='center', fontfamily='sans-serif')
    ax.text(50, 92, "Alur Pengalaman Pengguna (Mahasiswa & Rider Harian)", fontsize=13,
            color='#00F5A0', ha='center', va='center', fontfamily='sans-serif')

    def draw_box(x, y, w, h, text, subtext="", border_col="#334155", bg_col="#131D2B", text_col="#F1F5F9", is_diamond=False):
        if is_diamond:
            diamond = patches.Polygon([
                [x, y + h/2],
                [x + w/2, y + h],
                [x + w, y + h/2],
                [x + w/2, y]
            ], closed=True, facecolor=bg_col, edgecolor=border_col, linewidth=2.2, zorder=3)
            ax.add_patch(diamond)
            cx, cy = x + w/2, y + h/2
            ax.text(cx, cy, text, fontsize=10.5, fontweight='bold', color=text_col, ha='center', va='center', zorder=4)
        else:
            box = patches.FancyBboxPatch(
                (x, y), w, h,
                boxstyle="round,pad=0.5,rounding_size=1.2",
                facecolor=bg_col, edgecolor=border_col, linewidth=2.0, zorder=3
            )
            ax.add_patch(box)
            cx, cy = x + w/2, y + h/2
            if subtext:
                ax.text(cx, cy + 1.2, text, fontsize=10.5, fontweight='bold', color=text_col, ha='center', va='center', zorder=4)
                ax.text(cx, cy - 1.4, subtext, fontsize=8.5, color="#94A3B8", ha='center', va='center', zorder=4)
            else:
                ax.text(cx, cy, text, fontsize=10.5, fontweight='bold', color=text_col, ha='center', va='center', zorder=4)

    def draw_arrow(x1, y1, x2, y2, label="", color="#00F5A0", style="->"):
        ax.annotate('', xy=(x2, y2), xytext=(x1, y1),
                    arrowprops=dict(arrowstyle="-|>", color=color, lw=2.2, mutation_scale=15), zorder=2)
        if label:
            mx, my = (x1 + x2)/2, (y1 + y2)/2
            ax.text(mx, my + 1.2, label, fontsize=9, fontweight='bold', color=color, ha='center', va='center',
                    bbox=dict(boxstyle="round,pad=0.2", facecolor="#090D14", edgecolor="none"))

    # ROW 1 (y = 78 to 82): Start & Registrasi
    # Mahasiswa Pill
    draw_box(4, 76, 14, 8, "MAHASISWA", "User Persona", border_col="#00F5A0", bg_col="#0F291E", text_col="#00F5A0")
    draw_arrow(18, 80, 23, 80)

    # Start Circle
    circle = patches.Circle((27, 80), 4, facecolor="#1E293B", edgecolor="#00F5A0", linewidth=2.2, zorder=3)
    ax.add_patch(circle)
    ax.text(27, 80, "START", fontsize=9.5, fontweight='bold', color="#00F5A0", ha='center', va='center', zorder=4)
    draw_arrow(31, 80, 36, 80)

    # Login
    draw_box(36, 76, 16, 8, "LOGIN / MASUK", "Pre-filled Credential")
    draw_arrow(52, 80, 57, 80)

    # Tambah Motor
    draw_box(57, 76, 18, 8, "TAMBAH MOTOR", "Merek, Model, Tahun")
    draw_arrow(75, 80, 80, 80)

    # Input Odometer
    draw_box(80, 76, 16, 8, "INPUT ODOMETER", "Kilometer Saat Ini")

    # Connect Row 1 to Row 2
    # Arrow downwards from Input Odometer to Auto-Redirect
    ax.plot([88, 88], [76, 68], color="#00F5A0", lw=2.2, zorder=2)
    ax.plot([88, 12], [68, 68], color="#00F5A0", lw=2.2, zorder=2)
    ax.annotate('', xy=(12, 62), xytext=(12, 68),
                arrowprops=dict(arrowstyle="-|>", color="#00F5A0", lw=2.2, mutation_scale=15), zorder=2)
    ax.text(50, 69.5, "OTOMATIS DIARAHKAN (AUTO-REDIRECT)", fontsize=9, fontweight='bold', color="#00F5A0", ha='center',
            bbox=dict(boxstyle="round,pad=0.2", facecolor="#090D14", edgecolor="none"))

    # ROW 2 (y = 54 to 62): Uji Mandiri & Dashboard
    # Uji Mandiri 8 Soal
    draw_box(4, 54, 18, 8, "UJI MANDIRI FISIK", "8 Pertanyaan Interaktif", border_col="#00F5A0", bg_col="#0F291E", text_col="#00F5A0")
    draw_arrow(22, 58, 27, 58)

    # Hitung Skor Unit
    draw_box(27, 54, 18, 8, "HITUNG SKOR UNIT", "Algoritma SQLite (0-100)")
    draw_arrow(45, 58, 50, 58)

    # Dashboard Cockpit
    draw_box(50, 54, 18, 8, "COCKPIT BERANDA", "Ring Status & 14 Komponen")
    draw_arrow(68, 58, 74, 58)

    # Decision: Ada Keluhan?
    draw_box(74, 53, 20, 10, "ADA\nKELUHAN?", is_diamond=True, border_col="#F59E0B", bg_col="#241B08", text_col="#F59E0B")

    # If IYA -> Connect downwards to AI Konsultasi
    ax.plot([84, 84], [53, 44], color="#EF4444", lw=2.2, zorder=2)
    ax.annotate('', xy=(84, 38), xytext=(84, 44),
                arrowprops=dict(arrowstyle="-|>", color="#EF4444", lw=2.2, mutation_scale=15), zorder=2)
    ax.text(85.5, 46, "IYA", fontsize=9.5, fontweight='bold', color="#EF4444")

    # If TIDAK -> Connect directly to Budget / Suku Cadang
    ax.plot([74, 50], [58, 58], color="#00F5A0", lw=0) # dummy
    ax.plot([84, 97], [58, 58], color="#10B981", lw=2.2, zorder=2)
    ax.plot([97, 97], [58, 20], color="#10B981", lw=2.2, zorder=2)
    ax.plot([97, 85], [20, 20], color="#10B981", lw=2.2, zorder=2)
    ax.annotate('', xy=(85, 20), xytext=(88, 20),
                arrowprops=dict(arrowstyle="-|>", color="#10B981", lw=2.2, mutation_scale=15), zorder=2)
    ax.text(94, 59.5, "TIDAK", fontsize=9.5, fontweight='bold', color="#10B981")

    # ROW 3 (y = 30 to 38): AI Diagnosis
    draw_box(72, 30, 24, 8, "KONSULTASI AI GEMINI", "Multi-turn Chat & Diagnosa", border_col="#38BDF8", bg_col="#0C2338", text_col="#38BDF8")
    draw_arrow(72, 34, 58, 34)

    draw_box(38, 30, 20, 8, "ESTIMASI BIAYA & PART", "Prioritas Ganti vs Tunda")
    draw_arrow(38, 34, 24, 34)

    draw_box(4, 30, 20, 8, "ALOKASI BUDGET", "Filter Ambang Batas Dompet")

    # Connect Row 3 to Row 4
    ax.plot([14, 14], [30, 24], color="#00F5A0", lw=2.2, zorder=2)
    ax.plot([14, 14], [24, 20], color="#00F5A0", lw=2.2, zorder=2)
    ax.annotate('', xy=(24, 20), xytext=(14, 20),
                arrowprops=dict(arrowstyle="-|>", color="#00F5A0", lw=2.2, mutation_scale=15), zorder=2)

    # ROW 4 (y = 16 to 24): Katalog & Servis & Selesai
    draw_box(24, 16, 22, 8, "KATALOG SPAREPART", "Original Honda/Yamaha")
    draw_arrow(46, 20, 52, 20)

    draw_box(52, 16, 20, 8, "LOGBOOK SERVIS", "Catat Servis & Riwayat")
    draw_arrow(72, 20, 78, 20)

    # Selesai Pill
    draw_box(78, 16, 16, 8, "MOTOR PRIMA", "SELESAI", border_col="#00F5A0", bg_col="#0F291E", text_col="#00F5A0")

    # Clean borders
    rect_frame = patches.Rectangle((2, 2), 96, 96, fill=False, edgecolor="#1E293B", linewidth=2.5)
    ax.add_patch(rect_frame)

    user_flow_img = os.path.join(SCRATCH_DIR, "user_flow_v2.png")
    plt.tight_layout()
    plt.savefig(user_flow_img, dpi=300, facecolor=fig.get_facecolor(), bbox_inches='tight')
    plt.close()
    print(f"Rendered User Flow: {user_flow_img}")

    # Build DOCX
    doc = Document()
    for section in doc.sections:
        section.top_margin = Inches(0.5)
        section.bottom_margin = Inches(0.5)
        section.left_margin = Inches(0.5)
        section.right_margin = Inches(0.5)
        section.page_width = Inches(8.5)
        section.page_height = Inches(11.0)

    p_head = doc.add_paragraph()
    p_head.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    run_head = p_head.add_run("BUILDHAUS / DIAGRAM ARSITEKTUR UX")
    run_head.font.size = Pt(8.5)
    run_head.font.bold = True
    run_head.font.color.rgb = RGBColor(113, 128, 150)

    p_title = doc.add_paragraph()
    p_title.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_title.paragraph_format.space_after = Pt(2)
    run_title = p_title.add_run("USER FLOW - BUILDHAUS v2.0")
    run_title.font.size = Pt(18)
    run_title.font.bold = True
    run_title.font.color.rgb = RGBColor(26, 32, 44)

    p_sub = doc.add_paragraph()
    p_sub.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_sub.paragraph_format.space_after = Pt(14)
    run_sub = p_sub.add_run("Diagram alur lengkap proses registrasi kendaraan, uji mandiri fisik, telemetri kesehatan, hingga diagnosa Gemini AI.")
    run_sub.font.size = Pt(9.5)
    run_sub.font.color.rgb = RGBColor(113, 128, 150)

    p_img = doc.add_paragraph()
    p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run_img = p_img.add_run()
    run_img.add_picture(user_flow_img, width=Inches(7.2))

    p_foot = doc.add_paragraph()
    p_foot.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_foot.paragraph_format.space_before = Pt(8)
    run_foot = p_foot.add_run("BuildHaus • User Flow v2.0")
    run_foot.font.size = Pt(8)
    run_foot.font.color.rgb = RGBColor(160, 174, 192)

    docx_path = os.path.join(OUT_DIR, "USER_FLOW_v2.docx")
    pdf_path = os.path.join(OUT_DIR, "USER_FLOW_v2.docx.pdf")
    doc.save(docx_path)
    print(f"Saved: {docx_path}")
    convert_docx_to_pdf(docx_path, pdf_path)

# ==============================================================================
# 3. CRAZY 8 GENERATOR
# ==============================================================================
def generate_crazy_8():
    print("Generating Crazy_8_v2...")
    fig, axes = plt.subplots(4, 2, figsize=(16, 17.5), facecolor="#090D14")
    fig.subplots_adjust(hspace=0.22, wspace=0.14, top=0.94, bottom=0.03, left=0.05, right=0.95)

    fig.suptitle("CRAZY 8s — RAPID IDEATION SKETCHES (BUILDHAUS v2.0)",
                 fontsize=18, fontweight='bold', color='#F1F5F9', fontfamily='sans-serif')

    panels = [
        ("KOTAK 1: ONBOARDING & REGISTRASI MOTOR", [
            "[ Form Tambah Motor Baru ]",
            "• Merek: [ Honda v ]   Tahun: [ 2022 v ]",
            "• Model: [ Vario 160 (CBS-ISS) v ]",
            "• Odometer: [ 14.500 km ]",
            "• Profil Pemakaian: [ Harian Dalam Kota v ]",
            "[ Tombol: Simpan & Lanjut Cek Fisik -> ]"
        ]),
        ("KOTAK 2: COCKPIT TELEMETRI & BERANDA", [
            "[ Header: Halo, Aiman | Malam ]",
            "• Motor Aktif: Honda arjuna (2022)",
            "• Telemetri Odometer: 14,500 km [ Update ]",
            "• Quick Action: [Kesehatan] [Konsultasi AI]",
            "• Kartu Pintasan Servis Terdekat & Edukasi",
            "[ Bottom Nav: Beranda | Sehat | Part | Akun ]"
        ]),
        ("KOTAK 3: UJI MANDIRI FISIK (8 SOAL)", [
            "[ Progress: Pertanyaan 1 dari 8 (Pengereman) ]",
            "\"Bagaimana respons daya cengkeram rem Anda?\"",
            "(o) [V] Pakem dan merespons normal",
            "( ) [!] Kurang pakem / tuas ditarik dalam",
            "( ) [X] Rem blong / tidak menggigit sama sekali",
            "[ <- Kembali ]                [ Lanjut -> ]"
        ]),
        ("KOTAK 4: TELEMETRI SKOR KESEHATAN", [
            "[ Ring Gauge: 70/100 — KONDISI CUKUP ]",
            "• Telemetri estimasi keausan 14 komponen",
            "• Masa Pembelajaran Odometer (Periode 1/3 bln)",
            "• Kartu Komponen Kritis: Kampas Rem (Perhatian)",
            "[ Tombol Hijau: Uji Ulang Mandiri ]",
            "[ Kartu: AI Rekomendasi Pintar ]"
        ]),
        ("KOTAK 5: KONSULTASI KELUHAN GEMINI AI", [
            "[ Header: AI Health Assistant (Gemini 2.5 Flash) ]",
            "User: \"Mesin bunyi kasar & tarikan awal gredek\"",
            "AI: \"Kemungkinan CVT aus / roller peyang.",
            "Estimasi perbaikan: Rp 120rb - Rp 180rb.",
            "Apakah getaran terasa di kecepatan rendah?\"",
            "[ Input Chat: Tanyakan keluhan motor... ] [Kirim]"
        ]),
        ("KOTAK 6: SMART BUDGET & SPAREPART ADVISOR", [
            "[ Input Budget: Rp 200.000 ]",
            "• Filter: [Semua] [Rekomendasi Budget] [Kesehatan]",
            "• Wajib Ganti: Oli Mesin SPX2 (Rp 68k)",
            "• Prioritas 2: Kampas Rem Depan (Rp 65k)",
            "• Total: Rp 133k | Sisa Budget Aman: Rp 67k",
            "• Part Ditunda: V-Belt (Masih 54% fit)"
        ]),
        ("KOTAK 7: KATALOG SUKU CADANG TERKURASI", [
            "[ Katalog Suku Cadang Resmi (Honda / AHM) ]",
            "• Filter otomatis hanya memunculkan part Vario 160",
            "• Foto real suku cadang & kode part resmi",
            "• Estimasi harga pasar terverifikasi",
            "• Tautan langsung ke bengkel resmi AHASS / Toko",
            "[ Beli Sekarang ]             [ Simpan Favorit ]"
        ]),
        ("KOTAK 8: DIGITAL SERVICE LOGBOOK & GARASI", [
            "[ Riwayat Servis Digital & Logbook ]",
            "• Total Servis: 12x  |  Total Biaya: Rp 1.2jt",
            "• Servis Terakhir: 17 Sep 2026 (AHASS Mitra)",
            "• Detail: Ganti Oli Mesin + Kampas Rem Depan",
            "• Multi-Motor: Honda Arjuna, Yamaha Aerox",
            "[ + Catat Servis Baru ]    [ Ekspor PDF ]"
        ])
    ]

    for idx, (title, lines) in enumerate(panels):
        row = idx // 2
        col = idx % 2
        ax = axes[row, col]
        ax.set_facecolor("#0F172A")
        ax.set_xlim(0, 10)
        ax.set_ylim(0, 10)
        ax.axis('off')

        # Card border
        border = patches.FancyBboxPatch((0.2, 0.2), 9.6, 9.6, boxstyle="round,pad=0.2,rounding_size=0.5",
                                        facecolor="#131D2B", edgecolor="#00F5A0" if idx in [2, 4] else "#334155",
                                        linewidth=1.8)
        ax.add_patch(border)

        # Header banner
        banner = patches.FancyBboxPatch((0.2, 8.4), 9.6, 1.4, boxstyle="round,pad=0.2,rounding_size=0.3",
                                        facecolor="#1E293B", edgecolor="none")
        ax.add_patch(banner)
        ax.text(5.0, 9.1, title, fontsize=10.5, fontweight='bold', color="#00F5A0" if idx in [2, 4] else "#F1F5F9",
                ha='center', va='center', fontfamily='sans-serif')

        # Content lines
        y_pos = 7.5
        for line in lines:
            if line.startswith("["):
                ax.text(0.8, y_pos, line, fontsize=9.2, fontweight='bold', color="#38BDF8", fontfamily='monospace')
            elif line.startswith("•") or line.startswith("(o)") or line.startswith("User:") or line.startswith("AI:"):
                ax.text(0.8, y_pos, line, fontsize=8.8, color="#E2E8F0", fontfamily='sans-serif')
            else:
                ax.text(0.8, y_pos, line, fontsize=8.2, color="#94A3B8", fontfamily='sans-serif')
            y_pos -= 1.15

    crazy_8_img = os.path.join(SCRATCH_DIR, "crazy_8_v2.png")
    plt.savefig(crazy_8_img, dpi=300, facecolor=fig.get_facecolor(), bbox_inches='tight')
    plt.close()
    print(f"Rendered Crazy 8s: {crazy_8_img}")

    # Build DOCX
    doc = Document()
    for section in doc.sections:
        section.top_margin = Inches(0.3)
        section.bottom_margin = Inches(0.3)
        section.left_margin = Inches(0.3)
        section.right_margin = Inches(0.3)
        section.page_width = Inches(8.5)
        section.page_height = Inches(11.0)

    p_head = doc.add_paragraph()
    p_head.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    p_head.paragraph_format.space_before = Pt(0)
    p_head.paragraph_format.space_after = Pt(2)
    run_head = p_head.add_run("BUILDHAUS / DESIGN SPRINT")
    run_head.font.size = Pt(8)
    run_head.font.bold = True
    run_head.font.color.rgb = RGBColor(113, 128, 150)

    p_title = doc.add_paragraph()
    p_title.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_title.paragraph_format.space_before = Pt(0)
    p_title.paragraph_format.space_after = Pt(2)
    run_title = p_title.add_run("CRAZY 8s — SKETSA SOLUSI CEPAT v2.0")
    run_title.font.size = Pt(15)
    run_title.font.bold = True
    run_title.font.color.rgb = RGBColor(26, 32, 44)

    p_sub = doc.add_paragraph()
    p_sub.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_sub.paragraph_format.space_before = Pt(0)
    p_sub.paragraph_format.space_after = Pt(6)
    run_sub = p_sub.add_run("8 panel visualisasi eksplorasi fitur inti arsitektur BuildHaus v2.0.")
    run_sub.font.size = Pt(8.5)
    run_sub.font.color.rgb = RGBColor(113, 128, 150)

    p_img = doc.add_paragraph()
    p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_img.paragraph_format.space_before = Pt(0)
    p_img.paragraph_format.space_after = Pt(4)
    run_img = p_img.add_run()
    run_img.add_picture(crazy_8_img, height=Inches(8.8))

    p_foot = doc.add_paragraph()
    p_foot.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_foot.paragraph_format.space_before = Pt(2)
    p_foot.paragraph_format.space_after = Pt(0)
    run_foot = p_foot.add_run("BuildHaus • Design Sprint Crazy 8s v2.0")
    run_foot.font.size = Pt(7.5)
    run_foot.font.color.rgb = RGBColor(160, 174, 192)

    docx_path = os.path.join(OUT_DIR, "Crazy_8_v2.docx")
    pdf_path = os.path.join(OUT_DIR, "Crazy_8_v2.docx.pdf")
    doc.save(docx_path)
    print(f"Saved: {docx_path}")
    convert_docx_to_pdf(docx_path, pdf_path)

# ==============================================================================
# 4. SKETSA SOLUSI GENERATOR
# ==============================================================================
def generate_sketsa_solusi():
    print("Generating Sketsa_Solusi_v2...")
    doc = Document()
    for section in doc.sections:
        section.top_margin = Inches(0.5)
        section.bottom_margin = Inches(0.5)
        section.left_margin = Inches(0.5)
        section.right_margin = Inches(0.5)
        section.page_width = Inches(8.5)
        section.page_height = Inches(11.0)

    p_head = doc.add_paragraph()
    p_head.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    run_head = p_head.add_run("BUILDHAUS / SKETSA SOLUSI")
    run_head.font.size = Pt(8.5)
    run_head.font.bold = True
    run_head.font.color.rgb = RGBColor(113, 128, 150)

    p_title = doc.add_paragraph()
    p_title.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_title.paragraph_format.space_after = Pt(2)
    run_title = p_title.add_run("SKETSA SOLUSI — 3 TAHAP UTAMA v2.0")
    run_title.font.size = Pt(17)
    run_title.font.bold = True
    run_title.font.color.rgb = RGBColor(26, 32, 44)

    p_sub = doc.add_paragraph()
    p_sub.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_sub.paragraph_format.space_after = Pt(14)
    run_sub = p_sub.add_run("Visualisasi 3 antarmuka kunci penyelesaian masalah perawatan motor: Telemetri Kesehatan, Pemeriksaan Mandiri, dan Rekomendasi Suku Cadang Sesuai Budget.")
    run_sub.font.size = Pt(9.5)
    run_sub.font.color.rgb = RGBColor(113, 128, 150)

    # 3-column table
    table = doc.add_table(rows=2, cols=3)
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    table.autofit = False

    screens = [
        ("Layar 1: Telemetri Kesehatan", os.path.join(ARTIFACTS_DIR, "emulator_screen_health3.png"),
         "Memantau skor kesehatan unit (70/100) dan masa pembelajaran odometer secara instan."),
        ("Layar 2: Pemeriksaan Mandiri", os.path.join(ARTIFACTS_DIR, "emulator_screen_back.png"),
         "8 aspek pertanyaan fisik terpandu dengan navigasi otomatis dan tombol lanjut responsif."),
        ("Layar 3: Katalog & Budget AI", os.path.join(ARTIFACTS_DIR, "cyber_parts_screen.png"),
         "Rekomendasi suku cadang original yang presisi berdasarkan merek/model dan anggaran.")
    ]

    for col_idx, (col_title, img_path, desc) in enumerate(screens):
        cell_img = table.cell(0, col_idx)
        cell_img.width = Inches(2.45)
        p = cell_img.paragraphs[0]
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p.paragraph_format.space_after = Pt(4)
        run_img = p.add_run()
        run_img.add_picture(img_path, width=Inches(2.35))

        cell_desc = table.cell(1, col_idx)
        cell_desc.width = Inches(2.45)
        p_desc = cell_desc.paragraphs[0]
        p_desc.alignment = WD_ALIGN_PARAGRAPH.CENTER
        run_t = p_desc.add_run(f"{col_title}\n")
        run_t.font.bold = True
        run_t.font.size = Pt(9.5)
        run_t.font.color.rgb = RGBColor(26, 32, 44)
        run_d = p_desc.add_run(desc)
        run_d.font.size = Pt(8.5)
        run_d.font.color.rgb = RGBColor(113, 128, 150)

    p_foot = doc.add_paragraph()
    p_foot.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_foot.paragraph_format.space_before = Pt(14)
    run_foot = p_foot.add_run("BuildHaus • Sketsa Solusi v2.0")
    run_foot.font.size = Pt(8)
    run_foot.font.color.rgb = RGBColor(160, 174, 192)

    docx_path = os.path.join(OUT_DIR, "Sketsa_Solusi_v2.docx")
    pdf_path = os.path.join(OUT_DIR, "Sketsa_Solusi_v2.docx.pdf")
    doc.save(docx_path)
    print(f"Saved: {docx_path}")
    convert_docx_to_pdf(docx_path, pdf_path)

# ==============================================================================
# 5. STORYBOARD GENERATOR
# ==============================================================================
def generate_storyboard():
    print("Generating Storyboard_v2...")
    fig, axes = plt.subplots(2, 3, figsize=(18, 13), facecolor="#090D14")
    fig.subplots_adjust(hspace=0.25, wspace=0.18, top=0.92, bottom=0.04, left=0.04, right=0.96)

    fig.suptitle("STORYBOARD NARATIF — USER JOURNEY SCENARIO (BUILDHAUS v2.0)",
                 fontsize=20, fontweight='bold', color='#F1F5F9', fontfamily='sans-serif')

    scenes = [
        ("SCENE 1: MASALAH AWAL",
         "Aiman (Mahasiswa) merasa rem motor Vario-nya berdecit keras dan tarikan awal terasa bergetar (gredek) saat dipakai kuliah.",
         "Aksi User:\n• Menyadari motor tidak nyaman\n• Khawatir biaya bengkel mahal\n• Membuka aplikasi BuildHaus",
         "Dampak Sistem:\n• Membuka layar login instan\n• Pre-filled akun demo Aiman",
         "#3B82F6"),
        ("SCENE 2: PENDAFTARAN MOTOR",
         "Aiman masuk ke akun dan menambahkan data motor Vario 160 beserta kilometer odometer saat ini (14.500 km).",
         "Aksi User:\n• Pilih Merek: Honda\n• Pilih Model: Vario 160\n• Masukkan Odometer: 14.500 km\n• Tekan [ Simpan Motor ]",
         "Dampak Sistem:\n• Data tersimpan offline di SQLite\n• Otomatis me-redirect ke Cek Fisik",
         "#10B981"),
        ("SCENE 3: PEMERIKSAAN MANDIRI",
         "Sistem langsung memandu Aiman menjawab 8 pertanyaan pemeriksaan fisik sederhana tanpa perlu alat bengkel.",
         "Aksi User:\n• Jawab rem berdecit: [ Aus/Gesek Logam ]\n• Jawab getaran CVT: [ Bergetar ]\n• Pertanyaan auto-advance lancar",
         "Dampak Sistem:\n• Merekam respons tiap komponen\n• Menghitung degradasi part",
         "#00F5A0"),
        ("SCENE 4: SKOR TELEMETRI KESEHATAN",
         "Aiman melihat skor kesehatan motornya 70/100 (CUKUP) dengan indikator visual kampas rem & roller CVT butuh perhatian.",
         "Aksi User:\n• Melihat skor ring gauge 70/100\n• Membaca detail komponen kritis\n• Mengklik [ Konsultasi AI ]",
         "Dampak Sistem:\n• Memberikan ringkasan risiko\n• Menyiapkan konteks motor ke AI",
         "#F59E0B"),
        ("SCENE 5: KONSULTASI GEMINI AI",
         "Aiman menanyakan keluhan gredek dan suara rem ke AI. Gemini 2.5 Flash menjelaskan penyebab mekanis dan solusinya.",
         "Aksi User:\n• Ketik keluhan / klik chip pintasan\n• Bertanya estimasi biaya servis\n• AI merekomendasikan cek kampas",
         "Dampak Sistem:\n• Respon cerdas real-time Cloud AI\n• Menyarankan sparepart pengganti",
         "#38BDF8"),
        ("SCENE 6: SPAREPART & LOGBOOK",
         "Aiman membuka katalog sparepart, memilih kampas rem resmi AHM sesuai budgetnya, lalu mencatatnya ke logbook.",
         "Aksi User:\n• Filter budget: Rp 200.000\n• Pilih Kampas Rem AHM (Rp 65k)\n• Catat riwayat perawatan\n• Motor kembali prima",
         "Dampak Sistem:\n• Menyimpan nota servis ke arsip\n• Merestart siklus interval servis",
         "#00F5A0")
    ]

    for idx, (title, narrative, aksi, dampak, col) in enumerate(scenes):
        row = idx // 3
        c = idx % 3
        ax = axes[row, c]
        ax.set_facecolor("#0F172A")
        ax.set_xlim(0, 10)
        ax.set_ylim(0, 10)
        ax.axis('off')

        # Outer card box
        card = patches.FancyBboxPatch((0.2, 0.2), 9.6, 9.6, boxstyle="round,pad=0.2,rounding_size=0.6",
                                     facecolor="#131D2B", edgecolor=col, linewidth=2.0)
        ax.add_patch(card)

        # Header title
        banner = patches.FancyBboxPatch((0.2, 8.4), 9.6, 1.4, boxstyle="round,pad=0.2,rounding_size=0.3",
                                        facecolor="#1E293B", edgecolor="none")
        ax.add_patch(banner)
        ax.text(5.0, 9.1, title, fontsize=11, fontweight='bold', color=col,
                ha='center', va='center', fontfamily='sans-serif')

        # Narrative box
        ax.text(0.6, 7.5, narrative, fontsize=8.8, color="#F1F5F9", fontfamily='sans-serif', wrap=True)

        # User action section
        ax.text(0.6, 5.0, "AKSI USER:", fontsize=8.5, fontweight='bold', color="#00F5A0", fontfamily='sans-serif')
        ax.text(0.6, 3.8, aksi, fontsize=8, color="#94A3B8", fontfamily='sans-serif')

        # System impact section
        ax.text(0.6, 2.0, "DAMPAK SISTEM:", fontsize=8.5, fontweight='bold', color="#38BDF8", fontfamily='sans-serif')
        ax.text(0.6, 1.1, dampak, fontsize=8, color="#94A3B8", fontfamily='sans-serif')

    storyboard_img = os.path.join(SCRATCH_DIR, "storyboard_v2.png")
    plt.savefig(storyboard_img, dpi=300, facecolor=fig.get_facecolor(), bbox_inches='tight')
    plt.close()
    print(f"Rendered Storyboard: {storyboard_img}")

    # Build DOCX
    doc = Document()
    for section in doc.sections:
        section.top_margin = Inches(0.4)
        section.bottom_margin = Inches(0.4)
        section.left_margin = Inches(0.4)
        section.right_margin = Inches(0.4)
        section.page_width = Inches(8.5)
        section.page_height = Inches(11.0)

    p_head = doc.add_paragraph()
    p_head.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    run_head = p_head.add_run("BUILDHAUS / STORYBOARD USER JOURNEY")
    run_head.font.size = Pt(8.5)
    run_head.font.bold = True
    run_head.font.color.rgb = RGBColor(113, 128, 150)

    p_title = doc.add_paragraph()
    p_title.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_title.paragraph_format.space_after = Pt(2)
    run_title = p_title.add_run("STORYBOARD — SKENARIO PENGGUNA v2.0")
    run_title.font.size = Pt(17)
    run_title.font.bold = True
    run_title.font.color.rgb = RGBColor(26, 32, 44)

    p_sub = doc.add_paragraph()
    p_sub.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_sub.paragraph_format.space_after = Pt(10)
    run_sub = p_sub.add_run("6 adegan narasi alur penyelesaian masalah motor dari keluhan hingga perbaikan sukses.")
    run_sub.font.size = Pt(9.5)
    run_sub.font.color.rgb = RGBColor(113, 128, 150)

    p_img = doc.add_paragraph()
    p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run_img = p_img.add_run()
    run_img.add_picture(storyboard_img, width=Inches(7.4))

    p_foot = doc.add_paragraph()
    p_foot.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_foot.paragraph_format.space_before = Pt(6)
    run_foot = p_foot.add_run("BuildHaus • Storyboard Scenario v2.0")
    run_foot.font.size = Pt(8)
    run_foot.font.color.rgb = RGBColor(160, 174, 192)

    docx_path = os.path.join(OUT_DIR, "Storyboard_v2.docx")
    pdf_path = os.path.join(OUT_DIR, "Storyboard_v2.docx.pdf")
    doc.save(docx_path)
    print(f"Saved: {docx_path}")
    convert_docx_to_pdf(docx_path, pdf_path)

# ==============================================================================
# 6. HEAT MAP & PRIORITY MATRIX GENERATOR
# ==============================================================================
def generate_heat_map():
    print("Generating Heat_Map_v2...")
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(18, 9), facecolor="#090D14")
    fig.subplots_adjust(wspace=0.2, top=0.88, bottom=0.08, left=0.06, right=0.94)

    fig.suptitle("HEAT MAP INTERAKSI & MATRIKS PRIORITAS FITUR (BUILDHAUS v2.0)",
                 fontsize=18, fontweight='bold', color='#F1F5F9', fontfamily='sans-serif')

    # LEFT: Visual Heat Map of Screen Engagement
    ax1.set_facecolor("#0F172A")
    ax1.set_title("Peta Titik Fokus & Interaksi Pengguna (Screen Heat Map)",
                  fontsize=13, fontweight='bold', color='#00F5A0', pad=14)
    ax1.set_xlim(0, 10)
    ax1.set_ylim(0, 14)
    ax1.axis('off')

    # Phone mockup container
    phone = patches.FancyBboxPatch((1.5, 0.5), 7.0, 13.0, boxstyle="round,pad=0.2,rounding_size=0.8",
                                  facecolor="#131D2B", edgecolor="#334155", linewidth=2.0)
    ax1.add_patch(phone)

    # Hotspot 1: Header & Motor Active (Cool)
    h1 = patches.FancyBboxPatch((2.0, 11.2), 6.0, 1.4, boxstyle="round,pad=0.1,rounding_size=0.3",
                               facecolor="#1E293B", edgecolor="#3B82F6", linewidth=1.2)
    ax1.add_patch(h1)
    ax1.text(5.0, 11.9, "Selector Motor & Profil [Cool]", fontsize=9, color="#94A3B8", ha='center', va='center')

    # Hotspot 2: Health Score Ring (HOT! Core Value)
    h2 = patches.FancyBboxPatch((2.0, 7.8), 6.0, 3.0, boxstyle="round,pad=0.1,rounding_size=0.4",
                               facecolor="#7F1D1D", edgecolor="#EF4444", linewidth=2.5) # Red Hot
    ax1.add_patch(h2)
    ax1.text(5.0, 9.6, "★ SKOR KESEHATAN UNIT (70/100)", fontsize=11, fontweight='bold', color="#FEF2F2", ha='center')
    ax1.text(5.0, 8.6, "ZONA PALING SERING DIKLIK (HOT)", fontsize=9, fontweight='bold', color="#FCA5A5", ha='center')

    # Hotspot 3: Tombol Uji Ulang (HOT!)
    h3 = patches.FancyBboxPatch((2.0, 6.2), 6.0, 1.2, boxstyle="round,pad=0.1,rounding_size=0.3",
                               facecolor="#B45309", edgecolor="#F59E0B", linewidth=2.0) # Warm / Hot
    ax1.add_patch(h3)
    ax1.text(5.0, 6.8, "Tombol Uji Mandiri Fisik [Very High]", fontsize=9.5, fontweight='bold', color="#FFFBEB", ha='center')

    # Hotspot 4: Konsultasi AI Quick Action (HOT!)
    h4 = patches.FancyBboxPatch((2.0, 4.2), 6.0, 1.6, boxstyle="round,pad=0.1,rounding_size=0.3",
                               facecolor="#7C2D12", edgecolor="#EA580C", linewidth=2.0) # Hot
    ax1.add_patch(h4)
    ax1.text(5.0, 5.2, "★ KONSULTASI KELUHAN AI GEMINI", fontsize=10, fontweight='bold', color="#FFEDD5", ha='center')
    ax1.text(5.0, 4.6, "Penyelesaian Kerusakan Interaktif", fontsize=8, color="#FDBA74", ha='center')

    # Hotspot 5: Rekomendasi Suku Cadang Sesuai Budget (WARM)
    h5 = patches.FancyBboxPatch((2.0, 2.2), 6.0, 1.6, boxstyle="round,pad=0.1,rounding_size=0.3",
                               facecolor="#1E3A8A", edgecolor="#3B82F6", linewidth=1.5) # Warm
    ax1.add_patch(h5)
    ax1.text(5.0, 3.2, "Katalog Sparepart & Filter Budget [Warm]", fontsize=9.5, fontweight='bold', color="#DBEAFE", ha='center')
    ax1.text(5.0, 2.6, "Transparansi Estimasi Biaya", fontsize=8, color="#93C5FD", ha='center')

    # Bottom Nav (Neutral)
    nav = patches.FancyBboxPatch((2.0, 0.8), 6.0, 1.0, boxstyle="round,pad=0.1,rounding_size=0.2",
                                facecolor="#0F172A", edgecolor="#334155", linewidth=1.0)
    ax1.add_patch(nav)
    ax1.text(5.0, 1.3, "Navigasi: Beranda | Sehat | Sparepart | Akun", fontsize=8, color="#64748B", ha='center')

    # RIGHT: Matriks Prioritas Fitur (Impact vs Feasibility)
    ax2.set_facecolor("#0F172A")
    ax2.set_title("Matriks Prioritas Fitur (Impact vs Feasibility)",
                  fontsize=13, fontweight='bold', color='#38BDF8', pad=14)
    ax2.set_xlim(0, 10)
    ax2.set_ylim(0, 10)
    ax2.set_xlabel("Feasibility (Kemudahan Implementasi / Stabilitas) ->", color="#94A3B8", fontsize=10, labelpad=10)
    ax2.set_ylabel("Impact Bagi Pengguna (Nilai Solusi Perawatan) ->", color="#94A3B8", fontsize=10, labelpad=10)
    ax2.tick_params(colors='#475569')
    ax2.grid(True, linestyle="--", alpha=0.3, color="#334155")

    # Quadrant lines
    ax2.axvline(5, color="#334155", linestyle=":", lw=1.5)
    ax2.axhline(5, color="#334155", linestyle=":", lw=1.5)

    # Quadrant Labels
    ax2.text(2.5, 9.4, "KUADRAN II: STRATEGIS", fontsize=8.5, color="#F59E0B", ha='center', fontweight='bold')
    ax2.text(7.5, 9.4, "KUADRAN I: FITUR UTAMA (CORE)", fontsize=8.5, color="#00F5A0", ha='center', fontweight='bold')
    ax2.text(2.5, 0.6, "KUADRAN IV: HINDARI / LOW", fontsize=8.5, color="#EF4444", ha='center', fontweight='bold')
    ax2.text(7.5, 0.6, "KUADRAN III: PENDUKUNG (NICE-TO-HAVE)", fontsize=8.5, color="#38BDF8", ha='center', fontweight='bold')

    # Scatter points of features
    feature_points = [
        ("Pemeriksaan Mandiri 8 Soal", 8.8, 9.0, "#00F5A0"),
        ("Telemetri Skor Unit (SQLite)", 8.2, 8.5, "#00F5A0"),
        ("Konsultasi AI Gemini 2.5", 7.2, 9.2, "#00F5A0"),
        ("Filter Sparepart per Model", 8.5, 7.8, "#00F5A0"),
        ("Auto-Redirect Tambah Motor", 9.2, 8.2, "#00F5A0"),
        ("Prediksi Odo AI Kompleks", 4.0, 7.5, "#F59E0B"),
        ("Scan OCR Nota Pembayaran", 3.5, 6.8, "#F59E0B"),
        ("Pemberitahuan Push Alarm", 7.8, 4.2, "#38BDF8"),
        ("Tema Gelap/Terang Otomatis", 8.9, 3.8, "#38BDF8"),
        ("Ekspor Riwayat ke PDF", 7.5, 4.5, "#38BDF8")
    ]

    for name, x, y, col in feature_points:
        ax2.scatter(x, y, color=col, s=120, zorder=4, edgecolors="#F1F5F9", linewidth=1.2)
        ax2.text(x, y + 0.35, name, fontsize=8.5, color="#F1F5F9", ha='center', fontweight='bold', zorder=5)

    heat_map_img = os.path.join(SCRATCH_DIR, "heat_map_v2.png")
    plt.savefig(heat_map_img, dpi=300, facecolor=fig.get_facecolor(), bbox_inches='tight')
    plt.close()
    print(f"Rendered Heat Map: {heat_map_img}")

    # Build DOCX
    doc = Document()
    for section in doc.sections:
        section.top_margin = Inches(0.4)
        section.bottom_margin = Inches(0.4)
        section.left_margin = Inches(0.4)
        section.right_margin = Inches(0.4)
        section.page_width = Inches(8.5)
        section.page_height = Inches(11.0)

    p_head = doc.add_paragraph()
    p_head.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    run_head = p_head.add_run("BUILDHAUS / ANALISIS UX & PRIORITAS")
    run_head.font.size = Pt(8.5)
    run_head.font.bold = True
    run_head.font.color.rgb = RGBColor(113, 128, 150)

    p_title = doc.add_paragraph()
    p_title.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_title.paragraph_format.space_after = Pt(2)
    run_title = p_title.add_run("HEAT MAP & MATRIKS PRIORITAS v2.0")
    run_title.font.size = Pt(17)
    run_title.font.bold = True
    run_title.font.color.rgb = RGBColor(26, 32, 44)

    p_sub = doc.add_paragraph()
    p_sub.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_sub.paragraph_format.space_after = Pt(10)
    run_sub = p_sub.add_run("Peta titik interaksi visual utama pengguna dan pemetaan prioritas fitur BuildHaus v2.0.")
    run_sub.font.size = Pt(9.5)
    run_sub.font.color.rgb = RGBColor(113, 128, 150)

    p_img = doc.add_paragraph()
    p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run_img = p_img.add_run()
    run_img.add_picture(heat_map_img, width=Inches(7.4))

    p_foot = doc.add_paragraph()
    p_foot.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_foot.paragraph_format.space_before = Pt(6)
    run_foot = p_foot.add_run("BuildHaus • Heat Map & Priority Matrix v2.0")
    run_foot.font.size = Pt(8)
    run_foot.font.color.rgb = RGBColor(160, 174, 192)

    docx_path = os.path.join(OUT_DIR, "Heat_Map_v2.docx")
    pdf_path = os.path.join(OUT_DIR, "Heat_Map_v2.docx.pdf")
    doc.save(docx_path)
    print(f"Saved: {docx_path}")
    convert_docx_to_pdf(docx_path, pdf_path)

if __name__ == "__main__":
    generate_prd()
    generate_user_flow()
    generate_crazy_8()
    generate_sketsa_solusi()
    generate_storyboard()
    generate_heat_map()
    print("\nALL 6 DESIGN DOCUMENTS SUCCESSFULLY GENERATED IN JOSJIS FOLDER!")
