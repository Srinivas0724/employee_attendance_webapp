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
<title>My Salary - emPower</title>

<style>
/* GLOBAL STYLES */
body { margin:0; font-family:"Segoe UI", sans-serif; background:#f4f6f9; display:flex; height:100vh; color:#333; }

/* SIDEBAR */
.sidebar { width:260px; background:#343a40; color:#fff; display:flex; flex-direction:column; }
.sidebar h2 { padding:20px; margin:0; background:#212529; text-align:center; }
.sidebar a { display:block; padding:15px 20px; color:#c2c7d0; text-decoration:none; border-left: 3px solid transparent; }
.sidebar a:hover, .sidebar a.active { background:#495057; color:#fff; border-left: 3px solid #007bff; }
@media (max-width: 768px) { .sidebar { display:none; } }

/* MAIN CONTENT */
.main { flex:1; display:flex; flex-direction:column; }
.header { height:60px; background:#fff; display:flex; justify-content:space-between; align-items:center; padding:0 20px; border-bottom: 1px solid #dee2e6; }
.content { padding:30px; display:flex; flex-direction:column; align-items: center; overflow-y: auto; }

/* SALARY SLIP CARD */
.salary-slip {
    background: white;
    width: 600px;
    max-width: 90%;
    padding: 40px;
    box-shadow: 0 4px 10px rgba(0,0,0,0.1);
    border-radius: 8px;
    display: none; /* Hidden until loaded */
}
.slip-header { text-align: center; border-bottom: 2px solid #333; padding-bottom: 20px; margin-bottom: 20px; }
.slip-header h2 { margin: 0; color: #333; }
.company-name { font-size: 14px; color: #666; margin-top: 5px; }

.row { display: flex; justify-content: space-between; padding: 12px 0; border-bottom: 1px solid #eee; font-size: 15px; }
.total { font-weight: bold; font-size: 1.3em; border-top: 2px solid #333; margin-top: 20px; padding-top: 15px; background: #f8f9fa; padding-left: 10px; padding-right: 10px; }

.btn-print { background: #007bff; color: white; border: none; padding: 10px 20px; margin-top: 20px; cursor: pointer; border-radius: 4px; font-weight: bold; }
.btn-print:hover { background: #0056b3; }

/* CONTROLS */
.controls { margin-bottom: 20px; background: white; padding: 15px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); display: flex; gap: 10px; align-items: center; }
select { padding: 8px; border-radius: 4px; border: 1px solid #ccc; }
button { padding: 8px 15px; cursor: pointer; border-radius: 4px; border: 1px solid #ccc; }

.no-data { color: #666; font-style: italic; margin-top: 50px; }

@media print {
    body * { visibility: hidden; }
    .salary-slip, .salary-slip * { visibility: visible; }
    .salary-slip { position: absolute; left: 0; top: 0; width: 100%; box-shadow: none; border: 1px solid #ccc; }
    .btn-print { display: none; }
}
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
  <a href="attendance_history.jsp">🕒 Attendance History</a>
  <a href="employee_expenses.jsp">💸 My Expenses</a>
  <a href="salary.jsp" class="active">💰 My Salary</a>
  <a href="settings.jsp">⚙️ Settings</a>
  <a href="#" onclick="logout()">🚪 Logout</a>
</div>

<div class="main">
    <div class="header">
        <b>My Salary</b>
        <span id="userEmail">Loading...</span>
    </div>

    <div class="content">
        
        <div class="controls">
            <label>Select Period:</label>
            <select id="monthSelect"></select>
            <select id="yearSelect">
                <option value="2024">2024</option>
                <option value="2025" selected>2025</option>
            </select>
            <button onclick="fetchSalary()" style="background:#28a745; color:white; border:none;">View Slip</button>
        </div>

        <div id="loadingMsg" style="display:none;">⌛ Fetching Payroll Data...</div>
        <div id="noDataMsg" class="no-data" style="display:block;">Please select a month and click View Slip.</div>

        <div id="salarySlip" class="salary-slip">
            <div class="slip-header">
                <h2>PAYSLIP</h2>
                <div class="company-name" id="dispCompany">emPower Tech</div>
                <p style="margin-bottom:0; margin-top:10px;">Period: <b id="dispMonth"></b></p>
                <p style="margin:0; font-size:13px; color:#555;">Employee: <span id="dispName"></span></p>
            </div>

            <div class="row"><span>Days Present</span> <span id="dispDays">-</span></div>
            <div class="row"><span>Base Salary</span> <span id="dispBase">₹ 0</span></div>
            <div class="row"><span>Bonus / Incentives</span> <span style="color:green" id="dispBonus">+ ₹ 0</span></div>
            <div class="row"><span>Deductions</span> <span style="color:red" id="dispDed">- ₹ 0</span></div>
            
            <div class="row total">
                <span>NET PAYABLE</span>
                <span style="color:green" id="dispFinal">₹ 0</span>
            </div>

            <div style="text-align:center;">
                <button class="btn-print" onclick="window.print()">🖨️ Print / Download PDF</button>
            </div>
        </div>

    </div>
</div>

<script>
const firebaseConfig = { apiKey: "AIzaSyCV5tKJMLOVcXiZUyuJZhLWOOSD96gsmP0", authDomain: "attendencewebapp-4215b.firebaseapp.com", projectId: "attendencewebapp-4215b" };
if (!firebase.apps.length) firebase.initializeApp(firebaseConfig);
const auth = firebase.auth();
const db = firebase.firestore();

let currentUserEmail = null;
const monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

// Init Dropdown
const mSelect = document.getElementById("monthSelect");
monthNames.forEach((m, i) => {
    let opt = document.createElement("option");
    opt.value = m; // Value is string "January" to match Admin format
    opt.text = m;
    if(i === new Date().getMonth()) opt.selected = true;
    mSelect.add(opt);
});

auth.onAuthStateChanged(user => {
    if(user) {
        currentUserEmail = user.email;
        document.getElementById("userEmail").innerText = user.email;
        fetchCompanyInfo();
    } else {
        window.location.href = "login.jsp";
    }
});

function fetchCompanyInfo() {
    db.collection("settings").doc("system").get().then(doc => {
        if(doc.exists && doc.data().companyName) {
            document.getElementById("dispCompany").innerText = doc.data().companyName;
        }
    });
}

function fetchSalary() {
    if(!currentUserEmail) return;

    const month = document.getElementById("monthSelect").value;
    const year = document.getElementById("yearSelect").value;
    const queryMonth = month + " " + year; // Format must match Admin's save format e.g., "January 2025"

    document.getElementById("loadingMsg").style.display = "block";
    document.getElementById("salarySlip").style.display = "none";
    document.getElementById("noDataMsg").style.display = "none";

    db.collection("payroll")
        .where("email", "==", currentUserEmail)
        .where("month", "==", queryMonth)
        .get()
        .then(snap => {
            document.getElementById("loadingMsg").style.display = "none";

            if(snap.empty) {
                document.getElementById("noDataMsg").innerText = "No generated salary slip found for " + queryMonth + ".";
                document.getElementById("noDataMsg").style.display = "block";
                return;
            }

            // Assume only 1 record per month per user
            const data = snap.docs[0].data();

            document.getElementById("dispMonth").innerText = data.month;
            document.getElementById("dispName").innerText = data.name + " (" + data.email + ")";
            document.getElementById("dispDays").innerText = data.presentDays;
            document.getElementById("dispBase").innerText = "₹ " + data.baseSalary;
            document.getElementById("dispBonus").innerText = "+ ₹ " + data.bonus;
            document.getElementById("dispDed").innerText = "- ₹ " + data.deductions;
            document.getElementById("dispFinal").innerText = "₹ " + data.finalPay;

            document.getElementById("salarySlip").style.display = "block";
        })
        .catch(err => {
            console.error(err);
            document.getElementById("loadingMsg").style.display = "none";
            alert("Error fetching data: " + err.message);
        });
}

function logout(){
    auth.signOut().then(() => {
        window.location.href = "login.jsp";
    });
}
</script>

</body>
</html>