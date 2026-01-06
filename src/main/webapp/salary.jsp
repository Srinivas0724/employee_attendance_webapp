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
    <title>My Salary - Synod Bioscience</title>
    
    <style>
        /* --- 1. RESET & VARS --- */
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        
        :root {
            --primary-navy: #1a3b6e;
            --primary-green: #2ecc71;
            --bg-light: #f4f6f9;
            --text-dark: #333;
            --text-grey: #666;
            --sidebar-width: 260px;
            --border-color: #eee;
        }

        body { display: flex; height: 100vh; background-color: var(--bg-light); overflow: hidden; }

        /* --- 2. SIDEBAR --- */
        .sidebar {
            width: var(--sidebar-width);
            background-color: var(--primary-navy);
            color: white;
            display: flex;
            flex-direction: column;
            transition: transform 0.3s ease-in-out;
            flex-shrink: 0;
            z-index: 1000;
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
            position: relative;
        }

        /* Top Bar */
        .topbar {
            background: white;
            height: 60px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            position: sticky; top: 0; z-index: 100;
        }

        .toggle-btn { display: none; font-size: 24px; cursor: pointer; color: var(--primary-navy); margin-right: 15px; }
        .page-title { font-size: 18px; font-weight: bold; color: var(--primary-navy); }
        .user-profile { font-size: 14px; color: var(--text-grey); display: flex; align-items: center; gap: 10px; }
        .user-avatar { width: 35px; height: 35px; background: #e0e0e0; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: bold; color: var(--primary-navy); }

        /* --- 4. SALARY CONTENT --- */
        .content { padding: 30px; max-width: 900px; margin: 0 auto; width: 100%; display: flex; flex-direction: column; align-items: center; gap: 20px; }

        /* Controls Bar */
        .controls-card {
            background: white; padding: 20px; border-radius: 10px; 
            box-shadow: 0 4px 6px rgba(0,0,0,0.05); width: 100%;
            display: flex; gap: 15px; align-items: center; justify-content: center;
            flex-wrap: wrap;
        }
        
        select { padding: 10px; border: 1px solid #ddd; border-radius: 6px; font-size: 14px; min-width: 150px; }
        
        .btn-view { 
            background: var(--primary-navy); color: white; border: none; padding: 10px 25px; 
            border-radius: 6px; cursor: pointer; font-weight: bold; font-size: 14px; 
            transition: 0.2s;
        }
        .btn-view:hover { background: #132c52; }

        /* Salary Slip */
        .salary-slip {
            background: white; width: 100%; max-width: 700px;
            padding: 40px; border-radius: 8px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.08);
            display: none; border: 1px solid #eee;
            position: relative;
        }

        .slip-header { text-align: center; border-bottom: 2px solid var(--primary-navy); padding-bottom: 20px; margin-bottom: 30px; }
        .slip-header h2 { margin: 0; color: var(--primary-navy); text-transform: uppercase; letter-spacing: 1px; }
        .company-name { font-size: 14px; color: #777; margin-top: 5px; font-weight: 600; }
        
        .emp-details { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 30px; background: #f8f9fa; padding: 15px; border-radius: 6px; font-size: 14px; }
        .emp-details div b { color: #555; }

        .salary-table { width: 100%; border-collapse: collapse; margin-bottom: 20px; }
        .salary-table th { text-align: left; padding: 10px; border-bottom: 1px solid #ddd; color: #555; font-size: 13px; text-transform: uppercase; }
        .salary-table td { padding: 12px 10px; border-bottom: 1px solid #f1f1f1; font-size: 14px; }
        .salary-table tr:last-child td { border-bottom: none; }
        
        .amount-col { text-align: right; font-weight: 600; }
        .text-green { color: #27ae60; }
        .text-red { color: #e74c3c; }

        .total-row { 
            background: var(--primary-navy); color: white; 
            padding: 15px; border-radius: 6px; display: flex; 
            justify-content: space-between; align-items: center;
            font-size: 18px; font-weight: bold; margin-top: 20px;
        }

        .btn-print { 
            background: var(--primary-green); color: white; border: none; padding: 12px 30px; 
            border-radius: 50px; cursor: pointer; font-weight: bold; margin-top: 30px; 
            display: block; margin-left: auto; margin-right: auto;
            box-shadow: 0 4px 10px rgba(46, 204, 113, 0.3); transition: 0.2s;
        }
        .btn-print:hover { transform: translateY(-2px); box-shadow: 0 6px 15px rgba(46, 204, 113, 0.4); }

        .no-data { text-align: center; color: #999; margin-top: 50px; font-style: italic; }

        /* Loader */
        #loadingOverlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: white; z-index: 9999; display: flex; justify-content: center; align-items: center; font-size: 24px; color: #333; flex-direction: column; gap: 10px; }

        /* Print Styles */
        @media print {
            body * { visibility: hidden; }
            .salary-slip, .salary-slip * { visibility: visible; }
            .salary-slip { position: absolute; left: 0; top: 0; width: 100%; box-shadow: none; border: 2px solid #333; margin: 0; padding: 20px; }
            .btn-print { display: none; }
        }

        /* Mobile Responsive */
        @media (max-width: 900px) {
            .sidebar { position: fixed; left: -260px; height: 100%; width: 260px; }
            .sidebar.active { transform: translateX(260px); }
            .toggle-btn { display: block; }
            .emp-details { grid-template-columns: 1fr; }
        }
    </style>

    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
</head>
<body>

    <div id="loadingOverlay">
        <div style="font-size: 40px; margin-bottom: 10px;">💰</div>
        <div>Loading Profile...</div>
    </div>

    <nav class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <img src="synod_logo.png" alt="Synod Logo" class="sidebar-logo">
            <div class="sidebar-brand">EMPLOYEE PORTAL</div>
        </div>

        <ul class="nav-menu">
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
                <span id="userEmail">Loading...</span>
                <div class="user-avatar">E</div>
            </div>
        </header>

        <div class="content">
            
            <div class="controls-card">
                <label>Select Period:</label>
                <select id="monthSelect"></select>
                <select id="yearSelect">
                    <option value="2024">2024</option>
                    <option value="2025" selected>2025</option>
                    <option value="2026">2026</option>
                </select>
                <button onclick="fetchSalary()" class="btn-view">🔍 View Payslip</button>
            </div>

            <div id="noDataMsg" class="no-data">Select a month above to view your payslip.</div>

            <div id="salarySlip" class="salary-slip">
                <div class="slip-header">
                    <h2>Salary Slip</h2>
                    <div class="company-name" id="dispCompany">Synod Bioscience</div>
                    <p style="margin: 10px 0 0 0; color:#555;">Payslip for the month of <b id="dispMonth"></b></p>
                </div>

                <div class="emp-details">
                    <div><b>Employee Name:</b> <br><span id="dispName">-</span></div>
                    <div><b>Employee ID / Email:</b> <br><span id="dispEmail">-</span></div>
                    <div><b>Days Present:</b> <br><span id="dispDays">-</span></div>
                    <div><b>Payment Date:</b> <br><span id="dispDate">-</span></div>
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
                        alert("⚠️ SYSTEM ALERT: Database Index Missing. Please create it in Firebase Console.");
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