document.addEventListener("DOMContentLoaded", async function() {
    const params = new URLSearchParams(window.location.search);
    const hotelId = params.get("id");
    
    if (!hotelId) {
        document.getElementById("hotel-details-container").innerHTML = "<p>Hotel not found.</p>";
        return;
    }

    try {
        const response = await fetch(`/wp-json/hotel-api/v1/hotels/${hotelId}`);
        const data = await response.json();
        
        document.getElementById("hotel-name").textContent = data.hotel.hotel_name;
        document.getElementById("hotel-address").textContent = data.hotel.hotel_address;

        const roomsContainer = document.getElementById("rooms-container");
        data.rooms.forEach(room => {
            const div = document.createElement("div");
            div.className = "room-box";
            div.innerHTML = `
                <p>Room: ${room.room_id} - Price: ${room.price_id} - Services: ${room.service_id}</p>
                <button onclick="viewRoom(${room.room_id})">View Details</button>
            `;
            roomsContainer.appendChild(div);
        });
    } catch (error) {
        console.error("Error fetching hotel details:", error);
    }
});

function viewRoom(roomId) {
    window.location.href = `/room-detail/?id=${roomId}`;
}