import os
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT
import win32com.client
import gc

OUT_DIR = r"C:\SAVING\GAWEAN GW\Capstone-Project\JOSJIS\baru"
SCRATCH_DIR = r"C:\SAVING\GAWEAN GW\Capstone-Project\BuildHaus\scratch_generated"
os.makedirs(OUT_DIR, exist_ok=True)
os.makedirs(SCRATCH_DIR, exist_ok=True)

def draw_rounded_box(ax, x, y, w, h, text, box_type="action", subtitle=None):
    """
    Renders styled flowchart box:
    box_type: 'start_end', 'action', 'redirect', 'decision'
    """
    if box_type == "start_end":
        bg_col = "#0f2e22"
        edge_col = "#00f5a0"
        txt_col = "#00f5a0"
        corner_rad = 0.04
    elif box_type == "redirect":
        bg_col = "#2a1545"
        edge_col = "#c084fc"
        txt_col = "#f3e8ff"
        corner_rad = 0.02
    elif box_type == "decision":
        bg_col = "#332208"
        edge_col = "#f59e0b"
        txt_col = "#fef3c7"
        corner_rad = 0.02
    else: # action
        bg_col = "#132338"
        edge_col = "#38bdf8"
        txt_col = "#f0f9ff"
        corner_rad = 0.02

    # Draw rounded rectangle
    box = patches.FancyBboxPatch(
        (x - w/2, y - h/2), w, h,
        boxstyle=f"round,pad=0.012,rounding_size={corner_rad}",
        facecolor=bg_col, edgecolor=edge_col, linewidth=1.5, zorder=3
    )
    ax.add_patch(box)

    # Prefix icon/tag for redirect
    prefix = ""
    if box_type == "redirect":
        prefix = "⚡ "
    elif box_type == "decision":
        prefix = "❖ "

    # Main text
    full_text = prefix + text
    ax.text(x, y + (0.015 if subtitle else 0), full_text, ha='center', va='center',
            color=txt_col, fontsize=9.5, fontweight='bold', zorder=4,
            wrap=True)
    
    if subtitle:
        ax.text(x, y - 0.022, subtitle, ha='center', va='center',
                color="#94a3b8", fontsize=7.5, zorder=4)

def draw_arrow(ax, x1, y1, x2, y2, label=None, label_side="right"):
    ax.annotate(
        "", xy=(x2, y2), xytext=(x1, y1),
        arrowprops=dict(arrowstyle="-|>", color="#94a3b8", lw=1.6, mutation_scale=14),
        zorder=2
    )
    if label:
        lx = (x1 + x2) / 2 + (0.03 if label_side == "right" else -0.04)
        ly = (y1 + y2) / 2
        ax.text(lx, ly, label, color="#f59e0b" if "Tidak" in label or "Soal" in label else "#00f5a0",
                fontsize=8, fontweight='bold', ha='center', va='center',
                bbox=dict(boxstyle="round,pad=0.2", facecolor="#090d14", edgecolor="none", alpha=0.85),
                zorder=5)

