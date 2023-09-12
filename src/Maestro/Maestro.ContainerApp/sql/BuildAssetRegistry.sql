USE [master]
GO
/****** Object:  Database [BuildAssetRegistry]    Script Date: 12-Sep-23 2:08:14 PM ******/
CREATE DATABASE [BuildAssetRegistry]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'BuildAssetRegistry', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\BuildAssetRegistry.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'BuildAssetRegistry_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\BuildAssetRegistry_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [BuildAssetRegistry] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [BuildAssetRegistry].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [BuildAssetRegistry] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [BuildAssetRegistry] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [BuildAssetRegistry] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [BuildAssetRegistry] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [BuildAssetRegistry] SET ARITHABORT OFF 
GO
ALTER DATABASE [BuildAssetRegistry] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [BuildAssetRegistry] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [BuildAssetRegistry] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [BuildAssetRegistry] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [BuildAssetRegistry] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [BuildAssetRegistry] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [BuildAssetRegistry] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [BuildAssetRegistry] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [BuildAssetRegistry] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [BuildAssetRegistry] SET  ENABLE_BROKER 
GO
ALTER DATABASE [BuildAssetRegistry] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [BuildAssetRegistry] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [BuildAssetRegistry] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [BuildAssetRegistry] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [BuildAssetRegistry] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [BuildAssetRegistry] SET READ_COMMITTED_SNAPSHOT ON 
GO
ALTER DATABASE [BuildAssetRegistry] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [BuildAssetRegistry] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [BuildAssetRegistry] SET  MULTI_USER 
GO
ALTER DATABASE [BuildAssetRegistry] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [BuildAssetRegistry] SET DB_CHAINING OFF 
GO
ALTER DATABASE [BuildAssetRegistry] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [BuildAssetRegistry] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [BuildAssetRegistry] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [BuildAssetRegistry] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
ALTER DATABASE [BuildAssetRegistry] SET QUERY_STORE = ON
GO
ALTER DATABASE [BuildAssetRegistry] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [BuildAssetRegistry]
GO
/****** Object:  Table [dbo].[SubscriptionUpdateHistory]    Script Date: 12-Sep-23 2:08:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SubscriptionUpdateHistory](
	[SubscriptionId] [uniqueidentifier] NOT NULL,
	[Success] [bit] NOT NULL,
	[Action] [nvarchar](max) NULL,
	[ErrorMessage] [nvarchar](max) NULL,
	[Method] [nvarchar](max) NULL,
	[Arguments] [nvarchar](max) NULL,
	[SysEndTime] [datetime2](7) NOT NULL,
	[SysStartTime] [datetime2](7) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [IX_SubscriptionUpdateHistory_SysEndTime_SysStartTime]    Script Date: 12-Sep-23 2:08:15 PM ******/
CREATE CLUSTERED INDEX [IX_SubscriptionUpdateHistory_SysEndTime_SysStartTime] ON [dbo].[SubscriptionUpdateHistory]
(
	[SysEndTime] ASC,
	[SysStartTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SubscriptionUpdates]    Script Date: 12-Sep-23 2:08:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SubscriptionUpdates](
	[SubscriptionId] [uniqueidentifier] NOT NULL,
	[Success] [bit] NOT NULL,
	[Action] [nvarchar](max) NULL,
	[ErrorMessage] [nvarchar](max) NULL,
	[Method] [nvarchar](max) NULL,
	[Arguments] [nvarchar](max) NULL,
	[SysEndTime] [datetime2](7) GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
	[SysStartTime] [datetime2](7) GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
 CONSTRAINT [PK_SubscriptionUpdates] PRIMARY KEY CLUSTERED 
(
	[SubscriptionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTime], [SysEndTime])
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[SubscriptionUpdateHistory])
)
GO
/****** Object:  Table [dbo].[RepositoryBranchUpdateHistory]    Script Date: 12-Sep-23 2:08:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RepositoryBranchUpdateHistory](
	[RepositoryName] [nvarchar](450) NOT NULL,
	[BranchName] [nvarchar](450) NOT NULL,
	[Success] [bit] NOT NULL,
	[Action] [nvarchar](max) NULL,
	[ErrorMessage] [nvarchar](max) NULL,
	[Method] [nvarchar](max) NULL,
	[Arguments] [nvarchar](max) NULL,
	[SysEndTime] [datetime2](7) NOT NULL,
	[SysStartTime] [datetime2](7) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [IX_RepositoryBranchUpdateHistory_SysEndTime_SysStartTime]    Script Date: 12-Sep-23 2:08:15 PM ******/
