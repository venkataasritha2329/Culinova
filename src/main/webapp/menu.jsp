<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.tap.model.Menu" %>
<%@ page import="com.tap.model.CartItem" %>

<%
    String contextPath = request.getContextPath();

    List<Menu> menuList =
        (List<Menu>) request.getAttribute("menuList");

    if (menuList == null) {
        menuList = new ArrayList<>();
    }

    int currentRestaurantId = 0;

    Object restaurantIdObject =
        request.getAttribute("restaurantId");

    if (restaurantIdObject != null) {

        try {
            currentRestaurantId =
                Integer.parseInt(restaurantIdObject.toString());

        } catch (NumberFormatException e) {
            currentRestaurantId = 0;
        }

    } else {

        String restaurantIdParam =
            request.getParameter("restaurantId");

        if (restaurantIdParam != null
                && !restaurantIdParam.trim().isEmpty()) {

            try {
                currentRestaurantId =
                    Integer.parseInt(restaurantIdParam);

            } catch (NumberFormatException e) {
                currentRestaurantId = 0;
            }
        }
    }

    /*
     * Get cart from session
     */
    List<CartItem> cartItems =
        (List<CartItem>) session.getAttribute("cartItems");

    if (cartItems == null) {
        cartItems = new ArrayList<>();
    }

    /*
     * Calculate total quantity in cart
     */
    int cartCount = 0;

    for (CartItem cartItem : cartItems) {

        if (cartItem != null
                && cartItem.getMenu() != null) {

            cartCount += cartItem.getQuantity();
        }
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Culinova - Menu</title>


    
    <style>

        :root {

            color-scheme: dark;

            --page: #171411;
            --surface: #211d19;
            --surface-hover: #2a241f;
            --text: #f7f1e9;
            --muted: #b5a99c;
            --accent: #d17a54;
            --border: #3b322b;
            --notice: #30251e;

            --shadow:
                0 8px 28px rgba(0, 0, 0, 0.18);
        }


        :root[data-theme="light"] {

            color-scheme: light;

            --page: #faf7f2;
            --surface: #ffffff;
            --surface-hover: #f4eee7;
            --text: #30251f;
            --muted: #796c61;
            --accent: #b85f3b;
            --border: #e8ddd2;
            --notice: #fff0e7;

            --shadow:
                0 8px 28px rgba(69, 45, 27, 0.07);
        }


        * {
            box-sizing: border-box;
        }


        body {

            margin: 0;

            background: var(--page);
            color: var(--text);

            font-family:
                "DM Sans",
                Arial,
                sans-serif;

            transition:
                background 0.2s ease,
                color 0.2s ease;
        }


        a {

            color: inherit;
            text-decoration: none;
        }


        button {
            font: inherit;
        }


        /* Navbar is imported from navbar.jsp */


        .page-container {

            width: min(1200px, 90%);

            margin: 0 auto;

            padding: 38px 0 60px;
        }


        .page-heading {
            margin-bottom: 28px;
        }


        .eyebrow {

            margin-bottom: 8px;

            color: var(--accent);

            font-size: 12px;

            font-weight: 800;

            letter-spacing: 2px;

            text-transform: uppercase;
        }


        .page-heading h1 {

            margin: 0 0 10px;

            font-family:
                Georgia,
                "Times New Roman",
                serif;

            font-size:
                clamp(30px, 4vw, 43px);

            font-weight: 700;
        }


        .page-heading p {

            margin: 0;

            color: var(--muted);

            line-height: 1.6;
        }


        .notice {

            display: none;

            margin-bottom: 22px;

            padding: 13px 16px;

            color: var(--text);

            background: var(--notice);

            border: 1px solid var(--border);

            border-radius: 10px;

            line-height: 1.5;
        }


        .notice.show {
            display: block;
        }


        .menu-grid {

            display: grid;

            grid-template-columns:
                repeat(3, minmax(0, 1fr));

            gap: 24px;
        }


        .menu-card {

            display: flex;

            min-width: 0;

            flex-direction: column;

            overflow: hidden;

            background: var(--surface);

            border: 1px solid var(--border);

            border-radius: 17px;

            box-shadow: var(--shadow);

            transition:
                transform 0.2s ease,
                border-color 0.2s ease;
        }


        .menu-card:hover {

            transform: translateY(-3px);

            border-color: var(--accent);
        }


        .menu-image,
        .image-placeholder {

            display: block;

            width: 100%;

            height: 205px;

            background: var(--surface-hover);
        }


        .menu-image {

            object-fit: cover;
        }


        .image-placeholder {

            display: flex;

            align-items: center;

            justify-content: center;

            color: var(--muted);

            font-size: 14px;
        }


        .menu-content {

            display: flex;

            flex: 1;

            flex-direction: column;

            padding: 18px;
        }


        .menu-title {

            margin: 0 0 9px;

            font-size: 19px;

            font-weight: 750;

            overflow-wrap: anywhere;
        }


        .menu-description {

            display: -webkit-box;

            overflow: hidden;

            margin: 0 0 18px;

            color: var(--muted);

            font-size: 13px;

            line-height: 1.6;

            -webkit-line-clamp: 3;

            -webkit-box-orient: vertical;
        }


        .menu-bottom {

            display: flex;

            align-items: center;

            justify-content: space-between;

            gap: 12px;

            flex-wrap: wrap;

            margin-top: auto;
        }


        .menu-price {

            color: var(--accent);

            font-size: 19px;

            font-weight: 800;
        }


        .quantity-control {

            display: flex;

            min-height: 36px;

            align-items: center;

            justify-content: flex-end;
        }


        .add-button {

            padding: 9px 22px;

            color: var(--accent);

            background: transparent;

            border: 1.5px solid #a87950;

            border-radius:
                13px 19px 12px 20px /
                16px 12px 19px 13px;

            font-size: 13px;

            font-weight: 700;

            cursor: pointer;

            transition:
                background 0.25s ease,
                color 0.25s ease;
        }


        .add-button:hover {

            color: #fff8ee;

            background: #8b6547;

            border-color: #8b6547;
        }


        .quantity-counter {

            display: inline-flex;

            align-items: center;

            justify-content: space-between;

            gap: 10px;

            min-width: 116px;

            padding: 4px 9px;

            color: var(--text);

            background: transparent;

            border: 1.5px solid #a87950;

            border-radius:
                14px 20px 13px 19px /
                17px 13px 19px 14px;
        }


        .quantity-btn {

            display: inline-flex;

            align-items: center;

            justify-content: center;

            width: 27px;

            height: 29px;

            padding: 0;

            color: var(--accent);

            background: transparent;

            border: none;

            border-radius: 0;

            font-size: 23px;

            font-weight: 500;

            cursor: pointer;

            transition:
                color 0.2s ease,
                transform 0.2s ease;
        }


        .quantity-btn:hover {

            color: #a87950;

            background: transparent;

            transform: scale(1.12);
        }


        .quantity-value {

            display: inline-block;

            min-width: 18px;

            text-align: center;

            color: var(--text);

            font-size: 15px;

            font-weight: 700;
        }


        .add-button:disabled,
        .quantity-btn:disabled {

            opacity: 0.6;

            cursor: wait;
        }


        .unavailable {

            color: var(--muted);

            font-size: 12px;

            font-weight: 700;
        }


        .empty-state {

            padding: 55px 20px;

            text-align: center;

            background: var(--surface);

            border: 1px solid var(--border);

            border-radius: 16px;
        }


        .empty-state h2 {
            margin-top: 0;
        }


        .empty-state p {
            color: var(--muted);
        }


        .back-link {

            display: inline-block;

            margin-top: 15px;

            color: var(--accent);

            font-weight: 700;
        }


        /* Restaurant switch modal */

        .cart-modal {

            position: fixed;

            inset: 0;

            z-index: 9999;

            display: none;

            align-items: center;

            justify-content: center;

            padding: 20px;

            background: rgba(0, 0, 0, 0.62);

            backdrop-filter: blur(5px);
        }


        .cart-modal-box {

            width: min(420px, 100%);

            padding: 26px;

            color: var(--text);

            background: var(--surface);

            border: 1px solid #a87950;

            border-radius: 20px;

            box-shadow:
                0 18px 55px rgba(0, 0, 0, 0.3);
        }


        .cart-modal-box h2 {

            margin: 0 0 12px;

            font-family:
                Georgia,
                "Times New Roman",
                serif;

            font-size: 25px;
        }


        .cart-modal-box p {

            margin: 0;

            color: var(--muted);

            line-height: 1.65;
        }


        .cart-modal-actions {

            display: flex;

            justify-content: flex-end;

            flex-wrap: wrap;

            gap: 12px;

            margin-top: 24px;
        }


        .modal-cancel,
        .modal-confirm {

            padding: 10px 16px;

            border: 1.5px solid #a87950;

            border-radius:
                13px 18px 12px 17px /
                15px 12px 17px 13px;

            font-size: 13px;

            font-weight: 700;

            cursor: pointer;
        }


        .modal-cancel {

            color: var(--text);

            background: transparent;
        }


        .modal-confirm {

            color: #fff8ee;

            background: #8b6547;
        }


        .modal-cancel:disabled,
        .modal-confirm:disabled {

            opacity: 0.6;

            cursor: wait;
        }


        /* ==============================
           FLOATING CART
           ============================== */

        .floating-cart {

            position: fixed;

            right: 24px;

            bottom: 24px;

            z-index: 9998;

            display: none;

            align-items: center;

            gap: 14px;

            width: min(360px, calc(100% - 32px));

            padding: 16px;

            background: var(--surface);

            color: var(--text);

            border: 1px solid var(--accent);

            border-radius: 18px;

            box-shadow:
                0 12px 35px rgba(0, 0, 0, 0.22);

            animation:
                cartCardAppear 0.25s ease;
        }


        .floating-cart.visible {
            display: flex;
        }


        .floating-cart-icon {

            display: flex;

            align-items: center;

            justify-content: center;

            flex-shrink: 0;

            width: 46px;

            height: 30px;

            background: var(--notice);

            border-radius: 14px;

            font-size: 24px;
        }


        .floating-cart-info {

            display: flex;

            flex: 1;

            min-width: 0;

            flex-direction: column;

            gap: 5px;
        }


        #floatingCartCount {

            font-size: 15px;

            font-weight: 800;
        }


        .floating-cart-subtitle {

            color: var(--muted);

            font-size: 12px;
        }


        .floating-cart-button {

            flex-shrink: 0;

            padding: 11px 13px;

            background: var(--accent);

            color: #ffffff;

            border-radius: 11px;

            font-size: 12px;

            font-weight: 700;

            white-space: nowrap;

            text-decoration: none;
        }


        .floating-cart-button:hover {
            opacity: 0.88;
        }


        @keyframes cartCardAppear {

            from {

                opacity: 0;

                transform:
                    translateY(12px);
            }

            to {

                opacity: 1;

                transform:
                    translateY(0);
            }
        }


        @media (max-width: 900px) {

            .menu-grid {

                grid-template-columns:
                    repeat(2, minmax(0, 1fr));
            }
        }


        @media (max-width: 600px) {

            .page-container {

                width: 92%;

                padding-top: 27px;
            }


            .menu-grid {
                grid-template-columns: 1fr;
            }


            .menu-image,
            .image-placeholder {

                height: 220px;
            }


            .cart-modal-actions {

                flex-direction:
                    column-reverse;
            }


            .modal-cancel,
            .modal-confirm {

                width: 100%;
            }
        }


        @media (max-width: 480px) {

            .floating-cart {

                right: 12px;

                bottom: 12px;

                gap: 10px;

                padding: 12px;
            }


            .floating-cart-icon {

                width: 38px;

                height: 38px;

                font-size: 20px;
            }


            .floating-cart-button {

                padding: 10px;

                font-size: 11px;
            }
        }   
        
        .add-button {
    width: 110px;
    height: 38px;
    padding: 0;

    display: inline-flex;
    align-items: center;
    justify-content: center;

    box-sizing: border-box;
    color: var(--accent);
    background: transparent;
    border: 1.5px solid var(--accent);
    border-radius: 10px;

    font-family: inherit;
    font-size: 13px;
    font-weight: 700;
    line-height: 1;
    white-space: nowrap;

    cursor: pointer;
    transition: background 0.25s ease,
                color 0.25s ease,
                transform 0.2s ease;
}

