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
    </style>
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
        <td class="editable"><%= techlog.getId() %></td>
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
            <td></td>
            <td><input type="number" id="techNum" name="techNum" required></td>
            <td><input type="number" id="lane" name="lane" required></td>
            <td><input type="time" id="reportTime" name="reportTime" required></td>
            <td><input type="time" id="startTime" name="startTime" required></td>
            <td><input type="time" id="stopTime" name="stopTime" required></td>
            <td><input type="text" id="reportedProb" name="reportedProb" required></td>
            <td><input type="text" id="actualProb" name="actualProb" required></td>
            <td><input type="text" id="actionTaken" name="actionTaken" required></td>
            <td>
                <input type="radio" id="skidataYes" name="skidata" value="true" required>
                <label for="skidataYes">Yes</label>
                <input type="radio" id="skidataNo" name="skidata" value="false" required>
                <label for="skidataNo">No</label>
            </td>
            <td colspan="2">
                <input type="submit" value="Submit">
            </td>
        </form>
    </tr>

</table>
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
                        fields.forEach(function (field) {
                            let input = field.querySelector('input');
                            field.textContent = input.value;
                            field.removeChild(input);
                        });

                        row.classList.remove('editing');
                        event.target.textContent = 'Edit';
                    }
                };

                let jsonData = {
                    id: id,
                    data: data
                };
                xhr.send(JSON.stringify(jsonData));

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
</script>
</body>
</html>