CREATE CLUSTERED INDEX [IX_RepositoryBranchUpdateHistory_SysEndTime_SysStartTime] ON [dbo].[RepositoryBranchUpdateHistory]
(
	[SysEndTime] ASC,
	[SysStartTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RepositoryBranchUpdates]    Script Date: 12-Sep-23 2:08:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RepositoryBranchUpdates](
	[RepositoryName] [nvarchar](450) NOT NULL,
	[BranchName] [nvarchar](450) NOT NULL,
	[Success] [bit] NOT NULL,
	[Action] [nvarchar](max) NULL,
	[ErrorMessage] [nvarchar](max) NULL,
	[Method] [nvarchar](max) NULL,
	[Arguments] [nvarchar](max) NULL,
	[SysEndTime] [datetime2](7) GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
	[SysStartTime] [datetime2](7) GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
 CONSTRAINT [PK_RepositoryBranchUpdates] PRIMARY KEY CLUSTERED 
(
	[RepositoryName] ASC,
	[BranchName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTime], [SysEndTime])
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[RepositoryBranchUpdateHistory])
)
GO
/****** Object:  Table [dbo].[__EFMigrationsHistory]    Script Date: 12-Sep-23 2:08:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[__EFMigrationsHistory](
	[MigrationId] [nvarchar](150) NOT NULL,
	[ProductVersion] [nvarchar](32) NOT NULL,
 CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY CLUSTERED 
(
	[MigrationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AspNetRoleClaims]    Script Date: 12-Sep-23 2:08:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetRoleClaims](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[RoleId] [int] NOT NULL,
	[ClaimType] [nvarchar](max) NULL,
	[ClaimValue] [nvarchar](max) NULL,
 CONSTRAINT [PK_AspNetRoleClaims] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AspNetRoles]    Script Date: 12-Sep-23 2:08:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetRoles](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](256) NULL,
	[NormalizedName] [nvarchar](256) NULL,
	[ConcurrencyStamp] [nvarchar](max) NULL,
 CONSTRAINT [PK_AspNetRoles] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AspNetUserClaims]    Script Date: 12-Sep-23 2:08:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUserClaims](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[ClaimType] [nvarchar](max) NULL,
	[ClaimValue] [nvarchar](max) NULL,
 CONSTRAINT [PK_AspNetUserClaims] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AspNetUserLogins]    Script Date: 12-Sep-23 2:08:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUserLogins](
	[LoginProvider] [nvarchar](450) NOT NULL,
	[ProviderKey] [nvarchar](450) NOT NULL,
	[ProviderDisplayName] [nvarchar](max) NULL,
	[UserId] [int] NOT NULL,
 CONSTRAINT [PK_AspNetUserLogins] PRIMARY KEY CLUSTERED 
(
	[LoginProvider] ASC,
	[ProviderKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AspNetUserPersonalAccessTokens]    Script Date: 12-Sep-23 2:08:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUserPersonalAccessTokens](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](450) NULL,
	[Created] [datetimeoffset](7) NOT NULL,
	[Hash] [nvarchar](max) NULL,
	[ApplicationUserId] [int] NOT NULL,
 CONSTRAINT [PK_AspNetUserPersonalAccessTokens] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AspNetUserRoles]    Script Date: 12-Sep-23 2:08:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUserRoles](
	[UserId] [int] NOT NULL,
	[RoleId] [int] NOT NULL,
 CONSTRAINT [PK_AspNetUserRoles] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AspNetUsers]    Script Date: 12-Sep-23 2:08:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUsers](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[FullName] [nvarchar](max) NULL,
	[LastUpdated] [datetimeoffset](7) NOT NULL,
	[UserName] [nvarchar](256) NULL,
	[NormalizedUserName] [nvarchar](256) NULL,
	[Email] [nvarchar](256) NULL,
	[NormalizedEmail] [nvarchar](256) NULL,
	[EmailConfirmed] [bit] NOT NULL,
	[PasswordHash] [nvarchar](max) NULL,
	[SecurityStamp] [nvarchar](max) NULL,
	[ConcurrencyStamp] [nvarchar](max) NULL,
	[PhoneNumber] [nvarchar](max) NULL,
	[PhoneNumberConfirmed] [bit] NOT NULL,
	[TwoFactorEnabled] [bit] NOT NULL,
	[LockoutEnd] [datetimeoffset](7) NULL,
	[LockoutEnabled] [bit] NOT NULL,
	[AccessFailedCount] [int] NOT NULL,
 CONSTRAINT [PK_AspNetUsers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AspNetUserTokens]    Script Date: 12-Sep-23 2:08:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUserTokens](
	[UserId] [int] NOT NULL,
	[LoginProvider] [nvarchar](450) NOT NULL,
	[Name] [nvarchar](450) NOT NULL,
	[Value] [nvarchar](max) NULL,
 CONSTRAINT [PK_AspNetUserTokens] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[LoginProvider] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AssetLocations]    Script Date: 12-Sep-23 2:08:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AssetLocations](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Location] [nvarchar](max) NULL,
	[Type] [int] NOT NULL,
	[AssetId] [int] NULL,
 CONSTRAINT [PK_AssetLocations] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Assets]    Script Date: 12-Sep-23 2:08:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Assets](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](150) NULL,
	[Version] [nvarchar](75) NULL,
	[BuildId] [int] NOT NULL,
	[NonShipping] [bit] NOT NULL,
 CONSTRAINT [PK_Assets] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BuildChannels]    Script Date: 12-Sep-23 2:08:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BuildChannels](
	[BuildId] [int] NOT NULL,
	[ChannelId] [int] NOT NULL,
	[DateTimeAdded] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [PK_BuildChannels] PRIMARY KEY CLUSTERED 
(
	[BuildId] ASC,
	[ChannelId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BuildDependencies]    Script Date: 12-Sep-23 2:08:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BuildDependencies](
	[BuildId] [int] NOT NULL,
	[DependentBuildId] [int] NOT NULL,
	[IsProduct] [bit] NOT NULL,
	[TimeToInclusionInMinutes] [float] NOT NULL,
 CONSTRAINT [PK_BuildDependencies] PRIMARY KEY CLUSTERED 
(
	[BuildId] ASC,
	[DependentBuildId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BuildIncoherencies]    Script Date: 12-Sep-23 2:08:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BuildIncoherencies](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](max) NULL,
	[Version] [nvarchar](max) NULL,
	[Repository] [nvarchar](max) NULL,
	[Commit] [nvarchar](max) NULL,
	[BuildId] [int] NULL,
 CONSTRAINT [PK_BuildIncoherencies] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Builds]    Script Date: 12-Sep-23 2:08:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Builds](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Commit] [nvarchar](max) NULL,
	[AzureDevOpsBuildId] [int] NULL,
	[AzureDevOpsBuildDefinitionId] [int] NULL,
	[AzureDevOpsAccount] [nvarchar](max) NULL,
	[AzureDevOpsProject] [nvarchar](max) NULL,
	[AzureDevOpsBuildNumber] [nvarchar](max) NULL,
	[AzureDevOpsRepository] [nvarchar](max) NULL,
	[AzureDevOpsBranch] [nvarchar](max) NULL,
	[GitHubRepository] [nvarchar](max) NULL,
	[GitHubBranch] [nvarchar](max) NULL,
	[DateProduced] [datetimeoffset](7) NOT NULL,
	[Released] [bit] NOT NULL,
	[Stable] [bit] NOT NULL,
 CONSTRAINT [PK_Builds] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Channels]    Script Date: 12-Sep-23 2:08:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Channels](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](450) NOT NULL,
	[Classification] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_Channels] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DefaultChannels]    Script Date: 12-Sep-23 2:08:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DefaultChannels](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Repository] [varchar](300) NOT NULL,
	[Branch] [varchar](100) NOT NULL,
	[ChannelId] [int] NOT NULL,
	[Enabled] [bit] NOT NULL,
 CONSTRAINT [PK_DefaultChannels] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DependencyFlowEvents]    Script Date: 12-Sep-23 2:08:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DependencyFlowEvents](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[SourceRepository] [nvarchar](450) NULL,
	[TargetRepository] [nvarchar](450) NULL,
	[ChannelId] [int] NULL,
	[BuildId] [int] NOT NULL,
	[Event] [nvarchar](max) NULL,
	[Reason] [nvarchar](max) NULL,
	[FlowType] [nvarchar](max) NULL,
	[Timestamp] [datetimeoffset](7) NOT NULL,
	[Url] [nvarchar](max) NULL,
 CONSTRAINT [PK_DependencyFlowEvents] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[GoalTime]    Script Date: 12-Sep-23 2:08:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GoalTime](
	[ChannelId] [int] NOT NULL,
	[DefinitionId] [int] NOT NULL,
	[Minutes] [int] NOT NULL,
 CONSTRAINT [PK_GoalTime] PRIMARY KEY CLUSTERED 
(
	[DefinitionId] ASC,
	[ChannelId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LongestBuildPaths]    Script Date: 12-Sep-23 2:08:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LongestBuildPaths](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ChannelId] [int] NOT NULL,
	[ReportDate] [datetimeoffset](7) NOT NULL,
	[BestCaseTimeInMinutes] [float] NOT NULL,
	[WorstCaseTimeInMinutes] [float] NOT NULL,
	[ContributingRepositories] [nvarchar](max) NULL,
 CONSTRAINT [PK_LongestBuildPaths] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Repositories]    Script Date: 12-Sep-23 2:08:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Repositories](
	[RepositoryName] [nvarchar](450) NOT NULL,
	[InstallationId] [bigint] NOT NULL,
 CONSTRAINT [PK_Repositories] PRIMARY KEY CLUSTERED 
(
	[RepositoryName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RepositoryBranches]    Script Date: 12-Sep-23 2:08:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RepositoryBranches](
	[RepositoryName] [nvarchar](450) NOT NULL,
	[BranchName] [nvarchar](450) NOT NULL,
	[Policy] [nvarchar](max) NULL,
 CONSTRAINT [PK_RepositoryBranches] PRIMARY KEY CLUSTERED 
(
	[RepositoryName] ASC,
	[BranchName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Subscriptions]    Script Date: 12-Sep-23 2:08:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Subscriptions](
	[Id] [uniqueidentifier] NOT NULL,
	[ChannelId] [int] NOT NULL,
	[SourceRepository] [nvarchar](max) NULL,
	[TargetRepository] [nvarchar](max) NULL,
	[TargetBranch] [nvarchar](max) NULL,
	[Policy] [nvarchar](max) NULL,
	[Enabled] [bit] NOT NULL,
	[LastAppliedBuildId] [int] NULL,
	[PullRequestFailureNotificationTags] [nvarchar](max) NULL,
 CONSTRAINT [PK_Subscriptions] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [IX_AspNetRoleClaims_RoleId]    Script Date: 12-Sep-23 2:08:15 PM ******/
