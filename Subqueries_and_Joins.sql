--Subqueries and Joins

--1.	Employee Address

USE SoftUni

 SELECT TOP (5) 
        e.EmployeeId,
        e.JobTitle,
        e.AddressId,
        a.AddressText
 FROM Employees AS e
 JOIN Addresses AS a 
 ON e.AddressID = a.AddressID
 ORDER BY e.AddressID

 --2.	Addresses with Towns
  SELECT TOP (50)
         e.FirstName,
         e.LastName,
		 t.Name AS Town,
		 a.AddressText
    FROM Employees e
	JOIN Addresses a ON e.AddressID = a.AddressID
	JOIN Towns t ON a.TownID = t.TownID
	ORDER BY e.FirstName, e.LastName

	--3.	Sales Employee
	SELECT  e.EmployeeID,
	        e.FirstName,
            e.LastName,
			d.Name AS DepartmentName
	  FROM Employees e
	  JOIN Departments d ON e.DepartmentID = d.DepartmentID
	  WHERE d.Name= 'Sales'
	  ORDER BY EmployeeID

	-- 4.Employee Departments
	SELECT  TOP(5)
			e.EmployeeID,
	        e.FirstName,
			Salary,
			d.Name AS DepartmentName
	FROM Employees e
	JOIN Departments d ON e.DepartmentID = d.DepartmentID
	WHERE Salary > 15000
	ORDER BY e.DepartmentID

	--5.	Employees Without Project

	SELECT TOP(3)
	    e.EmployeeID,
        FirstName
		FROM Employees e
		LEFT JOIN EmployeesProjects ep ON e.EmployeeID = ep.EmployeeID
		WHERE ep.EmployeeID IS NULL
		ORDER BY e.EmployeeID

--6.	Employees Hired After
SELECT FirstName,
       LastName,
       HireDate,
       d.Name AS DeptName
	FROM Employees e
	JOIN Departments d ON d.DepartmentID = e.DepartmentID
	WHERE  HireDate > '1-1-1999' AND d.Name IN ('Sales','Finance')
	ORDER BY HireDate

--7.	Employees with Project

	SELECT TOP(5) 
	    e.EmployeeID,
        e.FirstName,
		p.Name AS ProjectName
	FROM Employees e
	JOIN EmployeesProjects ep ON ep.EmployeeID = e.EmployeeID
	JOIN Projects p ON p.ProjectID =ep.ProjectID
	WHERE p.StartDate > '08-13-2002' AND p.EndDate IS NULL
	ORDER BY e.EmployeeID

	--8.	Employee 24
	SELECT e.EmployeeID,
           e.FirstName,
		   CASE
			WHEN DATEPART(YEAR, p.StartDate) >='2005' THEN NULL
			ELSE p.Name
		   END AS ProjectName
	FROM Employees e
	FULL JOIN EmployeesProjects ep ON ep.EmployeeID = e.EmployeeID
	FULL JOIN Projects p ON p.ProjectID =ep.ProjectID
	WHERE e.EmployeeID = 24 

	--9.	Employee Manager
	SELECT emp.EmployeeID,
		   emp.FirstName,
		   emp.ManagerID,
		   mng.FirstName
	FROM Employees emp
	JOIN Employees mng ON emp.ManagerID = mng.EmployeeID
	WHERE emp.ManagerID IN (3,7)
	ORDER BY emp.EmployeeID

	--10. Employee Summary
	SELECT TOP(50) 
	        e.EmployeeID,
			e.FirstName + ' ' + e.LastName  AS EmployeeName, 
			mng.FirstName + ' ' + mng.LastName AS  ManagerName,
			d.Name AS DepartmentName
	FROM Employees e
	JOIN Departments d ON d.DepartmentID = e.DepartmentID
	JOIN Employees mng ON e.ManagerID = mng.EmployeeID
	ORDER BY e.EmployeeID

	--11. Min Average Salary
	SELECT TOP(1) AVG(Salary) AS AverageSalary
	FROM Employees e
	JOIN Departments AS d ON d.DepartmentID = e.DepartmentID
	GROUP BY e.DepartmentID
	ORDER BY AverageSalary

	--12. Highest Peaks in Bulgaria
	USE Geography

	SELECT mc.CountryCode, m.MountainRange,PeakName, Elevation 
	FROM Peaks p
	JOIN MountainsCountries mc ON mc.MountainId = p.MountainId
	JOIN Mountains m ON m.Id = p.MountainId
	WHERE mc.CountryCode = 'BG' AND Elevation > 2835
	ORDER BY Elevation DESC

	--13. Count Mountain Ranges
	SELECT c.CountryCode, COUNT(*)
	  FROM Countries c
	  JOIN MountainsCountries mc ON mc.CountryCode = c.CountryCode
	WHERE c.CountryCode IN ('BG', 'US', 'RU')
	GROUP BY c.CountryCode

	--14. Countries with Rivers
	SELECT TOP(5) CountryName, RiverName
	FROM Countries c
	LEFT JOIN CountriesRivers cr ON cr.CountryCode = c.CountryCode
	LEFT JOIN Rivers r ON r.Id = cr.RiverId
	WHERE c.ContinentCode = 'AF'
	ORDER BY CountryName