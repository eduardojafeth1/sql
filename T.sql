use ResiduosToxicos
go

--Ejercicio 1
select *
from dbo.Residuo r
go

select *
from dbo.Constituyente
go

select * 
from dbo.Residuo_Constituyente rc
order by rc.cod_residuo
go

SELECT  r.cod_residuo, r.desc_residuo, (SELECT SUM(rc.cantidad) 
										FROM dbo.Residuo_Constituyente rc 
										WHERE rc.cod_residuo = r.cod_residuo) AS totalconstituyentes
FROM dbo.Residuo r
group by r.cod_residuo, r.desc_residuo;

--Ejercicio 2
select r.cod_residuo, r.desc_residuo, c.nombre_constituyente,SUM(rc.cantidad) as TotalConstituyentes
from dbo.Residuo r
inner join dbo.Residuo_Constituyente rc
on rc.cod_residuo=r.cod_residuo
inner join dbo.Constituyente c
on c.cod_constituyente=rc.cod_constituyente
group by r.cod_residuo, r.desc_residuo, c.nombre_constituyente
go

--Ejercicio 3
select r.cod_residuo, r.desc_residuo, r.toxicidad
from dbo.Residuo r
where r.toxicidad>(select AVG(rr.toxicidad) from dbo.Residuo rr);
go

--Ejercicio 4

select *
from dbo.EmpresaProductora

select *
from dbo.EmpresaTransportista

select *
from dbo.Destino

select *
from dbo.Traslado_EmpresaTransportista

select *
from dbo.EmpresaProductora ep

select et.nombre_emptransporte, ep.nombre_empresa, d.ciudad_destino, COUNT(tet.cod_destino) as TotalTraslados
from dbo.EmpresaTransportista et
inner join dbo.Traslado_EmpresaTransportista tet
on et.nif_emptransporte=tet.nif_emptransporte
inner join dbo.Destino d
on tet.cod_destino=d.cod_destino
inner join dbo.EmpresaProductora ep
on ep.nif_empresa=tet.nif_empresa 
group by et.nombre_emptransporte, ep.nombre_empresa, d.ciudad_destino
go

--Ejercicio 5
WITH CET_ResiduoTransporte  
as (
	select r.cod_residuo, r.desc_residuo, COUNT(tet.cod_destino) as ResiduoTransportado
	from dbo.Residuo r
	inner join dbo.Traslado_EmpresaTransportista tet
	on r.cod_residuo=tet.cod_residuo
	group by r.cod_residuo, r.desc_residuo
	) 
select * 
from CET_ResiduoTransporte
order by CET_ResiduoTransporte.ResiduoTransportado DESC

--Ejercicio 6
alter view vw_ResiduosPorEmpresa (NombreEmpresa, Actividad, CantidadDeResiduos) as 
(
select ep.nombre_empresa, ep.actividad, SUM(r.cantidad_residuo)
from dbo.EmpresaProductora ep
inner join dbo.Residuo r
on ep.nif_empresa=r.nif_empresa
group by ep.nombre_empresa,ep.actividad
)

select *
from vw_ResiduosPorEmpresa

--Ejercicio 7

select*
from dbo.EmpresaProductora

alter table dbo.EmpresaProductora
drop constraint pk_emp ;

create clustered index IDX_FechaCreacionEmpresa on dbo.EmpresaProductora (nif_empresa, fecha_creacion)

ALTER TABLE Residuo
DROP CONSTRAINT fk_res_emp;

select ep.nif_empresa
from dbo.EmpresaProductora ep

--Ejercicio 8

select *
from dbo.Residuo
go

select *
from dbo.Destino
go

select *
from dbo.Traslado
go 

alter procedure dbo.cp_TrasporteResiduo
@fechaInicial date,
@fechaFinal date,
@Residuo decimal(5,4) output,
@ciudad_destino varchar(25) output,
@cantidad int output
as 
begin
	select @Residuo=r.cod_residuo, @ciudad_destino=d.ciudad_destino, @cantidad=COUNT(*)
	from dbo.Residuo r
	inner join dbo.Traslado t
	on r.nif_empresa=t.nif_empresa
	inner join dbo.Destino d
	on t.cod_destino=d.cod_destino
	where t.fecha_envio=@fechaInicial AND t.fecha_llegada=@fechaFinal
	group by r.cod_residuo, d.ciudad_destino
end;
go

declare @FechaInicial date,
@FechaFinal date,
@residuo decimal(5,4) ,
@Ciudad_Destino varchar(25) ,
@Cantidad int;
set @FechaInicial='1994-07-30';
set @FechaFinal='1994-07-31'

execute dbo.cp_TrasporteResiduo 
@fechaInicial=@FechaInicial,
@fechaFinal=@FechaFinal,
@Residuo=@residuo output,
@ciudad_destino=@Ciudad_Destino output,
@cantidad=@Cantidad output;

select @FechaInicial as fechaInicial,
@FechaFinal as fechaFinal,
@residuo as residuo,
@Ciudad_Destino as ciudad_destino,
@Cantidad as cantidad;

--Ejercicio 9
alter procedure dbo.ap_CantidadTraslados 
@NifEmpresa  varchar(25) output,
@CantidadTraslados int output
as
begin
	select @NifEmpresa=t.nif_empresa, @CantidadTraslados=COUNT(*)
	from dbo.Traslado t
	inner join dbo.EmpresaProductora ep
	on t.nif_empresa=ep.nif_empresa
	group by t.nif_empresa
	order by COUNT(*) ASC
end;
go

declare 
@nifEmpresa varchar(25),
@cantidadTraslados int;

execute dbo.ap_CantidadTraslados 
@NifEmpresa=@nifEmpresa output,
@CantidadTraslados=@cantidadTraslados output;

select @nifEmpresa ,
@cantidadTraslados;
go

--Ejercicio 10
create TABLE dbo.ResiduosAltamenteToxicos (
    nif_empresa VARCHAR(25),
    cod_residuo decimal(5,4),
    toxicidad INT,
    cantidad_residuo INT
);
go

CREATE PROCEDURE dbo.PoblarResiduosAltamenteToxicos
AS
BEGIN
    -- Limpiar la tabla para evitar duplicados
    TRUNCATE TABLE dbo.ResiduosAltamenteToxicos;

    -- Insertar los residuos altamente tóxicos en la tabla
    INSERT INTO dbo.ResiduosAltamenteToxicos (nif_empresa, cod_residuo, toxicidad, cantidad_residuo)
    SELECT r.nif_empresa, r.cod_residuo, r.toxicidad, r.cantidad_residuo
    FROM dbo.Residuo r
    WHERE r.toxicidad > 500;
END;
GO

execute dbo.PoblarResiduosAltamenteToxicos

select*
from dbo.ResiduosAltamenteToxicos
go

select *
from dbo.Residuo r
where r.toxicidad>500





