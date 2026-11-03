import os
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
import win32com.client
import gc

OUT_DIR = r"C:\SAVING\GAWEAN GW\Capstone-Project\JOSJIS\baru"
SCRATCH_DIR = r"C:\SAVING\GAWEAN GW\Capstone-Project\BuildHaus\scratch_generated"
os.makedirs(OUT_DIR, exist_ok=True)
os.makedirs(SCRATCH_DIR, exist_ok=True)

def draw_box(ax, x, y, w, h, text, is_redirect=False, is_role=False, font_size=10.5):
    bg = "#182433" if not is_redirect else "#24173d"
    border = "#38bdf8" if not is_redirect else "#c084fc"
    txt_color = "#ffffff" if not is_redirect else "#f3e8ff"

    if is_role:
        bg = "#111c2a"
        border = "#2a3e57"
        txt_color = "#94a3b8"

    box = patches.Rectangle(
        (x - w/2, y - h/2), w, h,
        facecolor=bg, edgecolor=border, lw=2.2, zorder=3
    )
    ax.add_patch(box)

    ax.text(x, y, text, ha='center', va='center', color=txt_color,
            fontsize=font_size, fontweight='bold', fontfamily='sans-serif', zorder=4)

def draw_circle(ax, x, y, r, text, font_size=11):
    circle = patches.Circle(
        (x, y), r, facecolor="#132333", edgecolor="#38bdf8", lw=2.2, zorder=3
    )
    ax.add_patch(circle)
    ax.text(x, y, text, ha='center', va='center', color="#ffffff",
            fontsize=font_size, fontweight='bold', fontfamily='sans-serif', zorder=4)

def draw_diamond(ax, x, y, w, h, text, font_size=9.5):
    pts = [[x, y + h/2], [x + w/2, y], [x, y - h/2], [x - w/2, y]]
    poly = patches.Polygon(pts, facecolor="#1a271c", edgecolor="#00f5a0", lw=2.2, zorder=3)
    ax.add_patch(poly)
    ax.text(x, y, text, ha='center', va='center', color="#ffffff",
            fontsize=font_size, fontweight='bold', fontfamily='sans-serif', zorder=4)

def draw_arrow(ax, pts, label=None, label_pos=None):
    xs, ys = zip(*pts)
    ax.plot(xs, ys, color="#94a3b8", lw=2.2, zorder=2)
    x1, y1 = pts[-2]
    x2, y2 = pts[-1]
    dx = x2 - x1
    dy = y2 - y1
    length = (dx**2 + dy**2)**0.5
    if length > 0:
        ax.annotate("", xy=(x2, y2), xytext=(x2 - (dx/length)*10, y2 - (dy/length)*10),
                    arrowprops=dict(arrowstyle="-|>", color="#94a3b8", lw=2.2, mutation_scale=18),
                    zorder=2)
    if label:
        lx = label_pos[0] if label_pos else (x1 + x2)/2
        ly = label_pos[1] if label_pos else (y1 + y2)/2
        ax.text(lx, ly, label, color="#00f5a0" if "IYA" in label or "Masih" in label else "#f59e0b",
                fontsize=10, fontweight='bold', fontfamily='sans-serif',
                bbox=dict(boxstyle="square,pad=0.2", facecolor="#0e1620", edgecolor="none"),
                zorder=5)

