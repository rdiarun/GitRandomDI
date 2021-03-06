USE [master]
GO
/****** Object:  Database [system.detectorinspector.com.au]    Script Date: 09/02/2013 13:37:44 ******/
CREATE DATABASE [system.detectorinspector.com.au] ON  PRIMARY 
( NAME = N'DetectorInspector', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\system.detectorinspector.com.au.mdf' , SIZE = 197632KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'DetectorInspector_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\system.detectorinspector.com.au.ldf' , SIZE = 102144KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [system.detectorinspector.com.au] SET COMPATIBILITY_LEVEL = 100
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [system.detectorinspector.com.au].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [system.detectorinspector.com.au] SET ANSI_NULL_DEFAULT OFF
GO
ALTER DATABASE [system.detectorinspector.com.au] SET ANSI_NULLS OFF
GO
ALTER DATABASE [system.detectorinspector.com.au] SET ANSI_PADDING OFF
GO
ALTER DATABASE [system.detectorinspector.com.au] SET ANSI_WARNINGS OFF
GO
ALTER DATABASE [system.detectorinspector.com.au] SET ARITHABORT OFF
GO
ALTER DATABASE [system.detectorinspector.com.au] SET AUTO_CLOSE OFF
GO
ALTER DATABASE [system.detectorinspector.com.au] SET AUTO_CREATE_STATISTICS ON
GO
ALTER DATABASE [system.detectorinspector.com.au] SET AUTO_SHRINK OFF
GO
ALTER DATABASE [system.detectorinspector.com.au] SET AUTO_UPDATE_STATISTICS ON
GO
ALTER DATABASE [system.detectorinspector.com.au] SET CURSOR_CLOSE_ON_COMMIT OFF
GO
ALTER DATABASE [system.detectorinspector.com.au] SET CURSOR_DEFAULT  GLOBAL
GO
ALTER DATABASE [system.detectorinspector.com.au] SET CONCAT_NULL_YIELDS_NULL OFF
GO
ALTER DATABASE [system.detectorinspector.com.au] SET NUMERIC_ROUNDABORT OFF
GO
ALTER DATABASE [system.detectorinspector.com.au] SET QUOTED_IDENTIFIER OFF
GO
ALTER DATABASE [system.detectorinspector.com.au] SET RECURSIVE_TRIGGERS OFF
GO
ALTER DATABASE [system.detectorinspector.com.au] SET  DISABLE_BROKER
GO
ALTER DATABASE [system.detectorinspector.com.au] SET AUTO_UPDATE_STATISTICS_ASYNC OFF
GO
ALTER DATABASE [system.detectorinspector.com.au] SET DATE_CORRELATION_OPTIMIZATION OFF
GO
ALTER DATABASE [system.detectorinspector.com.au] SET TRUSTWORTHY OFF
GO
ALTER DATABASE [system.detectorinspector.com.au] SET ALLOW_SNAPSHOT_ISOLATION OFF
GO
ALTER DATABASE [system.detectorinspector.com.au] SET PARAMETERIZATION SIMPLE
GO
ALTER DATABASE [system.detectorinspector.com.au] SET READ_COMMITTED_SNAPSHOT OFF
GO
ALTER DATABASE [system.detectorinspector.com.au] SET HONOR_BROKER_PRIORITY OFF
GO
ALTER DATABASE [system.detectorinspector.com.au] SET  READ_WRITE
GO
ALTER DATABASE [system.detectorinspector.com.au] SET RECOVERY SIMPLE
GO
ALTER DATABASE [system.detectorinspector.com.au] SET  MULTI_USER
GO
ALTER DATABASE [system.detectorinspector.com.au] SET PAGE_VERIFY CHECKSUM
GO
ALTER DATABASE [system.detectorinspector.com.au] SET DB_CHAINING OFF
GO
EXEC sys.sp_db_vardecimal_storage_format N'system.detectorinspector.com.au', N'ON'
GO
USE [system.detectorinspector.com.au]
GO
/****** Object:  User [IIS APPPOOL\test.system.detectorinspector.com.au]    Script Date: 09/02/2013 13:37:44 ******/
CREATE USER [IIS APPPOOL\test.system.detectorinspector.com.au]
GO
/****** Object:  User [IIS APPPOOL\detectorinspector.kdev.com.au]    Script Date: 09/02/2013 13:37:44 ******/
CREATE USER [IIS APPPOOL\detectorinspector.kdev.com.au]
GO
/****** Object:  User [IIS APPPOOL\DefaultAppPool]    Script Date: 09/02/2013 13:37:44 ******/
CREATE USER [IIS APPPOOL\DefaultAppPool] FOR LOGIN [IIS APPPOOL\DefaultAppPool]
GO
/****** Object:  User [IIS APPPOOL\ASP.NET v4.0]    Script Date: 09/02/2013 13:37:44 ******/
CREATE USER [IIS APPPOOL\ASP.NET v4.0] FOR LOGIN [IIS APPPOOL\ASP.NET v4.0]
GO
/****** Object:  User [ICO-4783AVIRT\detector.kdev.com.au]    Script Date: 09/02/2013 13:37:44 ******/
CREATE USER [ICO-4783AVIRT\detector.kdev.com.au] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [c]    Script Date: 09/02/2013 13:37:44 ******/
CREATE USER [c]
GO
/****** Object:  StoredProcedure [dbo].[aspnet_Setup_RestorePermissions]    Script Date: 09/02/2013 13:37:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[aspnet_Setup_RestorePermissions]
@name [sysname]
AS
BEGIN
    DECLARE @object sysname
    DECLARE @protectType char(10)
    DECLARE @action varchar(60)
    DECLARE @grantee sysname
    DECLARE @cmd nvarchar(500)
    DECLARE c1 cursor FORWARD_ONLY FOR
        SELECT Object, ProtectType, [Action], Grantee FROM #aspnet_Permissions where Object = @name

    OPEN c1

    FETCH c1 INTO @object, @protectType, @action, @grantee
    WHILE (@@fetch_status = 0)
    BEGIN
        SET @cmd = @protectType + ' ' + @action + ' on ' + @object + ' TO [' + @grantee + ']'
        EXEC (@cmd)
        FETCH c1 INTO @object, @protectType, @action, @grantee
    END

    CLOSE c1
    DEALLOCATE c1
END
GO
/****** Object:  StoredProcedure [dbo].[aspnet_Setup_RemoveAllRoleMembers]    Script Date: 09/02/2013 13:37:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[aspnet_Setup_RemoveAllRoleMembers]
@name [sysname]
AS
BEGIN
    CREATE TABLE #aspnet_RoleMembers
    (
        Group_name      sysname,
        Group_id        smallint,
        Users_in_group  sysname,
        User_id         smallint
    )

    INSERT INTO #aspnet_RoleMembers
    EXEC sp_helpuser @name

    DECLARE @user_id smallint
    DECLARE @cmd nvarchar(500)
    DECLARE c1 cursor FORWARD_ONLY FOR
        SELECT User_id FROM #aspnet_RoleMembers

    OPEN c1

    FETCH c1 INTO @user_id
    WHILE (@@fetch_status = 0)
    BEGIN
        SET @cmd = 'EXEC sp_droprolemember ' + '''' + @name + ''', ''' + USER_NAME(@user_id) + ''''
        EXEC (@cmd)
        FETCH c1 INTO @user_id
    END

    CLOSE c1
    DEALLOCATE c1
END
GO
/****** Object:  Table [dbo].[aspnet_SchemaVersions]    Script Date: 09/02/2013 13:37:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[aspnet_SchemaVersions](
	[Feature] [nvarchar](128) NOT NULL,
	[CompatibleSchemaVersion] [nvarchar](128) NOT NULL,
	[IsCurrentVersion] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Feature] ASC,
	[CompatibleSchemaVersion] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[aspnet_Applications]    Script Date: 09/02/2013 13:37:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[aspnet_Applications](
	[ApplicationName] [nvarchar](256) NOT NULL,
	[LoweredApplicationName] [nvarchar](256) NOT NULL,
	[ApplicationId] [uniqueidentifier] NOT NULL,
	[Description] [nvarchar](256) NULL,
PRIMARY KEY NONCLUSTERED 
(
	[ApplicationId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[LoweredApplicationName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ApplicationName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ApplicationArea]    Script Date: 09/02/2013 13:37:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ApplicationArea](
	[ApplicationAreaId] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_ApplicationArea] PRIMARY KEY CLUSTERED 
(
	[ApplicationAreaId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AgencyGroup]    Script Date: 09/02/2013 13:37:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AgencyGroup](
	[AgencyGroupId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[IsDeleted] [bit] NULL,
	[CreatedByUserId] [uniqueidentifier] NULL,
	[CreatedUtcDate] [datetime] NULL,
	[ModifiedByUserId] [uniqueidentifier] NULL,
	[ModifiedUtcDate] [datetime] NULL,
	[RowVersion] [timestamp] NULL,
 CONSTRAINT [PK_AgencyGroup] PRIMARY KEY CLUSTERED 
(
	[AgencyGroupId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[f_StringSplit]    Script Date: 09/02/2013 13:37:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[f_StringSplit]
(@ValueList NVARCHAR (MAX), @SplitOn NVARCHAR (5))
RETURNS 
    @Result TABLE (
        [Index] INT           IDENTITY (1, 1) NOT NULL PRIMARY KEY CLUSTERED ([Index] ASC) WITH (ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, STATISTICS_NORECOMPUTE = OFF),
        [Value] NVARCHAR (20) NOT NULL)
AS
begin 
	while (charindex(@SplitOn, @ValueList) > 0)
	begin
		insert @Result (Value)
		select convert(nvarchar(20), ltrim(rtrim(substring(@ValueList, 1, charindex(@SplitOn, @ValueList) - 1))))

		set		@ValueList = substring(@ValueList, charindex(@SplitOn, @ValueList) + 1, len(@ValueList))
	end

	insert @Result (Value)
	select convert(nvarchar(20), ltrim(rtrim(@ValueList)))

	return
end
GO
/****** Object:  UserDefinedFunction [dbo].[f_StreetAddress]    Script Date: 09/02/2013 13:37:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[f_StreetAddress]
(
	-- Add the parameters for the function here
	@UnitShopNumber nvarchar(50), @StreetNumber nvarchar(50), @StreetName nvarchar(50)
)
RETURNS nvarchar(50)
AS
BEGIN
	DECLARE @StreetAddress nvarchar(150)
	SET @StreetAddress = @StreetName
	IF(ISNULL(@StreetNumber, '') <> '')
	BEGIN
		SET @StreetAddress = @StreetNumber + ' ' + @StreetAddress
	END
	
	IF(ISNULL(@UnitShopNumber, '') <> '')
	BEGIN
		SET @StreetAddress = @UnitShopNumber + '/' + @StreetAddress
	END
	RETURN @StreetAddress
END
GO
/****** Object:  UserDefinedFunction [dbo].[f_NextServiceDate]    Script Date: 09/02/2013 13:37:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[f_NextServiceDate]
(@ServiceDate DATETIME, @PropertyHoldDate DATETIME, @CreatedUtcDate DATETIME)
RETURNS datetime
AS
begin
/* 
	RJC. 20130416. Calculation to convert GMT to Local date was incorrect. 
	Updated version also uses minutes instead of hours in case server ends up in Adelaide which is on 1/2 hour time zone offset
	Note. This function is used in the NextServiceDate column of PropertyInfo, as a calculated column
	([dbo].[f_NextServiceDate]([LastServicedDate],[PropertyHoldDate],[CreatedUtcDate]))
	
	return CONVERT(date, COALESCE(Dateadd(year, 1, @ServiceDate), @PropertyHoldDate, DATEADD(Hour, DATEDIFF(Hour, GETDATE(), GETUTCDATE()), @CreatedUtcDate), getdate()))
*/
	return CONVERT(date, COALESCE(Dateadd(year, 1, @ServiceDate), @PropertyHoldDate, DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), @CreatedUtcDate), getdate()))
