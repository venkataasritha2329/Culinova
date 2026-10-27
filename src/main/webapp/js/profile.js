
document.addEventListener("DOMContentLoaded", function () {
    const trigger = document.getElementById("profileTrigger");
    const menu = document.getElementById("profileMenu");

    if (!trigger || !menu) {
        console.error("Profile dropdown elements were not found.");
        return;
    }

    trigger.addEventListener("click", function (event) {
        event.preventDefault();
        event.stopPropagation();

        menu.classList.toggle("show");

        trigger.setAttribute(
            "aria-expanded",
            menu.classList.contains("show") ? "true" : "false"
        );
    });

    menu.addEventListener("click", function (event) {
        event.stopPropagation();
    });

    document.addEventListener("click", function () {
        menu.classList.remove("show");
        trigger.setAttribute("aria-expanded", "false");
    });

    document.addEventListener("keydown", function (event) {
        if (event.key === "Escape") {
            menu.classList.remove("show");
            trigger.setAttribute("aria-expanded", "false");
        }
    });
});
