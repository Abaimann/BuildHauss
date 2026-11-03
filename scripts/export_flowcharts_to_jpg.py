import os
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from PIL import Image

OUT_DIR = r"C:\SAVING\GAWEAN GW\Capstone-Project\JOSJIS\baru"
os.makedirs(OUT_DIR, exist_ok=True)

# Remove the PDF file as requested
old_pdf = os.path.join(OUT_DIR, "USER FLOW.docx.pdf")
if os.path.exists(old_pdf):
    try:
        os.remove(old_pdf)
        print("Removed PDF file.")
    except Exception as e:
        print("Could not remove PDF (may be open):", e)

def draw_box(ax, x, y, w, h, text, is_redirect=False, is_role=False, font_size=11):
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

def draw_diamond(ax, x, y, w, h, text, font_size=10):
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
                fontsize=10.5, fontweight='bold', fontfamily='sans-serif',
                bbox=dict(boxstyle="square,pad=0.2", facecolor="#0e1620", edgecolor="none"),
                zorder=5)

def save_fig_as_jpg(fig, filepath):
    # Save as high-res JPG
    png_temp = filepath.replace(".jpg", "_temp.png")
    plt.tight_layout()
    plt.savefig(png_temp, dpi=200, facecolor=fig.get_facecolor(), edgecolor='none', bbox_inches='tight')
    plt.close()

    # Convert to pure RGB JPG
    im = Image.open(png_temp).convert("RGB")
    im.save(filepath, "JPEG", quality=95)
    os.remove(png_temp)
    print(f"Saved JPG: {filepath}")

# ==============================================================================
# 1. FITUR 1: LOGIN
# ==============================================================================
def export_fitur_1():
    fig, ax = plt.subplots(figsize=(15, 5.5), facecolor="#0e1620")
    ax.set_facecolor("#0e1620")
    ax.set_xlim(0, 1500)
    ax.set_ylim(0, 550)
    ax.axis('off')

    rect_outer = patches.Rectangle((20, 20), 1460, 510, fill=False, edgecolor="#1e2c3d", lw=1.8, zorder=1)
    ax.add_patch(rect_outer)

    ax.text(60, 485, "FITUR 1: ALUR MASUK KE APLIKASI (LOGIN)", color="#38bdf8", fontsize=15, fontweight='bold')
    ax.text(60, 455, "Otentikasi akun offline-first dan navigasi otomatis ke halaman beranda", color="#94a3b8", fontsize=10.5)

    draw_box(ax, 110, 350, 130, 60, "PENGGUNA", is_role=True, font_size=11)
    draw_arrow(ax, [[110, 320], [110, 265]])

    draw_circle(ax, 110, 210, 50, "START")
    draw_arrow(ax, [[160, 210], [230, 210]])

    draw_box(ax, 320, 210, 170, 80, "MASUKKAN\nEMAIL & SANDI", font_size=11)
    draw_arrow(ax, [[405, 210], [475, 210]])

    draw_box(ax, 555, 210, 150, 80, "KLIK TOMBOL\n'MASUK'", font_size=11)
    draw_arrow(ax, [[630, 210], [700, 210]])

    draw_box(ax, 825, 210, 230, 80, "DIALIHKAN KE\nHALAMAN BERANDA", is_redirect=True, font_size=11)
    draw_arrow(ax, [[940, 210], [1010, 210]])

    draw_box(ax, 1135, 210, 230, 80, "PENGGUNA MELIHAT\nDASHBOARD GARASI", font_size=11)
    draw_arrow(ax, [[1250, 210], [1320, 210]])

    draw_circle(ax, 1375, 210, 50, "SELESAI")

    save_fig_as_jpg(fig, os.path.join(OUT_DIR, "01_Flowchart_Login.jpg"))