.add-button:hover {
    color: #ffffff;
    background: var(--accent);
    transform: translateY(-1px);
}

.add-button:active {
    transform: scale(0.97);
}
.quantity-counter {
    display: inline-flex;
    align-items: center;
    justify-content: space-between;
    gap: 10px;

    height: 36px;
    min-width: 108px;
    padding: 0 6px;

    box-sizing: border-box;
    border: 1px solid var(--accent);
    border-radius: 10px;
}

.quantity-btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    flex: 0 0 28px;

    width: 28px;
    height: 28px;
    padding: 0;

    border: none;
    border-radius: 7px;
    background: transparent;
    color: var(--accent);

    font-family: inherit;
    font-size: 18px;
    font-weight: 700;
    line-height: 1;
    cursor: pointer;
}

.quantity-btn:hover {
    background: var(--accent);
    color: #ffffff;
}

.quantity-value {
    display: inline-block;
    min-width: 18px;
    text-align: center;
    font-size: 14px;
    font-weight: 700;
    font-variant-numeric: tabular-nums;
}


.floating-cart {
    position: fixed;
    left: 50%;
    bottom: 24px;
    transform: translateX(-50%);

    z-index: 9998;

    display: none;
    align-items: center;
    gap: 18px;

    width: min(600px, calc(100% - 40px));
    min-height: 90px;
    padding: 20px 24px;

    background: var(--surface);
    color: var(--text);

    border: 1px solid var(--accent);
    border-radius: 20px;

    box-shadow: 0 12px 35px rgba(0, 0, 0, 0.22);
}