CREATE NONCLUSTERED INDEX [IX_AspNetRoleClaims_RoleId] ON [dbo].[AspNetRoleClaims]
(
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [RoleNameIndex]    Script Date: 12-Sep-23 2:08:15 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [RoleNameIndex] ON [dbo].[AspNetRoles]
(
	[NormalizedName] ASC
)
WHERE ([NormalizedName] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_AspNetUserClaims_UserId]    Script Date: 12-Sep-23 2:08:15 PM ******/
CREATE NONCLUSTERED INDEX [IX_AspNetUserClaims_UserId] ON [dbo].[AspNetUserClaims]
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_AspNetUserLogins_UserId]    Script Date: 12-Sep-23 2:08:15 PM ******/
CREATE NONCLUSTERED INDEX [IX_AspNetUserLogins_UserId] ON [dbo].[AspNetUserLogins]
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_AspNetUserPersonalAccessTokens_ApplicationUserId_Name]    Script Date: 12-Sep-23 2:08:15 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_AspNetUserPersonalAccessTokens_ApplicationUserId_Name] ON [dbo].[AspNetUserPersonalAccessTokens]
(
	[ApplicationUserId] ASC,
	[Name] ASC
)
WHERE ([Name] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_AspNetUserRoles_RoleId]    Script Date: 12-Sep-23 2:08:15 PM ******/
CREATE NONCLUSTERED INDEX [IX_AspNetUserRoles_RoleId] ON [dbo].[AspNetUserRoles]
(
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [EmailIndex]    Script Date: 12-Sep-23 2:08:15 PM ******/
CREATE NONCLUSTERED INDEX [EmailIndex] ON [dbo].[AspNetUsers]
(
	[NormalizedEmail] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UserNameIndex]    Script Date: 12-Sep-23 2:08:15 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [UserNameIndex] ON [dbo].[AspNetUsers]
(
	[NormalizedUserName] ASC
)
WHERE ([NormalizedUserName] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_AssetLocations_AssetId]    Script Date: 12-Sep-23 2:08:15 PM ******/
CREATE NONCLUSTERED INDEX [IX_AssetLocations_AssetId] ON [dbo].[AssetLocations]
(
	[AssetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Assets_BuildId]    Script Date: 12-Sep-23 2:08:15 PM ******/
CREATE NONCLUSTERED INDEX [IX_Assets_BuildId] ON [dbo].[Assets]
(
	[BuildId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Assets_Name_Version]    Script Date: 12-Sep-23 2:08:15 PM ******/
CREATE NONCLUSTERED INDEX [IX_Assets_Name_Version] ON [dbo].[Assets]
(
	[Name] ASC,
	[Version] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_BuildChannels_ChannelId]    Script Date: 12-Sep-23 2:08:15 PM ******/
CREATE NONCLUSTERED INDEX [IX_BuildChannels_ChannelId] ON [dbo].[BuildChannels]
(
	[ChannelId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_BuildDependencies_DependentBuildId]    Script Date: 12-Sep-23 2:08:15 PM ******/
CREATE NONCLUSTERED INDEX [IX_BuildDependencies_DependentBuildId] ON [dbo].[BuildDependencies]
(
	[DependentBuildId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_BuildIncoherencies_BuildId]    Script Date: 12-Sep-23 2:08:15 PM ******/
CREATE NONCLUSTERED INDEX [IX_BuildIncoherencies_BuildId] ON [dbo].[BuildIncoherencies]
(
	[BuildId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Channels_Name]    Script Date: 12-Sep-23 2:08:15 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Channels_Name] ON [dbo].[Channels]
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_DefaultChannels_ChannelId]    Script Date: 12-Sep-23 2:08:15 PM ******/
CREATE NONCLUSTERED INDEX [IX_DefaultChannels_ChannelId] ON [dbo].[DefaultChannels]
(
	[ChannelId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_DefaultChannels_Repository_Branch_ChannelId]    Script Date: 12-Sep-23 2:08:15 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_DefaultChannels_Repository_Branch_ChannelId] ON [dbo].[DefaultChannels]
(
	[Repository] ASC,
	[Branch] ASC,
	[ChannelId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_DependencyFlowEvents_BuildId]    Script Date: 12-Sep-23 2:08:15 PM ******/
CREATE NONCLUSTERED INDEX [IX_DependencyFlowEvents_BuildId] ON [dbo].[DependencyFlowEvents]
(
	[BuildId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_GoalTime_ChannelId]    Script Date: 12-Sep-23 2:08:15 PM ******/
CREATE NONCLUSTERED INDEX [IX_GoalTime_ChannelId] ON [dbo].[GoalTime]
(
	[ChannelId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_LongestBuildPaths_ChannelId]    Script Date: 12-Sep-23 2:08:15 PM ******/
CREATE NONCLUSTERED INDEX [IX_LongestBuildPaths_ChannelId] ON [dbo].[LongestBuildPaths]
(
	[ChannelId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_RepositoryBranchUpdateHistory_RepositoryName_BranchName_SysEndTime_SysStartTime]    Script Date: 12-Sep-23 2:08:15 PM ******/
CREATE NONCLUSTERED INDEX [IX_RepositoryBranchUpdateHistory_RepositoryName_BranchName_SysEndTime_SysStartTime] ON [dbo].[RepositoryBranchUpdateHistory]
(
	[RepositoryName] ASC,
	[BranchName] ASC,
	[SysEndTime] ASC,
	[SysStartTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Subscriptions_ChannelId]    Script Date: 12-Sep-23 2:08:15 PM ******/
CREATE NONCLUSTERED INDEX [IX_Subscriptions_ChannelId] ON [dbo].[Subscriptions]
(
	[ChannelId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Subscriptions_LastAppliedBuildId]    Script Date: 12-Sep-23 2:08:15 PM ******/
CREATE NONCLUSTERED INDEX [IX_Subscriptions_LastAppliedBuildId] ON [dbo].[Subscriptions]
(
	[LastAppliedBuildId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_SubscriptionUpdateHistory_SubscriptionId_SysEndTime_SysStartTime]    Script Date: 12-Sep-23 2:08:15 PM ******/
CREATE NONCLUSTERED INDEX [IX_SubscriptionUpdateHistory_SubscriptionId_SysEndTime_SysStartTime] ON [dbo].[SubscriptionUpdateHistory]
(
	[SubscriptionId] ASC,
	[SysEndTime] ASC,
	[SysStartTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AspNetRoleClaims]  WITH CHECK ADD  CONSTRAINT [FK_AspNetRoleClaims_AspNetRoles_RoleId] FOREIGN KEY([RoleId])
REFERENCES [dbo].[AspNetRoles] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetRoleClaims] CHECK CONSTRAINT [FK_AspNetRoleClaims_AspNetRoles_RoleId]
GO
ALTER TABLE [dbo].[AspNetUserClaims]  WITH CHECK ADD  CONSTRAINT [FK_AspNetUserClaims_AspNetUsers_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserClaims] CHECK CONSTRAINT [FK_AspNetUserClaims_AspNetUsers_UserId]
GO
ALTER TABLE [dbo].[AspNetUserLogins]  WITH CHECK ADD  CONSTRAINT [FK_AspNetUserLogins_AspNetUsers_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserLogins] CHECK CONSTRAINT [FK_AspNetUserLogins_AspNetUsers_UserId]
GO
ALTER TABLE [dbo].[AspNetUserPersonalAccessTokens]  WITH CHECK ADD  CONSTRAINT [FK_AspNetUserPersonalAccessTokens_AspNetUsers_ApplicationUserId] FOREIGN KEY([ApplicationUserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserPersonalAccessTokens] CHECK CONSTRAINT [FK_AspNetUserPersonalAccessTokens_AspNetUsers_ApplicationUserId]
GO
ALTER TABLE [dbo].[AspNetUserRoles]  WITH CHECK ADD  CONSTRAINT [FK_AspNetUserRoles_AspNetRoles_RoleId] FOREIGN KEY([RoleId])
REFERENCES [dbo].[AspNetRoles] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserRoles] CHECK CONSTRAINT [FK_AspNetUserRoles_AspNetRoles_RoleId]
GO
ALTER TABLE [dbo].[AspNetUserRoles]  WITH CHECK ADD  CONSTRAINT [FK_AspNetUserRoles_AspNetUsers_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserRoles] CHECK CONSTRAINT [FK_AspNetUserRoles_AspNetUsers_UserId]
GO
ALTER TABLE [dbo].[AspNetUserTokens]  WITH CHECK ADD  CONSTRAINT [FK_AspNetUserTokens_AspNetUsers_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserTokens] CHECK CONSTRAINT [FK_AspNetUserTokens_AspNetUsers_UserId]
GO
ALTER TABLE [dbo].[AssetLocations]  WITH CHECK ADD  CONSTRAINT [FK_AssetLocations_Assets_AssetId] FOREIGN KEY([AssetId])
REFERENCES [dbo].[Assets] ([Id])
GO
ALTER TABLE [dbo].[AssetLocations] CHECK CONSTRAINT [FK_AssetLocations_Assets_AssetId]
GO
ALTER TABLE [dbo].[Assets]  WITH CHECK ADD  CONSTRAINT [FK_Assets_Builds_BuildId] FOREIGN KEY([BuildId])
REFERENCES [dbo].[Builds] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Assets] CHECK CONSTRAINT [FK_Assets_Builds_BuildId]
GO
ALTER TABLE [dbo].[BuildChannels]  WITH CHECK ADD  CONSTRAINT [FK_BuildChannels_Builds_BuildId] FOREIGN KEY([BuildId])
REFERENCES [dbo].[Builds] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[BuildChannels] CHECK CONSTRAINT [FK_BuildChannels_Builds_BuildId]
GO
ALTER TABLE [dbo].[BuildChannels]  WITH CHECK ADD  CONSTRAINT [FK_BuildChannels_Channels_ChannelId] FOREIGN KEY([ChannelId])
REFERENCES [dbo].[Channels] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[BuildChannels] CHECK CONSTRAINT [FK_BuildChannels_Channels_ChannelId]
GO
ALTER TABLE [dbo].[BuildDependencies]  WITH CHECK ADD  CONSTRAINT [FK_BuildDependencies_Builds_BuildId] FOREIGN KEY([BuildId])
REFERENCES [dbo].[Builds] ([Id])
GO
ALTER TABLE [dbo].[BuildDependencies] CHECK CONSTRAINT [FK_BuildDependencies_Builds_BuildId]
GO
ALTER TABLE [dbo].[BuildDependencies]  WITH CHECK ADD  CONSTRAINT [FK_BuildDependencies_Builds_DependentBuildId] FOREIGN KEY([DependentBuildId])
REFERENCES [dbo].[Builds] ([Id])
GO
ALTER TABLE [dbo].[BuildDependencies] CHECK CONSTRAINT [FK_BuildDependencies_Builds_DependentBuildId]
GO
ALTER TABLE [dbo].[BuildIncoherencies]  WITH CHECK ADD  CONSTRAINT [FK_BuildIncoherencies_Builds_BuildId] FOREIGN KEY([BuildId])
REFERENCES [dbo].[Builds] ([Id])
GO
ALTER TABLE [dbo].[BuildIncoherencies] CHECK CONSTRAINT [FK_BuildIncoherencies_Builds_BuildId]
GO
ALTER TABLE [dbo].[DefaultChannels]  WITH CHECK ADD  CONSTRAINT [FK_DefaultChannels_Channels_ChannelId] FOREIGN KEY([ChannelId])
REFERENCES [dbo].[Channels] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[DefaultChannels] CHECK CONSTRAINT [FK_DefaultChannels_Channels_ChannelId]
GO
ALTER TABLE [dbo].[DependencyFlowEvents]  WITH CHECK ADD  CONSTRAINT [FK_DependencyFlowEvents_Builds_BuildId] FOREIGN KEY([BuildId])
REFERENCES [dbo].[Builds] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[DependencyFlowEvents] CHECK CONSTRAINT [FK_DependencyFlowEvents_Builds_BuildId]
GO
ALTER TABLE [dbo].[GoalTime]  WITH CHECK ADD  CONSTRAINT [FK_GoalTime_Channels_ChannelId] FOREIGN KEY([ChannelId])
REFERENCES [dbo].[Channels] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[GoalTime] CHECK CONSTRAINT [FK_GoalTime_Channels_ChannelId]
GO
ALTER TABLE [dbo].[LongestBuildPaths]  WITH CHECK ADD  CONSTRAINT [FK_LongestBuildPaths_Channels_ChannelId] FOREIGN KEY([ChannelId])
REFERENCES [dbo].[Channels] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LongestBuildPaths] CHECK CONSTRAINT [FK_LongestBuildPaths_Channels_ChannelId]
GO
ALTER TABLE [dbo].[RepositoryBranches]  WITH CHECK ADD  CONSTRAINT [FK_RepositoryBranches_Repositories_RepositoryName] FOREIGN KEY([RepositoryName])
REFERENCES [dbo].[Repositories] ([RepositoryName])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[RepositoryBranches] CHECK CONSTRAINT [FK_RepositoryBranches_Repositories_RepositoryName]
GO
ALTER TABLE [dbo].[RepositoryBranchUpdates]  WITH CHECK ADD  CONSTRAINT [FK_RepositoryBranchUpdates_RepositoryBranches_RepositoryName_BranchName] FOREIGN KEY([RepositoryName], [BranchName])
REFERENCES [dbo].[RepositoryBranches] ([RepositoryName], [BranchName])
GO
ALTER TABLE [dbo].[RepositoryBranchUpdates] CHECK CONSTRAINT [FK_RepositoryBranchUpdates_RepositoryBranches_RepositoryName_BranchName]
GO
ALTER TABLE [dbo].[Subscriptions]  WITH CHECK ADD  CONSTRAINT [FK_Subscriptions_Builds_LastAppliedBuildId] FOREIGN KEY([LastAppliedBuildId])
REFERENCES [dbo].[Builds] ([Id])
GO
ALTER TABLE [dbo].[Subscriptions] CHECK CONSTRAINT [FK_Subscriptions_Builds_LastAppliedBuildId]
GO
ALTER TABLE [dbo].[Subscriptions]  WITH CHECK ADD  CONSTRAINT [FK_Subscriptions_Channels_ChannelId] FOREIGN KEY([ChannelId])
REFERENCES [dbo].[Channels] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Subscriptions] CHECK CONSTRAINT [FK_Subscriptions_Channels_ChannelId]
GO
ALTER TABLE [dbo].[SubscriptionUpdates]  WITH CHECK ADD  CONSTRAINT [FK_SubscriptionUpdates_Subscriptions_SubscriptionId] FOREIGN KEY([SubscriptionId])
REFERENCES [dbo].[Subscriptions] ([Id])
GO
ALTER TABLE [dbo].[SubscriptionUpdates] CHECK CONSTRAINT [FK_SubscriptionUpdates_Subscriptions_SubscriptionId]
GO
USE [master]
GO
ALTER DATABASE [BuildAssetRegistry] SET  READ_WRITE 
GO


INSERT [dbo].[Repositories] ([RepositoryName], [InstallationId]) VALUES (N'https://dev.azure.com/dnceng/internal/_git/maestro-test1', 0)
INSERT [dbo].[Repositories] ([RepositoryName], [InstallationId]) VALUES (N'https://dev.azure.com/dnceng/internal/_git/maestro-test2', 0)
INSERT [dbo].[Repositories] ([RepositoryName], [InstallationId]) VALUES (N'https://github.com/maestro-auth-test/maestro-test1', 289474)
INSERT [dbo].[Repositories] ([RepositoryName], [InstallationId]) VALUES (N'https://github.com/maestro-auth-test/maestro-test2', 289474)
INSERT [dbo].[Repositories] ([RepositoryName], [InstallationId]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', 289474)
GO