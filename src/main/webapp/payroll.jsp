<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
  response.setHeader("Pragma", "no-cache");
  response.setDateHeader("Expires", 0);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payroll Management - Synod Bioscience</title>
    
    <style>
        /* --- 1. RESET & VARS (MATCHING ADMIN THEME) --- */
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        
        :root {
            --primary-navy: #1a3b6e;
            --primary-green: #2ecc71;
            --bg-light: #f4f6f9;
            --text-dark: #333;
            --text-grey: #666;
            --sidebar-width: 260px;
        }

        body { display: flex; height: 100vh; background-color: var(--bg-light); overflow: hidden; }

        /* --- 2. SIDEBAR --- */
        .sidebar {
            width: var(--sidebar-width);
            background-color: var(--primary-navy);
            color: white;
            display: flex;
            flex-direction: column;
            transition: width 0.3s;
            flex-shrink: 0;
        }

        .sidebar-header {
            padding: 20px;
            background-color: rgba(0,0,0,0.1);
            text-align: center;
            border-bottom: 1px solid rgba(255,255,255,0.1);
        }

        .sidebar-logo {
            max-width: 140px;
            height: auto;
            margin-bottom: 10px;
            filter: brightness(0) invert(1);
        }
        
        .sidebar-brand { font-size: 14px; opacity: 0.8; letter-spacing: 1px; text-transform: uppercase; }

        .nav-menu {
            list-style: none;
            padding: 20px 0;
            flex: 1;
            overflow-y: auto;
        }

        .nav-item a {
            display: flex;
            align-items: center;
            padding: 15px 25px;
            color: #bdc3c7;
            text-decoration: none;
            font-size: 15px;
            transition: all 0.3s;
            border-left: 4px solid transparent;
        }

        .nav-item a:hover, .nav-item a.active {
            background-color: rgba(255,255,255,0.05);
            color: white;
            border-left-color: var(--primary-green);
        }

        .nav-icon { margin-right: 15px; font-size: 18px; width: 25px; text-align: center; }

        .sidebar-footer { padding: 20px; border-top: 1px solid rgba(255,255,255,0.1); }
        .btn-logout {
            width: 100%;
            padding: 12px;
            background-color: rgba(231, 76, 60, 0.8);
            color: white;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-weight: bold;
            transition: 0.3s;
            display: flex; align-items: center; justify-content: center; gap: 10px;
        }
        .btn-logout:hover { background-color: #c0392b; }

        /* --- 3. MAIN CONTENT --- */
        .main-content {
            flex: 1;
            display: flex;
            flex-direction: column;
            overflow-y: auto;
        }

        /* Top Bar */
        .topbar {
            background: white;
            height: 60px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0 30px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            position: sticky; top: 0; z-index: 100;
        }

        .page-title { font-size: 20px; font-weight: bold; color: var(--primary-navy); }
        .user-profile { font-size: 14px; color: var(--text-grey); display: flex; align-items: center; gap: 10px; }
        .user-avatar { width: 35px; height: 35px; background: #e0e0e0; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: bold; color: var(--primary-navy); }

        /* --- 4. PAGE CONTENT --- */
        .content { padding: 30px; max-width: 1300px; margin: 0 auto; width: 100%; display: flex; flex-direction: column; gap: 25px; }

        /* Cards */
        .card { background: white; padding: 25px; border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); border-top: 4px solid transparent; }
        .card h3 { margin-top: 0; color: var(--primary-navy); border-bottom: 2px solid #f4f6f9; padding-bottom: 12px; margin-bottom: 20px; font-size: 18px; font-weight: bold; }

        /* Card Borders */
        .card-calc { border-top-color: #3498db; }
        .card-table { border-top-color: var(--primary-green); }

        /* Grid Layout for Form */
        .grid-row { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; margin-bottom: 15px; }

        /* Forms */
        label { font-weight: 600; font-size: 13px; color: #555; display: block; margin-bottom: 8px; text-transform: uppercase; }
        input, select { width: 100%; padding: 12px; border: 2px solid #f1f1f1; border-radius: 6px; box-sizing: border-box; font-size: 14px; transition: all 0.3s; }
        input:focus, select:focus { border-color: var(--primary-navy); outline: none; background: #fff; }
        .readonly-field { background-color: #f8f9fa; color: #666; cursor: not-allowed; border-color: #eee; }

        /* Buttons */
        button.action-btn { margin-top: 10px; padding: 12px 20px; border: none; border-radius: 6px; cursor: pointer; font-size: 14px; font-weight: 600; transition: background 0.3s; color: white; display: flex; align-items: center; justify-content: center; gap: 8px; }
        
        .btn-green { background: var(--primary-green); width: 100%; }
        .btn-green:hover { background: #27ae60; }
        
        .btn-orange { background: #f39c12; width: auto; }
        .btn-orange:hover { background: #d35400; }
        
        .btn-red { background: #e74c3c; width: auto; }
        .btn-red:hover { background: #c0392b; }

        .btn-mini { padding: 6px 12px; font-size: 11px; margin-top: 5px; background: #3498db; width: auto; display: inline-block; }
        .btn-mini:hover { background: #2980b9; }

        /* Table */
        table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        th { background: #f8f9fa; color: #666; padding: 15px 12px; text-align: left; font-size: 13px; text-transform: uppercase; border-bottom: 2px solid #eee; font-weight: 700; }
        td { padding: 15px 12px; border-bottom: 1px solid #f1f1f1; color: #444; font-size: 14px; vertical-align: middle; }
        tr:hover { background: #fafafa; }

        /* Final Pay Highlight */
        .final-pay-text { font-size: 16px; font-weight: bold; color: var(--primary-green); }

        #loadingOverlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: white; z-index: 9999; display: flex; justify-content: center; align-items: center; font-size: 24px; color: #333; flex-direction: column; gap: 10px; }

        /* Responsive */
        @media (max-width: 900px) {
            .sidebar { position: absolute; left: -260px; height: 100%; z-index: 200; }
            .sidebar.open { left: 0; }
            .toggle-btn { display: block; margin-right: 15px; cursor: pointer; font-size: 24px; }
        }
        @media (min-width: 901px) { .toggle-btn { display: none; } }
    </style>

    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.17.0/xlsx.full.min.js"></script>
</head>
<body>

    <div id="loadingOverlay">
        <div style="font-size: 40px; margin-bottom: 10px;">💰</div>
        <div>Loading Payroll...</div>
    </div>

    <nav class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <img src="synod_logo.png" alt="Synod Logo" class="sidebar-logo">
            <div class="sidebar-brand">ADMIN PORTAL</div>
        </div>

        <ul class="nav-menu">
            <li class="nav-item">
                <a href="admin_homepage.html"><span class="nav-icon">🏠</span> Home</a>
            </li>
            <li class="nav-item">
                <a href="admin_dashboard.jsp"><span class="nav-icon">📊</span> Live Dashboard</a>
            </li>
            <li class="nav-item">
                <a href="manage_employees.jsp"><span class="nav-icon">👥</span> Employees</a>
            </li>
            <li class="nav-item">
                <a href="admin_task_monitoring.jsp"><span class="nav-icon">📝</span> Tasks</a>
            </li>
            <li class="nav-item">
                <a href="admin_attendance.jsp"><span class="nav-icon">📅</span> Attendance</a>
            </li>
            <li class="nav-item">
                <a href="admin_expenses.jsp"><span class="nav-icon">💸</span> Expenses</a>
            </li>
            <li class="nav-item">
                <a href="payroll.jsp" class="active"><span class="nav-icon">💰</span> Payroll</a>
            </li>
            <li class="nav-item">
                <a href="admin_settings.jsp"><span class="nav-icon">⚙️</span> Settings</a>
            </li>
        </ul>

        <div class="sidebar-footer">
            <button onclick="logout()" class="btn-logout"><span>🚪</span> Sign Out</button>
        </div>
    </nav>

    <div class="main-content">
        <header class="topbar">
            <div style="display:flex; align-items:center;">
                <div class="toggle-btn" onclick="toggleSidebar()">☰</div>
                <div class="page-title">Payroll Management</div>
            </div>
            <div class="user-profile">
                <span id="adminEmail">Loading...</span>
                <div class="user-avatar">A</div>
            </div>
        </header>

        <div class="content">

            <div class="card card-calc">
                <div style="display:flex; justify-content:space-between; align-items:center;">
                    <h3>Step 1: Calculate & Allot Salary</h3>
                    <div style="display:flex; gap:10px;">
                        <select id="monthSelect" style="width:auto;"></select>
                        <select id="yearSelect" style="width:auto;">
                            <option value="2024">2024</option>
                            <option value="2025" selected>2025</option>
                            <option value="2026">2026</option>
                        </select>
                    </div>
                </div>

                <div class="grid-row">
                    <div>
                        <label>Select Employee</label>
                        <select id="empSelect" onchange="handleEmployeeChange()">
                            <option value="">-- Choose Employee --</option>
                        </select>
                    </div>
                    <div>
                        <label>Days Present (Auto)</label>
                        <input type="text" id="daysPresent" class="readonly-field" readonly value="0">
                    </div>
                    <div>
                        <label>Fixed Base Salary (₹)</label>
                        <input type="number" id="monthlySalary" placeholder="Enter Amount" oninput="calcPreview()">
                        <button class="action-btn btn-mini" onclick="saveBaseSalary()">💾 Save as Default</button>
                    </div>
                </div>

                <div class="grid-row">
                    <div>
                        <label>Bonus / Incentives (+)</label>
                        <input type="number" id="bonus" value="0" oninput="calcPreview()">
                    </div>
                    <div>
                        <label>Deductions / Advance (-)</label>
                        <input type="number" id="deductions" value="0" oninput="calcPreview()">
                    </div>
                    <div>
                        <label>Calculated Final Pay (₹)</label>
                        <input type="text" id="finalPay" class="readonly-field" readonly style="font-weight:bold; color:#27ae60; font-size:16px;">
                    </div>
                </div>

                <button class="action-btn btn-green" onclick="savePayrollRecord()">💾 Submit Payroll Record</button>
            </div>

            <div class="card card-table">
                <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px;">
                    <h3 style="margin:0;">Step 2: Monthly Payroll Sheet</h3>
                    <div style="display:flex; gap:10px;">
                        <button class="action-btn btn-orange" onclick="exportPayroll()">📥 Export to Excel</button>
                        <button class="action-btn btn-red" onclick="clearTable()">🗑️ Clear Table</button>
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
        // --- 1. CONFIG ---
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

        let attendanceData = [];
        const monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

        // Init Month Dropdown
        const mSelect = document.getElementById("monthSelect");
        monthNames.forEach((m, i) => {
            const opt = document.createElement("option");
            opt.value = i; 
            opt.text = m;
            if(i === new Date().getMonth()) opt.selected = true;
            mSelect.add(opt);
        });

        // --- 2. AUTH CHECK ---
        auth.onAuthStateChanged(user => {
            if(user) {
                document.getElementById("adminEmail").innerText = user.email;
                loadEmployees();
                loadPayrollTable();
                document.getElementById("loadingOverlay").style.display = "none";
            } else {
                window.location.replace("index.html");
            }
        });

        // --- 3. LOAD EMPLOYEES ---
        function loadEmployees() {
            db.collection("users").get().then(snap => {
                const sel = document.getElementById("empSelect");
                sel.innerHTML = '<option value="">-- Choose Employee --</option>';
                snap.forEach(doc => {
                    const d = doc.data();
                    if(d.role !== 'admin') {
                        const opt = document.createElement("option");
                        opt.value = d.email;
                        opt.text = (d.fullName || d.email);
                        sel.add(opt);
                    }
                });
            });
        }

        // --- 4. HANDLE SELECTION ---
        function handleEmployeeChange() {
            const email = document.getElementById("empSelect").value;
            if(!email) return;

            // Get Base Salary
            db.collection("users").doc(email).get().then(doc => {
                if(doc.exists && doc.data().baseSalary) {
                    document.getElementById("monthlySalary").value = doc.data().baseSalary;
                } else {
                    document.getElementById("monthlySalary").value = "";
                }
                // Get Attendance
                fetchEmployeeStats(email);
            });
        }

        // --- 5. FETCH ATTENDANCE ---
        function fetchEmployeeStats(email) {
            const month = parseInt(document.getElementById("monthSelect").value);
            const year = parseInt(document.getElementById("yearSelect").value);
            
            const start = new Date(year, month, 1);
            const end = new Date(year, month + 1, 0, 23, 59, 59);

            // Dynamic collection based on year
            // Assuming attendance_2025 is fixed for now per your DB
            const collectionName = "attendance_2025"; 

            db.collection(collectionName)
                .where("email", "==", email)
                .where("timestamp", ">=", start)
                .where("timestamp", "<=", end)
                .where("type", "==", "IN")
                .get()
                .then(snap => {
                    document.getElementById("daysPresent").value = snap.size;
                    calcPreview();
                })
                .catch(error => {
                    console.error(error);
                    if(error.message.includes("requires an index")) {
                        alert("⚠️ SYSTEM ALERT: A database index is missing. Please create it in Firebase Console.");
                    }
                });
        }

        // --- 6. SAVE DEFAULT SALARY ---
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

        // --- 7. AUTO CALC ---
        function calcPreview() {
            const present = parseInt(document.getElementById("daysPresent").value) || 0;
            const salary = parseFloat(document.getElementById("monthlySalary").value) || 0;
            const bonus = parseFloat(document.getElementById("bonus").value) || 0;
            const ded = parseFloat(document.getElementById("deductions").value) || 0;
            
            // Simple Prorated: (Salary / 30 * Days Present) + Bonus - Deductions
            const perDay = salary / 30; 
            const earned = (perDay * present) + bonus - ded;
            
            document.getElementById("finalPay").value = Math.round(earned);
        }

        // --- 8. SAVE RECORD ---
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

        // --- 9. LOAD TABLE ---
        function loadPayrollTable() {
            db.collection("payroll").orderBy("timestamp", "desc").onSnapshot(snap => {
                const tb = document.getElementById("payrollTable");
                tb.innerHTML = "";
                if(snap.empty) {
                    tb.innerHTML = "<tr><td colspan='7' style='text-align:center; padding:20px;'>No records found.</td></tr>";
                    return;
                }
                
                let html = "";
                snap.forEach(doc => {
                    const d = doc.data();
                    html += "<tr>";
                    html += "<td>" + d.name + "</td>";
                    html += "<td>" + d.month + "</td>";
                    html += "<td>" + d.presentDays + "</td>";
                    html += "<td>₹" + d.baseSalary + "</td>";
                    html += "<td>₹" + d.bonus + "</td>";
                    html += "<td>₹" + d.deductions + "</td>";
                    html += "<td class='final-pay-text'>₹" + d.finalPay + "</td>";
                    html += "</tr>";
                });
                tb.innerHTML = html;
            });
        }

        // --- 10. EXPORT ---
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
                XLSX.writeFile(wb, "Payroll_Export.xlsx");
            });
        }

        // --- 11. CLEAR ---
        function clearTable() {
            if(!confirm("⚠️ WARNING: This will delete ALL records in the payroll table.\n\nDid you export first?")) return;
            
            db.collection("payroll").get().then(snap => {
                snap.forEach(doc => doc.ref.delete());
                alert("Table Cleared.");
            });
        }

        function logout(){
            auth.signOut().then(() => window.location.href = "index.html");
        }
        
        function toggleSidebar() {
            document.getElementById("sidebar").classList.toggle("open");
        }
    </script>
</body>
</html>