.floating-cart.visible {
    display: flex;
    animation: cartCardAppear 0.25s ease;
}

.floating-cart-icon {
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;

    width: 52px;
    height: 52px;

    background: var(--notice);
    border-radius: 15px;
    font-size: 26px;
}

.floating-cart-info {
    display: flex;
    flex: 1;
    min-width: 0;
    flex-direction: column;
    gap: 6px;
}

#floatingCartCount {
    font-size: 16px;
    font-weight: 800;
}

.floating-cart-subtitle {
    color: var(--muted);
    font-size: 13px;
}

.floating-cart-button {
    flex-shrink: 0;
    padding: 13px 18px;

    background: var(--accent);
    color: #ffffff;

    border-radius: 12px;
    font-size: 13px;
    font-weight: 700;
    white-space: nowrap;
    text-decoration: none;
}

.floating-cart-button:hover {
    opacity: 0.88;
}

@media (max-width: 480px) {
   .floating-cart {
    min-height: 60px;
    padding: 8px 16px;
    gap: 12px;
}

.floating-cart-icon {
    width: 36px;
    height: 36px;
    font-size: 20px;
}

.floating-cart-button {
    padding: 8px 14px;
}
    </style>

</head>


<body>


    <!-- Shared Navbar -->
    <jsp:include page="/navbar.jsp" />


    <!-- Main Menu -->
    <main class="page-container">


        <section class="page-heading">

            <div class="eyebrow">
                Freshly prepared for you
            </div>

            <h1>
                Explore the Menu
            </h1>

            <p>
                Choose your favourites and add them to your cart.
            </p>

        </section>


        <!-- Cart Notice -->
        <div class="notice"
             id="cartNotice"
             role="status"
             aria-live="polite">
        </div>


        <% if (menuList.isEmpty()) { %>


            <section class="empty-state">

                <h2>
                    No menu items available
                </h2>

                <p>
                    This restaurant does not currently have
                    menu items to display.
                </p>

                <a class="back-link"
                   href="<%= contextPath %>/restaurant?view=restaurants">

                    Browse restaurants

                </a>

            </section>


        <% } else { %>


            <section class="menu-grid">


                <% for (Menu menu : menuList) {

                    if (menu == null) {
                        continue;
                    }

                    int itemQuantity = 0;

                    for (CartItem cartItem : cartItems) {

                        if (cartItem != null
                                && cartItem.getMenu() != null
                                && cartItem.getMenu().getMenuId()
                                    == menu.getMenuId()) {

                            itemQuantity =
                                cartItem.getQuantity();

                            break;
                        }
                    }


                    String imagePath =
                        menu.getImagePath();

                    String imageUrl = null;


                    if (imagePath != null
                            && !imagePath.trim().isEmpty()) {

                        imagePath =
                            imagePath.trim();


                        if (imagePath.startsWith("http://")
                                || imagePath.startsWith("https://")) {

                            imageUrl = imagePath;

                        } else if (imagePath.startsWith("/")) {

                            imageUrl =
                                contextPath + imagePath;

                        } else {

                            imageUrl =
                                contextPath + "/" + imagePath;
                        }
                    }

                %>


                    <article class="menu-card">


                        <% if (imageUrl != null) { %>


                            <img class="menu-image"
                                 src="<%= imageUrl %>"
                                 alt="<%= menu.getItemName() %>"
                                 loading="lazy"
                                 onerror="this.style.display='none';
                                 this.nextElementSibling.style.display='flex';">


                            <div class="image-placeholder"
                                 style="display:none;">

                                Image unavailable

                            </div>


                        <% } else { %>


                            <div class="image-placeholder">

                                No image available

                            </div>


                        <% } %>


                        <div class="menu-content">


                            <h2 class="menu-title">

                                <%= menu.getItemName() %>

                            </h2>


                            <p class="menu-description">

                                <%

                                    String description =
                                        menu.getDescription();

                                    if (description != null
                                            && !description.trim().isEmpty()) {

                                %>

                                    <%= description %>

                                <% } else { %>

                                    A delicious choice from our menu.

                                <% } %>

                            </p>


                            <div class="menu-bottom">


                                <span class="menu-price">

                                    ₹<%= String.format(
                                        java.util.Locale.ROOT,
                                        "%.2f",
                                        menu.getPrice()) %>

                                </span>


                                <div class="quantity-control"
                                     data-menu-id="<%= menu.getMenuId() %>"
                                     data-restaurant-id="<%= menu.getRestaurantId() %>">


                                    <% if (!menu.isAvailable()) { %>


                                        <span class="unavailable">

                                            Unavailable

                                        </span>


                                    <% } else if (itemQuantity <= 0) { %>


                                        <button type="button"
                                                class="add-button add-btn">

                                            + Add

                                        </button>


                                    <% } else { %>


                                        <div class="quantity-counter">


                                            <button type="button"
                                                    class="quantity-btn minus-btn"
                                                    aria-label="Decrease quantity">

                                                −

                                            </button>


                                            <span class="quantity-value">

                                                <%= itemQuantity %>

                                            </span>


                                            <button type="button"
                                                    class="quantity-btn plus-btn"
                                                    aria-label="Increase quantity">

                                                +

                                            </button>


                                        </div>


                                    <% } %>


                                </div>


                            </div>


                        </div>


                    </article>


                <% } %>


            </section>


        <% } %>


    </main>


    <!-- Restaurant Switch Confirmation Modal -->

    <div id="cartModal"
         class="cart-modal"
         role="dialog"
         aria-modal="true"
         aria-labelledby="cartModalTitle"
         aria-describedby="cartModalMessage">


        <div class="cart-modal-box">


            <h2 id="cartModalTitle">
                Change restaurant?
            </h2>


            <p id="cartModalMessage">

                Your cart contains items from another restaurant.
                Clear the existing cart and add this item?

            </p>


            <div class="cart-modal-actions">


                <button type="button"
                        id="cancelCartChange"
                        class="modal-cancel">

                    Cancel

                </button>


                <button type="button"
                        id="confirmCartChange"
                        class="modal-confirm">

                    Clear cart &amp; add

                </button>


            </div>


        </div>


    </div>


    <!-- =========================================
         FLOATING CART CARD
         This is outside the JavaScript.
         Only ONE floating cart exists.
         ========================================= -->

    <div id="floatingCart"
         class="floating-cart <%= cartCount > 0 ? "visible" : "" %>">


        <div class="floating-cart-icon">

            🛒

        </div>


        <div class="floating-cart-info">


            <span id="floatingCartCount">

                <%= cartCount %>
                <%= cartCount == 1 ? "item" : "items" %>

            </span>


            <span class="floating-cart-subtitle">

                Added to your cart

            </span>


        </div>


        <a href="<%= contextPath %>/cart"
           class="floating-cart-button">

            View Cart →

        </a>


    </div>


    <!-- JavaScript -->

    <script>

    (function () {

        "use strict";


        const contextPath =
            "<%= contextPath %>";


        const themeToggle =
            document.getElementById("themeToggle");


        const cartCountElement =
            document.getElementById("cartCount");


        const cartNotice =
            document.getElementById("cartNotice");


        const cartModal =
            document.getElementById("cartModal");


        const cartModalMessage =
            document.getElementById("cartModalMessage");


        const cancelCartChange =
            document.getElementById("cancelCartChange");


        const confirmCartChange =
            document.getElementById("confirmCartChange");


        /*
         * Floating cart elements
         */

        const floatingCart =
            document.getElementById("floatingCart");


        const floatingCartCount =
            document.getElementById("floatingCartCount");


        let pendingRequest = null;

        let requestInProgress = false;


        /*
         * Update floating cart
         */

        function updateFloatingCart(count) {

            const total =
                Number(count) || 0;


            if (floatingCartCount) {

                floatingCartCount.textContent =
                    total +
                    (total === 1
                        ? " item"
                        : " items");
            }


            if (floatingCart) {

                floatingCart.classList.toggle(
                    "visible",
                    total > 0
                );
            }
        }


        /*
         * Update theme button
         */

        function updateThemeButton() {

            if (!themeToggle) {
                return;
            }


            const currentTheme =
                document.documentElement
                    .getAttribute("data-theme");


            themeToggle.textContent =
                currentTheme === "light"
                    ? "☾ Dark Mode"
                    : "☀️ Light Mode";
        }


        /*
         * Theme toggle
         */

        if (themeToggle) {

            themeToggle.addEventListener(
                "click",
                function () {

                    const currentTheme =
                        document.documentElement
                            .getAttribute("data-theme");


                    const newTheme =
                        currentTheme === "light"
                            ? "dark"
                            : "light";


                    document.documentElement
                        .setAttribute(
                            "data-theme",
                            newTheme
                        );


                    try {

                        localStorage.setItem(
                            "culinova-theme",
                            newTheme
                        );

                    } catch (error) {

                        console.warn(
                            "Unable to save theme preference.",
                            error
                        );
                    }


                    updateThemeButton();

                }
            );
        }


        updateThemeButton();


        /*
         * Show notice
         */

        function showCartNotice(message) {

            if (!cartNotice) {
                return;
            }


            cartNotice.textContent =
                message;


            cartNotice.classList.add(
                "show"
            );
        }


        /*
         * Hide notice
         */

        function hideCartNotice() {

            if (!cartNotice) {
                return;
            }


            cartNotice.textContent =
                "";


            cartNotice.classList.remove(
                "show"
            );
        }


        /*
         * Open restaurant change modal
         */

        function openCartModal(
            request,
            message
        ) {

            pendingRequest =
                request;


            cartModalMessage.textContent =
                message ||
                "Your cart contains items from another restaurant. " +
                "Clear the existing cart and add this item?";


            cartModal.style.display =
                "flex";


            confirmCartChange.disabled =
                false;


            cancelCartChange.disabled =
                false;


            confirmCartChange.focus();
        }


        /*
         * Close restaurant change modal
         */

        function closeCartModal() {

            cartModal.style.display =
                "none";


            pendingRequest =
                null;


            confirmCartChange.disabled =
                false;


            cancelCartChange.disabled =
                false;
        }


        /*
         * Cancel restaurant change
         */

        cancelCartChange.addEventListener(
            "click",
            function () {

                if (!requestInProgress) {

                    closeCartModal();
                }
            }
        );


        /*
         * Close modal by clicking outside
         */

        cartModal.addEventListener(
            "click",
            function (event) {

                if (
                    event.target === cartModal
                    && !requestInProgress
                ) {

                    closeCartModal();
                }
            }
        );


        /*
         * Close modal using Escape
         */

        document.addEventListener(
            "keydown",
            function (event) {

                if (
                    event.key === "Escape"
                    && cartModal.style.display === "flex"
                    && !requestInProgress
                ) {

                    closeCartModal();
                }
            }
        );


        /*
         * Render quantity control
         */

        function renderQuantityControl(
            control,
            quantity
        ) {

            if (quantity <= 0) {

                control.innerHTML =
                    '<button type="button" ' +
                    'class="add-button add-btn">' +
                    '+ Add' +
                    '</button>';

                return;
            }


            control.innerHTML =

                '<div class="quantity-counter">' +

                    '<button type="button" ' +
                        'class="quantity-btn minus-btn" ' +
                        'aria-label="Decrease quantity">' +
                        '−' +
                    '</button>' +

                    '<span class="quantity-value">' +
                        quantity +
                    '</span>' +

                    '<button type="button" ' +
                        'class="quantity-btn plus-btn" ' +
                        'aria-label="Increase quantity">' +
                        '+' +
                    '</button>' +

                '</div>';
        }


        /*
         * Send cart request
         */

        async function sendCartRequest(
            request,
            replacingCart
        ) {

            if (requestInProgress) {
                return;
            }


            requestInProgress =
                true;


            hideCartNotice();


            if (replacingCart) {

                confirmCartChange.disabled =
                    true;

                cancelCartChange.disabled =
                    true;
            }


            try {


                const params =
                    new URLSearchParams({

                        action:
                            replacingCart
                                ? "replaceCart"
                                : request.action,

                        menuId:
                            request.menuId,

                        restaurantId:
                            request.restaurantId || "",

                        source:
                            "menu"
                    });


                if (replacingCart) {

                    params.set(
                        "clearCart",
                        "true"
                    );
                }


                const response =
                    await fetch(
                        contextPath + "/cart",
                        {
                            method: "POST",

                            headers: {

                                "Content-Type":
                                    "application/x-www-form-urlencoded;charset=UTF-8",

                                "X-Requested-With":
                                    "XMLHttpRequest"
                            },

                            body: params
                        }
                    );


                const responseText =
                    await response.text();


                let data;


                /*
                 * Convert response to JSON
                 */

                try {

                    data =
                        JSON.parse(
                            responseText
                        );

                } catch (error) {

                    throw new Error(
                        "The server did not return JSON. " +
                        "Check CartController."
                    );
                }


                /*
                 * Restaurant conflict
                 */

                if (
                    data.conflict === true
                    && !replacingCart
                ) {

                    openCartModal(
                        request,
                        data.message
                    );

                    return;
                }


                /*
                 * Failed request
                 */

                if (
                    !response.ok
                    || data.success !== true
                ) {

                    showCartNotice(
                        data.message ||
                        "Unable to update your cart."
                    );

                    return;
                }


                /*
                 * Update navbar cart count
                 * and floating cart count
                 */

                if (
                    data.cartCount !== undefined
                ) {

                    if (cartCountElement) {

                        cartCountElement.textContent =
                            data.cartCount;
                    }


                    updateFloatingCart(
                        data.cartCount
                    );
                }


                /*
                 * Update menu quantity
                 */

                if (
                    data.quantity !== undefined
                ) {

                    const control =
                        document.querySelector(
                            '.quantity-control[data-menu-id="' +
                            request.menuId +
                            '"]'
                        );


                    if (control) {

                        renderQuantityControl(
                            control,
                            Number(data.quantity)
                        );
                    }
                }


                /*
                 * Replacement success
                 */

                if (replacingCart) {

                    closeCartModal();


                    showCartNotice(
                        "Cart cleared. " +
                        "The selected item has been added."
                    );

                } else {

                    showCartNotice(
                        data.message ||
                        "Cart updated successfully."
                    );
                }


            } catch (error) {

                console.error(
                    "Cart update error:",
                    error
                );


                showCartNotice(
                    error.message ||
                    "Unable to update your cart. " +
                    "Please try again."
                );


            } finally {

                requestInProgress =
                    false;


                if (
                    cartModal.style.display === "flex"
                ) {

                    confirmCartChange.disabled =
                        false;

                    cancelCartChange.disabled =
                        false;
                }
            }
        }


        /*
         * Confirm restaurant change
         */

        confirmCartChange.addEventListener(
            "click",
            async function () {

                if (
                    !pendingRequest
                    || requestInProgress
                ) {
                    return;
                }


                const request =
                    pendingRequest;


                await sendCartRequest(
                    request,
                    true
                );
            }
        );


        /*
         * Add / Plus / Minus
         */

        document.addEventListener(
            "click",
            async function (event) {


                const button =
                    event.target.closest(
                        ".add-btn, .plus-btn, .minus-btn"
                    );


                if (
                    !button
                    || requestInProgress
                ) {
                    return;
                }


                const control =
                    button.closest(
                        ".quantity-control"
                    );


                if (!control) {
                    return;
                }


                const menuId =
                    control.dataset.menuId;


                const restaurantId =
                    control.dataset.restaurantId;


                if (!menuId) {

                    showCartNotice(
                        "Menu item ID is missing."
                    );

                    return;
                }


                let action;


                if (
                    button.classList.contains(
                        "add-btn"
                    )
                ) {

                    action = "add";

                } else if (
                    button.classList.contains(
                        "plus-btn"
                    )
                ) {

                    action = "increment";

                } else {

                    action = "decrement";
                }


                await sendCartRequest(
                    {
                        action: action,
                        menuId: menuId,
                        restaurantId: restaurantId
                    },
                    false
                );

            }
        );


    })();

    </script>


</body>

</html>