CREATE DATABASE WMS
USE WMS

CREATE TABLE Clients
(
	ClientId INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(50) NOT NULL,
	LastName VARCHAR(50) NOT NULL,
	Phone CHAR(12) CHECK(LEN(Phone) = 12) NOT NULL
)

CREATE TABLE Mechanics
(
	MechanicId INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(50) NOT NULL,
	LastName VARCHAR(50) NOT NULL,
	[Address] VARCHAR(255) NOT NULL
)

CREATE TABLE Models
(
	ModelId INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) UNIQUE NOT NULL
)

CREATE TABLE Jobs
(
	JobId INT PRIMARY KEY IDENTITY,
	ModelId INT NOT NULL,
		CONSTRAINT FK_Jobs_Models
		FOREIGN KEY (ModelId)
		REFERENCES Models(ModelId),
	[Status] VARCHAR(11) DEFAULT 'Pending' CHECK([Status] IN ('In Progress', 'Finished', 'Pending')) NOT NULL,
	ClientId INT NOT NULL,
		CONSTRAINT FK_Jobs_Clients
		FOREIGN KEY (ClientId)
		REFERENCES Clients(ClientId),
	MechanicId INT
		CONSTRAINT FK_Jobs_Mechanics
		FOREIGN KEY (MechanicId)
		REFERENCES Mechanics(MechanicId),
	IssueDate DATE NOT NULL,
	FinishDate DATE
)

CREATE TABLE Orders
(
	OrderId INT PRIMARY KEY IDENTITY,
	JobId INT FOREIGN KEY REFERENCES Jobs(JobId) NOT NULL,
	IssueDate DATE,
	Delivered BIT DEFAULT 0
)

CREATE TABLE Vendors
(
	VendorId INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) UNIQUE NOT NULL
)

CREATE TABLE Parts
(
	PartId INT PRIMARY KEY IDENTITY,
	SerialNumber VARCHAR(50) UNIQUE NOT NULL,
	[Description] VARCHAR(255),
	Price DECIMAL(15,2) CHECK(Price > 0 AND Price <= 9999.99) NOT NULL,
	VendorId INT FOREIGN KEY REFERENCES Vendors(VendorId) NOT NULL,
	StockQty INT DEFAULT 0 CHECK (StockQty >= 0)
)

CREATE TABLE OrderParts
(
	OrderId INT FOREIGN KEY REFERENCES Orders(OrderId) NOT NULL,
	PartId INT FOREIGN KEY REFERENCES Parts(PartId) NOT NULL,
	Quantity INT DEFAULT 1 CHECK(Quantity > 0) NOT NULL

	CONSTRAINT PK_OrdersParts PRIMARY KEY(OrderId, PartID)
)

CREATE TABLE PartsNeeded
(
	JobId INT FOREIGN KEY REFERENCES Orders(OrderId) NOT NULL,
	PartId INT FOREIGN KEY REFERENCES Parts(PartId) NOT NULL,
	Quantity INT DEFAULT 1 CHECK(Quantity > 0) NOT NULL

	CONSTRAINT PK_JobsParts PRIMARY KEY(JobId, PartID)
)

INSERT INTO Clients(FirstName, LastName, Phone) VALUES 

	('Teri', 'Ennaco', '570-889-5187'),
	('Merlyn', 'Lawler', '201-588-7810'),
	('Georgene', 'Montezuma', '925-615-5185'),
	('Jettie', 'Mconnell', '908-802-3564'),
	('Lemuel', 'Latzke', '631-748-6479'),
	('Melodie', 'Knipp', '805-690-1682'),
	('Candida', 'Corbley', '908-275-8357')

INSERT INTO Parts(SerialNumber, [Description], Price, VendorId) VALUES
		('WP8182119', 'Door Boot Seal', 117.86, 2),
		('W10780048', 'Suspension Rod', 42.81, 1),
		('W10841140', 'Silicone Adhesive', 6.77, 4),
		('WPY055980', 'High Temperature Adhesive', 13.94, 3)

UPDATE Jobs
	SET MechanicID = 3, Status = 'In Progress'
WHERE Status = 'Pending'

DELETE FROM OrderParts WHERE OrderId = 19
DELETE FROM Orders WHERE OrderId = 19

--5.	Mechanic Assignments
SELECT m.FirstName + ' ' + m.LastName AS Mechanic,
	   j.Status,
	   j.IssueDate
FROM Mechanics m
JOIN Jobs j ON m.MechanicId = j.MechanicId
ORDER BY m.MechanicId, j.IssueDate, j.JobId

--6.	Current Clients
SELECT FirstName + ' ' + LastName AS Client,
	   DATEDIFF(DAY,j.IssueDate, '2017/04/24') AS 'Days going',
	   j.Status
FROM Clients c
JOIN Jobs j ON c.ClientId = j.ClientId
WHERE j.Status != 'Finished'
ORDER BY 'Days going' DESC, c.ClientId

--7.	Mechanic Performance
SELECT m.FirstName + ' ' + m.LastName AS Mechanic,
     AVG(DATEDIFF(DAY,j.IssueDate,j.FinishDate))   
FROM Mechanics m
JOIN Jobs j ON m.MechanicId = j.MechanicId
GROUP BY m.MechanicId, (m.FirstName + ' ' + m.LastName)
ORDER BY m.MechanicId

--Select all finished jobs and the total cost of all parts that were ordered for them. Sort by total cost of parts ordered (descending) --and by job ID (ascending).

SELECT j.JobId, ISNULL(SUM(p.Price * op.Quantity),0) AS Total 
	FROM Jobs j
		LEFT JOIN Orders o ON o.JobId = j.JobId
		LEFT JOIN OrderParts op ON op.OrderId = o.OrderId
		LEFT JOIN Parts p ON p.PartId = op.PartId
	WHERE Status = 'Finished'
GROUP BY j.JobId
ORDER BY Total DESC, j.JobId


--

CREATE PROC usp_PlaceOrder
(@jobID INT, @serailNumber VARCHAR(50), @qty INT)
AS

DECLARE @status VARCHAR(10)= (SELECT Status FROM Jobs WHERE JobId = @jobID)
DECLARE @partID VARCHAR(10) =(SELECT PartId FROM Parts WHERE SerialNumber = @serailNumber)

	IF (@status = 'Finished')
		THROW 50011,  'This job is not avtive', 1
	ELSE IF (@qty <= 0)
		THROW 50012, 'Part quantity must be more than zero!', 1
	ELSE IF (@status IS NULL)
		THROW 50013, 'Job not found!', 1
	ELSE IF (@partID IS NULL)
		THROW 50014, 'Part not found!', 1

DECLARE @doesOrderExists INT = (SELECt OrderId FROM Orders WHERE JobId = @jobID)

IF (@doesOrderExists IS NULL)
INSERT INTO Orders (JobId, IssueDate) VALUE (@jobID, NULL)