# ==============================================================================
# PAGE 1: FITUR 1 (LOGIN) & FITUR 2 (TAMBAH MOTOR)
# ==============================================================================
def render_page1_image():
    fig, ax = plt.subplots(figsize=(15, 10.5), facecolor="#0e1620")
    ax.set_facecolor("#0e1620")
    ax.set_xlim(0, 1500)
    ax.set_ylim(0, 1050)
    ax.axis('off')

    rect_outer = patches.Rectangle((20, 20), 1460, 1010, fill=False, edgecolor="#1e2c3d", lw=1.8, zorder=1)
    ax.add_patch(rect_outer)
    ax.plot([20, 1480], [525, 525], color="#1e2c3d", lw=1.5, zorder=1)

    # --- FITUR 1: LOGIN (Y ≈ 780) ---
    ax.text(80, 970, "FITUR 1: ALUR MASUK KE APLIKASI (LOGIN)", color="#38bdf8", fontsize=15, fontweight='bold')

    draw_box(ax, 110, 870, 130, 60, "PENGGUNA", is_role=True, font_size=11)
    draw_arrow(ax, [[110, 840], [110, 785]])

    draw_circle(ax, 110, 730, 50, "START")
    draw_arrow(ax, [[160, 730], [230, 730]])

    draw_box(ax, 320, 730, 170, 80, "MASUKKAN\nEMAIL & SANDI", font_size=11)
    draw_arrow(ax, [[405, 730], [475, 730]])

    draw_box(ax, 555, 730, 150, 80, "KLIK TOMBOL\n'MASUK'", font_size=11)
    draw_arrow(ax, [[630, 730], [700, 730]])

    draw_box(ax, 825, 730, 230, 80, "DIALIHKAN KE\nHALAMAN BERANDA", is_redirect=True, font_size=11)
    draw_arrow(ax, [[940, 730], [1010, 730]])

    draw_box(ax, 1135, 730, 230, 80, "PENGGUNA MELIHAT\nDASHBOARD GARASI", font_size=11)
    draw_arrow(ax, [[1250, 730], [1320, 730]])

    draw_circle(ax, 1375, 730, 50, "SELESAI")

    # --- FITUR 2: TAMBAH MOTOR & REDIRECT (Y ≈ 260) ---
    ax.text(80, 460, "FITUR 2: ALUR MENAMBAH MOTOR BARU (DENGAN AUTO-REDIRECT)", color="#38bdf8", fontsize=15, fontweight='bold')

    draw_circle(ax, 110, 260, 50, "START")
    draw_arrow(ax, [[160, 260], [230, 260]])

    draw_box(ax, 335, 260, 200, 80, "DI BERANDA, KLIK\n'+ TAMBAH MOTOR'", font_size=11)
    draw_arrow(ax, [[435, 260], [505, 260]])

    draw_box(ax, 620, 260, 220, 80, "DIALIHKAN KE\nFORM TAMBAH MOTOR", is_redirect=True, font_size=11)
    draw_arrow(ax, [[730, 260], [800, 260]])

    draw_box(ax, 915, 260, 220, 80, "ISI DATA MOTOR\n(HONDA/YAMAHA & ODO)", font_size=11)
    draw_arrow(ax, [[1025, 260], [1095, 260]])

    draw_box(ax, 1195, 260, 190, 80, "KLIK TOMBOL\n'SIMPAN MOTOR'", font_size=11)
    draw_arrow(ax, [[1290, 260], [1340, 260]])

    draw_box(ax, 1410, 260, 130, 80, "OTOMATIS\nDIALIHKAN KE\nUJI MANDIRI", is_redirect=True, font_size=9.5)

    img_path = os.path.join(SCRATCH_DIR, "flowchart_p1_login_addmotor.png")
    plt.tight_layout()
    plt.savefig(img_path, dpi=200, facecolor=fig.get_facecolor(), edgecolor='none', bbox_inches='tight')
    plt.close()
    return img_path

