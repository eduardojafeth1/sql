--Ejercicio 1

Select *
from Sales.SalesOrderHeader

select *
from Person.Person

select *
from Sales.SalesPerson

select p.FirstName, p.LastName, soh.TotalDue
from Person.Person p
inner join Sales.SalesOrderHeader soh
on p.BusinessEntityID=soh.SalesPersonID
where soh.TotalDue>(select AVG(soh2.TotalDue)
					from Sales.SalesOrderHeader soh2)

--Ejericio 2
WITH CTE_VEntasPorVendedor
as(
select soh.SalesPersonID, p.FirstName, p.LastName, SUM(soh.TotalDue) as MontoTotalVentas, COUNT(soh.SalesOrderID) as CantidadDeVentas
from Sales.SalesOrderHeader soh
inner join Person.Person p
on soh.SalesPersonID=p.BusinessEntityID
group by soh.SalesPersonID, p.FirstName, p.LastName
)
select *
from CTE_VEntasPorVendedor


--Ejercicio 3

create index IDX_CurrencyRateID on Sales.SalesOrderHeader (CurrencyRateID)
where CurrencyRateID is not null

select soh.CurrencyRateID
from Sales.SalesOrderHeader soh
where soh.CurrencyRateID is not null

--Ejercicio 4

create view vw_InformacionEmpleados (NationalIDNumber, JobTitle, BusinessEntityID, AddressID, AddressLine1, City, PostalCode)
as(
select e.NationalIDNumber, e.JobTitle, bea.BusinessEntityID, bea.AddressID, a.AddressLine1, a.City, a.PostalCode
from HumanResources.Employee e
inner join Person.BusinessEntityAddress bea 
on e.BusinessEntityID=bea.BusinessEntityID
inner join Person.Address a
on bea.AddressID=a.AddressID
)

select *
from vw_InformacionEmpleados

--Ejercicio 5
select *
from Person.Person
go

select *
from Person.EmailAddress
go

select *
from HumanResources.Employee
go

select e.BusinessEntityID, e.JobTitle, e.HireDate, p.FirstName, p.LastName, ea.EmailAddress
from HumanResources.Employee e
inner join Person.Person p 
on e.BusinessEntityID=p.BusinessEntityID
left join Person.EmailAddress ea
on p.BusinessEntityID=ea.BusinessEntityID


--Ejercicio 6
create nonclustered index IDX_Nombres on Person.Person (firstname ASC,Lastname ASC)

select p.FirstName, p.LastName
from Person.Person p


--Ejercicio 7

select * 
from Sales.SalesOrderHeader
create table Sales.SOH2011 (SalesOrderID int, RevisionNumber int, OrderDate datetime, DueDate datetime, ShipDate datetime, Status int, OnlineOrderFlag int, SalesOrderNumber varchar(7), PurchaseOrderNumber varchar(13), AccountNumber varchar(12), CustomerID int, SalesPerdonID int, TerritoryID int, BillToAddressID int, ShipToAddressID int, ShipMethodID int, CreditCardID int, CreditCardAproovalCode varchar(15), CurrencyRateID int, SubTotal decimal(15,4), TaxAmt decimal(15,4), Freight decimal(15,4), TotalDue decimal(15,4), Comment varchar(25), rowguid varchar(50), ModifiedDate datetime)
create table Sales.SOH2012 (SalesOrderID int, RevisionNumber int, OrderDate datetime, DueDate datetime, ShipDate datetime, Status int, OnlineOrderFlag int, SalesOrderNumber varchar(7), PurchaseOrderNumber varchar(13), AccountNumber varchar(12), CustomerID int, SalesPerdonID int, TerritoryID int, BillToAddressID int, ShipToAddressID int, ShipMethodID int, CreditCardID int, CreditCardAproovalCode varchar(15), CurrencyRateID int, SubTotal decimal(15,4), TaxAmt decimal(15,4), Freight decimal(15,4), TotalDue decimal(15,4), Comment varchar(25), rowguid varchar(50), ModifiedDate datetime)
create table Sales.SOH2013 (SalesOrderID int, RevisionNumber int, OrderDate datetime, DueDate datetime, ShipDate datetime, Status int, OnlineOrderFlag int, SalesOrderNumber varchar(7), PurchaseOrderNumber varchar(13), AccountNumber varchar(12), CustomerID int, SalesPerdonID int, TerritoryID int, BillToAddressID int, ShipToAddressID int, ShipMethodID int, CreditCardID int, CreditCardAproovalCode varchar(15), CurrencyRateID int, SubTotal decimal(15,4), TaxAmt decimal(15,4), Freight decimal(15,4), TotalDue decimal(15,4), Comment varchar(25), rowguid varchar(50), ModifiedDate datetime)
create table Sales.SOH2014 (SalesOrderID int, RevisionNumber int, OrderDate datetime, DueDate datetime, ShipDate datetime, Status int, OnlineOrderFlag int, SalesOrderNumber varchar(7), PurchaseOrderNumber varchar(13), AccountNumber varchar(12), CustomerID int, SalesPerdonID int, TerritoryID int, BillToAddressID int, ShipToAddressID int, ShipMethodID int, CreditCardID int, CreditCardAproovalCode varchar(15), CurrencyRateID int, SubTotal decimal(15,4), TaxAmt decimal(15,4), Freight decimal(15,4), TotalDue decimal(15,4), Comment varchar(25), rowguid varchar(50), ModifiedDate datetime)
			
	
alter procedure pa_ParticionarPorAnio 
as 
begin
	insert into Sales.SOH2011
	select *
	from Sales.SalesOrderHeader soh
	Where soh.OrderDate=YEAR('2011');
	
	insert into Sales.SOH2012
	select *
	from Sales.SalesOrderHeader soh
	Where soh.OrderDate=YEAR('2012');
	
	insert into Sales.SOH2013
	select *
	from Sales.SalesOrderHeader soh
	Where soh.OrderDate=YEAR('2013');
	
	insert into Sales.SOH2014
	select *
	from Sales.SalesOrderHeader soh
	Where soh.OrderDate=YEAR('2014');
end;
go

execute pa_ParticionarPorAnio;

drop table Sales.SOH2011;
go
drop table Sales.SOH2012;
go
drop table Sales.SOH2013;
go
drop table Sales.SOH2014;
go

select *
from Sales.SOH2011

--Ejercicio 8

select *
from Sales.SalesOrderHeader
GO

alter procedure pa_PorAnio 
@Anio int,
@codigoEmpleado int output,
@totalVenta decimal(14,2) output,@cantidadVendida int outputas beginselect @codigoEmpleado=soh.SalesOrderID, @totalVenta=SUM(soh.TotalDue), @cantidadVendida=COUNT(*)from Sales.SalesOrderHeader sohwhere YEAR(soh.OrderDate)=@Aniogroup by soh.SalesOrderIDorder by SUM(soh.TotalDue) ASCendDECLARE @CodigoEmpleado int ,
@TotalVenta decimal(14,2) ,@CantidadVendida int;execute pa_PorAnio '2011', @codigoEmpleado=@CodigoEmpleado output,
@totalVenta=@TotalVenta output,@cantidadVendida=@CantidadVendida output 
select @CodigoEmpleado as SalesPersonID,
@TotalVenta as TotalVendido ,@CantidadVendida as CantidadVentas;









