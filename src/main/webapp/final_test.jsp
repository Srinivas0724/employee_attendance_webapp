
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>FINAL TEST SYSTEM</title>
    <style>
        body { font-family: sans-serif; padding: 30px; background-color: #f0f2f5; text-align: center; }
        .box { background: white; padding: 20px; border-radius: 10px; box-shadow: 0 4px 8px rgba(0,0,0,0.1); max-width: 600px; margin: 0 auto 20px auto; }
        button { padding: 10px 20px; font-size: 16px; cursor: pointer; background: #28a745; color: white; border: none; border-radius: 5px; }
        button.refresh { background: #007bff; }
        table { width: 100%; margin-top: 15px; border-collapse: collapse; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #343a40; color: white; }
    </style>
    
    <script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-firestore-compat.js"></script>
</head>
<body>

    <div class="box">
        <h2>🚀 Connection Test</h2>
        <p>Click below to write a test record directly to the database.</p>
        <button onclick="addTestRecord()">➕ Write 'Test Record' to DB</button>
        <p id="statusMsg" style="color:gray; font-size:14px; margin-top:10px;">Waiting...</p>
    </div>

    <div class="box">
        <h2>📅 Live History Data</h2>
        <button class="refresh" onclick="loadData()">🔄 Refresh Table</button>
        
        <table id="myTable">
            <thead>
                <tr>
                    <th>Project</th>
                    <th>Type</th>
                    <th>Time</th>
                </tr>
            </thead>
            <tbody id="tableBody">
                <tr><td colspan="3">Click Refresh to load...</td></tr>
            </tbody>
        </table>
    </div>

    <script>
        // --- CONFIG (Do not change) ---
        const firebaseConfig = {
            apiKey: "AIzaSyCV5tKJMLOVcXiZUyuJZhLWOOSD96gsmP0",
            projectId: "attendencewebapp-4215b",
            storageBucket: "attendencewebapp-4215b.firebasestorage.app",
            messagingSenderId: "97124588288",
            appId: "1:97124588288:web:08507eaacdc6155ad1b1e5"
        };
        firebase.initializeApp(firebaseConfig);
        const db = firebase.firestore();
        const COLLECTION_NAME = "attendance_2025"; // The new database room

        // 1. Function to Write Data (Bypasses Java Backend)
        function addTestRecord() {
            document.getElementById("statusMsg").innerText = "Writing to database...";
            
            db.collection(COLLECTION_NAME).add({
                project: "Final Test Project",
                type: "TEST-IN",
                timestamp: firebase.firestore.FieldValue.serverTimestamp(),
                userId: "test_user",
                location: { lat: 0, lng: 0 }
            }).then(() => {
                document.getElementById("statusMsg").innerText = "✅ Success! Saved. Now click Refresh.";
                document.getElementById("statusMsg").style.color = "green";
            }).catch(error => {
                document.getElementById("statusMsg").innerText = "❌ Error: " + error.message;
                document.getElementById("statusMsg").style.color = "red";
            });
        }

        // 2. Function to Read Data (Fixes "false" error)
        function loadData() {
            const tbody = document.getElementById("tableBody");
            tbody.innerHTML = "<tr><td colspan='3'>Loading...</td></tr>";

            db.collection(COLLECTION_NAME).orderBy("timestamp", "desc").get()
            .then(snap => {
                if (snap.empty) {
                    tbody.innerHTML = "<tr><td colspan='3' style='color:blue'>Database is connected but EMPTY. Click the Green Button above!</td></tr>";
                    return;
                }

                let htmlRows = "";
                snap.forEach(doc => {
                    let d = doc.data();
                    // Safe Check: If data is missing, show "Unknown" instead of crashing
                    let proj = d.project || "Unknown Project";
                    let type = d.type || "Unknown";
                    let time = d.timestamp ? new Date(d.timestamp.seconds * 1000).toLocaleTimeString() : "No Time";

                    htmlRows += `<tr>
                        <td>${proj}</td>
                        <td>${type}</td>
                        <td>${time}</td>
                    </tr>`;
                });

                tbody.innerHTML = htmlRows;
            })
            .catch(error => {
                console.error(error);
                if(error.message.includes("index")) {
                    tbody.innerHTML = "<tr><td colspan='3' style='color:red'><b>INDEX MISSING:</b> Open Console (F12) & Click the Link!</td></tr>";
                } else {
                    tbody.innerHTML = "<tr><td colspan='3' style='color:red'>Error: " + error.message + "</td></tr>";
                }
            });
        }
    </script>

</body>
</html>