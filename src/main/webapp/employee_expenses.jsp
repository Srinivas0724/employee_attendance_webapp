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
    <title>My Expenses - Employee Portal</title>
    
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

        /* --- 4. EXPENSE CONTENT --- */
        .content { 
            padding: 40px; 
            max-width: 1400px; 
            margin: 0 auto; 
            width: 100%; 
            display: grid; 
            grid-template-columns: 1fr 1.5fr; 
            gap: 30px; 
        }

        /* Form Card */
        .card { 
            background: white; 
            padding: 30px; 
            border-radius: 16px; 
            box-shadow: var(--card-shadow); 
            border-top: 4px solid var(--primary-navy);
        }
        
        .card-title { 
            margin: 0 0 25px 0; 
            font-size: 18px; 
            font-weight: 700; 
            color: var(--primary-navy); 
            border-bottom: 1px solid #f1f1f1; 
            padding-bottom: 15px; 
        }

        /* Forms */
        label { 
            font-weight: 600; font-size: 13px; color: var(--text-dark); 
            display: block; margin-bottom: 8px; margin-top: 20px; 
            text-transform: uppercase; letter-spacing: 0.5px;
        }
        
        input, select, textarea { 
            width: 100%; padding: 14px; 
            border: 1px solid #e0e0e0; border-radius: 8px; 
            box-sizing: border-box; font-size: 14px; 
            transition: all 0.3s; background: #fdfdfd;
        }
        
        input:focus, select:focus, textarea:focus { 
            border-color: var(--primary-navy); outline: none; background: white; 
            box-shadow: 0 0 0 3px rgba(26, 59, 110, 0.1);
        }
        
        textarea { height: 100px; resize: vertical; }

        .file-upload { 
            position: relative; display: flex; align-items: center; 
            gap: 10px; border: 2px dashed #d1d5db; padding: 20px; 
            border-radius: 10px; background: #fafafa; margin-top: 8px; 
            transition: 0.2s;
        }
        .file-upload:hover { border-color: var(--primary-navy); background: #f0f4f8; }

        button.btn-submit { 
            width: 100%; background: var(--primary-green); color: white; 
            border: none; padding: 14px; border-radius: 8px; font-weight: 700; 
            margin-top: 30px; cursor: pointer; transition: all 0.2s; font-size: 14px;
            box-shadow: 0 4px 10px rgba(46, 204, 113, 0.3);
        }
        button.btn-submit:hover { background: #27ae60; transform: translateY(-2px); }
        button.btn-submit:disabled { background: #cbd5e1; cursor: not-allowed; box-shadow: none; }

        /* Table Card */
        .table-responsive { overflow-x: auto; max-height: 600px; }
        
        table { width: 100%; border-collapse: separate; border-spacing: 0; min-width: 600px; }
        
        th { 
            background: #f8f9fa; color: var(--text-grey); padding: 15px; 
            text-align: left; font-size: 12px; text-transform: uppercase; 
            letter-spacing: 0.5px; border-bottom: 2px solid #eee; font-weight: 700;
        }
        
        td { 
            padding: 15px; border-bottom: 1px solid #f1f1f1; 
            color: var(--text-dark); font-size: 14px; vertical-align: middle; 
        }
        tr:hover td { background: #fcfcfc; }

        /* Badges */
        .badge { padding: 6px 12px; border-radius: 20px; font-size: 11px; font-weight: 700; display: inline-block; }
        .bg-Pending { background: #fff7ed; color: #c2410c; border: 1px solid #ffedd5; }
        .bg-Approved { background: #eff6ff; color: #1d4ed8; border: 1px solid #dbeafe; }
        .bg-Paid { background: #f0fdf4; color: #15803d; border: 1px solid #dcfce7; }
        .bg-Rejected { background: #fef2f2; color: #b91c1c; border: 1px solid #fee2e2; }

        .receipt-link { 
            color: var(--primary-navy); font-weight: 600; text-decoration: none; 
            font-size: 12px; display: inline-flex; align-items: center; gap: 5px; 
            background: rgba(26, 59, 110, 0.05); padding: 6px 12px; border-radius: 6px; 
            transition: 0.2s;
        }
        .receipt-link:hover { background: rgba(26, 59, 110, 0.1); }

        #loadingOverlay { 
            position: fixed; top: 0; left: 0; width: 100%; height: 100%; 
            background: rgba(255,255,255,0.9); backdrop-filter: blur(5px);
            z-index: 9999; display: flex; justify-content: center; align-items: center; 
            font-size: 24px; color: var(--primary-navy); flex-direction: column; gap: 15px; font-weight: 600;
        }

        @media (max-width: 900px) {
            .sidebar { position: fixed; left: -280px; height: 100%; }
            .sidebar.active { transform: translateX(280px); }
            .content { padding: 20px; grid-template-columns: 1fr; }
            .topbar { padding: 0 20px; }
            .toggle-btn { display: block; font-size: 24px; cursor: pointer; margin-right: 15px; }
        }
    </style>

    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
</head>
<body>

    <div id="loadingOverlay">
        <div style="font-size: 50px;">💸</div>
        <div>Loading Expenses...</div>
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
                <a href="employee_expenses.jsp" class="active"><span class="nav-icon">💸</span> My Expenses</a>
            </li>
            <li class="nav-item">
                <a href="salary.jsp"><span class="nav-icon">💰</span> My Salary</a>
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
                <div class="page-title">Expense Management</div>
            </div>
            <div class="user-profile">
                <span id="userEmail" class="user-email">Loading...</span>
                <div class="user-avatar">E</div>
            </div>
        </header>

        <div class="content">
            
            <div class="card">
                <h3 class="card-title">📝 Submit New Claim</h3>
                
                <label>Expense Type</label>
                <select id="expType">
                    <option>Travel</option>
                    <option>Food & Meals</option>
                    <option>Office Supplies</option>
                    <option>Equipment</option>
                    <option>Medical</option>
                    <option>Other</option>
                </select>
                
                <label>Amount (₹)</label>
                <input type="number" id="expAmount" placeholder="0.00" min="0">
                
                <label>Description / Purpose</label>
                <textarea id="expDesc" placeholder="Briefly describe the expense..."></textarea>
                
                <label>Upload Receipt (Image/PDF)</label>
                <div class="file-upload">
                    <input type="file" id="receiptFile" accept="image/*,application/pdf">
                </div>
                <div style="font-size:12px; color:var(--text-grey); margin-top:5px; margin-left:5px;">Max size 1MB. Clear image preferred.</div>

                <button onclick="addExpense()" id="submitBtn" class="btn-submit">Submit Claim</button>
            </div>

            <div class="card">
                <h3 class="card-title">🕒 Recent Claims History</h3>
                <div class="table-responsive">
                    <table id="expTable">
                        <thead>
                            <tr>
                                <th>Date</th>
                                <th>Type</th>
                                <th>Details</th>
                                <th>Amount</th>
                                <th>Receipt</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody id="tableBody">
                            <tr><td colspan="6" style="text-align:center; padding:30px; color:#999;">Loading records...</td></tr>
                        </tbody>
                    </table>
                </div>
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

        // --- 2. AUTH CHECK ---
        auth.onAuthStateChanged(user => {
            if (user) {
                document.getElementById("userEmail").innerText = user.email;
                loadExpenses(user.email);
            } else {
                window.location.replace("index.html");
            }
        });

        function toggleSidebar() {
            document.getElementById("sidebar").classList.toggle("active");
        }

        // --- 3. SUBMIT EXPENSE ---
        function addExpense() {
            const user = auth.currentUser;
            const type = document.getElementById("expType").value;
            const amount = document.getElementById("expAmount").value;
            const desc = document.getElementById("expDesc").value;
            const fileInput = document.getElementById("receiptFile");
            const btn = document.getElementById("submitBtn");

            if(!amount) { alert("Please enter the amount."); return; }
            if(!desc) { alert("Please enter a description."); return; }

            btn.innerText = "Processing...";
            btn.disabled = true;

            // Handle File Upload (Convert to Base64)
            if(fileInput.files.length > 0) {
                const file = fileInput.files[0];
                if(file.size > 1024 * 1024) { // 1MB Limit
                    alert("File too large. Please upload an image under 1MB.");
                    btn.innerText = "Submit Claim";
                    btn.disabled = false;
                    return;
                }
                
                const reader = new FileReader();
                reader.onload = function(e) {
                    saveToFirestore(user.email, type, amount, desc, e.target.result);
                };
                reader.readAsDataURL(file);
            } else {
                saveToFirestore(user.email, type, amount, desc, null);
            }
        }

        function saveToFirestore(email, type, amount, desc, receiptUrl) {
            db.collection("expenses").add({
                email: email,
                type: type,
                amount: parseFloat(amount),
                description: desc,
                receiptUrl: receiptUrl,
                status: "Pending",
                date: firebase.firestore.FieldValue.serverTimestamp()
            }).then(() => {
                alert("✅ Expense submitted successfully!");
                location.reload();
            }).catch(err => {
                alert("Error: " + err.message);
                document.getElementById("submitBtn").innerText = "Submit Claim";
                document.getElementById("submitBtn").disabled = false;
            });
        }

        // --- 4. LOAD DATA ---
        function loadExpenses(email) {
            const tbody = document.getElementById("tableBody");
            
            db.collection("expenses")
              .where("email", "==", email)
              .orderBy("date", "desc")
              .limit(20)
              .get()
              .then(snap => {
                  document.getElementById("loadingOverlay").style.display = "none";
                  tbody.innerHTML = "";
                  
                  if(snap.empty) { 
                      tbody.innerHTML = "<tr><td colspan='6' style='text-align:center; padding:30px; color:#999;'>No claims found.</td></tr>"; 
                      return; 
                  }
                  
                  let rows = "";
                  snap.forEach(doc => {
                      const d = doc.data();
                      const date = d.date ? new Date(d.date.seconds * 1000).toLocaleDateString() : "-";
                      
                      let status = d.status || "Pending";
                      status = status.charAt(0).toUpperCase() + status.slice(1);
                      
                      let receiptHtml = "<span style='color:#ccc; font-size:12px;'>No File</span>";
                      if(d.receiptUrl) {
                          receiptHtml = "<a href='" + d.receiptUrl + "' target='_blank' class='receipt-link'>📎 View</a>";
                      }

                      rows += "<tr>";
                      rows += "<td>" + date + "</td>";
                      rows += "<td>" + d.type + "</td>";
                      rows += "<td>" + d.description + "</td>";
                      rows += "<td><b style='color:var(--primary-navy)'>₹" + d.amount + "</b></td>";
                      rows += "<td>" + receiptHtml + "</td>";
                      rows += "<td><span class='badge bg-" + status + "'>" + status + "</span></td>";
                      rows += "</tr>";
                  });
                  tbody.innerHTML = rows;
              })
              .catch(error => {
                  console.error("Error loading expenses:", error);
                  if(error.message.includes("requires an index")) {
                      alert("⚠️ System Notification:\nThe database requires a one-time index configuration for sorting.\nPlease check the browser console for the link.");
                  }
                  tbody.innerHTML = "<tr><td colspan='6' style='text-align:center; color:red;'>Error loading data.</td></tr>";
              });
        }

        function logout(){ auth.signOut().then(() => location.href = "index.html"); }
        function toggleSidebar() { document.getElementById("sidebar").classList.toggle("open"); }
    </script>
</body>
</html>