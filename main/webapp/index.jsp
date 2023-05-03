<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="entity.TechlogEntity" %>
<%@ page import="jakarta.persistence.*" %>
<!DOCTYPE html>
<html>
<head>
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
        .form-container {
            display: flex;
            justify-content: space-between;
            flex-wrap: wrap;
            align-items: center;
            margin-bottom: 15px;
        }
        .form-container label {
            margin-right: 5px;
        }
        input[type="number"]#techNum {
            width: 12ch;
        }
        input[type="text"].small {
            width: 150px;
        }
        input[type="text"].medium {
            width: 250px;
        }
    </style>

    <script>
        document.addEventListener("DOMContentLoaded", function() {
            const deleteButtons = document.querySelectorAll(".delete-btn");
            deleteButtons.forEach((btn) => {
                btn.addEventListener("click", async function() {
                    const id = btn.getAttribute("data-id");
                    const formData = new FormData();
                    formData.append('id', id);
                    const response = await fetch("/deleteTechlog", {

                        method: "POST",
                        body: formData
                    });


                    const result = await response.text();
                    if (result === "success") {
                        btn.closest("tr").remove();
                    } else {
                        alert("An error occurred. Please try again.");
                    }
                });
            });
        });
    </script>


</head>
<body>
<h1>GOAA Revenue Technician Tech Log</h1>
<table>
    <tr>
        <th>ID</th>
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
        <td><%= techlog.getId() %></td>
        <td class="editable"><%= techlog.getTechNum() %></td>
        <td class="editable"><%= techlog.getLane() %></td>
        <td class="editable"><%= techlog.getReportTime() %></td>
        <td class="editable"><%= techlog.getStartTime() %></td>
        <td class="editable"><%= techlog.getStopTime() %></td>
        <td class="editable"><%= techlog.getReportedProb() %></td>
        <td class="editable"><%= techlog.getActualProb() %></td>
        <td class="editable"><%= techlog.getActionTaken() %></td>
        <td class="editable"><%= techlog.getSkidata() ? "Yes" : "No" %></td>
        <td>
            <button class="edit-btn" type="button">Edit</button>
        </td>
        <td>
            <button class="delete-btn" type="button" data-id="<%= techlog.getId() %>">Delete</button>

        </td>
    </tr>
        <% }
        em.close();
        emf.close(); %>
    <tr>
        <form action="submitTechlog" method="post">
            <td></td>
            <td><input type="number" id="techNum" name="techNum" required></td>
            <td><input type="number" id="lane" name="lane" required></td>
            <td><input type="time" id="reportTime" name="reportTime" required></td>
            <td><input type="time" id="startTime" name="startTime" required></td>
            <td><input type="time" id="stopTime" name="stopTime" required></td>
            <td><input type="text" id="reportedProb" name="reportedProb" class="small" required></td>
            <td><input type="text" id="actualProb" name="actualProb" class="small" required></td>
            <td><input type="text" id="actionTaken" name="actionTaken" class="medium" required></td>
            <td><input type="checkbox" id="skidata" name="skidata"></td>
            <td><input type="submit" value="Submit"></td>
            <td></td>
        </form>
    </tr>
</table>
<script>
    document.querySelectorAll('.edit-btn').forEach((btn, index) => {
        btn.addEventListener('click', () => {
            const row = btn.closest('tr');
            row.querySelectorAll('.editable').forEach(cell => {
                const input = document.createElement('input');
                input.value = cell.innerText;
                cell.innerText = '';
                cell.appendChild(input);
            });
            btn.innerText = 'Save';
            btn.removeEventListener('click', arguments.callee);
            btn.addEventListener('click', () => {
                row.querySelectorAll('.editable').forEach(cell => {
                    const input = cell.querySelector('input');
                    cell.innerText = input.value;
                });
                btn.innerText = 'Edit';
                btn.removeEventListener('click', arguments.callee);
                btn.addEventListener('click', arguments.callee.caller);
            });
            btn.addEventListener('click', () => {
                const id = row.querySelector('.delete-btn').getAttribute('data-id');
                const data = new FormData();
                data.append('id', id);

                row.querySelectorAll('.editable').forEach((cell, i) => {
                    const input = cell.querySelector('input');
                    const paramName = input.getAttribute('name');
                    data.append(paramName, input.value);
                });

                fetch('updateTechlog', {
                    method: 'POST',
                    body: data
                }).then(response => {
                    if (response.ok) {
                        row.querySelectorAll('.editable').forEach(cell => {
                            const input = cell.querySelector('input');
                            cell.innerText = input.value;
                        });
                        btn.innerText = 'Edit';
                        btn.removeEventListener('click', arguments.callee);
                        btn.addEventListener('click', arguments.callee.caller);
                    } else {
                        alert('An error occurred. Please try again.');
                    }
                }).catch(error => {
                    console.error('Error:', error);
                    alert('An error occurred. Please try again.');
                });
            });

        });
    });
</script>
</body>
</html>