# ==============================================================================
# PAGE 2: FITUR 3: PEMERIKSAAN MANDIRI (8-TITIK FISIK)
# ==============================================================================
def render_page2_image():
    fig, ax = plt.subplots(figsize=(15, 10.5), facecolor="#0e1620")
    ax.set_facecolor("#0e1620")
    ax.set_xlim(0, 1500)
    ax.set_ylim(0, 1050)
    ax.axis('off')

    rect_outer = patches.Rectangle((20, 20), 1460, 1010, fill=False, edgecolor="#1e2c3d", lw=1.8, zorder=1)
    ax.add_patch(rect_outer)

    ax.text(80, 970, "FITUR 3: ALUR PEMERIKSAAN MANDIRI (8-TITIK FISIK)", color="#38bdf8", fontsize=16, fontweight='bold')
    ax.text(80, 935, "Pengujian kondisi fisik 8 komponen bertahap hingga kalkulasi skor kesehatan terkalibrasi", color="#94a3b8", fontsize=11.5)

    # Row 1 (Y = 700)
    draw_circle(ax, 110, 700, 50, "START")
    draw_arrow(ax, [[160, 700], [225, 700]])

    draw_box(ax, 345, 700, 220, 85, "DI HALAMAN\nPEMERIKSAAN MANDIRI", is_redirect=True, font_size=11)
    draw_arrow(ax, [[455, 700], [530, 700]])

    draw_box(ax, 665, 700, 250, 85, "MEMILIH KONDISI AKTUAL\n(OLI, REM, BAN, CVT, DLL.)", font_size=11)
    draw_arrow(ax, [[790, 700], [870, 700]])

    draw_box(ax, 970, 700, 190, 85, "KLIK TOMBOL\n'LANJUT'", font_size=11)
    draw_arrow(ax, [[1065, 700], [1160, 700]])

    draw_diamond(ax, 1260, 700, 180, 120, "MASIH ADA\nSOAL\nBERIKUTNYA ?", font_size=10.5)

    # Loop back: MASIH ADA
    draw_arrow(ax, [[1260, 760], [1260, 850], [665, 850], [665, 745]], label="MASIH ADA", label_pos=[960, 865])

    # Down: SOAL TERAKHIR
    draw_arrow(ax, [[1260, 640], [1260, 480], [1260, 345]], label="SOAL TERAKHIR", label_pos=[1355, 490])

    # Row 2 (Y = 280)
    draw_box(ax, 1220, 280, 230, 85, "KLIK TOMBOL\n'SELESAI & HITUNG SKOR'", font_size=11)
    draw_arrow(ax, [[1105, 280], [1005, 280]])

    draw_box(ax, 875, 280, 240, 85, "DIALIHKAN KE\nHALAMAN SEHAT MOTOR", is_redirect=True, font_size=11)
    draw_arrow(ax, [[755, 280], [655, 280]])

    draw_box(ax, 515, 280, 260, 85, "PENGGUNA MELIHAT SKOR\n& STATUS 14 KOMPONEN", font_size=11)
    draw_arrow(ax, [[385, 280], [285, 280]])

    draw_circle(ax, 210, 280, 55, "SELESAI")

    img_path = os.path.join(SCRATCH_DIR, "flowchart_p2_inspection.png")
    plt.tight_layout()
    plt.savefig(img_path, dpi=200, facecolor=fig.get_facecolor(), edgecolor='none', bbox_inches='tight')
    plt.close()
    return img_path

