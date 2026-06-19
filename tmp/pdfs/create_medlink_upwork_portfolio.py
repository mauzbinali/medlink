from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfgen import canvas


OUTPUT = "output/pdf/medlink_upwork_portfolio.pdf"
PAGE_W, PAGE_H = A4

PRIMARY = colors.HexColor("#1368D8")
TEAL = colors.HexColor("#12B8A6")
INK = colors.HexColor("#102033")
MUTED = colors.HexColor("#637083")
LINE = colors.HexColor("#E5EAF1")
SKY = colors.HexColor("#EAF4FF")
MINT = colors.HexColor("#E7F8F4")
DARK = colors.HexColor("#0B1118")
SURFACE = colors.HexColor("#F7FAFD")
WHITE = colors.white
WARN = colors.HexColor("#FFB547")
SUCCESS = colors.HexColor("#16A66A")


def text_width(text, font="Helvetica", size=10):
    return pdfmetrics.stringWidth(text, font, size)


def wrap_text(text, max_width, font="Helvetica", size=10):
    words = text.split()
    lines = []
    line = ""
    for word in words:
        candidate = word if not line else f"{line} {word}"
        if text_width(candidate, font, size) <= max_width:
            line = candidate
        else:
            if line:
                lines.append(line)
            line = word
    if line:
        lines.append(line)
    return lines


def draw_wrapped(c, text, x, y, max_width, font="Helvetica", size=10, color=INK, leading=14):
    c.setFont(font, size)
    c.setFillColor(color)
    for line in wrap_text(text, max_width, font, size):
        c.drawString(x, y, line)
        y -= leading
    return y


def rounded(c, x, y, w, h, fill=WHITE, stroke=LINE, r=8, width=1):
    c.setStrokeColor(stroke)
    c.setFillColor(fill)
    c.setLineWidth(width)
    c.roundRect(x, y, w, h, r, stroke=1, fill=1)


def pill(c, x, y, text, fill, color=INK, font="Helvetica-Bold", size=8):
    pad_x = 8
    w = text_width(text, font, size) + pad_x * 2
    h = 18
    rounded(c, x, y, w, h, fill=fill, stroke=fill, r=9, width=0.5)
    c.setFillColor(color)
    c.setFont(font, size)
    c.drawString(x + pad_x, y + 5.2, text)
    return w


def page_bg(c):
    c.setFillColor(SURFACE)
    c.rect(0, 0, PAGE_W, PAGE_H, stroke=0, fill=1)
    c.setFillColor(colors.HexColor("#EEF8FF"))
    c.circle(PAGE_W - 35 * mm, PAGE_H - 25 * mm, 38 * mm, stroke=0, fill=1)
    c.setFillColor(colors.HexColor("#EAFBF7"))
    c.circle(20 * mm, 18 * mm, 32 * mm, stroke=0, fill=1)


def footer(c, page):
    c.setStrokeColor(LINE)
    c.line(18 * mm, 15 * mm, PAGE_W - 18 * mm, 15 * mm)
    c.setFont("Helvetica", 8)
    c.setFillColor(MUTED)
    c.drawString(18 * mm, 10 * mm, "MedLink - Doctor Appointment & Telemedicine App")
    c.drawRightString(PAGE_W - 18 * mm, 10 * mm, f"Page {page}")


def title(c, heading, subheading=None):
    c.setFillColor(INK)
    c.setFont("Helvetica-Bold", 22)
    c.drawString(18 * mm, PAGE_H - 28 * mm, heading)
    if subheading:
        c.setFont("Helvetica", 10.5)
        c.setFillColor(MUTED)
        c.drawString(18 * mm, PAGE_H - 36 * mm, subheading)


def metric_card(c, x, y, w, label, value, accent=PRIMARY):
    rounded(c, x, y, w, 30 * mm, fill=WHITE, stroke=LINE, r=9)
    c.setFillColor(accent)
    c.roundRect(x + 10, y + 30 * mm - 14, 26, 6, 3, stroke=0, fill=1)
    c.setFont("Helvetica-Bold", 18)
    c.setFillColor(INK)
    c.drawString(x + 10, y + 12 * mm, value)
    c.setFont("Helvetica", 8.5)
    c.setFillColor(MUTED)
    c.drawString(x + 10, y + 6 * mm, label)