# ==============================================================================
# 2. FITUR 2: TAMBAH MOTOR
# ==============================================================================
def export_fitur_2():
    fig, ax = plt.subplots(figsize=(15, 5.5), facecolor="#0e1620")
    ax.set_facecolor("#0e1620")
    ax.set_xlim(0, 1500)
    ax.set_ylim(0, 550)
    ax.axis('off')

    rect_outer = patches.Rectangle((20, 20), 1460, 510, fill=False, edgecolor="#1e2c3d", lw=1.8, zorder=1)
    ax.add_patch(rect_outer)

    ax.text(60, 485, "FITUR 2: ALUR MENAMBAH MOTOR BARU (DENGAN AUTO-REDIRECT)", color="#38bdf8", fontsize=15, fontweight='bold')
    ax.text(60, 455, "Pendaftaran motor ke garasi yang langsung otomatis mengalihkan ke uji fisik mandiri", color="#94a3b8", fontsize=10.5)

    draw_circle(ax, 110, 230, 50, "START")
    draw_arrow(ax, [[160, 230], [230, 230]])

    draw_box(ax, 335, 230, 200, 80, "DI BERANDA, KLIK\n'+ TAMBAH MOTOR'", font_size=11)
    draw_arrow(ax, [[435, 230], [505, 230]])

    draw_box(ax, 620, 230, 220, 80, "DIALIHKAN KE\nFORM TAMBAH MOTOR", is_redirect=True, font_size=11)
    draw_arrow(ax, [[730, 230], [800, 230]])

    draw_box(ax, 915, 230, 220, 80, "ISI DATA MOTOR\n(HONDA/YAMAHA & ODO)", font_size=11)
    draw_arrow(ax, [[1025, 230], [1095, 230]])

    draw_box(ax, 1195, 230, 190, 80, "KLIK TOMBOL\n'SIMPAN MOTOR'", font_size=11)
    draw_arrow(ax, [[1290, 230], [1340, 230]])

    draw_box(ax, 1410, 230, 130, 80, "OTOMATIS\nDIALIHKAN KE\nUJI MANDIRI", is_redirect=True, font_size=9.5)

    save_fig_as_jpg(fig, os.path.join(OUT_DIR, "02_Flowchart_Tambah_Motor.jpg"))

# ==============================================================================
# 3. FITUR 3: PEMERIKSAAN MANDIRI 8-TITIK FISIK
# ==============================================================================
def export_fitur_3():
    fig, ax = plt.subplots(figsize=(15, 8.5), facecolor="#0e1620")
    ax.set_facecolor("#0e1620")
    ax.set_xlim(0, 1500)
    ax.set_ylim(0, 850)
    ax.axis('off')

    rect_outer = patches.Rectangle((20, 20), 1460, 810, fill=False, edgecolor="#1e2c3d", lw=1.8, zorder=1)
    ax.add_patch(rect_outer)

    ax.text(60, 785, "FITUR 3: ALUR PEMERIKSAAN MANDIRI (8-TITIK FISIK)", color="#38bdf8", fontsize=15, fontweight='bold')
    ax.text(60, 755, "Pengujian kondisi 8 komponen fisik secara bertahap hingga kalkulasi skor kesehatan terkalibrasi", color="#94a3b8", fontsize=10.5)

    # Row 1 (Y = 560)
    draw_circle(ax, 110, 560, 50, "START")
    draw_arrow(ax, [[160, 560], [225, 560]])

    draw_box(ax, 345, 560, 220, 85, "DI HALAMAN\nPEMERIKSAAN MANDIRI", is_redirect=True, font_size=11)
    draw_arrow(ax, [[455, 560], [530, 560]])

    draw_box(ax, 665, 560, 250, 85, "MEMILIH KONDISI AKTUAL\n(OLI, REM, BAN, CVT, DLL.)", font_size=11)
    draw_arrow(ax, [[790, 560], [870, 560]])

    draw_box(ax, 970, 560, 190, 85, "KLIK TOMBOL\n'LANJUT'", font_size=11)
    draw_arrow(ax, [[1065, 560], [1160, 560]])

    draw_diamond(ax, 1260, 560, 180, 120, "MASIH ADA\nSOAL\nBERIKUTNYA ?", font_size=10.5)

    # Loop back: MASIH ADA
    draw_arrow(ax, [[1260, 620], [1260, 700], [665, 700], [665, 605]], label="MASIH ADA", label_pos=[960, 715])

    # Down: SOAL TERAKHIR
    draw_arrow(ax, [[1260, 500], [1260, 360], [1260, 245]], label="SOAL TERAKHIR", label_pos=[1355, 370])

    # Row 2 (Y = 180)
    draw_box(ax, 1220, 180, 230, 85, "KLIK TOMBOL\n'SELESAI & HITUNG SKOR'", font_size=11)
    draw_arrow(ax, [[1105, 180], [1005, 180]])

    draw_box(ax, 875, 180, 240, 85, "DIALIHKAN KE\nHALAMAN SEHAT MOTOR", is_redirect=True, font_size=11)
    draw_arrow(ax, [[755, 180], [655, 180]])

    draw_box(ax, 515, 180, 260, 85, "PENGGUNA MELIHAT SKOR\n& STATUS 14 KOMPONEN", font_size=11)
    draw_arrow(ax, [[385, 180], [285, 180]])

    draw_circle(ax, 210, 180, 55, "SELESAI")

    save_fig_as_jpg(fig, os.path.join(OUT_DIR, "03_Flowchart_Pemeriksaan_Mandiri.jpg"))

