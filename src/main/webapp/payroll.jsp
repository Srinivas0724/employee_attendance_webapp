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
    <title>Payroll - Synod Bioscience</title>
    
    <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>

    <style>
        /* --- 1. RESET & CORE THEME --- */
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        :root {
            --primary-navy: #1a3b6e;
            --primary-dark: #122b52;
            --primary-green: #2ecc71;
            --bg-light: #f0f2f5;
            --text-dark: #2c3e50;
            --text-grey: #7f8c8d;
            --sidebar-width: 280px;
            --card-shadow: 0 4px 15px rgba(0,0,0,0.05);
        }

        body { display: flex; height: 100vh; background-color: var(--bg-light); overflow: hidden; }

        /* --- 2. SIDEBAR --- */
        .sidebar { 
            width: var(--sidebar-width); 
            background: linear-gradient(180deg, var(--primary-navy) 0%, var(--primary-dark) 100%);
            color: white; 
            display: flex; flex-direction: column; flex-shrink: 0; 
            transition: all 0.3s ease; z-index: 1000;
            box-shadow: 4px 0 20px rgba(0,0,0,0.1);
        }
        .sidebar-header { padding: 30px 20px; text-align: center; border-bottom: 1px solid rgba(255,255,255,0.05); background: rgba(0,0,0,0.1); }
        .sidebar-logo { max-width: 130px; margin-bottom: 15px; filter: brightness(0) invert(1) drop-shadow(0 4px 6px rgba(0,0,0,0.2)); }
        .sidebar-brand { font-size: 13px; font-weight: 600; letter-spacing: 1.5px; text-transform: uppercase; opacity: 0.9; }
        
        .nav-menu { list-style: none; padding: 20px 15px; flex: 1; overflow-y: auto; }
        .nav-item { margin-bottom: 8px; }
        .nav-item a { display: flex; align-items: center; padding: 14px 20px; color: #bdc3c7; text-decoration: none; font-size: 15px; font-weight: 500; border-radius: 10px; transition: all 0.2s; }
        .nav-item a:hover { background: rgba(255,255,255,0.08); color: white; transform: translateX(5px); }
        .nav-item a.active { background: var(--primary-green); color: white; box-shadow: 0 4px 15px rgba(46, 204, 113, 0.4); }
        .nav-icon { margin-right: 15px; font-size: 18px; width: 25px; text-align: center; }
        
        .sidebar-footer { padding: 25px; border-top: 1px solid rgba(255,255,255,0.05); }
        .btn-logout { width: 100%; padding: 14px; background: rgba(231, 76, 60, 0.9); color: white; border: none; border-radius: 10px; font-weight: bold; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 10px; transition: 0.2s; box-shadow: 0 4px 10px rgba(231, 76, 60, 0.3); }
        .btn-logout:hover { background: #c0392b; transform: translateY(-2px); }

        /* --- 3. MAIN CONTENT --- */
        .main-content { flex: 1; display: flex; flex-direction: column; overflow-y: auto; position: relative; }
        .topbar { background: white; height: 70px; display: flex; justify-content: space-between; align-items: center; padding: 0 40px; box-shadow: 0 2px 15px rgba(0,0,0,0.03); position: sticky; top: 0; z-index: 50; }
        .page-title { font-size: 22px; font-weight: 700; color: var(--primary-navy); letter-spacing: -0.5px; }
        .user-profile { display: flex; align-items: center; gap: 15px; background: #f8f9fa; padding: 8px 15px; border-radius: 30px; border: 1px solid #e9ecef; }
        .user-avatar { width: 36px; height: 36px; background: var(--primary-navy); color: white; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: bold; font-size: 14px; }

        .content { padding: 30px 40px; max-width: 1600px; margin: 0 auto; width: 100%; display: flex; flex-direction: column; gap: 30px; }

        /* --- 4. CARDS --- */
        .card { background: white; padding: 30px; border-radius: 16px; box-shadow: var(--card-shadow); border: 1px solid white; display: flex; flex-direction: column; }
        .card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; border-bottom: 1px solid #f0f0f0; padding-bottom: 15px; }
        .card-title { margin: 0; font-size: 18px; font-weight: 700; color: var(--primary-navy); }

        /* Grid Layout for Inputs */
        .grid-row { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; margin-bottom: 20px; }

        /* Form Elements */
        label { display: block; font-size: 12px; font-weight: 700; color: var(--text-dark); margin-bottom: 6px; text-transform: uppercase; letter-spacing: 0.5px; }
        input, select { width: 100%; padding: 12px; border: 1px solid #e0e0e0; border-radius: 8px; font-size: 14px; background: #f9f9f9; transition: 0.2s; }
        input:focus, select:focus { border-color: var(--primary-navy); background: white; outline: none; box-shadow: 0 0 0 3px rgba(26, 59, 110, 0.1); }
        .readonly-field { background-color: #eee; cursor: not-allowed; color: #666; font-weight: 600; }
        
        .final-pay-input { color: #27ae60; font-weight: 800; font-size: 18px; background: #e8f5e9; border: 1px solid #27ae60; }

        /* Buttons */
        .btn-action { padding: 12px 20px; border: none; border-radius: 8px; cursor: pointer; font-size: 14px; font-weight: 700; transition: 0.2s; color: white; display: inline-flex; align-items: center; gap: 8px; }
        .btn-green { background: var(--primary-green); width: 100%; justify-content: center; }
        .btn-green:hover { background: #27ae60; transform: translateY(-2px); box-shadow: 0 4px 10px rgba(46, 204, 113, 0.3); }
        
        .btn-orange { background: #f39c12; }
        .btn-orange:hover { background: #d35400; transform: translateY(-2px); }
        
        .btn-red { background: #e74c3c; }
        .btn-red:hover { background: #c0392b; transform: translateY(-2px); }

        .btn-mini { padding: 6px 12px; font-size: 11px; margin-top: 5px; background: var(--primary-navy); border-radius: 4px; display: inline-block; }
        .btn-mini:hover { opacity: 0.9; }

        /* Table */
        .table-wrap { overflow-x: auto; border-radius: 8px; border: 1px solid #f0f0f0; margin-top: 10px; }
        table { width: 100%; border-collapse: collapse; min-width: 800px; }
        th { background: #f8f9fa; text-align: left; padding: 15px; font-size: 12px; color: var(--text-grey); font-weight: 700; text-transform: uppercase; border-bottom: 2px solid #eee; }
        td { padding: 15px; font-size: 14px; border-bottom: 1px solid #f9f9f9; color: var(--text-dark); }
        tr:hover td { background: #fcfcfc; }
        .final-pay-text { font-weight: 800; color: #27ae60; }

        /* Period Selectors */
        .period-selector { display: flex; gap: 10px; }
        .period-selector select { width: auto; min-width: 120px; }

        #loadingOverlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: white; z-index: 9999; display: flex; flex-direction: column; justify-content: center; align-items: center; color: var(--primary-navy); font-weight: 600; }

        @media (max-width: 1024px) {
            .sidebar { position: fixed; left: -280px; height: 100%; }
            .sidebar.active { transform: translateX(280px); }
            .toggle-btn { display: block; font-size: 24px; cursor: pointer; margin-right: 15px; }
            .content { padding: 20px; }
        }
        @media (min-width: 1025px) { .toggle-btn { display: none; } }
    </style>
</head>
<body>

    <div id="loadingOverlay">
        <div style="font-size: 50px;">💰</div>
        <div style="margin-top:15px;">Loading Payroll...</div>
    </div>

    <nav class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <img src="synod_logo.png" alt="Logo" class="sidebar-logo">
            <div class="sidebar-brand">ADMIN PORTAL</div>
        </div>
        <ul class="nav-menu">
            <li class="nav-item"><a href="admin_homepage.html"><span class="nav-icon">🏠</span> Home</a></li>
            <li class="nav-item"><a href="admin_dashboard.jsp"><span class="nav-icon">📊</span> Live Dashboard</a></li>
            <li class="nav-item"><a href="manage_employees.jsp"><span class="nav-icon">👥</span> Employees</a></li>
            <li class="nav-item"><a href="list_of_employees.jsp"><span class="nav-icon">📋</span> Directory</a></li>
            <li class="nav-item"><a href="admin_task_monitoring.jsp"><span class="nav-icon">📝</span> Tasks</a></li>
            <li class="nav-item"><a href="reports.jsp"><span class="nav-icon">📅</span> Attendance</a></li>
            <li class="nav-item"><a href="admin_expenses.jsp"><span class="nav-icon">💸</span> Expenses</a></li>
            <li class="nav-item"><a href="payroll.jsp" class="active"><span class="nav-icon">💰</span> Payroll</a></li>
            <li class="nav-item"><a href="admin_settings.jsp"><span class="nav-icon">⚙️</span> Settings</a></li>
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

            <div class="card">
                <div class="card-header">
                    <span class="card-title">💵 Calculate & Allot Salary</span>
                    <div class="period-selector">
                        <select id="monthSelect"></select>
                        <select id="yearSelect">
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
                        <button class="btn-action btn-mini" onclick="saveBaseSalary()">Save as Default</button>
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
                        <input type="text" id="finalPay" class="readonly-field final-pay-input" readonly value="0">
                    </div>
                </div>

                <button class="btn-action btn-green" onclick="savePayrollRecord()">Submit Payroll Record</button>
            </div>

            <div class="card">
                <div class="card-header">
                    <span class="card-title">📜 Monthly Payroll Sheet</span>
                    <div style="display:flex; gap:10px;">
                        <button class="btn-action btn-orange" onclick="exportPayroll()">📥 Export Excel</button>
                        <button class="btn-action btn-red" onclick="clearTable()">🗑️ Clear</button>
                    </div>
                </div>

                <div class="table-wrap">
                    <table id="payrollTable">
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
                        <tbody id="payrollBody">
                            <tr><td colspan="7" style="text-align:center; padding:30px; color:#999;">No records found.</td></tr>
                        </tbody>
                    </table>
                </div>
            </div>

        </div>
    </div>

    <script>
        // CONFIG
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

        const monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

        // Init Month Dropdown
        const mSelect = document.getElementById("monthSelect");
        monthNames.forEach((m, i) => {
            const opt = document.createElement("option");
            opt.value = i; opt.text = m;
            if(i === new Date().getMonth()) opt.selected = true;
            mSelect.add(opt);
        });

        // AUTH
        auth.onAuthStateChanged(user => {
            if(user) {
                document.getElementById("adminEmail").innerText = user.email;
                loadEmployees();
                loadPayrollTable();
                document.getElementById("loadingOverlay").style.display = "none";
            } else {
                window.location.href = "index.html";
            }
        });

        // LOAD EMPLOYEES
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

        // HANDLE EMPLOYEE CHANGE
        function handleEmployeeChange() {
            const email = document.getElementById("empSelect").value;
            if(!email) return;

            db.collection("users").doc(email).get().then(doc => {
                if(doc.exists && doc.data().baseSalary) {
                    document.getElementById("monthlySalary").value = doc.data().baseSalary;
                } else {
                    document.getElementById("monthlySalary").value = "";
                }
                fetchEmployeeStats(email);
            });
        }

        // FETCH ATTENDANCE
        function fetchEmployeeStats(email) {
            const month = parseInt(document.getElementById("monthSelect").value);
            const year = parseInt(document.getElementById("yearSelect").value);
            
            const start = new Date(year, month, 1);
            const end = new Date(year, month + 1, 0, 23, 59, 59);

            // Fetch from correct collection
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

        // SAVE BASE SALARY
        function saveBaseSalary() {
            const email = document.getElementById("empSelect").value;
            const salary = document.getElementById("monthlySalary").value;
            
            if(!email || !salary) { alert("Please enter salary."); return; }

            db.collection("users").doc(email).update({ baseSalary: salary })
              .then(() => alert("✅ Saved as Default!"));
        }

        // CALC
        function calcPreview() {
            const present = parseInt(document.getElementById("daysPresent").value) || 0;
            const salary = parseFloat(document.getElementById("monthlySalary").value) || 0;
            const bonus = parseFloat(document.getElementById("bonus").value) || 0;
            const ded = parseFloat(document.getElementById("deductions").value) || 0;
            
            // Calc logic: (Salary / 30 * Days) + Bonus - Deductions
            const perDay = salary / 30; 
            const earned = (perDay * present) + bonus - ded;
            
            document.getElementById("finalPay").value = Math.round(earned);
        }

        // SAVE RECORD
        function savePayrollRecord() {
            const email = document.getElementById("empSelect").value;
            if(!email) { alert("Select employee."); return; }
            
            const name = document.getElementById("empSelect").options[document.getElementById("empSelect").selectedIndex].text;
            const month = monthNames[parseInt(document.getElementById("monthSelect").value)];
            const year = document.getElementById("yearSelect").value;

            const data = {
                name: name, email: email, month: month + " " + year,
                presentDays: document.getElementById("daysPresent").value,
                baseSalary: document.getElementById("monthlySalary").value,
                bonus: document.getElementById("bonus").value,
                deductions: document.getElementById("deductions").value,
                finalPay: document.getElementById("finalPay").value,
                timestamp: firebase.firestore.FieldValue.serverTimestamp()
            };

            db.collection("payroll").add(data).then(() => {
                alert("✅ Record Saved!");
                loadPayrollTable();
            });
        }

        // LOAD TABLE
        function loadPayrollTable() {
            db.collection("payroll").orderBy("timestamp", "desc").onSnapshot(snap => {
                const tb = document.getElementById("payrollBody");
                if(snap.empty) {
                    tb.innerHTML = "<tr><td colspan='7' style='text-align:center; padding:30px; color:#999;'>No records found.</td></tr>";
                    return;
                }
                
                let html = "";
                snap.forEach(doc => {
                    const d = doc.data();
                    html += `<tr>
                        <td>${d.name}</td>
                        <td>${d.month}</td>
                        <td>${d.presentDays}</td>
                        <td>₹${d.baseSalary}</td>
                        <td>₹${d.bonus}</td>
                        <td>₹${d.deductions}</td>
                        <td class="final-pay-text">₹${d.finalPay}</td>
                    </tr>`;
                });
                tb.innerHTML = html;
            });
        }

        // EXPORT
        function exportPayroll() {
            let data = [["Employee", "Month", "Present Days", "Base Salary", "Bonus", "Deductions", "FINAL PAYOUT"]];
            db.collection("payroll").get().then(snap => {
                snap.forEach(doc => {
                    const d = doc.data();
                    data.push([d.name, d.month, d.presentDays, d.baseSalary, d.bonus, d.deductions, d.finalPay]);
                });
                const ws = XLSX.utils.aoa_to_sheet(data);
                const wb = XLSX.utils.book_new();
                XLSX.utils.book_append_sheet(wb, ws, "Payroll");
                XLSX.writeFile(wb, "Payroll_Report.xlsx");
            });
        }

        function clearTable() {
            if(!confirm("Delete ALL records?")) return;
            db.collection("payroll").get().then(snap => {
                snap.forEach(doc => doc.ref.delete());
                alert("Cleared.");
            });
        }

        function logout(){ auth.signOut().then(() => window.location.href = "index.html"); }
        function toggleSidebar() { document.getElementById("sidebar").classList.toggle("active"); }
    </script>
</body>
</html>