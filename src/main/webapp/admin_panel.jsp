<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Admin Panel v2</title>
    <style>
        body { margin: 0; font-family: 'Segoe UI', sans-serif; background-color: #f4f6f9; display: flex; height: 100vh; }
        
        /* Sidebar */
        .sidebar { width: 250px; background-color: #212529; color: #fff; display: flex; flex-direction: column; }
        .sidebar-header { padding: 20px; font-size: 1.2rem; font-weight: bold; border-bottom: 1px solid #3d4046; }
        .nav-link { display: block; padding: 15px 20px; color: #adb5bd; text-decoration: none; border-left: 4px solid transparent; }
        .nav-link:hover, .nav-link.active { background-color: #343a40; color: #fff; border-left-color: #0d6efd; }
        
        /* Main Content */
        .main-content { flex: 1; display: flex; flex-direction: column; overflow: hidden; }
        .top-bar { background: #fff; padding: 15px 30px; border-bottom: 1px solid #dee2e6; display: flex; justify-content: space-between; align-items: center; }
        .container { padding: 30px; overflow-y: auto; }
        
        /* Table Card */
        .card { background: #fff; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); overflow: hidden; }
        .card-header { padding: 20px; border-bottom: 1px solid #eee; font-weight: bold; color: #333; }
        
        table { width: 100%; border-collapse: collapse; }
        th { background: #f8f9fa; padding: 15px; text-align: left; font-size: 13px; text-transform: uppercase; color: #666; border-bottom: 2px solid #dee2e6; }
        td { padding: 15px; border-bottom: 1px solid #eee; color: #444; vertical-align: middle; }
        
        /* Status Badges */
        .badge { padding: 5px 10px; border-radius: 4px; font-size: 12px; font-weight: bold; }
        .badge-IN { background-color: #d1e7dd; color: #0f5132; }
        .badge-OUT { background-color: #f8d7da; color: #842029; }
        
        /* Images */
        .selfie-thumb { width: 40px; height: 40px; border-radius: 50%; object-fit: cover; border: 1px solid #ddd; background: #eee; }
    </style>

    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
</head>
<body onload="loadData()">

    <div class="sidebar">
        <div class="sidebar-header">🛡️ Admin Panel</div>
        <a href="#" class="nav-link active">📊 Live Attendance</a>
        <a href="admin_tasks.jsp" class="nav-link">📝 Tasks</a>
        <a href="#" class="nav-link">⚙️ Settings</a>
    </div>

    <div class="main-content">
        <div class="top-bar">
            <div><strong>Dashboard</strong></div>
            <div style="font-size: 14px; color: #666;">Administrator</div>
        </div>

        <div class="container">
            <div class="card">
                <div class="card-header">Live Attendance Feed</div>
                <table>
                    <thead>
                        <tr>
                            <th width="80">Photo</th>
                            <th>Employee</th>
                            <th>Status</th>
                            <th>Project</th>
                            <th>Time</th>
                            <th>Location</th>
                        </tr>
                    </thead>
                    <tbody id="tableBody">
                        <tr><td colspan="6" style="text-align:center; padding:20px;">Loading data...</td></tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <script>
        const firebaseConfig = {
            apiKey: "AIzaSyCV5tKJMLOVcXiZUyuJZhLWOOSD96gsmP0",
            authDomain: "attendencewebapp-4215b.firebaseapp.com",
            projectId: "attendencewebapp-4215b",
            storageBucket: "attendencewebapp-4215b.firebasestorage.app",
            messagingSenderId: "97124588288",
            appId: "1:97124588288:web:08507eaacdc6155ad1b1e5"
        };
        
        if (!firebase.apps.length) firebase.initializeApp(firebaseConfig);
        const db = firebase.firestore();

        function loadData() {
            const tbody = document.getElementById("tableBody");
            
            // Getting data WITHOUT orderBy to avoid index issues
            db.collection("attendance_2025").get().then(snap => {
                
                if (snap.empty) {
                    tbody.innerHTML = "<tr><td colspan='6' style='text-align:center;'>No records found.</td></tr>";
                    return;
                }

                // USE AN ARRAY - prevents the "false" string error
                let rows = [];

                snap.forEach(doc => {
                    const d = doc.data();
                    
                    // 1. SAFE VARIABLES (Use default if missing)
                    const name = d.userName || d.email || "Unknown";
                    const email = d.email || "";
                    const project = d.project || "-"; // Default to dash, NOT false
                    const type = d.type || "N/A";
                    
                    // 2. TIME
                    let timeStr = "Unknown";
                    if(d.timestamp) {
                        timeStr = new Date(d.timestamp.seconds * 1000).toLocaleString();
                    }

                    // 3. PHOTO
                    let imgHtml = `<div class="selfie-thumb" style="display:flex;align-items:center;justify-content:center;font-size:10px;">No Pic</div>`;
                    if(d.photo) {
                        imgHtml = `<img src="${d.photo}" class="selfie-thumb">`;
                    }

                    // 4. MAP
                    let mapHtml = `<span style="color:#999">No GPS</span>`;
                    if(d.location && d.location.lat) {
                        mapHtml = `<a href="https://maps.google.com/?q=${d.location.lat},${d.location.lng}" target="_blank" style="color:#0d6efd;font-weight:bold;text-decoration:none;">View Map 📍</a>`;
                    }

                    // 5. BUILD ROW
                    rows.push(`
                        <tr>
                            <td>${imgHtml}</td>
                            <td>
                                <div style="font-weight:bold; color:#333;">${name}</div>
                                <div style="font-size:12px; color:#888;">${email}</div>
                            </td>
                            <td><span class="badge badge-${type}">${type}</span></td>
                            <td>${project}</td>
                            <td style="font-size:13px;">${timeStr}</td>
                            <td>${mapHtml}</td>
                        </tr>
                    `);
                });

                // JOIN ARRAY INTO STRING
                tbody.innerHTML = rows.join("");

            }).catch(error => {
                console.error(error);
                tbody.innerHTML = `<tr><td colspan='6' style='color:red;text-align:center;'>Error: ${error.message}</td></tr>`;
            });
        }
    </script>
</body>
</html>