# ==============================================================================
# 4. FITUR 4: TANYA GEMINI AI
# ==============================================================================
def export_fitur_4():
    fig, ax = plt.subplots(figsize=(15, 7.5), facecolor="#0e1620")
    ax.set_facecolor("#0e1620")
    ax.set_xlim(0, 1500)
    ax.set_ylim(0, 750)
    ax.axis('off')

    rect_outer = patches.Rectangle((20, 20), 1460, 710, fill=False, edgecolor="#1e2c3d", lw=1.8, zorder=1)
    ax.add_patch(rect_outer)

    ax.text(60, 685, "FITUR 4: ALUR TANYA KELUHAN MOTOR KE GEMINI AI (CHATBOT)", color="#38bdf8", fontsize=15, fontweight='bold')
    ax.text(60, 655, "Konsultasi keluhan motor santai, diagnosis cerdas, dan pemotongan poin kesehatan deterministik", color="#94a3b8", fontsize=10.5)

    draw_circle(ax, 100, 480, 48, "START")
    draw_arrow(ax, [[148, 480], [205, 480]])

    draw_box(ax, 295, 480, 180, 80, "DI BERANDA / SEHAT,\nKLIK 'TANYA AI'", font_size=10.5)
    draw_arrow(ax, [[385, 480], [455, 480]])

    draw_box(ax, 555, 480, 200, 80, "DIALIHKAN KE\nHALAMAN CHAT AI", is_redirect=True, font_size=11)
    draw_arrow(ax, [[655, 480], [725, 480]])

    draw_box(ax, 825, 480, 200, 80, "PILIH KELUHAN / KETIK\nMASALAH MOTOR", font_size=10.5)
    draw_arrow(ax, [[925, 480], [995, 480]])

    draw_box(ax, 1085, 480, 180, 80, "KLIK 'KIRIM' & BACA\nSOLUSI DARI AI", font_size=10.5)
    draw_arrow(ax, [[1175, 480], [1235, 480]])

    draw_diamond(ax, 1315, 480, 160, 110, "CEK PART\nREKOMENDASI ?", font_size=9.5)

    # Branch IYA: Down
    draw_arrow(ax, [[1315, 425], [1315, 305]], label="IYA", label_pos=[1350, 365])
    draw_box(ax, 1315, 265, 210, 70, "DIALIHKAN KE\nKATALOG SPAREPART", is_redirect=True, font_size=10.5)
    draw_arrow(ax, [[1210, 265], [1110, 265]])
    draw_circle(ax, 1060, 265, 45, "SELESAI", font_size=10.5)

    # Branch TIDAK: Right to Selesai
    draw_arrow(ax, [[1395, 480], [1435, 480]], label="TIDAK", label_pos=[1415, 505])
    draw_circle(ax, 1465, 480, 30, "SELESAI", font_size=8)

    save_fig_as_jpg(fig, os.path.join(OUT_DIR, "04_Flowchart_Tanya_Gemini_AI.jpg"))