def render_all_flowcharts():
    fig, axes = plt.subplots(4, 2, figsize=(18, 22), facecolor="#090d14")
    axes = axes.flatten()

    flows = [
        {
            "title": "1. Alur Masuk ke Aplikasi (Login)",
            "subtitle": "Proses otentikasi akun lokal dan navigasi ke beranda",
            "steps": [
                {"text": "Buka Aplikasi BuildHaus", "type": "start_end"},
                {"text": "Tampil Halaman Masuk (Login)", "type": "redirect"},
                {"text": "Pengguna Memasukkan Email & Kata Sandi", "type": "action"},
                {"text": "Klik Tombol 'Masuk'", "type": "action"},
                {"text": "Dialihkan ke Halaman Beranda", "type": "redirect"},
                {"text": "Pengguna Melihat Dashboard & Motor Aktif", "type": "start_end"}
            ]
        },
        {
            "title": "2. Alur Menambah Motor & Mulai Uji Mandiri",
            "subtitle": "Pendaftaran motor baru dengan auto-redirect ke uji mandiri",
            "steps": [
                {"text": "Di Beranda, Pengguna Klik '+ Tambah Motor'", "type": "start_end"},
                {"text": "Dialihkan ke Halaman Formulir Tambah Motor", "type": "redirect"},
                {"text": "Pengguna Mengisi Merek, Model, Plat, & Odometer", "type": "action"},
                {"text": "Klik Tombol 'Simpan Motor'", "type": "action"},
                {"text": "Otomatis Dialihkan ke Pemeriksaan Mandiri", "type": "redirect"},
                {"text": "Tampil Soal Pertama dari 8 Pertanyaan Fisik", "type": "start_end"}
            ]
        },
        {
            "title": "3. Alur Pemeriksaan Mandiri (8 Pertanyaan)",
            "subtitle": "Pemeriksaan fisik step-by-step dengan kalkulasi skor kesehatan",
            "custom": "inspection"
        },
        {
            "title": "4. Alur Tanya Keluhan Motor ke AI (Chatbot)",
            "subtitle": "Diagnosis cerdas masalah motor & rekomendasi suku cadang",
            "custom": "ai_chat"
        },
        {
            "title": "5. Alur Memperbarui Angka Kilometer (Odometer)",
            "subtitle": "Kalibrasi kilometer aktual untuk pembaruan jadwal servis",
            "steps": [
                {"text": "Di Beranda, Klik Tombol 'Update' pada Kartu Motor", "type": "start_end"},
                {"text": "Dialihkan ke Dialog Input Odometer", "type": "redirect"},
                {"text": "Pengguna Mengetik Angka Kilometer Terbaru", "type": "action"},
                {"text": "Klik Tombol 'Simpan'", "type": "action"},
                {"text": "Dialihkan Kembali ke Halaman Beranda", "type": "redirect"},
                {"text": "Kilometer & Sisa Usia Komponen Telah Terupdate", "type": "start_end"}
            ]
        },
        {
            "title": "6. Alur Mencari Suku Cadang (Katalog Sparepart)",
            "subtitle": "Eksplorasi sparepart resmi terverifikasi sesuai model motor",
            "steps": [
                {"text": "Di Menu Bawah, Pengguna Klik Tab 'Sparepart'", "type": "start_end"},
                {"text": "Dialihkan ke Halaman Katalog Sparepart", "type": "redirect"},
                {"text": "Pengguna Memilih Kategori Part / Ketik Pencarian", "type": "action"},
                {"text": "Klik Salah Satu Kartu Suku Cadang", "type": "action"},
                {"text": "Dialihkan ke Halaman Rincian Suku Cadang", "type": "redirect"},
                {"text": "Melihat Harga Resmi (HET), Kompatibilitas, & Spek", "type": "start_end"}
            ]
        },
        {
            "title": "7. Alur Mencatat Servis Motor (Riwayat Servis)",
            "subtitle": "Pencatatan nota servis untuk pemulihan skor kesehatan prima",
            "steps": [
                {"text": "Di Menu Bawah, Pengguna Klik Tab 'Riwayat'", "type": "start_end"},
                {"text": "Dialihkan ke Halaman Riwayat Servis", "type": "redirect"},
                {"text": "Pengguna Klik Tombol '+ Catat Servis'", "type": "action"},
                {"text": "Dialihkan ke Halaman Formulir Catat Servis", "type": "redirect"},
                {"text": "Pengguna Mengisi Jenis Servis, Biaya, & Tanggal", "type": "action"},
                {"text": "Klik Tombol 'Simpan Catatan'", "type": "action"},
                {"text": "Dialihkan Kembali ke Riwayat (Skor Ter-reset Prima)", "type": "start_end"}
            ]
        }
    ]

    for idx in range(8):
        ax = axes[idx]
        ax.set_facecolor("#0e1522")
        ax.set_xlim(0, 1)
        ax.set_ylim(0, 1)
        ax.axis('off')

        if idx >= len(flows):
            # Legend / Summary card
            ax.text(0.5, 0.88, "LEGENDA NOTASI FLOWCHART", ha='center', va='center',
                    color="#00f5a0", fontsize=13, fontweight='bold')
            ax.text(0.5, 0.82, "Simbol dan Makna pada Diagram Alur Pengguna", ha='center', va='center',
                    color="#94a3b8", fontsize=9.5)
            
            draw_rounded_box(ax, 0.5, 0.68, 0.75, 0.08, "Titik Awal / Akhir Sesi (Terminal)", "start_end", "Mulai atau selesainya suatu aktivitas pengguna")
            draw_rounded_box(ax, 0.5, 0.52, 0.75, 0.08, "Aksi Pengguna (User Action)", "action", "Interaksi pengguna (klik, ketik, pilih)")
            draw_rounded_box(ax, 0.5, 0.36, 0.75, 0.08, "Dialihkan ke Halaman... (Page Redirect)", "redirect", "Perpindahan layar atau tampilan yang dilihat pengguna")
            draw_rounded_box(ax, 0.5, 0.20, 0.75, 0.08, "Keputusan Pengguna (Decision)", "decision", "Pilihan percabangan aksi yang diambil pengguna")

            continue

        flow = flows[idx]
        # Title bar
        ax.text(0.5, 0.95, flow["title"], ha='center', va='center',
                color="#f1f5f9", fontsize=12.5, fontweight='bold')
        ax.text(0.5, 0.90, flow["subtitle"], ha='center', va='center',
                color="#64748b", fontsize=8.5)

        if "custom" in flow and flow["custom"] == "inspection":
            # Flow 3: Inspection with loop and decision
            draw_rounded_box(ax, 0.5, 0.82, 0.78, 0.065, "Di Halaman Pemeriksaan Mandiri", "start_end")
            draw_arrow(ax, 0.5, 0.785, 0.5, 0.735)

            draw_rounded_box(ax, 0.5, 0.70, 0.78, 0.065, "Pengguna Membaca Pertanyaan Komponen", "action")
            draw_arrow(ax, 0.5, 0.665, 0.5, 0.615)

            draw_rounded_box(ax, 0.5, 0.58, 0.78, 0.065, "Memilih Opsi Jawaban Sesuai Kondisi Fisik", "action")
            draw_arrow(ax, 0.5, 0.545, 0.5, 0.495)

            draw_rounded_box(ax, 0.5, 0.46, 0.78, 0.065, "Klik Tombol 'Lanjut'", "action")
            draw_arrow(ax, 0.5, 0.425, 0.5, 0.375)

            draw_rounded_box(ax, 0.5, 0.34, 0.78, 0.065, "Masih Ada Pertanyaan Berikutnya?", "decision")
            
            # Branch Yes (Masih Ada) -> loop left
            ax.plot([0.11, 0.11], [0.34, 0.70], color="#94a3b8", lw=1.5, zorder=2)
            draw_arrow(ax, 0.11, 0.70, 0.11, 0.70)
            ax.plot([0.11, 0.5 - 0.78/2], [0.34, 0.34], color="#94a3b8", lw=1.5, zorder=2)
            draw_arrow(ax, 0.11, 0.70, 0.5 - 0.78/2, 0.70, label="Masih Ada", label_side="right")

            # Branch No (Soal Terakhir) -> Down
            draw_arrow(ax, 0.5, 0.305, 0.5, 0.235, label="Soal Terakhir", label_side="right")
            draw_rounded_box(ax, 0.5, 0.20, 0.78, 0.065, "Klik Tombol 'Selesai & Hitung Skor'", "action")
            draw_arrow(ax, 0.5, 0.165, 0.5, 0.115)

            draw_rounded_box(ax, 0.5, 0.08, 0.78, 0.065, "Dialihkan ke Halaman Kesehatan Motor (Skor Muncul)", "redirect")

        elif "custom" in flow and flow["custom"] == "ai_chat":
            # Flow 4: AI Chat with choice
            draw_rounded_box(ax, 0.5, 0.83, 0.80, 0.065, "Di Halaman Beranda / Sehat, Klik 'Tanya AI'", "start_end")
            draw_arrow(ax, 0.5, 0.795, 0.5, 0.745)

            draw_rounded_box(ax, 0.5, 0.71, 0.80, 0.065, "Dialihkan ke Halaman Chat AI Riding Buddy", "redirect")
            draw_arrow(ax, 0.5, 0.675, 0.5, 0.625)

            draw_rounded_box(ax, 0.5, 0.59, 0.80, 0.065, "Pengguna Pilih Kasus Keluhan / Ketik Masalah", "action")
            draw_arrow(ax, 0.5, 0.555, 0.5, 0.505)

            draw_rounded_box(ax, 0.5, 0.47, 0.80, 0.065, "Klik 'Kirim' & Baca Solusi / Rekomendasi Part", "action")
            draw_arrow(ax, 0.5, 0.435, 0.5, 0.385)

            draw_rounded_box(ax, 0.5, 0.35, 0.80, 0.065, "Pengguna Ingin Memeriksa Sparepart Rekomendasi?", "decision")

            # Branch 1: Ya -> Cek sparepart
            draw_arrow(ax, 0.30, 0.315, 0.30, 0.225, label="Ya", label_side="right")
            draw_rounded_box(ax, 0.30, 0.19, 0.38, 0.065, "Klik 'Cek Sparepart'", "action")
            draw_arrow(ax, 0.30, 0.155, 0.30, 0.095)
            draw_rounded_box(ax, 0.30, 0.06, 0.38, 0.065, "Dialihkan ke Katalog", "redirect")

            # Branch 2: Tidak -> Selesai
            draw_arrow(ax, 0.70, 0.315, 0.70, 0.155, label="Tidak", label_side="right")
            draw_rounded_box(ax, 0.70, 0.12, 0.38, 0.065, "Selesai / Lanjut Chat", "start_end")

        else:
            # Linear steps
            steps = flow["steps"]
            y_start = 0.82
            y_gap = 0.14
            for s_idx, step in enumerate(steps):
                sy = y_start - s_idx * y_gap
                draw_rounded_box(ax, 0.5, sy, 0.82, 0.065, step["text"], step["type"])
                if s_idx < len(steps) - 1:
                    draw_arrow(ax, 0.5, sy - 0.033, 0.5, sy - y_gap + 0.033)

    plt.tight_layout(pad=2.5)
    img_path = os.path.join(SCRATCH_DIR, "flowchart_kegiatan_user_master.png")
    plt.savefig(img_path, dpi=200, facecolor=fig.get_facecolor(), edgecolor='none')
    plt.close()
    print(f"Master Flowchart Image Saved: {img_path}")
    return img_path