end
GO
/****** Object:  UserDefinedFunction [dbo].[f_IsElectricianRequired]    Script Date: 09/02/2013 13:37:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[f_IsElectricianRequired]    
(@DetectorMainCount int, @TotalDetectorCount int, @TotalMainCount int, @DynamicReadyForServiceId int)    
RETURNS bit    
AS    
begin    
 RETURN (CASE WHEN @DynamicReadyForServiceId IS NOT NULL AND (@DetectorMainCount > 0 AND @DetectorMainCount = @TotalDetectorCount) THEN 1 ELSE 0 END)    
end
GO
/****** Object:  UserDefinedFunction [dbo].[f_IsCompletedOneOffService]    Script Date: 09/02/2013 13:37:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[f_IsCompletedOneOffService]
(@IsOneOffService bit, @IsServiceCompleted bit, @cancelled bit)
RETURNS bit
AS
begin
	return CASE WHEN ISNULL(@cancelled, 1) = 1 THEN 0 WHEN ISNULL(@IsOneOffService,0) = 0 THEN 0 ELSE (@IsOneOffService & @IsServiceCompleted) END
end
GO
/****** Object:  Table [dbo].[ContactNumberType]    Script Date: 09/02/2013 13:37:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContactNumberType](
	[ContactNumberTypeId] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_ContactNumberType] PRIMARY KEY CLUSTERED 
(
	[ContactNumberTypeId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[p_ServiceSheet__Date]    Script Date: 09/02/2013 13:37:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[p_ServiceSheet__Date]
@startRow bigint, @pageSize bigint, @sortBy NVARCHAR (100), @sortDir NVARCHAR (4), @startdate datetime, @enddate datetime, @itemCount INT OUTPUT
AS
set nocount on

declare @countSelect nvarchar(max)
declare @resultsSelect nvarchar(max)
declare @from nvarchar(max)
declare @orderby nvarchar(max)
declare @groupBy nvarchar(max)
declare @Cmd nvarchar(max)

	select		@OrderBy		=	case @sortBy
									when 'BookingDate' then ' Booking.Date ' + @sortDir + ', CAST(ISNULL(Booking.TechnicianId, 0) AS bit) ASC, UserProfile.FirstName + '' '' + UserProfile.LastName, Booking.[Time] '
									when 'Technican.Name' then ' UserProfile.FirstName + '' '' + UserProfile.LastName ' + @sortDir + ', CAST(ISNULL(Booking.TechnicianId, 0) AS bit) ASC, UserProfile.FirstName + '' '' + UserProfile.LastName, Booking.[Time] '
									else @sortBy + ' ' + @sortDir end

	set @countSelect = 'select 1 [row] '
	
	set @from = '
		from   dbo.Booking '

	set @from = @from + ' left join ServiceSheet on Booking.BookingId = ServiceSheet.BookingId inner join PropertyInfo on Booking.PropertyInfoId = PropertyInfo.PropertyInfoId And Booking.Date BETWEEN @startdate AND @enddate AND Booking.IsDeleted = 0 '
	
			
	set @from = @from + ' left outer join State on PropertyInfo.StateId = State.StateId 
		left outer join Agency on PropertyInfo.AgencyId = Agency.AgencyId 
		left outer join Technician on Booking.TechnicianId = Technician.TechnicianId 
		left outer join UserProfile on Booking.TechnicianId = UserProfile.TechnicianId
		left outer join PropertyManager on PropertyInfo.PropertyManagerId = PropertyManager.PropertyManagerId
		left outer join InspectionStatus on PropertyInfo.InspectionStatusId = InspectionStatus.InspectionStatusId 
		left outer join ElectricalWorkStatus on PropertyInfo.ElectricalWorkStatusId = ElectricalWorkStatus.ElectricalWorkStatusId
		where	PropertyInfo.IsDeleted = 0 AND ISNULL(ServiceSheet.IsCompleted, 0) = 0'
		

	set @groupBy = ' group by
			Booking.BookingId
			,PropertyInfo.PropertyInfoId 
			,PropertyInfo.PropertyNumber 
			,PropertyInfo.UnitShopNumber
			,PropertyInfo.StreetNumber
			,PropertyInfo.StreetName
			,PropertyInfo.Suburb
			,State.Name
			,PropertyInfo.PostCode
			,PropertyInfo.LastServicedDate
			,dbo.f_NextServiceDate(PropertyInfo.LastServicedDate, PropertyInfo.SettlementDate, PropertyInfo.CreatedUtcDate)
			,PropertyInfo.InspectionStatusId
			,InspectionStatus.Name
			,PropertyInfo.ElectricalWorkStatusId
			,ElectricalWorkStatus.Name	
			,Booking.TechnicianId
			,UserProfile.FirstName + '' '' + UserProfile.LastName
			,Booking.Date
			,Booking.Time
			,Booking.Duration
			,Agency.Name
			,PropertyManager.Name
			,Booking.KeyNumber
			,Booking.Notes
			,CAST(ISNULL(ServiceSheet.ServiceSheetId, 0) as bit)
			,PropertyInfo.ContactNotes
			,OccupantName
			,ConcatenatedTenantContactNumber
			,PropertyInfo.HasProblem
			,PropertyInfo.HasLargeLadder
			,Booking.RowVersion '

	set @resultsSelect = ' 
		select
			Booking.BookingId [Id]
			,PropertyInfo.PropertyInfoId
			,PropertyInfo.PropertyNumber
			,PropertyInfo.UnitShopNumber
			,PropertyInfo.StreetNumber
			,PropertyInfo.StreetName
			,PropertyInfo.Suburb
			,State.Name [State]
			,PropertyInfo.PostCode
			,PropertyInfo.LastServicedDate
			,dbo.f_NextServiceDate(PropertyInfo.LastServicedDate, PropertyInfo.SettlementDate, PropertyInfo.CreatedUtcDate) [NextServiceDate]
			,PropertyInfo.InspectionStatusId [InspectionStatusEnum]
			,InspectionStatus.Name [InspectionStatus]
			,PropertyInfo.ElectricalWorkStatusId [ElectricalWorkStatusEnum]
			,ElectricalWorkStatus.Name [ElectricalWorkStatus]
			,Booking.TechnicianId
			,UserProfile.FirstName + '' '' + UserProfile.LastName [TechnicianName]
			,Booking.Date [BookingDate]
			,Booking.Time [BookingTime]
			,Booking.Duration
			,Agency.Name	[Agency]
			,PropertyManager.Name [PropertyManager]
			,OccupantName [TenantName]
			,ConcatenatedTenantContactNumber [TenantContactNumber]
			,PropertyInfo.HasProblem
			,PropertyInfo.HasLargeLadder
			,Booking.KeyNumber
			,Booking.Notes
			,CAST(ISNULL(ServiceSheet.ServiceSheetId, 0) as bit) [HasServiceSheet]
			,PropertyInfo.ContactNotes
			,Booking.RowVersion
			,row_number() '
			
	set @resultsSelect = @resultsSelect + ' over(order by ' + @orderby + ') as [sort_row]'

	set @Cmd = '
	select @itemcount = count(row) from (' + @countSelect + @from + @groupby + ') as countquery;
	select * from (' + @resultsSelect + @from + @groupBy + ' ) as query
	where    query.sort_row between @startRow and @startRow + @pageSize
	order by query.sort_row '

--select @countSelect
--select @from
--select @resultsSelect
--select @Cmd

exec		sp_executesql		 	
			@Cmd				=	@Cmd,
			@Params				=	N'@startRow bigint, @pageSize bigint, @startdate datetime, @enddate datetime, @itemCount INT OUTPUT',
			@startRow			=	@startRow,
			@pageSize			=	@pageSize,
			@startdate				=	@startdate,
			@enddate				=	@enddate,
			@itemCount			=	@itemCount OUTPUT
			
return 0
GO
/****** Object:  Table [dbo].[Notification]    Script Date: 09/02/2013 13:37:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Notification](
	[NotificationId] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Subject] [nvarchar](200) NOT NULL,
	[Body] [nvarchar](max) NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[CreatedByUserId] [uniqueidentifier] NOT NULL,
	[CreatedUtcDate] [datetime] NOT NULL,
	[ModifiedByUserId] [uniqueidentifier] NULL,
	[ModifiedUtcDate] [datetime] NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_Notification] PRIMARY KEY CLUSTERED 
(
	[NotificationId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InspectionStatus]    Script Date: 09/02/2013 13:37:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InspectionStatus](
	[InspectionStatusId] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_InspectionStatus] PRIMARY KEY CLUSTERED 
(
	[InspectionStatusId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Import]    Script Date: 09/02/2013 13:37:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Import](
	[F1] [float] NULL,
	[F2] [nvarchar](255) NULL,
	[F3] [nvarchar](255) NULL
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[p_Booking__Slot]    Script Date: 09/02/2013 13:37:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[p_Booking__Slot]
@startRow bigint, @pageSize bigint, @sortBy NVARCHAR (100), @sortDir NVARCHAR (4), @technicianId int = null, @date datetime, @time datetime = NULL, @itemCount INT OUTPUT
AS
set nocount on

declare @countSelect nvarchar(max)
declare @resultsSelect nvarchar(max)
declare @from nvarchar(max)
declare @orderby nvarchar(max)
declare @groupBy nvarchar(max)
declare @Cmd nvarchar(max)


	select		@OrderBy		=	case @sortBy
										when 'Id' then 'Booking.BookingId'
										when 'Technician.Name' then 'UserProfile.FirstName + '' '' + UserProfile.LastName'
										else @sortBy + ' '
									end
								+	' '
								+	@sortDir


	set @countSelect = 'select 1 [row] '
	
	set @from = '
		from   dbo.Booking '

	if @technicianId is null
		begin	
			if @time is null
				set @from = @from + ' inner join PropertyInfo on Booking.PropertyInfoId = PropertyInfo.PropertyInfoId And Booking.Date = @date And Booking.Time IS NULL And Booking.TechnicianId IS NULL '
			else
				set @from = @from + ' inner join PropertyInfo on Booking.PropertyInfoId = PropertyInfo.PropertyInfoId And Booking.Date = @date And Booking.Time = @time And Booking.TechnicianId IS NULL '
		end
	else
		begin
			if @time is null
				set @from = @from + ' inner join PropertyInfo on Booking.PropertyInfoId = PropertyInfo.PropertyInfoId And Booking.Date = @date And Booking.Time IS NULL And Booking.TechnicianId = @technicianId '
			else
				set @from = @from + ' inner join PropertyInfo on Booking.PropertyInfoId = PropertyInfo.PropertyInfoId And Booking.Date = @date And Booking.Time = @time And Booking.TechnicianId = @technicianId '
		end
			
	set @from = @from + ' left outer join State on PropertyInfo.StateId = State.StateId 
		left outer join ServiceSheet on Booking.BookingId = ServiceSheet.BookingId
		left outer join Agency on PropertyInfo.AgencyId = Agency.AgencyId 
		left outer join Technician on Booking.TechnicianId = Technician.TechnicianId 
		left outer join UserProfile on Booking.TechnicianId = UserProfile.TechnicianId
		left outer join PropertyManager on PropertyInfo.PropertyManagerId = PropertyManager.PropertyManagerId
		left outer join InspectionStatus on PropertyInfo.InspectionStatusId = InspectionStatus.InspectionStatusId 
		left outer join ElectricalWorkStatus on PropertyInfo.ElectricalWorkStatusId = ElectricalWorkStatus.ElectricalWorkStatusId
		where	PropertyInfo.IsDeleted = 0 AND Booking.IsDeleted = 0 AND PropertyInfo.IsCancelled = 0 '
		

	set @groupBy = ' group by
			Booking.BookingId
			,PropertyInfo.PropertyInfoId 
			,PropertyInfo.PropertyNumber
			,PropertyInfo.UnitShopNumber
			,PropertyInfo.StreetNumber
			,PropertyInfo.StreetName
			,PropertyInfo.Suburb
			,State.Name
			,PropertyInfo.PostCode
			,PropertyInfo.LastServicedDate
			,dbo.f_NextServiceDate(PropertyInfo.LastServicedDate, PropertyInfo.SettlementDate, PropertyInfo.CreatedUtcDate)
			,PropertyInfo.InspectionStatusId
			,InspectionStatus.Name
			,PropertyInfo.ElectricalWorkStatusId
			,ElectricalWorkStatus.Name	
			,Booking.TechnicianId
			,UserProfile.FirstName + '' '' + UserProfile.LastName
			,Booking.Date
			,Booking.Time
			,Booking.Duration
			,Agency.Name
			,PropertyManager.Name
			,Booking.KeyNumber
			,Booking.Notes
			,CAST(ISNULL(ServiceSheet.ServiceSheetId, 0) as bit)
			,PropertyInfo.ContactNotes
			,OccupantName
			,ConcatenatedTenantContactNumber
			,PropertyInfo.HasProblem
			,PropertyInfo.HasLargeLadder
			,Booking.RowVersion '

	set @resultsSelect = ' 
		select
			Booking.BookingId [Id]
			,PropertyInfo.PropertyInfoId
			,PropertyInfo.PropertyNumber
			,PropertyInfo.UnitShopNumber
			,PropertyInfo.StreetNumber
			,PropertyInfo.StreetName
			,PropertyInfo.Suburb
			,State.Name [State]
			,PropertyInfo.PostCode
			,PropertyInfo.LastServicedDate
			,dbo.f_NextServiceDate(PropertyInfo.LastServicedDate, PropertyInfo.SettlementDate, PropertyInfo.CreatedUtcDate) [NextServiceDate]
			,PropertyInfo.InspectionStatusId [InspectionStatusEnum]
			,InspectionStatus.Name [InspectionStatus]
			,PropertyInfo.ElectricalWorkStatusId [ElectricalWorkStatusEnum]
			,ElectricalWorkStatus.Name [ElectricalWorkStatus]
			,Booking.TechnicianId
			,UserProfile.FirstName + '' '' + UserProfile.LastName [TechnicianName]
			,Booking.Date [BookingDate]
			,Booking.Time [BookingTime]
			,Booking.Duration
			,Agency.Name	[Agency]
			,PropertyManager.Name [PropertyManager]
			,OccupantName [TenantName]
			,ConcatenatedTenantContactNumber [TenantContactNumber]
			,PropertyInfo.HasProblem
			,PropertyInfo.HasLargeLadder
			,Booking.KeyNumber
			,Booking.Notes
			,CAST(ISNULL(ServiceSheet.ServiceSheetId, 0) as bit) [HasServiceSheet]
			,PropertyInfo.ContactNotes
			,Booking.RowVersion
			,row_number() '
			
	set @resultsSelect = @resultsSelect + ' over(order by ' + @orderby + ') as [sort_row]'

	set @Cmd = '
	select @itemcount = count(row) from (' + @countSelect + @from + @groupby + ') as countquery;
	select * from (' + @resultsSelect + @from + @groupBy + ' ) as query
	where    query.sort_row between @startRow and @startRow + @pageSize
	order by query.sort_row '

--select @countSelect
--select @from
--select @resultsSelect
--select @Cmd

exec		sp_executesql		 	
			@Cmd				=	@Cmd,
			@Params				=	N'@startRow bigint, @pageSize bigint, @technicianId int=null, @date datetime, @time datetime=null, @itemCount INT OUTPUT',
			@startRow			=	@startRow,
			@pageSize			=	@pageSize,
			@technicianId		=	@technicianId,
			@date				=	@date,
			@time				=	@time,
			@itemCount			=	@itemCount OUTPUT
			
return 0
GO
/****** Object:  StoredProcedure [dbo].[p_Booking__Date]    Script Date: 09/02/2013 13:37:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Script Template
-- =============================================

CREATE PROCEDURE [dbo].[p_Booking__Date]
@startRow bigint, @pageSize bigint, @sortBy NVARCHAR (100), @sortDir NVARCHAR (4), @startdate datetime, @enddate datetime, @itemCount INT OUTPUT
AS
set nocount on

declare @countSelect nvarchar(max)
declare @resultsSelect nvarchar(max)
declare @from nvarchar(max)
declare @orderby nvarchar(max)
declare @groupBy nvarchar(max)
declare @Cmd nvarchar(max)


	select		@OrderBy		=	case @sortBy
										when 'Id' then 'Booking.BookingId'
										when 'Technician.Name' then 'UserProfile.FirstName + '' '' + UserProfile.LastName'
										else @sortBy + ' '
									end
								+	' '
								+	@sortDir


	set @countSelect = 'select 1 [row] '
	
	set @from = '
		from   dbo.Booking '

	set @from = @from + ' inner join PropertyInfo on Booking.PropertyInfoId = PropertyInfo.PropertyInfoId And Booking.Date BETWEEN @startdate AND @enddate '
	
			
	set @from = @from + ' left outer join State on PropertyInfo.StateId = State.StateId 
		left outer join ServiceSheet on Booking.BookingId = ServiceSheet.BookingId
		left outer join Agency on PropertyInfo.AgencyId = Agency.AgencyId 
		left outer join Technician on Booking.TechnicianId = Technician.TechnicianId 
		left outer join UserProfile on Booking.TechnicianId = UserProfile.TechnicianId
		left outer join PropertyManager on PropertyInfo.PropertyManagerId = PropertyManager.PropertyManagerId
		left outer join InspectionStatus on PropertyInfo.InspectionStatusId = InspectionStatus.InspectionStatusId 
		left outer join ElectricalWorkStatus on PropertyInfo.ElectricalWorkStatusId = ElectricalWorkStatus.ElectricalWorkStatusId
		where	PropertyInfo.IsDeleted = 0 AND Booking.IsDeleted = 0 '
		

	set @groupBy = ' group by
			Booking.BookingId
			,PropertyInfo.PropertyInfoId 
			,PropertyInfo.PropertyNumber
			,PropertyInfo.UnitShopNumber
			,PropertyInfo.StreetNumber
			,PropertyInfo.StreetName
			,PropertyInfo.Suburb
			,State.Name
			,PropertyInfo.PostCode
			,PropertyInfo.LastServicedDate
			,dbo.f_NextServiceDate(PropertyInfo.LastServicedDate, PropertyInfo.SettlementDate, PropertyInfo.CreatedUtcDate)
			,PropertyInfo.InspectionStatusId
			,InspectionStatus.Name
			,PropertyInfo.ElectricalWorkStatusId
			,ElectricalWorkStatus.Name	
			,Booking.TechnicianId
			,UserProfile.FirstName + '' '' + UserProfile.LastName
			,Booking.Date
			,Booking.Time
			,Booking.Duration
			,Agency.Name
			,PropertyManager.Name
			,Booking.KeyNumber
			,Booking.Notes
			,CAST(ISNULL(ServiceSheet.ServiceSheetId, 0) as bit)
			,PropertyInfo.ContactNotes
			,OccupantName
			,ConcatenatedTenantContactNumber
			,PropertyInfo.HasProblem
			,PropertyInfo.HasLargeLadder
			,Booking.RowVersion '

	set @resultsSelect = ' 
		select
			Booking.BookingId [Id]
			,PropertyInfo.PropertyInfoId
			,PropertyInfo.PropertyNumber
			,PropertyInfo.UnitShopNumber
			,PropertyInfo.StreetNumber
			,PropertyInfo.StreetName
			,PropertyInfo.Suburb
			,State.Name [State]
			,PropertyInfo.PostCode
			,PropertyInfo.LastServicedDate
			,dbo.f_NextServiceDate(PropertyInfo.LastServicedDate, PropertyInfo.SettlementDate, PropertyInfo.CreatedUtcDate) [NextServiceDate]
			,PropertyInfo.InspectionStatusId [InspectionStatusEnum]
			,InspectionStatus.Name [InspectionStatus]
			,PropertyInfo.ElectricalWorkStatusId [ElectricalWorkStatusEnum]
			,ElectricalWorkStatus.Name [ElectricalWorkStatus]
			,Booking.TechnicianId
			,UserProfile.FirstName + '' '' + UserProfile.LastName [TechnicianName]
			,Booking.Date [BookingDate]
			,Booking.Time [BookingTime]
			,Booking.Duration
			,Agency.Name	[Agency]
			,PropertyManager.Name [PropertyManager]
			,PropertyInfo.OccupantName [TenantName]
			,[dbo].[f_PropertyInfo__ConcatenateTenantContactNumber](PropertyInfo.PropertyInfoId) [TenantContactNumber]
			,PropertyInfo.HasProblem
			,PropertyInfo.HasLargeLadder
			,Booking.KeyNumber
			,Booking.Notes
			,CAST(ISNULL(ServiceSheet.ServiceSheetId, 0) as bit) [HasServiceSheet]
			,PropertyInfo.ContactNotes
			,Booking.RowVersion
			,row_number() '
			
	set @resultsSelect = @resultsSelect + ' over(order by ' + @orderby + ') as [sort_row]'

	set @Cmd = '
	select @itemcount = count(row) from (' + @countSelect + @from + @groupby + ') as countquery;
	select * from (' + @resultsSelect + @from + @groupBy + ' ) as query
	where    query.sort_row between @startRow and @startRow + @pageSize
	order by query.sort_row '

--select @countSelect
--select @from
--select @resultsSelect
--select @Cmd

exec		sp_executesql		 	
			@Cmd				=	@Cmd,
			@Params				=	N'@startRow bigint, @pageSize bigint, @startdate datetime, @enddate datetime, @itemCount INT OUTPUT',
			@startRow			=	@startRow,
			@pageSize			=	@pageSize,
			@startdate				=	@startdate,
			@enddate				=	@enddate,
			@itemCount			=	@itemCount OUTPUT
			
return 0
GO
/****** Object:  Table [dbo].[ElectricalWorkStatus]    Script Date: 09/02/2013 13:37:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ElectricalWorkStatus](
	[ElectricalWorkStatusId] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_ElectricalWorkStatus] PRIMARY KEY CLUSTERED 
(
	[ElectricalWorkStatusId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DMS_AUDITTAB]    Script Date: 09/02/2013 13:37:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DMS_AUDITTAB](
	[runid] [varchar](100) NOT NULL,
	[ruleid] [varchar](50) NOT NULL,
	[rulestatus] [char](1) NULL,
	[rulecreated] [datetime] NOT NULL,
	[ruleupdated] [datetime] NULL,
	[ruleblock] [int] NULL,
	[rulenum] [int] NULL,
	[rulesubscript] [int] NULL,
	[ruletype] [varchar](50) NULL,
	[ruletarget] [varchar](100) NULL,
	[rstat1] [int] NULL,
	[rstat2] [int] NULL,
	[rstat3] [int] NULL,
	[rstat4] [decimal](18, 0) NULL,
	[rstat5] [datetime] NULL,
	[rstat6] [varchar](50) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
CREATE NONCLUSTERED INDEX [IX_DMS_AUDITTAB] ON [dbo].[DMS_AUDITTAB] 
(
	[runid] ASC,
	[ruleid] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DetectorType]    Script Date: 09/02/2013 13:37:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DetectorType](
	[DetectorTypeId] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[IsMain] [bit] NULL,
	[IsSecurity] [bit] NULL,
 CONSTRAINT [PK_DetectorType] PRIMARY KEY CLUSTERED 
(
	[DetectorTypeId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DetectorType_IsMain] ON [dbo].[DetectorType] 
(
	[IsMain] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[f_IntSplit]    Script Date: 09/02/2013 13:37:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[f_IntSplit]
(@ValueList NVARCHAR (MAX), @SplitOn NVARCHAR (5))
RETURNS 
    @Result TABLE (
        [Index] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY CLUSTERED ([Index] ASC) WITH (ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, STATISTICS_NORECOMPUTE = OFF),
        [Value] INT NULL)
AS
begin 
      while (charindex(@SplitOn, @ValueList) > 0)
      begin
            insert      @Result (Value)
            select      convert(int, ltrim(rtrim(substring(@ValueList, 1, charindex(@SplitOn, @ValueList) - 1))))

            set         @ValueList = substring(@ValueList, charindex(@SplitOn, @ValueList) + 1, len(@ValueList))
      end

      insert      @Result (Value)
      select      convert(int, ltrim(rtrim(@ValueList)))

      return
end
GO
/****** Object:  UserDefinedFunction [dbo].[f_FormatDate]    Script Date: 09/02/2013 13:37:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[f_FormatDate]
(@Date DATETIME)
RETURNS NVARCHAR (50)
AS
begin
	-- Declare the return variable here
	declare		@Result				nvarchar(50)

	select		@Result			=	convert(varchar(50), @Date, 103)

	return @Result
end
GO
/****** Object:  UserDefinedFunction [dbo].[f_FirstOfMonth]    Script Date: 09/02/2013 13:37:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[f_FirstOfMonth]
(@Date DATETIME)
RETURNS DATETIME
AS
begin
	RETURN DATEADD(month, DATEDIFF(month,0,@date), 0)
end
GO
/****** Object:  Table [dbo].[AspNet_SqlCacheTablesForChangeNotification]    Script Date: 09/02/2013 13:37:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNet_SqlCacheTablesForChangeNotification](
	[tableName] [nvarchar](450) NOT NULL,
	[notificationCreated] [datetime] NOT NULL,
	[changeId] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[tableName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ClientDatabaseSystem]    Script Date: 09/02/2013 13:37:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientDatabaseSystem](
	[ClientDatabaseSystemId] [int] NOT NULL,
	[Name] [nchar](32) NOT NULL,
 CONSTRAINT [PK_ClientDatabase] PRIMARY KEY CLUSTERED 
(
	[ClientDatabaseSystemId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[aspnet_WebEvent_Events]    Script Date: 09/02/2013 13:37:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[aspnet_WebEvent_Events](
	[EventId] [char](32) NOT NULL,
	[EventTimeUtc] [datetime] NOT NULL,
	[EventTime] [datetime] NOT NULL,
	[EventType] [nvarchar](256) NOT NULL,
	[EventSequence] [decimal](19, 0) NOT NULL,
	[EventOccurrence] [decimal](19, 0) NOT NULL,
	[EventCode] [int] NOT NULL,
	[EventDetailCode] [int] NOT NULL,
	[Message] [nvarchar](1024) NULL,
	[ApplicationPath] [nvarchar](256) NULL,
	[ApplicationVirtualPath] [nvarchar](256) NULL,
	[MachineName] [nvarchar](256) NOT NULL,
	[RequestUrl] [nvarchar](1024) NULL,
	[ExceptionType] [nvarchar](256) NULL,
	[Details] [ntext] NULL,
PRIMARY KEY CLUSTERED 
(
	[EventId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Audit]    Script Date: 09/02/2013 13:37:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Audit](
	[AuditId] [bigint] IDENTITY(1,1) NOT NULL,
	[Description] [nvarchar](500) NOT NULL,
	[CreatedUtcDate] [datetime] NOT NULL,
	[UserId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_Audit] PRIMARY KEY CLUSTERED 
(
	[AuditId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AuditActionType]    Script Date: 09/02/2013 13:37:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AuditActionType](
	[AuditActionTypeId] [int] NOT NULL,
	[Name] [nvarchar](20) NOT NULL,
 CONSTRAINT [PK_AuditActionType] PRIMARY KEY CLUSTERED 
(
	[AuditActionTypeId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[State]    Script Date: 09/02/2013 13:37:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[State](
	[StateId] [int] NOT NULL,
	[Name] [nvarchar](3) NOT NULL,
 CONSTRAINT [PK_State] PRIMARY KEY CLUSTERED 
(
	[StateId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[p_User__Search]    Script Date: 09/02/2013 13:37:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[p_User__Search]
@RoleIds NVARCHAR (MAX), @IsEnabled BIT=NULL, @IsLockedOut BIT=NULL, @PageNumber INT=1, @PageSize INT=20, @SortAscending BIT=1, @SortBy NVARCHAR (50)='FirstName', @ItemCount INT=null OUTPUT
AS
set nocount on

declare		@Cmd					nvarchar(max),
			@From					nvarchar(max),
			@OrderBy				nvarchar(max),
			@FirstResult			int,
			@LastResult				int

select		@FirstResult	=	((@PageNumber - 1) * @PageSize) + 1,
			@LastResult		=	@FirstResult + @PageSize

select		@OrderBy			=	case @SortBy
										when 'FirstName' then 'p.FirstName'
										when 'LastName' then 'p.LastName'
										when 'EmailAddress' then 'm.Email'
										when 'LastLoginUtcDate' then 'case m.LastLoginDate when m.CreateDate then null else m.LastLoginDate end'
									end
								+	' '
								+	case @SortAscending
										when 1 then	
											'asc'
										else	
											'desc'
									end

select		@From				=	'			UserProfile				p
									inner join	aspnet_Membership		m
										on		m.UserId			=	p.UserId
									inner join	aspnet_Users			u
										on		u.UserId			=	p.UserId
									
									where		
												(@IsEnabled IS NULL OR		m.IsApproved		=	@IsEnabled)
										and		(@IsLockedOut IS NULL OR	m.IsLockedOut		=	@IsLockedOut)
										and		(ISNULL(p.IsDeleted, 0) = 0)
										
									'
									
if @RoleIds <> ''
begin
	set @From = @From +				'	
										and		exists
												(
													select		1
													from		UserRole				ur
													inner join	dbo.f_IntSplit(@RoleIDs, '','')		r
														on		r.Value				=	ur.RoleId
													where		ur.UserId			=	p.UserId
												)'
end

									

select		@Cmd				=  'select		@ItemCount = count(*)
									from		' + @From
									
--select		@Cmd									

exec		sp_executesql		 	
			@Cmd				=	@Cmd,
			@Params				=	N'@IsEnabled bit, @IsLockedOut bit, @RoleIDs nvarchar(max), @ItemCount int = null output',
			@IsEnabled			=	@IsEnabled,
			@IsLockedOut		=	@IsLockedOut,
			@RoleIDs			=	@RoleIDs,
			@ItemCount			=	@ItemCount		output


select		@Cmd				=  'select * from
									(
										select		p.*,
													p.FirstName + '' '' + p.LastName		FullName,
													u.UserName,
													m.Email,
													m.IsApproved,
													m.IsLockedOut,
													case m.LastLoginDate
														when m.CreateDate then	
															null
														else
															m.LastLoginDate
													end						LastLoginDate,
													row_number() over
													(
														order by		' + @OrderBy + '
													)						RowNumber
										from		' + @From
								+	') as q
									where			q.RowNumber		>=	@FirstResult 
										and			q.RowNumber		<	@LastResult'		
									
--select		@Cmd

exec		sp_executesql		 	
			@Cmd				=	@Cmd,
			@Params				=	N'@IsEnabled bit, @IsLockedOut bit, @RoleIDs nvarchar(max), @FirstResult int, @LastResult int',
			@IsEnabled			=	@IsEnabled,
			@IsLockedOut		=	@IsLockedOut,
			@RoleIDs			=	@RoleIDs,
			@FirstResult		=	@FirstResult,
			@LastResult			=	@LastResult
-- done
return 0
GO
/****** Object:  View [dbo].[v_DynamicReadyForServiceStatus]    Script Date: 09/02/2013 13:37:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  VIEW [dbo].[v_DynamicReadyForServiceStatus]  
AS  
SELECT 1 AS ComingUpForServiceStatusId, 2 AS NewPropertyStatusId, 3 AS OverdueStatusId
GO
/****** Object:  Table [dbo].[Zone]    Script Date: 09/02/2013 13:37:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Zone](
	[ZoneId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Zone] PRIMARY KEY CLUSTERED 
(
	[ZoneId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Technician]    Script Date: 09/02/2013 13:37:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Technician](
	[TechnicianId] [int] IDENTITY(1,1) NOT NULL,
	[Company] [nvarchar](100) NULL,
	[Telephone] [nvarchar](12) NULL,
	[Mobile] [nvarchar](12) NULL,
	[Address] [nvarchar](max) NULL,
	[Suburb] [nvarchar](50) NULL,
	[PostCode] [nvarchar](4) NULL,
	[StateId] [int] NULL,
	[Notes] [nvarchar](max) NULL,
	[Availability] [nvarchar](max) NOT NULL,
	[IsDeleted] [bit] NULL,
	[CreatedByUserId] [uniqueidentifier] NULL,
	[CreatedUtcDate] [datetime] NULL,
	[ModifiedByUserId] [uniqueidentifier] NULL,
	[ModifiedUtcDate] [datetime] NULL,
	[RowVersion] [timestamp] NULL,
 CONSTRAINT [PK_Technician] PRIMARY KEY CLUSTERED 
(
	[TechnicianId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PropertyInfo_History]    Script Date: 09/02/2013 13:37:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PropertyInfo_History](
	[PropertyInfoId] [int] NOT NULL,
	[PropertyNumber] [int] NULL,
	[AgencyId] [int] NULL,
	[PropertyManagerId] [int] NULL,
	[HasSendNotification] [bit] NULL,
	[HasLargeLadder] [bit] NULL,
	[KeyNumber] [nvarchar](50) NULL,
	[UnitShopNumber] [nvarchar](50) NULL,
	[StreetNumber] [nvarchar](50) NULL,
	[StreetName] [nvarchar](500) NULL,
	[Suburb] [nvarchar](50) NULL,
	[StateId] [int] NULL,
	[PostCode] [nvarchar](4) NULL,
	[ZoneId] [int] NULL,
	[OccupantName] [nvarchar](max) NULL,
	[OccupantEmail] [nvarchar](max) NULL,
	[PostalAddress] [nvarchar](max) NULL,
	[PostalSuburb] [nvarchar](50) NULL,
	[PostalPostcode] [nvarchar](4) NULL,
	[PostalStateId] [int] NULL,
	[PostalCountry] [nvarchar](50) NULL,
	[Notes] [nvarchar](max) NULL,
	[IsCancelled] [bit] NULL,
	[CancellationNotes] [nvarchar](max) NULL,
	[CancellationDate] [datetime] NULL,
	[SettlementDate] [datetime] NULL,
	[PropertyHoldDate] [datetime] NULL,
	[Discount] [money] NULL,
	[LastServicedDate] [datetime] NULL,
	[NextServiceDate] [datetime] NULL,
	[InspectionStatusUpdatedDate] [datetime] NULL,
	[InspectionStatusId] [int] NULL,
	[ElectricalWorkStatusUpdatedDate] [datetime] NULL,
	[ElectricalWorkStatusId] [int] NULL,
	[HasProblem] [bit] NULL,
	[ProblemStatusUpdatedDate] [datetime] NULL,
	[ProblemNotes] [nvarchar](max) NULL,
	[ContactNotes] [nvarchar](max) NULL,
	[IsOneOffService] [bit] NULL,
	[IsServiceCompleted] [bit] NULL,
	[LandlordName] [nvarchar](100) NULL,
	[LandlordAddress] [nvarchar](max) NULL,
	[LandlordSuburb] [nvarchar](50) NULL,
	[LandlordPostcode] [nvarchar](4) NULL,
	[LandlordStateId] [int] NULL,
	[LandlordCountry] [nvarchar](50) NULL,
	[LandlordEmail] [nvarchar](400) NULL,
	[ConcatenatedTenantName] [nvarchar](max) NULL,
	[ConcatenatedTenantContactNumber] [nvarchar](max) NULL,
	[IsDeleted] [bit] NULL,
	[CreatedByUserId] [uniqueidentifier] NULL,
	[CreatedUtcDate] [datetime] NULL,
	[ModifiedByUserId] [uniqueidentifier] NULL,
	[ModifiedUtcDate] [datetime] NULL,
	[DiscountPercentage] [decimal](18, 2) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PropertyBatch]    Script Date: 09/02/2013 13:37:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PropertyBatch](
	[PropertyBatchId] [int] IDENTITY(1,1) NOT NULL,
	[Date] [datetime] NULL,
	[Notes] [nvarchar](max) NULL,
	[BulkActionId] [int] NULL,
	[StatusId] [int] NULL,
	[CreatedUtcDate] [datetime] NULL,
	[CreatedByUserId] [uniqueidentifier] NULL,
	[ModifiedUtcDate] [datetime] NULL,
	[ModifiedByUserId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_PropertyBatch] PRIMARY KEY CLUSTERED 
(
	[PropertyBatchId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ServiceItem]    Script Date: 09/02/2013 13:37:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ServiceItem](
	[ServiceItemId] [int] IDENTITY(1,1) NOT NULL,
	[Code] [nvarchar](200) NOT NULL,
	[Name] [nvarchar](max) NOT NULL,
	[Price] [money] NOT NULL,
	[IsDeleted] [bit] NULL,
	[CreatedByUserId] [uniqueidentifier] NULL,
	[CreatedUtcDate] [datetime] NULL,
	[ModifiedByUserId] [uniqueidentifier] NULL,
	[ModifiedUtcDate] [datetime] NULL,
	[RowVersion] [timestamp] NULL,
	[QuickBooksCode] [nvarchar](400) NULL,
	[QuickBooksDescription] [nvarchar](1000) NULL,
	[QuickBooksFreeAndFixedFeeDescription] [nvarchar](max) NULL,
 CONSTRAINT [PK_ServiceItem] PRIMARY KEY CLUSTERED 
(
	[ServiceItemId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TechnicianAvailability]    Script Date: 09/02/2013 13:37:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TechnicianAvailability](
	[TechnicianAvailabilityId] [int] IDENTITY(1,1) NOT NULL,
	[TechnicianId] [int] NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[StartTime] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[Notes] [nvarchar](max) NULL,
	[IsInclusion] [bit] NOT NULL,
	[IsDeleted] [bit] NULL,
	[CreatedByUserId] [uniqueidentifier] NULL,
	[CreatedUtcDate] [datetime] NULL,
	[ModifiedByUserId] [uniqueidentifier] NULL,
	[ModifiedUtcDate] [datetime] NULL,
	[RowVersion] [timestamp] NULL,
 CONSTRAINT [PK_TechnicianAvailability] PRIMARY KEY CLUSTERED 
(
	[TechnicianAvailabilityId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Permission]    Script Date: 09/02/2013 13:37:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Permission](
	[PermissionId] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[ApplicationAreaId] [int] NULL,
 CONSTRAINT [PK_Permission] PRIMARY KEY CLUSTERED 
(
	[PermissionId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[ReadyForServiceStatus]    Script Date: 09/02/2013 13:37:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ReadyForServiceStatus]  
AS  
SELECT InspectionStatusId  
FROM InspectionStatus  
WHERE Name = 'Ready For Service'
GO
/****** Object:  Table [dbo].[AuditAction]    Script Date: 09/02/2013 13:37:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AuditAction](
	[AuditActionId] [bigint] IDENTITY(1,1) NOT NULL,
	[AuditId] [bigint] NOT NULL,
	[EntityType] [nvarchar](50) NOT NULL,
	[EntityKey] [nvarchar](50) NOT NULL,
	[AuditActionTypeId] [int] NOT NULL,
	[JobId] [int] NULL,
	[ContactId] [int] NULL,
	[PropertyName] [nvarchar](50) NOT NULL,
	[PreviousValue] [nvarchar](max) NULL,
	[CurrentValue] [nvarchar](max) NULL,
 CONSTRAINT [PK_AuditAction] PRIMARY KEY CLUSTERED 
(
	[AuditActionId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[aspnet_WebEvent_LogEvent]    Script Date: 09/02/2013 13:37:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[aspnet_WebEvent_LogEvent]
@EventId CHAR (32), @EventTimeUtc DATETIME, @EventTime DATETIME, @EventType NVARCHAR (256), @EventSequence DECIMAL (19), @EventOccurrence DECIMAL (19), @EventCode INT, @EventDetailCode INT, @Message NVARCHAR (1024), @ApplicationPath NVARCHAR (256), @ApplicationVirtualPath NVARCHAR (256), @MachineName NVARCHAR (256), @RequestUrl NVARCHAR (1024), @ExceptionType NVARCHAR (256), @Details NTEXT
AS
BEGIN
    INSERT
        dbo.aspnet_WebEvent_Events
        (
            EventId,
            EventTimeUtc,
            EventTime,
            EventType,
            EventSequence,
            EventOccurrence,
            EventCode,
            EventDetailCode,
            Message,
            ApplicationPath,
            ApplicationVirtualPath,
            MachineName,
            RequestUrl,
            ExceptionType,
            Details
        )
    VALUES
    (
        @EventId,
        @EventTimeUtc,
        @EventTime,
        @EventType,
        @EventSequence,
        @EventOccurrence,
        @EventCode,
        @EventDetailCode,
        @Message,
        @ApplicationPath,
        @ApplicationVirtualPath,
        @MachineName,
        @RequestUrl,
        @ExceptionType,
        @Details
    )
END
GO
/****** Object:  StoredProcedure [dbo].[AspNet_SqlCacheRegisterTableStoredProcedure]    Script Date: 09/02/2013 13:37:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AspNet_SqlCacheRegisterTableStoredProcedure]
@tableName NVARCHAR (450)
AS
BEGIN

         DECLARE @triggerName AS NVARCHAR(3000) 
         DECLARE @fullTriggerName AS NVARCHAR(3000)
         DECLARE @canonTableName NVARCHAR(3000) 
         DECLARE @quotedTableName NVARCHAR(3000) 

         /* Create the trigger name */ 
         SET @triggerName = REPLACE(@tableName, '[', '__o__') 
         SET @triggerName = REPLACE(@triggerName, ']', '__c__') 
         SET @triggerName = @triggerName + '_AspNet_SqlCacheNotification_Trigger' 
         SET @fullTriggerName = 'dbo.[' + @triggerName + ']' 

         /* Create the cannonicalized table name for trigger creation */ 
         /* Do not touch it if the name contains other delimiters */ 
         IF (CHARINDEX('.', @tableName) <> 0 OR 
             CHARINDEX('[', @tableName) <> 0 OR 
             CHARINDEX(']', @tableName) <> 0) 
             SET @canonTableName = @tableName 
         ELSE 
             SET @canonTableName = '[' + @tableName + ']' 

         /* First make sure the table exists */ 
         IF (SELECT OBJECT_ID(@tableName, 'U')) IS NULL 
         BEGIN 
             RAISERROR ('00000001', 16, 1) 
             RETURN 
         END 

         BEGIN TRAN
         /* Insert the value into the notification table */ 
         IF NOT EXISTS (SELECT tableName FROM dbo.AspNet_SqlCacheTablesForChangeNotification WITH (NOLOCK) WHERE tableName = @tableName) 
             IF NOT EXISTS (SELECT tableName FROM dbo.AspNet_SqlCacheTablesForChangeNotification WITH (TABLOCKX) WHERE tableName = @tableName) 
                 INSERT  dbo.AspNet_SqlCacheTablesForChangeNotification 
                 VALUES (@tableName, GETDATE(), 0)

         /* Create the trigger */ 
         SET @quotedTableName = QUOTENAME(@tableName, '''') 
         IF NOT EXISTS (SELECT name FROM sysobjects WITH (NOLOCK) WHERE name = @triggerName AND type = 'TR') 
             IF NOT EXISTS (SELECT name FROM sysobjects WITH (TABLOCKX) WHERE name = @triggerName AND type = 'TR') 
                 EXEC('CREATE TRIGGER ' + @fullTriggerName + ' ON ' + @canonTableName +'
                       FOR INSERT, UPDATE, DELETE AS BEGIN
                       SET NOCOUNT ON
                       EXEC dbo.AspNet_SqlCacheUpdateChangeIdStoredProcedure N' + @quotedTableName + '
                       END
                       ')
         COMMIT TRAN
         END
GO
/****** Object:  StoredProcedure [dbo].[AspNet_SqlCacheQueryRegisteredTablesStoredProcedure]    Script Date: 09/02/2013 13:37:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AspNet_SqlCacheQueryRegisteredTablesStoredProcedure]

AS
SELECT tableName FROM dbo.AspNet_SqlCacheTablesForChangeNotification
GO
/****** Object:  StoredProcedure [dbo].[AspNet_SqlCachePollingStoredProcedure]    Script Date: 09/02/2013 13:37:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AspNet_SqlCachePollingStoredProcedure]

AS
SELECT tableName, changeId FROM dbo.AspNet_SqlCacheTablesForChangeNotification
         RETURN 0
GO
/****** Object:  StoredProcedure [dbo].[aspnet_CheckSchemaVersion]    Script Date: 09/02/2013 13:37:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[aspnet_CheckSchemaVersion]
@Feature NVARCHAR (128), @CompatibleSchemaVersion NVARCHAR (128)
AS
BEGIN
    IF (EXISTS( SELECT  *
                FROM    dbo.aspnet_SchemaVersions
                WHERE   Feature = LOWER( @Feature ) AND
                        CompatibleSchemaVersion = @CompatibleSchemaVersion ))
        RETURN 0

    RETURN 1
END
GO
/****** Object:  StoredProcedure [dbo].[aspnet_Applications_CreateApplication]    Script Date: 09/02/2013 13:37:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[aspnet_Applications_CreateApplication]
@ApplicationName NVARCHAR (256), @ApplicationId UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    SELECT  @ApplicationId = ApplicationId FROM dbo.aspnet_Applications WHERE LOWER(@ApplicationName) = LoweredApplicationName

    IF(@ApplicationId IS NULL)
    BEGIN
        DECLARE @TranStarted   bit
        SET @TranStarted = 0

        IF( @@TRANCOUNT = 0 )
        BEGIN
	        BEGIN TRANSACTION
	        SET @TranStarted = 1
        END
        ELSE
    	    SET @TranStarted = 0

        SELECT  @ApplicationId = ApplicationId
        FROM dbo.aspnet_Applications WITH (UPDLOCK, HOLDLOCK)
        WHERE LOWER(@ApplicationName) = LoweredApplicationName

        IF(@ApplicationId IS NULL)
        BEGIN
            SELECT  @ApplicationId = NEWID()
            INSERT  dbo.aspnet_Applications (ApplicationId, ApplicationName, LoweredApplicationName)
            VALUES  (@ApplicationId, @ApplicationName, LOWER(@ApplicationName))
        END


        IF( @TranStarted = 1 )
        BEGIN
            IF(@@ERROR = 0)
            BEGIN
	        SET @TranStarted = 0
	        COMMIT TRANSACTION
            END
            ELSE
            BEGIN
                SET @TranStarted = 0
                ROLLBACK TRANSACTION
            END
        END
    END
END
GO
/****** Object:  UserDefinedFunction [dbo].[f_CalendarMonths]    Script Date: 09/02/2013 13:37:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[f_CalendarMonths]
(@date datetime)
RETURNS 
@Results TABLE 
(
	[CalendarMonth] varchar(MAX),
	[Month] int,
	[Year] int
)
AS
BEGIN


	IF @date IS NULL
	BEGIN
		SET @date = CONVERT(date, GETDATE())
	END

	DECLARE @startDate datetime, @endDate datetime

	SET @startDate = dbo.f_FirstOfMonth(@date)
	SET @endDate = DATEADD(day, -1, DATEADD(year, 1,@startDate));


	with    mycte as

			(

			select @startDate DateValue

			union all

			select DATEADD(month, 1, DateValue) 

			from    mycte    

			where   DATEADD(month, 1, DateValue)  < @endDate

			)

	INSERT INTO @Results(CalendarMonth, [Year], [Month])

	select  CAST(MONTH(DateValue) as varchar) + '/' + CAST(YEAR(DateValue) as varchar) [CalendarMonth],
	YEAR(DateValue) [Year],
	MONTH(DateValue) [Month]

	from    mycte

	OPTION  (MAXRECURSION 0)


	RETURN 



END
GO
/****** Object:  Table [dbo].[ContactEntry]    Script Date: 09/02/2013 13:37:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContactEntry](
	[ContactEntryId] [int] IDENTITY(1,1) NOT NULL,
	[PropertyInfoId] [int] NOT NULL,
	[ContactNumber] [nvarchar](50) NOT NULL,
	[ContactNumberTypeId] [int] NOT NULL,
	[IsDeleted] [bit] NULL,
	[CreatedByUserId] [uniqueidentifier] NULL,
	[CreatedUtcDate] [datetime] NULL,
	[ModifiedByUserId] [uniqueidentifier] NULL,
	[ModifiedUtcDate] [datetime] NULL,
	[RowVersion] [timestamp] NULL,
 CONSTRAINT [PK_TenantContactNumber] PRIMARY KEY CLUSTERED 
(
	[ContactEntryId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[aspnet_Paths]    Script Date: 09/02/2013 13:37:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[aspnet_Paths](
	[ApplicationId] [uniqueidentifier] NOT NULL,
	[PathId] [uniqueidentifier] NOT NULL,
	[Path] [nvarchar](256) NOT NULL,
	[LoweredPath] [nvarchar](256) NOT NULL,
PRIMARY KEY NONCLUSTERED 
(
	[PathId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Agency]    Script Date: 09/02/2013 13:37:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Agency](
	[AgencyId] [int] IDENTITY(1,1) NOT NULL,
	[AgencyGroupId] [int] NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[CustomerCode] [nvarchar](50) NOT NULL,
	[ConsoleVersionNumber] [nvarchar](50) NULL,
	[ABN] [nvarchar](11) NULL,
	[StreetAddress] [nvarchar](max) NULL,
	[StreetSuburb] [nvarchar](50) NULL,
	[StreetPostcode] [nvarchar](4) NULL,
	[StreetStateId] [int] NOT NULL,
	[PostalAddress] [nvarchar](max) NULL,
	[PostalSuburb] [nvarchar](50) NULL,
	[PostalPostcode] [nvarchar](4) NULL,
	[PostalStateId] [int] NULL,
	[Telephone] [nvarchar](12) NULL,
	[Fax] [nvarchar](12) NULL,
	[Email] [nvarchar](400) NULL,
	[Website] [nvarchar](400) NULL,
	[Discount] [money] NULL,
	[DefaultPropertyManagerId] [int] NULL,
	[IsCancelled] [bit] NULL,
	[IsDeleted] [bit] NULL,
	[CreatedByUserId] [uniqueidentifier] NULL,
	[CreatedUtcDate] [datetime] NULL,
	[ModifiedByUserId] [uniqueidentifier] NULL,
	[ModifiedUtcDate] [datetime] NULL,
	[RowVersion] [timestamp] NULL,
	[PostalLine1] [nvarchar](200) NULL,
	[PostalLine2] [nvarchar](200) NULL,
	[ClientDatabaseSystemId] [int] NULL,
	[ClientCreditorReference] [nvarchar](50) NULL,
	[IsFixedFeeService] [bit] NULL,
 CONSTRAINT [PK_Agency] PRIMARY KEY CLUSTERED 
(
	[AgencyId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[aspnet_Personalization_GetApplicationId]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[aspnet_Personalization_GetApplicationId]
@ApplicationName NVARCHAR (256), @ApplicationId UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    SELECT @ApplicationId = ApplicationId FROM dbo.aspnet_Applications WHERE LOWER(@ApplicationName) = LoweredApplicationName
END
GO
/****** Object:  Table [dbo].[aspnet_Users]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[aspnet_Users](
	[ApplicationId] [uniqueidentifier] NOT NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[UserName] [nvarchar](256) NOT NULL,
	[LoweredUserName] [nvarchar](256) NOT NULL,
	[MobileAlias] [nvarchar](16) NULL,
	[IsAnonymous] [bit] NOT NULL,
	[LastActivityDate] [datetime] NOT NULL,
PRIMARY KEY NONCLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[aspnet_UnRegisterSchemaVersion]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[aspnet_UnRegisterSchemaVersion]
@Feature NVARCHAR (128), @CompatibleSchemaVersion NVARCHAR (128)
AS
BEGIN
    DELETE FROM dbo.aspnet_SchemaVersions
        WHERE   Feature = LOWER(@Feature) AND @CompatibleSchemaVersion = CompatibleSchemaVersion
END
GO
/****** Object:  StoredProcedure [dbo].[AspNet_SqlCacheUpdateChangeIdStoredProcedure]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AspNet_SqlCacheUpdateChangeIdStoredProcedure]
@tableName NVARCHAR (450)
AS
BEGIN 
             UPDATE dbo.AspNet_SqlCacheTablesForChangeNotification WITH (ROWLOCK) SET changeId = changeId + 1 
             WHERE tableName = @tableName
         END
GO
/****** Object:  StoredProcedure [dbo].[AspNet_SqlCacheUnRegisterTableStoredProcedure]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AspNet_SqlCacheUnRegisterTableStoredProcedure]
@tableName NVARCHAR (450)
AS
BEGIN

         BEGIN TRAN
         DECLARE @triggerName AS NVARCHAR(3000) 
         DECLARE @fullTriggerName AS NVARCHAR(3000)
         SET @triggerName = REPLACE(@tableName, '[', '__o__') 
         SET @triggerName = REPLACE(@triggerName, ']', '__c__') 
         SET @triggerName = @triggerName + '_AspNet_SqlCacheNotification_Trigger' 
         SET @fullTriggerName = 'dbo.[' + @triggerName + ']' 

         /* Remove the table-row from the notification table */ 
         IF EXISTS (SELECT name FROM sysobjects WITH (NOLOCK) WHERE name = 'AspNet_SqlCacheTablesForChangeNotification' AND type = 'U') 
             IF EXISTS (SELECT name FROM sysobjects WITH (TABLOCKX) WHERE name = 'AspNet_SqlCacheTablesForChangeNotification' AND type = 'U') 
             DELETE FROM dbo.AspNet_SqlCacheTablesForChangeNotification WHERE tableName = @tableName 

         /* Remove the trigger */ 
         IF EXISTS (SELECT name FROM sysobjects WITH (NOLOCK) WHERE name = @triggerName AND type = 'TR') 
             IF EXISTS (SELECT name FROM sysobjects WITH (TABLOCKX) WHERE name = @triggerName AND type = 'TR') 
             EXEC('DROP TRIGGER ' + @fullTriggerName) 

         COMMIT TRAN
         END
GO
/****** Object:  StoredProcedure [dbo].[aspnet_RegisterSchemaVersion]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[aspnet_RegisterSchemaVersion]
@Feature NVARCHAR (128), @CompatibleSchemaVersion NVARCHAR (128), @IsCurrentVersion BIT, @RemoveIncompatibleSchema BIT
AS
BEGIN
    IF( @RemoveIncompatibleSchema = 1 )
    BEGIN
        DELETE FROM dbo.aspnet_SchemaVersions WHERE Feature = LOWER( @Feature )
    END
    ELSE
    BEGIN
        IF( @IsCurrentVersion = 1 )
        BEGIN
            UPDATE dbo.aspnet_SchemaVersions
            SET IsCurrentVersion = 0
            WHERE Feature = LOWER( @Feature )
        END
    END

    INSERT  dbo.aspnet_SchemaVersions( Feature, CompatibleSchemaVersion, IsCurrentVersion )
    VALUES( LOWER( @Feature ), @CompatibleSchemaVersion, @IsCurrentVersion )
END
GO
/****** Object:  Table [dbo].[aspnet_Profile]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[aspnet_Profile](
	[UserId] [uniqueidentifier] NOT NULL,
	[PropertyNames] [ntext] NOT NULL,
	[PropertyValuesString] [ntext] NOT NULL,
	[PropertyValuesBinary] [image] NOT NULL,
	[LastUpdatedDate] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[aspnet_PersonalizationAllUsers]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[aspnet_PersonalizationAllUsers](
	[PathId] [uniqueidentifier] NOT NULL,
	[PageSettings] [image] NOT NULL,
	[LastUpdatedDate] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PathId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[aspnet_PersonalizationPerUser]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[aspnet_PersonalizationPerUser](
	[Id] [uniqueidentifier] NOT NULL,
	[PathId] [uniqueidentifier] NULL,
	[UserId] [uniqueidentifier] NULL,
	[PageSettings] [image] NOT NULL,
	[LastUpdatedDate] [datetime] NOT NULL,
PRIMARY KEY NONCLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[aspnet_Membership]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[aspnet_Membership](
	[ApplicationId] [uniqueidentifier] NOT NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[Password] [nvarchar](128) NOT NULL,
	[PasswordFormat] [int] NOT NULL,
	[PasswordSalt] [nvarchar](128) NOT NULL,
	[MobilePIN] [nvarchar](16) NULL,
	[Email] [nvarchar](256) NULL,
	[LoweredEmail] [nvarchar](256) NULL,
	[PasswordQuestion] [nvarchar](256) NULL,
	[PasswordAnswer] [nvarchar](128) NULL,
	[IsApproved] [bit] NOT NULL,
	[IsLockedOut] [bit] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[LastLoginDate] [datetime] NOT NULL,
	[LastPasswordChangedDate] [datetime] NOT NULL,
	[LastLockoutDate] [datetime] NOT NULL,
	[FailedPasswordAttemptCount] [int] NOT NULL,
	[FailedPasswordAttemptWindowStart] [datetime] NOT NULL,
	[FailedPasswordAnswerAttemptCount] [int] NOT NULL,
	[FailedPasswordAnswerAttemptWindowStart] [datetime] NOT NULL,
	[Comment] [ntext] NULL,
PRIMARY KEY NONCLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[aspnet_Paths_CreatePath]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[aspnet_Paths_CreatePath]
@ApplicationId UNIQUEIDENTIFIER, @Path NVARCHAR (256), @PathId UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    BEGIN TRANSACTION
    IF (NOT EXISTS(SELECT * FROM dbo.aspnet_Paths WHERE LoweredPath = LOWER(@Path) AND ApplicationId = @ApplicationId))
    BEGIN
        INSERT dbo.aspnet_Paths (ApplicationId, Path, LoweredPath) VALUES (@ApplicationId, @Path, LOWER(@Path))
    END
    COMMIT TRANSACTION
    SELECT @PathId = PathId FROM dbo.aspnet_Paths WHERE LOWER(@Path) = LoweredPath AND ApplicationId = @ApplicationId
END
GO
/****** Object:  UserDefinedFunction [dbo].[f_IsComingUpForService]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[f_IsComingUpForService]          
(@StatusId int, @ServiceDate DATETIME, @PropertyHoldDate DATETIME, @CreatedUtcDate DATETIME)          
RETURNS bit          
AS          
begin          
 DECLARE @NextServiceDate DATETIME        
 DECLARE @ReadyForServiceStatus INT    
     
 SET @ReadyForServiceStatus = (SELECT TOP 1 InspectionStatusId FROM ReadyForServiceStatus)    
 SET @NextServiceDate = dbo.f_NextServiceDate(@ServiceDate, @PropertyHoldDate, @CreatedUtcDate)        
         
 RETURN (CASE WHEN @StatusId NOT IN (7,8,9,10,12) AND @NextServiceDate > DATEADD(ww, -6, GETDATE()) AND @NextServiceDate > GETDATE() AND @StatusId = @ReadyForServiceStatus THEN 1 ELSE 0 END)          
end
GO
/****** Object:  UserDefinedFunction [dbo].[f_IsOverDue]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[f_IsOverDue]    
(@StatusId int, @ServiceDate DATETIME, @PropertyHoldDate DATETIME, @CreatedUtcDate DATETIME)    
RETURNS bit    
AS    
begin   
 DECLARE @ReadyForServiceStatus INT    
 SET @ReadyForServiceStatus = (SELECT TOP 1 InspectionStatusId FROM ReadyForServiceStatus)    
 RETURN (CASE WHEN @ServiceDate IS NOT NULL AND @StatusId NOT IN (7,8,9,10,12) AND dbo.f_NextServiceDate(@ServiceDate, @PropertyHoldDate, @CreatedUtcDate) < GETDATE() AND @StatusId = @ReadyForServiceStatus THEN 1 ELSE 0 END)    
end
GO
/****** Object:  UserDefinedFunction [dbo].[f_IsNew]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[f_IsNew]      
(@StatusId int, @ServiceDate DATETIME)      
RETURNS bit      
AS      
begin      
 DECLARE @ReadyForServiceStatus INT      
 SET @ReadyForServiceStatus = (SELECT TOP 1 InspectionStatusId FROM ReadyForServiceStatus)      
     
 return (CASE WHEN @ServiceDate IS NULL AND @StatusId = @ReadyForServiceStatus THEN 1 ELSE 0 END)      
end
GO
/****** Object:  UserDefinedFunction [dbo].[f_PropertyInfo__ConcatenateTenantContactNumber]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[f_PropertyInfo__ConcatenateTenantContactNumber]
(@PropertyInfoId INT)
RETURNS NVARCHAR (MAX)
AS
begin
	declare @result nvarchar(max)

	select @result = coalesce(@result + ', ', '') + ContactNumber
	from ContactEntry
	where ContactEntry.PropertyInfoId = @PropertyInfoId
		and ContactEntry.IsDeleted = 0

    return @result
end
GO
/****** Object:  UserDefinedFunction [dbo].[f_PropertyInfo__ConcatenateMobileNumber]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[f_PropertyInfo__ConcatenateMobileNumber]
(@PropertyInfoId INT)
RETURNS NVARCHAR (MAX)
AS
begin
	declare @result nvarchar(max)

	select @result = coalesce(@result + ', ', '') + ContactNumber
	from ContactEntry
	where ContactEntry.PropertyInfoId = @PropertyInfoId and 
		  ContactEntry.IsDeleted = 0 AND 
		  (ContactEntry.ContactNumberTypeId = 1 OR
		   (
				ContactEntry.ContactNumber like '04%' OR
				ContactEntry.ContactNumber like '+614%' OR
				ContactEntry.ContactNumber like '+61 4%' OR
				ContactEntry.ContactNumber like '(+614%' OR
				ContactEntry.ContactNumber like '(+61 4%' OR
				ContactEntry.ContactNumber like '4%' 
		   )
		  )

    return @result
end
GO
/****** Object:  UserDefinedFunction [dbo].[f_PropertyInfo__ConcatenateContactNumberOfType]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[f_PropertyInfo__ConcatenateContactNumberOfType]
(@PropertyInfoId INT, @contactNumberType INT)
RETURNS NVARCHAR (MAX)
AS
begin
	declare @result nvarchar(max)

	select @result = coalesce(@result + ', ', '') + ContactNumber
	from ContactEntry
	where ContactEntry.PropertyInfoId = @PropertyInfoId
		and ContactEntry.IsDeleted = 0
		and ContactEntry.ContactNumberTypeId = @contactNumberType

    return @result
end
GO
/****** Object:  UserDefinedFunction [dbo].[f_ContactNumber]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[f_ContactNumber]
(
	-- Add the parameters for the function here
	@PropertyInfoId int, @ContactNumberTypeId int
)
RETURNS nvarchar(50)
AS
BEGIN
	RETURN (SELECT ContactNumber FROM ContactEntry WHERE PropertyInfoId = @PropertyInfoId AND ContactNumberTypeId = @ContactNumberTypeId)
END
GO
/****** Object:  StoredProcedure [dbo].[aspnet_Users_CreateUser]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[aspnet_Users_CreateUser]
@ApplicationId UNIQUEIDENTIFIER, @UserName NVARCHAR (256), @IsUserAnonymous BIT, @LastActivityDate DATETIME, @UserId UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    IF( @UserId IS NULL )
        SELECT @UserId = NEWID()
    ELSE
    BEGIN
        IF( EXISTS( SELECT UserId FROM dbo.aspnet_Users
                    WHERE @UserId = UserId ) )
            RETURN -1
    END

    INSERT dbo.aspnet_Users (ApplicationId, UserId, UserName, LoweredUserName, IsAnonymous, LastActivityDate)
    VALUES (@ApplicationId, @UserId, @UserName, LOWER(@UserName), @IsUserAnonymous, @LastActivityDate)

    RETURN 0
END
GO
/****** Object:  Table [dbo].[UserProfile]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserProfile](
	[UserId] [uniqueidentifier] NOT NULL,
	[TechnicianId] [int] NULL,
	[FirstName] [nvarchar](50) NULL,
	[LastName] [nvarchar](50) NULL,
	[IsDeleted] [bit] NULL,
	[IsSystem] [bit] NULL,
	[CreatedByUserId] [uniqueidentifier] NULL,
	[CreatedUtcDate] [datetime] NULL,
	[ModifiedByUserId] [uniqueidentifier] NULL,
	[ModifiedUtcDate] [datetime] NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_UserProfile] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[p_UpdateUsername]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[p_UpdateUsername]
	@UserId uniqueidentifier,
	@username nvarchar(256)
AS
BEGIN 

	update aspnet_Users 
	set 
		UserName = @username,
		LoweredUserName = lower(@username)
		
	where UserId = @UserId
	
END
GO
/****** Object:  Table [dbo].[PropertyManager]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PropertyManager](
	[PropertyManagerId] [int] IDENTITY(1,1) NOT NULL,
	[AgencyId] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Position] [nvarchar](50) NULL,
	[Telephone] [nvarchar](12) NULL,
	[Email] [nvarchar](400) NULL,
	[IsDeleted] [bit] NULL,
	[CreatedByUserId] [uniqueidentifier] NULL,
	[CreatedUtcDate] [datetime] NULL,
	[ModifiedByUserId] [uniqueidentifier] NULL,
	[ModifiedUtcDate] [datetime] NULL,
	[RowVersion] [timestamp] NULL,
	[IsFixedFeeService] [bit] NULL,
 CONSTRAINT [PK_PropertyManager] PRIMARY KEY CLUSTERED 
(
	[PropertyManagerId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PropertyInfo]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PropertyInfo](
	[PropertyInfoId] [int] IDENTITY(1,1) NOT NULL,
	[PropertyNumber] [int] NULL,
	[AgencyId] [int] NULL,
	[PropertyManagerId] [int] NULL,
	[HasSendNotification] [bit] NULL,
	[HasLargeLadder] [bit] NULL,
	[KeyNumber] [nvarchar](50) NULL,
	[UnitShopNumber] [nvarchar](50) NULL,
	[StreetNumber] [nvarchar](50) NULL,
	[StreetName] [nvarchar](500) NULL,
	[Suburb] [nvarchar](50) NULL,
	[StateId] [int] NULL,
	[PostCode] [nvarchar](4) NULL,
	[ZoneId] [int] NULL,
	[OccupantName] [nvarchar](max) NULL,
	[OccupantEmail] [nvarchar](max) NULL,
	[PostalAddress] [nvarchar](max) NULL,
	[PostalSuburb] [nvarchar](50) NULL,
	[PostalPostcode] [nvarchar](4) NULL,
	[PostalStateId] [int] NULL,
	[PostalCountry] [nvarchar](50) NULL,
	[Notes] [nvarchar](max) NULL,
	[IsCancelled] [bit] NULL,
	[CancellationNotes] [nvarchar](max) NULL,
	[CancellationDate] [datetime] NULL,
	[SettlementDate] [datetime] NULL,
	[PropertyHoldDate] [datetime] NULL,
	[Discount] [money] NULL,
	[LastServicedDate] [datetime] NULL,
	[InspectionStatusUpdatedDate] [datetime] NULL,
	[InspectionStatusId] [int] NULL,
	[ElectricalWorkStatusUpdatedDate] [datetime] NULL,
	[ElectricalWorkStatusId] [int] NULL,
	[HasProblem] [bit] NULL,
	[ProblemStatusUpdatedDate] [datetime] NULL,
	[ProblemNotes] [nvarchar](max) NULL,
	[ContactNotes] [nvarchar](max) NULL,
	[IsOneOffService] [bit] NULL,
	[IsServiceCompleted] [bit] NULL,
	[LandlordName] [nvarchar](100) NULL,
	[LandlordAddress] [nvarchar](max) NULL,
	[LandlordSuburb] [nvarchar](50) NULL,
	[LandlordPostcode] [nvarchar](4) NULL,
	[LandlordStateId] [int] NULL,
	[LandlordCountry] [nvarchar](50) NULL,
	[LandlordEmail] [nvarchar](400) NULL,
	[ConcatenatedTenantName] [nvarchar](max) NULL,
	[ConcatenatedTenantContactNumber] [nvarchar](max) NULL,
	[IsDeleted] [bit] NULL,
	[CreatedByUserId] [uniqueidentifier] NULL,
	[CreatedUtcDate] [datetime] NULL,
	[ModifiedByUserId] [uniqueidentifier] NULL,
	[ModifiedUtcDate] [datetime] NULL,
	[RowVersion] [timestamp] NULL,
	[DiscountPercentage] [decimal](18, 2) NULL,
	[NextServiceDate]  AS ([dbo].[f_NextServiceDate]([LastServicedDate],[PropertyHoldDate],[CreatedUtcDate])),
	[IsFixedFeeService] [bit] NULL,
	[IsFreeService] [bit] NULL,
 CONSTRAINT [PK_PropertyInfo] PRIMARY KEY CLUSTERED 
(
	[PropertyInfoId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_PropertyInfo)Combined] ON [dbo].[PropertyInfo] 
(
	[ElectricalWorkStatusId] ASC,
	[IsDeleted] ASC
)
INCLUDE ( [PropertyInfoId],
[AgencyId],
[PropertyManagerId],
[IsCancelled],
[SettlementDate],
[PropertyHoldDate],
[LastServicedDate],
[InspectionStatusId],
[HasProblem],
[CreatedUtcDate]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Role]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Role](
	[RoleId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](256) NOT NULL,
	[Description] [nvarchar](256) NULL,
	[IsDeleted] [bit] NOT NULL,
	[CreatedByUserId] [uniqueidentifier] NOT NULL,
	[CreatedUtcDate] [datetime] NOT NULL,
	[ModifiedByUserId] [uniqueidentifier] NULL,
	[ModifiedUtcDate] [datetime] NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_Role] PRIMARY KEY CLUSTERED 
(
	[RoleId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Upload]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Upload](
	[UploadId] [int] IDENTITY(1,1) NOT NULL,
	[FileName] [nvarchar](500) NULL,
	[OriginalFileName] [nvarchar](500) NOT NULL,
	[Extension] [nvarchar](50) NOT NULL,
	[SizeInBytes] [int] NOT NULL,
	[Upload] [varbinary](max) NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[CreatedByUserId] [uniqueidentifier] NULL,
	[CreatedUtcDate] [datetime] NOT NULL,
	[ModifiedByUserId] [uniqueidentifier] NULL,
	[ModifiedUtcDate] [datetime] NOT NULL,
 CONSTRAINT [PK_Upload] PRIMARY KEY CLUSTERED 
(
	[UploadId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Suburb]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Suburb](
	[SuburbId] [int] IDENTITY(1,1) NOT NULL,
	[StateId] [int] NOT NULL,
	[ZoneId] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[PostCode] [nvarchar](4) NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[CreatedByUserId] [uniqueidentifier] NOT NULL,
	[CreatedUtcDate] [datetime] NOT NULL,
	[ModifiedByUserId] [uniqueidentifier] NULL,
	[ModifiedUtcDate] [datetime] NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_Suburb] PRIMARY KEY CLUSTERED 
(
	[SuburbId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[f_DynamicReadyForServiceStatus]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[f_DynamicReadyForServiceStatus]                
(@StatusId int, @ServiceDate DATETIME, @PropertyHoldDate DATETIME, @CreatedUtcDate DATETIME)                
RETURNS INT  
AS                
begin                
 DECLARE @NextServiceDate DATETIME              
 DECLARE @ReadyForServiceStatus INT          
 DECLARE @IsNewStatusId INT        
 DECLARE @IsOverdueStatusId INT        
 DECLARE @IsComingUpForServiceStatusId INT        
 DECLARE @Result INT      
         
 SET @IsNewStatusId = (SELECT TOP 1 NewPropertyStatusId FROM v_DynamicReadyForServiceStatus)        
 SET @IsOverdueStatusId = (SELECT TOP 1 OverdueStatusId FROM v_DynamicReadyForServiceStatus)        
 SET @IsComingUpForServiceStatusId = (SELECT TOP 1 ComingUpForServiceStatusId FROM v_DynamicReadyForServiceStatus)         
          
 IF ((SELECT TOP 1 dbo.f_IsOverDue(@StatusId, @ServiceDate, @PropertyHoldDate, @CreatedUtcDate)) = 1)      
 SET @Result = @IsOverdueStatusId        
 ELSE IF ((SELECT TOP 1 dbo.f_IsComingUpForService(@StatusId, @ServiceDate, @PropertyHoldDate, @CreatedUtcDate)) = 1 )      
 SET @Result = @IsComingUpForServiceStatusId        
 ELSE IF ((SELECT TOP 1 dbo.f_IsNew(@StatusId, @ServiceDate)) = 1)      
 SET @Result = @IsNewStatusId        
 ELSE       
 SET @Result = NULL        
        
        
  RETURN @Result      
END
GO
/****** Object:  StoredProcedure [dbo].[aspnet_Users_DeleteUser]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[aspnet_Users_DeleteUser]
@ApplicationName NVARCHAR (256), @UserName NVARCHAR (256), @TablesToDeleteFrom INT, @NumTablesDeletedFrom INT OUTPUT
AS
BEGIN
    DECLARE @UserId               uniqueidentifier
    SELECT  @UserId               = NULL
    SELECT  @NumTablesDeletedFrom = 0

    DECLARE @TranStarted   bit
    SET @TranStarted = 0

    IF( @@TRANCOUNT = 0 )
    BEGIN
	    BEGIN TRANSACTION
	    SET @TranStarted = 1
    END
    ELSE
	SET @TranStarted = 0

    DECLARE @ErrorCode   int
    DECLARE @RowCount    int

    SET @ErrorCode = 0
    SET @RowCount  = 0

    SELECT  @UserId = u.UserId
    FROM    dbo.aspnet_Users u, dbo.aspnet_Applications a
    WHERE   u.LoweredUserName       = LOWER(@UserName)
        AND u.ApplicationId         = a.ApplicationId
        AND LOWER(@ApplicationName) = a.LoweredApplicationName

    IF (@UserId IS NULL)
    BEGIN
        GOTO Cleanup
    END

    -- Delete from Membership table if (@TablesToDeleteFrom & 1) is set
    IF ((@TablesToDeleteFrom & 1) <> 0 AND
        (EXISTS (SELECT name FROM sysobjects WHERE (name = N'vw_aspnet_MembershipUsers') AND (type = 'V'))))
    BEGIN
        DELETE FROM dbo.aspnet_Membership WHERE @UserId = UserId

        SELECT @ErrorCode = @@ERROR,
               @RowCount = @@ROWCOUNT

        IF( @ErrorCode <> 0 )
            GOTO Cleanup

        IF (@RowCount <> 0)
            SELECT  @NumTablesDeletedFrom = @NumTablesDeletedFrom + 1
    END

    -- Delete from aspnet_UsersInRoles table if (@TablesToDeleteFrom & 2) is set
    IF ((@TablesToDeleteFrom & 2) <> 0  AND
        (EXISTS (SELECT name FROM sysobjects WHERE (name = N'vw_aspnet_UsersInRoles') AND (type = 'V'))) )
    BEGIN
        DELETE FROM dbo.aspnet_UsersInRoles WHERE @UserId = UserId

        SELECT @ErrorCode = @@ERROR,
                @RowCount = @@ROWCOUNT

        IF( @ErrorCode <> 0 )
            GOTO Cleanup

        IF (@RowCount <> 0)
            SELECT  @NumTablesDeletedFrom = @NumTablesDeletedFrom + 1
    END

    -- Delete from aspnet_Profile table if (@TablesToDeleteFrom & 4) is set
    IF ((@TablesToDeleteFrom & 4) <> 0  AND
        (EXISTS (SELECT name FROM sysobjects WHERE (name = N'vw_aspnet_Profiles') AND (type = 'V'))) )
    BEGIN
        DELETE FROM dbo.aspnet_Profile WHERE @UserId = UserId

        SELECT @ErrorCode = @@ERROR,
                @RowCount = @@ROWCOUNT

        IF( @ErrorCode <> 0 )
            GOTO Cleanup

        IF (@RowCount <> 0)
            SELECT  @NumTablesDeletedFrom = @NumTablesDeletedFrom + 1
    END

    -- Delete from aspnet_PersonalizationPerUser table if (@TablesToDeleteFrom & 8) is set
    IF ((@TablesToDeleteFrom & 8) <> 0  AND
        (EXISTS (SELECT name FROM sysobjects WHERE (name = N'vw_aspnet_WebPartState_User') AND (type = 'V'))) )
    BEGIN
        DELETE FROM dbo.aspnet_PersonalizationPerUser WHERE @UserId = UserId

        SELECT @ErrorCode = @@ERROR,
                @RowCount = @@ROWCOUNT

        IF( @ErrorCode <> 0 )
            GOTO Cleanup

        IF (@RowCount <> 0)
            SELECT  @NumTablesDeletedFrom = @NumTablesDeletedFrom + 1
    END

    -- Delete from aspnet_Users table if (@TablesToDeleteFrom & 1,2,4 & 8) are all set
    IF ((@TablesToDeleteFrom & 1) <> 0 AND
        (@TablesToDeleteFrom & 2) <> 0 AND
        (@TablesToDeleteFrom & 4) <> 0 AND
        (@TablesToDeleteFrom & 8) <> 0 AND
        (EXISTS (SELECT UserId FROM dbo.aspnet_Users WHERE @UserId = UserId)))
    BEGIN
        DELETE FROM dbo.aspnet_Users WHERE @UserId = UserId

        SELECT @ErrorCode = @@ERROR,
                @RowCount = @@ROWCOUNT

        IF( @ErrorCode <> 0 )
            GOTO Cleanup

        IF (@RowCount <> 0)
            SELECT  @NumTablesDeletedFrom = @NumTablesDeletedFrom + 1
    END

    IF( @TranStarted = 1 )
    BEGIN
	    SET @TranStarted = 0
	    COMMIT TRANSACTION
    END

    RETURN 0

Cleanup:
    SET @NumTablesDeletedFrom = 0

    IF( @TranStarted = 1 )
    BEGIN
        SET @TranStarted = 0
	    ROLLBACK TRANSACTION
    END

    RETURN @ErrorCode

END
GO
/****** Object:  Table [dbo].[Help]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Help](
	[HelpId] [uniqueidentifier] NOT NULL,
	[ApplicationAreaId] [int] NULL,
	[Title] [nvarchar](50) NOT NULL,
	[Content] [nvarchar](max) NULL,
	[Code] [nvarchar](100) NULL,
	[IsDeleted] [bit] NOT NULL,
	[CreatedByUserId] [uniqueidentifier] NOT NULL,
	[CreatedUtcDate] [datetime] NOT NULL,
	[ModifiedByUserId] [uniqueidentifier] NULL,
	[ModifiedUtcDate] [datetime] NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_Help] PRIMARY KEY CLUSTERED 
(
	[HelpId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[aspnet_Profile_DeleteInactiveProfiles]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[aspnet_Profile_DeleteInactiveProfiles]
@ApplicationName NVARCHAR (256), @ProfileAuthOptions INT, @InactiveSinceDate DATETIME
AS
BEGIN
    DECLARE @ApplicationId uniqueidentifier
    SELECT  @ApplicationId = NULL
    SELECT  @ApplicationId = ApplicationId FROM aspnet_Applications WHERE LOWER(@ApplicationName) = LoweredApplicationName
    IF (@ApplicationId IS NULL)
    BEGIN
        SELECT  0
        RETURN
    END

    DELETE
    FROM    dbo.aspnet_Profile
    WHERE   UserId IN
            (   SELECT  UserId
                FROM    dbo.aspnet_Users u
                WHERE   ApplicationId = @ApplicationId
                        AND (LastActivityDate <= @InactiveSinceDate)
                        AND (
                                (@ProfileAuthOptions = 2)
                             OR (@ProfileAuthOptions = 0 AND IsAnonymous = 1)
                             OR (@ProfileAuthOptions = 1 AND IsAnonymous = 0)
                            )
            )

    SELECT  @@ROWCOUNT
END
GO
/****** Object:  StoredProcedure [dbo].[aspnet_Membership_UpdateUserInfo]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[aspnet_Membership_UpdateUserInfo]
@ApplicationName NVARCHAR (256), @UserName NVARCHAR (256), @IsPasswordCorrect BIT, @UpdateLastLoginActivityDate BIT, @MaxInvalidPasswordAttempts INT, @PasswordAttemptWindow INT, @CurrentTimeUtc DATETIME, @LastLoginDate DATETIME, @LastActivityDate DATETIME
AS
BEGIN
    DECLARE @UserId                                 uniqueidentifier
    DECLARE @IsApproved                             bit
    DECLARE @IsLockedOut                            bit
    DECLARE @LastLockoutDate                        datetime
    DECLARE @FailedPasswordAttemptCount             int
    DECLARE @FailedPasswordAttemptWindowStart       datetime
    DECLARE @FailedPasswordAnswerAttemptCount       int
    DECLARE @FailedPasswordAnswerAttemptWindowStart datetime

    DECLARE @ErrorCode     int
    SET @ErrorCode = 0

    DECLARE @TranStarted   bit
    SET @TranStarted = 0

    IF( @@TRANCOUNT = 0 )
    BEGIN
	    BEGIN TRANSACTION
	    SET @TranStarted = 1
    END
    ELSE
    	SET @TranStarted = 0

    SELECT  @UserId = u.UserId,
            @IsApproved = m.IsApproved,
            @IsLockedOut = m.IsLockedOut,
            @LastLockoutDate = m.LastLockoutDate,
            @FailedPasswordAttemptCount = m.FailedPasswordAttemptCount,
            @FailedPasswordAttemptWindowStart = m.FailedPasswordAttemptWindowStart,
            @FailedPasswordAnswerAttemptCount = m.FailedPasswordAnswerAttemptCount,
            @FailedPasswordAnswerAttemptWindowStart = m.FailedPasswordAnswerAttemptWindowStart
    FROM    dbo.aspnet_Applications a, dbo.aspnet_Users u, dbo.aspnet_Membership m WITH ( UPDLOCK )
    WHERE   LOWER(@ApplicationName) = a.LoweredApplicationName AND
            u.ApplicationId = a.ApplicationId    AND
            u.UserId = m.UserId AND
            LOWER(@UserName) = u.LoweredUserName

    IF ( @@rowcount = 0 )
    BEGIN
        SET @ErrorCode = 1
        GOTO Cleanup
    END

    IF( @IsLockedOut = 1 )
    BEGIN
        GOTO Cleanup
    END

    IF( @IsPasswordCorrect = 0 )
    BEGIN
        IF( @CurrentTimeUtc > DATEADD( minute, @PasswordAttemptWindow, @FailedPasswordAttemptWindowStart ) )
        BEGIN
            SET @FailedPasswordAttemptWindowStart = @CurrentTimeUtc
            SET @FailedPasswordAttemptCount = 1
        END
        ELSE
        BEGIN
            SET @FailedPasswordAttemptWindowStart = @CurrentTimeUtc
            SET @FailedPasswordAttemptCount = @FailedPasswordAttemptCount + 1
        END

        BEGIN
            IF( @FailedPasswordAttemptCount >= @MaxInvalidPasswordAttempts )
            BEGIN
                SET @IsLockedOut = 1
                SET @LastLockoutDate = @CurrentTimeUtc
            END
        END
    END
    ELSE
    BEGIN
        IF( @FailedPasswordAttemptCount > 0 OR @FailedPasswordAnswerAttemptCount > 0 )
        BEGIN
            SET @FailedPasswordAttemptCount = 0
            SET @FailedPasswordAttemptWindowStart = CONVERT( datetime, '17540101', 112 )
            SET @FailedPasswordAnswerAttemptCount = 0
            SET @FailedPasswordAnswerAttemptWindowStart = CONVERT( datetime, '17540101', 112 )
            SET @LastLockoutDate = CONVERT( datetime, '17540101', 112 )
        END
    END

    IF( @UpdateLastLoginActivityDate = 1 )
    BEGIN
        UPDATE  dbo.aspnet_Users
        SET     LastActivityDate = @LastActivityDate
        WHERE   @UserId = UserId

        IF( @@ERROR <> 0 )
        BEGIN
            SET @ErrorCode = -1
            GOTO Cleanup
        END

        UPDATE  dbo.aspnet_Membership
        SET     LastLoginDate = @LastLoginDate
        WHERE   UserId = @UserId

        IF( @@ERROR <> 0 )
        BEGIN
            SET @ErrorCode = -1
            GOTO Cleanup
        END
    END


    UPDATE dbo.aspnet_Membership
    SET IsLockedOut = @IsLockedOut, LastLockoutDate = @LastLockoutDate,
        FailedPasswordAttemptCount = @FailedPasswordAttemptCount,
        FailedPasswordAttemptWindowStart = @FailedPasswordAttemptWindowStart,
        FailedPasswordAnswerAttemptCount = @FailedPasswordAnswerAttemptCount,
        FailedPasswordAnswerAttemptWindowStart = @FailedPasswordAnswerAttemptWindowStart
    WHERE @UserId = UserId

    IF( @@ERROR <> 0 )
    BEGIN
        SET @ErrorCode = -1
        GOTO Cleanup
    END

    IF( @TranStarted = 1 )
    BEGIN
	SET @TranStarted = 0
	COMMIT TRANSACTION
    END

    RETURN @ErrorCode

Cleanup:

    IF( @TranStarted = 1 )
    BEGIN
        SET @TranStarted = 0
    	ROLLBACK TRANSACTION
    END

    RETURN @ErrorCode

END
GO
/****** Object:  StoredProcedure [dbo].[aspnet_Membership_UpdateUser]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[aspnet_Membership_UpdateUser]
@ApplicationName NVARCHAR (256), @UserName NVARCHAR (256), @Email NVARCHAR (256), @Comment NTEXT, @IsApproved BIT, @LastLoginDate DATETIME, @LastActivityDate DATETIME, @UniqueEmail INT, @CurrentTimeUtc DATETIME
AS
BEGIN
    DECLARE @UserId uniqueidentifier
    DECLARE @ApplicationId uniqueidentifier
    SELECT  @UserId = NULL
    SELECT  @UserId = u.UserId, @ApplicationId = a.ApplicationId
    FROM    dbo.aspnet_Users u, dbo.aspnet_Applications a, dbo.aspnet_Membership m
    WHERE   LoweredUserName = LOWER(@UserName) AND
            u.ApplicationId = a.ApplicationId  AND
            LOWER(@ApplicationName) = a.LoweredApplicationName AND
            u.UserId = m.UserId

    IF (@UserId IS NULL)
        RETURN(1)

    IF (@UniqueEmail = 1)
    BEGIN
        IF (EXISTS (SELECT *
                    FROM  dbo.aspnet_Membership WITH (UPDLOCK, HOLDLOCK)
                    WHERE ApplicationId = @ApplicationId  AND @UserId <> UserId AND LoweredEmail = LOWER(@Email)))
        BEGIN
            RETURN(7)
        END
    END

    DECLARE @TranStarted   bit
    SET @TranStarted = 0

    IF( @@TRANCOUNT = 0 )
    BEGIN
	    BEGIN TRANSACTION
	    SET @TranStarted = 1
    END
    ELSE
	SET @TranStarted = 0

    UPDATE dbo.aspnet_Users WITH (ROWLOCK)
    SET
         LastActivityDate = @LastActivityDate
    WHERE
       @UserId = UserId

    IF( @@ERROR <> 0 )
        GOTO Cleanup

    UPDATE dbo.aspnet_Membership WITH (ROWLOCK)
    SET
         Email            = @Email,
         LoweredEmail     = LOWER(@Email),
         Comment          = @Comment,
         IsApproved       = @IsApproved,
         LastLoginDate    = @LastLoginDate
    WHERE
       @UserId = UserId

    IF( @@ERROR <> 0 )
        GOTO Cleanup

    IF( @TranStarted = 1 )
    BEGIN
	SET @TranStarted = 0
	COMMIT TRANSACTION
    END

    RETURN 0

Cleanup:

    IF( @TranStarted = 1 )
    BEGIN
        SET @TranStarted = 0
    	ROLLBACK TRANSACTION
    END

    RETURN -1
END
GO
/****** Object:  StoredProcedure [dbo].[aspnet_Membership_UnlockUser]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[aspnet_Membership_UnlockUser]
@ApplicationName NVARCHAR (256), @UserName NVARCHAR (256)
AS
BEGIN
    DECLARE @UserId uniqueidentifier
    SELECT  @UserId = NULL
    SELECT  @UserId = u.UserId
    FROM    dbo.aspnet_Users u, dbo.aspnet_Applications a, dbo.aspnet_Membership m
    WHERE   LoweredUserName = LOWER(@UserName) AND
            u.ApplicationId = a.ApplicationId  AND
            LOWER(@ApplicationName) = a.LoweredApplicationName AND
            u.UserId = m.UserId

    IF ( @UserId IS NULL )
        RETURN 1

    UPDATE dbo.aspnet_Membership
    SET IsLockedOut = 0,
        FailedPasswordAttemptCount = 0,
        FailedPasswordAttemptWindowStart = CONVERT( datetime, '17540101', 112 ),
        FailedPasswordAnswerAttemptCount = 0,
        FailedPasswordAnswerAttemptWindowStart = CONVERT( datetime, '17540101', 112 ),
        LastLockoutDate = CONVERT( datetime, '17540101', 112 )
    WHERE @UserId = UserId

    RETURN 0
END
GO
/****** Object:  StoredProcedure [dbo].[aspnet_Membership_SetPassword]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[aspnet_Membership_SetPassword]
@ApplicationName NVARCHAR (256), @UserName NVARCHAR (256), @NewPassword NVARCHAR (128), @PasswordSalt NVARCHAR (128), @CurrentTimeUtc DATETIME, @PasswordFormat INT=0
AS
BEGIN
    DECLARE @UserId uniqueidentifier
    SELECT  @UserId = NULL
    SELECT  @UserId = u.UserId
    FROM    dbo.aspnet_Users u, dbo.aspnet_Applications a, dbo.aspnet_Membership m
    WHERE   LoweredUserName = LOWER(@UserName) AND
            u.ApplicationId = a.ApplicationId  AND
            LOWER(@ApplicationName) = a.LoweredApplicationName AND
            u.UserId = m.UserId

    IF (@UserId IS NULL)
        RETURN(1)

    UPDATE dbo.aspnet_Membership
    SET Password = @NewPassword, PasswordFormat = @PasswordFormat, PasswordSalt = @PasswordSalt,
        LastPasswordChangedDate = @CurrentTimeUtc
    WHERE @UserId = UserId
    RETURN(0)
END
GO
/****** Object:  StoredProcedure [dbo].[aspnet_Membership_ResetPassword]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[aspnet_Membership_ResetPassword]
@ApplicationName NVARCHAR (256), @UserName NVARCHAR (256), @NewPassword NVARCHAR (128), @MaxInvalidPasswordAttempts INT, @PasswordAttemptWindow INT, @PasswordSalt NVARCHAR (128), @CurrentTimeUtc DATETIME, @PasswordFormat INT=0, @PasswordAnswer NVARCHAR (128)=NULL
AS
BEGIN
    DECLARE @IsLockedOut                            bit
    DECLARE @LastLockoutDate                        datetime
    DECLARE @FailedPasswordAttemptCount             int
    DECLARE @FailedPasswordAttemptWindowStart       datetime
    DECLARE @FailedPasswordAnswerAttemptCount       int
    DECLARE @FailedPasswordAnswerAttemptWindowStart datetime

    DECLARE @UserId                                 uniqueidentifier
    SET     @UserId = NULL

    DECLARE @ErrorCode     int
    SET @ErrorCode = 0

    DECLARE @TranStarted   bit
    SET @TranStarted = 0

    IF( @@TRANCOUNT = 0 )
    BEGIN
	    BEGIN TRANSACTION
	    SET @TranStarted = 1
    END
    ELSE
    	SET @TranStarted = 0

    SELECT  @UserId = u.UserId
    FROM    dbo.aspnet_Users u, dbo.aspnet_Applications a, dbo.aspnet_Membership m
    WHERE   LoweredUserName = LOWER(@UserName) AND
            u.ApplicationId = a.ApplicationId  AND
            LOWER(@ApplicationName) = a.LoweredApplicationName AND
            u.UserId = m.UserId

    IF ( @UserId IS NULL )
    BEGIN
        SET @ErrorCode = 1
        GOTO Cleanup
    END

    SELECT @IsLockedOut = IsLockedOut,
           @LastLockoutDate = LastLockoutDate,
           @FailedPasswordAttemptCount = FailedPasswordAttemptCount,
           @FailedPasswordAttemptWindowStart = FailedPasswordAttemptWindowStart,
           @FailedPasswordAnswerAttemptCount = FailedPasswordAnswerAttemptCount,
           @FailedPasswordAnswerAttemptWindowStart = FailedPasswordAnswerAttemptWindowStart
    FROM dbo.aspnet_Membership WITH ( UPDLOCK )
    WHERE @UserId = UserId

    IF( @IsLockedOut = 1 )
    BEGIN
        SET @ErrorCode = 99
        GOTO Cleanup
    END

    UPDATE dbo.aspnet_Membership
    SET    Password = @NewPassword,
           LastPasswordChangedDate = @CurrentTimeUtc,
           PasswordFormat = @PasswordFormat,
           PasswordSalt = @PasswordSalt
    WHERE  @UserId = UserId AND
           ( ( @PasswordAnswer IS NULL ) OR ( LOWER( PasswordAnswer ) = LOWER( @PasswordAnswer ) ) )

    IF ( @@ROWCOUNT = 0 )
        BEGIN
            IF( @CurrentTimeUtc > DATEADD( minute, @PasswordAttemptWindow, @FailedPasswordAnswerAttemptWindowStart ) )
            BEGIN
                SET @FailedPasswordAnswerAttemptWindowStart = @CurrentTimeUtc
                SET @FailedPasswordAnswerAttemptCount = 1
            END
            ELSE
            BEGIN
                SET @FailedPasswordAnswerAttemptWindowStart = @CurrentTimeUtc
                SET @FailedPasswordAnswerAttemptCount = @FailedPasswordAnswerAttemptCount + 1
            END

            BEGIN
                IF( @FailedPasswordAnswerAttemptCount >= @MaxInvalidPasswordAttempts )
                BEGIN
                    SET @IsLockedOut = 1
                    SET @LastLockoutDate = @CurrentTimeUtc
                END
            END

            SET @ErrorCode = 3
        END
    ELSE
        BEGIN
            IF( @FailedPasswordAnswerAttemptCount > 0 )
            BEGIN
                SET @FailedPasswordAnswerAttemptCount = 0
                SET @FailedPasswordAnswerAttemptWindowStart = CONVERT( datetime, '17540101', 112 )
            END
        END

    IF( NOT ( @PasswordAnswer IS NULL ) )
    BEGIN
        UPDATE dbo.aspnet_Membership
        SET IsLockedOut = @IsLockedOut, LastLockoutDate = @LastLockoutDate,
            FailedPasswordAttemptCount = @FailedPasswordAttemptCount,
            FailedPasswordAttemptWindowStart = @FailedPasswordAttemptWindowStart,
            FailedPasswordAnswerAttemptCount = @FailedPasswordAnswerAttemptCount,
            FailedPasswordAnswerAttemptWindowStart = @FailedPasswordAnswerAttemptWindowStart
        WHERE @UserId = UserId

        IF( @@ERROR <> 0 )
        BEGIN
            SET @ErrorCode = -1
            GOTO Cleanup
        END
    END

    IF( @TranStarted = 1 )
    BEGIN
	SET @TranStarted = 0
	COMMIT TRANSACTION
    END

    RETURN @ErrorCode

Cleanup:

    IF( @TranStarted = 1 )
    BEGIN
        SET @TranStarted = 0
    	ROLLBACK TRANSACTION
    END

    RETURN @ErrorCode

END
GO
/****** Object:  StoredProcedure [dbo].[aspnet_Membership_GetUserByUserId]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[aspnet_Membership_GetUserByUserId]
@UserId UNIQUEIDENTIFIER, @CurrentTimeUtc DATETIME, @UpdateLastActivity BIT=0
AS
BEGIN
    IF ( @UpdateLastActivity = 1 )
    BEGIN
        UPDATE   dbo.aspnet_Users
        SET      LastActivityDate = @CurrentTimeUtc
        FROM     dbo.aspnet_Users
        WHERE    @UserId = UserId

        IF ( @@ROWCOUNT = 0 ) -- User ID not found
            RETURN -1
    END

    SELECT  m.Email, m.PasswordQuestion, m.Comment, m.IsApproved,
            m.CreateDate, m.LastLoginDate, u.LastActivityDate,
            m.LastPasswordChangedDate, u.UserName, m.IsLockedOut,
            m.LastLockoutDate
    FROM    dbo.aspnet_Users u, dbo.aspnet_Membership m
    WHERE   @UserId = u.UserId AND u.UserId = m.UserId

    IF ( @@ROWCOUNT = 0 ) -- User ID not found
       RETURN -1

    RETURN 0
END
GO
/****** Object:  StoredProcedure [dbo].[aspnet_Membership_GetUserByName]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[aspnet_Membership_GetUserByName]
@ApplicationName NVARCHAR (256), @UserName NVARCHAR (256), @CurrentTimeUtc DATETIME, @UpdateLastActivity BIT=0
AS
BEGIN
    DECLARE @UserId uniqueidentifier

    IF (@UpdateLastActivity = 1)
    BEGIN
        -- select user ID from aspnet_users table
        SELECT TOP 1 @UserId = u.UserId
        FROM    dbo.aspnet_Applications a, dbo.aspnet_Users u, dbo.aspnet_Membership m
        WHERE    LOWER(@ApplicationName) = a.LoweredApplicationName AND
                u.ApplicationId = a.ApplicationId    AND
                LOWER(@UserName) = u.LoweredUserName AND u.UserId = m.UserId

        IF (@@ROWCOUNT = 0) -- Username not found
            RETURN -1

        UPDATE   dbo.aspnet_Users
        SET      LastActivityDate = @CurrentTimeUtc
        WHERE    @UserId = UserId

        SELECT m.Email, m.PasswordQuestion, m.Comment, m.IsApproved,
                m.CreateDate, m.LastLoginDate, u.LastActivityDate, m.LastPasswordChangedDate,
                u.UserId, m.IsLockedOut, m.LastLockoutDate
        FROM    dbo.aspnet_Applications a, dbo.aspnet_Users u, dbo.aspnet_Membership m
        WHERE  @UserId = u.UserId AND u.UserId = m.UserId 
    END
    ELSE
    BEGIN
        SELECT TOP 1 m.Email, m.PasswordQuestion, m.Comment, m.IsApproved,
                m.CreateDate, m.LastLoginDate, u.LastActivityDate, m.LastPasswordChangedDate,
                u.UserId, m.IsLockedOut,m.LastLockoutDate
        FROM    dbo.aspnet_Applications a, dbo.aspnet_Users u, dbo.aspnet_Membership m
        WHERE    LOWER(@ApplicationName) = a.LoweredApplicationName AND
                u.ApplicationId = a.ApplicationId    AND
                LOWER(@UserName) = u.LoweredUserName AND u.UserId = m.UserId

        IF (@@ROWCOUNT = 0) -- Username not found
            RETURN -1
    END

    RETURN 0
END
GO
/****** Object:  StoredProcedure [dbo].[aspnet_Membership_GetUserByEmail]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[aspnet_Membership_GetUserByEmail]
@ApplicationName NVARCHAR (256), @Email NVARCHAR (256)
AS
BEGIN
    IF( @Email IS NULL )
        SELECT  u.UserName
        FROM    dbo.aspnet_Applications a, dbo.aspnet_Users u, dbo.aspnet_Membership m
        WHERE   LOWER(@ApplicationName) = a.LoweredApplicationName AND
                u.ApplicationId = a.ApplicationId    AND
                u.UserId = m.UserId AND
                m.LoweredEmail IS NULL
    ELSE
        SELECT  u.UserName
        FROM    dbo.aspnet_Applications a, dbo.aspnet_Users u, dbo.aspnet_Membership m
        WHERE   LOWER(@ApplicationName) = a.LoweredApplicationName AND
                u.ApplicationId = a.ApplicationId    AND
                u.UserId = m.UserId AND
                LOWER(@Email) = m.LoweredEmail

    IF (@@rowcount = 0)
        RETURN(1)
    RETURN(0)
END
GO
/****** Object:  StoredProcedure [dbo].[aspnet_Membership_GetPasswordWithFormat]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[aspnet_Membership_GetPasswordWithFormat]
@ApplicationName NVARCHAR (256), @UserName NVARCHAR (256), @UpdateLastLoginActivityDate BIT, @CurrentTimeUtc DATETIME
AS
BEGIN
    DECLARE @IsLockedOut                        bit
    DECLARE @UserId                             uniqueidentifier
    DECLARE @Password                           nvarchar(128)
    DECLARE @PasswordSalt                       nvarchar(128)
    DECLARE @PasswordFormat                     int
    DECLARE @FailedPasswordAttemptCount         int
    DECLARE @FailedPasswordAnswerAttemptCount   int
    DECLARE @IsApproved                         bit
    DECLARE @LastActivityDate                   datetime
    DECLARE @LastLoginDate                      datetime

    SELECT  @UserId          = NULL

    SELECT  @UserId = u.UserId, @IsLockedOut = m.IsLockedOut, @Password=Password, @PasswordFormat=PasswordFormat,
            @PasswordSalt=PasswordSalt, @FailedPasswordAttemptCount=FailedPasswordAttemptCount,
		    @FailedPasswordAnswerAttemptCount=FailedPasswordAnswerAttemptCount, @IsApproved=IsApproved,
            @LastActivityDate = LastActivityDate, @LastLoginDate = LastLoginDate
    FROM    dbo.aspnet_Applications a, dbo.aspnet_Users u, dbo.aspnet_Membership m
    WHERE   LOWER(@ApplicationName) = a.LoweredApplicationName AND
            u.ApplicationId = a.ApplicationId    AND
            u.UserId = m.UserId AND
            LOWER(@UserName) = u.LoweredUserName

    IF (@UserId IS NULL)
        RETURN 1

    IF (@IsLockedOut = 1)
        RETURN 99

    SELECT   @Password, @PasswordFormat, @PasswordSalt, @FailedPasswordAttemptCount,
             @FailedPasswordAnswerAttemptCount, @IsApproved, @LastLoginDate, @LastActivityDate

    IF (@UpdateLastLoginActivityDate = 1 AND @IsApproved = 1)
    BEGIN
        UPDATE  dbo.aspnet_Membership
        SET     LastLoginDate = @CurrentTimeUtc
        WHERE   UserId = @UserId

        UPDATE  dbo.aspnet_Users
        SET     LastActivityDate = @CurrentTimeUtc
        WHERE   @UserId = UserId
    END


    RETURN 0
END
GO
/****** Object:  StoredProcedure [dbo].[aspnet_Membership_GetPassword]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[aspnet_Membership_GetPassword]
@ApplicationName NVARCHAR (256), @UserName NVARCHAR (256), @MaxInvalidPasswordAttempts INT, @PasswordAttemptWindow INT, @CurrentTimeUtc DATETIME, @PasswordAnswer NVARCHAR (128)=NULL
AS
BEGIN
    DECLARE @UserId                                 uniqueidentifier
    DECLARE @PasswordFormat                         int
    DECLARE @Password                               nvarchar(128)
    DECLARE @passAns                                nvarchar(128)
    DECLARE @IsLockedOut                            bit
    DECLARE @LastLockoutDate                        datetime
    DECLARE @FailedPasswordAttemptCount             int
    DECLARE @FailedPasswordAttemptWindowStart       datetime
    DECLARE @FailedPasswordAnswerAttemptCount       int
    DECLARE @FailedPasswordAnswerAttemptWindowStart datetime

    DECLARE @ErrorCode     int
    SET @ErrorCode = 0

    DECLARE @TranStarted   bit
    SET @TranStarted = 0

    IF( @@TRANCOUNT = 0 )
    BEGIN
	    BEGIN TRANSACTION
	    SET @TranStarted = 1
    END
    ELSE
    	SET @TranStarted = 0

    SELECT  @UserId = u.UserId,
            @Password = m.Password,
            @passAns = m.PasswordAnswer,
            @PasswordFormat = m.PasswordFormat,
            @IsLockedOut = m.IsLockedOut,
            @LastLockoutDate = m.LastLockoutDate,
            @FailedPasswordAttemptCount = m.FailedPasswordAttemptCount,
            @FailedPasswordAttemptWindowStart = m.FailedPasswordAttemptWindowStart,
            @FailedPasswordAnswerAttemptCount = m.FailedPasswordAnswerAttemptCount,
            @FailedPasswordAnswerAttemptWindowStart = m.FailedPasswordAnswerAttemptWindowStart
    FROM    dbo.aspnet_Applications a, dbo.aspnet_Users u, dbo.aspnet_Membership m WITH ( UPDLOCK )
    WHERE   LOWER(@ApplicationName) = a.LoweredApplicationName AND
            u.ApplicationId = a.ApplicationId    AND
            u.UserId = m.UserId AND
            LOWER(@UserName) = u.LoweredUserName

    IF ( @@rowcount = 0 )
    BEGIN
        SET @ErrorCode = 1
        GOTO Cleanup
    END

    IF( @IsLockedOut = 1 )
    BEGIN
        SET @ErrorCode = 99
        GOTO Cleanup
    END

    IF ( NOT( @PasswordAnswer IS NULL ) )
    BEGIN
        IF( ( @passAns IS NULL ) OR ( LOWER( @passAns ) <> LOWER( @PasswordAnswer ) ) )
        BEGIN
            IF( @CurrentTimeUtc > DATEADD( minute, @PasswordAttemptWindow, @FailedPasswordAnswerAttemptWindowStart ) )
            BEGIN
                SET @FailedPasswordAnswerAttemptWindowStart = @CurrentTimeUtc
                SET @FailedPasswordAnswerAttemptCount = 1
            END
            ELSE
            BEGIN
                SET @FailedPasswordAnswerAttemptCount = @FailedPasswordAnswerAttemptCount + 1
                SET @FailedPasswordAnswerAttemptWindowStart = @CurrentTimeUtc
            END

            BEGIN
                IF( @FailedPasswordAnswerAttemptCount >= @MaxInvalidPasswordAttempts )
                BEGIN
                    SET @IsLockedOut = 1
                    SET @LastLockoutDate = @CurrentTimeUtc
                END
            END

            SET @ErrorCode = 3
        END
        ELSE
        BEGIN
            IF( @FailedPasswordAnswerAttemptCount > 0 )
            BEGIN
                SET @FailedPasswordAnswerAttemptCount = 0
                SET @FailedPasswordAnswerAttemptWindowStart = CONVERT( datetime, '17540101', 112 )
            END
        END

        UPDATE dbo.aspnet_Membership
        SET IsLockedOut = @IsLockedOut, LastLockoutDate = @LastLockoutDate,
            FailedPasswordAttemptCount = @FailedPasswordAttemptCount,
            FailedPasswordAttemptWindowStart = @FailedPasswordAttemptWindowStart,
            FailedPasswordAnswerAttemptCount = @FailedPasswordAnswerAttemptCount,
            FailedPasswordAnswerAttemptWindowStart = @FailedPasswordAnswerAttemptWindowStart
        WHERE @UserId = UserId

        IF( @@ERROR <> 0 )
        BEGIN
            SET @ErrorCode = -1
            GOTO Cleanup
        END
    END

    IF( @TranStarted = 1 )
    BEGIN
	SET @TranStarted = 0
	COMMIT TRANSACTION
    END

    IF( @ErrorCode = 0 )
        SELECT @Password, @PasswordFormat

    RETURN @ErrorCode

Cleanup:

    IF( @TranStarted = 1 )
    BEGIN
        SET @TranStarted = 0
    	ROLLBACK TRANSACTION
    END

    RETURN @ErrorCode

END
GO
/****** Object:  StoredProcedure [dbo].[aspnet_Membership_GetNumberOfUsersOnline]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[aspnet_Membership_GetNumberOfUsersOnline]
@ApplicationName NVARCHAR (256), @MinutesSinceLastInActive INT, @CurrentTimeUtc DATETIME
AS
BEGIN
    DECLARE @DateActive datetime
    SELECT  @DateActive = DATEADD(minute,  -(@MinutesSinceLastInActive), @CurrentTimeUtc)

    DECLARE @NumOnline int
    SELECT  @NumOnline = COUNT(*)
    FROM    dbo.aspnet_Users u(NOLOCK),
            dbo.aspnet_Applications a(NOLOCK),
            dbo.aspnet_Membership m(NOLOCK)
    WHERE   u.ApplicationId = a.ApplicationId                  AND
            LastActivityDate > @DateActive                     AND
            a.LoweredApplicationName = LOWER(@ApplicationName) AND
            u.UserId = m.UserId
    RETURN(@NumOnline)
END
GO
/****** Object:  StoredProcedure [dbo].[aspnet_Membership_GetAllUsers]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[aspnet_Membership_GetAllUsers]
@ApplicationName NVARCHAR (256), @PageIndex INT, @PageSize INT
AS
BEGIN
    DECLARE @ApplicationId uniqueidentifier
    SELECT  @ApplicationId = NULL
    SELECT  @ApplicationId = ApplicationId FROM dbo.aspnet_Applications WHERE LOWER(@ApplicationName) = LoweredApplicationName
    IF (@ApplicationId IS NULL)
        RETURN 0


    -- Set the page bounds
    DECLARE @PageLowerBound int
    DECLARE @PageUpperBound int
    DECLARE @TotalRecords   int
    SET @PageLowerBound = @PageSize * @PageIndex
    SET @PageUpperBound = @PageSize - 1 + @PageLowerBound

    -- Create a temp table TO store the select results
    CREATE TABLE #PageIndexForUsers
    (
        IndexId int IDENTITY (0, 1) NOT NULL,
        UserId uniqueidentifier
    )

    -- Insert into our temp table
    INSERT INTO #PageIndexForUsers (UserId)
    SELECT u.UserId
    FROM   dbo.aspnet_Membership m, dbo.aspnet_Users u
    WHERE  u.ApplicationId = @ApplicationId AND u.UserId = m.UserId
    ORDER BY u.UserName

    SELECT @TotalRecords = @@ROWCOUNT

    SELECT u.UserName, m.Email, m.PasswordQuestion, m.Comment, m.IsApproved,
            m.CreateDate,
            m.LastLoginDate,
            u.LastActivityDate,
            m.LastPasswordChangedDate,
            u.UserId, m.IsLockedOut,
            m.LastLockoutDate
    FROM   dbo.aspnet_Membership m, dbo.aspnet_Users u, #PageIndexForUsers p
    WHERE  u.UserId = p.UserId AND u.UserId = m.UserId AND
           p.IndexId >= @PageLowerBound AND p.IndexId <= @PageUpperBound
    ORDER BY u.UserName
    RETURN @TotalRecords
END
GO
/****** Object:  StoredProcedure [dbo].[aspnet_Membership_FindUsersByName]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[aspnet_Membership_FindUsersByName]
@ApplicationName NVARCHAR (256), @UserNameToMatch NVARCHAR (256), @PageIndex INT, @PageSize INT
AS
BEGIN
    DECLARE @ApplicationId uniqueidentifier
    SELECT  @ApplicationId = NULL
    SELECT  @ApplicationId = ApplicationId FROM dbo.aspnet_Applications WHERE LOWER(@ApplicationName) = LoweredApplicationName
    IF (@ApplicationId IS NULL)
        RETURN 0

    -- Set the page bounds
    DECLARE @PageLowerBound int
    DECLARE @PageUpperBound int
    DECLARE @TotalRecords   int
    SET @PageLowerBound = @PageSize * @PageIndex
    SET @PageUpperBound = @PageSize - 1 + @PageLowerBound

    -- Create a temp table TO store the select results
    CREATE TABLE #PageIndexForUsers
    (
        IndexId int IDENTITY (0, 1) NOT NULL,
        UserId uniqueidentifier
    )

    -- Insert into our temp table
    INSERT INTO #PageIndexForUsers (UserId)
        SELECT u.UserId
        FROM   dbo.aspnet_Users u, dbo.aspnet_Membership m
        WHERE  u.ApplicationId = @ApplicationId AND m.UserId = u.UserId AND u.LoweredUserName LIKE LOWER(@UserNameToMatch)
        ORDER BY u.UserName


    SELECT  u.UserName, m.Email, m.PasswordQuestion, m.Comment, m.IsApproved,
            m.CreateDate,
            m.LastLoginDate,
            u.LastActivityDate,
            m.LastPasswordChangedDate,
            u.UserId, m.IsLockedOut,
            m.LastLockoutDate
    FROM   dbo.aspnet_Membership m, dbo.aspnet_Users u, #PageIndexForUsers p
    WHERE  u.UserId = p.UserId AND u.UserId = m.UserId AND
           p.IndexId >= @PageLowerBound AND p.IndexId <= @PageUpperBound
    ORDER BY u.UserName

    SELECT  @TotalRecords = COUNT(*)
    FROM    #PageIndexForUsers
    RETURN @TotalRecords
END
GO
/****** Object:  StoredProcedure [dbo].[aspnet_Membership_FindUsersByEmail]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[aspnet_Membership_FindUsersByEmail]
@ApplicationName NVARCHAR (256), @EmailToMatch NVARCHAR (256), @PageIndex INT, @PageSize INT
AS
BEGIN
    DECLARE @ApplicationId uniqueidentifier
    SELECT  @ApplicationId = NULL
    SELECT  @ApplicationId = ApplicationId FROM dbo.aspnet_Applications WHERE LOWER(@ApplicationName) = LoweredApplicationName
    IF (@ApplicationId IS NULL)
        RETURN 0

    -- Set the page bounds
    DECLARE @PageLowerBound int
    DECLARE @PageUpperBound int
    DECLARE @TotalRecords   int
    SET @PageLowerBound = @PageSize * @PageIndex
    SET @PageUpperBound = @PageSize - 1 + @PageLowerBound

    -- Create a temp table TO store the select results
    CREATE TABLE #PageIndexForUsers
    (
        IndexId int IDENTITY (0, 1) NOT NULL,
        UserId uniqueidentifier
    )

    -- Insert into our temp table
    IF( @EmailToMatch IS NULL )
        INSERT INTO #PageIndexForUsers (UserId)
            SELECT u.UserId
            FROM   dbo.aspnet_Users u, dbo.aspnet_Membership m
            WHERE  u.ApplicationId = @ApplicationId AND m.UserId = u.UserId AND m.Email IS NULL
            ORDER BY m.LoweredEmail
    ELSE
        INSERT INTO #PageIndexForUsers (UserId)
            SELECT u.UserId
            FROM   dbo.aspnet_Users u, dbo.aspnet_Membership m
            WHERE  u.ApplicationId = @ApplicationId AND m.UserId = u.UserId AND m.LoweredEmail LIKE LOWER(@EmailToMatch)
            ORDER BY m.LoweredEmail

    SELECT  u.UserName, m.Email, m.PasswordQuestion, m.Comment, m.IsApproved,
            m.CreateDate,
            m.LastLoginDate,
            u.LastActivityDate,
            m.LastPasswordChangedDate,
            u.UserId, m.IsLockedOut,
            m.LastLockoutDate
    FROM   dbo.aspnet_Membership m, dbo.aspnet_Users u, #PageIndexForUsers p
    WHERE  u.UserId = p.UserId AND u.UserId = m.UserId AND
           p.IndexId >= @PageLowerBound AND p.IndexId <= @PageUpperBound
    ORDER BY m.LoweredEmail

    SELECT  @TotalRecords = COUNT(*)
    FROM    #PageIndexForUsers
    RETURN @TotalRecords
END
GO
/****** Object:  StoredProcedure [dbo].[aspnet_Membership_CreateUser]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[aspnet_Membership_CreateUser]
@ApplicationName NVARCHAR (256), @UserName NVARCHAR (256), @Password NVARCHAR (128), @PasswordSalt NVARCHAR (128), @Email NVARCHAR (256), @PasswordQuestion NVARCHAR (256), @PasswordAnswer NVARCHAR (128), @IsApproved BIT, @CurrentTimeUtc DATETIME, @CreateDate DATETIME=NULL, @UniqueEmail INT=0, @PasswordFormat INT=0, @UserId UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    DECLARE @ApplicationId uniqueidentifier
    SELECT  @ApplicationId = NULL

    DECLARE @NewUserId uniqueidentifier
    SELECT @NewUserId = NULL

    DECLARE @IsLockedOut bit
    SET @IsLockedOut = 0

    DECLARE @LastLockoutDate  datetime
    SET @LastLockoutDate = CONVERT( datetime, '17540101', 112 )

    DECLARE @FailedPasswordAttemptCount int
    SET @FailedPasswordAttemptCount = 0

    DECLARE @FailedPasswordAttemptWindowStart  datetime
    SET @FailedPasswordAttemptWindowStart = CONVERT( datetime, '17540101', 112 )

    DECLARE @FailedPasswordAnswerAttemptCount int
    SET @FailedPasswordAnswerAttemptCount = 0

    DECLARE @FailedPasswordAnswerAttemptWindowStart  datetime
    SET @FailedPasswordAnswerAttemptWindowStart = CONVERT( datetime, '17540101', 112 )

    DECLARE @NewUserCreated bit
    DECLARE @ReturnValue   int
    SET @ReturnValue = 0

    DECLARE @ErrorCode     int
    SET @ErrorCode = 0

    DECLARE @TranStarted   bit
    SET @TranStarted = 0

    IF( @@TRANCOUNT = 0 )
    BEGIN
	    BEGIN TRANSACTION
	    SET @TranStarted = 1
    END
    ELSE
    	SET @TranStarted = 0

    EXEC dbo.aspnet_Applications_CreateApplication @ApplicationName, @ApplicationId OUTPUT

    IF( @@ERROR <> 0 )
    BEGIN
        SET @ErrorCode = -1
        GOTO Cleanup
    END

    SET @CreateDate = @CurrentTimeUtc

    SELECT  @NewUserId = UserId FROM dbo.aspnet_Users WHERE LOWER(@UserName) = LoweredUserName AND @ApplicationId = ApplicationId
    IF ( @NewUserId IS NULL )
    BEGIN
        SET @NewUserId = @UserId
        EXEC @ReturnValue = dbo.aspnet_Users_CreateUser @ApplicationId, @UserName, 0, @CreateDate, @NewUserId OUTPUT
        SET @NewUserCreated = 1
    END
    ELSE
    BEGIN
        SET @NewUserCreated = 0
        IF( @NewUserId <> @UserId AND @UserId IS NOT NULL )
        BEGIN
            SET @ErrorCode = 6
            GOTO Cleanup
        END
    END

    IF( @@ERROR <> 0 )
    BEGIN
        SET @ErrorCode = -1
        GOTO Cleanup
    END

    IF( @ReturnValue = -1 )
    BEGIN
        SET @ErrorCode = 10
        GOTO Cleanup
    END

    IF ( EXISTS ( SELECT UserId
                  FROM   dbo.aspnet_Membership
                  WHERE  @NewUserId = UserId ) )
    BEGIN
        SET @ErrorCode = 6
        GOTO Cleanup
    END

    SET @UserId = @NewUserId

    IF (@UniqueEmail = 1)
    BEGIN
        IF (EXISTS (SELECT *
                    FROM  dbo.aspnet_Membership m WITH ( UPDLOCK, HOLDLOCK )
                    WHERE ApplicationId = @ApplicationId AND LoweredEmail = LOWER(@Email)))
        BEGIN
            SET @ErrorCode = 7
            GOTO Cleanup
        END
    END

    IF (@NewUserCreated = 0)
    BEGIN
        UPDATE dbo.aspnet_Users
        SET    LastActivityDate = @CreateDate
        WHERE  @UserId = UserId
        IF( @@ERROR <> 0 )
        BEGIN
            SET @ErrorCode = -1
            GOTO Cleanup
        END
    END

    INSERT INTO dbo.aspnet_Membership
                ( ApplicationId,
                  UserId,
                  Password,
                  PasswordSalt,
                  Email,
                  LoweredEmail,
                  PasswordQuestion,
                  PasswordAnswer,
                  PasswordFormat,
                  IsApproved,
                  IsLockedOut,
                  CreateDate,
                  LastLoginDate,
                  LastPasswordChangedDate,
                  LastLockoutDate,
                  FailedPasswordAttemptCount,
                  FailedPasswordAttemptWindowStart,
                  FailedPasswordAnswerAttemptCount,
                  FailedPasswordAnswerAttemptWindowStart )
         VALUES ( @ApplicationId,
                  @UserId,
                  @Password,
                  @PasswordSalt,
                  @Email,
                  LOWER(@Email),
                  @PasswordQuestion,
                  @PasswordAnswer,
                  @PasswordFormat,
                  @IsApproved,
                  @IsLockedOut,
                  @CreateDate,
                  @CreateDate,
                  @CreateDate,
                  @LastLockoutDate,
                  @FailedPasswordAttemptCount,
                  @FailedPasswordAttemptWindowStart,
                  @FailedPasswordAnswerAttemptCount,
                  @FailedPasswordAnswerAttemptWindowStart )

    IF( @@ERROR <> 0 )
    BEGIN
        SET @ErrorCode = -1
        GOTO Cleanup
    END

    IF( @TranStarted = 1 )
    BEGIN
	    SET @TranStarted = 0
	    COMMIT TRANSACTION
    END

    RETURN 0

Cleanup:

    IF( @TranStarted = 1 )
    BEGIN
        SET @TranStarted = 0
    	ROLLBACK TRANSACTION
    END

    RETURN @ErrorCode

END
GO
/****** Object:  StoredProcedure [dbo].[aspnet_Membership_ChangePasswordQuestionAndAnswer]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[aspnet_Membership_ChangePasswordQuestionAndAnswer]
@ApplicationName NVARCHAR (256), @UserName NVARCHAR (256), @NewPasswordQuestion NVARCHAR (256), @NewPasswordAnswer NVARCHAR (128)
AS
BEGIN
    DECLARE @UserId uniqueidentifier
    SELECT  @UserId = NULL
    SELECT  @UserId = u.UserId
    FROM    dbo.aspnet_Membership m, dbo.aspnet_Users u, dbo.aspnet_Applications a
    WHERE   LoweredUserName = LOWER(@UserName) AND
            u.ApplicationId = a.ApplicationId  AND
            LOWER(@ApplicationName) = a.LoweredApplicationName AND
            u.UserId = m.UserId
    IF (@UserId IS NULL)
    BEGIN
        RETURN(1)
    END

    UPDATE dbo.aspnet_Membership
    SET    PasswordQuestion = @NewPasswordQuestion, PasswordAnswer = @NewPasswordAnswer
    WHERE  UserId=@UserId
    RETURN(0)
END
GO
/****** Object:  StoredProcedure [dbo].[aspnet_AnyDataInTables]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[aspnet_AnyDataInTables]
@TablesToCheck INT
AS
BEGIN
    -- Check Membership table if (@TablesToCheck & 1) is set
    IF ((@TablesToCheck & 1) <> 0 AND
        (EXISTS (SELECT name FROM sysobjects WHERE (name = N'vw_aspnet_MembershipUsers') AND (type = 'V'))))
    BEGIN
        IF (EXISTS(SELECT TOP 1 UserId FROM dbo.aspnet_Membership))
        BEGIN
            SELECT N'aspnet_Membership'
            RETURN
        END
    END

    -- Check aspnet_Roles table if (@TablesToCheck & 2) is set
    IF ((@TablesToCheck & 2) <> 0  AND
        (EXISTS (SELECT name FROM sysobjects WHERE (name = N'vw_aspnet_Roles') AND (type = 'V'))) )
    BEGIN
        IF (EXISTS(SELECT TOP 1 RoleId FROM dbo.aspnet_Roles))
        BEGIN
            SELECT N'aspnet_Roles'
            RETURN
        END
    END

    -- Check aspnet_Profile table if (@TablesToCheck & 4) is set
    IF ((@TablesToCheck & 4) <> 0  AND
        (EXISTS (SELECT name FROM sysobjects WHERE (name = N'vw_aspnet_Profiles') AND (type = 'V'))) )
    BEGIN
        IF (EXISTS(SELECT TOP 1 UserId FROM dbo.aspnet_Profile))
        BEGIN
            SELECT N'aspnet_Profile'
            RETURN
        END
    END

    -- Check aspnet_PersonalizationPerUser table if (@TablesToCheck & 8) is set
    IF ((@TablesToCheck & 8) <> 0  AND
        (EXISTS (SELECT name FROM sysobjects WHERE (name = N'vw_aspnet_WebPartState_User') AND (type = 'V'))) )
    BEGIN
        IF (EXISTS(SELECT TOP 1 UserId FROM dbo.aspnet_PersonalizationPerUser))
        BEGIN
            SELECT N'aspnet_PersonalizationPerUser'
            RETURN
        END
    END

    -- Check aspnet_PersonalizationPerUser table if (@TablesToCheck & 16) is set
    IF ((@TablesToCheck & 16) <> 0  AND
        (EXISTS (SELECT name FROM sysobjects WHERE (name = N'aspnet_WebEvent_LogEvent') AND (type = 'P'))) )
    BEGIN
        IF (EXISTS(SELECT TOP 1 * FROM dbo.aspnet_WebEvent_Events))
        BEGIN
            SELECT N'aspnet_WebEvent_Events'
            RETURN
        END
    END

    -- Check aspnet_Users table if (@TablesToCheck & 1,2,4 & 8) are all set
    IF ((@TablesToCheck & 1) <> 0 AND
        (@TablesToCheck & 2) <> 0 AND
        (@TablesToCheck & 4) <> 0 AND
        (@TablesToCheck & 8) <> 0 AND
        (@TablesToCheck & 32) <> 0 AND
        (@TablesToCheck & 128) <> 0 AND
        (@TablesToCheck & 256) <> 0 AND
        (@TablesToCheck & 512) <> 0 AND
        (@TablesToCheck & 1024) <> 0)
    BEGIN
        IF (EXISTS(SELECT TOP 1 UserId FROM dbo.aspnet_Users))
        BEGIN
            SELECT N'aspnet_Users'
            RETURN
        END
        IF (EXISTS(SELECT TOP 1 ApplicationId FROM dbo.aspnet_Applications))
        BEGIN
            SELECT N'aspnet_Applications'
            RETURN
        END
    END
END
GO
/****** Object:  StoredProcedure [dbo].[aspnet_PersonalizationAllUsers_SetPageSettings]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[aspnet_PersonalizationAllUsers_SetPageSettings]
@ApplicationName NVARCHAR (256), @Path NVARCHAR (256), @PageSettings IMAGE, @CurrentTimeUtc DATETIME
AS
BEGIN
    DECLARE @ApplicationId UNIQUEIDENTIFIER
    DECLARE @PathId UNIQUEIDENTIFIER

    SELECT @ApplicationId = NULL
    SELECT @PathId = NULL

    EXEC dbo.aspnet_Applications_CreateApplication @ApplicationName, @ApplicationId OUTPUT

    SELECT @PathId = u.PathId FROM dbo.aspnet_Paths u WHERE u.ApplicationId = @ApplicationId AND u.LoweredPath = LOWER(@Path)
    IF (@PathId IS NULL)
    BEGIN
        EXEC dbo.aspnet_Paths_CreatePath @ApplicationId, @Path, @PathId OUTPUT
    END

    IF (EXISTS(SELECT PathId FROM dbo.aspnet_PersonalizationAllUsers WHERE PathId = @PathId))
        UPDATE dbo.aspnet_PersonalizationAllUsers SET PageSettings = @PageSettings, LastUpdatedDate = @CurrentTimeUtc WHERE PathId = @PathId
    ELSE
        INSERT INTO dbo.aspnet_PersonalizationAllUsers(PathId, PageSettings, LastUpdatedDate) VALUES (@PathId, @PageSettings, @CurrentTimeUtc)
    RETURN 0
END
GO
/****** Object:  StoredProcedure [dbo].[aspnet_PersonalizationAllUsers_ResetPageSettings]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[aspnet_PersonalizationAllUsers_ResetPageSettings]
@ApplicationName NVARCHAR (256), @Path NVARCHAR (256)
AS
BEGIN
    DECLARE @ApplicationId UNIQUEIDENTIFIER
    DECLARE @PathId UNIQUEIDENTIFIER

    SELECT @ApplicationId = NULL
    SELECT @PathId = NULL

    EXEC dbo.aspnet_Personalization_GetApplicationId @ApplicationName, @ApplicationId OUTPUT
    IF (@ApplicationId IS NULL)
    BEGIN
        RETURN
    END

    SELECT @PathId = u.PathId FROM dbo.aspnet_Paths u WHERE u.ApplicationId = @ApplicationId AND u.LoweredPath = LOWER(@Path)
    IF (@PathId IS NULL)
    BEGIN
        RETURN
    END

    DELETE FROM dbo.aspnet_PersonalizationAllUsers WHERE PathId = @PathId
    RETURN 0
END
GO
/****** Object:  StoredProcedure [dbo].[aspnet_PersonalizationAllUsers_GetPageSettings]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[aspnet_PersonalizationAllUsers_GetPageSettings]
@ApplicationName NVARCHAR (256), @Path NVARCHAR (256)
AS
BEGIN
    DECLARE @ApplicationId UNIQUEIDENTIFIER
    DECLARE @PathId UNIQUEIDENTIFIER

    SELECT @ApplicationId = NULL
    SELECT @PathId = NULL

    EXEC dbo.aspnet_Personalization_GetApplicationId @ApplicationName, @ApplicationId OUTPUT
    IF (@ApplicationId IS NULL)
    BEGIN
        RETURN
    END

    SELECT @PathId = u.PathId FROM dbo.aspnet_Paths u WHERE u.ApplicationId = @ApplicationId AND u.LoweredPath = LOWER(@Path)
    IF (@PathId IS NULL)
    BEGIN
        RETURN
    END

    SELECT p.PageSettings FROM dbo.aspnet_PersonalizationAllUsers p WHERE p.PathId = @PathId
END
GO
/****** Object:  StoredProcedure [dbo].[aspnet_PersonalizationAdministration_ResetUserState]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[aspnet_PersonalizationAdministration_ResetUserState]
@Count INT OUTPUT, @ApplicationName NVARCHAR (256), @InactiveSinceDate DATETIME=NULL, @UserName NVARCHAR (256)=NULL, @Path NVARCHAR (256)=NULL
AS
BEGIN
    DECLARE @ApplicationId UNIQUEIDENTIFIER
    EXEC dbo.aspnet_Personalization_GetApplicationId @ApplicationName, @ApplicationId OUTPUT
    IF (@ApplicationId IS NULL)
        SELECT @Count = 0
    ELSE
    BEGIN
        DELETE FROM dbo.aspnet_PersonalizationPerUser
        WHERE Id IN (SELECT PerUser.Id
                     FROM dbo.aspnet_PersonalizationPerUser PerUser, dbo.aspnet_Users Users, dbo.aspnet_Paths Paths
                     WHERE Paths.ApplicationId = @ApplicationId
                           AND PerUser.UserId = Users.UserId
                           AND PerUser.PathId = Paths.PathId
                           AND (@InactiveSinceDate IS NULL OR Users.LastActivityDate <= @InactiveSinceDate)
                           AND (@UserName IS NULL OR Users.LoweredUserName = LOWER(@UserName))
                           AND (@Path IS NULL OR Paths.LoweredPath = LOWER(@Path)))

        SELECT @Count = @@ROWCOUNT
    END
END
GO
/****** Object:  StoredProcedure [dbo].[aspnet_PersonalizationAdministration_ResetSharedState]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[aspnet_PersonalizationAdministration_ResetSharedState]
@Count INT OUTPUT, @ApplicationName NVARCHAR (256), @Path NVARCHAR (256)
AS
BEGIN
    DECLARE @ApplicationId UNIQUEIDENTIFIER
    EXEC dbo.aspnet_Personalization_GetApplicationId @ApplicationName, @ApplicationId OUTPUT
    IF (@ApplicationId IS NULL)
        SELECT @Count = 0
    ELSE
    BEGIN
        DELETE FROM dbo.aspnet_PersonalizationAllUsers
        WHERE PathId IN
            (SELECT AllUsers.PathId
             FROM dbo.aspnet_PersonalizationAllUsers AllUsers, dbo.aspnet_Paths Paths
             WHERE Paths.ApplicationId = @ApplicationId
                   AND AllUsers.PathId = Paths.PathId
                   AND Paths.LoweredPath = LOWER(@Path))

        SELECT @Count = @@ROWCOUNT
    END
END
GO
/****** Object:  StoredProcedure [dbo].[aspnet_PersonalizationAdministration_GetCountOfState]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[aspnet_PersonalizationAdministration_GetCountOfState]
@Count INT OUTPUT, @AllUsersScope BIT, @ApplicationName NVARCHAR (256), @Path NVARCHAR (256)=NULL, @UserName NVARCHAR (256)=NULL, @InactiveSinceDate DATETIME=NULL
AS
BEGIN

    DECLARE @ApplicationId UNIQUEIDENTIFIER
    EXEC dbo.aspnet_Personalization_GetApplicationId @ApplicationName, @ApplicationId OUTPUT
    IF (@ApplicationId IS NULL)
        SELECT @Count = 0
    ELSE
        IF (@AllUsersScope = 1)
            SELECT @Count = COUNT(*)
            FROM dbo.aspnet_PersonalizationAllUsers AllUsers, dbo.aspnet_Paths Paths
            WHERE Paths.ApplicationId = @ApplicationId
                  AND AllUsers.PathId = Paths.PathId
                  AND (@Path IS NULL OR Paths.LoweredPath LIKE LOWER(@Path))
        ELSE
            SELECT @Count = COUNT(*)
            FROM dbo.aspnet_PersonalizationPerUser PerUser, dbo.aspnet_Users Users, dbo.aspnet_Paths Paths
            WHERE Paths.ApplicationId = @ApplicationId
                  AND PerUser.UserId = Users.UserId
                  AND PerUser.PathId = Paths.PathId
                  AND (@Path IS NULL OR Paths.LoweredPath LIKE LOWER(@Path))
                  AND (@UserName IS NULL OR Users.LoweredUserName LIKE LOWER(@UserName))
                  AND (@InactiveSinceDate IS NULL OR Users.LastActivityDate <= @InactiveSinceDate)
END
GO
/****** Object:  StoredProcedure [dbo].[aspnet_PersonalizationAdministration_FindState]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[aspnet_PersonalizationAdministration_FindState]
@AllUsersScope BIT, @ApplicationName NVARCHAR (256), @PageIndex INT, @PageSize INT, @Path NVARCHAR (256)=NULL, @UserName NVARCHAR (256)=NULL, @InactiveSinceDate DATETIME=NULL
AS
BEGIN
    DECLARE @ApplicationId UNIQUEIDENTIFIER
    EXEC dbo.aspnet_Personalization_GetApplicationId @ApplicationName, @ApplicationId OUTPUT
    IF (@ApplicationId IS NULL)
        RETURN

    -- Set the page bounds
    DECLARE @PageLowerBound INT
    DECLARE @PageUpperBound INT
    DECLARE @TotalRecords   INT
    SET @PageLowerBound = @PageSize * @PageIndex
    SET @PageUpperBound = @PageSize - 1 + @PageLowerBound

    -- Create a temp table to store the selected results
    CREATE TABLE #PageIndex (
        IndexId int IDENTITY (0, 1) NOT NULL,
        ItemId UNIQUEIDENTIFIER
    )

    IF (@AllUsersScope = 1)
    BEGIN
        -- Insert into our temp table
        INSERT INTO #PageIndex (ItemId)
        SELECT Paths.PathId
        FROM dbo.aspnet_Paths Paths,
             ((SELECT Paths.PathId
               FROM dbo.aspnet_PersonalizationAllUsers AllUsers, dbo.aspnet_Paths Paths
               WHERE Paths.ApplicationId = @ApplicationId
                      AND AllUsers.PathId = Paths.PathId
                      AND (@Path IS NULL OR Paths.LoweredPath LIKE LOWER(@Path))
              ) AS SharedDataPerPath
              FULL OUTER JOIN
              (SELECT DISTINCT Paths.PathId
               FROM dbo.aspnet_PersonalizationPerUser PerUser, dbo.aspnet_Paths Paths
               WHERE Paths.ApplicationId = @ApplicationId
                      AND PerUser.PathId = Paths.PathId
                      AND (@Path IS NULL OR Paths.LoweredPath LIKE LOWER(@Path))
              ) AS UserDataPerPath
              ON SharedDataPerPath.PathId = UserDataPerPath.PathId
             )
        WHERE Paths.PathId = SharedDataPerPath.PathId OR Paths.PathId = UserDataPerPath.PathId
        ORDER BY Paths.Path ASC

        SELECT @TotalRecords = @@ROWCOUNT

        SELECT Paths.Path,
               SharedDataPerPath.LastUpdatedDate,
               SharedDataPerPath.SharedDataLength,
               UserDataPerPath.UserDataLength,
               UserDataPerPath.UserCount
        FROM dbo.aspnet_Paths Paths,
             ((SELECT PageIndex.ItemId AS PathId,
                      AllUsers.LastUpdatedDate AS LastUpdatedDate,
                      DATALENGTH(AllUsers.PageSettings) AS SharedDataLength
               FROM dbo.aspnet_PersonalizationAllUsers AllUsers, #PageIndex PageIndex
               WHERE AllUsers.PathId = PageIndex.ItemId
                     AND PageIndex.IndexId >= @PageLowerBound AND PageIndex.IndexId <= @PageUpperBound
              ) AS SharedDataPerPath
              FULL OUTER JOIN
              (SELECT PageIndex.ItemId AS PathId,
                      SUM(DATALENGTH(PerUser.PageSettings)) AS UserDataLength,
                      COUNT(*) AS UserCount
               FROM aspnet_PersonalizationPerUser PerUser, #PageIndex PageIndex
               WHERE PerUser.PathId = PageIndex.ItemId
                     AND PageIndex.IndexId >= @PageLowerBound AND PageIndex.IndexId <= @PageUpperBound
               GROUP BY PageIndex.ItemId
              ) AS UserDataPerPath
              ON SharedDataPerPath.PathId = UserDataPerPath.PathId
             )
        WHERE Paths.PathId = SharedDataPerPath.PathId OR Paths.PathId = UserDataPerPath.PathId
        ORDER BY Paths.Path ASC
    END
    ELSE
    BEGIN
        -- Insert into our temp table
        INSERT INTO #PageIndex (ItemId)
        SELECT PerUser.Id
        FROM dbo.aspnet_PersonalizationPerUser PerUser, dbo.aspnet_Users Users, dbo.aspnet_Paths Paths
        WHERE Paths.ApplicationId = @ApplicationId
              AND PerUser.UserId = Users.UserId
              AND PerUser.PathId = Paths.PathId
              AND (@Path IS NULL OR Paths.LoweredPath LIKE LOWER(@Path))
              AND (@UserName IS NULL OR Users.LoweredUserName LIKE LOWER(@UserName))
              AND (@InactiveSinceDate IS NULL OR Users.LastActivityDate <= @InactiveSinceDate)
        ORDER BY Paths.Path ASC, Users.UserName ASC

        SELECT @TotalRecords = @@ROWCOUNT

        SELECT Paths.Path, PerUser.LastUpdatedDate, DATALENGTH(PerUser.PageSettings), Users.UserName, Users.LastActivityDate
        FROM dbo.aspnet_PersonalizationPerUser PerUser, dbo.aspnet_Users Users, dbo.aspnet_Paths Paths, #PageIndex PageIndex
        WHERE PerUser.Id = PageIndex.ItemId
              AND PerUser.UserId = Users.UserId
              AND PerUser.PathId = Paths.PathId
              AND PageIndex.IndexId >= @PageLowerBound AND PageIndex.IndexId <= @PageUpperBound
        ORDER BY Paths.Path ASC, Users.UserName ASC
    END

    RETURN @TotalRecords
END
GO
/****** Object:  StoredProcedure [dbo].[aspnet_PersonalizationAdministration_DeleteAllState]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[aspnet_PersonalizationAdministration_DeleteAllState]
@AllUsersScope BIT, @ApplicationName NVARCHAR (256), @Count INT OUTPUT
AS
BEGIN
    DECLARE @ApplicationId UNIQUEIDENTIFIER
    EXEC dbo.aspnet_Personalization_GetApplicationId @ApplicationName, @ApplicationId OUTPUT
    IF (@ApplicationId IS NULL)
        SELECT @Count = 0
    ELSE
    BEGIN
        IF (@AllUsersScope = 1)
            DELETE FROM aspnet_PersonalizationAllUsers
            WHERE PathId IN
               (SELECT Paths.PathId
                FROM dbo.aspnet_Paths Paths
                WHERE Paths.ApplicationId = @ApplicationId)
        ELSE
            DELETE FROM aspnet_PersonalizationPerUser
            WHERE PathId IN
               (SELECT Paths.PathId
                FROM dbo.aspnet_Paths Paths
                WHERE Paths.ApplicationId = @ApplicationId)

        SELECT @Count = @@ROWCOUNT
    END
END
GO
/****** Object:  StoredProcedure [dbo].[aspnet_PersonalizationPerUser_SetPageSettings]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[aspnet_PersonalizationPerUser_SetPageSettings]
@ApplicationName NVARCHAR (256), @UserName NVARCHAR (256), @Path NVARCHAR (256), @PageSettings IMAGE, @CurrentTimeUtc DATETIME
AS
BEGIN
    DECLARE @ApplicationId UNIQUEIDENTIFIER
    DECLARE @PathId UNIQUEIDENTIFIER
    DECLARE @UserId UNIQUEIDENTIFIER

    SELECT @ApplicationId = NULL
    SELECT @PathId = NULL
    SELECT @UserId = NULL

    EXEC dbo.aspnet_Applications_CreateApplication @ApplicationName, @ApplicationId OUTPUT

    SELECT @PathId = u.PathId FROM dbo.aspnet_Paths u WHERE u.ApplicationId = @ApplicationId AND u.LoweredPath = LOWER(@Path)
    IF (@PathId IS NULL)
    BEGIN
        EXEC dbo.aspnet_Paths_CreatePath @ApplicationId, @Path, @PathId OUTPUT
    END

    SELECT @UserId = u.UserId FROM dbo.aspnet_Users u WHERE u.ApplicationId = @ApplicationId AND u.LoweredUserName = LOWER(@UserName)
    IF (@UserId IS NULL)
    BEGIN
        EXEC dbo.aspnet_Users_CreateUser @ApplicationId, @UserName, 0, @CurrentTimeUtc, @UserId OUTPUT
    END

    UPDATE   dbo.aspnet_Users WITH (ROWLOCK)
    SET      LastActivityDate = @CurrentTimeUtc
    WHERE    UserId = @UserId
    IF (@@ROWCOUNT = 0) -- Username not found
        RETURN

    IF (EXISTS(SELECT PathId FROM dbo.aspnet_PersonalizationPerUser WHERE UserId = @UserId AND PathId = @PathId))
        UPDATE dbo.aspnet_PersonalizationPerUser SET PageSettings = @PageSettings, LastUpdatedDate = @CurrentTimeUtc WHERE UserId = @UserId AND PathId = @PathId
    ELSE
        INSERT INTO dbo.aspnet_PersonalizationPerUser(UserId, PathId, PageSettings, LastUpdatedDate) VALUES (@UserId, @PathId, @PageSettings, @CurrentTimeUtc)
    RETURN 0
END
GO
/****** Object:  StoredProcedure [dbo].[aspnet_PersonalizationPerUser_ResetPageSettings]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[aspnet_PersonalizationPerUser_ResetPageSettings]
@ApplicationName NVARCHAR (256), @UserName NVARCHAR (256), @Path NVARCHAR (256), @CurrentTimeUtc DATETIME
AS
BEGIN
    DECLARE @ApplicationId UNIQUEIDENTIFIER
    DECLARE @PathId UNIQUEIDENTIFIER
    DECLARE @UserId UNIQUEIDENTIFIER

    SELECT @ApplicationId = NULL
    SELECT @PathId = NULL
    SELECT @UserId = NULL

    EXEC dbo.aspnet_Personalization_GetApplicationId @ApplicationName, @ApplicationId OUTPUT
    IF (@ApplicationId IS NULL)
    BEGIN
        RETURN
    END

    SELECT @PathId = u.PathId FROM dbo.aspnet_Paths u WHERE u.ApplicationId = @ApplicationId AND u.LoweredPath = LOWER(@Path)
    IF (@PathId IS NULL)
    BEGIN
        RETURN
    END

    SELECT @UserId = u.UserId FROM dbo.aspnet_Users u WHERE u.ApplicationId = @ApplicationId AND u.LoweredUserName = LOWER(@UserName)
    IF (@UserId IS NULL)
    BEGIN
        RETURN
    END

    UPDATE   dbo.aspnet_Users WITH (ROWLOCK)
    SET      LastActivityDate = @CurrentTimeUtc
    WHERE    UserId = @UserId
    IF (@@ROWCOUNT = 0) -- Username not found
        RETURN

    DELETE FROM dbo.aspnet_PersonalizationPerUser WHERE PathId = @PathId AND UserId = @UserId
    RETURN 0
END
GO
/****** Object:  StoredProcedure [dbo].[aspnet_PersonalizationPerUser_GetPageSettings]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[aspnet_PersonalizationPerUser_GetPageSettings]
@ApplicationName NVARCHAR (256), @UserName NVARCHAR (256), @Path NVARCHAR (256), @CurrentTimeUtc DATETIME
AS
BEGIN
    DECLARE @ApplicationId UNIQUEIDENTIFIER
    DECLARE @PathId UNIQUEIDENTIFIER
    DECLARE @UserId UNIQUEIDENTIFIER

    SELECT @ApplicationId = NULL
    SELECT @PathId = NULL
    SELECT @UserId = NULL

    EXEC dbo.aspnet_Personalization_GetApplicationId @ApplicationName, @ApplicationId OUTPUT
    IF (@ApplicationId IS NULL)
    BEGIN
        RETURN
    END

    SELECT @PathId = u.PathId FROM dbo.aspnet_Paths u WHERE u.ApplicationId = @ApplicationId AND u.LoweredPath = LOWER(@Path)
    IF (@PathId IS NULL)
    BEGIN
        RETURN
    END

    SELECT @UserId = u.UserId FROM dbo.aspnet_Users u WHERE u.ApplicationId = @ApplicationId AND u.LoweredUserName = LOWER(@UserName)
    IF (@UserId IS NULL)
    BEGIN
        RETURN
    END

    UPDATE   dbo.aspnet_Users WITH (ROWLOCK)
    SET      LastActivityDate = @CurrentTimeUtc
    WHERE    UserId = @UserId
    IF (@@ROWCOUNT = 0) -- Username not found
        RETURN

    SELECT p.PageSettings FROM dbo.aspnet_PersonalizationPerUser p WHERE p.PathId = @PathId AND p.UserId = @UserId
END
GO
/****** Object:  StoredProcedure [dbo].[aspnet_Profile_SetProperties]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[aspnet_Profile_SetProperties]
@ApplicationName NVARCHAR (256), @PropertyNames NTEXT, @PropertyValuesString NTEXT, @PropertyValuesBinary IMAGE, @UserName NVARCHAR (256), @IsUserAnonymous BIT, @CurrentTimeUtc DATETIME
AS
BEGIN
    DECLARE @ApplicationId uniqueidentifier
    SELECT  @ApplicationId = NULL

    DECLARE @ErrorCode     int
    SET @ErrorCode = 0

    DECLARE @TranStarted   bit
    SET @TranStarted = 0

    IF( @@TRANCOUNT = 0 )
    BEGIN
       BEGIN TRANSACTION
       SET @TranStarted = 1
    END
    ELSE
    	SET @TranStarted = 0

    EXEC dbo.aspnet_Applications_CreateApplication @ApplicationName, @ApplicationId OUTPUT

    IF( @@ERROR <> 0 )
    BEGIN
        SET @ErrorCode = -1
        GOTO Cleanup
    END

    DECLARE @UserId uniqueidentifier
    DECLARE @LastActivityDate datetime
    SELECT  @UserId = NULL
    SELECT  @LastActivityDate = @CurrentTimeUtc

    SELECT @UserId = UserId
    FROM   dbo.aspnet_Users
    WHERE  ApplicationId = @ApplicationId AND LoweredUserName = LOWER(@UserName)
    IF (@UserId IS NULL)
        EXEC dbo.aspnet_Users_CreateUser @ApplicationId, @UserName, @IsUserAnonymous, @LastActivityDate, @UserId OUTPUT

    IF( @@ERROR <> 0 )
    BEGIN
        SET @ErrorCode = -1
        GOTO Cleanup
    END

    UPDATE dbo.aspnet_Users
    SET    LastActivityDate=@CurrentTimeUtc
    WHERE  UserId = @UserId

    IF( @@ERROR <> 0 )
    BEGIN
        SET @ErrorCode = -1
        GOTO Cleanup
    END

    IF (EXISTS( SELECT *
               FROM   dbo.aspnet_Profile
               WHERE  UserId = @UserId))
        UPDATE dbo.aspnet_Profile
        SET    PropertyNames=@PropertyNames, PropertyValuesString = @PropertyValuesString,
               PropertyValuesBinary = @PropertyValuesBinary, LastUpdatedDate=@CurrentTimeUtc
        WHERE  UserId = @UserId
    ELSE
        INSERT INTO dbo.aspnet_Profile(UserId, PropertyNames, PropertyValuesString, PropertyValuesBinary, LastUpdatedDate)
             VALUES (@UserId, @PropertyNames, @PropertyValuesString, @PropertyValuesBinary, @CurrentTimeUtc)

    IF( @@ERROR <> 0 )
    BEGIN
        SET @ErrorCode = -1
        GOTO Cleanup
    END

    IF( @TranStarted = 1 )
    BEGIN
    	SET @TranStarted = 0
    	COMMIT TRANSACTION
    END

    RETURN 0

Cleanup:

    IF( @TranStarted = 1 )
    BEGIN
        SET @TranStarted = 0
    	ROLLBACK TRANSACTION
    END

    RETURN @ErrorCode

END
GO
/****** Object:  StoredProcedure [dbo].[aspnet_Profile_GetProperties]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[aspnet_Profile_GetProperties]
@ApplicationName NVARCHAR (256), @UserName NVARCHAR (256), @CurrentTimeUtc DATETIME
AS
BEGIN
    DECLARE @ApplicationId uniqueidentifier
    SELECT  @ApplicationId = NULL
    SELECT  @ApplicationId = ApplicationId FROM dbo.aspnet_Applications WHERE LOWER(@ApplicationName) = LoweredApplicationName
    IF (@ApplicationId IS NULL)
        RETURN

    DECLARE @UserId uniqueidentifier
    SELECT  @UserId = NULL

    SELECT @UserId = UserId
    FROM   dbo.aspnet_Users
    WHERE  ApplicationId = @ApplicationId AND LoweredUserName = LOWER(@UserName)

    IF (@UserId IS NULL)
        RETURN
    SELECT TOP 1 PropertyNames, PropertyValuesString, PropertyValuesBinary
    FROM         dbo.aspnet_Profile
    WHERE        UserId = @UserId

    IF (@@ROWCOUNT > 0)
    BEGIN
        UPDATE dbo.aspnet_Users
        SET    LastActivityDate=@CurrentTimeUtc
        WHERE  UserId = @UserId
    END
END
GO
/****** Object:  StoredProcedure [dbo].[aspnet_Profile_GetProfiles]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[aspnet_Profile_GetProfiles]
@ApplicationName NVARCHAR (256), @ProfileAuthOptions INT, @PageIndex INT, @PageSize INT, @UserNameToMatch NVARCHAR (256)=NULL, @InactiveSinceDate DATETIME=NULL
AS
BEGIN
    DECLARE @ApplicationId uniqueidentifier
    SELECT  @ApplicationId = NULL
    SELECT  @ApplicationId = ApplicationId FROM aspnet_Applications WHERE LOWER(@ApplicationName) = LoweredApplicationName
    IF (@ApplicationId IS NULL)
        RETURN

    -- Set the page bounds
    DECLARE @PageLowerBound int
    DECLARE @PageUpperBound int
    DECLARE @TotalRecords   int
    SET @PageLowerBound = @PageSize * @PageIndex
    SET @PageUpperBound = @PageSize - 1 + @PageLowerBound

    -- Create a temp table TO store the select results
    CREATE TABLE #PageIndexForUsers
    (
        IndexId int IDENTITY (0, 1) NOT NULL,
        UserId uniqueidentifier
    )

    -- Insert into our temp table
    INSERT INTO #PageIndexForUsers (UserId)
        SELECT  u.UserId
        FROM    dbo.aspnet_Users u, dbo.aspnet_Profile p
        WHERE   ApplicationId = @ApplicationId
            AND u.UserId = p.UserId
            AND (@InactiveSinceDate IS NULL OR LastActivityDate <= @InactiveSinceDate)
            AND (     (@ProfileAuthOptions = 2)
                   OR (@ProfileAuthOptions = 0 AND IsAnonymous = 1)
                   OR (@ProfileAuthOptions = 1 AND IsAnonymous = 0)
                 )
            AND (@UserNameToMatch IS NULL OR LoweredUserName LIKE LOWER(@UserNameToMatch))
        ORDER BY UserName

    SELECT  u.UserName, u.IsAnonymous, u.LastActivityDate, p.LastUpdatedDate,
            DATALENGTH(p.PropertyNames) + DATALENGTH(p.PropertyValuesString) + DATALENGTH(p.PropertyValuesBinary)
    FROM    dbo.aspnet_Users u, dbo.aspnet_Profile p, #PageIndexForUsers i
    WHERE   u.UserId = p.UserId AND p.UserId = i.UserId AND i.IndexId >= @PageLowerBound AND i.IndexId <= @PageUpperBound

    SELECT COUNT(*)
    FROM   #PageIndexForUsers

    DROP TABLE #PageIndexForUsers
END
GO
/****** Object:  StoredProcedure [dbo].[aspnet_Profile_GetNumberOfInactiveProfiles]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[aspnet_Profile_GetNumberOfInactiveProfiles]
@ApplicationName NVARCHAR (256), @ProfileAuthOptions INT, @InactiveSinceDate DATETIME
AS
BEGIN
    DECLARE @ApplicationId uniqueidentifier
    SELECT  @ApplicationId = NULL
    SELECT  @ApplicationId = ApplicationId FROM aspnet_Applications WHERE LOWER(@ApplicationName) = LoweredApplicationName
    IF (@ApplicationId IS NULL)
    BEGIN
        SELECT 0
        RETURN
    END

    SELECT  COUNT(*)
    FROM    dbo.aspnet_Users u, dbo.aspnet_Profile p
    WHERE   ApplicationId = @ApplicationId
        AND u.UserId = p.UserId
        AND (LastActivityDate <= @InactiveSinceDate)
        AND (
                (@ProfileAuthOptions = 2)
                OR (@ProfileAuthOptions = 0 AND IsAnonymous = 1)
                OR (@ProfileAuthOptions = 1 AND IsAnonymous = 0)
            )
END
GO
/****** Object:  StoredProcedure [dbo].[aspnet_Profile_DeleteProfiles]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[aspnet_Profile_DeleteProfiles]
@ApplicationName NVARCHAR (256), @UserNames NVARCHAR (4000)
AS
BEGIN
    DECLARE @UserName     nvarchar(256)
    DECLARE @CurrentPos   int
    DECLARE @NextPos      int
    DECLARE @NumDeleted   int
    DECLARE @DeletedUser  int
    DECLARE @TranStarted  bit
    DECLARE @ErrorCode    int

    SET @ErrorCode = 0
    SET @CurrentPos = 1
    SET @NumDeleted = 0
    SET @TranStarted = 0

    IF( @@TRANCOUNT = 0 )
    BEGIN
        BEGIN TRANSACTION
        SET @TranStarted = 1
    END
    ELSE
    	SET @TranStarted = 0

    WHILE (@CurrentPos <= LEN(@UserNames))
    BEGIN
        SELECT @NextPos = CHARINDEX(N',', @UserNames,  @CurrentPos)
        IF (@NextPos = 0 OR @NextPos IS NULL)
            SELECT @NextPos = LEN(@UserNames) + 1

        SELECT @UserName = SUBSTRING(@UserNames, @CurrentPos, @NextPos - @CurrentPos)
        SELECT @CurrentPos = @NextPos+1

        IF (LEN(@UserName) > 0)
        BEGIN
            SELECT @DeletedUser = 0
            EXEC dbo.aspnet_Users_DeleteUser @ApplicationName, @UserName, 4, @DeletedUser OUTPUT
            IF( @@ERROR <> 0 )
            BEGIN
                SET @ErrorCode = -1
                GOTO Cleanup
            END
            IF (@DeletedUser <> 0)
                SELECT @NumDeleted = @NumDeleted + 1
        END
    END
    SELECT @NumDeleted
    IF (@TranStarted = 1)
    BEGIN
    	SET @TranStarted = 0
    	COMMIT TRANSACTION
    END
    SET @TranStarted = 0

    RETURN 0

Cleanup:
    IF (@TranStarted = 1 )
    BEGIN
        SET @TranStarted = 0
    	ROLLBACK TRANSACTION
    END
    RETURN @ErrorCode
END
GO
/****** Object:  UserDefinedFunction [dbo].[f_PropertyInfo__ConcatenateAddress]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[f_PropertyInfo__ConcatenateAddress]    
(@PropertyInfoId INT)    
RETURNS NVARCHAR (MAX)    
AS    
begin    
 declare @result nvarchar(max)    
    
 select @result = coalesce(ISNULL(PropertyInfo.UnitShopNumber, '') + '/', '') + ISNULL(PropertyInfo.StreetNumber, '') + ' ' + ISNULL(PropertyInfo.StreetName, '') + ' ' + ISNULL(PropertyInfo.Suburb, '')  
 from PropertyInfo    
 where PropertyInfo.PropertyInfoId = @PropertyInfoId    
    
    return @result    
end
GO
/****** Object:  StoredProcedure [dbo].[p_PropertyInfo__UpdateInspectionStatus]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[p_PropertyInfo__UpdateInspectionStatus]
@selectedRows NVARCHAR (MAX), @status int, @userId uniqueidentifier
AS
set nocount on

UPDATE	
	PropertyInfo
SET
	InspectionStatusId = @status,
	ModifiedByUserId = @userId,
	InspectionStatusUpdatedDate = GETUTCDATE()
WHERE
	PropertyInfoId IN (SELECT value from dbo.f_IntSplit(@selectedRows, ','))
	
return 0
GO
/****** Object:  StoredProcedure [dbo].[p_PropertyInfo__UpdateElectricalWorkStatus]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[p_PropertyInfo__UpdateElectricalWorkStatus]
@selectedRows NVARCHAR (MAX), @status int, @userId uniqueidentifier
AS
set nocount on

UPDATE	
	PropertyInfo
SET
	ElectricalWorkStatusId = @status,
	ModifiedByUserId = @userId,
	ElectricalWorkStatusUpdatedDate = GETUTCDATE()
WHERE
	PropertyInfoId IN (SELECT value from dbo.f_IntSplit(@selectedRows, ','))
	
return 0
GO
/****** Object:  StoredProcedure [dbo].[p_PropertyInfo__UpdateDiscountPercentage]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Roger Clark
-- Create date: 21/03/2013
-- Description:	Update percentage discount in PropertyInfo Table
-- =============================================
CREATE PROCEDURE [dbo].[p_PropertyInfo__UpdateDiscountPercentage] 
	-- Add the parameters for the stored procedure here
	@selectedRows NVARCHAR(MAX) = 0, 
	@discountPercentage money = 0,
	@userId uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

UPDATE	
	PropertyInfo
SET
	DiscountPercentage = @discountPercentage,
	ModifiedByUserId = @userId,
	ModifiedUtcDate = GETUTCDATE()
WHERE
	PropertyInfoId IN (SELECT value from dbo.f_IntSplit(@selectedRows, ','))
	
return 0
END
GO
/****** Object:  StoredProcedure [dbo].[p_PropertyInfo__UpdateDiscount]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[p_PropertyInfo__UpdateDiscount]
@selectedRows NVARCHAR (MAX), @discount money, @userId uniqueidentifier
AS
set nocount on

UPDATE	
	PropertyInfo
SET
	Discount = @discount,
	ModifiedByUserId = @userId,
	ModifiedUtcDate = GETUTCDATE()
WHERE
	PropertyInfoId IN (SELECT value from dbo.f_IntSplit(@selectedRows, ','))
	
return 0
GO
/****** Object:  StoredProcedure [dbo].[p_PropertyInfo__TenantInfo]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[p_PropertyInfo__TenantInfo]
	@selectedRows NVARCHAR(MAX)
AS

SELECT
	RTRIM(SUBSTRING(occupantname,1, LEN(occupantname) - CHARINDEX(' ', REVERSE(occupantname))))				[First]
	-- Middle
	,NULL																									[Middle]
	,LTRIM(REVERSE(left(REVERSE(occupantname),CHARINDEX(' ', REVERSE(occupantname)))))						[Last]
    ,dbo.f_StreetAddress(PropertyInfo.UnitShopNumber, PropertyInfo.StreetNumber, PropertyInfo.StreetName)	[Home Street]
	,PropertyInfo.Suburb																					[Home City]
	,PropertyInfo.PostCode																					[Home Postcode]
    ,ISNULL(PropertyInfo.PostalAddress, 
			dbo.f_StreetAddress(PropertyInfo.UnitShopNumber, PropertyInfo.StreetNumber, PropertyInfo.StreetName)) [Mailing Street]
	,ISNULL(PropertyInfo.PostalSuburb,PropertyInfo.Suburb)													[Mailing City]
	,ISNULL(PropertyInfo.PostalPostCode, PropertyInfo.Postcode)												[Mailing Postcode]
	,dbo.f_PropertyInfo__ConcatenateContactNumberOfType(PropertyInfo.PropertyInfoId, 2)						[Home]
	,dbo.f_PropertyInfo__ConcatenateContactNumberOfType(PropertyInfo.PropertyInfoId, 1)						[Mobile]
	,dbo.f_PropertyInfo__ConcatenateContactNumberOfType(PropertyInfo.PropertyInfoId, 3)						[Business]
	-- Fax
	,NULL																									[Fax]
	-- Company
	,dbo.f_PropertyInfo__ConcatenateContactNumberOfType(PropertyInfo.PropertyInfoId, 4)						[Company]
    ,OccupantEmail																							[Email]
FROM
	PropertyInfo
WHERE
	PropertyInfo.PropertyInfoId in (select value from [dbo].[f_IntSplit](@selectedRows, ','))
GO
/****** Object:  StoredProcedure [dbo].[p_PropertyInfo__MonthlyService_2]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[p_PropertyInfo__MonthlyService_2]  
 @date datetime = NULL  
AS  
  
BEGIN  
  
IF @date IS NULL  
BEGIN  
 SET @date = CONVERT(date, GETDATE())  
END  
  
DECLARE @startDate datetime, @endDate datetime  
  
SET @startDate = dbo.f_FirstOfMonth(@date)  
SET @endDate = DATEADD(day, -1, DATEADD(year, 1,@startDate))  

PRINT @startDate
PRINT @endDAte
  
SELECT  'Total Services' [Series],  
        CAST([Month] AS Varchar)  + '/' + CAST([Year] AS varchar) [Label],  
		SUM(Value) [Value]  
FROM   
(  
		SELECT  'Total Services' [Series],  
				CalendarMonth [Label],  
				[Year] [Year],  
				[Month] [Month],  
				0 [Value]  
		FROM    [dbo].[f_CalendarMonths](@date)  
		
		UNION  

		SELECT  'Total Services' [Series],   
				CAST(MONTH(dbo.f_NextServiceDate(LastServicedDate, SettlementDate, CreatedUtcDate)) AS varchar) + '/' + CAST(YEAR(dbo.f_NextServiceDate(LastServicedDate, SettlementDate, CreatedUtcDate)) as nvarchar) [Label],  
				YEAR(dbo.f_NextServiceDate(LastServicedDate, SettlementDate, CreatedUtcDate)) [Year],  
				MONTH(dbo.f_NextServiceDate(LastServicedDate, SettlementDate, CreatedUtcDate)) [Month],  
				CAST(COUNT(PropertyInfoId) as numeric) [Value]  
		FROM	PropertyInfo
		WHERE   dbo.f_NextServiceDate(LastServicedDate, SettlementDate, CreatedUtcDate) BETWEEN @startDate AND @endDate AND
				PropertyInfo.IsDeleted = 0 AND
				Propertyinfo.IsCancelled = 0
		GROUP BY    YEAR(dbo.f_NextServiceDate(LastServicedDate, SettlementDate, CreatedUtcDate)),
					MONTH(dbo.f_NextServiceDate(LastServicedDate, SettlementDate, CreatedUtcDate))  
 ) AS TotalServices  
GROUP BY  
 [Year]  
 ,[Month]  
ORDER BY  
 [Year]  
 ,[Month]  
  
  
END
GO
/****** Object:  StoredProcedure [dbo].[p_PropertyInfo__MonthlyService]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[p_PropertyInfo__MonthlyService]  
 @date datetime = NULL,
 @monthCount int = 12
AS  
  
BEGIN  
  
IF @date IS NULL  
BEGIN  
 SET @date = CONVERT(date, GETDATE())  
END  
  
DECLARE @startDate datetime, @endDate datetime  
  
SET @startDate = dbo.f_FirstOfMonth(@date)  
SET @endDate = DATEADD(day, -1, DATEADD(month, @monthCount,@startDate))  

 
SELECT  'Total Services' [Series],  
        CAST([Month] AS Varchar)  + '/' + CAST(([Year] % 100) AS varchar) [Label],  
		SUM(Value) [Value]  
FROM   
(  
		SELECT  'Total Services' [Series],  
				CalendarMonth [Label],  
				[Year] [Year],  
				[Month] [Month],  
				0 [Value]  
		FROM    [dbo].[f_CalendarMonths](@date)  
		
		UNION  

		SELECT  'Total Services' [Series],   
				--CAST(MONTH(dbo.f_NextServiceDate(LastServicedDate, SettlementDate, CreatedUtcDate)) AS varchar) + '/' + CAST(YEAR(dbo.f_NextServiceDate(LastServicedDate, SettlementDate, CreatedUtcDate)) as nvarchar) [Label],  
				CAST(MONTH(Propertyinfo.NextServiceDate) AS varchar) + '/' + CAST(YEAR(Propertyinfo.NextServiceDate) as nvarchar) [Label],  
				--YEAR(dbo.f_NextServiceDate(LastServicedDate, SettlementDate, CreatedUtcDate)) [Year],  
				YEAR(Propertyinfo.NextServiceDate) [Year],  
				--MONTH(dbo.f_NextServiceDate(LastServicedDate, SettlementDate, CreatedUtcDate)) [Month],  
				MONTH(Propertyinfo.NextServiceDate) [Month],  
				CAST(COUNT(PropertyInfoId) as numeric) [Value]  
		FROM	PropertyInfo
		WHERE   --dbo.f_NextServiceDate(LastServicedDate, SettlementDate, CreatedUtcDate) BETWEEN @startDate AND @endDate 
				Propertyinfo.NextServiceDate BETWEEN @startDate AND @endDate AND
				PropertyInfo.IsDeleted = 0 AND
				Propertyinfo.IsCancelled = 0
		GROUP BY  YEAR(Propertyinfo.NextServiceDate),
					MONTH(Propertyinfo.NextServiceDate)  
		  --YEAR(dbo.f_NextServiceDate(LastServicedDate, SettlementDate, CreatedUtcDate)),
		  --MONTH(dbo.f_NextServiceDate(LastServicedDate, SettlementDate, CreatedUtcDate))  
 ) AS TotalServices  
GROUP BY  
 [Year]  
 ,[Month]  
ORDER BY  
 [Year]  
 ,[Month]  
  
  
END
GO
/****** Object:  StoredProcedure [dbo].[p_PropertyInfo__Cancel]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[p_PropertyInfo__Cancel]
@selectedRows NVARCHAR (MAX), @cancellationDate datetime, @cancellationNotes nvarchar(max), @userId uniqueidentifier
AS
set nocount on

UPDATE	
	PropertyInfo
SET
	IsCancelled = 1,
	CancellationDate = @cancellationDate,
	CancellationNotes = @cancellationNotes,
	ModifiedByUserId = @userId,
	ModifiedUtcDate = GETUTCDATE()
WHERE
	PropertyInfoId IN (SELECT value from dbo.f_IntSplit(@selectedRows, ','))
	
return 0
GO
/****** Object:  StoredProcedure [dbo].[p_PropertyInfo__Hold]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[p_PropertyInfo__Hold]
@selectedRows NVARCHAR (MAX), @holdDate datetime = NULL, @holdNotes nvarchar(max), @userId uniqueidentifier, @inspectionStatus int = null, @electricalWorkStatus int = null
AS
set nocount on

UPDATE	
	PropertyInfo
SET
	InspectionStatusId = ISNULL(@inspectionStatus, InspectionStatusId),
	ElectricalWorkStatusId = ISNULL(@electricalWorkStatus, ElectricalWorkStatusId),
	PropertyHoldDate = ISNULL(@holdDate, PropertyHoldDate),
	ContactNotes = @holdNotes + ' ' + ISNULL(ContactNotes, ''),
	ModifiedByUserId = @userId,
	ModifiedUtcDate = GETUTCDATE()
WHERE
	PropertyInfoId IN (SELECT value from dbo.f_IntSplit(@selectedRows, ','))
	
return 0
GO
/****** Object:  StoredProcedure [dbo].[p_Cleanup_PropertiesOnHold]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author:  <Author,,Name>  
-- Create date: <Create Date,,>  
-- Description: <Description,,>  
-- =============================================  
CREATE PROCEDURE [dbo].[p_Cleanup_PropertiesOnHold]  
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
  
    UPDATE  
  PropertyInfo  
 SET  
  PropertyInfo.InspectionStatusId = 1,  
  PropertyInfo.PropertyHoldDate = NULL  
 WHERE  
  PropertyInfo.InspectionStatusId = 7  
 AND  
  PropertyInfo.PropertyHoldDate >= Dateadd(day,datediff(day,0,getdate()),-1)  
   
END
GO
/****** Object:  Table [dbo].[Booking]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Booking](
	[BookingId] [int] IDENTITY(1,1) NOT NULL,
	[TechnicianId] [int] NULL,
	[PropertyInfoId] [int] NOT NULL,
	[Date] [datetime] NULL,
	[Time] [datetime] NULL,
	[Duration] [int] NULL,
	[KeyNumber] [nvarchar](50) NULL,
	[Notes] [nvarchar](max) NULL,
	[ZoneId] [int] NOT NULL,
	[IsInvoiced] [bit] NULL,
	[IsDeleted] [bit] NULL,
	[CreatedByUserId] [uniqueidentifier] NULL,
	[CreatedUtcDate] [datetime] NULL,
	[ModifiedByUserId] [uniqueidentifier] NULL,
	[ModifiedUtcDate] [datetime] NULL,
	[RowVersion] [timestamp] NULL,
 CONSTRAINT [PK_Booking] PRIMARY KEY CLUSTERED 
(
	[BookingId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Detector]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Detector](
	[DetectorId] [int] IDENTITY(1,1) NOT NULL,
	[PropertyInfoId] [int] NOT NULL,
	[Location] [nvarchar](100) NOT NULL,
	[DetectorTypeId] [int] NOT NULL,
	[Manufacturer] [nvarchar](50) NOT NULL,
	[ExpiryYear] [int] NULL,
	[IsOptional] [bit] NOT NULL,
	[IsDeleted] [bit] NULL,
	[CreatedByUserId] [uniqueidentifier] NULL,
	[CreatedUtcDate] [datetime] NULL,
	[ModifiedByUserId] [uniqueidentifier] NULL,
	[ModifiedUtcDate] [datetime] NULL,
	[RowVersion] [timestamp] NULL,
	[NewExpiryYear] [int] NULL,
 CONSTRAINT [PK_Detector] PRIMARY KEY CLUSTERED 
(
	[DetectorId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Detector_isDeleted] ON [dbo].[Detector] 
(
	[IsDeleted] ASC
)
INCLUDE ( [PropertyInfoId],
[DetectorTypeId],
[ExpiryYear],
[IsOptional]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PropfertyInfoId] ON [dbo].[Detector] 
(
	[PropertyInfoId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RolePermission]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RolePermission](
	[RoleId] [int] NOT NULL,
	[PermissionId] [int] NOT NULL,
 CONSTRAINT [PK_RolePermission] PRIMARY KEY CLUSTERED 
(
	[RoleId] ASC,
	[PermissionId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[v_PropertyInfos]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[v_PropertyInfos] 
AS
WITH PropertyInfos AS
(     
      SELECT [PropertyInfoId]
      ,[PropertyNumber]
      ,[AgencyId]
      ,[PropertyManagerId]
      ,[HasSendNotification]
      ,[HasLargeLadder]
      ,[KeyNumber]
      ,[UnitShopNumber]
      ,[StreetNumber]
      ,[StreetName]
      ,[Suburb]
      ,[StateId]
      ,[PostCode]
      ,[ZoneId]
      ,[OccupantName]
      ,[OccupantEmail]
      ,[PostalAddress]
      ,[PostalSuburb]
      ,[PostalPostcode]
      ,[PostalStateId]
      ,[PostalCountry]
      ,[Notes]
      ,[IsCancelled]
      ,[CancellationNotes]
      ,[CancellationDate]
      ,[SettlementDate]
      ,[PropertyHoldDate]
      ,[Discount]
      ,[LastServicedDate]
      ,[NextServiceDate]
      ,[InspectionStatusUpdatedDate]
      ,[InspectionStatusId]
      ,[ElectricalWorkStatusUpdatedDate]
      ,[ElectricalWorkStatusId]
      ,[HasProblem]
      ,[ProblemStatusUpdatedDate]
      ,[ProblemNotes]
      ,[ContactNotes]
      ,[IsOneOffService]
      ,[IsServiceCompleted]
      ,[LandlordName]
      ,[LandlordAddress]
      ,[LandlordSuburb]
      ,[LandlordPostcode]
      ,[LandlordStateId]
      ,[LandlordCountry]
      ,[LandlordEmail]
      ,[ConcatenatedTenantName]
      ,[ConcatenatedTenantContactNumber]
      ,[IsDeleted]
      ,[CreatedByUserId]
      ,[CreatedUtcDate]
      ,[ModifiedByUserId]
      ,[ModifiedUtcDate]
      ,[RowVersion]
  
            ,CONVERT(date, COALESCE(Dateadd(year, 1, PropertyInfo.LastServicedDate), PropertyInfo.SettlementDate, DATEADD(Hour, DATEDIFF(Hour, GETDATE(), GETUTCDATE()), PropertyInfo.CreatedUtcDate), getdate())) CalculatedNextServiceDate
      FROM PropertyInfo
      
)

SELECT 
      PropertyInfo.* 
, CASE WHEN --replaces f_IsOverDue
                  CASE WHEN PropertyInfo.LastServicedDate IS NOT NULL AND PropertyInfo.InspectionStatusId NOT IN (7,8,9,10,12)                    
                        AND CalculatedNextServiceDate < GETDATE() 
                        AND PropertyInfo.InspectionStatusId = rs.InspectionStatusId 
                        THEN 1 ELSE 0 END  = 1 
                  THEN ds.OverdueStatusId
                  
      WHEN --replaces f_IsComingUpForService
            CASE WHEN PropertyInfo.InspectionStatusId NOT IN (7,8,9,10,12) AND CalculatedNextServiceDate > DATEADD(ww, -6, GETDATE()) AND CalculatedNextServiceDate > GETDATE() AND PropertyInfo.InspectionStatusId = rs.InspectionStatusId THEN 1 ELSE 0 END = 1 
            THEN ds.ComingUpForServiceStatusId
      
      WHEN --replaces f_IsNew 
            CASE WHEN PropertyInfo.LastServicedDate IS NULL AND PropertyInfo.InspectionStatusId = rs.InspectionStatusId THEN 1 ELSE 0 END = 1 
            THEN ds.NewPropertyStatusId   
      
      END AS DynamicReadyForServiceStatusId
    
FROM PropertyInfos PropertyInfo
CROSS JOIN (SELECT TOP 1 * FROM  v_DynamicReadyForServiceStatus) ds
CROSS JOIN (SELECT TOP 1 InspectionStatusId FROM ReadyForServiceStatus) rs
GO
/****** Object:  Table [dbo].[UserRole]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserRole](
	[UserId] [uniqueidentifier] NOT NULL,
	[RoleId] [int] NOT NULL,
 CONSTRAINT [PK_UserRole] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[RoleId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PropertyBatchItem]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PropertyBatchItem](
	[PropertyBatchItemId] [int] IDENTITY(1,1) NOT NULL,
	[PropertyBatchId] [int] NOT NULL,
	[PropertyInfoId] [int] NOT NULL,
 CONSTRAINT [PK_PropertyBatchItem] PRIMARY KEY CLUSTERED 
(
	[PropertyBatchItemId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[PropertyInfoDetectorMainCount]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[PropertyInfoDetectorMainCount]        
AS        
  SELECT PropertyInfo.PropertyInfoId,        
   SUM(CAST(ISNULL(DetectorType.IsMain, 0) as int)) [DetectorMainCount],        
   SUM(CAST(ISNULL(MainsType.IsMain, 0) as int)) [TotalMainCount],        
   COUNT(*) [TotalDetectorCount]        
  FROM  PropertyInfo LEFT OUTER JOIN         
   Detector ON PropertyInfo.PropertyInfoId = Detector.PropertyInfoId AND Detector.IsDeleted = 0 LEFT OUTER JOIN          
   DetectorType ON Detector.DetectorTypeId = DetectorType.DetectorTypeId AND         
       DetectorType.IsMain = 1 AND         
       (YEAR(GETDATE()) + 1) >= Detector.ExpiryYear AND         
       Detector.ExpiryYear > Year(GetDate()) AND
       Detector.IsOptional = 0 LEFT OUTER JOIN  
   DetectorType MainsType ON Detector.DetectorTypeId = MainsType.DetectorTypeId AND  
     MainsType.IsMain = 1 AND  
     Detector.IsOptional = 0  
   GROUP BY PropertyInfo.PropertyInfoId
GO
/****** Object:  Table [dbo].[ServiceSheet]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ServiceSheet](
	[ServiceSheetId] [int] IDENTITY(1,1) NOT NULL,
	[BookingId] [int] NOT NULL,
	[TechnicianId] [int] NULL,
	[Date] [datetime] NULL,
	[Notes] [nvarchar](max) NULL,
	[ElectricalNotes] [nvarchar](max) NULL,
	[IsElectricianRequired] [bit] NOT NULL,
	[HasProblem] [bit] NOT NULL,
	[ProblemNotes] [nvarchar](max) NULL,
	[Discount] [money] NULL,
	[IsCompleted] [bit] NOT NULL,
	[IsCardLeft] [bit] NOT NULL,
	[HasSignature] [bit] NOT NULL,
	[IsElectrical] [bit] NOT NULL,
	[IsDeleted] [bit] NULL,
	[CreatedByUserId] [uniqueidentifier] NULL,
	[CreatedUtcDate] [datetime] NULL,
	[ModifiedByUserId] [uniqueidentifier] NULL,
	[ModifiedUtcDate] [datetime] NULL,
	[RowVersion] [timestamp] NULL,
 CONSTRAINT [PK_ServiceSheet] PRIMARY KEY CLUSTERED 
(
	[ServiceSheetId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[f_DetectorMainCount]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[f_DetectorMainCount]
(@PropertyInfoId int)
RETURNS int
AS
begin
	RETURN 
	(SELECT
		SUM(CAST(ISNULL(DetectorType.IsMain, 0) as int)) [DetectorMainCount]
	FROM
		PropertyInfo
	LEFT JOIN
		Detector
	ON
		PropertyInfo.PropertyInfoId = Detector.PropertyInfoId AND Detector.IsDeleted = 0
	LEFT JOIN
		DetectorType
	ON
		Detector.DetectorTypeId = DetectorType.DetectorTypeId
	AND
		DetectorType.IsMain = 1
	AND
		(YEAR(GETDATE()) + 1) >= Detector.ExpiryYear
	AND
		Detector.IsOptional = 0
		
	WHERE
		PropertyInfo.PropertyInfoId = @PropertyInfoId)
end
GO
/****** Object:  StoredProcedure [dbo].[p_Booking__UpdateKeynumberOnLastBooking]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[p_Booking__UpdateKeynumberOnLastBooking]
@keyNumber NVARCHAR (MAX), @propertyInfoID int = NULL
AS
set nocount on


update Booking
set KeyNumber = @keyNumber
where BookingId in (
SELECT TOP 1 [BookingId]
  FROM Booking
  where [PropertyInfoId] = @propertyInfoID
  order by [Date] desc
) 	
return 0
GO
/****** Object:  StoredProcedure [dbo].[p_Booking__AllocateTechnician]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[p_Booking__AllocateTechnician]
@selectedRows NVARCHAR (MAX), @technicianId int = NULL, @time datetime = NULL, @duration int = NULL, @userId uniqueidentifier
AS
set nocount on

UPDATE	
	Booking
SET
	TechnicianId = @technicianId,
	[Time] = COALESCE(@time, [Time]),
	Duration = COALESCE(@duration, Duration),
	ModifiedByUserId = @userId,
	ModifiedUtcDate = GETUTCDATE()
WHERE
	BookingId IN (SELECT value from dbo.f_IntSplit(@selectedRows, ','))
	
return 0
GO
/****** Object:  StoredProcedure [dbo].[p_PropertyInfo__HasProblemCount]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[p_PropertyInfo__HasProblemCount] 
	@AgencyId int = null,
	@PropertyManagerId int = null,
	@DateRangeStart datetime = null,
    @DateRangeEnd datetime = null,
    @Keyword nvarchar(50) = null,
    @HasProblem bit = null   
AS
BEGIN
	SET NOCOUNT ON;

    SELECT
		CAST([HasProblem] AS int) [StatusId],
		COUNT(PropertyInfoId) [Count],
		0 [New],
		0 [OverDue]
	FROM
		PropertyInfo
	WHERE
		PropertyInfo.IsCancelled = 0 AND PropertyInfo.IsDeleted = 0 AND PropertyInfo.HasProblem = 1
	AND
		(@AgencyId IS NULL OR AgencyId = @AgencyId)
	AND
		(@PropertyManagerId IS NULL OR PropertyManagerId = @PropertyManagerId)
	AND
     (@Keyword IS NULL OR dbo.f_PropertyInfo__ConcatenateAddress(PropertyInfo.PropertyInfoId) LIKE '%' + @Keyword + '%') AND              
     (@DateRangeStart IS NULL OR NextServiceDate >= @DateRangeStart) AND              
     (@DateRangeEnd IS NULL OR NextServiceDate <= @DateRangeEnd) AND              
     (@HasProblem IS NULL OR PropertyInfo.HasProblem = @HasProblem)  
	GROUP BY
		HasProblem
END
GO
/****** Object:  StoredProcedure [dbo].[p_PropertyInfo__ElectricalWorkStatusCount]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================    
-- Author:  <Author,,Name>    
-- Create date: <Create Date,,>    
-- Description: <Description,,>    
-- =============================================    
CREATE PROCEDURE [dbo].[p_PropertyInfo__ElectricalWorkStatusCount]     
 @AgencyId int = null,    
 @PropertyManagerId int = null,
 @DateRangeStart datetime = null,
 @DateRangeEnd datetime = null,
 @Keyword nvarchar(50) = null,
 @HasProblem bit = null      
AS    
BEGIN    
 SET NOCOUNT ON;    
  
WITH ElectricalStatuses AS  
(  
 SELECT 1 AS StatusId UNION  
 SELECT 2 AS StatusId  
)  
     
 SELECT DISTINCT    
  StatusId,    
  MAX([Count]) [Count],    
  MAX([New]) [New],    
  MAX([OverDue]) OverDue    
 FROM    
 (    
  SELECT    
   StatusId,  
   SUM(CASE WHEN StatusId = 2 AND   
     dbo.f_IsElectricianRequired(DetectorMainCount, TotalDetectorCount, [TotalMainCount], dbo.f_DynamicReadyForServiceStatus(InspectionStatusId, LastServicedDate, SettlementDate, CreatedUtcDate)) = 1   
  THEN 0  
  ELSE 1 END) AS [Count],  
   0 [New],    
   SUM(CASE WHEN dbo.f_IsElectricianRequired(DetectorMainCount, TotalDetectorCount, [TotalMainCount], dbo.f_DynamicReadyForServiceStatus(InspectionStatusId, LastServicedDate, SettlementDate, CreatedUtcDate)) = 1 AND IsElectricalStatus = 1 THEN 1 ELSE 0 END) [OverDue]    
  FROM    
  (SELECT    
   ElectricalWorkStatusId [StatusId],    
   CASE WHEN ElectricalWorkStatusId IN (SELECT StatusId FROM ElectricalStatuses) THEN 1 ELSE 0 END IsElectricalStatus,  
      InspectionStatusId,    
   PropertyInfo.PropertyInfoId [PropertyInfoId],    
   PropertyInfo.LastServicedDate,    
   PropertyInfo.SettlementDate,    
   PropertyInfo.CreatedUtcDate,    
   SUM(CAST(ISNULL(DetectorType.IsMain, 0) as int)) [DetectorMainCount],    
   SUM(CAST(ISNULL(MainsType.IsMain, 0) as int)) [TotalMainCount],    
   COUNT(*) [TotalDetectorCount]    
  FROM    
   PropertyInfo   
  LEFT JOIN    
   Detector    
  ON    
   PropertyInfo.PropertyInfoId = Detector.PropertyInfoId AND Detector.IsDeleted = 0    
  LEFT JOIN    
   DetectorType    
  ON    
   Detector.DetectorTypeId = DetectorType.DetectorTypeId AND DetectorType.IsMain = 1 AND (YEAR(GETDATE()) + 1) >= Detector.ExpiryYear 
   AND Detector.ExpiryYear > Year(GetDate()) LEFT OUTER JOIN  
   DetectorType MainsType  
   ON  
   Detector.DetectorTypeId = MainsType.DetectorTypeId AND DetectorType.IsMain = 1  
  WHERE
   PropertyInfo.IsCancelled = 0 AND PropertyInfo.IsDeleted = 0    
   AND    
    (@AgencyId IS NULL OR AgencyId = @AgencyId)    
   AND    
    (@PropertyManagerId IS NULL OR PropertyManagerId = @PropertyManagerId)    
	AND
	 (@Keyword IS NULL OR dbo.f_PropertyInfo__ConcatenateAddress(PropertyInfo.PropertyInfoId) LIKE '%' + @Keyword + '%') AND              
     (@DateRangeStart IS NULL OR NextServiceDate >= @DateRangeStart) AND              
     (@DateRangeEnd IS NULL OR NextServiceDate <= @DateRangeEnd) AND              
     (@HasProblem IS NULL OR PropertyInfo.HasProblem = @HasProblem)          
  GROUP BY    
   ElectricalWorkStatusId,    
   InspectionStatusId,    
   PropertyInfo.PropertyInfoId,    
   PropertyInfo.LastServicedDate,    
   PropertyInfo.SettlementDate,    
   PropertyInfo.CreatedUtcDate) [Results]   
  GROUP BY    
   StatusId    
  UNION    
  SELECT    
   ElectricalWorkStatusId [StatusId],    
   0 [Count],    
   0 [New],    
   0 [OverDue]    
  FROM    
   ElectricalWorkStatus    
 ) [StatusCount]    
 GROUP BY    
  StatusId    
    
END
GO
/****** Object:  StoredProcedure [dbo].[p_PropertyInfo__MobileNumber_Unfiltered]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[p_PropertyInfo__MobileNumber_Unfiltered]
	@bookingDate datetime
AS


SELECT 
	Agency.Name,
	CAST((CASE WHEN Booking.[Time] IS NULL THEN 0 ELSE 1 END) as bit) [HasBooking],
	dbo.f_PropertyInfo__ConcatenateMobileNumber(PropertyInfo.PropertyInfoId) [ContactNumber]
FROM Booking
INNER JOIN
	PropertyInfo
ON
	Booking.PropertyInfoId = PropertyInfo.PropertyInfoId
INNER JOIN
	Agency
ON
	PropertyInfo.AgencyId = Agency.AgencyId	
WHERE
	Booking.[Date] = @bookingDate and Booking.IsDeleted = 0 and PropertyInfo.IsDeleted = 0 and PropertyInfo.IsCancelled = 0

ORDER BY
	CASE WHEN Booking.[Time] IS NULL THEN 0 ELSE 1 END DESC,
	Agency.Name
GO
/****** Object:  StoredProcedure [dbo].[p_PropertyInfo__MobileNumber]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[p_PropertyInfo__MobileNumber]
	@bookingDate datetime
AS


SELECT 
	Agency.Name,
	CAST((CASE WHEN Booking.[Time] IS NULL THEN 0 ELSE 1 END) as bit) [HasBooking],
	dbo.f_PropertyInfo__ConcatenateMobileNumber(PropertyInfo.PropertyInfoId) [ContactNumber]
FROM Booking
INNER JOIN
	PropertyInfo
ON
	Booking.PropertyInfoId = PropertyInfo.PropertyInfoId
INNER JOIN
	Agency
ON
	PropertyInfo.AgencyId = Agency.AgencyId	
WHERE
	Booking.[Date] = @bookingDate and Booking.IsDeleted = 0 and PropertyInfo.IsDeleted = 0 and PropertyInfo.IsCancelled = 0 AND
	dbo.f_PropertyInfo__ConcatenateMobileNumber(PropertyInfo.PropertyInfoId) IS NOT NULL

ORDER BY
	CASE WHEN Booking.[Time] IS NULL THEN 0 ELSE 1 END DESC,
	Agency.Name
GO
/****** Object:  StoredProcedure [dbo].[p_PropertyInfo__ServiceByZone]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[p_PropertyInfo__ServiceByZone]
	@date datetime = NULL,
	@technicianId int = NULL
AS

BEGIN

IF @date IS NULL
BEGIN
	SET @date = CONVERT(date, GETDATE())
END

DECLARE @startDate datetime, @endDate datetime

SET @startDate = dbo.f_FirstOfMonth(@date)
SET @endDate = DATEADD(day, -1, DATEADD(month, 1,@startDate))
SELECT
	CAST(MONTH(Booking.[Date]) as varchar) + '/' + CAST(YEAR(Booking.[Date]) as varchar) [Series],
	Zone.Name [Label]
	,CAST(COUNT(Booking.BookingId) as numeric) [Value]
FROM
	Booking
INNER JOIN
	ServiceSheet
ON
	Booking.BookingId = ServiceSheet.BookingId AND ServiceSheet.IsCompleted = 1
INNER JOIN
	Zone
ON
	Booking.ZoneId = Zone.ZoneId	
AND
	Booking.Date BETWEEN @startDate AND @endDate
AND
	(Booking.TechnicianId = @technicianId OR @technicianId IS NULL)
GROUP BY
	Zone.Name
	,YEAR(Booking.[Date])
	,MONTH(Booking.[Date])
ORDER BY
	YEAR(Booking.[Date])
	,MONTH(Booking.[Date])


END
GO
/****** Object:  StoredProcedure [dbo].[p_PropertyInfo__Search]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[p_PropertyInfo__Search]              
@startRow bigint,                   
@pageSize bigint,                   
@sortBy NVARCHAR (100),                   
@sortDir NVARCHAR (4),                   
@SearchByInspectionStatus bit,              
@SearchByElectricalWorkStatus bit,              
@isComingUpForService bit,          
@dueForService bit,                   
@isNew bit,                   
@isOverDue bit,                   
@isElectricianRequired bit,                   
@isReadyForInvoice bit,                   
@agencyId int=null,                   
@propertyManagerId int = NULL,                   
@hasProblem bit = NULL,                   
@cancelled bit = NULL,                   
@keyword NVARCHAR (50)=null,                   
@dateStart DATETIME,                   
@dateEnd DATETIME,              
@inspectionStatuses NVARCHAR (MAX),                   
@electricalWorkStatuses NVARCHAR(MAX),  
@isQuickSearch bit = 0              
--@itemCount INT OUTPUT              
AS              
              
SET NOCOUNT ON            
        
DECLARE @IsNewStatusId INT          
DECLARE @IsOverdueStatusId INT          
DECLARE @IsComingUpForServiceStatusId INT          
DECLARE @ReadyForInvoiceStatusId INT    
        
SET @IsNewStatusId = (SELECT TOP 1 NewPropertyStatusId FROM v_DynamicReadyForServiceStatus)          
SET @IsOverdueStatusId = (SELECT TOP 1 OverdueStatusId FROM v_DynamicReadyForServiceStatus)          
SET @IsComingUpForServiceStatusId = (SELECT TOP 1 ComingUpForServiceStatusId FROM v_DynamicReadyForServiceStatus)           
SET @ReadyForInvoiceStatusId = (SELECT TOP 1 InspectionStatusId FROM InspectionStatus WHERE InspectionStatusId = 10) --Ready for invoice    
  
;        
        
WITH InspectionStatuses AS              
(              
 SELECT DISTINCT value AS StatusId from [dbo].[f_IntSplit](@inspectionStatuses, ',')              
),              
ElectricalWorkStatuses AS              
(              
 select value AS StatusId from [dbo].[f_IntSplit](@electricalWorkStatuses, ',')              
),              
ElectricalStatuses AS  
(  
SELECT 1 AS StatusId UNION  
SELECT 2 AS StatusId  
),  
AllowedElectricalStatuses AS  
(  
SELECT 1 AS StatusId UNION  
SELECT 4 AS StatusId  
),  
              
AllProperties AS              
(              
 SELECT    PropertyInfo.PropertyInfoId [Id],              
     PropertyInfo.PropertyNumber,              
     PropertyInfo.ContactNotes,              
     PropertyInfo.UnitShopNumber,              
     PropertyInfo.StreetNumber,              
     PropertyInfo.StreetName,              
     PropertyInfo.Suburb,              
     State.Name [State],              
     PropertyInfo.PostCode,              
     PropertyInfo.LastServicedDate [LastServicedDate],              
     PropertyInfo.NextServiceDate [NextServiceDate],              
     Booking.Date [BookingDate],              
     PropertyInfo.InspectionStatusId [InspectionStatusEnum],              
     InspectionStatus.Name [InspectionStatus],              
     PropertyInfo.ElectricalWorkStatusId [ElectricalWorkStatusEnum],              
     ElectricalWorkStatus.Name [ElectricalWorkStatus],              
     Agency.Name [Agency],              
     PropertyManager.Name [PropertyManager],              
     OccupantName [TenantName],              
     ConcatenatedTenantContactNumber [TenantContactNumber],              
     PropertyInfo.KeyNumber,              
     PropertyInfo.HasProblem,              
     PropertyInfo.HasLargeLadder,              
     PropertyInfo.IsCancelled,              
     PropertyInfo.HasSendNotification,              
     PropertyInfo.DynamicReadyForServiceStatusId,        
     PropertyInfoDetectorMainCount.DetectorMainCount,              
     dbo.f_IsElectricianRequired(PropertyInfoDetectorMainCount.DetectorMainCount, PropertyInfoDetectorMainCount.[TotalDetectorCount], PropertyInfoDetectorMainCount.TotalMainCount, PropertyInfo.DynamicReadyForServiceStatusId) [IsElectricianRequired],       -- 8000        
     dbo.f_IsCompletedOneOffService(PropertyInfo.IsOneOffService, PropertyInfo.IsServiceCompleted, @cancelled) [IsCompletedOneOffService],              
     CASE WHEN ReadyForServiceStatus.InspectionStatusId IS NULL THEN 0 ELSE 1 END [IsReadyForService],          
     PropertyInfo.RowVersion              
 FROM  v_PropertyInfos  PropertyInfo LEFT OUTER JOIN              
     State on PropertyInfo.StateId = State.StateId LEFT OUTER JOIN              
     Agency on PropertyInfo.AgencyId = Agency.AgencyId LEFT OUTER JOIN              
     PropertyManager on PropertyInfo.PropertyManagerId = PropertyManager.PropertyManagerId LEFT OUTER JOIN              
     InspectionStatus on PropertyInfo.InspectionStatusId = InspectionStatus.InspectionStatusId LEFT OUTER JOIN              
     ReadyForServiceStatus ON PropertyInfo.InspectionStatusId = ReadyForServiceStatus.InspectionStatusId LEFT OUTER JOIN          
     ElectricalWorkStatus on PropertyInfo.ElectricalWorkStatusId = ElectricalWorkStatus.ElectricalWorkStatusId LEFT OUTER JOIN              
     Booking on PropertyInfo.PropertyInfoId = Booking.PropertyInfoId and Booking.IsDeleted = 0 and Booking.IsInvoiced = 0 LEFT OUTER JOIN              
     ServiceSheet on Booking.BookingId = ServiceSheet.BookingId and ServiceSheet.IsCompleted = 0 and ServiceSheet.IsElectrical = 0 LEFT OUTER JOIN              
     PropertyInfoDetectorMainCount ON PropertyInfo.PropertyInfoId = PropertyInfoDetectorMainCount.PropertyInfoId              
   WHERE PropertyInfo.IsDeleted = 0 AND              
     (@agencyId IS NULL OR PropertyInfo.AgencyId = @agencyId) AND              
     (@propertyManagerId IS NULL OR PropertyInfo.PropertyManagerId = @propertyManagerId) AND              
     (@keyword IS NULL OR dbo.f_PropertyInfo__ConcatenateAddress(PropertyInfo.PropertyInfoId) LIKE '%' + @keyword + '%') AND              
     (@dateStart IS NULL OR NextServiceDate >= @dateStart) AND              
     (@dateEnd IS NULL OR NextServiceDate <= @dateEnd) AND              
     (@hasProblem IS NULL OR PropertyInfo.HasProblem = @hasProblem)               
),              
              
PagedProperties AS              
(                 
SELECT  ROW_NUMBER() OVER (ORDER BY CASE WHEN @SortBy = 'Id' AND @SortDir <> 'ASC' THEN Id END DESC,              
          CASE WHEN @SortBy = 'Id' THEN Id END,              
          CASE WHEN @SortBy = 'PropertyNumber' AND @SortDir <> 'ASC' THEN PropertyNumber END DESC,              
          CASE WHEN @SortBy = 'PropertyNumber' THEN PropertyNumber END,              
          CASE WHEN @SortBy = 'UnitShopNumber' AND @SortDir <> 'ASC' THEN UnitShopNumber END DESC,              
          CASE WHEN @SortBy = 'UnitShopNumber' THEN UnitShopNumber END,              
          CASE WHEN @SortBy = 'StreetNumber' AND @SortDir <> 'ASC' THEN StreetNumber END DESC,              
          CASE WHEN @SortBy = 'StreetNumber' THEN StreetNumber END,              
          CASE WHEN @SortBy = 'StreetName' AND @SortDir <> 'ASC' THEN StreetName END DESC,              
          CASE WHEN @SortBy = 'StreetName' THEN StreetName END,              
          CASE WHEN @SortBy = 'Suburb' AND @SortDir <> 'ASC' THEN Suburb END DESC,              
          CASE WHEN @SortBy = 'Suburb' THEN Suburb END,              
          CASE WHEN @SortBy = 'State.Name' AND @SortDir <> 'ASC' THEN [State] END DESC,              
          CASE WHEN @SortBy = 'State.Name' THEN [State] END,              
          CASE WHEN @SortBy = 'PostCode' AND @SortDir <> 'ASC' THEN PostCode END DESC,              
          CASE WHEN @SortBy = 'PostCode' THEN PostCode END,              
          CASE WHEN @SortBy = 'NextServiceDate' AND @SortDir <> 'ASC' THEN NextServiceDate END DESC,              
          CASE WHEN @SortBy = 'NextServiceDate' THEN NextServiceDate END,              
          CASE WHEN @SortBy = 'BookingDate' AND @SortDir <> 'ASC' THEN BookingDate END DESC,              
          CASE WHEN @SortBy = 'BookingDate' THEN BookingDate END,              
          CASE WHEN @SortBy = 'Agency.Name' AND @SortDir <> 'ASC' THEN Agency END DESC,              
          CASE WHEN @SortBy = 'Agency.Name' THEN Agency END,              
          CASE WHEN @SortBy = 'ContactNotes' AND @SortDir <> 'ASC' THEN ContactNotes END DESC,              
          CASE WHEN @SortBy = 'ContactNotes' THEN ContactNotes END,              
          CASE WHEN @SortBy = 'KeyNumber' AND @SortDir <> 'ASC' THEN KeyNumber END DESC,              
          CASE WHEN @SortBy = 'KeyNumber' THEN KeyNumber END,              
          CASE WHEN @SortBy = 'InspectionStatus.Name' AND @SortDir <> 'ASC' THEN InspectionStatus END DESC,              
          CASE WHEN @SortBy = 'InspectionStatus.Name' THEN InspectionStatus END,              
          CASE WHEN @SortBy = 'ElectricalWorkStatus.Name' AND @SortDir <> 'ASC' THEN ElectricalWorkStatus END DESC,              
          CASE WHEN @SortBy = 'ElectricalWorkStatus.Name' THEN ElectricalWorkStatus END) RowNumber,              
   AllProperties.*,            
   CAST(CASE WHEN AllProperties.DynamicReadyForServiceStatusId = 1 THEN 1 ELSE 0 END AS BIT) [IsComingUpForService],        
   CAST(CASE WHEN AllProperties.DynamicReadyForServiceStatusId = 2 THEN 1 ELSE 0 END AS BIT) [IsNew],        
   CAST(CASE WHEN AllProperties.DynamicReadyForServiceStatusId = 3 THEN 1 ELSE 0 END AS BIT) [IsOverDue],        
   COUNT(*) OVER () AS TotalRowCount            
FROM  AllProperties               
              
--inspection service              
WHERE (  @SearchByInspectionStatus = 1 AND AllProperties.[ElectricalWorkStatusEnum] IN (SELECT StatusId FROM AllowedElectricalStatuses) AND AllProperties.IsElectricianRequired = 0 AND              
            (          
               AllProperties.IsReadyForService = 1 AND (AllProperties.IsCancelled = 0 OR @isQuickSearch = 1) AND       
                   (    
                       (        
                          (@IsNew = 1 AND DynamicReadyForServiceStatusId = @IsNewStatusId) OR        
                          (@IsComingUpForService = 1 AND DynamicReadyForServiceStatusId = @IsComingUpForServiceStatusId)        
                       ) OR        
                       (        
                          @IsOverdue = 1 AND DynamicReadyForServiceStatusId = @IsOverdueStatusId    
                       )        
                   ) OR          
                   (    
                       InspectionStatusEnum IN (Select StatusId FROM InspectionStatuses) AND  (AllProperties.IsCancelled = 0 OR @isQuickSearch = 1 OR InspectionStatusEnum  = @ReadyForInvoiceStatusId)    
                   )    
             )     
      )    
       OR                        
      (      
          @SearchByElectricalWorkStatus = 1 AND (AllProperties.IsCancelled = 0 OR @isQuickSearch = 1) AND    
               (    
                    (@isElectricianRequired = 1 AND AllProperties.IsElectricianRequired = 1 AND ElectricalWorkStatusEnum IN (SELECT StatusId FROM ElectricalStatuses)) OR          
                    (ElectricalWorkStatusEnum IN (SELECT StatusId FROM ElectricalWorkStatuses) AND ElectricalWorkStatusEnum <> 2) OR  
                    ( (SELECT COUNT(*) FROM ElectricalWorkStatuses WHERE StatusId = 2) > 0 AND ElectricalWorkStatusEnum = 2 AND IsElectricianRequired = 0)  
               )  
                 
                 
      )    
       OR      
        (@SearchByInspectionStatus = 0 AND @SearchByElectricalWorkStatus = 0 AND (AllProperties.IsCancelled = 0 OR @isQuickSearch = 1))      
      )       
            
SELECT  *               
FROM PagedProperties                 
WHERE RowNumber BETWEEN @startRow AND @startRow + @pageSize

OPTION (RECOMPILE)
GO
/****** Object:  StoredProcedure [dbo].[p_PropertyInfo__Retrieve]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[p_PropertyInfo__Retrieve]    
 @selectedRows NVARCHAR(MAX)    
AS    
    
SELECT DISTINCT    
 PropertyInfo.PropertyNumber [Property Id]    
 ,PropertyInfo.ContactNotes    
 ,PropertyInfo.UnitShopNumber    
 ,PropertyInfo.StreetNumber    
 ,PropertyInfo.StreetName    
 ,PropertyInfo.Suburb    
 ,State.Name [State]    
 ,PropertyInfo.PostCode    
 ,PropertyInfo.LastServicedDate
 ,PropertyInfo.NextServiceDate
 ,Booking.Date [BookingDate]  
 ,PropertyInfo.InspectionStatusId [InspectionStatusEnum]    
 ,InspectionStatus.Name [InspectionStatus]    
 ,PropertyInfo.ElectricalWorkStatusId [ElectricalWorkStatusEnum]    
 ,ElectricalWorkStatus.Name [ElectricalWorkStatus]    
 ,Agency.Name [Agency]    
 ,PropertyManager.Name [PropertyManager]    
 ,OccupantName [TenantName]    
 ,ConcatenatedTenantContactNumber [TenantContactNumber]    
 ,PropertyInfo.KeyNumber    
 ,PropertyInfo.HasProblem    
 ,PropertyInfo.HasLargeLadder    
 ,PropertyInfo.IsCancelled    
 ,PropertyInfo.HasSendNotification    
 ,dbo.f_IsComingUpForService(PropertyInfo.InspectionStatusId, PropertyInfo.LastServicedDate, PropertyInfo.SettlementDate, PropertyInfo.CreatedUtcDate) IsComingUpForService   
 ,cast((case when PropertyInfo.LastServicedDate is null then 1 else 0 end) as bit) [IsNew]    
 ,cast((CASE WHEN NextServiceDate < GETDATE() THEN 1 ELSE 0 END) as bit) [IsOverDue]    
 ,cast(0 as bit) [IsElectricianRequired]    
 ,PropertyInfo.RowVersion    
 ,PropertyInfo.PropertyInfoId [Id]    
 ,PropertyInfo.PropertyNumber    
FROM PropertyInfo    
LEFT JOIN    
 State    
ON    
 PropertyInfo.StateId = State.StateId     
LEFT JOIN    
 Agency    
ON    
 PropertyInfo.AgencyId = Agency.AgencyId     
 left join PropertyManager on PropertyInfo.PropertyManagerId = PropertyManager.PropertyManagerId    
LEFT JOIN    
 ElectricalWorkStatus    
ON    
 PropertyInfo.ElectricalWorkStatusId = ElectricalWorkStatus.ElectricalWorkStatusId     
LEFT JOIN    
 InspectionStatus    
ON    
 PropertyInfo.InspectionStatusId = InspectionStatus.InspectionStatusId    
left outer join    
 Booking    
on    
 PropertyInfo.PropertyInfoId = Booking.PropertyInfoId and Booking.IsDeleted = 0  and Booking.IsInvoiced = 0    
left outer join    
 ServiceSheet    
on    
 Booking.BookingId = ServiceSheet.BookingId and ServiceSheet.IsCompleted = 0 and ServiceSheet.IsElectrical = 0    
WHERE    
PropertyInfo.PropertyInfoId in (select value from [dbo].[f_IntSplit](@selectedRows, ','))    
GROUP BY    
 PropertyInfo.PropertyInfoId    
 ,Booking.PropertyInfoId    
 ,PropertyInfo.PropertyNumber    
 ,PropertyInfo.ContactNotes    
 ,PropertyInfo.UnitShopNumber    
 ,PropertyInfo.StreetNumber    
 ,PropertyInfo.StreetName    
 ,PropertyInfo.Suburb    
 ,State.Name    
 ,PropertyInfo.PostCode    
 ,PropertyInfo.InspectionStatusId    
 ,PropertyInfo.ElectricalWorkStatusId    
 ,Agency.Name    
 ,PropertyManager.Name    
 ,PropertyInfo.LastServicedDate    
 ,PropertyInfo.NextServiceDate    
 ,Booking.Date    
 ,PropertyInfo.SettlementDate    
 ,PropertyInfo.CreatedUtcDate     
 ,InspectionStatus.Name    
 ,ElectricalWorkStatus.Name    
 ,PropertyInfo.KeyNumber    
 ,OccupantName    
 ,ConcatenatedTenantContactNumber    
 ,PropertyInfo.HasProblem    
 ,PropertyInfo.HasLargeLadder    
 ,PropertyInfo.IsCancelled    
 ,PropertyInfo.HasSendNotification    
 ,PropertyInfo.[RowVersion]
GO
/****** Object:  StoredProcedure [dbo].[p_PropertyInfo__InspectionStatusCount]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================          
-- Author:  <Author,,Name>          
-- Create date: <Create Date,,>          
-- Description: <Description,,>          
-- =============================================          
  
CREATE PROCEDURE [dbo].[p_PropertyInfo__InspectionStatusCount]           
@AgencyId int = null,          
@PropertyManagerId int = null,
@DateRangeStart datetime = null,
@DateRangeEnd datetime = null,
@Keyword nvarchar(50) = null,
@HasProblem bit = null      
AS          
BEGIN          
 SET NOCOUNT ON;          
 DECLARE @cancelled bit      
 DECLARE @IsNewStatusId INT      
 DECLARE @IsOverdueStatusId INT      
 DECLARE @IsComingUpForServiceStatusId INT      
 DECLARE @NoElectricianRequiredStatusId INT       
    
 SET @IsNewStatusId = (SELECT TOP 1 NewPropertyStatusId FROM v_DynamicReadyForServiceStatus)      
 SET @IsOverdueStatusId = (SELECT TOP 1 OverdueStatusId FROM v_DynamicReadyForServiceStatus)      
 SET @IsComingUpForServiceStatusId = (SELECT TOP 1 ComingUpForServiceStatusId FROM v_DynamicReadyForServiceStatus)           
 SET @NoElectricianRequiredStatusId = (SELECT TOP 1 ElectricalWorkStatusId FROM ElectricalWorkStatus WHERE ElectricalWorkStatusId = 1)
 SET @cancelled = 0          
 ;    
WITH AllowedElectricalStatuses AS
(
	SELECT 1 AS StatusId UNION
	SELECT 4 AS StatusId
),
PropertyInfoWithDynamicStatuses AS    
 (    
   SELECT  DISTINCT   PropertyInfo.InspectionStatusId [StatusId],          
    PropertyInfo.PropertyInfoId,          
    dbo.f_DynamicReadyForServiceStatus(PropertyInfo.InspectionStatusId, PropertyInfo.LastServicedDate, PropertyInfo.SettlementDate, PropertyInfo.CreatedUtcDate) DynamicReadyForServiceStatusId ,
    dbo.f_IsElectricianRequired(PropertyInfoDetectorMainCount.DetectorMainCount, PropertyInfoDetectorMainCount.[TotalDetectorCount], PropertyInfoDetectorMainCount.TotalMainCount, dbo.f_DynamicReadyForServiceStatus(PropertyInfo.InspectionStatusId, PropertyInfo.LastServicedDate, PropertyInfo.SettlementDate, PropertyInfo.CreatedUtcDate)) IsElectricianRequired
   FROM  PropertyInfo LEFT OUTER JOIN            
     PropertyInfoDetectorMainCount ON PropertyInfo.PropertyInfoId = PropertyInfoDetectorMainCount.PropertyInfoId        
   WHERE     (PropertyInfo.IsCancelled = 0 OR PropertyInfo.InspectionStatusId = 10) AND PropertyInfo.IsDeleted = 0 AND          
    (@AgencyId IS NULL OR AgencyId = @AgencyId) AND          
    (@PropertyManagerId IS NULL OR PropertyManagerId = @PropertyManagerId) AND
	 (@Keyword IS NULL OR dbo.f_PropertyInfo__ConcatenateAddress(PropertyInfo.PropertyInfoId) LIKE '%' + @Keyword + '%') AND              
     (@DateRangeStart IS NULL OR NextServiceDate >= @DateRangeStart) AND              
     (@DateRangeEnd IS NULL OR NextServiceDate <= @DateRangeEnd) AND              
     (@HasProblem IS NULL OR PropertyInfo.HasProblem = @HasProblem)     AND            
    (PropertyInfo.ElectricalWorkStatusId IN (SELECT StatusId FROM AllowedElectricalStatuses) AND
     dbo.f_IsElectricianRequired(PropertyInfoDetectorMainCount.DetectorMainCount, PropertyInfoDetectorMainCount.[TotalDetectorCount], PropertyInfoDetectorMainCount.TotalMainCount, dbo.f_DynamicReadyForServiceStatus(PropertyInfo.InspectionStatusId, PropertyInfo.LastServicedDate, PropertyInfo.SettlementDate, PropertyInfo.CreatedUtcDate)) = 0) 
    
 )    
          
 SELECT DISTINCT          
  StatusId,          
  MAX([Count]) [Count],          
  MAX([New]) [New],          
  MAX([OverDue]) OverDue,        
  MAX([ComingUpForService]) ComingUpForService            
 FROM          
 (          
  SELECT    [StatusId],          
   COUNT(PropertyInfoId) [Count],          
   SUM(CAST(CASE WHEN PropertyInfoWithDynamicStatuses.DynamicReadyForServiceStatusId = @IsNewStatusId THEN 1 ELSE 0 END AS INT)) AS [New],    
   SUM(CAST(CASE WHEN PropertyInfoWithDynamicStatuses.DynamicReadyForServiceStatusId = @IsOverdueStatusId THEN 1 ELSE 0 END AS INT)) AS [OverDue],    
   SUM(CAST(CASE WHEN PropertyInfoWithDynamicStatuses.DynamicReadyForServiceStatusId = @IsComingUpForServiceStatusId THEN 1 ELSE 0 END AS INT)) AS [ComingUpForService]    
  FROM      PropertyInfoWithDynamicStatuses       
  GROUP BY  [StatusId]    
  UNION          
  SELECT          
   InspectionStatusId [StatusId],          
   0 [Count],          
   0 [New],          
   0 [OverDue],        
   0 [ComingUpForService]            
  FROM          
   InspectionStatus          
 ) [StatusCount]          
 GROUP BY          
  StatusId          
            
           
END
GO
/****** Object:  StoredProcedure [dbo].[p_PropertyInfo__Agency]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[p_PropertyInfo__Agency]
	@agencyId int
AS

SELECT DISTINCT
	PropertyInfo.PropertyNumber [Property Id]
	,PropertyInfo.UnitShopNumber
	,PropertyInfo.StreetNumber
	,PropertyInfo.StreetName
	,PropertyInfo.Suburb
	,State.Name [State]
	,PropertyInfo.PostCode
	,CONVERT(VARCHAR(10), PropertyInfo.LastServicedDate, 103) [LastServicedDate]
	,CONVERT(VARCHAR(10), PropertyInfo.NextServiceDate, 103) [NextServiceDate]
	,CONVERT(VARCHAR(10), Booking.Date, 103) [BookingDate]
	,PropertyInfo.InspectionStatusId [InspectionStatusEnum]
	,InspectionStatus.Name [InspectionStatus]
	,PropertyInfo.ElectricalWorkStatusId [ElectricalWorkStatusEnum]
	,ElectricalWorkStatus.Name [ElectricalWorkStatus]
	,Agency.Name	[Agency]
	,PropertyManager.Name [PropertyManager]
	,OccupantName [TenantName]
	,ConcatenatedTenantContactNumber [TenantContactNumber]
	,PropertyInfo.ContactNotes
	,PropertyInfo.KeyNumber
	,PropertyInfo.HasProblem
	,PropertyInfo.HasLargeLadder
	,PropertyInfo.IsCancelled
	,PropertyInfo.HasSendNotification
	,cast((case when PropertyInfo.LastServicedDate is null then 1 else 0 end) as bit) [IsNew]
	,cast((CASE WHEN NextServiceDate < GETDATE() THEN 1 ELSE 0 END) as bit) [IsOverDue]
	,cast(0 as bit) [IsElectricianRequired]
	,PropertyInfo.RowVersion
FROM PropertyInfo
LEFT JOIN
	State
ON
	PropertyInfo.StateId = State.StateId	
LEFT JOIN
	Agency
ON
	PropertyInfo.AgencyId = Agency.AgencyId	
	left join PropertyManager on PropertyInfo.PropertyManagerId = PropertyManager.PropertyManagerId
LEFT JOIN
	ElectricalWorkStatus
ON
	PropertyInfo.ElectricalWorkStatusId = ElectricalWorkStatus.ElectricalWorkStatusId	
LEFT JOIN
	InspectionStatus
ON
	PropertyInfo.InspectionStatusId = InspectionStatus.InspectionStatusId
left outer join
	Booking
on
	PropertyInfo.PropertyInfoId = Booking.PropertyInfoId and Booking.IsDeleted = 0  and Booking.IsInvoiced = 0
left outer join
	ServiceSheet
on
	Booking.BookingId = ServiceSheet.BookingId and ServiceSheet.IsCompleted = 0 and ServiceSheet.IsElectrical = 0
WHERE
	PropertyInfo.AgencyId = @agencyId
AND
	PropertyInfo.IsDeleted = 0
GROUP BY
	PropertyInfo.PropertyInfoId
	,Booking.PropertyInfoId
	,PropertyInfo.PropertyNumber
	,PropertyInfo.ContactNotes
	,PropertyInfo.UnitShopNumber
	,PropertyInfo.StreetNumber
	,PropertyInfo.StreetName
	,PropertyInfo.Suburb
	,State.Name
	,PropertyInfo.PostCode
	,PropertyInfo.InspectionStatusId
	,PropertyInfo.ElectricalWorkStatusId
	,Agency.Name
	,PropertyManager.Name
	,PropertyInfo.LastServicedDate
	,PropertyInfo.NextServiceDate
	,Booking.Date
	,PropertyInfo.SettlementDate
	,PropertyInfo.CreatedUtcDate	
	,InspectionStatus.Name
	,ElectricalWorkStatus.Name
	,PropertyInfo.KeyNumber
	,OccupantName
	,ConcatenatedTenantContactNumber
	,PropertyInfo.HasProblem
	,PropertyInfo.HasLargeLadder
	,PropertyInfo.IsCancelled
	,PropertyInfo.HasSendNotification
	,PropertyInfo.[RowVersion]
ORDER BY
	PropertyInfo.PropertyNumber
GO
/****** Object:  Table [dbo].[ServiceSheetItem]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ServiceSheetItem](
	[ServiceSheetItemId] [int] IDENTITY(1,1) NOT NULL,
	[ServiceSheetId] [int] NOT NULL,
	[Location] [nvarchar](100) NOT NULL,
	[DetectorTypeId] [int] NOT NULL,
	[Manufacturer] [nvarchar](50) NOT NULL,
	[ExpiryYear] [int] NULL,
	[NewExpiryYear] [int] NULL,
	[IsBatteryReplaced] [bit] NOT NULL,
	[IsReplacedByElectrician] [bit] NOT NULL,
	[IsRepositioned] [bit] NOT NULL,
	[IsDecibelTested] [bit] NOT NULL,
	[IsCleaned] [bit] NOT NULL,
	[HasSticker] [bit] NOT NULL,
	[IsOptional] [bit] NOT NULL,
	[HasProblem] [bit] NOT NULL,
	[IsDeleted] [bit] NULL,
	[CreatedByUserId] [uniqueidentifier] NULL,
	[CreatedUtcDate] [datetime] NULL,
	[ModifiedByUserId] [uniqueidentifier] NULL,
	[ModifiedUtcDate] [datetime] NULL,
	[RowVersion] [timestamp] NULL,
 CONSTRAINT [PK_ServiceSheetItem] PRIMARY KEY CLUSTERED 
(
	[ServiceSheetItemId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[p_Technician__ServicesByZone]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[p_Technician__ServicesByZone]
	@date datetime = NULL
AS

BEGIN

IF @date IS NULL
BEGIN
	SET @date = CONVERT(date, GETDATE())
END

DECLARE @startDate datetime, @endDate datetime

SET @startDate = dbo.f_FirstOfMonth(@date)
SET @endDate = DATEADD(day, -1, DATEADD(month, 1,@startDate))
SELECT
	UserProfile.FirstName,
	UserProfile.LastName,
	SUM(CASE WHEN Booking.ZoneId = 1 THEN 1 ELSE 0 END) [Zone1],
	SUM(CASE WHEN Booking.ZoneId = 2 THEN 1 ELSE 0 END) [Zone2],
	SUM(CASE WHEN Booking.ZoneId = 3 THEN 1 ELSE 0 END) [Zone3]
FROM
	Booking
INNER JOIN
	ServiceSheet
ON
	Booking.BookingId = ServiceSheet.BookingId  AND ServiceSheet.IsCompleted = 1
INNER JOIN
	Zone
ON
	Booking.ZoneId = Zone.ZoneId	
INNER JOIN
	Technician
ON
	Booking.TechnicianId = Technician.TechnicianId
INNER JOIN
	UserProfile
ON
	Technician.TechnicianId = UserProfile.TechnicianId
AND
	Booking.Date BETWEEN @startDate AND @endDate
GROUP BY
	UserProfile.FirstName,
	UserProfile.Lastname
END
GO
/****** Object:  StoredProcedure [dbo].[PurgeData]    Script Date: 09/02/2013 13:37:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[PurgeData]
	@password nvarchar(50)
AS
BEGIN
	IF @password = 'kss@kss4'
	BEGIN
		delete from detector
		delete from servicesheetitem
		delete from servicesheet
		delete from booking
		delete from contactentry
		delete from propertybatchitem
		delete from propertybatch
		delete from propertyinfo
		delete from contactentry
	END
END
GO
/****** Object:  Default [DF__aspnet_Ap__Appli__6754599E]    Script Date: 09/02/2013 13:37:48 ******/
ALTER TABLE [dbo].[aspnet_Applications] ADD  DEFAULT (newid()) FOR [ApplicationId]
GO
/****** Object:  Default [DF_Notification_IsDeleted]    Script Date: 09/02/2013 13:37:49 ******/
ALTER TABLE [dbo].[Notification] ADD  CONSTRAINT [DF_Notification_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
/****** Object:  Default [DF_Notification_CreatedUtcDate]    Script Date: 09/02/2013 13:37:49 ******/
ALTER TABLE [dbo].[Notification] ADD  CONSTRAINT [DF_Notification_CreatedUtcDate]  DEFAULT (getutcdate()) FOR [CreatedUtcDate]
GO
/****** Object:  Default [DF__AspNet_Sq__notif__71D1E811]    Script Date: 09/02/2013 13:37:50 ******/
ALTER TABLE [dbo].[AspNet_SqlCacheTablesForChangeNotification] ADD  DEFAULT (getdate()) FOR [notificationCreated]
GO
/****** Object:  Default [DF__AspNet_Sq__chang__72C60C4A]    Script Date: 09/02/2013 13:37:50 ******/
ALTER TABLE [dbo].[AspNet_SqlCacheTablesForChangeNotification] ADD  DEFAULT ((0)) FOR [changeId]
GO
/****** Object:  Default [DF__ServiceIt__Quick__5C02A283]    Script Date: 09/02/2013 13:37:50 ******/
ALTER TABLE [dbo].[ServiceItem] ADD  DEFAULT ('') FOR [QuickBooksFreeAndFixedFeeDescription]
GO
/****** Object:  Default [DF__aspnet_Pa__PathI__6C190EBB]    Script Date: 09/02/2013 13:37:50 ******/
ALTER TABLE [dbo].[aspnet_Paths] ADD  DEFAULT (newid()) FOR [PathId]
GO
/****** Object:  Default [DF__Agency__ClientDa__5649C92D]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[Agency] ADD  DEFAULT ((1)) FOR [ClientDatabaseSystemId]
GO
/****** Object:  Default [DF__Agency__IsFixedF__5832119F]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[Agency] ADD  DEFAULT ((0)) FOR [IsFixedFeeService]
GO
/****** Object:  Default [DF__aspnet_Us__UserI__74AE54BC]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[aspnet_Users] ADD  DEFAULT (newid()) FOR [UserId]
GO
/****** Object:  Default [DF__aspnet_Us__Mobil__75A278F5]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[aspnet_Users] ADD  DEFAULT (NULL) FOR [MobileAlias]
GO
/****** Object:  Default [DF__aspnet_Us__IsAno__76969D2E]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[aspnet_Users] ADD  DEFAULT ((0)) FOR [IsAnonymous]
GO
/****** Object:  Default [DF__aspnet_Perso__Id__6FE99F9F]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[aspnet_PersonalizationPerUser] ADD  DEFAULT (newid()) FOR [Id]
GO
/****** Object:  Default [DF__aspnet_Me__Passw__6A30C649]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[aspnet_Membership] ADD  DEFAULT ((0)) FOR [PasswordFormat]
GO
/****** Object:  Default [DF_UserProfile_CreatedUtcDate]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[UserProfile] ADD  CONSTRAINT [DF_UserProfile_CreatedUtcDate]  DEFAULT (getutcdate()) FOR [CreatedUtcDate]
GO
/****** Object:  Default [DF_UserProfile_ModifiedUtcDate]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[UserProfile] ADD  CONSTRAINT [DF_UserProfile_ModifiedUtcDate]  DEFAULT (getutcdate()) FOR [ModifiedUtcDate]
GO
/****** Object:  Default [DF__PropertyM__IsFix__592635D8]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[PropertyManager] ADD  DEFAULT ((0)) FOR [IsFixedFeeService]
GO
/****** Object:  Default [DF__PropertyI__IsFix__5A1A5A11]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[PropertyInfo] ADD  DEFAULT ((0)) FOR [IsFixedFeeService]
GO
/****** Object:  Default [DF__PropertyI__IsFre__5B0E7E4A]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[PropertyInfo] ADD  DEFAULT ((0)) FOR [IsFreeService]
GO
/****** Object:  Default [DF_Role_IsDeleted]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[Role] ADD  CONSTRAINT [DF_Role_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
/****** Object:  Default [DF_Role_ModifiedUtcDate]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[Role] ADD  CONSTRAINT [DF_Role_ModifiedUtcDate]  DEFAULT (getutcdate()) FOR [ModifiedUtcDate]
GO
/****** Object:  Default [DF_Suburb_IsDeleted]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[Suburb] ADD  CONSTRAINT [DF_Suburb_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
/****** Object:  Default [DF_Suburb_CreatedUtcDate]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[Suburb] ADD  CONSTRAINT [DF_Suburb_CreatedUtcDate]  DEFAULT (getutcdate()) FOR [CreatedUtcDate]
GO
/****** Object:  Default [DF_Suburb_ModifiedUtcDate]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[Suburb] ADD  CONSTRAINT [DF_Suburb_ModifiedUtcDate]  DEFAULT (getutcdate()) FOR [ModifiedUtcDate]
GO
/****** Object:  Default [DF_Help_IsDeleted]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[Help] ADD  CONSTRAINT [DF_Help_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
/****** Object:  Default [DF_Help_CreatedUtcDate]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[Help] ADD  CONSTRAINT [DF_Help_CreatedUtcDate]  DEFAULT (getutcdate()) FOR [CreatedUtcDate]
GO
/****** Object:  Default [DF_Help_ModifiedUtcDate]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[Help] ADD  CONSTRAINT [DF_Help_ModifiedUtcDate]  DEFAULT (getutcdate()) FOR [ModifiedUtcDate]
GO
/****** Object:  Default [DF_ServiceSheetItem_HasProblem]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[ServiceSheetItem] ADD  CONSTRAINT [DF_ServiceSheetItem_HasProblem]  DEFAULT ((0)) FOR [HasProblem]
GO
/****** Object:  Check [ClientDatabaseSystemId]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[Agency]  WITH NOCHECK ADD  CONSTRAINT [ClientDatabaseSystemId] CHECK  (([ClientDatabaseSystemId] IS NOT NULL))
GO
ALTER TABLE [dbo].[Agency] CHECK CONSTRAINT [ClientDatabaseSystemId]
GO
/****** Object:  ForeignKey [FK_TechnicianAvailability_Technician]    Script Date: 09/02/2013 13:37:50 ******/
ALTER TABLE [dbo].[TechnicianAvailability]  WITH CHECK ADD  CONSTRAINT [FK_TechnicianAvailability_Technician] FOREIGN KEY([TechnicianId])
REFERENCES [dbo].[Technician] ([TechnicianId])
GO
ALTER TABLE [dbo].[TechnicianAvailability] CHECK CONSTRAINT [FK_TechnicianAvailability_Technician]
GO
/****** Object:  ForeignKey [FK_Permission_ApplicationArea]    Script Date: 09/02/2013 13:37:50 ******/
ALTER TABLE [dbo].[Permission]  WITH CHECK ADD  CONSTRAINT [FK_Permission_ApplicationArea] FOREIGN KEY([ApplicationAreaId])
REFERENCES [dbo].[ApplicationArea] ([ApplicationAreaId])
GO
ALTER TABLE [dbo].[Permission] CHECK CONSTRAINT [FK_Permission_ApplicationArea]
GO
/****** Object:  ForeignKey [FK_AuditAction_Audit]    Script Date: 09/02/2013 13:37:50 ******/
ALTER TABLE [dbo].[AuditAction]  WITH CHECK ADD  CONSTRAINT [FK_AuditAction_Audit] FOREIGN KEY([AuditId])
REFERENCES [dbo].[Audit] ([AuditId])
GO
ALTER TABLE [dbo].[AuditAction] CHECK CONSTRAINT [FK_AuditAction_Audit]
GO
/****** Object:  ForeignKey [FK_AuditAction_AuditActionType]    Script Date: 09/02/2013 13:37:50 ******/
ALTER TABLE [dbo].[AuditAction]  WITH CHECK ADD  CONSTRAINT [FK_AuditAction_AuditActionType] FOREIGN KEY([AuditActionTypeId])
REFERENCES [dbo].[AuditActionType] ([AuditActionTypeId])
GO
ALTER TABLE [dbo].[AuditAction] CHECK CONSTRAINT [FK_AuditAction_AuditActionType]
GO
/****** Object:  ForeignKey [FK_ContactEntry_ContactNumberType]    Script Date: 09/02/2013 13:37:50 ******/
ALTER TABLE [dbo].[ContactEntry]  WITH CHECK ADD  CONSTRAINT [FK_ContactEntry_ContactNumberType] FOREIGN KEY([ContactNumberTypeId])
REFERENCES [dbo].[ContactNumberType] ([ContactNumberTypeId])
GO
ALTER TABLE [dbo].[ContactEntry] CHECK CONSTRAINT [FK_ContactEntry_ContactNumberType]
GO
/****** Object:  ForeignKey [FK__aspnet_Pa__Appli__2BFE89A6]    Script Date: 09/02/2013 13:37:50 ******/
ALTER TABLE [dbo].[aspnet_Paths]  WITH CHECK ADD FOREIGN KEY([ApplicationId])
REFERENCES [dbo].[aspnet_Applications] ([ApplicationId])
GO
/****** Object:  ForeignKey [FK__aspnet_Pa__Appli__6B24EA82]    Script Date: 09/02/2013 13:37:50 ******/
ALTER TABLE [dbo].[aspnet_Paths]  WITH CHECK ADD FOREIGN KEY([ApplicationId])
REFERENCES [dbo].[aspnet_Applications] ([ApplicationId])
GO
/****** Object:  ForeignKey [FK_Agency_AgencyGroup]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[Agency]  WITH CHECK ADD  CONSTRAINT [FK_Agency_AgencyGroup] FOREIGN KEY([AgencyGroupId])
REFERENCES [dbo].[AgencyGroup] ([AgencyGroupId])
GO
ALTER TABLE [dbo].[Agency] CHECK CONSTRAINT [FK_Agency_AgencyGroup]
GO
/****** Object:  ForeignKey [FK__aspnet_Us__Appli__30C33EC3]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[aspnet_Users]  WITH CHECK ADD FOREIGN KEY([ApplicationId])
REFERENCES [dbo].[aspnet_Applications] ([ApplicationId])
GO
/****** Object:  ForeignKey [FK__aspnet_Us__Appli__73BA3083]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[aspnet_Users]  WITH CHECK ADD FOREIGN KEY([ApplicationId])
REFERENCES [dbo].[aspnet_Applications] ([ApplicationId])
GO
/****** Object:  ForeignKey [FK__aspnet_Pr__UserI__2FCF1A8A]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[aspnet_Profile]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[aspnet_Users] ([UserId])
GO
/****** Object:  ForeignKey [FK__aspnet_Pr__UserI__70DDC3D8]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[aspnet_Profile]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[aspnet_Users] ([UserId])
GO
/****** Object:  ForeignKey [FK__aspnet_Pe__PathI__2CF2ADDF]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[aspnet_PersonalizationAllUsers]  WITH CHECK ADD FOREIGN KEY([PathId])
REFERENCES [dbo].[aspnet_Paths] ([PathId])
GO
/****** Object:  ForeignKey [FK__aspnet_Pe__PathI__6D0D32F4]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[aspnet_PersonalizationAllUsers]  WITH CHECK ADD FOREIGN KEY([PathId])
REFERENCES [dbo].[aspnet_Paths] ([PathId])
GO
/****** Object:  ForeignKey [FK__aspnet_Pe__PathI__2DE6D218]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[aspnet_PersonalizationPerUser]  WITH CHECK ADD FOREIGN KEY([PathId])
REFERENCES [dbo].[aspnet_Paths] ([PathId])
GO
/****** Object:  ForeignKey [FK__aspnet_Pe__PathI__6E01572D]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[aspnet_PersonalizationPerUser]  WITH CHECK ADD FOREIGN KEY([PathId])
REFERENCES [dbo].[aspnet_Paths] ([PathId])
GO
/****** Object:  ForeignKey [FK__aspnet_Pe__UserI__2EDAF651]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[aspnet_PersonalizationPerUser]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[aspnet_Users] ([UserId])
GO
/****** Object:  ForeignKey [FK__aspnet_Pe__UserI__6EF57B66]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[aspnet_PersonalizationPerUser]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[aspnet_Users] ([UserId])
GO
/****** Object:  ForeignKey [FK__aspnet_Me__Appli__2A164134]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[aspnet_Membership]  WITH CHECK ADD FOREIGN KEY([ApplicationId])
REFERENCES [dbo].[aspnet_Applications] ([ApplicationId])
GO
/****** Object:  ForeignKey [FK__aspnet_Me__Appli__68487DD7]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[aspnet_Membership]  WITH CHECK ADD FOREIGN KEY([ApplicationId])
REFERENCES [dbo].[aspnet_Applications] ([ApplicationId])
GO
/****** Object:  ForeignKey [FK__aspnet_Me__UserI__2B0A656D]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[aspnet_Membership]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[aspnet_Users] ([UserId])
GO
/****** Object:  ForeignKey [FK__aspnet_Me__UserI__693CA210]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[aspnet_Membership]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[aspnet_Users] ([UserId])
GO
/****** Object:  ForeignKey [FK_UserProfile_aspnet_Users]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[UserProfile]  WITH CHECK ADD  CONSTRAINT [FK_UserProfile_aspnet_Users] FOREIGN KEY([UserId])
REFERENCES [dbo].[aspnet_Users] ([UserId])
GO
ALTER TABLE [dbo].[UserProfile] CHECK CONSTRAINT [FK_UserProfile_aspnet_Users]
GO
/****** Object:  ForeignKey [FK_UserProfile_UserProfile]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[UserProfile]  WITH CHECK ADD  CONSTRAINT [FK_UserProfile_UserProfile] FOREIGN KEY([CreatedByUserId])
REFERENCES [dbo].[UserProfile] ([UserId])
GO
ALTER TABLE [dbo].[UserProfile] CHECK CONSTRAINT [FK_UserProfile_UserProfile]
GO
/****** Object:  ForeignKey [FK_UserProfile_UserProfile1]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[UserProfile]  WITH CHECK ADD  CONSTRAINT [FK_UserProfile_UserProfile1] FOREIGN KEY([ModifiedByUserId])
REFERENCES [dbo].[UserProfile] ([UserId])
GO
ALTER TABLE [dbo].[UserProfile] CHECK CONSTRAINT [FK_UserProfile_UserProfile1]
GO
/****** Object:  ForeignKey [FK_PropertyManager_Agency]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[PropertyManager]  WITH CHECK ADD  CONSTRAINT [FK_PropertyManager_Agency] FOREIGN KEY([AgencyId])
REFERENCES [dbo].[Agency] ([AgencyId])
GO
ALTER TABLE [dbo].[PropertyManager] CHECK CONSTRAINT [FK_PropertyManager_Agency]
GO
/****** Object:  ForeignKey [FK_PropertyInfo_Agency]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[PropertyInfo]  WITH CHECK ADD  CONSTRAINT [FK_PropertyInfo_Agency] FOREIGN KEY([AgencyId])
REFERENCES [dbo].[Agency] ([AgencyId])
GO
ALTER TABLE [dbo].[PropertyInfo] CHECK CONSTRAINT [FK_PropertyInfo_Agency]
GO
/****** Object:  ForeignKey [FK_PropertyInfo_ElectricalWorkStatus]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[PropertyInfo]  WITH CHECK ADD  CONSTRAINT [FK_PropertyInfo_ElectricalWorkStatus] FOREIGN KEY([ElectricalWorkStatusId])
REFERENCES [dbo].[ElectricalWorkStatus] ([ElectricalWorkStatusId])
GO
ALTER TABLE [dbo].[PropertyInfo] CHECK CONSTRAINT [FK_PropertyInfo_ElectricalWorkStatus]
GO
/****** Object:  ForeignKey [FK_PropertyInfo_InspectionStatus]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[PropertyInfo]  WITH CHECK ADD  CONSTRAINT [FK_PropertyInfo_InspectionStatus] FOREIGN KEY([InspectionStatusId])
REFERENCES [dbo].[InspectionStatus] ([InspectionStatusId])
GO
ALTER TABLE [dbo].[PropertyInfo] CHECK CONSTRAINT [FK_PropertyInfo_InspectionStatus]
GO
/****** Object:  ForeignKey [FK_PropertyInfo_PropertyManager]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[PropertyInfo]  WITH CHECK ADD  CONSTRAINT [FK_PropertyInfo_PropertyManager] FOREIGN KEY([PropertyManagerId])
REFERENCES [dbo].[PropertyManager] ([PropertyManagerId])
GO
ALTER TABLE [dbo].[PropertyInfo] CHECK CONSTRAINT [FK_PropertyInfo_PropertyManager]
GO
/****** Object:  ForeignKey [FK_PropertyInfo_Zone]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[PropertyInfo]  WITH CHECK ADD  CONSTRAINT [FK_PropertyInfo_Zone] FOREIGN KEY([ZoneId])
REFERENCES [dbo].[Zone] ([ZoneId])
GO
ALTER TABLE [dbo].[PropertyInfo] CHECK CONSTRAINT [FK_PropertyInfo_Zone]
GO
/****** Object:  ForeignKey [FK_Role_UserProfile]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[Role]  WITH CHECK ADD  CONSTRAINT [FK_Role_UserProfile] FOREIGN KEY([CreatedByUserId])
REFERENCES [dbo].[UserProfile] ([UserId])
GO
ALTER TABLE [dbo].[Role] CHECK CONSTRAINT [FK_Role_UserProfile]
GO
/****** Object:  ForeignKey [FK_Role_UserProfile1]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[Role]  WITH CHECK ADD  CONSTRAINT [FK_Role_UserProfile1] FOREIGN KEY([ModifiedByUserId])
REFERENCES [dbo].[UserProfile] ([UserId])
GO
ALTER TABLE [dbo].[Role] CHECK CONSTRAINT [FK_Role_UserProfile1]
GO
/****** Object:  ForeignKey [FK_Upload_UserProfile]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[Upload]  WITH CHECK ADD  CONSTRAINT [FK_Upload_UserProfile] FOREIGN KEY([CreatedByUserId])
REFERENCES [dbo].[UserProfile] ([UserId])
GO
ALTER TABLE [dbo].[Upload] CHECK CONSTRAINT [FK_Upload_UserProfile]
GO
/****** Object:  ForeignKey [FK_Upload_UserProfile1]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[Upload]  WITH CHECK ADD  CONSTRAINT [FK_Upload_UserProfile1] FOREIGN KEY([ModifiedByUserId])
REFERENCES [dbo].[UserProfile] ([UserId])
GO
ALTER TABLE [dbo].[Upload] CHECK CONSTRAINT [FK_Upload_UserProfile1]
GO
/****** Object:  ForeignKey [FK_Suburb_State]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[Suburb]  WITH CHECK ADD  CONSTRAINT [FK_Suburb_State] FOREIGN KEY([StateId])
REFERENCES [dbo].[State] ([StateId])
GO
ALTER TABLE [dbo].[Suburb] CHECK CONSTRAINT [FK_Suburb_State]
GO
/****** Object:  ForeignKey [FK_Suburb_UserProfile]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[Suburb]  WITH CHECK ADD  CONSTRAINT [FK_Suburb_UserProfile] FOREIGN KEY([CreatedByUserId])
REFERENCES [dbo].[UserProfile] ([UserId])
GO
ALTER TABLE [dbo].[Suburb] CHECK CONSTRAINT [FK_Suburb_UserProfile]
GO
/****** Object:  ForeignKey [FK_Suburb_UserProfile1]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[Suburb]  WITH CHECK ADD  CONSTRAINT [FK_Suburb_UserProfile1] FOREIGN KEY([ModifiedByUserId])
REFERENCES [dbo].[UserProfile] ([UserId])
GO
ALTER TABLE [dbo].[Suburb] CHECK CONSTRAINT [FK_Suburb_UserProfile1]
GO
/****** Object:  ForeignKey [FK_Help_ApplicationArea]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[Help]  WITH CHECK ADD  CONSTRAINT [FK_Help_ApplicationArea] FOREIGN KEY([ApplicationAreaId])
REFERENCES [dbo].[ApplicationArea] ([ApplicationAreaId])
GO
ALTER TABLE [dbo].[Help] CHECK CONSTRAINT [FK_Help_ApplicationArea]
GO
/****** Object:  ForeignKey [FK_Help_UserProfile]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[Help]  WITH CHECK ADD  CONSTRAINT [FK_Help_UserProfile] FOREIGN KEY([CreatedByUserId])
REFERENCES [dbo].[UserProfile] ([UserId])
GO
ALTER TABLE [dbo].[Help] CHECK CONSTRAINT [FK_Help_UserProfile]
GO
/****** Object:  ForeignKey [FK_Help_UserProfile1]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[Help]  WITH CHECK ADD  CONSTRAINT [FK_Help_UserProfile1] FOREIGN KEY([ModifiedByUserId])
REFERENCES [dbo].[UserProfile] ([UserId])
GO
ALTER TABLE [dbo].[Help] CHECK CONSTRAINT [FK_Help_UserProfile1]
GO
/****** Object:  ForeignKey [FK_Booking_PropertyInfo]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[Booking]  WITH CHECK ADD  CONSTRAINT [FK_Booking_PropertyInfo] FOREIGN KEY([PropertyInfoId])
REFERENCES [dbo].[PropertyInfo] ([PropertyInfoId])
GO
ALTER TABLE [dbo].[Booking] CHECK CONSTRAINT [FK_Booking_PropertyInfo]
GO
/****** Object:  ForeignKey [FK_Detector_DetectorType]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[Detector]  WITH CHECK ADD  CONSTRAINT [FK_Detector_DetectorType] FOREIGN KEY([DetectorTypeId])
REFERENCES [dbo].[DetectorType] ([DetectorTypeId])
GO
ALTER TABLE [dbo].[Detector] CHECK CONSTRAINT [FK_Detector_DetectorType]
GO
/****** Object:  ForeignKey [FK_Detector_PropertyInfo]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[Detector]  WITH CHECK ADD  CONSTRAINT [FK_Detector_PropertyInfo] FOREIGN KEY([PropertyInfoId])
REFERENCES [dbo].[PropertyInfo] ([PropertyInfoId])
GO
ALTER TABLE [dbo].[Detector] CHECK CONSTRAINT [FK_Detector_PropertyInfo]
GO
/****** Object:  ForeignKey [FK_RolePermission_Permission]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[RolePermission]  WITH CHECK ADD  CONSTRAINT [FK_RolePermission_Permission] FOREIGN KEY([PermissionId])
REFERENCES [dbo].[Permission] ([PermissionId])
GO
ALTER TABLE [dbo].[RolePermission] CHECK CONSTRAINT [FK_RolePermission_Permission]
GO
/****** Object:  ForeignKey [FK_RolePermission_Role]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[RolePermission]  WITH CHECK ADD  CONSTRAINT [FK_RolePermission_Role] FOREIGN KEY([RoleId])
REFERENCES [dbo].[Role] ([RoleId])
GO
ALTER TABLE [dbo].[RolePermission] CHECK CONSTRAINT [FK_RolePermission_Role]
GO
/****** Object:  ForeignKey [FK__aspnet_Us__UserI__04E4BC85]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[UserRole]  WITH CHECK ADD  CONSTRAINT [FK__aspnet_Us__UserI__04E4BC85] FOREIGN KEY([UserId])
REFERENCES [dbo].[aspnet_Users] ([UserId])
GO
ALTER TABLE [dbo].[UserRole] CHECK CONSTRAINT [FK__aspnet_Us__UserI__04E4BC85]
GO
/****** Object:  ForeignKey [FK_UserRole_Role]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[UserRole]  WITH CHECK ADD  CONSTRAINT [FK_UserRole_Role] FOREIGN KEY([RoleId])
REFERENCES [dbo].[Role] ([RoleId])
GO
ALTER TABLE [dbo].[UserRole] CHECK CONSTRAINT [FK_UserRole_Role]
GO
/****** Object:  ForeignKey [FK_PropertyBatchItem_PropertyBatch]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[PropertyBatchItem]  WITH CHECK ADD  CONSTRAINT [FK_PropertyBatchItem_PropertyBatch] FOREIGN KEY([PropertyBatchId])
REFERENCES [dbo].[PropertyBatch] ([PropertyBatchId])
GO
ALTER TABLE [dbo].[PropertyBatchItem] CHECK CONSTRAINT [FK_PropertyBatchItem_PropertyBatch]
GO
/****** Object:  ForeignKey [FK_PropertyBatchItem_PropertyInfo]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[PropertyBatchItem]  WITH CHECK ADD  CONSTRAINT [FK_PropertyBatchItem_PropertyInfo] FOREIGN KEY([PropertyInfoId])
REFERENCES [dbo].[PropertyInfo] ([PropertyInfoId])
GO
ALTER TABLE [dbo].[PropertyBatchItem] CHECK CONSTRAINT [FK_PropertyBatchItem_PropertyInfo]
GO
/****** Object:  ForeignKey [FK_ServiceSheet_Booking]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[ServiceSheet]  WITH CHECK ADD  CONSTRAINT [FK_ServiceSheet_Booking] FOREIGN KEY([BookingId])
REFERENCES [dbo].[Booking] ([BookingId])
GO
ALTER TABLE [dbo].[ServiceSheet] CHECK CONSTRAINT [FK_ServiceSheet_Booking]
GO
/****** Object:  ForeignKey [FK_ServiceSheet_Technician]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[ServiceSheet]  WITH CHECK ADD  CONSTRAINT [FK_ServiceSheet_Technician] FOREIGN KEY([TechnicianId])
REFERENCES [dbo].[Technician] ([TechnicianId])
GO
ALTER TABLE [dbo].[ServiceSheet] CHECK CONSTRAINT [FK_ServiceSheet_Technician]
GO
/****** Object:  ForeignKey [FK_ServiceSheetItem_ServiceSheet]    Script Date: 09/02/2013 13:37:51 ******/
ALTER TABLE [dbo].[ServiceSheetItem]  WITH CHECK ADD  CONSTRAINT [FK_ServiceSheetItem_ServiceSheet] FOREIGN KEY([ServiceSheetId])
REFERENCES [dbo].[ServiceSheet] ([ServiceSheetId])
GO
ALTER TABLE [dbo].[ServiceSheetItem] CHECK CONSTRAINT [FK_ServiceSheetItem_ServiceSheet]
GO
