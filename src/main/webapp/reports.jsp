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
<title>Monthly Attendance Report - emPower</title>

<style>
/* GLOBAL STYLES */
body { margin:0; font-family:"Segoe UI", sans-serif; background:#f4f6f9; display:flex; height:100vh; color:#333; }

/* SIDEBAR */
.sidebar { width:260px; background:#212529; color:#fff; display:flex; flex-direction:column; }
.sidebar h2 { padding:20px; margin:0; background:#c0392b; text-align:center; font-size: 22px; }
.sidebar a { display:block; padding:15px 20px; color:#adb5bd; text-decoration:none; border-left: 3px solid transparent; }
.sidebar a:hover, .sidebar a.active { background:#343a40; color:#fff; border-left: 3px solid #e74c3c; }

/* MAIN CONTENT */
.main { flex:1; display:flex; flex-direction:column; overflow: hidden; }
.header { height:60px; background:#fff; display:flex; justify-content:space-between; align-items:center; padding:0 30px; border-bottom: 1px solid #dee2e6; }
.content { padding: 20px; flex:1; overflow: auto; display:flex; flex-direction:column; }

/* CONTROLS */
.controls { background:white; padding:15px; border-radius:8px; display:flex; gap:15px; align-items:center; box-shadow: 0 2px 5px rgba(0,0,0,0.05); margin-bottom: 20px; }
select, input { padding:8px; border:1px solid #ccc; border-radius:4px; }
button { padding: 8px 15px; background: #2980b9; color: white; border: none; border-radius: 4px; cursor: pointer; }
.btn-export { background: #27ae60; margin-left: auto; }

/* THE SHEET */
.sheet-container { overflow: auto; background: white; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); flex:1; position: relative; }
table { border-collapse: collapse; width: 100%; min-width: 1500px; }
th, td { border: 1px solid #ddd; padding: 6px; text-align: center; font-size: 12px; white-space: nowrap; vertical-align: middle; }

/* Sticky Headers */
th { background: #34495e; color: white; position: sticky; top: 0; z-index: 10; height: 40px; }
td:first-child, th:first-child { position: sticky; left: 0; background: #f8f9fa; z-index: 11; border-right: 2px solid #ddd; font-weight: bold; text-align: left; width: 150px; }
th:first-child { z-index: 12; background: #34495e; }

/* STATUS COLORS */
.P { background-color: #d4edda; color: #155724; } /* Present */
.A { background-color: #f8d7da; color: #721c24; } /* Absent */
.L { background-color: #fff3cd; color: #856404; } /* Late */
.H { background-color: #e2e3e5; color: #aaa; }    /* Holiday/Future */

/* Cell Content Formatting */
.time-box { font-size: 11px; line-height: 1.4; }
.lbl { color: #666; font-size: 9px; text-transform: uppercase; }

#loadingOverlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: white; z-index: 9999; display: flex; justify-content: center; align-items: center; font-size: 24px; color: #333; }
</style>

<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.17.0/xlsx.full.min.js"></script>
</head>
<body>

<div id="loadingOverlay">⌛ Generating Report...</div>

<div class="sidebar">
  <h2>ADMIN PORTAL</h2>
  <a href="admin_dashboard.jsp">📊 Dashboard</a>
  <a href="manage_employees.jsp">👥 Manage Employees</a>
  <a href="admin_task_monitoring.jsp">📝 Task Monitoring</a>
  <a href="reports.jsp" class="active">📅 Attendance Reports</a>
  <a href="payroll.jsp">💰 Payroll Management</a>
  <a href="admin_expenses.jsp" class="active">💸 Expense Approvals</a>
  <a href="admin_settings.jsp">⚙️ Settings</a>
  <a href="#" onclick="logout()" style="margin-top:auto; background:#1a1d20;">🚪 Logout</a>
</div>

<div class="main">
    <div class="header">
        <h3>Monthly Attendance Sheet</h3>
        <span id="adminEmail">Loading...</span>
    </div>

    <div class="content">
        <div class="controls">
            <label>Month:</label>
            <select id="monthSelect"></select>
            <label>Year:</label>
            <select id="yearSelect">
                <option value="2024">2024</option>
                <option value="2025" selected>2025</option>
                <option value="2026">2026</option>
            </select>
            <button onclick="generateReport()">🔄 Refresh Data</button>
            <button class="btn-export" onclick="exportToExcel()">📥 Download Excel</button>
        </div>

        <div class="sheet-container">
            <table id="attendanceTable">
                <thead><tr id="tableHeader"><th>Employee Name</th></tr></thead>
                <tbody id="tableBody"></tbody>
            </table>
        </div>
    </div>
</div>

<script>
const firebaseConfig = { apiKey: "AIzaSyCV5tKJMLOVcXiZUyuJZhLWOOSD96gsmP0", authDomain: "attendencewebapp-4215b.firebaseapp.com", projectId: "attendencewebapp-4215b" };
if (!firebase.apps.length) firebase.initializeApp(firebaseConfig);
const auth = firebase.auth();
const db = firebase.firestore();

let allUsers = [];
let attendanceData = [];
const daysMap = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

// Setup Month Dropdown
const monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
const monthSelect = document.getElementById("monthSelect");
monthNames.forEach((m, i) => {
    let opt = document.createElement("option");
    opt.value = i; opt.text = m;
    if(i === new Date().getMonth()) opt.selected = true;
    monthSelect.add(opt);
});

auth.onAuthStateChanged(user => {
    if(user) {
        document.getElementById("adminEmail").innerText = user.email;
        fetchUsersAndReport();
    } else {
        window.location.replace("login.jsp");
    }
});

async function fetchUsersAndReport() {
    document.getElementById("loadingOverlay").style.display = "flex";
    try {
        const userSnap = await db.collection("users").get();
        allUsers = [];
        userSnap.forEach(doc => {
            const d = doc.data();
            if(d.role !== 'admin') {
                allUsers.push({
                    email: d.email || "",
                    name: d.fullName || d.email || "Unknown",
                    shifts: d.shiftTimings || {} 
                });
            }
        });
        allUsers.sort((a, b) => (a.name || "").localeCompare(b.name || ""));
        generateReport();
    } catch(e) {
        alert("Error: " + e.message);
        document.getElementById("loadingOverlay").style.display = "none";
    }
}

function generateReport() {
    const month = parseInt(document.getElementById("monthSelect").value);
    const year = parseInt(document.getElementById("yearSelect").value);
    const start = new Date(year, month, 1);
    const end = new Date(year, month + 1, 0, 23, 59, 59);

    document.getElementById("loadingOverlay").style.display = "flex";

    db.collection("attendance_2025")
        .where("timestamp", ">=", start)
        .where("timestamp", "<=", end)
        .get()
        .then(snap => {
            attendanceData = [];
            snap.forEach(doc => attendanceData.push(doc.data()));
            renderTable(month, year);
            document.getElementById("loadingOverlay").style.display = "none";
        });
}

function renderTable(month, year) {
    const daysInMonth = new Date(year, month + 1, 0).getDate();
    const tableHeader = document.getElementById("tableHeader");
    const tableBody = document.getElementById("tableBody");
    const today = new Date();
    
    // Header
    let headerHTML = "<th>Employee Name</th>";
    for(let i=1; i<=daysInMonth; i++) headerHTML += "<th>" + i + "</th>";
    tableHeader.innerHTML = headerHTML;

    // Body
    let bodyHTML = "";

    allUsers.forEach(user => {
        bodyHTML += "<tr><td>" + user.name + "</td>";

        for(let d=1; d<=daysInMonth; d++) {
            const colDate = new Date(year, month, d);
            colDate.setHours(23, 59, 59); // End of that day
            
            // Check if Future Date
            if(colDate > today && colDate.toDateString() !== today.toDateString()) {
                bodyHTML += "<td class='H'>-</td>";
                continue;
            }

            const dayName = daysMap[colDate.getDay()]; 
            let requiredTime = user.shifts[dayName] || "09:30";

            // Find Records for this User & Day
            // We use .filter() now to get ALL records (IN and OUT)
            const dailyRecs = attendanceData.filter(a => {
                if(!a.timestamp) return false;
                const recDate = new Date(a.timestamp.seconds * 1000);
                return a.email === user.email && recDate.getDate() === d;
            });

            // If Holiday
            if (requiredTime === "OFF") {
                bodyHTML += "<td class='H'>OFF</td>";
                continue;
            }

            // Find specific IN and OUT docs
            const inRec = dailyRecs.find(r => r.type === 'IN');
            const outRec = dailyRecs.find(r => r.type === 'OUT');

            let cellClass = "";
            let cellContent = "";

            if (!inRec) {
                // No IN record found -> Absent
                cellClass = "A";
                cellContent = "<b>Absent</b>";
            } else {
                // Has IN record
                const inTimeObj = new Date(inRec.timestamp.seconds * 1000);
                const inTimeStr = inTimeObj.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'});
                
                let outTimeStr = "--:--";
                if(outRec) {
                    const outTimeObj = new Date(outRec.timestamp.seconds * 1000);
                    outTimeStr = outTimeObj.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'});
                }

                // Check Photo
                let hasPhoto = false;
                if(inRec.photo && (inRec.photo.startsWith("http") || inRec.photo.startsWith("data:image"))) hasPhoto = true;

                // Check Late
                const [reqH, reqM] = requiredTime.split(":").map(Number);
                const isLate = (inTimeObj.getHours() > reqH) || (inTimeObj.getHours() === reqH && inTimeObj.getMinutes() > reqM);

                // Build Display
                if(!hasPhoto) {
                    cellClass = "A";
                    cellContent = "<div class='time-box'><span style='color:red'>No Photo</span><br><span class='lbl'>In:</span> " + inTimeStr + "</div>";
                } else if(isLate) {
                    cellClass = "L"; // Late
                    cellContent = "<div class='time-box'><span style='color:#a71d2a; font-weight:bold;'>LATE</span><br><span class='lbl'>In:</span> " + inTimeStr + "<br><span class='lbl'>Out:</span> " + outTimeStr + "</div>";
                } else {
                    cellClass = "P"; // Present
                    cellContent = "<div class='time-box'><span class='lbl'>In:</span> " + inTimeStr + "<br><span class='lbl'>Out:</span> " + outTimeStr + "</div>";
                }
            }
            bodyHTML += "<td class='" + cellClass + "'>" + cellContent + "</td>";
        }
        bodyHTML += "</tr>";
    });
    tableBody.innerHTML = bodyHTML;
}

function exportToExcel() {
    // Logic updated to handle IN/OUT times in export
    let exportData = [];
    const month = parseInt(document.getElementById("monthSelect").value);
    const year = parseInt(document.getElementById("yearSelect").value);
    const daysInMonth = new Date(year, month + 1, 0).getDate();

    allUsers.forEach(user => {
        let row = { "Employee": user.name };
        
        for(let d=1; d<=daysInMonth; d++) {
             const dailyRecs = attendanceData.filter(a => {
                if(!a.timestamp) return false;
                const recDate = new Date(a.timestamp.seconds * 1000);
                return a.email === user.email && recDate.getDate() === d;
            });
            
            const inRec = dailyRecs.find(r => r.type === 'IN');
            const outRec = dailyRecs.find(r => r.type === 'OUT');

            if(inRec) {
                const iTime = new Date(inRec.timestamp.seconds * 1000).toLocaleTimeString([], {hour:'2-digit', minute:'2-digit'});
                const oTime = outRec ? new Date(outRec.timestamp.seconds * 1000).toLocaleTimeString([], {hour:'2-digit', minute:'2-digit'}) : "--";
                
                if(inRec.photo && inRec.photo.startsWith("http")) {
                   row[d] = "In: " + iTime + " / Out: " + oTime + " (View Photo: " + inRec.photo + ")";
                } else {
                   row[d] = "In: " + iTime + " / Out: " + oTime;
                }
            } else {
                row[d] = "Absent";
            }
        }
        exportData.push(row);
    });

    const ws = XLSX.utils.json_to_sheet(exportData);
    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, "Attendance");
    XLSX.writeFile(wb, "Attendance_Report.xlsx");
}

function logout(){ auth.signOut().then(() => location.href = "login.jsp"); }
</script>

</body>
</html>