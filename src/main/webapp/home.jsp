
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.tap.model.Restaurant" %>

<%!
    private String safe(String value) {
        if (value == null) {
            return "";
        }

        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }

    private String restaurantImage(String imagePath) {
        if (imagePath == null || imagePath.trim().isEmpty()) {
            return "https://images.unsplash.com/photo-1552566626-52f8b828add9?auto=format&fit=crop&w=900&q=85";
        }

        return imagePath.trim();
    }
%>

<%
    String contextPath = request.getContextPath();

    List<Restaurant> restaurants =
        (List<Restaurant>) request.getAttribute("restaurants");

    String[] cuisines = {
        "Indian",
        "Chinese",
        "Italian",
        "South Indian",
        "North Indian",
        "Fast Food"
    };
%>

<!DOCTYPE html>
<html lang="en" data-theme="light">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Culinova - Home</title>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>

    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Playfair+Display:wght@500;600;700&display=swap"
          rel="stylesheet">

    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        :root {
            --background: #FAF7F2;
            --surface: #FFFFFF;
            --text: #29231F;
            --muted: #77716B;
            --accent: #B85F3B;
            --accent-hover: #93482C;
            --border: #E9DED4;
            --shadow: 0 15px 40px rgba(53, 38, 29, 0.10);
        }

        html[data-theme="dark"] {
            --background: #171411;
            --surface: #211D19;
            --text: #F5EEE8;
            --muted: #C0B4AA;
            --accent: #D17A54;
            --accent-hover: #E18C65;
            --border: #3B312B;
            --shadow: 0 18px 45px rgba(0, 0, 0, 0.25);
        }

        html {
            scroll-behavior: smooth;
        }

        body {
            font-family: 'DM Sans', sans-serif;
            background: var(--background);
            color: var(--text);
            transition: background 0.25s ease, color 0.25s ease;
        }

        button,
        input {
            font: inherit;
        }

        /* HERO SECTION */

