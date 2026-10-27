
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="com.tap.model.Orders" %>
<%@ page import="com.tap.model.User" %>
<%@ page import="com.tap.util.DBConnection" %>

<%
    User user = (User) session.getAttribute("user");

    if (user == null) {
        user = (User) session.getAttribute("loggedInUser");
    }

    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    Orders order =
        (Orders) session.getAttribute("lastSuccessfulOrder");

    if (order == null) {
        response.sendRedirect(
            request.getContextPath() + "/orders.jsp"
        );
        return;
    }

    String contextPath = request.getContextPath();

    String orderDate = "Recently placed";

    if (order.getOrderDate() != null) {
        orderDate = new SimpleDateFormat(
            "dd MMM yyyy, hh:mm a",
            Locale.ENGLISH
        ).format(order.getOrderDate());
    }

    String paymentMode = order.getPaymentMode() == null
        ? "Not specified"
        : order.getPaymentMode();

    String orderStatus = order.getStatus() == null
        ? "Confirmed"
        : order.getStatus();

    String formattedTotal = String.format(
        Locale.US, "%.2f", order.getTotalAmount()
    );

    List<Map<String, Object>> orderedItems = new ArrayList<>();

    String itemSql =
        "SELECT m.item_name, oi.total_amount " +
        "FROM orderitem oi " +
        "JOIN menu m ON oi.menu_id = m.menu_id " +
        "WHERE oi.order_id = ? " +
        "ORDER BY oi.order_item_id ASC";

    try (
        Connection con = DBConnection.getConnection();
        PreparedStatement ps = con.prepareStatement(itemSql)
    ) {
        ps.setInt(1, order.getOrderId());

        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> item = new HashMap<>();
                item.put("itemName", rs.getString("item_name"));
                item.put("totalAmount", rs.getDouble("total_amount"));
                orderedItems.add(item);
            }
        }
    } catch (Exception e) {
        application.log(
            "Error loading items for order " + order.getOrderId(), e
        );
    }

    boolean isConfirmed =
        orderStatus.equalsIgnoreCase("confirmed")
        || orderStatus.equalsIgnoreCase("placed")
        || orderStatus.equalsIgnoreCase("pending")
        || orderStatus.equalsIgnoreCase("success")
        || orderStatus.equalsIgnoreCase("completed");
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Order Confirmed | Culinova</title>

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>

<link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Playfair+Display:wght@600;700&display=swap"
      rel="stylesheet">

<style>
:root {
    --cream: #FAF7F2;
    --white: #FFFFFF;
    --terracotta: #B84F2B;
    --terracotta-dark: #963C20;
    --ink: #18221A;
    --muted: #766D64;
    --line: #E9DFD3;
    --green: #246B45;
    --green-bg: #E8F2E7;
    --soft-green: #F0F4EB;
    --soft-orange: #FBF0E3;
}

* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: 'DM Sans', sans-serif;
    background: var(--cream);
    color: var(--ink);
    min-height: 100vh;
}

a {
    text-decoration: none;
    color: inherit;
}

/* NAVBAR */

.navbar {
    height: 82px;
    padding: 0 6%;
    background: rgba(255, 253, 249, 0.97);
    border-bottom: 1px solid rgba(115, 82, 55, 0.10);
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 28px;
    position: relative;
    z-index: 2;
}

.brand {
    font-family: 'Playfair Display', serif;
    font-size: 35px;
    font-weight: 700;
    color: var(--terracotta);
    letter-spacing: -1.5px;
    line-height: 1;
    white-space: nowrap;
}

.brand-subtitle {
    display: block;
    font-family: 'DM Sans', sans-serif;
    font-size: 9px;
    letter-spacing: 3px;
    text-align: center;
    margin-top: 6px;
    color: #65584C;
    font-weight: 700;
}

.nav-links {
    display: flex;
    align-items: center;
    gap: 30px;
}

.nav-links a {
    font-size: 13px;
    font-weight: 600;
    color: #302D29;
    transition: color 0.2s;
}

