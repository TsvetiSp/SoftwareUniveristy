--Find Names of All employees by Last Name 
Use SoftUni

  SELECT [FirstName], 
         [LastName]
 FROM Employees
 WHERE LastName LIKE '%ei%'

--Problem 3.	Find First Names of All Employees

SELECT [FirstName] 
  FROM Employees
WHERE ([DepartmentID] = 10 OR 
       [DepartmentID] = 3) AND 
	   [HireDate] BETWEEN '1995' AND '2006'

--Problem 4.	Find All Employees Except Engineers

SELECT [FirstName], 
       [LastName] 
  FROM Employees
WHERE [JobTitle] NOT LIKE '%engineer%'

--Problem 5.	Find Towns with Name Length

SELECT [Name] 
  FROM Towns
WHERE LEN(Name) =5 OR LEN(Name) =6
  ORDER BY Name ASC

--Find Towns Starting With

SELECT TownId, 
       [Name] 
	FROM Towns
WHERE Name LIKE '[M, B, K, E]%'
ORDER BY [Name]

--Find Towns Not Starting With

SELECT TownId, 
       Name 
	FROM Towns
WHERE Name NOT LIKE '[R, B, D]%'
ORDER BY Name

--Problem 8.	Create View Employees Hired After 2000 Year
go
CREATE VIEW V_EmployeesHiredAfter2000
AS
SELECT FirstName, LastName
 FROM Employees
WHERE DATEPART(YEAR, HireDate) > 2000

--Problem 9.	Length of Last NamE

  SELECT FirstName, LastName
   FROM Employees
WHERE LEN(LastName) = 5

--Rank Employees by Salary

 SELECT * FROM 
 (
  SELECT EmployeeID,
		 FirstName,
		 LastName,
		 Salary,
DENSE_RANK() OVER (PARTITION BY Salary Order BY EmployeeID) AS [Rank]
FROM Employees
WHERE Salary BETWEEN 10000 and 50000
) 
AS Result
WHERE Rank= 2
ORDER BY Salary DESC

--Problem 12.	Countries Holding ‘A’ 3 or More Times
use Geography

  SELECT CountryName, IsoCode 
   FROM Countries
  WHERE CountryName LIKE '%a%a%a%'
ORDER BY IsoCode 

--Mix of Peak and River Names

  SELECT PeakName, RiverName, LOWER(LEFT(PeakName, LEN(PeakName)-1) + RiverName) AS Mix
   FROM Peaks, Rivers
  WHERE RIGHT(PeakName, 1) = LEFT(RiverName, 1) 
  ORDER BY Mix

  --Problem 14.	Games from 2011 and 2012 year
  use Diablo

  SELECT TOP(50) [Name], FORMAT([Start], 'yyyy-MM-dd') AS [Start]
    FROM Games
  WHERE DATEPART(YEAR,[Start]) BETWEEN 2011 AND 2012
 ORDER BY [Start], [Name]


--Problem 15.	 User Email Providers
  SELECT Username, SUBSTRING(Email, CHARINDEX('@', Email) + 1, LEN(Email)) AS EmailProvider
   FROM Users
  ORDER BY EmailProvider, Username 

  --Get Users with IPAdress Like Pattern

  SELECT Username, IpAddress
   FROM Users
   WHERE IpAddress LIKE '___.1%.%.___'
   ORDER BY Username

  --Show All Games with Duration and Part of the Day

   SELECT [Name], 
          CASE
		   WHEN DATEPART(HOUR, [Start]) BETWEEN 0 AND 11 THEN 'Morning'
		   WHEN DATEPART(HOUR, [Start])  BETWEEN 12 AND 17 THEN 'Afternoon'
		   WHEN DATEPART(HOUR, [Start])  BETWEEN 18 AND 23 THEN 'Evening'
		  END
   AS [Part of the Day],
         CASE
         WHEN Duration <= 3 THEN 'Extra Short'
         WHEN Duration BETWEEN 4 AND 6 THEN 'Short'
         WHEN Duration > 6 THEN 'Long'
		 ELSE 'Extra Long'
         END 
   AS
   [Duration]
FROM Games
   ORDER BY [Name], [Duration], [Part of the Day]