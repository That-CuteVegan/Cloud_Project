// Version: 1.0
// Author: That_CuteVegan

document.addEventListener("DOMContentLoaded", async function() {
    const container = document.getElementById("hotels-container");
    
    try {

        // Waits on a response from database and posts the informations at "/wp-json/hotel-api/v1/hotels"
        const response = await fetch("/wp-json/hotel-api/v1/hotels");
        const hotels = await response.json();
        
        // Foreach loop looking in to how many hotels we have and makes a crate element per hotel
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

    // In case of an error, error is shown directly on the console
    } catch (error) {
        console.error("Error fetching hotels:", error);
    }
});

function viewHotel(hotelId) {
    window.location.href = `/hotel-details/?id=${hotelId}`;
}