.nav-links a:hover {
    color: var(--terracotta);
}

.nav-profile {
    width: 43px;
    height: 43px;
    border-radius: 50%;
    background: #F0ECE5;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 20px;
}

/* HERO */

.hero {
    min-height: 405px;
    position: relative;
    overflow: hidden;
    background:
        linear-gradient(
            90deg,
            rgba(250, 247, 242, 0.99) 0%,
            rgba(250, 247, 242, 0.96) 42%,
            rgba(250, 247, 242, 0.35) 68%,
            rgba(250, 247, 242, 0.03) 100%
        ),
        url('https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=1800&q=85')
        center 48% / cover no-repeat;
}

.hero-inner {
    max-width: 1250px;
    margin: auto;
    padding: 57px 38px 75px;
    position: relative;
    z-index: 1;
}

.success-mark {
    width: 64px;
    height: 64px;
    border-radius: 50%;
    background: #DDEBD8;
    color: #27834D;
    display: flex;
    justify-content: center;
    align-items: center;
    font-size: 35px;
    font-weight: 700;
    margin-bottom: 18px;
    box-shadow: 0 0 0 9px rgba(221, 235, 216, 0.28);
}

.hero h1 {
    font-family: 'Playfair Display', serif;
    font-size: clamp(32px, 4vw, 48px);
    line-height: 1.18;
    letter-spacing: -1.2px;
    max-width: 640px;
    margin-bottom: 15px;
}

.hero-description {
    font-size: 17px;
    color: #554D46;
    line-height: 1.8;
    max-width: 470px;
}

.hero-note {
    display: flex;
    align-items: flex-start;
    gap: 13px;
    max-width: 410px;
    margin-top: 22px;
    color: #5D554D;
    font-size: 13px;
    line-height: 1.8;
}

.note-icon {
    width: 39px;
    height: 39px;
    flex-shrink: 0;
    border-radius: 50%;
    background: #E5EBD9;
    display: flex;
    justify-content: center;
    align-items: center;
    font-size: 19px;
}

/* MAIN ORDER CARD */

.page-container {
    width: min(1160px, calc(100% - 48px));
    margin: -40px auto 60px;
    position: relative;
    z-index: 1;
}

.order-card {
    padding: 31px;
    background: rgba(255, 254, 251, 0.98);
    border: 1px solid #E8D9C8;
    border-radius: 18px;
    box-shadow: 0 12px 45px rgba(74, 49, 29, 0.08);
}

.card-heading {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 15px;
    flex-wrap: wrap;
    margin-bottom: 25px;
}

.card-heading h2 {
    font-family: 'Playfair Display', serif;
    font-size: 34px;
    letter-spacing: -0.7px;
}

.card-heading p {
    color: var(--muted);
    margin-top: 6px;
    font-size: 14px;
}

.status-badge {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    background: var(--green-bg);
    color: var(--green);
    padding: 10px 15px;
    border-radius: 30px;
    font-size: 12px;
    font-weight: 700;
    text-transform: capitalize;
}

.status-dot {
    width: 8px;
    height: 8px;
    background: #29854F;
    border-radius: 50%;
}

/* TWO COLUMNS */

.summary-grid {
    display: grid;
    grid-template-columns: minmax(270px, 0.83fr) minmax(0, 1.17fr);
    gap: 32px;
}

.left-column,
.right-column {
    min-width: 0;
}

.order-reference {
    padding: 20px;
    background: #F7F4EF;
    border: 1px solid #EFE7DC;
    border-radius: 13px;
    margin-bottom: 15px;
}

.reference-label {
    font-size: 12px;
    color: var(--muted);
    margin-bottom: 7px;
}

.reference-value {
    font-size: 24px;
    font-weight: 700;
    color: var(--ink);
    overflow-wrap: anywhere;
}

.metadata {
    padding: 0 20px;
    background: #FCFAF7;
    border: 1px solid #F0E9E0;
    border-radius: 13px;
}

