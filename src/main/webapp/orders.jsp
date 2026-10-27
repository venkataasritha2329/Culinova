
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="com.tap.model.Orders" %>
<%@ page import="com.tap.model.OrderItem" %>
<%@ page import="com.tap.model.Restaurant" %>
<%@ page import="com.tap.model.Menu" %>
<%@ page import="com.tap.model.User" %>
<%@ page import="com.tap.Dao.RestaurantDao" %>
<%@ page import="com.tap.Dao.MenuDao" %>
<%@ page import="com.tap.DaoImpl.RestaurantDaoImpl" %>
<%@ page import="com.tap.DaoImpl.MenuDaoImpl" %>

<%!
    private String escapeHtml(String value) {
        if (value == null) return "";

        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }

    private String formatMoney(double amount) {
        return String.format(Locale.US, "₹%,.2f", amount);
    }

    private String imageUrl(String path, String contextPath) {
        if (path == null || path.trim().isEmpty()) {
            return "";
        }

        path = path.trim();

        if (path.startsWith("https://") || path.startsWith("http://")) {
            return path;
        }

        return contextPath + "/" + path.replaceAll("^/+", "");
    }

    private String statusClass(String status) {
        if (status == null) return "pending";

        String value = status.toLowerCase(Locale.ROOT);

        if (value.contains("cancel") || value.contains("fail")
                || value.contains("reject")) {
            return "cancelled";
        }

        if (value.contains("deliver") || value.contains("complete")
                || value.contains("success")) {
            return "completed";
        }

        if (value.contains("pending") || value.contains("process")
                || value.contains("prepar") || value.contains("placed")) {
            return "pending";
        }

        if (value.contains("confirm")) {
            return "confirmed";
        }

        return "confirmed";
    }
%>

