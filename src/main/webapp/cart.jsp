
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Locale" %>
<%@ page import="com.tap.model.CartItem" %>
<%@ page import="com.tap.model.Menu" %>
<%@ page import="com.tap.model.Restaurant" %>


<%
    String contextPath = request.getContextPath();

    List<CartItem> cartItems =
        (List<CartItem>) session.getAttribute("cartItems");

    if (cartItems == null) {
        cartItems = new ArrayList<CartItem>();
    }

    double subtotal = 0.0;
    int totalItems = 0;

    for (CartItem item : cartItems) {
        if (item != null && item.getMenu() != null) {
            subtotal += item.getSubtotal();
            totalItems += item.getQuantity();
        }
    }

    double deliveryFee = cartItems.isEmpty() ? 0.0 : 40.0;
    double tax = subtotal * 0.05;
    double grandTotal = subtotal + deliveryFee + tax;
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Culinova | My Cart</title>

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700;800&family=Playfair+Display:wght@600;700&display=swap"
      rel="stylesheet">

<style>
:root {
    --bg: #FAF7F2;
    --surface: #FFFFFF;
    --soft: #F3EDE5;
    --text: #29231F;
    --muted: #82766C;
    --accent: #B85F3B;
    --accent-hover: #984A2C;
    --border: #E9DED3;
    --danger: #C43D3D;
    --shadow: 0 6px 22px rgba(63,43,28,.06);
}

/* Theme is controlled only by navbar.jsp */
html[data-theme="dark"] body {
    --bg: #171411;
    --surface: #211D19;
    --soft: #2A241F;
    --text: #F5EEE6;
    --muted: #B4A69A;
    --accent: #D17A54;
    --accent-hover: #E18B64;
    --border: #3A3028;
    --danger: #FF7777;
    --shadow: 0 6px 22px rgba(0,0,0,.2);
}

* {
    box-sizing: border-box;
    margin: 0;
    padding: 0;
}

body {
    font-family: "DM Sans", Arial, sans-serif;
    background: var(--bg);
    color: var(--text);
    min-height: 100vh;
    transition: background .25s, color .25s;
}

a {
    color: inherit;
    text-decoration: none;
}

button {
    font-family: inherit;
}

.page {
    max-width: 1200px;
    padding: 42px 24px 70px;
    margin: auto;
}

.eyebrow {
    color: var(--accent);
    text-transform: uppercase;
    font-size: 12px;
    font-weight: 800;
    letter-spacing: 2px;
    margin-bottom: 10px;
}

.page-heading {
    margin-bottom: 30px;
}

.page-heading h1 {
    font-family: "Playfair Display", Georgia, serif;
    font-size: clamp(32px, 4vw, 46px);
    margin-bottom: 10px;
}

.page-heading p {
    color: var(--muted);
    font-size: 15px;
    line-height: 1.6;
}

.cart-layout {
    display: grid;
    grid-template-columns: minmax(0, 1fr) 355px;
    gap: 28px;
    align-items: start;
}

.cart-panel {
    min-width: 0;
}

.panel-heading {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 15px;
    padding-bottom: 20px;
}

.panel-heading h2,
.summary-panel h2 {
    font-size: 20px;
}

.item-count {
    margin-top: 5px;
    color: var(--muted);
    font-size: 13px;
}

/* Clear Cart button */
.clear-button,
.remove-button {
    background: transparent;
    border: none;
    color: var(--danger);
    cursor: pointer;
    font-size: 13px;
    font-weight: 700;
}

.clear-button:hover,
.remove-button:hover {
    text-decoration: underline;
}

.cart-bottom-actions {
    display: flex;
    justify-content: flex-end;
    margin-top: 4px;
    margin-bottom: 24px;
}

/* Cart item cards */
.cart-item {
    display: grid;
    grid-template-columns: 112px minmax(0, 1fr) auto;
    align-items: center;
    gap: 18px;
    padding: 20px;
    margin-bottom: 18px;
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 16px;
    box-shadow: var(--shadow);
    transition: border-color .2s;
}

.cart-item:hover {
    border-color: var(--accent);
}

.item-image {
    display: block;
    width: 112px;
    height: 112px;
    object-fit: cover;
    border-radius: 13px;
    background: var(--soft);
}

.item-details {
    min-width: 0;
}

.item-details h3 {
    font-size: 17px;
    font-weight: 750;
    margin-bottom: 7px;
    overflow-wrap: anywhere;
}

