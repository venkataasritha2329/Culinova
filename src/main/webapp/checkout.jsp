
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%@ page import="com.tap.model.User" %>
<%@ page import="com.tap.model.CartItem" %>
<%@ page import="com.tap.model.Menu" %>

<%
    User user = (User) session.getAttribute("user");

    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String error = request.getParameter("error");

    List<CartItem> cartItems =
        (List<CartItem>) session.getAttribute("cartItems");

    if (cartItems == null || cartItems.isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/cart.jsp");
        return;
    }

    String fullName = user.getUsername() == null
        ? "" : user.getUsername();

    String email = user.getEmail() == null
        ? "" : user.getEmail();

    String phone = String.valueOf(user.getPhone());

    Object addressValue = user.getAddress();
    String address = addressValue == null ? "" : addressValue.toString();

    Object landmarkValue = user.getLandmark();
    String landmark = landmarkValue == null ? "" : landmarkValue.toString();

    Object cityValue = user.getCity();
    String city = cityValue == null ? "" : cityValue.toString();

    Object stateValue = user.getState();
    String state = stateValue == null ? "" : stateValue.toString();

    Object pincodeValue = user.getPincode();
    String pincode = pincodeValue == null ? "" : pincodeValue.toString();

    Object instructionsValue = user.getDeliveryInstructions();
    String instructions = instructionsValue == null
        ? "" : instructionsValue.toString();

    double subtotal = 0.0;

    for (CartItem item : cartItems) {
        if (item != null && item.getMenu() != null) {
            subtotal += item.getMenu().getPrice() * item.getQuantity();
        }
    }

    double deliveryFee = 40.0;
    double tax = subtotal * 0.05;
    double total = subtotal + deliveryFee + tax;

    session.setAttribute("paymentAmount", total);

    String contextPath = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Culinova - Checkout</title>

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Playfair+Display:wght@600;700&display=swap"
      rel="stylesheet">

<style>
:root {
    --page: #faf7f2;
    --surface: #ffffff;
    --text: #28231f;
    --muted: #81776f;
    --accent: #b85f3b;
    --accent-hover: #9f4c2d;
    --border: #e9e0d8;
    --soft: #f6eee7;
    --shadow: 0 10px 35px rgba(65, 43, 29, 0.07);
}

* {
    box-sizing: border-box;
}

body {
    margin: 0;
    font-family: 'DM Sans', sans-serif;
    background: var(--page);
    color: var(--text);
}

a {
    color: var(--accent);
    text-decoration: none;
}

.navbar {
    min-height: 76px;
    padding: 16px 6%;
    background: var(--surface);
    border-bottom: 1px solid var(--border);
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 20px;
}

.logo {
    font-family: 'Playfair Display', serif;
    font-size: 29px;
    font-weight: 700;
    color: var(--accent);
}

.nav-links {
    display: flex;
    gap: 24px;
    align-items: center;
    flex-wrap: wrap;
}

.nav-links a {
    color: var(--text);
    font-size: 14px;
    font-weight: 600;
}

.nav-links a:hover {
    color: var(--accent);
}

.page-heading {
    max-width: 1200px;
    margin: 38px auto 24px;
    padding: 0 22px;
}

.page-heading h1 {
    margin: 0 0 8px;
    font-family: 'Playfair Display', serif;
    font-size: clamp(30px, 4vw, 42px);
}

.page-heading p {
    margin: 0;
    color: var(--muted);
    line-height: 1.6;
}

.checkout-container {
    max-width: 1200px;
    margin: 0 auto 60px;
    padding: 0 22px;
    display: grid;
    grid-template-columns: minmax(0, 1.45fr) minmax(300px, 0.8fr);
    gap: 26px;
    align-items: start;
}

.left-column,
.right-column {
    display: flex;
    flex-direction: column;
    gap: 22px;
}

.panel {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 20px;
    padding: 26px;
    box-shadow: var(--shadow);
}

.panel h2 {
    margin: 0 0 8px;
    font-size: 21px;
}

.panel-description {
    color: var(--muted);
    font-size: 13px;
    line-height: 1.6;
    margin: 0 0 22px;
}

.form-grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 17px;
}

.form-group {
    display: flex;
    flex-direction: column;
    gap: 8px;
    min-width: 0;
}

