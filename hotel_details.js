document.addEventListener("DOMContentLoaded", async function () {
    console.log("Hotel Details Script Loaded!");

    const urlparams = new URLSearchParams(window.location.search);
    const hotelId = urlparams.get("id");

    if (!hotelId) {
        console.error("No hotel ID found in URL.");
        return;
    }

    const container = document.getElementById("hotel-details-container");

    try {
        console.log("Fetching hotel details...");
        const response = await fetch(`/wp-json/hotel-api/v1/hotels/${hotelId}`);

        if (!response.ok) {
            throw new Error(`HTTP error! Status: ${response.status}`);
        }

        const data = await response.json();
        console.log("Hotel details received:", data);

        if (!data.hotel) {
            container.innerHTML = "<p>Hotel not found.</p>";
            return;
        }

        let html = `
            <h2>${data.hotel.hotel_name}</h2>
            <p>${data.hotel.hotel_address}</p>
            <h3>Rooms:</h3>
            <div class="rooms-container">
        `;

        data.rooms.forEach(room => {
            html += `
                <div class="room-box">
                    <h4>${room.room_name}</h4>
                    <p>${room.room_description}</p>
                    <h5>Prices:</h5>
                    <ul>
            `;

            room.prices.forEach(price => {
                html += `<li>${price.price_type}: ${price.price_amount} ${price.currency}</li>`;
            });

            html += `</ul><h5>Services:</h5><ul>`;

            room.services.forEach(service => {
                html += `<li>${service.service_name} - ${service.service_description}</li>`;
            });

            html += `</ul></div>`;
        });

        html += `</div>`;
        container.innerHTML = html;

    } catch (error) {
        console.error("Error fetching hotel details:", error);
        container.innerHTML = "<p>Error loading hotel details.</p>";
    }
});