.item-description {
    color: var(--muted);
    font-size: 13px;
    line-height: 1.5;
    margin-bottom: 9px;
    overflow-wrap: anywhere;
}

.unit-price {
    color: var(--accent);
    font-size: 14px;
    font-weight: 750;
}

.item-actions {
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    gap: 12px;
    margin-top: 14px;
}

/* Quantity controls */
.quantity-control {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    background: var(--soft);
    border: 1px solid var(--border);
    border-radius: 9px;
    overflow: hidden;
    height: 37px;
}

.quantity-control form {
    display: flex;
    align-items: center;
    margin: 0;
}

.quantity-control button {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    flex: 0 0 35px;
    width: 35px;
    height: 35px;
    padding: 0;
    border: none;
    background: transparent;
    color: var(--text);
    font-size: 21px;
    line-height: 1;
    cursor: pointer;
    transition: background .15s;
}

.quantity-control button:hover {
    background: var(--border);
}

.quantity-control button:disabled {
    opacity: .5;
    cursor: wait;
}

.quantity-number {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-width: 32px;
    height: 35px;
    padding: 0 4px;
    text-align: center;
    font-size: 14px;
    font-weight: 750;
    font-variant-numeric: tabular-nums;
}

.item-total {
    align-self: start;
    padding-top: 5px;
    text-align: right;
    white-space: nowrap;
    font-size: 16px;
}

/* Order summary */
.summary-panel {
    padding: 25px;
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 18px;
    box-shadow: var(--shadow);
    position: sticky;
    top: 24px;
}

.summary-panel h2 {
    margin-bottom: 24px;
}

.summary-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 15px;
    margin-bottom: 17px;
    color: var(--muted);
    font-size: 14px;
}

.summary-row span:last-child {
    color: var(--text);
    font-weight: 650;
    white-space: nowrap;
}

.summary-row.total {
    border-top: 1px solid var(--border);
    padding-top: 20px;
    margin-top: 20px;
    margin-bottom: 22px;
    color: var(--text);
    font-size: 17px;
    font-weight: 800;
}

.summary-row.total span:last-child {
    color: var(--accent);
    font-size: 22px;
    font-weight: 800;
}

.primary-button {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 100%;
    min-height: 49px;
    padding: 13px 16px;
    border-radius: 11px;
    font-size: 14px;
    font-weight: 750;
    cursor: pointer;
    transition: background .2s, border-color .2s;
    background: var(--accent);
    color: #FFFFFF;
    border: 1px solid var(--accent);
    margin-bottom: 0;
}

.primary-button:hover {
    background: var(--accent-hover);
    border-color: var(--accent-hover);
}

/* Small centered text below checkout */
.add-more-link {
    display: block;
    margin-top: 12px;
    text-align: center;
    color: var(--accent);
    font-size: 12px;
    font-weight: 500;
    text-decoration: none;
    transition: color .2s;
}

.add-more-link:hover {
    color: var(--accent-hover);
    text-decoration: underline;
}

.delivery-note {
    display: flex;
    gap: 10px;
    padding: 14px;
    margin-top: 20px;
    border-radius: 11px;
    background: var(--soft);
    color: var(--muted);
    font-size: 12px;
    line-height: 1.6;
}

/* Empty cart */
.empty-cart {
    padding: 65px 20px;
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 18px;
    box-shadow: var(--shadow);
    text-align: center;
}

.empty-icon {
    width: 90px;
    height: 90px;
    display: flex;
    align-items: center;
    justify-content: center;
    margin: 0 auto 24px;
    border-radius: 50%;
    background: var(--soft);
    font-size: 40px;
}

.empty-cart h2 {
    font-size: 25px;
    margin-bottom: 10px;
}

.empty-cart p {
    color: var(--muted);
    font-size: 14px;
    line-height: 1.7;
    margin-bottom: 25px;
}

.empty-cart .secondary-button {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 100%;
    max-width: 240px;
    min-height: 49px;
    padding: 13px 16px;
    margin: auto;
    border-radius: 11px;
    background: var(--accent);
    color: #FFFFFF;
    border: 1px solid var(--accent);
    font-size: 14px;
    font-weight: 750;
}

.empty-cart .secondary-button:hover {
    background: var(--accent-hover);
}

.footer {
    padding: 25px 20px;
    border-top: 1px solid var(--border);
    color: var(--muted);
    text-align: center;
    font-size: 12px;
}

