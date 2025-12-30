<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  // 1. PASTE THE CACHE CODE HERE (Lines 2-6)
  response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
  response.setHeader("Pragma", "no-cache");
  response.setDateHeader("Expires", 0);
%>
<%@ page isELIgnored="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Admin - All Attendance</title>
    <style>
        /* --- ADMIN LAYOUT STYLES --- */
        body { display: flex; height: 100vh; margin: 0; font-family: 'Segoe UI', sans-serif; background: #f4f6f9; overflow: hidden; }
        .sidebar { width: 260px; background: #343a40; color: white; display: flex; flex-direction: column; }
        .brand { padding: 20px; font-size: 22px; font-weight: bold; background: #212529; text-align: center; }
        .nav-links { list-style: none; padding: 0; margin: 0; }
        .nav-links li a { display: block; padding: 15px 20px; color: #c2c7d0; text-decoration: none; border-left: 4px solid transparent; }
        .nav-links li a:hover, .nav-links li a.active { background: #495057; color: white; border-left-color: #007bff; }
        .main { flex: 1; display: flex; flex-direction: column; }
        .header { background: white; padding: 10px 30px; display: flex; justify-content: flex-end; align-items: center; height: 60px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
        .content { padding: 30px; overflow-y: auto; }
        .card { background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
        
        /* TABLE STYLES */
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th { background: #343a40; color: white; padding: 12px; text-align: left; }
        td { padding: 12px; border-bottom: 1px solid #ddd; color: #555; vertical-align: middle; }
        tr:hover { background-color: #f1f1f1; }
        
        .tag-in { background: #d4edda; color: #155724; padding: 4px 8px; border-radius: 4px; font-weight: bold; font-size: 12px; }
        .tag-out { background: #f8d7da; color: #721c24; padding: 4px 8px; border-radius: 4px; font-weight: bold; font-size: 12px; }
    </style>

    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
</head>

<body>

    <div class="sidebar">
        <div class="brand">emPower Admin</div>
        <ul class="nav-links">
            <li><a href="admin_tasks.jsp">📝 Task Manager</a></li>
            <li><a href="#" class="active">🕒 All Attendance</a></li>
            <li><a href="#" onclick="logout()">🚪 Logout</a></li>
        </ul>
    </div>

    <div class="main">
        <div class="header">
            <strong>Admin Console</strong>
        </div>

        <div class="content">
            <div class="card">
                <h2>All Employee Attendance</h2>
                <table>
                    <thead>
                        <tr>
                            <th>Employee (Email)</th>
                            <th>Project</th>
                            <th>Type</th>
                            <th>Date & Time</th>
                            <th>Location</th>
                        </tr>
                    </thead>
                    <tbody id="allAttendanceTable">
                        <tr><td colspan="5">Loading all records...</td></tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <script>
        /* --- FIREBASE CONFIG --- */
        const firebaseConfig = {
            apiKey: "AIzaSyCV5tKJMLOVcXiZUyuJZhLWOOSD96gsmP0",
            authDomain: "attendencewebapp-4215b.firebaseapp.com",
            projectId: "attendencewebapp-4215b",
            storageBucket: "attendencewebapp-4215b.firebasestorage.app",
            messagingSenderId: "97124588288",
            appId: "1:97124588288:web:08507eaacdc6155ad1b1e5"
        };
        if (!firebase.apps.length) firebase.initializeApp(firebaseConfig);
        const db = firebase.firestore();
        const auth = firebase.auth();

        /* --- AUTH CHECK --- */
        auth.onAuthStateChanged(user => {
            if(user) {
                // In a real app, verify admin status here
                loadAllAttendance();
            } else {
                window.location.href = "login.jsp";
            }
        });

        /* --- LOAD ALL DATA --- */
        function loadAllAttendance() {
            const tbody = document.getElementById("allAttendanceTable");

            // Query: Get ALL records from 'attendance_2025'
            // We order by timestamp descending to see newest first
            db.collection("attendance_2025")
                .orderBy("timestamp", "desc")
                .get()
                .then(snap => {
                    if (snap.empty) {
                        tbody.innerHTML = "<tr><td colspan='5'>No attendance records found in system.</td></tr>";
                        return;
                    }

                    let rows = "";
                    snap.forEach(doc => {
                        const d = doc.data();
                        
                        // Safety Checks
                        const email = d.userId || d.email || "Unknown User";
                        const project = d.project || "General";
                        const type = d.type || "N/A";
                        const tagClass = (type === "IN") ? "tag-in" : "tag-out";
                        
                        let timeStr = "N/A";
                        if (d.timestamp) {
                            timeStr = new Date(d.timestamp.seconds * 1000).toLocaleString();
                        }

                        let locStr = "No GPS";
                        if (d.location && d.location.lat) {
                            locStr = `Lat: ${d.location.lat.toFixed(4)}, Lng: ${d.location.lng.toFixed(4)}`;
                        }

                        rows += `
                            <tr>
                                <td><b>${email}</b></td>
                                <td>${project}</td>
                                <td><span class="${tagClass}">${type}</span></td>
                                <td>${timeStr}</td>
                                <td style="font-size:13px; color:#666;">${locStr}</td>
                            </tr>
                        `;
                    });
                    tbody.innerHTML = rows;
                })
                .catch(err => {
                    console.error("Error loading data:", err);
                    tbody.innerHTML = "<tr><td colspan='5' style='color:red'>Error: " + err.message + "</td></tr>";
                });
        }

        function logout() {
            auth.signOut().then(() => window.location.href = "login.jsp");
        }
    </script>
</body>
</html>