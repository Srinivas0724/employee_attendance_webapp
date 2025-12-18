<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page isELIgnored="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Admin Dashboard</title>

<style>
body {
    display: flex;
    height: 100vh;
    margin: 0;
    font-family: 'Segoe UI', sans-serif;
    background: #f4f6f9;
}

/* ===== SIDEBAR ===== */
.sidebar {
    width: 260px;
    background: #212529;
    color: white;
    display: flex;
    flex-direction: column;
}
.brand {
    padding: 20px;
    font-size: 20px;
    font-weight: bold;
    background: #00000030;
}
.nav-links {
    list-style: none;
    padding: 0;
    margin: 0;
}
.nav-links li a {
    display: block;
    padding: 14px 20px;
    color: #adb5bd;
    text-decoration: none;
    border-left: 4px solid transparent;
}
.nav-links li a:hover,
.nav-links li a.active {
    background: #343a40;
    color: white;
    border-left-color: #0d6efd;
}

/* ===== MAIN ===== */
.main {
    flex: 1;
    display: flex;
    flex-direction: column;
}
.header {
    background: white;
    padding: 15px 30px;
    display: flex;
    justify-content: space-between;
    border-bottom: 1px solid #dee2e6;
}
.content {
    padding: 30px;
    overflow-y: auto;
}

/* ===== PANEL ===== */
.panel {
    background: white;
    border-radius: 8px;
    box-shadow: 0 2px 6px rgba(0,0,0,0.05);
}
.panel-header {
    padding: 20px;
    border-bottom: 1px solid #eee;
}

/* ===== TABLE ===== */
table {
    width: 100%;
    border-collapse: collapse;
}
th {
    background: #343a40;
    color: white;
    padding: 12px;
}
td {
    padding: 12px;
    border-bottom: 1px solid #eee;
}
.selfie-img {
    width: 50px;
    height: 50px;
    border-radius: 50%;
    object-fit: cover;
}
.map-link {
    color: #0d6efd;
    text-decoration: none;
    font-weight: bold;
}
</style>

<!-- Firebase SDKs -->
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
</head>

<body>

<!-- ===== SIDEBAR ===== -->
<div class="sidebar">
    <div class="brand">🛡️ Admin Panel</div>
    <ul class="nav-links">
        <li><a href="admin_dashboard.jsp" class="active">📊 Attendance Monitor</a></li>
        <li><a href="admin_tasks.jsp">📝 Task Assignment</a></li>
        <li><a href="admin_expenses.jsp">💸 Employee Expenses</a></li>
        <li><a href="company_accounts.jsp">🏦 Company Accounts</a></li>
        <li><a href="admin_settings.jsp">⚙️ Settings</a></li>
        <li><a href="logout.jsp">🚪 Logout</a></li>
    </ul>
</div>

<!-- ===== MAIN CONTENT ===== -->
<div class="main">

    <div class="header">
        <h3>Dashboard</h3>
        <div><b>Administrator</b></div>
    </div>

    <div class="content">
        <div class="panel">
            <div class="panel-header">
                <h4>Live Attendance Feed</h4>
            </div>

            <table>
                <thead>
                    <tr>
                        <th>Selfie</th>
                        <th>Employee</th>
                        <th>Status</th>
                        <th>Project</th>
                        <th>Time</th>
                        <th>Map</th>
                    </tr>
                </thead>
                <tbody id="adminTableBody"></tbody>
            </table>
        </div>
    </div>
</div>

<script>
/* ===== FIREBASE CONFIG ===== */
const firebaseConfig = {
    apiKey: "AIzaSyCV5tKJMLOVcXiZUyuJZhLWOOSD96gsmP0",
    authDomain: "attendencewebapp-4215b.firebaseapp.com",
    projectId: "attendencewebapp-4215b",
    storageBucket: "attendencewebapp-4215b.firebasestorage.app",
    messagingSenderId: "97124588288",
    appId: "1:97124588288:web:08507eaacdc6155ad1b1e5"
};

if (!firebase.apps.length) {
    firebase.initializeApp(firebaseConfig);
}
const db = firebase.firestore();

/* ===== LOAD ADMIN ATTENDANCE ===== */
document.addEventListener("DOMContentLoaded", loadAdminAttendance);

function loadAdminAttendance() {
    const tbody = document.getElementById("adminTableBody");
    tbody.innerHTML = "<tr><td colspan='6'>Loading...</td></tr>";

    // ✅ THIS COLLECTION MATCHES YOUR FIREBASE DATA
    db.collection("attendance_2025")
      .get()
      .then(snapshot => {
          tbody.innerHTML = "";

          if (snapshot.empty) {
              tbody.innerHTML =
                "<tr><td colspan='6'>No attendance records found</td></tr>";
              return;
          }

          snapshot.forEach(doc => {
              const d = doc.data();

              const img = d.photo
                ? `<img src="${d.photo}" class="selfie-img">`
                : `<div style="width:50px;height:50px;background:#eee;border-radius:50%;line-height:50px;text-align:center;">No IMG</div>`;

              const map = d.location
                ? `<a class="map-link" target="_blank"
                     href="https://www.google.com/maps?q=${d.location.lat},${d.location.lng}">
                     Map
                   </a>`
                : "N/A";

              const time = d.timestamp
                ? new Date(d.timestamp.seconds * 1000).toLocaleString()
                : "N/A";

              tbody.innerHTML += `
                <tr>
                    <td>${img}</td>
                    <td><b>${d.userName}</b><br>${d.userId}</td>
                    <td>${d.type}</td>
                    <td>${d.project || "General"}</td>
                    <td>${time}</td>
                    <td>${map}</td>
                </tr>
              `;
          });
      })
      .catch(err => {
          console.error(err);
          tbody.innerHTML =
            `<tr><td colspan="6" style="color:red;">${err.message}</td></tr>`;
      });
}
</script>

</body>
</html>
