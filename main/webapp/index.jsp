<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="entity.TechlogEntity" %>
<%@ page import="jakarta.persistence.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<!DOCTYPE html>
<html>
<head>
    <%
        Date currentDate = new Date();
        SimpleDateFormat sdf = new SimpleDateFormat("MM/dd/yyyy");
        String formattedDate = sdf.format(currentDate);
    %>
    <title>Tech Log</title>
    <style>
        table, th, td {
            border: 1px solid black;
            border-collapse: collapse;
            padding: 10px;
            text-align: center;
        }
        th {
            background-color: lightgrey;
        }
    </style>
    <head>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.0/jspdf.umd.min.js" onload="initialize()" defer></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.5.23/jspdf.plugin.autotable.min.js" defer></script>
        <script>
            let jsPDF;
            function initialize() {
                jsPDF = window.jspdf.jsPDF;
            }
        </script>
    </head>
<body>
<h1>GOAA Revenue Technician Tech Log - Date: <%= formattedDate %></h1></h1>
<table>
    <tr>
        <th>Technician Number</th>
        <th>Lane Number</th>
        <th>Time Reported</th>
        <th>Start Time</th>
        <th>Stop Time</th>
        <th>Problem Reported</th>
        <th>Actual Problem</th>
        <th>Action Taken</th>
        <th>Skidata Contacted</th>
        <th>Edit</th>
        <th>Delete</th>
    </tr>
    <% EntityManagerFactory emf = Persistence.createEntityManagerFactory("default");
        EntityManager em = emf.createEntityManager();
        TypedQuery<TechlogEntity> query = em.createQuery("SELECT t FROM TechlogEntity t", TechlogEntity.class);
        List<TechlogEntity> techlogs = query.getResultList();
        for (TechlogEntity techlog : techlogs) { %>
    <tr>
        <td class="editable"><%= techlog.getTechNum() %></td>
        <td class="editable"><%= techlog.getLane() %></td>
        <td class="editable"><%= new SimpleDateFormat("HH:mm:ss").format(techlog.getReportTime()) %></td>
        <td class="editable"><%= new SimpleDateFormat("HH:mm:ss").format(techlog.getStartTime()) %></td>
        <td class="editable"><%= new SimpleDateFormat("HH:mm:ss").format(techlog.getStopTime()) %></td>
        <td class="editable"><%= techlog.getReportedProb() %></td>
        <td class="editable"><%= techlog.getActualProb() %></td>
        <td class="editable"><%= techlog.getActionTaken() %></td>
        <td class="editable"><%= techlog.getSkidata() ? "Yes" : "No" %></td>
        <td>
            <button class="edit-btn" type="button">Edit</button>
        </td>
        <td>
            <form method="POST" action="<%=request.getContextPath()%>/deleteTechlog">
                <input type="hidden" name="id" value="<%= techlog.getId() %>"/>
                <input type="submit" value="Delete"/>
            </form>
        </td>
    </tr>
    <% }
        em.close();
        emf.close(); %>
    <tr>
        <form action="submitTechlog" method="post">
            <td><input type="number" id="techNum" name="techNum" required></td>
            <td><input type="number" id="lane" name="lane" required></td>
            <td><input type="time" id="reportTime" name="reportTime" required></td>
            <td><input type="time" id="startTime" name="startTime" required></td>
            <td><input type="time" id="stopTime" name="stopTime" required></td>
            <td><input type="text" id="reportedProb" name="reportedProb" required></td>
            <td><input type="text" id="actualProb" name="actualProb" required></td>
            <td><input type="text" id="actionTaken" name="actionTaken" required></td>
            <td>
                <select id="skidata" name="skidata" required>
                    <option value="">Select</option>
                    <option value="true">Yes</option>
                    <option value="false">No</option>
                </select>
            </td>
            <td colspan="2">
                <input type="submit" value="Add"/>
            </td>
        </form>
    </tr>
</table>
<button id="saveAsPDF" type="button">Save as PDF</button>
<script>
    document.querySelectorAll('.edit-btn').forEach(function (button) {
        button.addEventListener('click', function (event) {
            let row = event.target.parentElement.parentElement;
            let fields = row.querySelectorAll('.editable');
            let isEditing = row.classList.contains('editing');
            if (isEditing) {
                let id = row.querySelector('input[name="id"]').value;
                let data = Array.from(fields).map(function (field) {
                    let input = field.querySelector('input');
                    if (input) {
                        return input.value;
                    } else {
                        return field.textContent;
                    }
                });
                let xhr = new XMLHttpRequest();
                xhr.open("POST", "<%=request.getContextPath()%>/updateTechlog", true);
                xhr.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
                xhr.onreadystatechange = function () {
                    if (xhr.readyState === 4 && xhr.status === 200) {
                        location.reload(); // Add this line to reload the page
                    }
                };
                let jsonData = {
                    id: id,
                    data: [
                        data[0], // Technician Number
                        data[1], // Lane Number
                        data[2], // Time Reported
                        data[3], // Start Time
                        data[4], // Stop Time
                        data[5], // Problem Reported
                        data[6], // Actual Problem
                        data[7], // Action Taken
                        data[8] === 'true' // Skidata Contacted
                    ]
                };

                xhr.send(JSON.stringify(jsonData));

                // Remove input elements and update text content of the fields
                fields.forEach(function (field) {
                    let input = field.querySelector('input');
                    field.textContent = input.value;
                    field.removeChild(input);
                });
                row.classList.remove('editing');
                event.target.textContent = 'Edit';
            } else {
                fields.forEach(function (field) {
                    let value = field.textContent;
                    field.textContent = '';
                    let input = document.createElement('input');
                    input.value = value;
                    field.appendChild(input);
                });
                row.classList.add('editing');
                event.target.textContent = 'Save';
            }
        });
    });
    window.onload = function() {
    document.getElementById('saveAsPDF').addEventListener('click', function () {
        const table = document.querySelector('table');
        const headers = Array.from(table.querySelectorAll('th')).map(th => th.innerText);
        const rows = Array.from(table.querySelectorAll('tr:not(:first-child)')).map(tr => Array.from(tr.querySelectorAll('td:not(:last-child):not(:nth-last-child(2))')).map(td => td.innerText));

        const doc = new jsPDF('l', 'pt', 'letter');


        doc.setFontSize(18);
        doc.text('GOAA Revenue Technician Tech Log - Date: ' + '<%= formattedDate %>', 15, 15);
        doc.autoTable({
            head: [headers.slice(0, -2)],
            body: rows,
            startY: 30,
            styles: {
                fontSize: 11
            }
        });

        const fileName = 'Tech_Log_' + '<%= formattedDate %>' + '.pdf';
        doc.save(fileName);
    });
    };
</script>
</body>
</html>