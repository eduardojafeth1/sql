use AdventureWorks2019
go

-- Ejercicio 1
SELECT  p.FirstName, p.LastName,  e.JobTitle,  e.BusinessEntityID
FROM    HumanResources.Employee e
INNER JOIN  Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
WHERE e.VacationHours > (SELECT AVG(VacationHours) FROM HumanResources.Employee);
go


-- Ejercicio 3
select ProductId, Name, ProductNumber, ListPrice from Production.product
where Product.ListPrice = (select MAX(Product.ListPrice) from Production.product);
go

-- Ejercicio 4
create nonclustered index IDX_FirstName
on Person.person (FirstName)
where FirstName is not null ;
go

-- Ejercicio 5
create nonclustered index IDX_ListPrice
on Production.Product (ListPrice desc);
go

-- Ejercicio 6
Create view Purchasing.Ejercicio
as
select
 pv.Name,
 sum(po.TotalDue) as total,
 count( po.PurchaseOrderID) as cantidad
 from Purchasing.vendor pv
 inner join Purchasing.PurchaseOrderHeader po on po.VendorID = pv.BusinessEntityID
 group by pv.Name;
 go

 select *
 from Purchasing.Ejercicio

 --Ejercicio 7
 WITH EjemploCTE2 (NationalIDNumber,FirstName,LastName,JobTitle,HireDate) 
  as
 (select e.NationalIDNumber, pp.FirstName, pp.LastName, e.JobTitle, e.HireDate
  from HumanResources.Employee e 
  RIGHT join Person.Person pp on e.BusinessEntityID =pp.BusinessEntityID
  where e.JobTitle like '%Engineer%')

 select * from EjemploCTE2
 order by HireDate
 go

 -- Ejerccio 8
 CREATE PROCEDURE ObtenerClienteMasOrdenes
    @fechaInicio DATE,
    @fechaFin DATE,
    @CustomerID INT OUTPUT,
    @CantidadOrdenes INT OUTPUT
AS
BEGIN  

    SELECT c.CustomerID, COUNT(soh.SalesOrderID) AS CantidadOrdenes
    FROM Sales.Customer c
    INNER JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
    WHERE soh.OrderDate BETWEEN @fechaInicio AND @fechaFin
    GROUP BY c.CustomerID;
	    
 END;
 go

 declare @FechaInicio date,
 @FechaFin date,
 @customerID int,
 @cantidadOrdenes int;
 set @FechaInicio='2011-01-01';
 set @FechaFin='2014-12-31';
 
 execute ObtenerClienteMasOrdenes
			@fechaInicio=@FechaInicio,
    @fechaFin=@FechaFin,
    @CustomerID= @customerID OUTPUT,
    @CantidadOrdenes=@cantidadOrdenes OUTPUT

 -- Ejercicio 9
alter PROCEDURE dbo.Clasificarclientes
AS
BEGIN
    SET NOCOUNT ON; 
    CREATE TABLE Clasificacionclientes
    (
        ClienteID INT,
        CantidadOrdenes INT,
        Clasificacion NVARCHAR(50)
    );
	   
    INSERT INTO Clasificacionclientes (ClienteID, CantidadOrdenes)
    SELECT CustomerID, COUNT(SalesOrderID) AS CantidadOrdenes
    FROM Sales.SalesOrderHeader 
    GROUP BY CustomerID;
	    
    UPDATE Clasificacionclientes
    SET Clasificacion = 
        CASE
            WHEN CantidadOrdenes BETWEEN 25 AND 30 THEN 'platinum'
            WHEN CantidadOrdenes BETWEEN 20 AND 24 THEN 'oro'
            WHEN CantidadOrdenes BETWEEN 15 AND 19 THEN 'plata'
            WHEN CantidadOrdenes BETWEEN 10 AND 14 THEN 'blue'
            ELSE 'Sin Clasificación'
        END;

    
    SELECT Clasificacion, COUNT(*) AS CantidadClientes
    FROM Clasificacionclientes
    GROUP BY Clasificacion;

    
   
END;
go

execute dbo.Clasificarclientes
go

select *
from dbo.Clasificacionclientes
go

 -- Ejercicio 10
 alter PROCEDURE Obtenerproductos
    @nombreproductoEntrada NVARCHAR(255),
    @precioMaxEntrada DECIMAL(18, 2),
    @precioComparacionSalida DECIMAL(18, 2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;


    DECLARE @precioMax DECIMAL(18, 2);

	
    SELECT @precioMax = MAX(p.ListPrice)
    FROM Production.Product p
    INNER JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    WHERE p.Name = @nombreproductoEntrada
      AND p.ListPrice < @precioMaxEntrada;

  
    SET @precioComparacionSalida = @precioMax;

  
    SELECT p.Name AS NombreProducto, p.ListPrice AS PrecioLista
    FROM Production.Product p
    INNER JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    WHERE ps.Name = @nombreproductoEntrada
      AND p.ListPrice < @precioMaxEntrada;
END;
go

select * from Production.Product
select * from Production.ProductSubcategory

declare @nombreproductoEntrada NVARCHAR(255),
    @precioMaxEntrada DECIMAL(18, 2),
    @precioComparacionSalida DECIMAL(18, 2);
set @nombreproductoEntrada='Mountain Frames'
set @precioComparacionSalida='1000.00';

execute Obtenerproductos @nombreproductoEntrada=@nombreproductoEntrada,
    @precioMaxEntrada=@precioMaxEntrada,
    @precioComparacionSalida=@precioComparacionSalida output;
