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

def create_flowchart_image():
    # Figure 16x16 inches, 2400x2400 px
    fig, ax = plt.subplots(figsize=(16, 16), facecolor="#0e1620")
    ax.set_facecolor("#0e1620")
    ax.set_xlim(0, 1600)
    ax.set_ylim(0, 1600)
    ax.axis('off')

    # Subtle horizontal dividers
    ax.plot([30, 1570], [1080, 1080], color="#1e2c3d", lw=1.5, zorder=1)
    ax.plot([30, 1570], [550, 550], color="#1e2c3d", lw=1.5, zorder=1)

    # Outer border
    rect_outer = patches.Rectangle((30, 30), 1540, 1540, fill=False, edgecolor="#1e2c3d", lw=1.8, zorder=1)
    ax.add_patch(rect_outer)

    def draw_box(x, y, w, h, text, is_redirect=False, is_role=False, font_size=10):
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

    def draw_circle(x, y, r, text, font_size=11):
        circle = patches.Circle(
            (x, y), r, facecolor="#132333", edgecolor="#38bdf8", lw=2.2, zorder=3
        )
        ax.add_patch(circle)
        ax.text(x, y, text, ha='center', va='center', color="#ffffff",
                fontsize=font_size, fontweight='bold', fontfamily='sans-serif', zorder=4)

    def draw_diamond(x, y, w, h, text, font_size=9.5):
        pts = [[x, y + h/2], [x + w/2, y], [x, y - h/2], [x - w/2, y]]
        poly = patches.Polygon(pts, facecolor="#1a271c", edgecolor="#00f5a0", lw=2.2, zorder=3)
        ax.add_patch(poly)
        ax.text(x, y, text, ha='center', va='center', color="#ffffff",
                fontsize=font_size, fontweight='bold', fontfamily='sans-serif', zorder=4)

    def draw_line(pts, arrow=True):
        xs, ys = zip(*pts)
        ax.plot(xs, ys, color="#94a3b8", lw=2.2, zorder=2)
        if arrow:
            x1, y1 = pts[-2]
            x2, y2 = pts[-1]
            dx = x2 - x1
            dy = y2 - y1
            length = (dx**2 + dy**2)**0.5
            if length > 0:
                ax.annotate("", xy=(x2, y2), xytext=(x2 - (dx/length)*10, y2 - (dy/length)*10),
                            arrowprops=dict(arrowstyle="-|>", color="#94a3b8", lw=2.2, mutation_scale=18),
                            zorder=2)

    def draw_branch_text(x, y, text):
        ax.text(x, y, text, ha='center', va='center', color="#00f5a0",
                fontsize=10.5, fontweight='bold', fontfamily='sans-serif',
                bbox=dict(boxstyle="square,pad=0.2", facecolor="#0e1620", edgecolor="none"),
                zorder=5)

    # ==================== ROW 1 (Y = 1320) ====================
    # 1. Role: PENGGUNA
    draw_box(140, 1490, 160, 75, "PENGGUNA", is_role=True, font_size=12)
    draw_line([[140, 1452], [140, 1375]])

    # 2. START
    draw_circle(140, 1320, 55, "START")
    draw_line([[195, 1320], [255, 1320]])

    # 3. LOGIN
    draw_box(320, 1320, 120, 80, "LOGIN", font_size=11)
    draw_line([[380, 1320], [440, 1320]])

    # 4. DIALIHKAN KE BERANDA
    draw_box(525, 1320, 160, 80, "DIALIHKAN KE\nHALAMAN BERANDA", is_redirect=True, font_size=9.5)
    draw_line([[605, 1320], [665, 1320]])

    # 5. KLIK TAMBAH MOTOR
    draw_box(745, 1320, 150, 80, "KLIK TAMBAH\nMOTOR", font_size=10.5)
    draw_line([[820, 1320], [880, 1320]])

    # 6. DIALIHKAN KE FORM TAMBAH
    draw_box(965, 1320, 160, 80, "DIALIHKAN KE\nFORM TAMBAH", is_redirect=True, font_size=9.5)
    draw_line([[1045, 1320], [1105, 1320]])

    # 7. ISI DATA MOTOR
    draw_box(1200, 1320, 180, 80, "ISI DATA MOTOR\n(HONDA/YAMAHA)", font_size=10)
    draw_line([[1290, 1320], [1350, 1320]])

    # 8. DIALIHKAN KE UJI MANDIRI
    draw_box(1435, 1320, 160, 80, "DIALIHKAN KE\nUJI MANDIRI", is_redirect=True, font_size=9.5)

    # Snake arrow Row 1 -> Row 2
    draw_line([[1515, 1320], [1545, 1320], [1545, 1180], [75, 1180], [75, 820], [115, 820]])

    # ==================== ROW 2 (Y = 820) ====================
    # 1. JAWAB 8 PERTANYAAN FISIK
    draw_box(200, 820, 160, 85, "JAWAB 8\nPERTANYAAN FISIK", font_size=10)
    draw_line([[280, 820], [335, 820]])

    # 2. DIALIHKAN KE HALAMAN SEHAT
    draw_box(415, 820, 150, 85, "DIALIHKAN KE\nHALAMAN SEHAT", is_redirect=True, font_size=9.5)
    draw_line([[490, 820], [545, 820]])

    # 3. LIHAT SKOR KESEHATAN MOTOR
    draw_box(635, 820, 170, 85, "LIHAT SKOR\nKESEHATAN MOTOR", font_size=10)
    draw_line([[720, 820], [775, 820]])

    # 4. DIAMOND: ADA KELUHAN MOTOR ?
    draw_diamond(850, 820, 140, 100, "ADA\nKELUHAN\nMOTOR ?", font_size=9.5)

    # Branch IYA -> Right
    draw_line([[920, 820], [975, 820]])
    draw_branch_text(945, 835, "IYA")

    # 5. DIALIHKAN KE TANYA AI
    draw_box(1050, 820, 140, 85, "DIALIHKAN KE\nTANYA AI", is_redirect=True, font_size=9.5)
    draw_line([[1120, 820], [1175, 820]])

    # 6. INPUT KELUHAN KE GEMINI AI
    draw_box(1265, 820, 170, 85, "INPUT KELUHAN\nKE GEMINI AI", font_size=10)
    draw_line([[1350, 820], [1405, 820]])

    # 7. REKOMENDASI SERVIS
    draw_box(1480, 820, 140, 85, "REKOMENDASI\nSERVIS", font_size=10.5)

    # Branch TIDAK -> Down from diamond, across to bottom of REKOMENDASI SERVIS
    draw_line([[850, 770], [850, 690], [1480, 690], [1480, 777]])
    draw_branch_text(900, 750, "TIDAK")

    # Snake arrow Row 2 -> Row 3 from right side of REKOMENDASI SERVIS
    draw_line([[1550, 820], [1565, 820], [1565, 600], [75, 600], [75, 290], [130, 290]])

    # ==================== ROW 3 (Y = 290) ====================
    # 1. DIALIHKAN KE KATALOG SPAREPART
    draw_box(240, 290, 210, 85, "DIALIHKAN KE\nKATALOG SPAREPART", is_redirect=True, font_size=10.5)
    draw_line([[345, 290], [425, 290]])

    # 2. LIHAT SPAREPART RESMI MOTOR
    draw_box(535, 290, 210, 85, "LIHAT SPAREPART\nRESMI MOTOR", font_size=10.5)
    draw_line([[640, 290], [720, 290]])

    # 3. CATAT RIWAYAT SERVIS
    draw_box(825, 290, 200, 85, "CATAT RIWAYAT\nSERVIS", font_size=10.5)
    draw_line([[925, 290], [1005, 290]])

    # 4. UPDATE ODOMETER RUTIN
    draw_box(1110, 290, 200, 85, "UPDATE ODOMETER\nRUTIN", font_size=10.5)
    draw_line([[1210, 290], [1300, 290]])

    # 5. SELESAI
    draw_circle(1365, 290, 60, "SELESAI", font_size=12)

    img_path = os.path.join(SCRATCH_DIR, "user_flow_master_diagram.png")
    plt.tight_layout()
    plt.savefig(img_path, dpi=200, facecolor=fig.get_facecolor(), edgecolor='none', bbox_inches='tight')
    plt.close()
    print(f"Master Flowchart Image Saved: {img_path}")
    return img_path