# ==============================================================================
# PAGE 3: FITUR 4 (TANYA AI) & FITUR 5 (UPDATE ODOMETER)
# ==============================================================================
def render_page3_image():
    fig, ax = plt.subplots(figsize=(15, 10.5), facecolor="#0e1620")
    ax.set_facecolor("#0e1620")
    ax.set_xlim(0, 1500)
    ax.set_ylim(0, 1050)
    ax.axis('off')

    rect_outer = patches.Rectangle((20, 20), 1460, 1010, fill=False, edgecolor="#1e2c3d", lw=1.8, zorder=1)
    ax.add_patch(rect_outer)
    ax.plot([20, 1480], [510, 510], color="#1e2c3d", lw=1.5, zorder=1)

    # --- FITUR 4: TANYA GEMINI AI (Y ≈ 780) ---
    ax.text(80, 970, "FITUR 4: ALUR TANYA KELUHAN MOTOR KE GEMINI AI (CHATBOT)", color="#38bdf8", fontsize=15, fontweight='bold')

    draw_circle(ax, 100, 760, 48, "START")
    draw_arrow(ax, [[148, 760], [205, 760]])

    draw_box(ax, 295, 760, 180, 80, "DI BERANDA / SEHAT,\nKLIK 'TANYA AI'", font_size=10.5)
    draw_arrow(ax, [[385, 760], [455, 760]])

    draw_box(ax, 555, 760, 200, 80, "DIALIHKAN KE\nHALAMAN CHAT AI", is_redirect=True, font_size=11)
    draw_arrow(ax, [[655, 760], [725, 760]])

    draw_box(ax, 825, 760, 200, 80, "PILIH KELUHAN / KETIK\nMASALAH MOTOR", font_size=10.5)
    draw_arrow(ax, [[925, 760], [995, 760]])

    draw_box(ax, 1085, 760, 180, 80, "KLIK 'KIRIM' & BACA\nSOLUSI DARI AI", font_size=10.5)
    draw_arrow(ax, [[1175, 760], [1235, 760]])

    draw_diamond(ax, 1315, 760, 160, 110, "CEK PART\nREKOMENDASI ?", font_size=9.5)

    # Branch IYA: Down to check catalog
    draw_arrow(ax, [[1315, 705], [1315, 595]], label="IYA", label_pos=[1350, 645])
    draw_box(ax, 1315, 555, 210, 70, "DIALIHKAN KE\nKATALOG SPAREPART", is_redirect=True, font_size=10.5)
    draw_arrow(ax, [[1210, 555], [1110, 555]])
    draw_circle(ax, 1060, 555, 45, "SELESAI", font_size=10.5)

    # Branch TIDAK: Right to Selesai
    draw_arrow(ax, [[1395, 760], [1435, 760]], label="TIDAK", label_pos=[1415, 785])
    draw_circle(ax, 1465, 760, 30, "SELESAI", font_size=8)

    # --- FITUR 5: UPDATE ODOMETER (Y ≈ 250) ---
    ax.text(80, 440, "FITUR 5: ALUR MEMPERBARUI ANGKA KILOMETER (UPDATE ODOMETER)", color="#38bdf8", fontsize=15, fontweight='bold')

    draw_circle(ax, 90, 250, 45, "START")
    draw_arrow(ax, [[135, 250], [195, 250]])

    draw_box(ax, 295, 250, 200, 80, "DI BERANDA, KLIK\n'UPDATE' PADA MOTOR", font_size=10.5)
    draw_arrow(ax, [[395, 250], [455, 250]])

    draw_box(ax, 565, 250, 220, 80, "DIALIHKAN KE\nDIALOG INPUT ODOMETER", is_redirect=True, font_size=10.5)
    draw_arrow(ax, [[675, 250], [735, 250]])

    draw_box(ax, 845, 250, 220, 80, "PENGGUNA MENGETIK\nKILOMETER TERBARU", font_size=10.5)
    draw_arrow(ax, [[955, 250], [1015, 250]])

    draw_box(ax, 1095, 250, 160, 80, "KLIK TOMBOL\n'SIMPAN'", font_size=11)
    draw_arrow(ax, [[1175, 250], [1225, 250]])

    draw_box(ax, 1315, 250, 180, 80, "DIALIHKAN KEMBALI\nKE BERANDA", is_redirect=True, font_size=10.5)
    draw_arrow(ax, [[1405, 250], [1440, 250]])

    draw_circle(ax, 1470, 250, 30, "SELESAI", font_size=8)

    img_path = os.path.join(SCRATCH_DIR, "flowchart_p3_ai_and_odometer.png")
    plt.tight_layout()
    plt.savefig(img_path, dpi=200, facecolor=fig.get_facecolor(), edgecolor='none', bbox_inches='tight')
    plt.close()
    return img_path