.metadata-item {
    display: flex;
    align-items: center;
    gap: 14px;
    padding: 17px 0;
    border-bottom: 1px solid var(--line);
}

.metadata-item:last-child {
    border-bottom: none;
}

.metadata-icon {
    width: 42px;
    height: 42px;
    flex-shrink: 0;
    display: flex;
    align-items: center;
    justify-content: center;
    background: #F2E8D9;
    border-radius: 50%;
    font-size: 19px;
}

.metadata-label {
    display: block;
    color: var(--muted);
    font-size: 12px;
    margin-bottom: 5px;
}

.metadata-value {
    display: block;
    color: #27251F;
    font-size: 13px;
    font-weight: 700;
    line-height: 1.6;
    overflow-wrap: anywhere;
}

.delivery-box {
    background: var(--soft-orange);
    padding: 19px;
    border-radius: 13px;
    margin-top: 15px;
    display: flex;
    gap: 13px;
    align-items: flex-start;
}

.delivery-icon {
    font-size: 22px;
}

.delivery-title {
    font-size: 13px;
    font-weight: 700;
    margin-bottom: 5px;
}

.delivery-time {
    font-size: 16px;
    font-weight: 700;
    margin-bottom: 8px;
}

.delivery-description {
    font-size: 11px;
    line-height: 1.7;
    color: #75685B;
}

/* ORDERED ITEMS */

.items-heading {
    font-size: 19px;
    font-weight: 700;
    margin: 2px 0 10px;
}

.items-subheading {
    color: var(--muted);
    font-size: 12px;
    margin-bottom: 8px;
}

.item-list {
    border-top: 1px solid var(--line);
}

.food-item {
    display: flex;
    align-items: center;
    gap: 14px;
    padding: 15px 0;
    border-bottom: 1px solid var(--line);
}

.food-image {
    width: 64px;
    height: 64px;
    border-radius: 11px;
    object-fit: cover;
    flex-shrink: 0;
    background: #F1E8DC;
}

.food-info {
    flex: 1;
    min-width: 0;
}

.food-name {
    display: block;
    font-size: 14px;
    line-height: 1.5;
    font-weight: 700;
    overflow-wrap: anywhere;
}

.food-description {
    display: block;
    font-size: 11px;
    color: var(--muted);
    margin-top: 4px;
}

.food-price {
    white-space: nowrap;
    font-size: 14px;
    font-weight: 700;
    color: #29251F;
}

.empty-items {
    padding: 22px 0;
    color: var(--muted);
    font-size: 13px;
    line-height: 1.7;
}

.total-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 15px;
    margin-top: 15px;
    padding: 19px;
    background: var(--soft-green);
    border-radius: 11px;
}

.total-label {
    color: #23563F;
    font-size: 15px;
    font-weight: 700;
}

.total-value {
    color: #154C38;
    font-size: 25px;
    font-weight: 700;
    white-space: nowrap;
}

/* ACTIONS */

.card-actions {
    display: flex;
    justify-content: center;
    gap: 13px;
    border-top: 1px solid var(--line);
    margin-top: 28px;
    padding-top: 25px;
}

.btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 9px;
    min-width: 230px;
    min-height: 49px;
    padding: 13px 23px;
    border-radius: 9px;
    font-family: 'DM Sans', sans-serif;
    font-size: 13px;
    font-weight: 700;
    transition: transform 0.2s, background 0.2s;
}

.btn:hover {
    transform: translateY(-2px);
}

.btn-primary {
    background: var(--terracotta);
    color: #FFFFFF;
    border: 1px solid var(--terracotta);
}

.btn-primary:hover {
    background: var(--terracotta-dark);
}

.btn-secondary {
    background: transparent;
    color: var(--terracotta);
    border: 1px solid var(--terracotta);
}

.btn-secondary:hover {
    background: #FBF0E9;
}

/* BENEFITS */

.benefits {
    background: #F0F3E9;
    padding: 29px 6%;
    display: grid;
    grid-template-columns: repeat(4, minmax(0, 1fr));
    margin-top: 0;
}