def build_pdf_document(img_path):
    doc = Document()

    for s in doc.sections:
        s.page_width = Inches(8.27)
        s.page_height = Inches(11.69)
        s.top_margin = Inches(0.4)
        s.bottom_margin = Inches(0.4)
        s.left_margin = Inches(0.4)
        s.right_margin = Inches(0.4)

    # Document Header
    p_title = doc.add_paragraph()
    p_title.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_title.paragraph_format.space_before = Pt(0)
    p_title.paragraph_format.space_after = Pt(2)
    run_t = p_title.add_run("USER FLOW")
    run_t.font.name = "Arial"
    run_t.font.size = Pt(18)
    run_t.font.bold = True
    run_t.font.color.rgb = RGBColor(14, 23, 31)

    # Subtitle
    p_sub = doc.add_paragraph()
    p_sub.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_sub.paragraph_format.space_before = Pt(0)
    p_sub.paragraph_format.space_after = Pt(8)
    run_s = p_sub.add_run("BuildHaus v2.0 • Diagram Alur Navigasi Lengkap Pengguna")
    run_s.font.name = "Arial"
    run_s.font.size = Pt(9.5)
    run_s.font.color.rgb = RGBColor(100, 116, 139)

    # Add the Flowchart Image
    p_img = doc.add_paragraph()
    p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_img.paragraph_format.space_before = Pt(0)
    p_img.paragraph_format.space_after = Pt(8)
    run_img = p_img.add_run()
    run_img.add_picture(img_path, width=Inches(7.45))

    # Footer note
    p_foot = doc.add_paragraph()
    p_foot.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_foot.paragraph_format.space_before = Pt(4)
    p_foot.paragraph_format.space_after = Pt(0)
    run_f = p_foot.add_run("BuildHaus • Dokumentasi Perancangan Antarmuka & Alur Pengguna (User Flow)")
    run_f.font.name = "Arial"
    run_f.font.size = Pt(8)
    run_f.font.color.rgb = RGBColor(148, 163, 184)

    temp_docx = os.path.join(SCRATCH_DIR, "temp_user_flow_doc.docx")
    final_pdf_path = os.path.join(OUT_DIR, "USER FLOW.docx.pdf")
    doc.save(temp_docx)

    # Convert to PDF via Word COM
    word = win32com.client.DispatchEx("Word.Application")
    word.Visible = False
    word.DisplayAlerts = False
    try:
        wdoc = word.Documents.Open(os.path.abspath(temp_docx))
        wdoc.SaveAs2(os.path.abspath(final_pdf_path), FileFormat=17) # 17 = wdFormatPDF
        wdoc.Close()
        print(f"SUCCESS! 1 Single File Generated: {final_pdf_path}")
    finally:
        word.Quit()
        del word
        gc.collect()

if __name__ == "__main__":
    img = create_flowchart_image()
    build_pdf_document(img)