# ==============================================================================
# PAGE 4: FITUR 6 (KATALOG SPAREPART) & FITUR 7 (RIWAYAT SERVIS)
# ==============================================================================
def render_page4_image():
    fig, ax = plt.subplots(figsize=(15, 10.5), facecolor="#0e1620")
    ax.set_facecolor("#0e1620")
    ax.set_xlim(0, 1500)
    ax.set_ylim(0, 1050)
    ax.axis('off')

    rect_outer = patches.Rectangle((20, 20), 1460, 1010, fill=False, edgecolor="#1e2c3d", lw=1.8, zorder=1)
    ax.add_patch(rect_outer)
    ax.plot([20, 1480], [510, 510], color="#1e2c3d", lw=1.5, zorder=1)

    # --- FITUR 6: KATALOG SPAREPART (Y ≈ 780 & 620) ---
    ax.text(80, 970, "FITUR 6: ALUR MENCARI SUKU CADANG (KATALOG SPAREPART)", color="#38bdf8", fontsize=15, fontweight='bold')

    draw_circle(ax, 110, 780, 50, "START")
    draw_arrow(ax, [[160, 780], [230, 780]])

    draw_box(ax, 345, 780, 215, 80, "DI MENU BAWAH,\nKLIK TAB 'SPAREPART'", font_size=11)
    draw_arrow(ax, [[453, 780], [523, 780]])

    draw_box(ax, 640, 780, 220, 80, "DIALIHKAN KE\nKATALOG SPAREPART", is_redirect=True, font_size=11)
    draw_arrow(ax, [[750, 780], [820, 780]])

    draw_box(ax, 940, 780, 225, 80, "PILIH KATEGORI PART\natau KETIK PENCARIAN", font_size=11)
    draw_arrow(ax, [[1053, 780], [1123, 780]])

    draw_box(ax, 1240, 780, 220, 80, "KLIK SALAH SATU\nKARTU SUKU CADANG", font_size=11)

    # Elbow arrow down to Detail box
    draw_arrow(ax, [[1350, 780], [1420, 780], [1420, 630], [1355, 630]])

    draw_box(ax, 1230, 630, 240, 75, "DIALIHKAN KE\nDETAIL SUKU CADANG", is_redirect=True, font_size=11)
    draw_arrow(ax, [[1110, 630], [980, 630]])

    draw_box(ax, 830, 630, 280, 75, "LIHAT HARGA RESMI (HET)\n& SPESIFIKASI MOTOR", font_size=11)
    draw_arrow(ax, [[690, 630], [590, 630]])

    draw_circle(ax, 530, 630, 50, "SELESAI")

    # --- FITUR 7: RIWAYAT SERVIS (Y ≈ 260 & 100) ---
    ax.text(80, 450, "FITUR 7: ALUR MENCATAT SERVIS MOTOR (RIWAYAT SERVIS)", color="#38bdf8", fontsize=15, fontweight='bold')

    draw_circle(ax, 110, 260, 50, "START")
    draw_arrow(ax, [[160, 260], [230, 260]])

    draw_box(ax, 335, 260, 195, 80, "DI MENU BAWAH,\nKLIK TAB 'RIWAYAT'", font_size=11)
    draw_arrow(ax, [[433, 260], [503, 260]])

    draw_box(ax, 615, 260, 210, 80, "DIALIHKAN KE\nHALAMAN RIWAYAT", is_redirect=True, font_size=11)
    draw_arrow(ax, [[720, 260], [790, 260]])

    draw_box(ax, 895, 260, 195, 80, "PENGGUNA KLIK\n'+ CATAT SERVIS'", font_size=11)
    draw_arrow(ax, [[993, 260], [1063, 260]])

    draw_box(ax, 1180, 260, 220, 80, "DIALIHKAN KE\nFORM CATAT SERVIS", is_redirect=True, font_size=11)

    # Elbow arrow down to Submit box
    draw_arrow(ax, [[1290, 260], [1400, 260], [1400, 110], [1335, 110]])

    draw_box(ax, 1205, 110, 250, 75, "ISI BIAYA & KLIK 'SIMPAN'", font_size=11)
    draw_arrow(ax, [[1080, 110], [970, 110]])

    draw_box(ax, 830, 110, 260, 75, "DIALIHKAN KEMBALI\nKE RIWAYAT SERVIS", is_redirect=True, font_size=11)
    draw_arrow(ax, [[700, 110], [600, 110]])

    draw_circle(ax, 540, 110, 50, "SELESAI")

    img_path = os.path.join(SCRATCH_DIR, "flowchart_p4_parts_and_history.png")
    plt.tight_layout()
    plt.savefig(img_path, dpi=200, facecolor=fig.get_facecolor(), edgecolor='none', bbox_inches='tight')
    plt.close()
    return img_path