.form-group.full {
    grid-column: 1 / -1;
}

.form-group label {
    font-size: 13px;
    font-weight: 700;
}

.form-group input,
.form-group textarea {
    width: 100%;
    padding: 13px 14px;
    border: 1px solid var(--border);
    border-radius: 11px;
    outline: none;
    background: #fffdfa;
    color: var(--text);
    font: inherit;
    font-size: 14px;
    transition: border-color 0.2s, box-shadow 0.2s;
}

.form-group input:focus,
.form-group textarea:focus {
    border-color: var(--accent);
    box-shadow: 0 0 0 3px rgba(184, 95, 59, 0.10);
}

.form-group textarea {
    min-height: 90px;
    resize: vertical;
}

.payment-options {
    display: flex;
    flex-direction: column;
    gap: 12px;
}

.payment-option {
    display: flex;
    align-items: flex-start;
    gap: 13px;
    padding: 17px;
    border: 1px solid var(--border);
    border-radius: 13px;
    cursor: pointer;
    transition: border-color 0.2s, background 0.2s;
}

.payment-option:has(input:checked) {
    border-color: var(--accent);
    background: #fff8f3;
}

.payment-option input {
    margin-top: 4px;
    accent-color: var(--accent);
    width: 17px;
    height: 17px;
    flex-shrink: 0;
}

.payment-option strong {
    display: block;
    margin-bottom: 5px;
    font-size: 14px;
}

.payment-option small {
    color: var(--muted);
    line-height: 1.5;
    display: block;
}

.payment-icon {
    width: 42px;
    height: 42px;
    flex-shrink: 0;
    border-radius: 12px;
    background: var(--soft);
    display: grid;
    place-items: center;
    font-size: 21px;
}

.order-item {
    display: flex;
    justify-content: space-between;
    gap: 14px;
    padding: 15px 0;
    border-bottom: 1px solid var(--border);
}

.order-item:last-of-type {
    border-bottom: none;
}

.item-name {
    font-weight: 700;
    font-size: 14px;
    overflow-wrap: anywhere;
}

.item-quantity {
    margin-top: 5px;
    font-size: 12px;
    color: var(--muted);
}

.item-price {
    font-size: 14px;
    font-weight: 700;
    white-space: nowrap;
}

.summary-row {
    display: flex;
    justify-content: space-between;
    gap: 14px;
    margin: 15px 0;
    font-size: 14px;
}

.summary-row span:first-child {
    color: var(--muted);
}

.summary-row span:last-child {
    font-weight: 600;
}

.total-row {
    border-top: 1px solid var(--border);
    padding-top: 19px;
    margin-top: 19px;
    font-size: 19px;
    font-weight: 700;
}

.total-row span:first-child {
    color: var(--text);
}

.place-order-btn {
    display: block;
    width: 100%;
    padding: 16px;
    border: none;
    border-radius: 12px;
    background: var(--accent);
    color: white;
    font: inherit;
    font-size: 15px;
    font-weight: 700;
    cursor: pointer;
    transition: background 0.2s, transform 0.2s;
    margin-top: 22px;
}

.place-order-btn:hover {
    background: var(--accent-hover);
    transform: translateY(-1px);
}

.place-order-btn:disabled {
    opacity: 0.65;
    cursor: wait;
    transform: none;
}

.secure-note {
    margin: 14px 0 0;
    text-align: center;
    color: var(--muted);
    font-size: 12px;
    line-height: 1.6;
}

.error-message {
    max-width: 1156px;
    margin: 0 auto 20px;
    padding: 14px 18px;
    border-radius: 12px;
    border: 1px solid #efc3b9;
    background: #fff0ed;
    color: #9b3023;
    font-size: 14px;
}

.back-link {
    display: inline-block;
    margin-top: 20px;
    font-size: 13px;
    font-weight: 700;
}

@media (max-width: 850px) {
    .checkout-container {
        grid-template-columns: 1fr;
    }

    .right-column {
        order: -1;
    }
}

