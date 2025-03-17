<!--
 * Version: 1.0
 * Author: That_CuteVegan
 -->

document.addEventListener("DOMContentLoaded", async function() {
    const container = document.getElementById("hotels-container");
    
    try {
        const response = await fetch("/wp-json/hotel-api/v1/hotels");
        const hotels = await response.json();
        
        hotels.forEach(hotel => {
            const div = document.createElement("div");
            div.className = "hotel-box";
            div.innerHTML = `
                <h2>${hotel.hotel_name}</h2>
                <p>${hotel.hotel_address}</p>
                <button onclick="viewHotel(${hotel.hotel_id})">View Details</button>
            `;
            container.appendChild(div);
        });
    } catch (error) {
        console.error("Error fetching hotels:", error);
    }
});

function viewHotel(hotelId) {
    window.location.href = `/hotel-details/?id=${hotelId}`;
}