def draw_phone(c, x, y, w, h, mode="home"):
    c.setFillColor(DARK)
    c.roundRect(x, y, w, h, 20, stroke=0, fill=1)
    c.setFillColor(colors.HexColor("#111C29"))
    c.roundRect(x + 6, y + 6, w - 12, h - 12, 16, stroke=0, fill=1)
    c.setFillColor(colors.HexColor("#1B2A3D"))
    c.roundRect(x + w / 2 - 18, y + h - 14, 36, 4, 2, stroke=0, fill=1)

    if mode == "home":
        c.setFillColor(WHITE)
        c.setFont("Helvetica-Bold", 9)
        c.drawString(x + 16, y + h - 32, "Hello, Patient")
        c.setFont("Helvetica", 6.7)
        c.setFillColor(colors.HexColor("#AFC1D6"))
        c.drawString(x + 16, y + h - 42, "Lahore, Pakistan")
        c.setFillColor(PRIMARY)
        c.roundRect(x + 16, y + h - 92, w - 32, 38, 8, stroke=0, fill=1)
        c.setFillColor(TEAL)
        c.roundRect(x + w - 72, y + h - 92, 56, 38, 8, stroke=0, fill=1)
        c.setFillColor(WHITE)
        c.setFont("Helvetica-Bold", 8)
        c.drawString(x + 24, y + h - 70, "Need a doctor today?")
        c.setFont("Helvetica", 6.2)
        c.drawString(x + 24, y + h - 80, "Book clinic or online visits")
        icon_y = y + h - 122
        for i, label in enumerate(["Book", "Online", "Visits", "Records"]):
            ix = x + 16 + i * ((w - 32) / 4)
            c.setFillColor(MINT)
            c.roundRect(ix, icon_y, 26, 24, 6, stroke=0, fill=1)
            c.setFillColor(WHITE)
            c.setFont("Helvetica", 5.5)
            c.drawCentredString(ix + 13, icon_y - 9, label)
        c.setFont("Helvetica-Bold", 8)
        c.drawString(x + 16, y + h - 155, "Top Rated Doctors")
        for i in range(3):
            yy = y + h - 188 - i * 34
            rounded(c, x + 16, yy, w - 32, 26, fill=colors.HexColor("#162334"), stroke=colors.HexColor("#233247"), r=6)
            c.setFillColor(colors.HexColor("#72D5CA"))
            c.circle(x + 29, yy + 13, 8, stroke=0, fill=1)
            c.setFillColor(WHITE)
            c.setFont("Helvetica-Bold", 6.5)
            c.drawString(x + 42, yy + 15, ["Dr. Ayesha Khan", "Dr. Ahmed Raza", "Dr. Fatima Noor"][i])
            c.setFont("Helvetica", 5.5)
            c.setFillColor(colors.HexColor("#B8C8D9"))
            c.drawString(x + 42, yy + 7, ["General Physician", "Cardiologist", "Dermatologist"][i])

    elif mode == "dashboard":
        c.setFillColor(WHITE)
        c.setFont("Helvetica-Bold", 9)
        c.drawString(x + 16, y + h - 32, "Admin Dashboard")
        card_w = (w - 42) / 2
        for i, (label, value, col) in enumerate([
            ("Patients", "1841", TEAL),
            ("Doctors", "10", PRIMARY),
            ("Bookings", "24", WARN),
            ("Revenue", "PKR 52k", SUCCESS),
        ]):
            xx = x + 16 + (i % 2) * (card_w + 10)
            yy = y + h - 82 - (i // 2) * 44
            rounded(c, xx, yy, card_w, 34, fill=colors.HexColor("#162334"), stroke=colors.HexColor("#233247"), r=7)
            c.setFillColor(col)
            c.roundRect(xx + 8, yy + 22, 22, 5, 3, stroke=0, fill=1)
            c.setFillColor(WHITE)
            c.setFont("Helvetica-Bold", 8)
            c.drawString(xx + 8, yy + 12, value)
            c.setFillColor(colors.HexColor("#B8C8D9"))
            c.setFont("Helvetica", 5.7)
            c.drawString(xx + 8, yy + 5, label)
        c.setFont("Helvetica-Bold", 8)
        c.setFillColor(WHITE)
        c.drawString(x + 16, y + h - 178, "Appointments Trend")
        base_y = y + h - 236
        c.setStrokeColor(PRIMARY)
        c.setLineWidth(2)
        points = [(x + 22, base_y + 10), (x + 55, base_y + 34), (x + 88, base_y + 22), (x + 121, base_y + 47), (x + 154, base_y + 42)]
        for a, b in zip(points, points[1:]):
            c.line(a[0], a[1], b[0], b[1])
        for px, py in points:
            c.setFillColor(TEAL)
            c.circle(px, py, 3, stroke=0, fill=1)

    else:
        c.setFillColor(WHITE)
        c.setFont("Helvetica-Bold", 9)
        c.drawString(x + 16, y + h - 32, "Book Appointment")
        rounded(c, x + 16, y + h - 82, w - 32, 36, fill=colors.HexColor("#162334"), stroke=colors.HexColor("#233247"), r=7)
        c.setFillColor(TEAL)
        c.circle(x + 32, y + h - 64, 9, stroke=0, fill=1)
        c.setFillColor(WHITE)
        c.setFont("Helvetica-Bold", 7)
        c.drawString(x + 48, y + h - 62, "Dr. Sara Iqbal")
        c.setFont("Helvetica", 5.8)
        c.setFillColor(colors.HexColor("#B8C8D9"))
        c.drawString(x + 48, y + h - 71, "Pediatrician - PKR 1800")
        button_width = (w - 42) / 2
        for i, label in enumerate(["Clinic", "Online"]):
            xx = x + 16 + i * (button_width + 10)
            rounded(c, xx, y + h - 122, button_width, 22, fill=PRIMARY if i == 1 else colors.HexColor("#162334"), stroke=colors.HexColor("#233247"), r=6)
            c.setFillColor(WHITE)
            c.setFont("Helvetica-Bold", 6.5)
            c.drawCentredString(xx + button_width / 2, y + h - 113, label)
        c.setFont("Helvetica-Bold", 7.5)
        c.drawString(x + 16, y + h - 150, "Available Slots")
        slot_width = (w - 42) / 2
        for i, slot in enumerate(["10:00 AM", "11:30 AM", "5:00 PM", "7:00 PM"]):
            xx = x + 16 + (i % 2) * (slot_width + 10)
            yy = y + h - 180 - (i // 2) * 30
            rounded(c, xx, yy, slot_width, 21, fill=colors.HexColor("#162334"), stroke=colors.HexColor("#233247"), r=6)
            c.setFillColor(WHITE)
            c.setFont("Helvetica", 6.2)
            c.drawCentredString(xx + slot_width / 2, yy + 8, slot)
        rounded(c, x + 16, y + 20, w - 32, 26, fill=TEAL, stroke=TEAL, r=7)
        c.setFont("Helvetica-Bold", 7)
        c.setFillColor(WHITE)
        c.drawCentredString(x + w / 2, y + 29, "Confirm Booking")


def cover(c):
    page_bg(c)
    c.setFillColor(PRIMARY)
    c.roundRect(18 * mm, PAGE_H - 56 * mm, 72, 24, 12, stroke=0, fill=1)
    c.setFillColor(WHITE)
    c.setFont("Helvetica-Bold", 11)
    c.drawCentredString(18 * mm + 36, PAGE_H - 53 * mm, "MEDLINK")

    c.setFillColor(INK)
    c.setFont("Helvetica-Bold", 32)
    c.drawString(18 * mm, PAGE_H - 76 * mm, "MedLink")
    y = draw_wrapped(
        c,
        "Doctor Appointment & Telemedicine App",
        18 * mm,
        PAGE_H - 88 * mm,
        95 * mm,
        font="Helvetica-Bold",
        size=17,
        color=INK,
        leading=20,
    )
    y -= 12
    y = draw_wrapped(
        c,
        "A production-ready Flutter healthcare app concept for booking doctors, managing appointments, telemedicine consultations, prescriptions, medical records, payments, and admin operations.",
        18 * mm,
        y,
        91 * mm,
        size=10.5,
        color=MUTED,
        leading=15,
    )
    y -= 9
    x = 18 * mm
    for label, fill in [
        ("Flutter Android / iOS", SKY),
        ("Firebase-ready", MINT),
        ("Riverpod + go_router", SKY),
        ("Animated UI", MINT),
    ]:
        w = pill(c, x, y, label, fill, color=INK)
        x += w + 6
        if x > 98 * mm:
            x = 18 * mm
            y -= 23

    draw_phone(c, PAGE_W - 82 * mm, PAGE_H - 158 * mm, 58 * mm, 118 * mm, "home")

    metric_y = 54 * mm
    metric_card(c, 18 * mm, metric_y, 39 * mm, "Specialties", "12", TEAL)
    metric_card(c, 63 * mm, metric_y, 39 * mm, "Doctor profiles", "10", PRIMARY)
    metric_card(c, 108 * mm, metric_y, 39 * mm, "Portals", "3", WARN)
    metric_card(c, 153 * mm, metric_y, 39 * mm, "Core flows", "14+", SUCCESS)
    footer(c, 1)


def overview(c):
    page_bg(c)
    title(c, "Project Overview", "A polished healthcare marketplace app designed to impress clients and support real startup workflows.")

    x = 18 * mm
    y = PAGE_H - 55 * mm
    rounded(c, x, y - 52 * mm, 82 * mm, 52 * mm, fill=WHITE, stroke=LINE, r=10)
    c.setFont("Helvetica-Bold", 14)
    c.setFillColor(INK)
    c.drawString(x + 10, y - 10, "Problem")
    draw_wrapped(
        c,
        "Patients need a simple way to discover trusted doctors, compare fees, choose clinic or online visits, and keep prescriptions and reports organized.",
        x + 10,
        y - 26,
        68 * mm,
        size=9.3,
        color=MUTED,
        leading=13,
    )
    rounded(c, x + 92 * mm, y - 52 * mm, 82 * mm, 52 * mm, fill=WHITE, stroke=LINE, r=10)
    c.setFont("Helvetica-Bold", 14)
    c.setFillColor(INK)
    c.drawString(x + 92 * mm + 10, y - 10, "Solution")
    draw_wrapped(
        c,
        "MedLink combines booking, doctor management, telemedicine UI, medical records, PDF prescriptions, payments, notifications, and admin approval tools in one Flutter app.",
        x + 92 * mm + 10,
        y - 26,
        68 * mm,
        size=9.3,
        color=MUTED,
        leading=13,
    )

    c.setFont("Helvetica-Bold", 16)
    c.setFillColor(INK)
    c.drawString(18 * mm, PAGE_H - 124 * mm, "Core User Journey")
    steps = [
        ("01", "Onboard", "Splash, onboarding, role selection, login/register"),
        ("02", "Discover", "Search doctors, specialties, filters, favorites"),
        ("03", "Book", "Consultation type, date, slot, reports, payment"),
        ("04", "Care", "Video consultation UI, chat, prescriptions, records"),
        ("05", "Manage", "Doctor dashboard and admin operations"),
    ]
    start_x = 18 * mm
    y = PAGE_H - 145 * mm
    for i, (num, label, desc) in enumerate(steps):
        xx = start_x + i * 34 * mm
        c.setFillColor(PRIMARY if i % 2 == 0 else TEAL)
        c.circle(xx + 8, y + 12, 9, stroke=0, fill=1)
        c.setFillColor(WHITE)
        c.setFont("Helvetica-Bold", 7)
        c.drawCentredString(xx + 8, y + 9.5, num)
        c.setFillColor(INK)
        c.setFont("Helvetica-Bold", 9)
        c.drawString(xx, y - 4, label)
        draw_wrapped(c, desc, xx, y - 17, 28 * mm, size=6.7, color=MUTED, leading=8)

    draw_phone(c, 28 * mm, 30 * mm, 48 * mm, 98 * mm, "booking")
    draw_phone(c, 82 * mm, 30 * mm, 48 * mm, 98 * mm, "home")
    draw_phone(c, 136 * mm, 30 * mm, 48 * mm, 98 * mm, "dashboard")
    footer(c, 2)


def feature_matrix(c):
    page_bg(c)
    title(c, "Feature Matrix", "Role-based modules built for patients, doctors, and admins.")

    columns = [
        (
            "Patient App",
            PRIMARY,
            [
                "Splash, onboarding, login, register, forgot password",
                "Role selection with patient / doctor / admin routing",
                "Home dashboard with quick actions and health tips",
                "Specialties, doctor search, filters, doctor details",
                "Favorites, reviews, ratings, and doctor profiles",
                "Appointment booking with date, slot, reports, symptoms",
                "My appointments, details, cancel and reschedule",
                "Medical records, prescriptions, payments, notifications",
            ],
        ),
        (
            "Doctor App",
            TEAL,
            [
                "Dashboard with today, pending, completed, earnings",
                "Pending requests with accept / reject actions",
                "Patient detail screen with reports and records",
                "Manage availability and slots",
                "Write prescriptions with medicine details",
                "Follow-up date, diagnosis, instructions",
                "Video consultation mock screen",
                "Doctor profile and logout flow",
            ],
        ),
        (
            "Admin Panel",
            WARN,
            [
                "Admin dashboard with metrics and chart",
                "View patients, doctors, appointments, payments",
                "Approve, suspend, or reject doctors",
                "Revenue and payment overview",
                "Manage health tips for patients",
                "Doctor approval status persistence",
                "Logout confirmation flow",
                "Responsive dashboard-style UI",
            ],
        ),
    ]
    col_w = 54 * mm
    for i, (name, accent, items) in enumerate(columns):
        x = 18 * mm + i * (col_w + 7 * mm)
        y = PAGE_H - 58 * mm
        rounded(c, x, 31 * mm, col_w, 190 * mm, fill=WHITE, stroke=LINE, r=10)
        c.setFillColor(accent)
        c.roundRect(x, PAGE_H - 58 * mm, col_w, 18 * mm, 10, stroke=0, fill=1)
        c.rect(x, PAGE_H - 58 * mm, col_w, 9 * mm, stroke=0, fill=1)
        c.setFillColor(WHITE)
        c.setFont("Helvetica-Bold", 13)
        c.drawCentredString(x + col_w / 2, PAGE_H - 51 * mm, name)
        yy = PAGE_H - 70 * mm
        for item in items:
            c.setFillColor(accent)
            c.circle(x + 7, yy + 3, 2.1, stroke=0, fill=1)
            yy = draw_wrapped(c, item, x + 14, yy + 6, col_w - 21, size=8.4, color=INK, leading=11)
            yy -= 6
    footer(c, 3)


def technical(c):
    page_bg(c)
    title(c, "Technical Implementation", "Clean Flutter architecture with Firebase-ready services and portfolio-grade UI polish.")

    sections = [
        ("Frontend", ["Flutter", "Material 3", "Responsive Framework", "Google Fonts", "Iconsax"]),
        ("State & Routing", ["Riverpod", "go_router", "Shared Preferences", "Hive-ready local storage"]),
        ("Backend Ready", ["Firebase Auth", "Cloud Firestore", "Firebase Storage", "Firebase Messaging"]),
        ("Experience", ["flutter_animate", "Shimmer loading", "Hero transitions", "Dark mode", "Empty states"]),
        ("Documents", ["Prescription PDF", "Receipt PDF", "Share/download with printing package"]),
        ("Quality", ["Analyzer clean", "Widget test passing", "Debug APK build passing"]),
    ]
    x0 = 18 * mm
    y0 = PAGE_H - 60 * mm
    card_w = 54 * mm
    card_h = 42 * mm
    for i, (heading, chips) in enumerate(sections):
        x = x0 + (i % 3) * (card_w + 8 * mm)
        y = y0 - (i // 3) * (card_h + 12 * mm)
        rounded(c, x, y - card_h, card_w, card_h, fill=WHITE, stroke=LINE, r=10)
        c.setFillColor(PRIMARY if i % 2 == 0 else TEAL)
        c.roundRect(x + 9, y - 12, 26, 6, 3, stroke=0, fill=1)
        c.setFont("Helvetica-Bold", 12)
        c.setFillColor(INK)
        c.drawString(x + 9, y - 24, heading)
        yy = y - 36
        c.setFont("Helvetica", 7.8)
        c.setFillColor(MUTED)
        for chip in chips:
            c.drawString(x + 9, yy, f"- {chip}")
            yy -= 10

    c.setFont("Helvetica-Bold", 16)
    c.setFillColor(INK)
    c.drawString(18 * mm, PAGE_H - 165 * mm, "Architecture Snapshot")
    y = PAGE_H - 180 * mm
    nodes = [
        ("UI Screens", "Auth, Patient, Doctor, Admin"),
        ("State Layer", "Riverpod Notifier AppState"),
        ("Services", "Firestore, Storage, FCM, PDF"),
        ("Data", "Demo state + Firebase-ready models"),
    ]
    for i, (head, body) in enumerate(nodes):
        x = 18 * mm + i * 43 * mm
        rounded(c, x, y - 30 * mm, 38 * mm, 30 * mm, fill=WHITE, stroke=LINE, r=9)
        c.setFillColor(TEAL if i % 2 else PRIMARY)
        c.circle(x + 9, y - 9, 5, stroke=0, fill=1)
        c.setFont("Helvetica-Bold", 9)
        c.setFillColor(INK)
        c.drawString(x + 18, y - 11, head)
        draw_wrapped(c, body, x + 9, y - 22, 30 * mm, size=7.2, color=MUTED, leading=9)
        if i < len(nodes) - 1:
            c.setStrokeColor(LINE)
            c.setLineWidth(1.2)
            c.line(x + 38 * mm, y - 15 * mm, x + 43 * mm, y - 15 * mm)
    footer(c, 4)


def delivery(c):
    page_bg(c)
    title(c, "Portfolio Value", "Why this project helps clients trust the developer behind it.")

    rounded(c, 18 * mm, PAGE_H - 100 * mm, 174 * mm, 52 * mm, fill=WHITE, stroke=LINE, r=10)
    c.setFont("Helvetica-Bold", 14)
    c.setFillColor(INK)
    c.drawString(28 * mm, PAGE_H - 62 * mm, "What a client sees")
    client_points = [
        "A complete multi-role healthcare app, not just static screens.",
        "Modern mobile UI with animations, dark mode, responsive layout, and polished empty states.",
        "Real business workflows: booking, payments, prescriptions, records, admin approvals, and notifications.",
        "Firebase-ready architecture that can be connected to a production backend.",
    ]
    yy = PAGE_H - 76 * mm
    for point in client_points:
        c.setFillColor(TEAL)
        c.circle(29 * mm, yy + 3, 2.4, stroke=0, fill=1)
        yy = draw_wrapped(c, point, 34 * mm, yy + 6, 142 * mm, size=9, color=INK, leading=12)
        yy -= 4

    c.setFont("Helvetica-Bold", 14)
    c.setFillColor(INK)
    c.drawString(18 * mm, PAGE_H - 122 * mm, "Verified quality")
    q = [
        ("flutter analyze", "No issues found"),
        ("flutter test", "All tests passed"),
        ("flutter build apk --debug", "Debug APK built successfully"),
        ("Firebase rules", "Firestore and Storage rules included"),
    ]
    for i, (cmd, result) in enumerate(q):
        x = 18 * mm + (i % 2) * 88 * mm
        y = PAGE_H - 142 * mm - (i // 2) * 32 * mm
        rounded(c, x, y - 23 * mm, 82 * mm, 23 * mm, fill=WHITE, stroke=LINE, r=9)
        c.setFont("Helvetica-Bold", 8.8)
        c.setFillColor(PRIMARY)
        c.drawString(x + 8, y - 9, cmd)
        c.setFont("Helvetica", 8.2)
        c.setFillColor(MUTED)
        c.drawString(x + 8, y - 19, result)

    rounded(c, 18 * mm, 30 * mm, 174 * mm, 45 * mm, fill=DARK, stroke=DARK, r=12)
    c.setFillColor(WHITE)
    c.setFont("Helvetica-Bold", 17)
    c.drawString(30 * mm, 58 * mm, "Available for custom Flutter apps")
    draw_wrapped(
        c,
        "Use MedLink as a portfolio proof for appointment apps, booking platforms, telemedicine concepts, dashboards, Firebase MVPs, and polished mobile UI projects.",
        30 * mm,
        47 * mm,
        138 * mm,
        size=9.4,
        color=colors.HexColor("#D7E7F7"),
        leading=12,
    )
    pill(c, 30 * mm, 34 * mm, "Flutter", SKY, color=INK)
    pill(c, 55 * mm, 34 * mm, "Firebase", MINT, color=INK)
    pill(c, 86 * mm, 34 * mm, "Healthcare", SKY, color=INK)
    pill(c, 124 * mm, 34 * mm, "Upwork Portfolio", MINT, color=INK)
    footer(c, 5)


def build_pdf():
    c = canvas.Canvas(OUTPUT, pagesize=A4)
    cover(c)
    c.showPage()
    overview(c)
    c.showPage()
    feature_matrix(c)
    c.showPage()
    technical(c)
    c.showPage()
    delivery(c)
    c.save()


if __name__ == "__main__":
    build_pdf()