@media (max-width: 560px) {
    .navbar {
        align-items: flex-start;
        flex-direction: column;
    }

    .nav-links {
        gap: 15px;
    }

    .page-heading {
        margin-top: 26px;
    }

    .panel {
        padding: 19px;
        border-radius: 16px;
    }

    .form-grid {
        grid-template-columns: 1fr;
    }

    .form-group.full {
        grid-column: auto;
    }
}
</style>
</head>

<body>



<section class="page-heading">
    <h1>Complete your order</h1>
    <p>Confirm your delivery details and choose your preferred payment method.</p>
</section>

<% if ("order".equals(error)) { %>
    <div class="error-message">
        We couldn't place your order. Please check your details and try again.
    </div>
<% } else if ("address".equals(error)) { %>
    <div class="error-message">
        Please provide valid delivery information.
    </div>
<% } else if ("payment".equals(error)) { %>
    <div class="error-message">
        Payment could not be completed. Please try again.
    </div>
<% } %>

<main class="checkout-container">

    <div class="left-column">

        <form id="checkoutForm"
              action="<%= contextPath %>/checkout"
              method="post">

            <section class="panel">
                <h2>Delivery information</h2>
                <p class="panel-description">
                    Where should we deliver your delicious order?
                </p>

                <div class="form-grid">

                    <div class="form-group">
                        <label for="fullName">Full name</label>
                        <input type="text"
                               id="fullName"
                               name="fullName"
                               value="<%= fullName %>"
                               maxlength="100"
                               autocomplete="name"
                               required>
                    </div>

                    <div class="form-group">
                        <label for="phone">Phone number</label>
                        <input type="tel"
                               id="phone"
                               name="phone"
                               value="<%= phone %>"
                               maxlength="15"
                               autocomplete="tel"
                               required>
                    </div>

                    <div class="form-group full">
                        <label for="email">Email address</label>
                        <input type="email"
                               id="email"
                               name="email"
                               value="<%= email %>"
                               maxlength="150"
                               autocomplete="email"
                               required>
                    </div>

                    <div class="form-group full">
                        <label for="address">Street address</label>
                        <input type="text"
                               id="address"
                               name="address"
                               value="<%= address %>"
                               maxlength="250"
                               autocomplete="street-address"
                               required>
                    </div>

                    <div class="form-group">
                        <label for="landmark">Landmark</label>
                        <input type="text"
                               id="landmark"
                               name="landmark"
                               value="<%= landmark %>"
                               maxlength="150"
                               placeholder="Nearby landmark">
                    </div>

                    <div class="form-group">
                        <label for="pincode">PIN code</label>
                        <input type="text"
                               id="pincode"
                               name="pincode"
                               value="<%= pincode %>"
                               maxlength="10"
                               autocomplete="postal-code"
                               required>
                    </div>

                    <div class="form-group">
                        <label for="city">City</label>
                        <input type="text"
                               id="city"
                               name="city"
                               value="<%= city %>"
                               maxlength="100"
                               autocomplete="address-level2"
                               required>
                    </div>

                    <div class="form-group">
                        <label for="state">State</label>
                        <input type="text"
                               id="state"
                               name="state"
                               value="<%= state %>"
                               maxlength="100"
                               autocomplete="address-level1"
                               required>
                    </div>

                    <div class="form-group full">
                        <label for="instructions">Delivery instructions</label>
                        <textarea id="instructions"
                                  name="instructions"
                                  maxlength="500"
                                  placeholder="Optional instructions for the delivery partner"><%= instructions %></textarea>
                    </div>

                </div>
            </section>

            <section class="panel">
                <h2>Payment method</h2>
                <p class="panel-description">
                    Choose how you would like to pay.
                </p>

                <div class="payment-options">

                    <label class="payment-option">
                        <input type="radio"
                               name="paymentMode"
                               value="COD"
                               checked>

                        <span class="payment-icon">💵</span>

                        <span>
                            <strong>Cash on Delivery</strong>
                            <small>Pay when your order arrives.</small>
                        </span>
                    </label>

                    <label class="payment-option">
                        <input type="radio"
                               name="paymentMode"
                               value="ONLINE">

                        <span class="payment-icon">🔒</span>

                        <span>
                            <strong>Online Payment</strong>
                            <small>Pay securely using UPI, credit/debit card, or net banking through Razorpay.</small>
                        </span>
                    </label>

                </div>
            </section>

        </form>

    </div>

    <aside class="right-column">

        <section class="panel">
            <h2>Order summary</h2>
            <p class="panel-description">
                Review your items before placing the order.
            </p>

            <% for (CartItem item : cartItems) {
                   if (item == null || item.getMenu() == null) {
                       continue;
                   }

                   Menu menu = item.getMenu();
                   double itemTotal = menu.getPrice() * item.getQuantity();
            %>

                <div class="order-item">
                    <div>
                        <div class="item-name">
                            <%= menu.getItemName() %>
                        </div>

                        <div class="item-quantity">
                            Qty: <%= item.getQuantity() %>
                            &times;
                            &#8377;<%= String.format(Locale.US, "%.2f", menu.getPrice()) %>
                        </div>
                    </div>

                    <div class="item-price">
                        &#8377;<%= String.format(Locale.US, "%.2f", itemTotal) %>
                    </div>
                </div>

            <% } %>

            <div class="summary-row">
                <span>Subtotal</span>
                <span>&#8377;<%= String.format(Locale.US, "%.2f", subtotal) %></span>
            </div>

            <div class="summary-row">
                <span>Delivery fee</span>
                <span>&#8377;<%= String.format(Locale.US, "%.2f", deliveryFee) %></span>
            </div>

            <div class="summary-row">
                <span>Tax (5%)</span>
                <span>&#8377;<%= String.format(Locale.US, "%.2f", tax) %></span>
            </div>

            <div class="summary-row total-row">
                <span>Total</span>
                <span>&#8377;<%= String.format(Locale.US, "%.2f", total) %></span>
            </div>

            <button type="submit"
                    id="placeOrderBtn"
                    class="place-order-btn"
                    form="checkoutForm">
                Place Order · &#8377;<%= String.format(Locale.US, "%.2f", total) %>
            </button>

            <p class="secure-note">
                Your order total is calculated from your cart.
                Online payment is processed through Razorpay.
            </p>

            <a class="back-link"
               href="<%= contextPath %>/cart.jsp">
                &#8592; Back to cart
            </a>
        </section>

    </aside>

