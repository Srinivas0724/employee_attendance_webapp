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
<title>Admin Dashboard - emPower</title>

<script type="text/javascript">
    function lockHistory() {
        history.pushState(null, null, location.href);
        history.pushState(null, null, location.href);
        window.onpopstate = function () { history.go(1); };
    }
    lockHistory();
</script>

<style>
body { margin:0; font-family:"Segoe UI", sans-serif; background:#f4f6f9; display:flex; height:100vh; }

/* ADMIN SIDEBAR (Red/Dark Theme) */
.sidebar { width:260px; background:#212529; color:#fff; display:flex; flex-direction:column; }
.sidebar h2 { padding:20px; margin:0; background:#c0392b; text-align:center; font-size: 22px; }
.sidebar a { display:block; padding:15px 20px; color:#adb5bd; text-decoration:none; border-left: 3px solid transparent; }
.sidebar a:hover, .sidebar a.active { background:#343a40; color:#fff; border-left: 3px solid #e74c3c; }

.main { flex:1; display:flex; flex-direction:column; overflow-y: auto; }
.header { height:60px; background:#fff; display:flex; justify-content:space-between; align-items:center; padding:0 30px; border-bottom: 1px solid #dee2e6; }

/* DASHBOARD CARDS */
.cards-container { display: flex; gap: 20px; padding: 30px; }
.stat-card { flex: 1; background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); border-top: 4px solid #3498db; }
.stat-card h3 { margin: 0 0 10px 0; color: #7f8c8d; font-size: 14px; text-transform: uppercase; }
.stat-card .number { font-size: 32px; font-weight: bold; color: #2c3e50; }

/* ATTENDANCE TABLE */
.table-container { padding: 0 30px 30px 30px; }
.admin-table { width: 100%; border-collapse: collapse; background: white; box-shadow: 0 2px 5px rgba(0,0,0,0.05); border-radius: 8px; overflow: hidden; }
.admin-table th { background: #34495e; color: white; padding: 15px; text-align: left; font-size: 14px; }
.admin-table td { padding: 12px 15px; border-bottom: 1px solid #eee; color: #333; }
.admin-table tr:hover { background: #f8f9fa; }

/* BADGES */
.status-badge { padding: 5px 10px; border-radius: 12px; font-size: 12px; font-weight: bold; color: white; display: inline-block; }
.badge-in { background: #27ae60; }
.badge-out { background: #c0392b; }

/* [NEW] PHOTO BUTTON & MODAL STYLES */
.btn-view { background:#007bff; color:white; border:none; padding:5px 10px; border-radius:4px; cursor:pointer; font-size:12px; }
.btn-view:hover { background:#0056b3; }

.modal { display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.8); align-items: center; justify-content: center; }
.modal-content { background-color: #fefefe; padding: 15px; border-radius: 5px; max-width: 90%; max-height: 90%; text-align: center; position: relative; }
.modal img { max-width: 100%; max-height: 80vh; border-radius: 4px; border: 1px solid #ddd; margin-top:10px; }
.close-btn { position: absolute; top: -15px; right: -15px; background: red; color: white; border: none; border-radius: 50%; width: 30px; height: 30px; cursor: pointer; font-weight: bold; }

#loadingOverlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: white; z-index: 9999; display: flex; justify-content: center; align-items: center; font-size: 24px; color: #333; }
</style>

<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
</head>
<body>

<div id="loadingOverlay">⌛ Loading Admin Panel...</div>

<div id="mainApp" style="display:none; width: 100%; height: 100%;">
    
    <div class="sidebar">
      <h2>ADMIN PORTAL</h2>
      <a class="active">📊 Dashboard</a>
      <a href="manage_employees.jsp">👥 All Employees</a>
      <a href="admin_task_monitoring.jsp">📝 Task Monitoring</a>
      <a href="reports.jsp">📅 Attendance Reports</a>
      <a href="payroll.jsp">💰 Payroll Management</a>
      <a href="admin_expenses.jsp" class="active">💸 Expense Approvals</a>
      <a href="admin_settings.jsp">⚙️ Settings</a>
      <a href="#" onclick="logout()" style="margin-top:auto; background:#1a1d20;">🚪 Logout</a>
    </div>

    <div class="main">
      <div class="header">
        <h3 style="margin:0;">Dashboard Overview</h3>
        <div style="font-weight:bold;">Welcome, Admin</div>
      </div>

      <div class="cards-container">
        <div class="stat-card">
            <h3>Total Employees</h3>
            <div class="number" id="totalEmp">0</div>
        </div>
        <div class="stat-card" style="border-top-color: #27ae60;">
            <h3>Live Actions (Today)</h3>
            <div class="number" id="presentToday">0</div>
        </div>
        <div class="stat-card" style="border-top-color: #e67e22;">
            <h3>Pending Approvals</h3>
            <div class="number">0</div>
        </div>
      </div>

      <div class="table-container">
        <h3>🔴 Live Attendance Feed (Today)</h3>
        <table class="admin-table">
            <thead>
                <tr>
                    <th>Time</th>
                    <th>Employee Email</th>
                    <th>Action</th>
                    <th>Project</th>
                    <th>Location</th>
                    <th>Photo</th> </tr>
            </thead>
            <tbody id="tableBody">
                </tbody>
        </table>
      </div>
    </div>
</div>

<div id="photoModal" class="modal" onclick="closeModal()">
    <div class="modal-content" onclick="event.stopPropagation()">
        <button class="close-btn" onclick="closeModal()">X</button>
        <h4 style="margin:0; color:#333;">Attendance Verification</h4>
        <img id="modalImg" src="">
    </div>
</div>

<script>
const firebaseConfig = { apiKey: "AIzaSyCV5tKJMLOVcXiZUyuJZhLWOOSD96gsmP0", authDomain: "attendencewebapp-4215b.firebaseapp.com", projectId: "attendencewebapp-4215b" };
if (!firebase.apps.length) firebase.initializeApp(firebaseConfig);
const auth = firebase.auth();
const db = firebase.firestore();

// Store records here so modal can access them
let allRecords = [];

// 1. AUTH CHECK
auth.onAuthStateChanged(user => {
  if (user) {
      document.getElementById("loadingOverlay").style.display = "none";
      document.getElementById("mainApp").style.display = "flex";
      loadDashboardData();
  } else {
      window.location.replace("login.jsp");
  }
});

function loadDashboardData() {
    // A. Get Total Employees Count
    db.collection("users").get().then(snap => {
        document.getElementById("totalEmp").innerText = snap.size;
    });

    // B. Get Today's Attendance
    db.collection("attendance_2025")
      .orderBy("timestamp", "desc")
      .limit(20) // Show last 20 actions
      .onSnapshot(snapshot => {
          let actionCount = 0;
          let html = "";
          
          // Clear array before refilling
          allRecords = [];

          snapshot.forEach(doc => {
              const data = doc.data();
              actionCount++;
              
              // Store data for Modal
              allRecords.push(data);
              const index = allRecords.length - 1;
              
              // 1. SAFE DATA EXTRACTION
              let time = "N/A";
              if (data.timestamp) {
                  time = new Date(data.timestamp.seconds * 1000).toLocaleTimeString([], {hour:'2-digit', minute:'2-digit'});
              }
              
              const type = data.type || "UNKNOWN";
              const email = data.email || "Unknown";
              const project = data.project || "General";
              const badgeClass = (type === "IN") ? "badge-in" : "badge-out";

              // 2. SAFE MAP LINK
              let mapLink = "<span style='color:#ccc'>No Loc</span>";
              if(data.location && data.location.lat) {
                  mapLink = "<a href='https://www.google.com/maps/search/?api=1&query=" + data.location.lat + "," + data.location.lng + "' target='_blank' style='color:#3498db; text-decoration:none;'>View Map</a>";
              }

              // 3. [NEW] PHOTO BUTTON
              let photoBtn = "<span style='color:#ccc; font-size:12px'>No Photo</span>";
              if (data.photo && typeof data.photo === 'string' && data.photo.startsWith("data:image")) {
                  photoBtn = "<button class='btn-view' onclick='openPhoto(" + index + ")'>View</button>";
              }

              // 4. BUILD ROW (String Concatenation)
              html += "<tr>";
              html += "<td>" + time + "</td>";
              html += "<td>" + email + "</td>";
              html += "<td><span class='status-badge " + badgeClass + "'>" + type + "</span></td>";
              html += "<td>" + project + "</td>";
              html += "<td>" + mapLink + "</td>";
              html += "<td>" + photoBtn + "</td>"; // New Cell
              html += "</tr>";
          });
          
          document.getElementById("tableBody").innerHTML = html;
          document.getElementById("presentToday").innerText = actionCount; 
      });
}

// [NEW] MODAL FUNCTIONS
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

function logout(){
  auth.signOut().then(() => {
    window.location.replace("login.jsp");
  });
}
</script>

</body>
</html>