# ==============================================================================
# COMPILE INTO 1 SINGLE PDF WITH 4 HIGH-RES PAGES
# ==============================================================================
def compile_single_pdf():
    img1 = render_page1_image()
    img2 = render_page2_image()
    img3 = render_page3_image()
    img4 = render_page4_image()

    doc = Document()

    for s in doc.sections:
        s.page_width = Inches(8.27)
        s.page_height = Inches(11.69)
        s.top_margin = Inches(0.4)
        s.bottom_margin = Inches(0.4)
        s.left_margin = Inches(0.4)
        s.right_margin = Inches(0.4)

    pages_data = [
        {"img": img1, "title": "USER FLOW • FITUR 1 (LOGIN) & FITUR 2 (TAMBAH MOTOR)"},
        {"img": img2, "title": "USER FLOW • FITUR 3 (PEMERIKSAAN MANDIRI 8-TITIK FISIK)"},
        {"img": img3, "title": "USER FLOW • FITUR 4 (TANYA GEMINI AI) & FITUR 5 (UPDATE ODOMETER)"},
        {"img": img4, "title": "USER FLOW • FITUR 6 (KATALOG SPAREPART) & FITUR 7 (RIWAYAT SERVIS)"}
    ]

    for idx, p_info in enumerate(pages_data):
        if idx > 0:
            doc.add_page_break()

        # Page Header
        p_title = doc.add_paragraph()
        p_title.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_title.paragraph_format.space_before = Pt(0)
        p_title.paragraph_format.space_after = Pt(2)
        run_t = p_title.add_run(p_info["title"])
        run_t.font.name = "Arial"
        run_t.font.size = Pt(13)
        run_t.font.bold = True
        run_t.font.color.rgb = RGBColor(14, 23, 31)

        # Subtitle
        p_sub = doc.add_paragraph()
        p_sub.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_sub.paragraph_format.space_before = Pt(0)
        p_sub.paragraph_format.space_after = Pt(8)
        run_s = p_sub.add_run(f"BuildHaus v2.0 • Halaman {idx+1} dari {len(pages_data)} • Diagram Alir Navigasi Pengguna")
        run_s.font.name = "Arial"
        run_s.font.size = Pt(9)
        run_s.font.color.rgb = RGBColor(100, 116, 139)

        # Image
        p_img = doc.add_paragraph()
        p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_img.paragraph_format.space_before = Pt(0)
        p_img.paragraph_format.space_after = Pt(6)
        run_img = p_img.add_run()
        run_img.add_picture(p_info["img"], width=Inches(7.45))

    temp_docx = os.path.join(SCRATCH_DIR, "temp_user_flow_per_fitur.docx")
    final_pdf_path = os.path.join(OUT_DIR, "USER FLOW.docx.pdf")
    doc.save(temp_docx)

    # Convert to PDF
    word = win32com.client.DispatchEx("Word.Application")
    word.Visible = False
    word.DisplayAlerts = False
    try:
        wdoc = word.Documents.Open(os.path.abspath(temp_docx))
        wdoc.SaveAs2(os.path.abspath(final_pdf_path), FileFormat=17) # 17 = wdFormatPDF
        wdoc.Close()
        print(f"SUCCESS! 1 Single Multi-Page PDF Created: {final_pdf_path}")
    finally:
        word.Quit()
        del word
        gc.collect()

if __name__ == "__main__":
    compile_single_pdf()