</main>

<script src="https://checkout.razorpay.com/v1/checkout.js"></script>

<script>
(function () {
    "use strict";

    const contextPath = "<%= contextPath %>";
    const checkoutForm = document.getElementById("checkoutForm");
    const placeOrderBtn = document.getElementById("placeOrderBtn");

    checkoutForm.addEventListener("submit", async function (event) {
        const paymentMode = checkoutForm.querySelector(
            'input[name="paymentMode"]:checked'
        ).value;

        // COD uses the normal checkout form submission.
        if (paymentMode === "COD") {
            placeOrderBtn.disabled = true;
            placeOrderBtn.textContent = "Placing your order...";
            return;
        }

        // Online payment is handled using Razorpay.
        event.preventDefault();

        if (!checkoutForm.reportValidity()) {
            return;
        }

        if (typeof Razorpay === "undefined") {
            alert("Razorpay could not be loaded. Please check your internet connection.");
            return;
        }

        placeOrderBtn.disabled = true;
        placeOrderBtn.textContent = "Preparing secure payment...";

        try {
            /*
             * The payment amount is stored in the session by the JSP.
             * The server must calculate/validate the final amount itself
             * before creating a Razorpay order.
             */
            const orderResponse = await fetch(
                contextPath + "/create-razorpay-order",
                {
                    method: "POST",
                    credentials: "same-origin",
                    headers: {
                        "Content-Type": "application/json"
                    },
                    body: JSON.stringify({})
                }
            );

            if (!orderResponse.ok) {
                throw new Error("Unable to create the Razorpay order.");
            }

            const orderData = await orderResponse.json();

            if (!orderData.orderId || !orderData.keyId || !orderData.amount) {
                throw new Error("The server returned incomplete payment details.");
            }

            const options = {
                key: orderData.keyId,
                amount: orderData.amount,
                currency: orderData.currency || "INR",
                name: "Culinova",
                description: "Food order payment",
                order_id: orderData.orderId,

                prefill: {
                    name: document.getElementById("fullName").value,
                    email: document.getElementById("email").value,
                    contact: document.getElementById("phone").value
                },

                theme: {
                    color: "#B85F3B"
                },

                handler: async function (paymentResponse) {
                    try {
                        placeOrderBtn.textContent = "Verifying payment...";

                        const verifyData = new URLSearchParams();

                        verifyData.append(
                            "razorpay_payment_id",
                            paymentResponse.razorpay_payment_id
                        );

                        verifyData.append(
                            "razorpay_order_id",
                            paymentResponse.razorpay_order_id
                        );

                        verifyData.append(
                            "razorpay_signature",
                            paymentResponse.razorpay_signature
                        );

                        // Include delivery and payment details for the server.
                        const fields = [
                            "fullName",
                            "email",
                            "phone",
                            "address",
                            "landmark",
                            "pincode",
                            "city",
                            "state",
                            "instructions"
                        ];

                        fields.forEach(function (fieldName) {
                            verifyData.append(
                                fieldName,
                                document.getElementById(fieldName).value
                            );
                        });

                        verifyData.append("paymentMode", "ONLINE");

                        const verifyResponse = await fetch(
                            contextPath + "/verify-razorpay-payment",
                            {
                                method: "POST",
                                credentials: "same-origin",
                                headers: {
                                    "Content-Type":
                                        "application/x-www-form-urlencoded;charset=UTF-8"
                                },
                                body: verifyData.toString()
                            }
                        );

                        const result = await verifyResponse.json();

                        if (!verifyResponse.ok || result.success !== true) {
                            throw new Error(
                                result.message || "Payment verification failed."
                            );
                        }

                        window.location.href = contextPath + "/order-success.jsp";
                    } catch (verificationError) {
                        console.error(verificationError);

                        placeOrderBtn.disabled = false;
                        placeOrderBtn.textContent = "Retry payment verification";

                        alert(
                            "Payment verification could not be completed. " +
                            "Please contact support before attempting another payment."
                        );
                    }
                },

                modal: {
                    ondismiss: function () {
                        placeOrderBtn.disabled = false;
                        placeOrderBtn.textContent =
                            "Place Order · ₹<%= String.format(Locale.US, "%.2f", total) %>";
                    }
                }
            };

            const razorpay = new Razorpay(options);

            razorpay.on("payment.failed", function (response) {
                console.error(response.error);

                placeOrderBtn.disabled = false;
                placeOrderBtn.textContent =
                    "Place Order · ₹<%= String.format(Locale.US, "%.2f", total) %>";

                alert(
                    response.error && response.error.description
                        ? response.error.description
                        : "Payment failed. Please try again."
                );
            });

            razorpay.open();

        } catch (paymentError) {
            console.error(paymentError);

            placeOrderBtn.disabled = false;
            placeOrderBtn.textContent =
                "Place Order · ₹<%= String.format(Locale.US, "%.2f", total) %>";

            alert(paymentError.message || "Unable to start online payment.");
        }
    });
})();
</script>


