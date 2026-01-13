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
    <title>My Salary - Employee Portal</title>
    
    <style>
        /* --- 1. RESET & VARS --- */
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        
        :root {
            --primary-navy: #1a3b6e;
            --primary-dark: #122b52;
            --primary-green: #2ecc71;
            --bg-light: #f0f2f5;
            --text-dark: #2c3e50;
            --text-grey: #7f8c8d;
            --card-shadow: 0 10px 30px rgba(0,0,0,0.05);
            --sidebar-width: 280px;
        }

        body { display: flex; height: 100vh; background-color: var(--bg-light); overflow: hidden; }

        /* --- 2. SIDEBAR --- */
        .sidebar {
            width: var(--sidebar-width);
            background: linear-gradient(180deg, var(--primary-navy) 0%, var(--primary-dark) 100%);
            color: white;
            display: flex;
            flex-direction: column;
            transition: all 0.3s ease;
            flex-shrink: 0;
            z-index: 1000;
            box-shadow: 4px 0 20px rgba(0,0,0,0.1);
        }

        .sidebar-header {
            padding: 30px 20px;
            text-align: center;
            border-bottom: 1px solid rgba(255,255,255,0.05);
            background: rgba(0,0,0,0.1);
        }

        .sidebar-logo {
            max-width: 130px;
            height: auto;
            margin-bottom: 15px;
            filter: brightness(0) invert(1) drop-shadow(0 4px 6px rgba(0,0,0,0.2));
        }
        
        .sidebar-brand { 
            font-size: 13px; 
            opacity: 0.9; 
            letter-spacing: 1.5px; 
            text-transform: uppercase; 
            font-weight: 600;
        }

        .nav-menu {
            list-style: none;
            padding: 20px 15px;
            flex: 1;
            overflow-y: auto;
        }

        .nav-item { margin-bottom: 8px; }

        .nav-item a {
            display: flex;
            align-items: center;
            padding: 14px 20px;
            color: #bdc3c7;
            text-decoration: none;
            font-size: 15px;
            font-weight: 500;
            border-radius: 10px;
            transition: all 0.2s ease;
        }

        .nav-item a:hover {
            background-color: rgba(255,255,255,0.08);
            color: white;
            transform: translateX(5px);
        }

        .nav-item a.active {
            background-color: var(--primary-green);
            color: white;
            box-shadow: 0 4px 15px rgba(46, 204, 113, 0.4);
        }

        .nav-icon { margin-right: 15px; font-size: 18px; width: 25px; text-align: center; }

        .sidebar-footer { padding: 25px; border-top: 1px solid rgba(255,255,255,0.05); }
        .btn-logout {
            width: 100%;
            padding: 14px;
            background-color: rgba(231, 76, 60, 0.9);
            color: white;
            border: none;
            border-radius: 10px;
            cursor: pointer;
            font-weight: bold;
            font-size: 14px;
            display: flex; align-items: center; justify-content: center; gap: 10px;
            transition: all 0.2s;
            box-shadow: 0 4px 10px rgba(231, 76, 60, 0.3);
        }
        .btn-logout:hover { background-color: #c0392b; transform: translateY(-2px); }

        /* --- 3. MAIN CONTENT --- */
        .main-content {
            flex: 1;
            display: flex;
            flex-direction: column;
            overflow-y: auto;
            position: relative;
        }
        
        .topbar {
            background: white;
            height: 70px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0 40px;
            box-shadow: 0 2px 15px rgba(0,0,0,0.03);
            position: sticky; top: 0; z-index: 100;
        }
        
        .page-title { 
            font-size: 22px; 
            font-weight: 700; 
            color: var(--primary-navy); 
            letter-spacing: -0.5px;
        }

        .user-profile { 
            display: flex; 
            align-items: center; 
            gap: 15px; 
            background: #f8f9fa;
            padding: 8px 15px;
            border-radius: 30px;
            border: 1px solid #e9ecef;
        }
        
        .user-email { font-size: 13px; color: var(--text-dark); font-weight: 600; }
        .user-avatar { 
            width: 36px; height: 36px; 
            background: var(--primary-navy); 
            color: white;
            border-radius: 50%; 
            display: flex; align-items: center; justify-content: center; 
            font-weight: bold; font-size: 14px;
        }

        /* --- 4. SALARY CONTENT --- */
        .content { 
            padding: 40px; 
            max-width: 900px; 
            margin: 0 auto; 
            width: 100%; 
            display: flex; 
            flex-direction: column; 
            align-items: center; 
            gap: 30px; 
        }

        /* Controls Bar */
        .controls-card {
            background: white; 
            padding: 25px 30px; 
            border-radius: 16px; 
            box-shadow: var(--card-shadow); 
            width: 100%;
            display: flex; 
            gap: 20px; 
            align-items: center; 
            justify-content: center;
            flex-wrap: wrap;
            border-top: 4px solid var(--primary-navy);
        }
        
        .control-group { display: flex; align-items: center; gap: 10px; }
        label { font-weight: 600; font-size: 14px; color: var(--text-dark); }

        select { 
            padding: 10px 15px; 
            border: 1px solid #e0e0e0; 
            border-radius: 8px; 
            font-size: 14px; 
            min-width: 160px; 
            outline: none; 
            transition: 0.3s;
            background: #fdfdfd;
        }
        select:focus { border-color: var(--primary-navy); background: white; }
        
        .btn-view { 
            background: var(--primary-navy); 
            color: white; 
            border: none; 
            padding: 10px 25px; 
            border-radius: 8px; 
            cursor: pointer; 
            font-weight: 700; 
            font-size: 14px; 
            transition: all 0.2s;
            box-shadow: 0 4px 10px rgba(26, 59, 110, 0.2);
        }
        .btn-view:hover { background: #132c52; transform: translateY(-2px); }

        /* Salary Slip */
        .salary-slip {
            background: white; 
            width: 100%; 
            max-width: 750px;
            padding: 50px; 
            border-radius: 16px;
            box-shadow: 0 20px 50px rgba(0,0,0,0.1);
            display: none; 
            border: 1px solid #f1f1f1;
            position: relative;
            animation: slideUp 0.4s ease;
        }

        @keyframes slideUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }

        .slip-header { 
            text-align: center; 
            border-bottom: 2px solid var(--primary-navy); 
            padding-bottom: 25px; 
            margin-bottom: 35px; 
        }
        .slip-header h2 { 
            margin: 0; 
            color: var(--primary-navy); 
            text-transform: uppercase; 
            letter-spacing: 1.5px; 
            font-size: 24px;
        }
        .company-name { font-size: 15px; color: var(--text-grey); margin-top: 5px; font-weight: 600; }
        
        .emp-details { 
            display: grid; 
            grid-template-columns: 1fr 1fr; 
            gap: 25px; 
            margin-bottom: 35px; 
            background: #f8f9fa; 
            padding: 20px; 
            border-radius: 10px; 
            font-size: 14px; 
            border: 1px solid #e9ecef;
        }
        .emp-details div b { color: var(--primary-navy); display: block; margin-bottom: 4px; }
        .emp-details div span { color: var(--text-dark); }

        .salary-table { width: 100%; border-collapse: collapse; margin-bottom: 25px; }
        .salary-table th { 
            text-align: left; padding: 12px 10px; 
            border-bottom: 2px solid #eee; 
            color: var(--text-grey); font-size: 13px; 
            text-transform: uppercase; letter-spacing: 0.5px;
        }
        .salary-table td { padding: 15px 10px; border-bottom: 1px solid #f1f1f1; font-size: 14px; color: var(--text-dark); }
        .salary-table tr:last-child td { border-bottom: none; }
        
        .amount-col { text-align: right; font-weight: 700; font-family: 'Consolas', monospace; font-size: 15px; }
        .text-green { color: #16a34a; }
        .text-red { color: #dc2626; }

        .total-row { 
            background: var(--primary-navy); 
            color: white; 
            padding: 20px; 
            border-radius: 10px; 
            display: flex; 
            justify-content: space-between; 
            align-items: center;
            font-size: 18px; 
            font-weight: 800; 
            margin-top: 10px;
            box-shadow: 0 5px 15px rgba(26, 59, 110, 0.2);
        }

        .btn-print { 
            background: var(--primary-green); 
            color: white; 
            border: none; 
            padding: 14px 35px; 
            border-radius: 50px; 
            cursor: pointer; 
            font-weight: 700; 
            margin-top: 40px; 
            display: block; 
            margin-left: auto; 
            margin-right: auto;
            box-shadow: 0 4px 15px rgba(46, 204, 113, 0.3); 
            transition: all 0.2s;
            font-size: 14px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .btn-print:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(46, 204, 113, 0.4); }

        .no-data { 
            text-align: center; color: var(--text-grey); 
            margin-top: 80px; font-style: italic; font-size: 15px;
            background: white; padding: 40px; border-radius: 16px;
            width: 100%; box-shadow: var(--card-shadow);
        }

        /* Loader */
        #loadingOverlay { 
            position: fixed; top: 0; left: 0; width: 100%; height: 100%; 
            background: rgba(255,255,255,0.9); backdrop-filter: blur(5px);
            z-index: 9999; display: flex; justify-content: center; align-items: center; 
            font-size: 24px; color: var(--primary-navy); flex-direction: column; gap: 15px; font-weight: 600;
        }

        /* Print Styles */
        @media print {
            body * { visibility: hidden; }
            .sidebar, .topbar, .controls-card, .btn-print { display: none !important; }
            .salary-slip, .salary-slip * { visibility: visible; }
            .salary-slip { 
                position: absolute; left: 0; top: 0; width: 100%; 
                box-shadow: none; border: 2px solid #000; 
                margin: 0; padding: 40px; 
                display: block !important;
            }
            .content { padding: 0; margin: 0; }
        }

        /* Mobile Responsive */
        @media (max-width: 900px) {
            .sidebar { position: fixed; left: -280px; height: 100%; }
            .sidebar.active { transform: translateX(280px); }
            .toggle-btn { display: block; font-size: 24px; cursor: pointer; margin-right: 15px; }
            .content { padding: 20px; }
            .topbar { padding: 0 20px; }
            .emp-details { grid-template-columns: 1fr; }
            .controls-card { flex-direction: column; align-items: stretch; }
            select, .btn-view { width: 100%; }
        }
    </style>

    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
</head>
<body>

    <div id="loadingOverlay">
        <div style="font-size: 50px;">💰</div>
        <div>Loading Profile...</div>
    </div>

    <nav class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <img src="synod_logo.png" alt="Synod Logo" class="sidebar-logo">
            <div class="sidebar-brand">EMPLOYEE PORTAL</div>
        </div>

        <ul class="nav-menu">
            <li class="nav-item">
                <a href="employee_dashboard.jsp"><span class="nav-icon">📊</span> Dashboard</a>
            </li>
            <li class="nav-item">
                <a href="mark_attendance.jsp"><span class="nav-icon">📍</span> Mark Attendance</a>
            </li>
            <li class="nav-item">
                <a href="employee_tasks.jsp"><span class="nav-icon">📝</span> Assigned Tasks</a>
            </li>
            <li class="nav-item">
                <a href="attendance_history.jsp"><span class="nav-icon">🕒</span> History</a>
            </li>
            <li class="nav-item">
                <a href="employee_expenses.jsp"><span class="nav-icon">💸</span> My Expenses</a>
            </li>
            <li class="nav-item">
                <a href="salary.jsp" class="active"><span class="nav-icon">💰</span> My Salary</a>
            </li>
            <li class="nav-item">
                <a href="settings.jsp"><span class="nav-icon">⚙️</span> Settings</a>
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
                <div class="page-title">Salary & Payslips</div>
            </div>
            <div class="user-profile">
                <span id="userEmail" class="user-email">Loading...</span>
                <div class="user-avatar">E</div>
            </div>
        </header>

        <div class="content">
            
            <div class="controls-card">
                <div class="control-group">
                    <label>Month:</label>
                    <select id="monthSelect"></select>
                </div>
                <div class="control-group">
                    <label>Year:</label>
                    <select id="yearSelect">
                        <option value="2024">2024</option>
                        <option value="2025" selected>2025</option>
                        <option value="2026">2026</option>
                    </select>
                </div>
                <button onclick="fetchSalary()" class="btn-view">🔍 View Payslip</button>
            </div>

            <div id="noDataMsg" class="no-data">Select a month above to view your payslip.</div>

            <div id="salarySlip" class="salary-slip">
                <div class="slip-header">
                    <h2>Salary Slip</h2>
                    <div class="company-name" id="dispCompany">Synod Bioscience</div>
                    <p style="margin: 10px 0 0 0; color:#555; font-size:14px;">Payslip for the month of <b id="dispMonth" style="color:var(--primary-navy);"></b></p>
                </div>

                <div class="emp-details">
                    <div><b>Employee Name:</b> <span id="dispName">-</span></div>
                    <div><b>Employee ID / Email:</b> <span id="dispEmail">-</span></div>
                    <div><b>Days Present:</b> <span id="dispDays">-</span></div>
                    <div><b>Generated On:</b> <span id="dispDate">-</span></div>
                </div>

                <table class="salary-table">
                    <thead>
                        <tr>
                            <th>Description</th>
                            <th style="text-align:right;">Amount (₹)</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>Basic Salary</td>
                            <td class="amount-col" id="dispBase">0.00</td>
                        </tr>
                        <tr>
                            <td>Performance Bonus / Incentives</td>
                            <td class="amount-col text-green" id="dispBonus">0.00</td>
                        </tr>
                        <tr>
                            <td>Deductions (Tax/PF/Advance)</td>
                            <td class="amount-col text-red" id="dispDed">0.00</td>
                        </tr>
                    </tbody>
                </table>

                <div class="total-row">
                    <span>NET PAYABLE</span>
                    <span id="dispFinal">₹ 0.00</span>
                </div>

                <button class="btn-print" onclick="window.print()">🖨️ Print / Download PDF</button>
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

        let currentUserEmail = null;
        const monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

        // Init Dropdown
        const mSelect = document.getElementById("monthSelect");
        monthNames.forEach((m, i) => {
            let opt = document.createElement("option");
            opt.value = m; 
            opt.text = m;
            if(i === new Date().getMonth()) opt.selected = true;
            mSelect.add(opt);
        });

        // --- 2. AUTH CHECK ---
        auth.onAuthStateChanged(user => {
            if(user) {
                currentUserEmail = user.email;
                document.getElementById("userEmail").innerText = user.email;
                document.getElementById("loadingOverlay").style.display = "none";
                fetchCompanyInfo();
            } else {
                window.location.href = "index.html";
            }
        });

        function toggleSidebar() {
            document.getElementById("sidebar").classList.toggle("active");
        }

        function fetchCompanyInfo() {
            db.collection("settings").doc("system").get().then(doc => {
                if(doc.exists && doc.data().companyName) {
                    document.getElementById("dispCompany").innerText = doc.data().companyName;
                }
            });
        }

        // --- 3. FETCH SALARY ---
        function fetchSalary() {
            if(!currentUserEmail) return;

            const month = document.getElementById("monthSelect").value;
            const year = document.getElementById("yearSelect").value;
            const queryMonth = month + " " + year; 

            document.getElementById("salarySlip").style.display = "none";
            document.getElementById("noDataMsg").style.display = "block";
            document.getElementById("noDataMsg").innerText = "Searching records...";

            db.collection("payroll")
                .where("email", "==", currentUserEmail)
                .where("month", "==", queryMonth)
                .get()
                .then(snap => {
                    if(snap.empty) {
                        document.getElementById("noDataMsg").innerText = "No salary slip found for " + queryMonth + ".";
                        return;
                    }

                    document.getElementById("noDataMsg").style.display = "none";
                    const data = snap.docs[0].data();

                    document.getElementById("dispMonth").innerText = data.month;
                    document.getElementById("dispName").innerText = data.name;
                    document.getElementById("dispEmail").innerText = data.email;
                    document.getElementById("dispDays").innerText = data.presentDays;
                    document.getElementById("dispDate").innerText = new Date().toLocaleDateString();

                    document.getElementById("dispBase").innerText = "₹ " + data.baseSalary;
                    document.getElementById("dispBonus").innerText = "+ ₹ " + data.bonus;
                    document.getElementById("dispDed").innerText = "- ₹ " + data.deductions;
                    document.getElementById("dispFinal").innerText = "₹ " + data.finalPay;

                    document.getElementById("salarySlip").style.display = "block";
                })
                .catch(err => {
                    console.error(err);
                    if(err.message.includes("requires an index")) {
                        alert("⚠️ SYSTEM ALERT: Database Index Missing. Please check console.");
                    } else {
                        alert("Error fetching data: " + err.message);
                    }
                });
        }

        function logout(){
            auth.signOut().then(() => {
                window.location.href = "index.html";
            });
        }
    </script>
</body>
</html>