# ==============================================================================
# 5. FITUR 5: UPDATE ODOMETER
# ==============================================================================
def export_fitur_5():
    fig, ax = plt.subplots(figsize=(15, 5.5), facecolor="#0e1620")
    ax.set_facecolor("#0e1620")
    ax.set_xlim(0, 1500)
    ax.set_ylim(0, 550)
    ax.axis('off')

    rect_outer = patches.Rectangle((20, 20), 1460, 510, fill=False, edgecolor="#1e2c3d", lw=1.8, zorder=1)
    ax.add_patch(rect_outer)

    ax.text(60, 485, "FITUR 5: ALUR MEMPERBARUI ANGKA KILOMETER (UPDATE ODOMETER)", color="#38bdf8", fontsize=15, fontweight='bold')
    ax.text(60, 455, "Pembaruan rutin angka speedometer untuk menghitung ulang sisa kilometer usia pakai komponen", color="#94a3b8", fontsize=10.5)

    draw_circle(ax, 90, 240, 45, "START")
    draw_arrow(ax, [[135, 240], [195, 240]])

    draw_box(ax, 295, 240, 200, 80, "DI BERANDA, KLIK\n'UPDATE' PADA MOTOR", font_size=10.5)
    draw_arrow(ax, [[395, 240], [455, 240]])

    draw_box(ax, 565, 240, 220, 80, "DIALIHKAN KE\nDIALOG INPUT ODOMETER", is_redirect=True, font_size=10.5)
    draw_arrow(ax, [[675, 240], [735, 240]])

    draw_box(ax, 845, 240, 220, 80, "PENGGUNA MENGETIK\nKILOMETER TERBARU", font_size=10.5)
    draw_arrow(ax, [[955, 240], [1015, 240]])

    draw_box(ax, 1095, 240, 160, 80, "KLIK TOMBOL\n'SIMPAN'", font_size=11)
    draw_arrow(ax, [[1175, 240], [1225, 240]])

    draw_box(ax, 1315, 240, 180, 80, "DIALIHKAN KEMBALI\nKE BERANDA", is_redirect=True, font_size=10.5)
    draw_arrow(ax, [[1405, 240], [1440, 240]])

    draw_circle(ax, 1470, 240, 30, "SELESAI", font_size=8)

    save_fig_as_jpg(fig, os.path.join(OUT_DIR, "05_Flowchart_Update_Odometer.jpg"))

# ==============================================================================
# 6. FITUR 6: KATALOG SPAREPART
# ==============================================================================
def export_fitur_6():
    fig, ax = plt.subplots(figsize=(15, 7.5), facecolor="#0e1620")
    ax.set_facecolor("#0e1620")
    ax.set_xlim(0, 1500)
    ax.set_ylim(0, 750)
    ax.axis('off')

    rect_outer = patches.Rectangle((20, 20), 1460, 710, fill=False, edgecolor="#1e2c3d", lw=1.8, zorder=1)
    ax.add_patch(rect_outer)

    ax.text(60, 685, "FITUR 6: ALUR MENCARI SUKU CADANG (KATALOG SPAREPART)", color="#38bdf8", fontsize=15, fontweight='bold')
    ax.text(60, 655, "Eksplorasi katalog resmi yang tersaring khusus sesuai merek motor aktif (Honda/Yamaha)", color="#94a3b8", fontsize=10.5)

    # Row 1 (Y = 480)
    draw_circle(ax, 110, 480, 50, "START")
    draw_arrow(ax, [[160, 480], [230, 480]])

    draw_box(ax, 345, 480, 215, 80, "DI MENU BAWAH,\nKLIK TAB 'SPAREPART'", font_size=11)
    draw_arrow(ax, [[453, 480], [523, 480]])

    draw_box(ax, 640, 480, 220, 80, "DIALIHKAN KE\nKATALOG SPAREPART", is_redirect=True, font_size=11)
    draw_arrow(ax, [[750, 480], [820, 480]])

    draw_box(ax, 940, 480, 225, 80, "PILIH KATEGORI PART\natau KETIK PENCARIAN", font_size=11)
    draw_arrow(ax, [[1053, 480], [1123, 480]])

    draw_box(ax, 1240, 480, 220, 80, "KLIK SALAH SATU\nKARTU SUKU CADANG", font_size=11)

    # Elbow arrow down to Detail box (Row 2 Y = 220)
    draw_arrow(ax, [[1350, 480], [1420, 480], [1420, 220], [1355, 220]])

    draw_box(ax, 1230, 220, 240, 75, "DIALIHKAN KE\nDETAIL SUKU CADANG", is_redirect=True, font_size=11)
    draw_arrow(ax, [[1110, 220], [980, 220]])

    draw_box(ax, 830, 220, 280, 75, "LIHAT HARGA RESMI (HET)\n& SPESIFIKASI MOTOR", font_size=11)
    draw_arrow(ax, [[690, 220], [590, 220]])

    draw_circle(ax, 530, 220, 50, "SELESAI")

    save_fig_as_jpg(fig, os.path.join(OUT_DIR, "06_Flowchart_Katalog_Sparepart.jpg"))