.benefit {
    text-align: center;
    padding: 5px 14px;
    border-right: 1px solid #D5DDCD;
}

.benefit:last-child {
    border-right: none;
}

.benefit-icon {
    width: 43px;
    height: 43px;
    margin: 0 auto 9px;
    border-radius: 50%;
    background: #DFE8D6;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 19px;
}

.benefit-title {
    font-size: 13px;
    font-weight: 700;
    margin-bottom: 5px;
}

.benefit-description {
    font-size: 11px;
    color: #716B61;
}

/* FOOTER */

.footer {
    background: #38251B;
    color: #F9F0E7;
    padding: 32px 6% 20px;
}

.footer-top {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    gap: 30px;
    flex-wrap: wrap;
}

.footer .brand {
    color: #FFF5E8;
    font-size: 29px;
}

.footer .brand-subtitle {
    color: #E5D3C3;
    font-size: 8px;
    letter-spacing: 2px;
}

.footer-links {
    display: flex;
    gap: 17px 22px;
    flex-wrap: wrap;
    max-width: 350px;
    font-size: 11px;
}

.footer-links a:hover {
    color: #E9A17D;
}

.footer-social {
    font-size: 12px;
    color: #E9D7C8;
}

.footer-bottom {
    border-top: 1px solid rgba(255,255,255,0.15);
    margin-top: 25px;
    padding-top: 16px;
    text-align: center;
    color: #CDBCAF;
    font-size: 11px;
}

/* RESPONSIVE */

@media (max-width: 850px) {
    .hero {
        background:
            linear-gradient(
                90deg,
                rgba(250,247,242,0.98),
                rgba(250,247,242,0.85)
            ),
            url('https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=1200&q=80')
            center / cover no-repeat;
    }

    .summary-grid {
        grid-template-columns: 1fr;
        gap: 30px;
    }

    .navbar {
        padding: 0 4%;
    }

    .nav-links {
        gap: 15px;
    }

    .nav-links a {
        font-size: 12px;
    }
}

@media (max-width: 560px) {
    .navbar {
        height: auto;
        min-height: 75px;
        padding: 15px 5%;
        align-items: flex-start;
        flex-direction: column;
        gap: 15px;
    }

    .brand {
        font-size: 30px;
    }

    .nav-links {
        width: 100%;
        gap: 17px;
        flex-wrap: wrap;
    }

    .nav-profile {
        display: none;
    }

    .hero {
        min-height: auto;
    }

    .hero-inner {
        padding: 42px 22px 70px;
    }

    .success-mark {
        width: 54px;
        height: 54px;
        font-size: 29px;
    }

    .hero h1 {
        font-size: 33px;
    }

    .hero-description {
        font-size: 15px;
    }

    .page-container {
        width: calc(100% - 24px);
        margin-top: -32px;
        margin-bottom: 35px;
    }

    .order-card {
        padding: 19px;
        border-radius: 15px;
    }

    .card-heading h2 {
        font-size: 29px;
    }

    .card-heading {
        align-items: flex-start;
    }

    .metadata {
        padding: 0 13px;
    }

    .metadata-item {
        gap: 11px;
    }

    .food-image {
        width: 53px;
        height: 53px;
    }

    .food-item {
        gap: 10px;
    }

    .food-name {
        font-size: 12px;
    }

    .food-price {
        font-size: 12px;
    }

    .total-row {
        padding: 15px;
    }

    .total-value {
        font-size: 21px;
    }

    .card-actions {
        flex-direction: column;
    }

    .btn {
        width: 100%;
        min-width: 0;
    }

    .benefits {
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 23px 0;
        padding: 25px 4%;
    }

    .benefit:nth-child(2) {
        border-right: none;
    }

    .footer-top {
        flex-direction: column;
        gap: 25px;
    }
}


/* POPUP OVERLAY */
.popup-overlay {
    position: fixed;
    inset: 0;
    z-index: 99999;
    display: none;
    align-items: center;
    justify-content: center;
    padding: 20px;
    background: rgba(20, 17, 14, 0.65);
    backdrop-filter: blur(7px);
}

