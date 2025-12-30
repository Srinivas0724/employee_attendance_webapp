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
<title>Payroll Management - emPower</title>

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
.content { padding: 30px; flex:1; overflow-y:auto; }

/* CARDS & LAYOUT */
.card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); margin-bottom: 20px; }
.row { display: flex; gap: 20px; }
.col { flex: 1; }

/* FORM ELEMENTS */
label { display: block; font-size: 12px; font-weight: bold; color: #555; margin-bottom: 5px; margin-top: 10px; }
input, select { width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box; }
.readonly-field { background-color: #e9ecef; color: #495057; cursor: not-allowed; }

/* TABLE */
table { width: 100%; border-collapse: collapse; margin-top: 15px; }
th { background: #34495e; color: white; padding: 10px; text-align: left; font-size: 13px; }
td { padding: 10px; border-bottom: 1px solid #eee; font-size: 13px; }
tr:hover { background: #f8f9fa; }

/* BUTTONS */
button { padding: 10px 15px; border: none; border-radius: 4px; font-weight: bold; cursor: pointer; margin-top: 10px; color: white; }
.btn-save { background: #27ae60; width: 100%; }
.btn-export { background: #f39c12; }
.btn-reset { background: #c0392b; float: right; }
.btn-mini { padding: 4px 8px; font-size: 11px; width: auto; margin-top: 5px; background: #3498db; }

#loadingOverlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: white; z-index: 9999; display: flex; justify-content: center; align-items: center; font-size: 24px; color: #333; }
</style>

<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.17.0/xlsx.full.min.js"></script>
</head>
<body>

<div id="loadingOverlay">⌛ Loading Payroll...</div>

<div class="sidebar">
  <h2>ADMIN PORTAL</h2>
  <a href="admin_dashboard.jsp">📊 Dashboard</a>
  <a href="manage_employees.jsp">👥 Manage Employees</a>
  <a href="admin_task_monitoring.jsp">📝 Task Monitoring</a>
  <a href="reports.jsp">📅 Attendance Reports</a>
  <a href="payroll.jsp" class="active">💰 Payroll Management</a>
  <a href="admin_expenses.jsp" class="active">💸 Expense Approvals</a>
  <a href="admin_settings.jsp">⚙️ Settings</a>
  <a href="#" onclick="logout()" style="margin-top:auto; background:#1a1d20;">🚪 Logout</a>
</div>

<div class="main">
    <div class="header">
        <h3>Payroll Manager</h3>
        <span id="adminEmail">Loading...</span>
    </div>

    <div class="content">
        
        <div class="card">
            <div style="display:flex; justify-content:space-between; align-items:center;">
                <h3>Step 1: Calculate & Allot</h3>
                <div>
                    <select id="monthSelect" style="width:auto; display:inline-block;"></select>
                    <select id="yearSelect" style="width:auto; display:inline-block;">
                        <option value="2024">2024</option>
                        <option value="2025" selected>2025</option>
                    </select>
                </div>
            </div>
            
            <div class="row">
                <div class="col">
                    <label>Select Employee</label>
                    <select id="empSelect" onchange="handleEmployeeChange()">
                        <option value="">-- Choose Employee --</option>
                    </select>
                </div>
                <div class="col">
                    <label>Days Present (Auto-Fetched)</label>
                    <input type="text" id="daysPresent" class="readonly-field" readonly value="0">
                </div>
                <div class="col">
                    <label>Fixed Base Salary (₹)</label>
                    <input type="number" id="monthlySalary" placeholder="Enter Amount" oninput="calcPreview()">
                    <button class="btn-mini" onclick="saveBaseSalary()">💾 Save as Default for User</button>
                </div>
            </div>

            <div class="row">
                <div class="col">
                    <label>Bonus / Incentives (+)</label>
                    <input type="number" id="bonus" value="0" oninput="calcPreview()">
                </div>
                <div class="col">
                    <label>Deductions / Advance (-)</label>
                    <input type="number" id="deductions" value="0" oninput="calcPreview()">
                </div>
                <div class="col">
                    <label>Calculated Final Pay (₹)</label>
                    <input type="text" id="finalPay" class="readonly-field" readonly style="font-weight:bold; color:#27ae60; font-size:16px;">
                </div>
            </div>

            <button class="btn-save" onclick="savePayrollRecord()">💾 Submit Payroll Record</button>
        </div>

        <div class="card">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px;">
                <h3>Step 2: Monthly Payroll Sheet</h3>
                <div>
                    <button class="btn-export" onclick="exportPayroll()">📥 Export for Google Sheet</button>
                    <button class="btn-reset" onclick="clearTable()">🗑️ Clear Table (New Month)</button>
                </div>
            </div>

            <table>
                <thead>
                    <tr>
                        <th>Employee</th>
                        <th>Month/Year</th>
                        <th>Present Days</th>
                        <th>Base Salary</th>
                        <th>Bonus</th>
                        <th>Deductions</th>
                        <th>FINAL PAY</th>
                    </tr>
                </thead>
                <tbody id="payrollTable">
                    <tr><td colspan="7" style="text-align:center;">No records yet.</td></tr>
                </tbody>
            </table>
        </div>

    </div>
</div>

<script>
const firebaseConfig = { apiKey: "AIzaSyCV5tKJMLOVcXiZUyuJZhLWOOSD96gsmP0", authDomain: "attendencewebapp-4215b.firebaseapp.com", projectId: "attendencewebapp-4215b" };
if (!firebase.apps.length) firebase.initializeApp(firebaseConfig);
const auth = firebase.auth();
const db = firebase.firestore();

let attendanceData = [];
const monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

// Init
const mSelect = document.getElementById("monthSelect");
monthNames.forEach((m, i) => {
    let opt = document.createElement("option");
    opt.value = i; opt.text = m;
    if(i === new Date().getMonth()) opt.selected = true;
    mSelect.add(opt);
});

auth.onAuthStateChanged(user => {
    if(user) {
        document.getElementById("adminEmail").innerText = user.email;
        loadEmployees();
        loadPayrollTable();
        document.getElementById("loadingOverlay").style.display = "none";
    } else {
        window.location.replace("login.jsp");
    }
});

/* 1. LOAD EMPLOYEES */
function loadEmployees() {
    db.collection("users").get().then(snap => {
        const sel = document.getElementById("empSelect");
        sel.innerHTML = '<option value="">-- Choose Employee --</option>';
        snap.forEach(doc => {
            const d = doc.data();
            if(d.role !== 'admin') {
                let opt = document.createElement("option");
                opt.value = d.email;
                opt.text = (d.fullName || d.email);
                sel.add(opt);
            }
        });
    });
}

/* 2. HANDLE SELECTION: Fetch Salary AND Attendance */
function handleEmployeeChange() {
    const email = document.getElementById("empSelect").value;
    if(!email) return;

    // A. Fetch Saved Base Salary
    db.collection("users").doc(email).get().then(doc => {
        if(doc.exists && doc.data().baseSalary) {
            document.getElementById("monthlySalary").value = doc.data().baseSalary;
        } else {
            document.getElementById("monthlySalary").value = "";
        }
        
        // B. Fetch Attendance
        fetchEmployeeStats(email);
    });
}

/* 3. FETCH ATTENDANCE COUNT */
function fetchEmployeeStats(email) {
    const month = parseInt(document.getElementById("monthSelect").value);
    const year = parseInt(document.getElementById("yearSelect").value);
    
    const start = new Date(year, month, 1);
    const end = new Date(year, month + 1, 0, 23, 59, 59);

    db.collection("attendance_2025")
        .where("email", "==", email)
        .where("timestamp", ">=", start)
        .where("timestamp", "<=", end)
        .where("type", "==", "IN")
        .get()
        .then(snap => {
            document.getElementById("daysPresent").value = snap.size;
            calcPreview();
        });
}

/* 4. SAVE DEFAULT SALARY */
function saveBaseSalary() {
    const email = document.getElementById("empSelect").value;
    const salary = document.getElementById("monthlySalary").value;
    
    if(!email || !salary) { alert("Select user and enter salary first."); return; }

    db.collection("users").doc(email).update({
        baseSalary: salary
    }).then(() => {
        alert("✅ Base Salary Saved! Next time it will auto-load.");
    }).catch(e => alert("Error: " + e.message));
}

/* 5. CALCULATE PREVIEW */
function calcPreview() {
    const present = parseInt(document.getElementById("daysPresent").value) || 0;
    const salary = parseFloat(document.getElementById("monthlySalary").value) || 0;
    const bonus = parseFloat(document.getElementById("bonus").value) || 0;
    const ded = parseFloat(document.getElementById("deductions").value) || 0;
    
    const perDay = salary / 30; 
    const earned = (perDay * present) + bonus - ded;
    
    document.getElementById("finalPay").value = Math.round(earned);
}

/* 6. SAVE RECORD */
function savePayrollRecord() {
    const email = document.getElementById("empSelect").value;
    if(!email) { alert("Select an employee"); return; }
    
    const name = document.getElementById("empSelect").options[document.getElementById("empSelect").selectedIndex].text;
    const month = monthNames[parseInt(document.getElementById("monthSelect").value)];
    const year = document.getElementById("yearSelect").value;

    const data = {
        name: name,
        email: email,
        month: month + " " + year,
        presentDays: document.getElementById("daysPresent").value,
        baseSalary: document.getElementById("monthlySalary").value,
        bonus: document.getElementById("bonus").value,
        deductions: document.getElementById("deductions").value,
        finalPay: document.getElementById("finalPay").value,
        timestamp: firebase.firestore.FieldValue.serverTimestamp()
    };

    db.collection("payroll").add(data).then(() => {
        alert("✅ Payroll Record Saved!");
        loadPayrollTable();
    });
}

/* 7. LOAD TABLE */
function loadPayrollTable() {
    db.collection("payroll").orderBy("timestamp", "desc").onSnapshot(snap => {
        const tb = document.getElementById("payrollTable");
        tb.innerHTML = "";
        if(snap.empty) {
            tb.innerHTML = "<tr><td colspan='7' style='text-align:center;'>No records found.</td></tr>";
            return;
        }
        snap.forEach(doc => {
            const d = doc.data();
            let row = "<tr>";
            row += "<td>" + d.name + "</td>";
            row += "<td>" + d.month + "</td>";
            row += "<td>" + d.presentDays + "</td>";
            row += "<td>₹" + d.baseSalary + "</td>";
            row += "<td>₹" + d.bonus + "</td>";
            row += "<td>₹" + d.deductions + "</td>";
            row += "<td style='font-weight:bold; color:#27ae60;'>₹" + d.finalPay + "</td>";
            row += "</tr>";
            tb.innerHTML += row;
        });
    });
}

/* 8. EXPORT */
function exportPayroll() {
    let data = [];
    data.push(["Employee Name", "Month", "Present Days", "Base Salary", "Bonus", "Deductions", "FINAL PAYOUT"]);
    
    db.collection("payroll").get().then(snap => {
        snap.forEach(doc => {
            const d = doc.data();
            data.push([d.name, d.month, d.presentDays, d.baseSalary, d.bonus, d.deductions, d.finalPay]);
        });
        
        const ws = XLSX.utils.aoa_to_sheet(data);
        const wb = XLSX.utils.book_new();
        XLSX.utils.book_append_sheet(wb, ws, "Payroll_Export");
        XLSX.writeFile(wb, "Payroll_Export.csv");
    });
}

/* 9. CLEAR */
function clearTable() {
    if(!confirm("⚠️ WARNING: This will delete ALL records in the payroll table.\n\nDid you export first?")) return;
    
    db.collection("payroll").get().then(snap => {
        snap.forEach(doc => doc.ref.delete());
        alert("Table Cleared.");
    });
}

function logout(){ auth.signOut().then(() => location.href = "login.jsp"); }
</script>

</body>
</html>