# ==============================================================================
# 7. FITUR 7: RIWAYAT SERVIS
# ==============================================================================
def export_fitur_7():
    fig, ax = plt.subplots(figsize=(15, 7.5), facecolor="#0e1620")
    ax.set_facecolor("#0e1620")
    ax.set_xlim(0, 1500)
    ax.set_ylim(0, 750)
    ax.axis('off')

    rect_outer = patches.Rectangle((20, 20), 1460, 710, fill=False, edgecolor="#1e2c3d", lw=1.8, zorder=1)
    ax.add_patch(rect_outer)

    ax.text(60, 685, "FITUR 7: ALUR MENCATAT SERVIS MOTOR (RIWAYAT SERVIS)", color="#38bdf8", fontsize=15, fontweight='bold')
    ax.text(60, 655, "Pencatatan nota servis untuk memulihkan interval dan skor kesehatan komponen kembali prima", color="#94a3b8", fontsize=10.5)

    # Row 1 (Y = 480)
    draw_circle(ax, 110, 480, 50, "START")
    draw_arrow(ax, [[160, 480], [230, 480]])

    draw_box(ax, 335, 480, 195, 80, "DI MENU BAWAH,\nKLIK TAB 'RIWAYAT'", font_size=11)
    draw_arrow(ax, [[433, 480], [503, 480]])

    draw_box(ax, 615, 480, 210, 80, "DIALIHKAN KE\nHALAMAN RIWAYAT", is_redirect=True, font_size=11)
    draw_arrow(ax, [[720, 480], [790, 480]])

    draw_box(ax, 895, 480, 195, 80, "PENGGUNA KLIK\n'+ CATAT SERVIS'", font_size=11)
    draw_arrow(ax, [[993, 480], [1063, 480]])

    draw_box(ax, 1180, 480, 220, 80, "DIALIHKAN KE\nFORM CATAT SERVIS", is_redirect=True, font_size=11)

    # Elbow arrow down to Submit box (Row 2 Y = 220)
    draw_arrow(ax, [[1290, 480], [1400, 480], [1400, 220], [1335, 220]])

    draw_box(ax, 1205, 220, 250, 75, "ISI BIAYA & KLIK 'SIMPAN'", font_size=11)
    draw_arrow(ax, [[1080, 220], [970, 220]])

    draw_box(ax, 830, 220, 260, 75, "DIALIHKAN KEMBALI\nKE RIWAYAT SERVIS", is_redirect=True, font_size=11)
    draw_arrow(ax, [[700, 220], [600, 220]])

    draw_circle(ax, 540, 220, 50, "SELESAI")

    save_fig_as_jpg(fig, os.path.join(OUT_DIR, "07_Flowchart_Riwayat_Servis.jpg"))

