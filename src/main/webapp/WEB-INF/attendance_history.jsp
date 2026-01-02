<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
  response.setHeader("Pragma", "no-cache");
  response.setDateHeader("Expires", 0);
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Attendance History</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<style>
/* GLOBAL STYLES */
body { margin:0; font-family:"Segoe UI", sans-serif; background:#f4f6f9; display:flex; height:100vh; color: #333; }

/* SIDEBAR */
.sidebar { width:260px; background:#343a40; color:#fff; display:flex; flex-direction:column; }
.sidebar h2 { padding:20px; margin:0; background:#212529; text-align:center; }
.sidebar a { display:block; padding:15px 20px; color:#c2c7d0; text-decoration:none; }
.sidebar a:hover, .sidebar a.active { background:#495057; color:#fff; border-left: 3px solid #007bff; }
@media (max-width: 768px) { .sidebar { display:none; } }

/* LAYOUT */
.main { flex:1; display:flex; flex-direction:column; overflow: hidden; }
.header { height:60px; background:#fff; display:flex; align-items:center; padding:0 20px; border-bottom: 1px solid #dee2e6; justify-content: space-between; }
.content { flex:1; padding:20px; overflow-y:auto; }

/* TABLE */
table { width:100%; border-collapse:collapse; background:#fff; border-radius:8px; overflow:hidden; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
th, td { padding:15px; text-align:left; border-bottom:1px solid #dee2e6; color: #333 !important; } 
th { background:#343a40; color:#fff !important; font-weight:600; }

/* BADGES */
.badge { padding:5px 10px; border-radius:15px; font-size:12px; color:#fff !important; font-weight:bold; }
.in { background:#28a745; }
.out { background:#dc3545; }

/* BUTTONS */
.btn-view { background:#007bff; color:white !important; border:none; padding:6px 12px; border-radius:4px; cursor:pointer; font-size:13px; }
.btn-map { color:#007bff !important; text-decoration:none; font-weight:600; cursor: pointer; }

/* PHOTO POPUP */
.modal { display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.8); align-items: center; justify-content: center; }
.modal-content { background-color: #fefefe; padding: 10px; border-radius: 5px; max-width: 90%; max-height: 90%; text-align: center; position: relative; }
.modal img { max-width: 100%; max-height: 80vh; border-radius: 4px; border: 1px solid #ddd; }
.close-btn { position: absolute; top: -15px; right: -15px; background: red; color: white !important; border: none; border-radius: 50%; width: 30px; height: 30px; cursor: pointer; font-weight: bold; }

#loading { text-align:center; padding:20px; color:#666; }
</style>

<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
</head>

<body>

<div class="sidebar">
  <h2>emPower</h2>
  <a href="mark_attendance.jsp">📍 Mark Attendance</a>
  <a href="employee_tasks.jsp">📝 Assigned Tasks</a>
  <a href="attendance_history.jsp" class="active">🕒 Attendance History</a>
  <a href="employee_expenses.jsp">💸 My Expenses</a>
  <a href="salary.jsp">💰 My Salary</a>
  <a href="settings.jsp">⚙️ Settings</a>
  <a href="#" onclick="logout()">🚪 Logout</a>
</div>

<div class="main">
    <div class="header">
        <h3>My History</h3>
        <span id="userEmail">Loading...</span>
    </div>

    <div class="content">
        <div id="loading">⌛ Loading records...</div>
        <table id="historyTable" style="display:none;">
            <thead>
                <tr>
                    <th>Date & Time</th>
                    <th>Type</th>
                    <th>Project</th>
                    <th>Location</th>
                    <th>Photo</th>
                </tr>
            </thead>
            <tbody id="tableBody"></tbody>
        </table>
    </div>
</div>

<div id="photoModal" class="modal" onclick="closeModal()">
    <div class="modal-content" onclick="event.stopPropagation()">
        <button class="close-btn" onclick="closeModal()">X</button>
        <h4 style="margin:5px 0 10px;">Attendance Photo</h4>
        <img id="modalImg" src="">
    </div>
</div>

<script>
// --- ⚠️ PASTE YOUR NEW API KEY BELOW ⚠️ ---
const firebaseConfig = {
  apiKey: "AIzaSyBzdM77WwTSkxvF0lsxf2WLNLhjuGyNvQQ",
  authDomain: "attendancewebapp-ef02a.firebaseapp.com",
  projectId: "attendancewebapp-ef02a",
  storageBucket: "attendancewebapp-ef02a.firebasestorage.app",
  messagingSenderId: "734213881030",
  appId: "1:734213881030:web:bfdcee5a2ff293f87e6bc7"
};

if (!firebase.apps.length) firebase.initializeApp(firebaseConfig);
const auth = firebase.auth();
const db = firebase.firestore();

let allRecords = []; 

auth.onAuthStateChanged(user => {
    if (user) {
        document.getElementById("userEmail").innerText = user.email;
        loadHistory(user.email);
    } else {
        window.location.replace("login.jsp");
    }
});

function loadHistory(email) {
    db.collection("attendance_2025")
      .where("email", "==", email)
      .orderBy("timestamp", "desc")
      .get()
      .then(snapshot => {
          document.getElementById("loading").style.display = "none";
          const tbody = document.getElementById("tableBody");
          const table = document.getElementById("historyTable");
          
          if (snapshot.empty) {
              document.getElementById("loading").innerText = "No records found.";
              document.getElementById("loading").style.display = "block";
              return;
          }
          
          table.style.display = "table";
          allRecords = []; 
          let rowsHtml = "";

          snapshot.forEach((doc) => {
              const data = doc.data();
              allRecords.push(data);
              const index = allRecords.length - 1;

              // 1. DATE FORMATTING
              let dateStr = "No Date";
              if(data.timestamp && data.timestamp.seconds) {
                  dateStr = new Date(data.timestamp.seconds * 1000).toLocaleString();
              }

              // 2. LOCATION (Fixed Google Maps Link)
              let mapLink = "<span style='color:#999'>No Loc</span>";
              if (data.location && data.location.lat && data.location.lng) {
                  mapLink = "<a class='btn-map' href='https://www.google.com/maps/search/?api=1&query=" + data.location.lat + "," + data.location.lng + "' target='_blank'>View Map</a>";
              }

              // 3. PHOTO BUTTON (Supports both Storage URL and Base64)
              let photoBtn = "<span style='color:#ccc'>No Photo</span>";
              if (data.photo) {
                  if(data.photo.startsWith("http") || data.photo.startsWith("data:image")) {
                      photoBtn = "<button class='btn-view' onclick='openPhoto(" + index + ")'>View</button>";
                  }
              }

              // 4. BADGE & PROJECT
              let type = data.type || "UNKNOWN";
              let badgeClass = (type === 'IN') ? 'in' : 'out';
              let project = data.project || "General";

              // BUILD ROW
              rowsHtml += "<tr>";
              rowsHtml += "<td>" + dateStr + "</td>";
              rowsHtml += "<td><span class='badge " + badgeClass + "'>" + type + "</span></td>";
              rowsHtml += "<td>" + project + "</td>";
              rowsHtml += "<td>" + mapLink + "</td>";
              rowsHtml += "<td>" + photoBtn + "</td>";
              rowsHtml += "</tr>";
          });
          
          tbody.innerHTML = rowsHtml;
      })
      .catch(error => {
          console.error("Error:", error);
          if(error.message.includes("requires an index")) {
              alert("⚠️ Missing Database Index.\nCheck the console (F12) for the creation link.");
          }
          document.getElementById("loading").innerText = "Error loading data.";
          document.getElementById("loading").style.display = "block";
      });
}

function openPhoto(index) {
    const data = allRecords[index];
    const modal = document.getElementById("photoModal");
    const img = document.getElementById("modalImg");
    if(data && data.photo) {
        img.src = data.photo;
        modal.style.display = "flex";
    }
}

function closeModal() {
    document.getElementById("photoModal").style.display = "none";
}

function logout(){ auth.signOut().then(() => location.href = "login.jsp"); }
</script>

</body>
</html>