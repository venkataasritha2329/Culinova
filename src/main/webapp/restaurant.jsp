
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.tap.model.Restaurant" %>

<%!
    public String safe(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }
%>

<%
    List<Restaurant> restaurants =
        (List<Restaurant>) request.getAttribute("restaurants");

    String contextPath = request.getContextPath();
%>



<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Culinova - Restaurants</title>

<link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Playfair+Display:wght@600;700&display=swap"
      rel="stylesheet">

<style>
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

:root {
    color-scheme: light;
    --page-bg: #FAF7F2;
    --surface: #FFFFFF;
    --text: #211B17;
    --muted: #81736A;
    --secondary-text: #51443B;
    --border: #EEE5DC;
    --input-border: #E6D8CC;
    --input-bg: #FFFFFF;
    --accent: #B85F3B;
    --accent-soft: #F8EAE1;
    --accent-text: #A34F30;
    --card-shadow: rgba(75, 47, 29, .10);
    --meta-border: #F0E8E0;
    --rating-bg: #EAF5E9;
    --rating-text: #286B39;
    --open-text: #247447;
    --closed-text: #A33D35;
    --image-bg: #EFE6DC;
    --empty-border: #DCCBBE;
    --footer-bg: #211B17;
    --footer-text: #D8C9BD;
}

html[data-theme="dark"] {
    color-scheme: dark;
    --page-bg: #171411;
    --surface: #211C18;
    --text: #F4EDE6;
    --muted: #B5A69A;
    --secondary-text: #DED0C4;
    --border: #3A3029;
    --input-border: #493A30;
    --input-bg: #211C18;
    --accent: #D17A54;
    --accent-soft: #3B2921;
    --accent-text: #F0A17D;
    --card-shadow: rgba(0, 0, 0, .30);
    --meta-border: #3A3029;
    --rating-bg: #25372A;
    --rating-text: #A7D8AF;
    --open-text: #8BD4A4;
    --closed-text: #F19B91;
    --image-bg: #302720;
    --empty-border: #514034;
    --footer-bg: #110F0D;
    --footer-text: #D8C9BD;
}

html {
    min-height: 100%;
    background: var(--page-bg);
}

body {
    min-height: 100vh;
    display: flex;
    flex-direction: column;
    font-family: 'DM Sans', sans-serif;
    background: var(--page-bg);
    color: var(--text);
    transition: background .25s, color .25s;
}

a {
    text-decoration: none;
    color: inherit;
}

/* NAVBAR */

.navbar {
    min-height: 88px;
    padding: 16px 7%;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 20px;
    background: var(--surface);
    border-bottom: 1px solid var(--border);
}

.logo {
    font-family: 'Playfair Display', serif;
    font-size: 29px;
    font-weight: 700;
    color: var(--accent);
}

.nav-links {
    display: flex;
    align-items: center;
    gap: 28px;
}

.nav-links a {
    font-size: 14px;
    font-weight: 600;
    color: var(--secondary-text);
}

.nav-links a:hover,
.nav-links .active {
    color: var(--accent);
}

.profile-link {
    padding: 10px 16px;
    border-radius: 24px;
    background: var(--accent-soft);
    color: var(--accent-text) !important;
}

/* RESTAURANT SECTION */

.restaurant-section {
    width: 86%;
    max-width: 1450px;
    margin: 45px auto 70px;
    flex: 1;
}

/* TITLE AND SEARCH */

.section-heading {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 25px;
    margin-bottom: 30px;
}

.heading-text h1 {
    font-family: 'Playfair Display', serif;
    font-size: clamp(27px, 3vw, 36px);
    line-height: 1.25;
    color: var(--text);
}

.heading-text p {
    margin-top: 9px;
    color: var(--muted);
    font-size: 14px;
    line-height: 1.6;
}

.search-box {
    width: 330px;
    max-width: 100%;
    position: relative;
    flex-shrink: 0;
}

.search-box input {
    width: 100%;
    padding: 14px 18px 14px 44px;
    border: 1px solid var(--input-border);
    border-radius: 13px;
    background: var(--input-bg);
    color: var(--text);
    font-family: inherit;
    font-size: 14px;
    outline: none;
    transition: border-color .2s, box-shadow .2s;
}