# ==============================================================================
# 0. OVERVIEW LENGKAP (MASTER FLOWCHART)
# ==============================================================================
def export_overview_master():
    fig, ax = plt.subplots(figsize=(16, 16), facecolor="#0e1620")
    ax.set_facecolor("#0e1620")
    ax.set_xlim(0, 1600)
    ax.set_ylim(0, 1600)
    ax.axis('off')

    ax.plot([30, 1570], [1080, 1080], color="#1e2c3d", lw=1.5, zorder=1)
    ax.plot([30, 1570], [550, 550], color="#1e2c3d", lw=1.5, zorder=1)

    rect_outer = patches.Rectangle((30, 30), 1540, 1540, fill=False, edgecolor="#1e2c3d", lw=1.8, zorder=1)
    ax.add_patch(rect_outer)

    # Row 1
    draw_box(ax, 140, 1490, 160, 75, "PENGGUNA", is_role=True, font_size=12)
    draw_arrow(ax, [[140, 1452], [140, 1375]])

    draw_circle(ax, 140, 1320, 55, "START")
    draw_arrow(ax, [[195, 1320], [255, 1320]])

    draw_box(ax, 320, 1320, 120, 80, "LOGIN", font_size=11)
    draw_arrow(ax, [[380, 1320], [440, 1320]])

    draw_box(ax, 525, 1320, 160, 80, "DIALIHKAN KE\nHALAMAN BERANDA", is_redirect=True, font_size=9.5)
    draw_arrow(ax, [[605, 1320], [665, 1320]])

    draw_box(ax, 745, 1320, 150, 80, "KLIK TAMBAH\nMOTOR", font_size=10.5)
    draw_arrow(ax, [[820, 1320], [880, 1320]])

    draw_box(ax, 965, 1320, 160, 80, "DIALIHKAN KE\nFORM TAMBAH", is_redirect=True, font_size=9.5)
    draw_arrow(ax, [[1045, 1320], [1105, 1320]])

    draw_box(ax, 1200, 1320, 180, 80, "ISI DATA MOTOR\n(HONDA/YAMAHA)", font_size=10)
    draw_arrow(ax, [[1290, 1320], [1350, 1320]])

    draw_box(ax, 1435, 1320, 160, 80, "DIALIHKAN KE\nUJI MANDIRI", is_redirect=True, font_size=9.5)

    draw_arrow(ax, [[1515, 1320], [1545, 1320], [1545, 1180], [75, 1180], [75, 820], [115, 820]])

    # Row 2
    draw_box(ax, 200, 820, 160, 85, "JAWAB 8\nPERTANYAAN FISIK", font_size=10)
    draw_arrow(ax, [[280, 820], [335, 820]])

    draw_box(ax, 415, 820, 150, 85, "DIALIHKAN KE\nHALAMAN SEHAT", is_redirect=True, font_size=9.5)
    draw_arrow(ax, [[490, 820], [545, 820]])

    draw_box(ax, 635, 820, 170, 85, "LIHAT SKOR\nKESEHATAN MOTOR", font_size=10)
    draw_arrow(ax, [[720, 820], [775, 820]])

    draw_diamond(ax, 850, 820, 140, 100, "ADA\nKELUHAN\nMOTOR ?", font_size=9.5)

    draw_arrow(ax, [[920, 820], [975, 820]], label="IYA", label_pos=[945, 835])

    draw_box(ax, 1050, 820, 140, 85, "DIALIHKAN KE\nTANYA AI", is_redirect=True, font_size=9.5)
    draw_arrow(ax, [[1120, 820], [1175, 820]])

    draw_box(ax, 1265, 820, 170, 85, "INPUT KELUHAN\nKE GEMINI AI", font_size=10)
    draw_arrow(ax, [[1350, 820], [1405, 820]])

    draw_box(ax, 1480, 820, 140, 85, "REKOMENDASI\nSERVIS", font_size=10.5)

    draw_arrow(ax, [[850, 770], [850, 690], [1480, 690], [1480, 777]])
    ax.text(900, 750, "TIDAK", color="#f59e0b", fontsize=10.5, fontweight='bold',
            bbox=dict(boxstyle="square,pad=0.2", facecolor="#0e1620", edgecolor="none"), zorder=5)

    draw_arrow(ax, [[1550, 820], [1565, 820], [1565, 600], [75, 600], [75, 290], [130, 290]])

    # Row 3
    draw_box(ax, 240, 290, 210, 85, "DIALIHKAN KE\nKATALOG SPAREPART", is_redirect=True, font_size=10.5)
    draw_arrow(ax, [[345, 290], [425, 290]])

    draw_box(ax, 535, 290, 210, 85, "LIHAT SPAREPART\nRESMI MOTOR", font_size=10.5)
    draw_arrow(ax, [[640, 290], [720, 290]])

    draw_box(ax, 825, 290, 200, 85, "CATAT RIWAYAT\nSERVIS", font_size=10.5)
    draw_arrow(ax, [[925, 290], [1005, 290]])

    draw_box(ax, 1110, 290, 200, 85, "UPDATE ODOMETER\nRUTIN", font_size=10.5)
    draw_arrow(ax, [[1210, 290], [1300, 290]])

    draw_circle(ax, 1365, 290, 60, "SELESAI", font_size=12)

    save_fig_as_jpg(fig, os.path.join(OUT_DIR, "00_Flowchart_Overview_Lengkap.jpg"))

if __name__ == "__main__":
    print("Exporting all flowcharts as standalone JPG files...")
    export_overview_master()
    export_fitur_1()
    export_fitur_2()
    export_fitur_3()
    export_fitur_4()
    export_fitur_5()
    export_fitur_6()
    export_fitur_7()
    print("All JPGs exported successfully!")