.popup-overlay.show {
    display: flex;
    animation: overlayFadeIn 0.3s ease;
}

.popup-card {
    position: relative;
    width: min(450px, 100%);
    padding: 38px 28px 30px;
    overflow: hidden;
    text-align: center;
    background: #FFFCF7;
    border: 1px solid #E8D9C8;
    border-radius: 24px;
    box-shadow: 0 25px 80px rgba(0, 0, 0, 0.28);
    animation: popupAppear 0.45s cubic-bezier(.2, .8, .2, 1);
}

.popup-close {
    position: absolute;
    top: 12px;
    right: 15px;
    width: 35px;
    height: 35px;
    border: none;
    border-radius: 50%;
    background: #F3EAE0;
    color: #514238;
    font-size: 23px;
    cursor: pointer;
}

.popup-emoji {
    font-size: 55px;
    margin-bottom: 12px;
    animation: celebrateBounce 1s ease infinite alternate;
}

.popup-card h2 {
    font-family: 'Playfair Display', serif;
    font-size: 31px;
    color: #246B45;
    margin-bottom: 12px;
}

.popup-card p {
    color: #766D64;
    font-size: 14px;
    line-height: 1.8;
    margin-bottom: 18px;
}

.popup-order-number {
    display: inline-block;
    padding: 10px 18px;
    margin-bottom: 22px;
    background: #E8F2E7;
    color: #246B45;
    border-radius: 10px;
    font-size: 16px;
    font-weight: 700;
}

.popup-action {
    width: 100%;
    min-height: 48px;
    border: none;
    border-radius: 10px;
    background: #B84F2B;
    color: white;
    font-family: 'DM Sans', sans-serif;
    font-size: 14px;
    font-weight: 700;
    cursor: pointer;
    transition: background 0.2s, transform 0.2s;
}

.popup-action:hover {
    background: #963C20;
    transform: translateY(-2px);
}

.popup-secondary {
    margin-top: 10px;
    background: transparent;
    color: #B84F2B;
    border: 1px solid #B84F2B;
}

.popup-secondary:hover {
    background: #FBF0E9;
    color: #963C20;
}

.confetti-piece {
    position: absolute;
    top: -20px;
    width: 9px;
    height: 14px;
    pointer-events: none;
    animation: confettiFall 3s linear forwards;
}

@keyframes overlayFadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
}

@keyframes popupAppear {
    from {
        opacity: 0;
        transform: translateY(25px) scale(0.88);
    }
    to {
        opacity: 1;
        transform: translateY(0) scale(1);
    }
}

@keyframes celebrateBounce {
    from { transform: translateY(0) rotate(-5deg); }
    to { transform: translateY(-8px) rotate(5deg); }
}

@keyframes confettiFall {
    0% {
        transform: translateY(-10px) rotate(0deg);
        opacity: 1;
    }
    100% {
        transform: translateY(520px) rotate(720deg);
        opacity: 0;
    }
}

@media (max-width: 480px) {
    .popup-card {
        padding: 35px 20px 24px;
    }

    .popup-card h2 {
        font-size: 27px;
    }

    .popup-emoji {
        font-size: 47px;
    }
}
</style>
</head>

<body>

<header class="navbar">

    

    <jsp:include page="/navbar.jsp" />

   
</header>

<section class="hero">

    <div class="hero-inner">

        <div class="success-mark">&#10003;</div>

        <h1>Order Placed Successfully!</h1>

        <p class="hero-description">
            Thank you for choosing Culinova.<br>
            Your delicious food is on its way!
        </p>

        <div class="hero-note">
            <div class="note-icon">&#128336;</div>

            <p>
                Your order details are ready.
                Keep an eye on your My Orders section
                for the latest order status.
            </p>
        </div>

    </div>

</section>

