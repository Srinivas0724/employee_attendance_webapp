<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page isELIgnored="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>My Attendance History</title>

    <style>
        /* --- LAYOUT & SIDEBAR CSS --- */
        body { display: flex; height: 100vh; margin: 0; font-family: 'Segoe UI', sans-serif; background: #f4f6f9; overflow: hidden; }
        
        /* Sidebar Styling */
        .sidebar { width: 260px; background: #343a40; color: white; display: flex; flex-direction: column; }
        .brand { padding: 20px; font-size: 22px; font-weight: bold; background: #212529; text-align: center; }
        .nav-links { list-style: none; padding: 0; margin: 0; }
        .nav-links li a { display: block; padding: 15px 20px; color: #c2c7d0; text-decoration: none; border-left: 4px solid transparent; }
        .nav-links li a:hover, .nav-links li a.active { background: #495057; color: white; border-left-color: #007bff; }
        
        /* Main Content Area */
        .main { flex: 1; display: flex; flex-direction: column; }
        .header { background: white; padding: 10px 30px; display: flex; justify-content: flex-end; align-items: center; height: 60px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
        .content { padding: 30px; overflow-y: auto; }
        
        /* Profile Avatar */
        .profile-btn { display: flex; align-items: center; gap: 10px; }
        .avatar { width: 35px; height: 35px; background: #007bff; color: white; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: bold; }

        /* Card & Table Styling */
        .card { background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
        h2 { color: #333; margin-top: 0; }
        
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th { background: #007bff; color: white; padding: 12px; text-align: left; }
        td { padding: 12px; border-bottom: 1px solid #ddd; color: #555; }
        tr:hover { background-color: #f1f1f1; }
        
        /* Tags */
        .tag-in { background: #d4edda; color: #155724; padding: 4px 8px; border-radius: 4px; font-weight: bold; font-size: 12px; }
        .tag-out { background: #f8d7da; color: #721c24; padding: 4px 8px; border-radius: 4px; font-weight: bold; font-size: 12px; }
    </style>

    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
</head>

<body>

    <div class="sidebar">
        <div class="brand">emPower</div>
        <ul class="nav-links">
            <li><a href="mark_attendance.jsp">📍 Mark Attendance</a></li>
            <li><a href="employee_tasks.jsp">📝 Assigned Tasks</a></li>
            <li><a href="#" class="active">🕒 Attendance History</a></li>
            <li><a href="employee_expenses.jsp">💸 My Expenses</a></li>
            <li><a href="salary.jsp">💰 My Salary</a></li>
            <li><a href="settings.jsp">⚙️ Settings</a></li>
            <li><a href="#" onclick="auth.signOut().then(() => window.location.href='login.jsp')">🚪 Logout</a></li>
        </ul>
    </div>

    <div class="main">
        <div class="header">
            <div class="profile-btn">
                <div style="text-align:right;">
                    <span style="display:block; font-weight:bold; font-size:14px;">Employee</span>
                </div>
                <div class="avatar">E</div>
            </div>
        </div>

        <div class="content">
            <div class="card">
                <h2>My Attendance History</h2>

                <table>
                    <thead>
                        <tr>
                            <th>Project</th>
                            <th>Type</th>
                            <th>Date & Time</th>
                            <th>Location (Lat, Lng)</th>
                        </tr>
                    </thead>
                    <tbody id="historyTable">
                        </tbody>
                </table>
            </div>
        </div>
    </div>

<script>
/* ✅ FIREBASE CONFIG */
const firebaseConfig = {
    apiKey: "AIzaSyCV5tKJMLOVcXiZUyuJZhLWOOSD96gsmP0",
    authDomain: "attendencewebapp-4215b.firebaseapp.com",
    projectId: "attendencewebapp-4215b",
    storageBucket: "attendencewebapp-4215b.firebasestorage.app",
    messagingSenderId: "97124588288",
    appId: "1:97124588288:web:08507eaacdc6155ad1b1e5"
};

/* ✅ Prevent double initialization */
if (!firebase.apps.length) {
    firebase.initializeApp(firebaseConfig);
}

const auth = firebase.auth();
const db = firebase.firestore();

document.addEventListener("DOMContentLoaded", () => {

    const table = document.getElementById("historyTable");
    table.innerHTML = "<tr><td colspan='4'>Loading...</td></tr>";

    auth.onAuthStateChanged(user => {
        if (!user) {
            table.innerHTML = "<tr><td colspan='4'>Not logged in</td></tr>";
            window.location.href = "login.jsp"; // Added redirect for safety
            return;
        }

        const email = user.email;
        table.innerHTML = "";

        /* 🔥 FIRESTORE QUERY */
        db.collection("attendance_2025")
          .where("userId", "==", email)
          .get()   // ❗ no orderBy → avoids index error
          .then(snapshot => {

              if (snapshot.empty) {
                  table.innerHTML =
                      "<tr><td colspan='4'>No records found</td></tr>";
                  return;
              }

              snapshot.forEach(doc => {
                  const d = doc.data();

                  const time = d.timestamp
                      ? new Date(d.timestamp.seconds * 1000).toLocaleString()
                      : "N/A";

                  const location = d.location
                      ? d.location.lat.toFixed(4) + ", " + d.location.lng.toFixed(4)
                      : "N/A";

                  const tagClass = (d.type === "IN") ? "tag-in" : "tag-out";

                  table.innerHTML += `
                      <tr>
                          <td><b>${d.project || "-"}</b></td>
                          <td><span class="${tagClass}">${d.type}</span></td>
                          <td>${time}</td>
                          <td>${location}</td>
                      </tr>
                  `;
              });
          })
          .catch(err => {
              console.error("Firestore error:", err);
              table.innerHTML =
                  "<tr><td colspan='4' style='color:red;'>"
                  + err.message +
                  "</td></tr>";
          });
    });
});
</script>

</body>
</html>