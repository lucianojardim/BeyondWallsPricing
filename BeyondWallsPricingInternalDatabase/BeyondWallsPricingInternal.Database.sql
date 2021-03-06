USE [master]
GO
/****** Object:  Database [BeyondWallsPricingInternal]    Script Date: 2/22/2017 1:41:03 PM ******/
CREATE DATABASE [BeyondWallsPricingInternal]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'BeyondWallsPricing', FILENAME = N'F:\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\BeyondWallsPricingInternal.mdf' , SIZE = 16384KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'BeyondWallsPricing_log', FILENAME = N'G:\MSSQL10_50.MSSQLSERVER\MSSQL\Log\BeyondWallsPricingInternal_1.ldf' , SIZE = 16384KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [BeyondWallsPricingInternal] SET COMPATIBILITY_LEVEL = 120
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [BeyondWallsPricingInternal].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [BeyondWallsPricingInternal] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [BeyondWallsPricingInternal] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [BeyondWallsPricingInternal] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [BeyondWallsPricingInternal] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [BeyondWallsPricingInternal] SET ARITHABORT OFF 
GO
ALTER DATABASE [BeyondWallsPricingInternal] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [BeyondWallsPricingInternal] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [BeyondWallsPricingInternal] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [BeyondWallsPricingInternal] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [BeyondWallsPricingInternal] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [BeyondWallsPricingInternal] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [BeyondWallsPricingInternal] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [BeyondWallsPricingInternal] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [BeyondWallsPricingInternal] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [BeyondWallsPricingInternal] SET  DISABLE_BROKER 
GO
ALTER DATABASE [BeyondWallsPricingInternal] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [BeyondWallsPricingInternal] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [BeyondWallsPricingInternal] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [BeyondWallsPricingInternal] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [BeyondWallsPricingInternal] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [BeyondWallsPricingInternal] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [BeyondWallsPricingInternal] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [BeyondWallsPricingInternal] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [BeyondWallsPricingInternal] SET  MULTI_USER 
GO
ALTER DATABASE [BeyondWallsPricingInternal] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [BeyondWallsPricingInternal] SET DB_CHAINING OFF 
GO
ALTER DATABASE [BeyondWallsPricingInternal] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [BeyondWallsPricingInternal] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
ALTER DATABASE [BeyondWallsPricingInternal] SET DELAYED_DURABILITY = DISABLED 
GO
EXEC sys.sp_db_vardecimal_storage_format N'BeyondWallsPricingInternal', N'ON'
GO
USE [BeyondWallsPricingInternal]
GO
GRANT CONNECT TO [BeyondWallsAdmin] AS [dbo]
GO
GRANT CONNECT TO [BeyondWallsUsr] AS [dbo]
GO
USE [master]
GO
ALTER DATABASE [BeyondWallsPricingInternal] SET  READ_WRITE 
GO