<main class="page-container">

    <section class="order-card">

        <div class="card-heading">

            <div>
                <h2>Order Summary</h2>
                <p>Here are the details of your order</p>
            </div>

            <span class="status-badge">
                <span class="status-dot"></span>
                <%= orderStatus %>
            </span>

        </div>

        <div class="summary-grid">

            <!-- LEFT COLUMN: ORDER DETAILS -->

            <div class="left-column">

                <div class="order-reference">

                    <div class="reference-label">
                        Order Number
                    </div>

                    <div class="reference-value">
                        #<%= order.getOrderId() %>
                    </div>

                </div>

                <div class="metadata">

                    <div class="metadata-item">

                        <div class="metadata-icon">&#128197;</div>

                        <div>
                            <span class="metadata-label">Order Date</span>
                            <span class="metadata-value">
                                <%= orderDate %>
                            </span>
                        </div>

                    </div>

                    <div class="metadata-item">

                        <div class="metadata-icon">&#128179;</div>

                        <div>
                            <span class="metadata-label">Payment Method</span>
                            <span class="metadata-value">
                                <%= paymentMode %>
                            </span>
                        </div>

                    </div>

                    <div class="metadata-item">

                        <div class="metadata-icon">&#10003;</div>

                        <div>
                            <span class="metadata-label">Order Status</span>
                            <span class="metadata-value">
                                <%= orderStatus %>
                            </span>
                        </div>

                    </div>

                </div>

                <div class="delivery-box">

                    <div class="delivery-icon">&#128666;</div>

                    <div>
                        <div class="delivery-title">
                            Delivery Information
                        </div>

                        <div class="delivery-time">
                            Check My Orders
                        </div>

                        <p class="delivery-description">
                            We are preparing your order.
                            Visit your order history for available
                            delivery and status information.
                        </p>
                    </div>

                </div>

            </div>

            <!-- RIGHT COLUMN: FOOD ITEMS -->

            <div class="right-column">

                <h3 class="items-heading">Items Ordered</h3>

                <p class="items-subheading">
                    Your selected food items
                </p>

                <div class="item-list">

                    <% if (orderedItems.isEmpty()) { %>

                        <p class="empty-items">
                            No items were found for this order.
                            Please check the saved order items
                            in your database.
                        </p>

                    <% } else { %>

                        <% for (Map<String, Object> item : orderedItems) { %>

                            <div class="food-item">

                                <img
                                    class="food-image"
                                    src="https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=160&q=75"
                                    alt="Ordered food"
                                    loading="lazy">

                                <div class="food-info">

                                    <span class="food-name">
                                        <%= item.get("itemName") %>
                                    </span>

                                    <span class="food-description">
                                        Ordered item
                                    </span>

                                </div>

                                <span class="food-price">
                                    &#8377;<%= String.format(
                                        Locale.US,
                                        "%.2f",
                                        (Double) item.get("totalAmount")
                                    ) %>
                                </span>

                            </div>

                        <% } %>

                    <% } %>

                </div>

                <div class="total-row">

                    <span class="total-label">Total Amount</span>

                    <span class="total-value">
                        &#8377;<%= formattedTotal %>
                    </span>

                </div>

            </div>

        </div>

        <div class="card-actions">

            <a class="btn btn-primary"
               href="<%= contextPath %>/orders.jsp">
                &#9776; View My Orders
            </a>

            <a class="btn btn-secondary"
               href="<%= contextPath %>/restaurant?view=restaurants">
                &#128722; Continue Shopping
            </a>

        </div>

    </section>

</main>

<section class="benefits">

    <div class="benefit">
        <div class="benefit-icon">&#127793;</div>
        <div class="benefit-title">Fresh Ingredients</div>
        <div class="benefit-description">Quality in every bite</div>
    </div>

    <div class="benefit">
        <div class="benefit-icon">&#128666;</div>
        <div class="benefit-title">Fast Delivery</div>
        <div class="benefit-description">Your order, on its way</div>
    </div>

    <div class="benefit">
        <div class="benefit-icon">&#128737;</div>
        <div class="benefit-title">Secure Payments</div>
        <div class="benefit-description">Payment options for you</div>
    </div>

    <div class="benefit">
        <div class="benefit-icon">&#9825;</div>
        <div class="benefit-title">Great Taste</div>
        <div class="benefit-description">Made for good moments</div>
    </div>