.search-box input:focus {
    border-color: var(--accent);
    box-shadow: 0 0 0 3px rgba(184, 95, 59, .15);
}

.search-box input::placeholder {
    color: var(--muted);
}

.search-icon {
    position: absolute;
    left: 16px;
    top: 50%;
    transform: translateY(-50%);
    font-size: 17px;
    color: var(--muted);
    pointer-events: none;
}

/* RESTAURANT GRID */

.restaurant-grid {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 25px;
}

.restaurant-card {
    display: block;
    min-width: 0;
    overflow: hidden;
    border: 1px solid var(--border);
    border-radius: 17px;
    background: var(--surface);
    color: var(--text);
    transition: transform .2s, box-shadow .2s, border-color .2s;
}

.restaurant-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 12px 28px var(--card-shadow);
    border-color: var(--accent);
}

.restaurant-image {
    position: relative;
    height: 205px;
    background: var(--image-bg);
}

.restaurant-image img {
    display: block;
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.status {
    position: absolute;
    top: 13px;
    right: 13px;
    padding: 7px 11px;
    border-radius: 20px;
    background: var(--surface);
    font-size: 11px;
    font-weight: 700;
}

.status.open {
    color: var(--open-text);
}

.status.closed {
    color: var(--closed-text);
}

.restaurant-info {
    padding: 19px;
}

.restaurant-title-row {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    gap: 10px;
}

.restaurant-title-row h2 {
    font-size: 18px;
    line-height: 1.4;
    overflow-wrap: anywhere;
    color: var(--text);
}

.rating {
    flex-shrink: 0;
    padding: 5px 8px;
    border-radius: 7px;
    background: var(--rating-bg);
    color: var(--rating-text);
    font-size: 12px;
    font-weight: 700;
}

.cuisine {
    margin-top: 8px;
    color: var(--muted);
    font-size: 13px;
}

.restaurant-meta {
    display: flex;
    justify-content: space-between;
    gap: 10px;
    margin-top: 17px;
    padding-top: 14px;
    border-top: 1px solid var(--meta-border);
    color: var(--secondary-text);
    font-size: 12px;
}

.address {
    margin-top: 12px;
    color: var(--muted);
    font-size: 12px;
    line-height: 1.5;
    overflow-wrap: anywhere;
}

/* EMPTY STATES */

.empty-state {
    grid-column: 1 / -1;
    padding: 60px 20px;
    border: 1px dashed var(--empty-border);
    border-radius: 16px;
    text-align: center;
    color: var(--muted);
}

.empty-state h2 {
    margin-bottom: 10px;
    color: var(--text);
}

.empty-state p {
    font-size: 14px;
}

/* FOOTER */

.footer {
    padding: 25px;
    background: var(--footer-bg);
    color: var(--footer-text);
    text-align: center;
    font-size: 13px;
}

/* RESPONSIVE */

@media (max-width: 1050px) {
    .restaurant-grid {
        grid-template-columns: repeat(2, minmax(0, 1fr));
    }

    .navbar {
        padding: 18px 4%;
        flex-wrap: wrap;
    }

    .nav-links {
        gap: 16px;
        flex-wrap: wrap;
    }

    .section-heading {
        align-items: flex-start;
    }

    .search-box {
        width: 270px;
    }
}

@media (max-width: 650px) {
    .restaurant-section {
        width: 92%;
        margin-top: 30px;
    }

    .section-heading {
        flex-direction: column;
        align-items: stretch;
        gap: 20px;
    }

    .search-box {
        width: 100%;
    }

    .restaurant-grid {
        grid-template-columns: 1fr;
        gap: 20px;
    }

    .nav-links {
        gap: 12px;
    }

    .nav-links a {
        font-size: 13px;
    }

    .logo {
        font-size: 25px;
    }
}
</style>

<script>
/* Apply the saved theme before the page is displayed. */
(function () {
    try {
        var savedTheme = localStorage.getItem("culinova-theme");
        if (savedTheme === "light" || savedTheme === "dark") {
            document.documentElement.setAttribute("data-theme", savedTheme);
        }
    } catch (e) {
        /* Keep the default light theme if storage is unavailable. */
    }
})();
</script>
</head>

<body>

<jsp:include page="/navbar.jsp" />

<section class="restaurant-section">

    <div class="section-heading">
        <div class="heading-text">
            <h1>Explore Restaurants</h1>
            <p>Discover restaurants and find your next favourite meal.</p>
        </div>

        <div class="search-box">
            <span class="search-icon">&#9906;</span>
            <input
                type="search"
                id="searchInput"
                placeholder="Search restaurants or cuisines..."
                aria-label="Search restaurants by name or cuisine"
                oninput="filterRestaurants()">
        </div>
    </div>

    <div class="restaurant-grid" id="restaurantGrid">

        <% if (restaurants != null && !restaurants.isEmpty()) { %>

            <% for (Restaurant restaurant : restaurants) {

                String imagePath = restaurant.getImagePath();

                if (imagePath == null || imagePath.trim().isEmpty()) {
                    imagePath = contextPath + "/images/logo1.png";
                } else if (!imagePath.startsWith("http://")
                        && !imagePath.startsWith("https://")
                        && !imagePath.startsWith("/")) {
                    imagePath = contextPath + "/" + imagePath;
                }

                double rating = restaurant.getRating();
                boolean active = restaurant.isActive();
            %>

            <a class="restaurant-card"
               href="<%= contextPath %>/menu?restaurantId=<%= restaurant.getRestaurantId() %>"
               data-name="<%= safe(restaurant.getName()).toLowerCase(java.util.Locale.ROOT) %>"
               data-cuisine="<%= safe(restaurant.getCuisineType()).toLowerCase(java.util.Locale.ROOT) %>">

                <div class="restaurant-image">
                    <img
                        src="<%= safe(imagePath) %>"
                        alt="<%= safe(restaurant.getName()) %>"
                        loading="lazy"
                        onerror="this.onerror=null;this.src='<%= contextPath %>/images/logo1.png';">

                    <span class="status <%= active ? "open" : "closed" %>">
                        <%= active ? "Open" : "Closed" %>
                    </span>
                </div>

                <div class="restaurant-info">
                    <div class="restaurant-title-row">
                        <h2><%= safe(restaurant.getName()) %></h2>
                        <span class="rating">
                            &#9733;
                            <%= String.format(java.util.Locale.US, "%.1f", rating) %>
                        </span>
                    </div>

                    <p class="cuisine">
                        <%= safe(restaurant.getCuisineType()) %>
                    </p>

                    <div class="restaurant-meta">
                        <span>&#9201; <%= safe(restaurant.getDeliveryTime()) %></span>
                        <span>View Menu &#8594;</span>
                    </div>

                    <p class="address">
                        &#128205; <%= safe(restaurant.getAddress()) %>
                    </p>
                </div>
            </a>

            <% } %>

        <% } else { %>

            <div class="empty-state">
                <h2>No Restaurants Available</h2>
                <p>Restaurants from your database will appear here.</p>
            </div>

        <% } %>

    </div>

    <div class="empty-state" id="searchEmptyState" style="display:none;">
        <h2>No Matching Restaurants</h2>
        <p>Try searching with a different restaurant name or cuisine.</p>
    </div>

</section>

<footer class="footer">
    &copy; 2026 Culinova. All rights reserved.
</footer>

<script>
function filterRestaurants() {
    const searchInput = document.getElementById("searchInput");
    const search = searchInput.value.trim().toLowerCase();

    const grid = document.getElementById("restaurantGrid");
    const cards = grid.querySelectorAll("a.restaurant-card");

    let visibleCount = 0;

    cards.forEach(function(card) {
        const name = card.dataset.name || "";
        const cuisine = card.dataset.cuisine || "";

        const matches = name.includes(search) || cuisine.includes(search);
        card.style.display = matches ? "" : "none";

        if (matches) {
            visibleCount++;
        }
    });

    const emptyState = document.getElementById("searchEmptyState");
    emptyState.style.display =
        cards.length > 0 && visibleCount === 0 ? "block" : "none";
}
</script>

</body>
</html>