@media (max-width: 900px) {
    .cart-layout {
        grid-template-columns: minmax(0, 1fr);
    }

    .summary-panel {
        position: static;
    }
}

@media (max-width: 650px) {
    .page {
        padding: 28px 14px 45px;
    }

    .cart-item {
        grid-template-columns: 78px minmax(0, 1fr);
        gap: 13px;
        padding: 14px;
        margin-bottom: 14px;
    }

    .item-image {
        width: 78px;
        height: 78px;
    }

    .item-details h3 {
        font-size: 15px;
    }

    .item-total {
        grid-column: 2;
        text-align: left;
        padding-top: 0;
    }

    .quantity-control button {
        flex-basis: 31px;
        width: 31px;
        height: 31px;
    }

    .quantity-control {
        height: 33px;
    }

    .quantity-number {
        height: 31px;
    }

    .summary-panel {
        padding: 18px;
    }
}
</style>
</head>

<body>

<jsp:include page="/navbar.jsp" />

<main class="page">

    <section class="page-heading">
        <div class="eyebrow">Your selections</div>
        <h1>Your Shopping Cart</h1>
        <p>Review your favourite meals before placing your order.</p>
    </section>

    <% if (cartItems.isEmpty()) { %>

        <section class="empty-cart">
            <div class="empty-icon">🛒</div>
            <h2>Your cart is empty</h2>
            <p>
                You haven't added any items yet.<br>
                Explore our restaurants to find something delicious.
            </p>

            <a href="<%= contextPath %>/restaurant"
               class="secondary-button">
                Explore Restaurants
            </a>
        </section>

    <% } else { %>

        <div class="cart-layout">

            <section class="cart-panel">

                <div class="panel-heading">
                    <div>
                        <h2>Cart Items</h2>
                        <p class="item-count">
                            <%= totalItems %>
                            item<%= totalItems == 1 ? "" : "s" %> in your cart
                        </p>
                    </div>
                </div>

                <% for (CartItem cartItem : cartItems) {
                    if (cartItem == null || cartItem.getMenu() == null) {
                        continue;
                    }

                    Menu menu = cartItem.getMenu();

                    int menuId = menu.getMenuId();
                    int quantity = cartItem.getQuantity();

                    String itemName = menu.getItemName();
                    String description = menu.getDescription();
                    String imagePath = menu.getImagePath();

                    double itemSubtotal = cartItem.getSubtotal();

                    String imageUrl;

                    if (imagePath != null && !imagePath.trim().isEmpty()) {
                        imagePath = imagePath.trim();

                        if (imagePath.startsWith("http://")
                                || imagePath.startsWith("https://")) {
                            imageUrl = imagePath;
                        } else {
                            imagePath = imagePath.replace("\\", "/");

                            while (imagePath.startsWith("/")) {
                                imagePath = imagePath.substring(1);
                            }

                            imageUrl = contextPath + "/" + imagePath;
                        }
                    } else {
                        imageUrl = contextPath + "/images/food-placeholder.png";
                    }
                %>

                    <article class="cart-item">

                        <img
                            class="item-image"
                            src="<%= imageUrl %>"
                            alt="<%= itemName %>"
                            onerror="this.onerror=null;this.src='<%= contextPath %>/images/food-placeholder.png';">

                        <div class="item-details">

                            <h3><%= itemName %></h3>

                            <% if (description != null
                                    && !description.trim().isEmpty()) { %>
                                <p class="item-description">
                                    <%= description %>
                                </p>
                            <% } %>

                            <p class="unit-price">
                                ₹<%= String.format(Locale.US, "%.2f", menu.getPrice()) %>
                                <span style="color:var(--muted);font-weight:400;">
                                    / item
                                </span>
                            </p>

                            <div class="item-actions">

                                <div class="quantity-control">

                                    <form action="<%= contextPath %>/cart"
                                          method="post"
                                          class="quantity-form">

                                        <input type="hidden"
                                               name="action"
                                               value="decrement">

                                        <input type="hidden"
                                               name="menuId"
                                               value="<%= menuId %>">

                                        <button type="submit"
                                                aria-label="Decrease quantity">−</button>
                                    </form>

                                    <span class="quantity-number">
                                        <%= quantity %>
                                    </span>

                                    <form action="<%= contextPath %>/cart"
                                          method="post"
                                          class="quantity-form">

                                        <input type="hidden"
                                               name="action"
                                               value="increment">

                                        <input type="hidden"
                                               name="menuId"
                                               value="<%= menuId %>">

                                        <button type="submit"
                                                aria-label="Increase quantity">+</button>
                                    </form>

                                </div>

                                <form action="<%= contextPath %>/cart"
                                      method="post"
                                      onsubmit="return confirm('Remove this item?');">

                                    <input type="hidden"
                                           name="action"
                                           value="remove">

                                    <input type="hidden"
                                           name="menuId"
                                           value="<%= menuId %>">

                                    <button type="submit" class="remove-button">
                                        Remove
                                    </button>
                                </form>

                            </div>
                        </div>

                        <div class="item-total">
                            <strong>
                                ₹<%= String.format(Locale.US, "%.2f", itemSubtotal) %>
                            </strong>
                        </div>

                    </article>

                <% } %>

                <!-- Clear Cart appears after all cart item cards, on the right -->
                <div class="cart-bottom-actions">
                    <form action="<%= contextPath %>/cart"
                          method="post"
                          onsubmit="return confirm('Clear all items from your cart?');">

                        <input type="hidden" name="action" value="clear">

                        <button type="submit" class="clear-button">
                            Clear Cart
                        </button>
                    </form>
                </div>

            </section>

            <aside class="summary-panel">

                <h2>Order Summary</h2>

                <div class="summary-row">
                    <span>Subtotal</span>
                    <span>₹<%= String.format(Locale.US, "%.2f", subtotal) %></span>
                </div>

                <div class="summary-row">
                    <span>Delivery Fee</span>
                    <span>₹<%= String.format(Locale.US, "%.2f", deliveryFee) %></span>
                </div>

                <div class="summary-row">
                    <span>Tax (5%)</span>
                    <span>₹<%= String.format(Locale.US, "%.2f", tax) %></span>
                </div>

                <div class="summary-row total">
                    <span>Total</span>
                    <span>₹<%= String.format(Locale.US, "%.2f", grandTotal) %></span>
                </div>

                <a href="<%= contextPath %>/checkout"
                   class="primary-button">
                    Proceed to Checkout →
                </a>

                <!-- Small centered text below checkout -->
              <%
    int restaurantId = 0;

    if (cartItems != null && !cartItems.isEmpty()) {
        restaurantId = cartItems.get(0).getMenu().getRestaurantId();
    }
%>

<a href="<%= contextPath %>/menu?restaurantId=<%= restaurantId %>"
   class="add-more-link">
    ← Add More Items
</a>
                <div class="delivery-note">
                    <span>🚚</span>
                    <span>
                        Delivery fee ₹40 and tax of 5% are included
                        in your order total.
                    </span>
                </div>

            </aside>

        </div>

    <% } %>