</section>

<footer class="footer">

    <div class="footer-top">

        <a class="brand"
           href="<%= contextPath %>/restaurant?view=restaurants">
            Culinova
            <span class="brand-subtitle">GOOD FOOD, BETTER MOOD</span>
        </a>

        <div class="footer-links">
            <a href="<%= contextPath %>/restaurant?view=restaurants">Home</a>
            <a href="<%= contextPath %>/restaurant?view=restaurants">Restaurants</a>
            <a href="<%= contextPath %>/cart.jsp">Cart</a>
            <a href="<%= contextPath %>/orders.jsp">My Orders</a>
        </div>

        <div class="footer-social">
            Good Food. Delivered with Care.
        </div>

    </div>

    <div class="footer-bottom">
        &copy; 2026 Culinova. All rights reserved.
    </div>

</footer>
<!-- ORDER SUCCESS POPUP -->
<div class="popup-overlay" id="successPopup" role="dialog"
     aria-modal="true" aria-labelledby="popupTitle">

    <div class="popup-card">

        <button type="button"
                class="popup-close"
                onclick="closeSuccessPopup()"
                aria-label="Close popup">&times;</button>

        <div class="popup-emoji">🎉</div>

        <h2 id="popupTitle">Order Confirmed!</h2>

        <p>
            Great choice! Your order has been placed successfully.
            Thank you for choosing Culinova.
        </p>

        <div class="popup-order-number">
            Order #<%= order.getOrderId() %>
        </div>

        <button type="button"
                class="popup-action"
                onclick="viewMyOrders()">
            View My Orders
        </button>

        <button type="button"
                class="popup-action popup-secondary"
                onclick="continueShopping()">
            Continue Shopping
        </button>

    </div>
</div>

<script>
(function () {
    "use strict";

    const popup = document.getElementById("successPopup");

    function showSuccessPopup() {
        if (!popup) return;

        popup.classList.add("show");
        createConfetti();
    }

    window.closeSuccessPopup = function () {
        if (popup) {
            popup.classList.remove("show");
        }
    };

    window.viewMyOrders = function () {
        window.location.href =
            "<%= contextPath %>/orders.jsp";
    };

    window.continueShopping = function () {
        window.location.href =
            "<%= contextPath %>/restaurant?view=restaurants";
    };

    function createConfetti() {
        const card = popup.querySelector(".popup-card");

        if (!card) return;

        const colors = [
            "#B84F2B",
            "#E8B04A",
            "#27834D",
            "#E58A69",
            "#8A6CCF"
        ];

        for (let i = 0; i < 35; i++) {
            const piece = document.createElement("span");

            piece.className = "confetti-piece";
            piece.style.left = Math.random() * 100 + "%";
            piece.style.backgroundColor =
                colors[Math.floor(Math.random() * colors.length)];

            piece.style.animationDelay =
                (Math.random() * 1.2) + "s";

            piece.style.animationDuration =
                (2 + Math.random() * 1.5) + "s";

            card.appendChild(piece);

            piece.addEventListener("animationend", function () {
                piece.remove();
            });
        }
    }

    // Close when clicking outside the popup card.
    if (popup) {
        popup.addEventListener("click", function (event) {
            if (event.target === popup) {
                window.closeSuccessPopup();
            }
        });
    }

    // Close popup using the Escape key.
    document.addEventListener("keydown", function (event) {
        if (event.key === "Escape") {
            window.closeSuccessPopup();
        }
    });

    // Show popup only for a confirmed/successful order.
    <% if (isConfirmed) { %>
        window.addEventListener("DOMContentLoaded", function () {
            window.setTimeout(showSuccessPopup, 350);
        });
    <% } %>

})();
</script>

</body>
</html>