.hero {
    position: relative;
    width: 88%;
    max-width: 1450px;
    height: 450px;
    margin: 30px auto 46px;
    overflow: hidden;
    isolation: isolate;
    display: flex;
    align-items: center;
    border-radius: 22px;
    background: #171411;
    color: #FFFFFF;
    box-shadow: var(--shadow);
}
        .hero-slider {
            position: absolute;
            inset: 0;
            z-index: -2;
            overflow: hidden;
        }

        .hero-slide {
            position: absolute;
            inset: 0;
            width: 100%;
            height: 100%;
            display: block;
            object-fit: cover;
            object-position: center;
        }

        .hero-overlay {
            position: absolute;
            inset: 0;
            z-index: -1;
            background: linear-gradient(
                90deg,
                rgba(10, 8, 7, 0.96) 0%,
                rgba(10, 8, 7, 0.82) 38%,
                rgba(10, 8, 7, 0.42) 68%,
                rgba(10, 8, 7, 0.12) 100%
            );
        }

        html[data-theme="dark"] .hero-overlay {
            background: linear-gradient(
                90deg,
                rgba(0, 0, 0, 0.97) 0%,
                rgba(0, 0, 0, 0.84) 38%,
                rgba(0, 0, 0, 0.48) 68%,
                rgba(0, 0, 0, 0.16) 100%
            );
        }

        .hero-content {
            position: relative;
            z-index: 1;
            width: 75%;
            max-width: 760px;
            padding: 42px;
        }

        .hero-small {
            color: #E8A17E;
            font-size: 12px;
            font-weight: 700;
            letter-spacing: 2.2px;
            text-transform: uppercase;
            margin-bottom: 14px;
        }

        .hero-title {
            font-family: 'Playfair Display', serif;
            font-size: clamp(40px, 4.3vw, 62px);
            line-height: 1.08;
            font-weight: 700;
            margin-bottom: 16px;
        }

        .hero-title span {
            color: #E8A17E;
        }

        .hero-description {
            max-width: 510px;
            color: rgba(255, 255, 255, 0.82);
            font-size: 15px;
            line-height: 1.7;
            margin-bottom: 20px;
        }

        /* SEARCH BAR */

        .search-box {
            width: 100%;
            max-width: 510px;
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 6px;
            background: rgba(255, 255, 255, 0.12);
            border: 1px solid rgba(255, 255, 255, 0.24);
            border-radius: 14px;
            backdrop-filter: blur(8px);
        }

        .search-box input {
            flex: 1;
            min-width: 0;
            border: none;
            outline: none;
            background: transparent;
            padding: 12px 13px;
            color: #FFFFFF;
            font-size: 14px;
        }

        .search-box input::placeholder {
            color: rgba(255, 255, 255, 0.72);
        }

        .search-btn {
            border: none;
            border-radius: 10px;
            padding: 12px 19px;
            background: var(--accent);
            color: #FFFFFF;
            font-size: 13px;
            font-weight: 700;
            cursor: pointer;
            transition: background 0.2s ease;
        }

        .search-btn:hover {
            background: var(--accent-hover);
        }

        /* CUISINE AND RESTAURANT SECTIONS */

        .section {
            width: 88%;
            max-width: 1450px;
            margin: 0 auto 48px;
        }

        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: end;
            margin-bottom: 23px;
        }

        .section-title {
            font-family: 'Playfair Display', serif;
            font-size: clamp(28px, 3vw, 38px);
            line-height: 1.2;
            color: var(--text);
        }

        .section-subtitle {
            color: var(--muted);
            margin-top: 7px;
            font-size: 14px;
            line-height: 1.6;
        }

        /* CUISINE FILTERS */

        .cuisine-container {
            display: flex;
            gap: 11px;
            overflow-x: auto;
            padding: 2px 1px 10px;
            scrollbar-width: thin;
            scrollbar-color: var(--border) transparent;
        }

        .cuisine-btn {
            flex-shrink: 0;
            border: 1px solid var(--border);
            background: var(--surface);
            color: var(--text);
            padding: 10px 19px;
            border-radius: 30px;
            cursor: pointer;
            white-space: nowrap;
            font-size: 13px;
            font-weight: 600;
            transition: 0.2s ease;
        }

        .cuisine-btn:hover,
        .cuisine-btn.active {
            background: var(--accent);
            color: #FFFFFF;
            border-color: var(--accent);
        }

        /* RESTAURANT GRID */

        .restaurant-grid {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 20px;
        }

        .restaurant-card {
            min-width: 0;
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 19px;
            overflow: hidden;
            cursor: pointer;
            box-shadow: 0 8px 26px rgba(50, 35, 25, 0.06);
            transition: transform 0.25s ease, box-shadow 0.25s ease;
        }

        .restaurant-card:hover {
            transform: translateY(-5px);
            box-shadow: var(--shadow);
        }

        .restaurant-image {
            height: 225px;
            position: relative;
            overflow: hidden;
            background: var(--border);
        }

        .restaurant-image img {
            width: 100%;
            height: 100%;
            display: block;
            object-fit: cover;
            transition: transform 0.45s ease;
        }

        .restaurant-card:hover .restaurant-image img {
            transform: scale(1.05);
        }

        .rating {
            position: absolute;
            top: 13px;
            right: 13px;
            background: rgba(255, 255, 255, 0.94);
            color: #29231F;
            padding: 7px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 700;
        }

        .restaurant-info {
            padding: 18px;
        }

        .restaurant-name {
            font-family: 'Playfair Display', serif;
            color: var(--text);
            font-size: 22px;
            line-height: 1.3;
            margin-bottom: 7px;
            overflow-wrap: anywhere;
        }

        .restaurant-cuisine {
            color: var(--accent);
            font-size: 13px;
            font-weight: 700;
            margin-bottom: 12px;
        }

        .restaurant-location {
            color: var(--muted);
            font-size: 13px;
            line-height: 1.5;
            margin-bottom: 7px;
            overflow-wrap: anywhere;
        }

        .delivery-time {
            color: var(--muted);
            font-size: 12px;
        }

        .empty-message {
            grid-column: 1 / -1;
            padding: 35px 20px;
            text-align: center;
            border: 1px dashed var(--border);
            border-radius: 16px;
            color: var(--muted);
            background: var(--surface);
        }

        /* FOOTER */

        .footer {
            margin-top: 70px;
            padding: 38px 7%;
            background: #211D19;
            color: #FFFFFF;
            text-align: center;
        }

        .footer-logo {
            font-family: 'Playfair Display', serif;
            font-size: 28px;
            font-weight: 700;
            margin-bottom: 10px;
        }

        .footer-logo span {
            color: #D17A54;
        }

        .footer p {
            color: #C8BEB8;
            font-size: 13px;
            line-height: 1.7;
        }

        /* TABLET */

        @media (max-width: 1000px) {
            .hero {
                width: 90%;
                height: 375px;
            }

            .hero-content {
                width: 85%;
                padding: 32px;
            }

            .section {
                width: 90%;
            }

            .restaurant-grid {
                grid-template-columns: repeat(2, minmax(0, 1fr));
                gap: 18px;
            }

            .restaurant-image {
                height: 220px;
            }
        }

        /* MOBILE */

        @media (max-width: 650px) {
            .hero {
                width: 92%;
                height: 350px;
                margin: 18px auto 38px;
                border-radius: 17px;
            }

            .hero-content {
                width: 100%;
                padding: 28px 20px;
            }

            .hero-small {
                font-size: 10px;
                letter-spacing: 1.6px;
                margin-bottom: 13px;
            }

            .hero-title {
                font-size: clamp(34px, 8.5vw, 44px);
                margin-bottom: 14px;
            }

            .hero-description {
                font-size: 13px;
                line-height: 1.65;
                margin-bottom: 19px;
            }

            .search-box {
                gap: 3px;
                padding: 5px;
            }

            .search-box input {
                padding: 11px 8px;
                font-size: 12px;
            }

            .search-btn {
                padding: 11px 12px;
                font-size: 12px;
            }

            .section {
                width: 92%;
                margin-bottom: 38px;
            }

            .section-header {
                margin-bottom: 18px;
            }

            .section-title {
                font-size: 29px;
            }

            .section-subtitle {
                font-size: 13px;
            }

            .cuisine-container {
                gap: 8px;
            }

            .cuisine-btn {
                padding: 9px 15px;
                font-size: 12px;
            }

            .restaurant-grid {
                grid-template-columns: 1fr;
                gap: 18px;
            }

            .restaurant-image {
                height: 235px;
            }

            .restaurant-info {
                padding: 17px;
            }

            .restaurant-name {
                font-size: 21px;
            }

            .footer {
                margin-top: 45px;
                padding: 32px 6%;
            }
        }

        @media (prefers-reduced-motion: reduce) {
            *,
            *::before,
            *::after {
                scroll-behavior: auto !important;
                transition-duration: 0.01ms !important;
            }
        }
    </style>
