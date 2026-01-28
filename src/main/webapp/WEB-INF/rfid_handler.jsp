<%@ page import="com.google.firebase.database.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="com.example.FirebaseService" %> 
<%
    // 1. Get UID from ESP8266 Request
    String scannedCardID = request.getParameter("uid");

    if (scannedCardID != null && !scannedCardID.isEmpty()) {
        
        // 2. Reference to Users in Firebase
        DatabaseReference ref = FirebaseDatabase.getInstance().getReference("users");
        
        // 3. Query: Find the user who owns this card
        ref.orderByChild("rfid_uid").equalTo(scannedCardID).addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot dataSnapshot) {
                if (dataSnapshot.exists()) {
                    // User Found! Loop to get the actual user object (should be only one)
                    for (DataSnapshot userSnapshot : dataSnapshot.getChildren()) {
                        String userId = userSnapshot.getKey();
                        String name = userSnapshot.child("name").getValue(String.class);
                        String currentStatus = userSnapshot.child("status").getValue(String.class); // "Present" or "Absent"
                        
                        // --- LOGIC: TOGGLE STATUS ---
                        DatabaseReference attendanceRef = FirebaseDatabase.getInstance().getReference("attendance");
                        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
                        SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");
                        String today = dateFormat.format(new Date());
                        String now = timeFormat.format(new Date());

                        Map<String, Object> updates = new HashMap<>();

                        if ("Present".equalsIgnoreCase(currentStatus)) {
                            // LOGIC: CLOCK OUT
                            updates.put("users/" + userId + "/status", "Absent");
                            updates.put("attendance/" + today + "/" + userId + "/out_time", now);
                            updates.put("attendance/" + today + "/" + userId + "/status", "Present"); // Confirm present for the day
                            System.out.println("RFID: Clocking OUT " + name);
                        } else {
                            // LOGIC: CLOCK IN
                            updates.put("users/" + userId + "/status", "Present");
                            updates.put("attendance/" + today + "/" + userId + "/in_time", now);
                            updates.put("attendance/" + today + "/" + userId + "/name", name);
                            updates.put("attendance/" + today + "/" + userId + "/status", "Present");
                            System.out.println("RFID: Clocking IN " + name);
                        }

                        // Execute Update
                        FirebaseDatabase.getInstance().getReference().updateChildren(updates, null);
                    }
                } else {
                    System.out.println("RFID Error: Card ID " + scannedCardID + " not registered.");
                }
            }

            @Override
            public void onCancelled(DatabaseError databaseError) {
                // Handle error
            }
        });
        
        out.println("processed"); // Response to ESP
    } else {
        out.println("no_uid");
    }
%>