<script>
(function () {
    "use strict";

    const contextPath = "<%= contextPath %>";
    const checkoutForm = document.getElementById("checkoutForm");
    const placeOrderBtn = document.getElementById("placeOrderBtn");
    const originalButtonText =
        "Place Order · ₹<%= String.format(Locale.US, "%.2f", total) %>";

    checkoutForm.addEventListener("submit", async function (event) {
        const selectedPayment = checkoutForm.querySelector(
            'input[name="paymentMode"]:checked'
        );

        if (!selectedPayment) {
            event.preventDefault();
            alert("Please select a payment method.");
            return;
        }

        // Cash on Delivery uses the normal servlet form submission.
        if (selectedPayment.value === "COD") {
            placeOrderBtn.disabled = true;
            placeOrderBtn.textContent = "Placing your order...";
            return;
        }

        // Online payment uses Razorpay.
        event.preventDefault();

        if (!checkoutForm.reportValidity()) {
            return;
        }

        if (typeof Razorpay === "undefined") {
            alert("Razorpay could not be loaded. Please check your internet connection.");
            return;
        }

        placeOrderBtn.disabled = true;
        placeOrderBtn.textContent = "Saving delivery details...";

        try {
            /*
             * STEP 1:
             * Submit the checkout form to the controller.
             * This stores delivery details and the calculated amount in session.
             */
            const formData = new FormData(checkoutForm);

            const checkoutResponse = await fetch(
                contextPath + "/checkout",
                {
                    method: "POST",
                    credentials: "same-origin",
                    headers: {
                        "X-Requested-With": "XMLHttpRequest"
                    },
                    body: formData
                }
            );

            const checkoutResult = await checkoutResponse.json();

            if (!checkoutResponse.ok || checkoutResult.success !== true) {
                throw new Error(
                    checkoutResult.error || "Unable to save checkout details."
                );
            }

            /*
             * STEP 2:
             * Ask the server to create a Razorpay order.
             */
            placeOrderBtn.textContent = "Preparing secure payment...";

            const orderResponse = await fetch(
                contextPath + "/create-razorpay-order",
                {
                    method: "POST",
                    credentials: "same-origin",
                    headers: {
                        "Content-Type": "application/json"
                    },
                    body: JSON.stringify({})
                }
            );

            const orderData = await orderResponse.json();

            if (
                !orderResponse.ok ||
                !orderData.orderId ||
                !orderData.keyId ||
                !orderData.amount
            ) {
                throw new Error(
                    orderData.message || "Unable to create the Razorpay order."
                );
            }

            /*
             * STEP 3:
             * Open Razorpay Checkout.
             */
            const options = {
                key: orderData.keyId,
                amount: orderData.amount,
                currency: orderData.currency || "INR",
                name: "Culinova",
                description: "Food order payment",
                order_id: orderData.orderId,

                prefill: {
                    name: document.getElementById("fullName").value,
                    email: document.getElementById("email").value,
                    contact: document.getElementById("phone").value
                },

                theme: {
                    color: "#B85F3B"
                },

                /*
                 * STEP 4:
                 * Verify the payment on the server.
                 */
                handler: async function (paymentResponse) {
                    placeOrderBtn.textContent = "Verifying payment...";

                    try {
                        const verifyData = new URLSearchParams();

                        verifyData.append(
                            "razorpay_payment_id",
                            paymentResponse.razorpay_payment_id
                        );

                        verifyData.append(
                            "razorpay_order_id",
                            paymentResponse.razorpay_order_id
                        );

                        verifyData.append(
                            "razorpay_signature",
                            paymentResponse.razorpay_signature
                        );

                        const verifyResponse = await fetch(
                            contextPath + "/verify-razorpay-payment",
                            {
                                method: "POST",
                                credentials: "same-origin",
                                headers: {
                                    "Content-Type":
                                        "application/x-www-form-urlencoded;charset=UTF-8",
                                    "X-Requested-With": "XMLHttpRequest"
                                },
                                body: verifyData.toString()
                            }
                        );

                        const result = await verifyResponse.json();

                        if (
                            !verifyResponse.ok ||
                            result.success !== true
                        ) {
                            throw new Error(
                                result.message ||
                                result.error ||
                                "Payment verification failed."
                            );
                        }

                        /*
                         * STEP 5:
                         * The server must have verified the payment
                         * AND saved the order before returning success.
                         */
                        window.location.replace(
                            contextPath + "/order-success.jsp"
                        );

                    } catch (error) {
                        console.error("Payment verification error:", error);

                        placeOrderBtn.disabled = false;
                        placeOrderBtn.textContent = originalButtonText;

                        alert(
                            error.message ||
                            "Payment verification failed. Please check your order status before trying again."
                        );
                    }
                },

                modal: {
                    ondismiss: function () {
                        placeOrderBtn.disabled = false;
                        placeOrderBtn.textContent = originalButtonText;
                    }
                }
            };

            const razorpay = new Razorpay(options);

            razorpay.on("payment.failed", function (paymentError) {
                console.error(paymentError.error);

                placeOrderBtn.disabled = false;
                placeOrderBtn.textContent = originalButtonText;

                alert(
                    paymentError.error &&
                    paymentError.error.description
                        ? paymentError.error.description
                        : "Payment failed. Please try again."
                );
            });

            razorpay.open();

        } catch (error) {
            console.error("Checkout/payment error:", error);

            placeOrderBtn.disabled = false;
            placeOrderBtn.textContent = originalButtonText;

            alert(error.message || "Unable to start online payment.");
        }
    });
})();
</script>


</body>
</html>