<%
    User loggedInUser = (User) session.getAttribute("user");

    if (loggedInUser == null) {
        loggedInUser = (User) session.getAttribute("loggedInUser");
    }

    if (loggedInUser == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String customerName = "Food Lover";

    if (loggedInUser.getUsername() != null
            && !loggedInUser.getUsername().trim().isEmpty()) {
        customerName = loggedInUser.getUsername().trim();
    }

    List<Orders> orders =
        (List<Orders>) request.getAttribute("orders");

    Map<Integer, List<OrderItem>> orderItemsByOrder =
        (Map<Integer, List<OrderItem>>) request.getAttribute("orderItemsByOrder");

    if (orders == null) {
        orders = new ArrayList<Orders>();
    }

    if (orderItemsByOrder == null) {
        orderItemsByOrder = new HashMap<Integer, List<OrderItem>>();
    }

    RestaurantDao restaurantDao = new RestaurantDaoImpl();
    MenuDao menuDao = new MenuDaoImpl();

    Map<Integer, Restaurant> restaurantCache =
        new HashMap<Integer, Restaurant>();

    Map<Integer, Menu> menuCache =
        new HashMap<Integer, Menu>();

    SimpleDateFormat dateFormat =
        new SimpleDateFormat("dd MMM yyyy, hh:mm a", Locale.ENGLISH);

    String contextPath = request.getContextPath();

    int completedCount = 0;
    int activeCount = 0;
    double totalSpent = 0.0;

    for (Orders order : orders) {
        String s = order.getStatus() == null
            ? ""
            : order.getStatus().toLowerCase(Locale.ROOT);

        if (s.contains("cancel") || s.contains("fail")
                || s.contains("reject")) {
            // Excluded from completed and active counts.
        } else if (s.contains("deliver") || s.contains("complete")
                || s.contains("success")) {
            completedCount++;
            totalSpent += order.getTotalAmount();
        } else {
            activeCount++;
            totalSpent += order.getTotalAmount();
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>My Orders | Culinova</title>

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700;800&family=Playfair+Display:wght@500;600;700&display=swap"
      rel="stylesheet">

<style>
:root {
    --bg: #faf7f2;
    --surface: #ffffff;
    --surface-soft: #fdfaf6;
    --text: #29231f;
    --muted: #81766e;
    --accent: #b85f3b;
    --accent-dark: #984627;
    --accent-soft: #f8e9df;
    --border: #eee4da;
    --green: #20784b;
    --green-bg: #e8f5ec;
    --yellow: #8b600b;
    --yellow-bg: #fff3d6;
    --red: #b42318;
    --red-bg: #fde9e7;
    --shadow: 0 12px 36px rgba(67, 43, 29, .055);
}

* {
    box-sizing: border-box;
    margin: 0;
    padding: 0;
}

html {
    scroll-behavior: smooth;
}

body {
    font-family: 'DM Sans', sans-serif;
    color: var(--text);
    background: var(--bg);
    min-height: 100vh;
    -webkit-font-smoothing: antialiased;
}

button, a {
    font: inherit;
}

a {
    color: inherit;
    text-decoration: none;
}

button {
    -webkit-tap-highlight-color: transparent;
}

button:focus-visible,
a:focus-visible {
    outline: 3px solid rgba(184, 95, 59, .45);
    outline-offset: 4px;
}

.page {
    width: min(1120px, 92%);
    margin: 0 auto;
    padding: 34px 0 60px;
}

/* HERO */

.hero {
    position: relative;
    isolation: isolate;
    overflow: hidden;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 24px;
    min-height: 290px;
    padding: 44px;
    margin-bottom: 27px;
    border-radius: 26px;
    color: white;
    background:
        linear-gradient(100deg,
            rgba(32, 20, 15, .96) 0%,
            rgba(63, 36, 24, .88) 48%,
            rgba(74, 42, 27, .35) 100%),
        url('https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=1600&q=85')
        center 48% / cover no-repeat;
    box-shadow: 0 18px 42px rgba(67, 43, 29, .13);
}

.hero-content {
    position: relative;
    z-index: 1;
    max-width: 660px;
}

.eyebrow {
    display: flex;
    align-items: center;
    gap: 9px;
    margin-bottom: 16px;
    color: #f0c6a9;
    font-size: 10px;
    font-weight: 800;
    letter-spacing: 2.3px;
    text-transform: uppercase;
}

.eyebrow::before {
    content: "";
    width: 25px;
    height: 2px;
    background: #d98a64;
}

.hero h1 {
    max-width: 100%;
    margin-bottom: 14px;
    font-family: 'Playfair Display', serif;
    font-size: clamp(34px, 4.8vw, 49px);
    font-weight: 600;
    line-height: 1.16;
    letter-spacing: -.7px;
    overflow-wrap: anywhere;
}

.hero h1 span {
    color: #edb08e;
}

.hero p {
    max-width: 520px;
    color: rgba(255,255,255,.79);
    font-size: 13px;
    line-height: 1.95;
}

.hero-cta {
    display: inline-flex;
    align-items: center;
    gap: 12px;
    margin-top: 23px;
    padding: 13px 18px;
    border: 1px solid rgba(255,255,255,.7);
    border-radius: 11px;
    background: white;
    color: var(--accent-dark);
    font-size: 12px;
    font-weight: 800;
    transition: transform .2s, background .2s;
}

.hero-cta:hover {
    transform: translateY(-2px);
    background: #fff0e5;
}

.hero-cta span {
    font-size: 17px;
}

.hero-decoration {
    position: relative;
    z-index: 1;
    display: grid;
    width: 106px;
    height: 106px;
    flex-shrink: 0;
    place-items: center;
    border: 1px solid rgba(255,255,255,.25);
    border-radius: 30px;
    background: rgba(255,255,255,.12);
    box-shadow: inset 0 1px rgba(255,255,255,.1);
    backdrop-filter: blur(12px);
    font-size: 46px;
}

/* STATISTICS */

.stats-grid {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 16px;
    margin-bottom: 43px;
}

.stat-card {
    position: relative;
    overflow: hidden;
    display: flex;
    align-items: center;
    gap: 16px;
    min-width: 0;
    padding: 21px;
    border: 1px solid var(--border);
    border-radius: 19px;
    background: var(--surface);
    box-shadow: var(--shadow);
    transition: transform .2s, border-color .2s;
}

.stat-card:hover {
    transform: translateY(-3px);
    border-color: #dfc2ae;
}

.stat-icon {
    display: grid;
    width: 51px;
    height: 51px;
    flex-shrink: 0;
    place-items: center;
    border-radius: 16px;
    background: var(--accent-soft);
    font-size: 23px;
}

.stat-card:nth-child(2) .stat-icon {
    background: var(--green-bg);
}

.stat-card:nth-child(3) .stat-icon {
    background: #f0eaff;
}

.stat-label {
    margin-bottom: 6px;
    color: var(--muted);
    font-size: 11px;
    font-weight: 600;
}

.stat-value {
    font-size: clamp(19px, 2.4vw, 26px);
    font-weight: 800;
    letter-spacing: -.7px;
    overflow-wrap: anywhere;
}

.stat-note {
    margin-top: 5px;
    color: #9a8b80;
    font-size: 10px;
}

/* SECTION HEADER */

.section-heading {
    display: flex;
    align-items: end;
    justify-content: space-between;
    gap: 16px;
    margin: 0 2px 20px;
}

.section-title {
    font-family: 'Playfair Display', serif;
    font-size: 30px;
    font-weight: 600;
    letter-spacing: -.3px;
}

.section-subtitle {
    margin-top: 7px;
    color: var(--muted);
    font-size: 12px;
    line-height: 1.7;
}

.order-count {
    display: inline-flex;
    align-items: center;
    gap: 7px;
    padding: 10px 14px;
    border: 1px solid #ecd7c8;
    border-radius: 30px;
    background: var(--accent-soft);
    color: var(--accent-dark);
    font-size: 11px;
    font-weight: 800;
    white-space: nowrap;
}

/* ORDER CARDS */

.orders-list {
    display: flex;
    flex-direction: column;
    gap: 17px;
}

.order-card {
    overflow: hidden;
    border: 1px solid var(--border);
    border-radius: 21px;
    background: var(--surface);
    box-shadow: var(--shadow);
    animation: cardEnter .4s ease both;
    transition: border-color .2s, box-shadow .2s;
}

.order-card:hover {
    border-color: #e2c5b1;
    box-shadow: 0 15px 38px rgba(67,43,29,.085);
}

.order-summary {
    display: flex;
    align-items: center;
    gap: 20px;
    width: 100%;
    padding: 22px;
    border: 0;
    background: transparent;
    color: inherit;
    text-align: left;
    cursor: pointer;
}

.restaurant-image {
    display: grid;
    width: 116px;
    height: 116px;
    flex-shrink: 0;
    place-items: center;
    overflow: hidden;
    border-radius: 17px;
    background: linear-gradient(135deg, #f6e7da, #f0d4c1);
    color: var(--accent);
    font-size: 34px;
}

.restaurant-image img,
.menu-image img {
    display: block;
    width: 100%;
    height: 100%;
    object-fit: cover;
    transition: transform .35s ease;
}

.order-card:hover .restaurant-image img,
.menu-item:hover .menu-image img {
    transform: scale(1.055);
}

.restaurant-info {
    flex: 1;
    min-width: 0;
}

.restaurant-info h3 {
    margin-bottom: 6px;
    font-family: 'Playfair Display', serif;
    font-size: 22px;
    font-weight: 600;
    line-height: 1.35;
    overflow-wrap: anywhere;
}

.cuisine {
    margin-bottom: 13px;
    color: var(--muted);
    font-size: 11px;
    overflow-wrap: anywhere;
}

.order-meta {
    display: flex;
    flex-wrap: wrap;
    gap: 8px 14px;
    color: var(--muted);
    font-size: 10px;
}

.meta-item {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    min-width: 0;
    overflow-wrap: anywhere;
}

.meta-symbol {
    color: var(--accent);
    font-size: 14px;
}

.order-right {
    display: flex;
    align-items: flex-end;
    flex-shrink: 0;
    flex-direction: column;
    gap: 11px;
}

.status {
    display: inline-flex;
    align-items: center;
    gap: 7px;
    max-width: 155px;
    padding: 8px 11px;
    border-radius: 30px;
    background: var(--green-bg);
    color: var(--green);
    font-size: 10px;
    font-weight: 800;
    text-transform: capitalize;
    overflow-wrap: anywhere;
}

.status-dot {
    width: 7px;
    height: 7px;
    flex-shrink: 0;
    border-radius: 50%;
    background: currentColor;
}

.status.cancelled {
    background: var(--red-bg);
    color: var(--red);
}

.status.pending {
    background: var(--yellow-bg);
    color: var(--yellow);
}

.status.completed,
.status.confirmed {
    background: var(--green-bg);
    color: var(--green);
}

.total {
    font-size: 21px;
    font-weight: 800;
    letter-spacing: -.4px;
    white-space: nowrap;
}

.expand-hint {
    display: flex;
    align-items: center;
    gap: 8px;
    color: var(--accent);
    font-size: 10px;
    font-weight: 800;
}

.chevron {
    display: grid;
    width: 31px;
    height: 31px;
    place-items: center;
    border-radius: 50%;
    background: var(--accent-soft);
    font-size: 18px;
    transition: transform .25s, background .25s;
}

.order-card.open .chevron {
    transform: rotate(180deg);
    background: #efd4c2;
}

/* DETAILS */

.order-details {
    display: none;
    padding: 0 22px 23px;
}

.order-card.open .order-details {
    display: block;
    animation: detailsReveal .25s ease both;
}

.details-divider {
    height: 1px;
    margin-bottom: 22px;
    background: var(--border);
}

.details-heading {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 12px;
    margin-bottom: 15px;
}

.details-heading h4 {
    font-size: 15px;
    font-weight: 800;
}

.items-count {
    color: var(--muted);
    font-size: 10px;
}

/* MENU ITEMS */

.menu-list {
    display: flex;
    flex-direction: column;
    gap: 11px;
}

.menu-item {
    display: flex;
    align-items: center;
    gap: 14px;
    min-width: 0;
    padding: 12px;
    border: 1px solid #f0e8e0;
    border-radius: 15px;
    background: var(--surface-soft);
    transition: border-color .2s, background .2s;
}

.menu-item:hover {
    border-color: #e5c8b4;
    background: #fff9f3;
}

.menu-image {
    display: grid;
    width: 73px;
    height: 73px;
    flex-shrink: 0;
    place-items: center;
    overflow: hidden;
    border-radius: 12px;
    background: #f3e4d7;
    color: var(--accent);
    font-size: 25px;
}

.menu-info {
    flex: 1;
    min-width: 0;
}

.menu-info h5 {
    margin-bottom: 5px;
    font-size: 13px;
    font-weight: 800;
    line-height: 1.5;
    overflow-wrap: anywhere;
}

.menu-info p {
    color: var(--muted);
    font-size: 10px;
    line-height: 1.7;
    overflow-wrap: anywhere;
}

.item-price {
    flex-shrink: 0;
    font-size: 13px;
    font-weight: 800;
    white-space: nowrap;
}

.no-items {
    padding: 19px;
    border: 1px dashed #e7d6c8;
    border-radius: 13px;
    background: var(--surface-soft);
    color: var(--muted);
    font-size: 11px;
    line-height: 1.8;
}

/* ORDER INFORMATION */

.order-footer {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 13px;
    margin-top: 19px;
}

.info-box {
    padding: 16px;
    border: 1px solid #f0e7dc;
    border-radius: 14px;
    background: #faf6f1;
}

.info-box .label {
    display: flex;
    align-items: center;
    gap: 7px;
    margin-bottom: 8px;
    color: var(--muted);
    font-size: 10px;
}

.info-box .value {
    font-size: 13px;
    font-weight: 800;
    overflow-wrap: anywhere;
}

/* EMPTY STATE */

.empty-state {
    padding: 55px 24px;
    border: 1px solid var(--border);
    border-radius: 24px;
    background: var(--surface);
    box-shadow: var(--shadow);
    text-align: center;
}

.empty-icon {
    display: grid;
    width: 88px;
    height: 88px;
    margin: 0 auto 20px;
    place-items: center;
    border: 1px solid #f0ddce;
    border-radius: 27px;
    background: var(--accent-soft);
    font-size: 38px;
}

.empty-state h3 {
    margin-bottom: 11px;
    font-family: 'Playfair Display', serif;
    font-size: 29px;
    font-weight: 600;
}

.empty-state p {
    margin-bottom: 23px;
    color: var(--muted);
    font-size: 12px;
    line-height: 1.9;
}

.primary-btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 10px;
    padding: 13px 20px;
    border: 1px solid var(--accent);
    border-radius: 11px;
    background: var(--accent);
    color: white;
    font-size: 11px;
    font-weight: 800;
    transition: transform .2s, background .2s;
}

.primary-btn:hover {
    transform: translateY(-2px);
    background: var(--accent-dark);
}

/* FOOTER */

.footer {
    padding: 25px 12px 30px;
    color: var(--muted);
    font-size: 10px;
    text-align: center;
}

.footer strong {
    color: var(--accent);
}

/* ANIMATIONS */

@keyframes cardEnter {
    from {
        opacity: 0;
        transform: translateY(10px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

@keyframes detailsReveal {
    from {
        opacity: 0;
        transform: translateY(-4px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

/* TABLET */

@media (max-width: 800px) {
    .page {
        padding-top: 27px;
    }

    .hero {
        min-height: 250px;
        padding: 32px;
    }

    .hero-decoration {
        width: 82px;
        height: 82px;
        border-radius: 23px;
        font-size: 35px;
    }

    .stats-grid {
        gap: 11px;
    }

    .stat-card {
        gap: 11px;
        padding: 16px;
    }

    .stat-icon {
        width: 42px;
        height: 42px;
        border-radius: 13px;
        font-size: 19px;
    }

    .order-summary {
        gap: 14px;
        padding: 18px;
    }

    .restaurant-image {
        width: 94px;
        height: 100px;
    }

    .restaurant-info h3 {
        font-size: 19px;
    }

    .total {
        font-size: 17px;
    }
}

/* MOBILE */

@media (max-width: 600px) {
    .page {
        width: 94%;
        padding-top: 21px;
        padding-bottom: 38px;
    }

    .hero {
        min-height: 220px;
        padding: 27px 22px;
        margin-bottom: 19px;
        border-radius: 21px;
        background-position: center;
    }

    .hero-decoration {
        display: none;
    }

    .hero h1 {
        font-size: 34px;
    }

    .hero p {
        font-size: 12px;
        line-height: 1.85;
    }

    .hero-cta {
        margin-top: 18px;
        padding: 12px 14px;
    }

    .stats-grid {
        grid-template-columns: 1fr;
        gap: 10px;
        margin-bottom: 33px;
    }

    .stat-card {
        padding: 15px 17px;
    }

    .stat-icon {
        width: 45px;
        height: 45px;
    }

    .stat-value {
        font-size: 22px;
    }

    .section-heading {
        align-items: center;
        gap: 9px;
        margin-bottom: 17px;
    }

    .section-title {
        font-size: 26px;
    }

    .section-subtitle {
        font-size: 11px;
    }

    .order-count {
        padding: 8px 10px;
        font-size: 10px;
    }

    .orders-list {
        gap: 13px;
    }

    .order-card {
        border-radius: 17px;
    }

    .order-summary {
        align-items: flex-start;
        gap: 11px;
        padding: 14px;
    }

    .restaurant-image {
        width: 67px;
        height: 74px;
        border-radius: 11px;
    }

    .restaurant-info h3 {
        font-size: 15px;
        margin-bottom: 5px;
    }

    .cuisine {
        margin-bottom: 8px;
        font-size: 10px;
    }

    .order-meta {
        flex-direction: column;
        align-items: flex-start;
        gap: 5px;
        font-size: 9px;
    }

    .order-right {
        gap: 9px;
    }

    .status {
        max-width: 98px;
        padding: 6px 8px;
        font-size: 8px;
    }

    .total {
        font-size: 13px;
    }

    .expand-hint {
        gap: 0;
        font-size: 0;
    }

    .chevron {
        width: 27px;
        height: 27px;
        font-size: 16px;
    }

    .order-details {
        padding: 0 13px 15px;
    }

    .details-divider {
        margin-bottom: 16px;
    }

    .details-heading h4 {
        font-size: 13px;
    }

    .menu-item {
        gap: 10px;
        padding: 9px;
    }

    .menu-image {
        width: 54px;
        height: 56px;
        border-radius: 9px;
    }

    .menu-info h5 {
        font-size: 11px;
    }

    .menu-info p {
        font-size: 9px;
    }

    .item-price {
        font-size: 11px;
    }

    .order-footer {
        grid-template-columns: 1fr;
        gap: 9px;
    }

    .info-box {
        padding: 13px;
    }

    .empty-state {
        padding: 39px 17px;
    }

    .empty-state h3 {
        font-size: 25px;
    }
}

@media (max-width: 390px) {
    .order-summary {
        gap: 8px;
        padding: 11px;
    }

    .restaurant-image {
        width: 54px;
        height: 64px;
    }

    .restaurant-info h3 {
        font-size: 13px;
    }

    .order-meta {
        font-size: 8px;
    }

    .status {
        max-width: 82px;
        font-size: 7px;
    }

    .total {
        font-size: 11px;
    }

    .menu-image {
        width: 46px;
        height: 49px;
    }

    .item-price {
        font-size: 10px;
    }
}

@media (prefers-reduced-motion: reduce) {
    *,
    *::before,
    *::after {
        scroll-behavior: auto !important;
        animation-duration: .01ms !important;
        transition-duration: .01ms !important;
    }
}



/* PREMIUM RESTAURANT ORDER CARDS */

.orders-list {
    display: flex;
    flex-direction: column;
    gap: 20px;
}

.order-card {
    overflow: hidden;
    border: 1px solid var(--border);
    border-radius: 22px;
    background: var(--surface);
    box-shadow: var(--shadow);
    transition: border-color .25s, box-shadow .25s, transform .25s;
    animation: cardEnter .4s ease both;
}

.order-card:hover {
    transform: translateY(-3px);
    border-color: #dcb9a3;
    box-shadow: 0 18px 42px rgba(67, 43, 29, .10);
}

.order-summary {
    display: grid;
    grid-template-columns: 145px minmax(0, 1fr) 190px;
    align-items: center;
    gap: 24px;
    width: 100%;
    padding: 23px;
    border: 0;
    background: transparent;
    color: var(--text);
    text-align: left;
    cursor: pointer;
}

.restaurant-image {
    position: relative;
    display: grid;
    width: 145px;
    height: 145px;
    flex-shrink: 0;
    place-items: center;
    overflow: hidden;
    border-radius: 17px;
    background: var(--accent-soft);
    color: var(--accent);
    font-size: 36px;
}

.restaurant-image img {
    position: absolute;
    inset: 0;
    display: block;
    width: 100%;
    height: 100%;
    object-fit: cover;
    transition: transform .35s ease;
}

.order-card:hover .restaurant-image img {
    transform: scale(1.05);
}

.restaurant-info {
    min-width: 0;
}

.restaurant-info h3 {
    margin-bottom: 7px;
    font-family: 'Playfair Display', serif;
    font-size: 24px;
    font-weight: 600;
    line-height: 1.35;
    overflow-wrap: anywhere;
}

.cuisine {
    margin-bottom: 18px;
    color: var(--muted);
    font-size: 12px;
    line-height: 1.6;
}

.order-meta {
    display: flex;
    flex-wrap: wrap;
    gap: 9px 17px;
    color: var(--muted);
    font-size: 11px;
}

.meta-item {
    display: inline-flex;
    align-items: center;
    gap: 7px;
    min-width: 0;
    overflow-wrap: anywhere;
}

.meta-symbol {
    color: var(--accent);
    font-size: 15px;
}

.order-right {
    display: flex;
    align-items: flex-end;
    flex-direction: column;
    gap: 13px;
    min-width: 0;
}

.status {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 7px;
    max-width: 100%;
    padding: 8px 12px;
    border-radius: 30px;
    background: var(--green-bg);
    color: var(--green);
    font-size: 10px;
    font-weight: 800;
    text-transform: capitalize;
    overflow-wrap: anywhere;
}

.status-dot {
    width: 7px;
    height: 7px;
    flex-shrink: 0;
    border-radius: 50%;
    background: currentColor;
}

.status.cancelled {
    background: var(--red-bg);
    color: var(--red);
}

.status.pending {
    background: var(--yellow-bg);
    color: var(--yellow);
}

.status.completed,
.status.confirmed {
    background: var(--green-bg);
    color: var(--green);
}

.total {
    font-size: 26px;
    font-weight: 800;
    letter-spacing: -.8px;
    white-space: nowrap;
}

.total-label {
    margin-top: -9px;
    color: var(--muted);
    font-size: 10px;
}

.view-details-btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 10px;
    min-height: 40px;
    padding: 10px 14px;
    border: 1px solid var(--accent);
    border-radius: 10px;
    background: var(--accent);
    color: #fff;
    font-size: 11px;
    font-weight: 800;
    white-space: nowrap;
    transition: background .2s, transform .2s;
}

.order-summary:hover .view-details-btn {
    background: var(--accent-dark);
}

.view-details-btn .chevron {
    display: inline-grid;
    width: 18px;
    height: 18px;
    place-items: center;
    font-size: 15px;
    transition: transform .25s;
}

.order-card.open .view-details-btn .chevron {
    transform: rotate(180deg);
}

/* EXPANDABLE ORDER DETAILS */

.order-details {
    display: none;
    padding: 0 23px 23px;
}

.order-card.open .order-details {
    display: block;
    animation: detailsReveal .25s ease both;
}

.details-divider {
    height: 1px;
    margin-bottom: 22px;
    background: var(--border);
}

/* TABLET */

@media (max-width: 850px) {
    .order-summary {
        grid-template-columns: 110px minmax(0, 1fr) 145px;
        gap: 17px;
        padding: 18px;
    }

    .restaurant-image {
        width: 110px;
        height: 120px;
    }

    .restaurant-info h3 {
        font-size: 20px;
    }

    .total {
        font-size: 21px;
    }

    .view-details-btn {
        padding: 9px 11px;
        font-size: 10px;
    }
}

/* MOBILE */

@media (max-width: 600px) {
    .orders-list {
        gap: 14px;
    }

    .order-card {
        border-radius: 17px;
    }

    .order-summary {
        grid-template-columns: 82px minmax(0, 1fr);
        align-items: start;
        gap: 13px;
        padding: 14px;
    }

    .restaurant-image {
        grid-row: 1;
        width: 82px;
        height: 92px;
        border-radius: 12px;
    }

    .restaurant-info {
        grid-column: 2;
        grid-row: 1;
    }

    .restaurant-info h3 {
        font-size: 17px;
    }

    .cuisine {
        margin-bottom: 10px;
        font-size: 10px;
    }

    .order-meta {
        flex-direction: column;
        gap: 6px;
        font-size: 9px;
    }

    .order-right {
        grid-column: 1 / -1;
        display: grid;
        grid-template-columns: 1fr auto;
        align-items: center;
        gap: 10px;
        padding-top: 13px;
        border-top: 1px solid var(--border);
    }

    .status {
        justify-self: start;
        font-size: 9px;
    }

    .total {
        justify-self: end;
        font-size: 20px;
    }

    .total-label {
        display: none;
    }

    .view-details-btn {
        grid-column: 1 / -1;
        width: 100%;
        min-height: 42px;
    }

    .order-details {
        padding: 0 14px 16px;
    }
}

@media (max-width: 350px) {
    .order-summary {
        grid-template-columns: 65px minmax(0, 1fr);
        gap: 10px;
        padding: 11px;
    }

    .restaurant-image {
        width: 65px;
        height: 75px;
    }

    .restaurant-info h3 {
        font-size: 15px;
    }

    .total {
        font-size: 17px;
    }
}

/* DARK THEME — uses the shared navbar theme setting */

html[data-theme="dark"] {
    color-scheme: dark;

    --bg: #171411;
    --surface: #211d19;
    --surface-soft: #29231e;
    --text: #f3ece5;
    --muted: #b3a69b;
    --accent: #d17a54;
    --accent-dark: #b96542;
    --accent-soft: #38271f;
    --border: #3b312a;
    --green: #83d5a3;
    --green-bg: #20392b;
    --yellow: #f1ca72;
    --yellow-bg: #40351f;
    --red: #ff9b91;
    --red-bg: #452522;
    --shadow: 0 12px 36px rgba(0, 0, 0, .18);
}

html[data-theme="dark"] .stat-card,
html[data-theme="dark"] .order-card,
html[data-theme="dark"] .empty-state {
    border-color: var(--border);
}

html[data-theme="dark"] .stat-card:hover,
html[data-theme="dark"] .order-card:hover {
    border-color: #6b4837;
}

html[data-theme="dark"] .stat-card:nth-child(3) .stat-icon {
    background: #332844;
}

html[data-theme="dark"] .menu-item {
    border-color: var(--border);
    background: var(--surface-soft);
}

html[data-theme="dark"] .menu-item:hover {
    border-color: #6b4837;
    background: #302720;
}

html[data-theme="dark"] .info-box {
    border-color: var(--border);
    background: var(--surface-soft);
}

html[data-theme="dark"] .no-items {
    border-color: var(--border);
    background: var(--surface-soft);
}

html[data-theme="dark"] .order-count {
    border-color: var(--border);
    background: var(--accent-soft);
    color: #f0b08f;
}

html[data-theme="dark"] .chevron {
    background: var(--accent-soft);
}

html[data-theme="dark"] .order-card.open .view-details-btn {
    color: #fff;
}

html[data-theme="dark"] .menu-image,
html[data-theme="dark"] .restaurant-image {
    background: var(--accent-soft);
}

html[data-theme="dark"] .empty-icon {
    border-color: var(--border);
    background: var(--accent-soft);
}

</style>
</head>

<body>

<jsp:include page="/navbar.jsp" />

<main class="page">

    <!-- WELCOME HERO -->
    <section class="hero">
        <div class="hero-content">
            <div class="eyebrow">CULINOVA · YOUR ORDER HISTORY</div>

            <h1>Welcome back,<br><span><%= escapeHtml(customerName) %>.</span></h1>

            <p>
                Every great meal creates a memory. Explore your orders,
                revisit the restaurants you love, and get ready for your
                next delicious experience.
            </p>

            <a class="hero-cta"
               href="<%= contextPath %>/restaurant?view=restaurants">
                Explore Restaurants <span>→</span>
            </a>
        </div>

        <div class="hero-decoration" aria-hidden="true">🍽️</div>
    </section>

    <!-- ORDER STATISTICS -->
    <section class="stats-grid" aria-label="Order statistics">

        <div class="stat-card">
            <div class="stat-icon" aria-hidden="true">🧾</div>
            <div>
                <div class="stat-label">Total Orders</div>
                <div class="stat-value"><%= orders.size() %></div>
                <div class="stat-note">Your order history</div>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon" aria-hidden="true">✓</div>
            <div>
                <div class="stat-label">Completed Orders</div>
                <div class="stat-value"><%= completedCount %></div>
                <div class="stat-note">Successfully delivered or completed</div>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon" aria-hidden="true">₹</div>
            <div>
                <div class="stat-label">Order Value</div>
                <div class="stat-value"><%= formatMoney(totalSpent) %></div>
                <div class="stat-note">Excludes cancelled and failed orders</div>
            </div>
        </div>

    </section>

    <!-- ORDER HISTORY HEADER -->
    <section aria-labelledby="ordersHeading">

        <div class="section-heading">
            <div>
                <h2 class="section-title" id="ordersHeading">My Orders</h2>
                <p class="section-subtitle">
                    All your restaurant orders, neatly organised in one place.
                </p>
            </div>

            <span class="order-count">
                <%= orders.size() %>
                <%= orders.size() == 1 ? "ORDER" : "ORDERS" %>
            </span>
        </div>

        <% if (orders.isEmpty()) { %>

            <!-- EMPTY ORDER HISTORY -->
            <section class="empty-state">
                <div class="empty-icon" aria-hidden="true">🛍️</div>

                <h3>Your next favourite meal awaits</h3>

                <p>
                    You haven't placed an order yet.<br>
                    Discover great restaurants and make your first order with Culinova.
                </p>

                <a class="primary-btn"
                   href="<%= contextPath %>/restaurant?view=restaurants">
                    Discover Restaurants <span>→</span>
                </a>
            </section>

        <% } else { %>

            <div class="orders-list">

                <% for (Orders order : orders) {

                    Restaurant restaurant =
                        restaurantCache.get(order.getRestaurantId());

                    if (restaurant == null) {
                        restaurant =
                            restaurantDao.getRestaurant(order.getRestaurantId());

                        if (restaurant != null) {
                            restaurantCache.put(
                                order.getRestaurantId(), restaurant
                            );
                        }
                    }

                    List<OrderItem> items =
                        orderItemsByOrder.get(order.getOrderId());

                    if (items == null) {
                        items = new ArrayList<OrderItem>();
                    }

                    String status = order.getStatus() == null
                        || order.getStatus().trim().isEmpty()
                        ? "Confirmed"
                        : order.getStatus().trim();

                    String paymentMode = order.getPaymentMode() == null
                        || order.getPaymentMode().trim().isEmpty()
                        ? "Not specified"
                        : order.getPaymentMode().trim();

                    String dateText = order.getOrderDate() == null
                        ? "Date unavailable"
                        : dateFormat.format(order.getOrderDate());

                    String restaurantName = restaurant == null
                        ? "Restaurant #" + order.getRestaurantId()
                        : restaurant.getName();

                    String cuisine = restaurant == null
                        ? "Restaurant details unavailable"
                        : restaurant.getCuisineType();

                    String restaurantImage = restaurant == null
                        ? null
                        : restaurant.getImagePath();

                    String cssStatus = statusClass(status);
                %>

                <article class="order-card">

                    <!-- CLICK TO EXPAND ORDER -->
                    
<button class="order-summary"
        type="button"
        aria-expanded="false"
        aria-controls="order-details-<%= order.getOrderId() %>">

    <div class="restaurant-image">
        <% if (restaurantImage != null
                && !restaurantImage.trim().isEmpty()) { %>

            <img
                src="<%= escapeHtml(imageUrl(restaurantImage, contextPath)) %>"
                alt="<%= escapeHtml(restaurantName) %>"
                loading="lazy"
                onerror="this.style.display='none';">

        <% } else { %>
            <span aria-hidden="true">🍴</span>
        <% } %>
    </div>

    <div class="restaurant-info">
        <h3><%= escapeHtml(restaurantName) %></h3>

        <div class="cuisine">
            <%= escapeHtml(cuisine == null ? "Restaurant" : cuisine) %>
        </div>

        <div class="order-meta">
            <span class="meta-item">
                <span class="meta-symbol" aria-hidden="true">#</span>
                Order <%= order.getOrderId() %>
            </span>

            <span class="meta-item">
                <span class="meta-symbol" aria-hidden="true">◷</span>
                <%= escapeHtml(dateText) %>
            </span>
        </div>
    </div>

    <div class="order-right">
        <span class="status <%= cssStatus %>">
            <span class="status-dot" aria-hidden="true"></span>
            <%= escapeHtml(status) %>
        </span>

        <div class="total">
            <%= formatMoney(order.getTotalAmount()) %>
        </div>

        <div class="total-label">Total order amount</div>

        <span class="view-details-btn">
            View Order Details
            <span class="chevron" aria-hidden="true">↓</span>
        </span>
    </div>

</button>


                    <!-- EXPANDABLE DETAILS -->
                    <div class="order-details"
                         id="order-details-<%= order.getOrderId() %>">

                        <div class="details-divider"></div>

                        <div class="details-heading">
                            <h4>Items in your order</h4>

                            <span class="items-count">
                                <%= items.size() %>
                                <%= items.size() == 1 ? "ITEM" : "ITEMS" %>
                            </span>
                        </div>

                        <% if (items.isEmpty()) { %>

                            <div class="no-items">
                                No menu items were found for this order.
                                Please verify the order-item records in your database.
                            </div>

                        <% } else { %>

                            <div class="menu-list">

                                <% for (OrderItem item : items) {

                                    Menu menu = menuCache.get(item.getMenuId());

                                    if (menu == null) {
                                        menu = menuDao.getMenu(item.getMenuId());

                                        if (menu != null) {
                                            menuCache.put(item.getMenuId(), menu);
                                        }
                                    }

                                    String menuName = menu == null
                                        ? "Menu item #" + item.getMenuId()
                                        : menu.getItemName();

                                    String menuImage = menu == null
                                        ? null
                                        : menu.getImagePath();

                                    String description = menu == null
                                        ? "Menu details unavailable"
                                        : menu.getDescription();
                                %>

                                <div class="menu-item">

                                    <div class="menu-image">
                                        <% if (menuImage != null
                                                && !menuImage.trim().isEmpty()) { %>

                                            <img
                                                src="<%= escapeHtml(imageUrl(menuImage, contextPath)) %>"
                                                alt="<%= escapeHtml(menuName) %>"
                                                loading="lazy"
                                                onerror="this.style.display='none';this.nextElementSibling.style.display='grid';">

                                            <span style="display:none;"
                                                  aria-hidden="true">🍲</span>

                                        <% } else { %>
                                            <span aria-hidden="true">🍲</span>
                                        <% } %>
                                    </div>

                                    <div class="menu-info">
                                        <h5><%= escapeHtml(menuName) %></h5>

                                        <p>
                                            <%= escapeHtml(description == null
                                                ? ""
                                                : description) %>
                                        </p>
                                    </div>

                                    <div class="item-price">
                                        <%= formatMoney(item.getTotalAmount()) %>
                                    </div>

                                </div>

                                <% } %>

                            </div>

                        <% } %>

                        <!-- PAYMENT INFORMATION -->
                        <div class="order-footer">

                            <div class="info-box">
                                <div class="label">
                                    <span aria-hidden="true">◈</span>
                                    Payment Method
                                </div>

                                <div class="value">
                                    <%= escapeHtml(paymentMode) %>
                                </div>
                            </div>

                            <div class="info-box">
                                <div class="label">
                                    <span aria-hidden="true">₹</span>
                                    Total Order Amount
                                </div>

                                <div class="value">
                                    <%= formatMoney(order.getTotalAmount()) %>
                                </div>
                            </div>

                        </div>

                    </div>

                </article>

                <% } %>

            </div>

        <% } %>

    </section>

</main>

<footer class="footer">
    Made with <strong>♥ Culinova</strong> · Good food, happy moments.
</footer>

<script>
(function () {
    "use strict";

    const cards = document.querySelectorAll(".order-card");

    cards.forEach(function (card) {
        const summary = card.querySelector(".order-summary");
        const details = card.querySelector(".order-details");

        if (!summary || !details) {
            return;
        }

        summary.addEventListener("click", function () {
            const isOpen = card.classList.toggle("open");

            summary.setAttribute("aria-expanded", String(isOpen));

            details.setAttribute("aria-hidden", String(!isOpen));
        });

        details.setAttribute("aria-hidden", "true");
    });
})();
</script>

</body>
</html>