def build_word_and_pdf_doc(img_path):
    doc = Document()

    # Page setup - A4 Portrait with 0.5 inch margins for maximal diagram presentation
    for s in doc.sections:
        s.page_width = Inches(8.27)
        s.page_height = Inches(11.69)
        s.top_margin = Inches(0.5)
        s.bottom_margin = Inches(0.5)
        s.left_margin = Inches(0.5)
        s.right_margin = Inches(0.5)

    # Title
    p_title = doc.add_paragraph()
    p_title.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_title.paragraph_format.space_before = Pt(0)
    p_title.paragraph_format.space_after = Pt(2)
    run_t = p_title.add_run("USER FLOW — FLOWCHART KEGIATAN PENGGUNA")
    run_t.font.name = "Arial"
    run_t.font.size = Pt(16)
    run_t.font.bold = True
    run_t.font.color.rgb = RGBColor(0, 168, 107)

    # Subtitle
    p_sub = doc.add_paragraph()
    p_sub.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_sub.paragraph_format.space_before = Pt(0)
    p_sub.paragraph_format.space_after = Pt(8)
    run_s = p_sub.add_run("BuildHaus v2.0 • Diagram Alur Navigasi & Perpindahan Layar Lengkap Pengguna")
    run_s.font.name = "Arial"
    run_s.font.size = Pt(9.5)
    run_s.font.color.rgb = RGBColor(100, 116, 139)

    # Add master high-res image
    p_img = doc.add_paragraph()
    p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_img.paragraph_format.space_before = Pt(0)
    p_img.paragraph_format.space_after = Pt(6)
    run_img = p_img.add_run()
    run_img.add_picture(img_path, width=Inches(7.2))

    # Footer note
    p_foot = doc.add_paragraph()
    p_foot.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_foot.paragraph_format.space_before = Pt(4)
    p_foot.paragraph_format.space_after = Pt(0)
    run_f = p_foot.add_run("Dokumentasi Resmi Alur Pengguna (User Flow) • Capstone Project BuildHaus 2026")
    run_f.font.name = "Arial"
    run_f.font.size = Pt(8)
    run_f.font.color.rgb = RGBColor(148, 163, 184)

    # Save ONLY 1 PDF FILE in folder baru
    temp_docx = os.path.join(SCRATCH_DIR, "temp_user_flow.docx")
    final_pdf_path = os.path.join(OUT_DIR, "USER FLOW.docx.pdf")
    doc.save(temp_docx)
    print(f"Temporary docx saved: {temp_docx}")

    # Convert to PDF via Word COM
    word = win32com.client.DispatchEx("Word.Application")
    word.Visible = False
    word.DisplayAlerts = False
    try:
        wdoc = word.Documents.Open(os.path.abspath(temp_docx))
        wdoc.SaveAs2(os.path.abspath(final_pdf_path), FileFormat=17) # 17 = wdFormatPDF
        wdoc.Close()
        print(f"SUCCESS! Exported 1 Single File in folder baru: {final_pdf_path}")
    finally:
        word.Quit()
        del word
        gc.collect()

if __name__ == "__main__":
    img = render_all_flowcharts()
    build_word_and_pdf_doc(img)
