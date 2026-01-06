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
    <title>My Expenses - Synod Bioscience</title>
    
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

        /* --- 4. EXPENSE CONTENT --- */
        .content { padding: 30px; max-width: 1200px; margin: 0 auto; width: 100%; display: grid; grid-template-columns: 1fr 2fr; gap: 25px; }

        /* Form Card */
        .card { background: white; padding: 25px; border-radius: 10px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); border: 1px solid #f1f1f1; }
        
        .card-title { margin: 0 0 20px 0; font-size: 16px; font-weight: bold; color: var(--primary-navy); border-bottom: 2px solid #eee; padding-bottom: 10px; }

        label { display: block; font-size: 13px; font-weight: 600; color: #555; margin-bottom: 5px; margin-top: 15px; }
        input, select, textarea { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 6px; font-size: 14px; transition: 0.3s; box-sizing: border-box; }
        input:focus, select:focus, textarea:focus { border-color: var(--primary-navy); outline: none; }
        
        textarea { height: 80px; resize: vertical; }

        .file-upload { position: relative; display: flex; align-items: center; gap: 10px; border: 1px dashed #ccc; padding: 10px; border-radius: 6px; background: #fafafa; margin-top: 5px; }
        
        button.btn-submit { width: 100%; background: var(--primary-green); color: white; border: none; padding: 12px; border-radius: 6px; font-weight: bold; margin-top: 25px; cursor: pointer; transition: 0.2s; font-size: 15px; }
        button.btn-submit:hover { background: #27ae60; }
        button.btn-submit:disabled { background: #ccc; cursor: not-allowed; }

        /* Table Card */
        .table-responsive { overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; min-width: 500px; margin-top: 10px; }
        th { text-align: left; padding: 15px; background: #f8f9fa; color: #555; font-size: 13px; text-transform: uppercase; font-weight: 700; border-bottom: 2px solid #eee; }
        td { padding: 15px; border-bottom: 1px solid #f1f1f1; font-size: 14px; color: #333; vertical-align: middle; }
        tr:hover { background-color: #fafafa; }

        /* Badges */
        .badge { padding: 5px 12px; border-radius: 20px; font-size: 11px; font-weight: bold; color: white; display: inline-block; }
        .bg-Pending { background: #f39c12; color: white; }
        .bg-Approved { background: #3498db; }
        .bg-Paid { background: var(--primary-green); }
        .bg-Rejected { background: #e74c3c; }

        .receipt-link { color: var(--primary-navy); font-weight: 600; text-decoration: none; font-size: 12px; display: inline-flex; align-items: center; gap: 4px; }
        .receipt-link:hover { text-decoration: underline; }

        /* Loader */
        #loadingOverlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: white; z-index: 9999; display: flex; justify-content: center; align-items: center; font-size: 24px; color: #333; flex-direction: column; gap: 10px; }

        /* Responsive */
        @media (max-width: 900px) {
            .sidebar { position: fixed; left: -260px; height: 100%; width: 260px; }
            .sidebar.active { transform: translateX(260px); }
            .toggle-btn { display: block; }
            .content { grid-template-columns: 1fr; }
        }
    </style>

    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
</head>
<body>

    <div id="loadingOverlay">
        <div style="font-size: 40px; margin-bottom: 10px;">💸</div>
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
                <span id="userEmail">Loading...</span>
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
                <div id="fileHelp" style="font-size:11px; color:#888; margin-top:5px;">Max size 1MB. Clear image preferred.</div>

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
                            <tr><td colspan="6" style="text-align:center; padding:20px;">Loading records...</td></tr>
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

            // Handle File Upload (Convert to Base64 to avoid detailed storage config)
            let receiptData = null;
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
                receiptUrl: receiptUrl, // Stores Base64 string or null
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
              .limit(20) // Limit to recent 20 for performance
              .get()
              .then(snap => {
                  document.getElementById("loadingOverlay").style.display = "none";
                  tbody.innerHTML = "";
                  
                  if(snap.empty) { 
                      tbody.innerHTML = "<tr><td colspan='6' style='text-align:center; padding:20px; color:#777;'>No claims found.</td></tr>"; 
                      return; 
                  }
                  
                  let rows = "";
                  snap.forEach(doc => {
                      const d = doc.data();
                      const date = d.date ? new Date(d.date.seconds * 1000).toLocaleDateString() : "-";
                      
                      // Status Color Logic
                      let status = d.status || "Pending";
                      // Normalize case
                      status = status.charAt(0).toUpperCase() + status.slice(1);
                      
                      // Receipt Link
                      let receiptHtml = "<span style='color:#ccc; font-size:12px;'>No File</span>";
                      if(d.receiptUrl) {
                          receiptHtml = "<a href='" + d.receiptUrl + "' target='_blank' class='receipt-link'>📎 View</a>";
                      }

                      rows += "<tr>";
                      rows += "<td>" + date + "</td>";
                      rows += "<td>" + d.type + "</td>";
                      rows += "<td>" + d.description + "</td>";
                      rows += "<td><b>₹" + d.amount + "</b></td>";
                      rows += "<td>" + receiptHtml + "</td>";
                      rows += "<td><span class='badge bg-" + status + "'>" + status + "</span></td>";
                      rows += "</tr>";
                  });
                  tbody.innerHTML = rows;
              })
              .catch(error => {
                  console.error("Error loading expenses:", error);
                  if(error.message.includes("requires an index")) {
                      alert("⚠️ Missing Index. Please create it in Firebase Console.");
                  }
                  tbody.innerHTML = "<tr><td colspan='6' style='text-align:center; color:red;'>Error loading data.</td></tr>";
              });
        }

        function logout(){ auth.signOut().then(() => location.href = "index.html"); }
    </script>
</body>
</html>