</head>

<body>

    <!-- NAVBAR -->
    <jsp:include page="/navbar.jsp" />

    <!-- HERO SECTION -->
    <section class="hero">

        <div class="hero-slider">
            <img
                class="hero-slide"
                src="<%= contextPath %>/images/biryani.png"
                alt="Delicious chicken biryani"
                fetchpriority="high">
        </div>

        <div class="hero-overlay"></div>

        <div class="hero-content">

            <div class="hero-small">
                TASTE · DISCOVER · ENJOY
            </div>

            <h1 class="hero-title">
                Discover<br>
                Delicious <span>Food.</span>
            </h1>

            <p class="hero-description">
                Explore amazing restaurants, discover your favourite
                flavours, and enjoy delicious meals delivered to your door.
            </p>

            <div class="search-box">
                <input
                    type="text"
                    id="restaurantSearch"
                    placeholder="Search restaurants or cuisines..."
                    aria-label="Search restaurants or cuisines">

                <button
                    type="button"
                    class="search-btn"
                    onclick="searchRestaurants()">
                    Search
                </button>
            </div>

        </div>
    </section>

    <!-- CUISINE SECTION -->
    <section class="section">

        <div class="section-header">
            <div>
                <h2 class="section-title">Explore cuisines</h2>
                <p class="section-subtitle">
                    Find the flavour you're craving.
                </p>
            </div>
        </div>

        <div class="cuisine-container">

            <button
                type="button"
                class="cuisine-btn active"
                data-cuisine="all">
                All
            </button>

            <% for (String cuisine : cuisines) { %>
                <button
                    type="button"
                    class="cuisine-btn"
                    data-cuisine="<%= safe(cuisine) %>">
                    <%= safe(cuisine) %>
                </button>
            <% } %>

        </div>
    </section>

    <!-- RESTAURANT SECTION -->
    <section class="section">

        <div class="section-header">
            <div>
                <h2 class="section-title">Restaurants near you</h2>
                <p class="section-subtitle">
                    Discover places for your next meal.
                </p>
            </div>
        </div>

        <div class="restaurant-grid" id="restaurantGrid">

            <%
                boolean hasRestaurants = false;

                if (restaurants != null) {
                    for (Restaurant restaurant : restaurants) {

                        if (restaurant == null || !restaurant.isActive()) {
                            continue;
                        }

                        hasRestaurants = true;

                        String restaurantName = restaurant.getName();
                        String cuisineType = restaurant.getCuisineType();
                        String address = restaurant.getAddress();
                        String imagePath = restaurant.getImagePath();
                        String deliveryTime = restaurant.getDeliveryTime();

                        String restaurantUrl =
                            contextPath + "/menu?restaurantId="
                            + restaurant.getRestaurantId();

                        String cuisineForFilter =
                            cuisineType == null ? "" : cuisineType.trim();

                        String ratingText =
                            String.valueOf(restaurant.getRating());

                        String finalImage = restaurantImage(imagePath);
            %>

                <article
                    class="restaurant-card"
                    tabindex="0"
                    role="link"
                    aria-label="Open <%= safe(restaurantName) %> menu"
                    data-cuisine="<%= safe(cuisineForFilter) %>"
                    data-url="<%= safe(restaurantUrl) %>">

                    <div class="restaurant-image">

                        <img
                            src="<%= safe(finalImage) %>"
                            alt="<%= safe(restaurantName) %>"
                            loading="lazy"
                            onerror="this.onerror=null;this.src='https://images.unsplash.com/photo-1552566626-52f8b828add9?auto=format&fit=crop&w=900&q=85';">

                        <div class="rating">
                            ★ <%= safe(ratingText) %>
                        </div>

                    </div>

                    <div class="restaurant-info">

                        <h3 class="restaurant-name">
                            <%= safe(restaurantName) %>
                        </h3>

                        <div class="restaurant-cuisine">
                            <%= safe(cuisineType == null
                                || cuisineType.trim().isEmpty()
                                ? "Restaurant" : cuisineType) %>
                        </div>

                        <div class="restaurant-location">
                            &#128205;
                            <%= safe(address == null
                                || address.trim().isEmpty()
                                ? "Address unavailable" : address) %>
                        </div>

                        <div class="delivery-time">
                            &#128336;
                            <%= safe(deliveryTime == null
                                || deliveryTime.trim().isEmpty()
                                ? "Delivery time varies" : deliveryTime) %>
                        </div>

                    </div>
                </article>

            <%
                    }
                }
            %>

            <% if (!hasRestaurants) { %>
                <div class="empty-message" id="emptyMessage">
                    No active restaurants are available right now.
                    Please check back later.
                </div>
            <% } %>

        </div>

        <p
            id="noSearchResults"
            class="empty-message"
            style="display:none; margin-top:20px;">
            No restaurants match your search.
        </p>

    </section>

    <!-- FOOTER -->
    <footer class="footer">

        <div class="footer-logo">
            Culi<span>nova</span>
        </div>

        <p>
            Discover flavours. Share moments. Enjoy every bite.
        </p>

        <p style="margin-top:12px;">
            &copy; 2026 Culinova. All rights reserved.
        </p>

    </footer>

    <script>
        /* RESTAURANT SEARCH AND CUISINE FILTER */

        let selectedCuisine = "all";

        function normalize(value) {
            return (value || "").trim().toLowerCase();
        }

        function updateRestaurants() {
            const searchInput =
                document.getElementById("restaurantSearch");

            const searchValue =
                normalize(searchInput ? searchInput.value : "");

            const cards =
                document.querySelectorAll(".restaurant-card");

            const noResults =
                document.getElementById("noSearchResults");

            let visibleCount = 0;

            cards.forEach(function (card) {
                const nameElement =
                    card.querySelector(".restaurant-name");

                const cuisineElement =
                    card.querySelector(".restaurant-cuisine");

                const locationElement =
                    card.querySelector(".restaurant-location");

                const name =
                    normalize(nameElement ? nameElement.textContent : "");

                const cuisine =
                    normalize(cuisineElement ? cuisineElement.textContent : "");

                const location =
                    normalize(locationElement ? locationElement.textContent : "");

                const cardCuisine =
                    normalize(card.dataset.cuisine);

                const matchesSearch =
                    name.includes(searchValue) ||
                    cuisine.includes(searchValue) ||
                    location.includes(searchValue);

                const matchesCuisine =
                    selectedCuisine === "all" ||
                    cardCuisine === normalize(selectedCuisine);

                const visible = matchesSearch && matchesCuisine;

                card.style.display = visible ? "" : "none";

                if (visible) {
                    visibleCount++;
                }
            });

            if (noResults) {
                noResults.style.display =
                    cards.length > 0 && visibleCount === 0
                    ? "block" : "none";
            }
        }

        function searchRestaurants() {
            updateRestaurants();
        }

        document.querySelectorAll(".cuisine-btn").forEach(function (button) {
            button.addEventListener("click", function () {
                document.querySelectorAll(".cuisine-btn").forEach(
                    function (item) {
                        item.classList.remove("active");
                    }
                );

                button.classList.add("active");
                selectedCuisine = button.dataset.cuisine || "all";

                updateRestaurants();
            });
        });

        const searchInput =
            document.getElementById("restaurantSearch");

        if (searchInput) {
            searchInput.addEventListener("input", updateRestaurants);

            searchInput.addEventListener("keydown", function (event) {
                if (event.key === "Enter") {
                    updateRestaurants();
                }
            });
        }

        /* OPEN RESTAURANT MENU */

        document.querySelectorAll(".restaurant-card").forEach(function (card) {
            function openCard() {
                const url = card.dataset.url;

                if (url) {
                    window.location.href = url;
                }
            }

            card.addEventListener("click", openCard);

            card.addEventListener("keydown", function (event) {
                if (event.key === "Enter" || event.key === " ") {
                    event.preventDefault();
                    openCard();
                }
            });
        });

        /* RESTORE SAVED THEME */

        (function () {
            const root = document.documentElement;
            const themeKey = "culinova-theme";

            try {
                const savedTheme = localStorage.getItem(themeKey);

                if (savedTheme === "light" || savedTheme === "dark") {
                    root.setAttribute("data-theme", savedTheme);
                }
            } catch (error) {
                // Use the default theme if local storage is unavailable.
            }
        })();
    </script>

</body>
</html>