</main>

<footer class="footer">
    © <%= java.time.Year.now().getValue() %> Culinova.
    Made with care for your food cravings.
</footer>

<script>
(function () {
    "use strict";

    /*
     * Preserve scroll position when incrementing or decrementing.
     * Theme handling stays in navbar.jsp.
     */
    const scrollKey = "culinova-cart-scroll-position";
    const pendingKey = "culinova-cart-restore-scroll";

    try {
        if (sessionStorage.getItem(pendingKey) === "true") {
            const savedPosition = sessionStorage.getItem(scrollKey);

            sessionStorage.removeItem(pendingKey);
            sessionStorage.removeItem(scrollKey);

            if (savedPosition !== null) {
                const position = Number(savedPosition);

                if (Number.isFinite(position)) {
                    window.addEventListener("load", function () {
                        requestAnimationFrame(function () {
                            window.scrollTo(0, position);
                        });
                    });
                }
            }
        }
    } catch (error) {
        // Continue normally if sessionStorage is unavailable.
    }

    document.querySelectorAll(
        'form input[name="action"][value="increment"], ' +
        'form input[name="action"][value="decrement"]'
    ).forEach(function (actionInput) {

        const form = actionInput.closest("form");

        if (form) {
            form.addEventListener("submit", function () {
                try {
                    sessionStorage.setItem(
                        scrollKey,
                        String(window.scrollY)
                    );

                    sessionStorage.setItem(pendingKey, "true");
                } catch (error) {
                    // The form can still submit normally.
                }
            });
        }
    });
})();
</script>

</body>
</html>
