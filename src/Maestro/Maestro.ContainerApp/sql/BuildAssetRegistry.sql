USE [master]
GO
/****** Object:  Database [BuildAssetRegistry]    Script Date: 12-Sep-23 11:08:11 AM ******/
CREATE DATABASE [BuildAssetRegistry]
 CONTAINMENT = NONE
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
/****** Object:  Table [dbo].[SubscriptionUpdateHistory]    Script Date: 12-Sep-23 11:08:11 AM ******/
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
/****** Object:  Index [IX_SubscriptionUpdateHistory_SysEndTime_SysStartTime]    Script Date: 12-Sep-23 11:08:11 AM ******/
CREATE CLUSTERED INDEX [IX_SubscriptionUpdateHistory_SysEndTime_SysStartTime] ON [dbo].[SubscriptionUpdateHistory]
(
	[SysEndTime] ASC,
	[SysStartTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SubscriptionUpdates]    Script Date: 12-Sep-23 11:08:11 AM ******/
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
/****** Object:  Table [dbo].[RepositoryBranchUpdateHistory]    Script Date: 12-Sep-23 11:08:11 AM ******/
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
/****** Object:  Index [IX_RepositoryBranchUpdateHistory_SysEndTime_SysStartTime]    Script Date: 12-Sep-23 11:08:11 AM ******/
CREATE CLUSTERED INDEX [IX_RepositoryBranchUpdateHistory_SysEndTime_SysStartTime] ON [dbo].[RepositoryBranchUpdateHistory]
(
	[SysEndTime] ASC,
	[SysStartTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RepositoryBranchUpdates]    Script Date: 12-Sep-23 11:08:11 AM ******/
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
/****** Object:  Table [dbo].[__EFMigrationsHistory]    Script Date: 12-Sep-23 11:08:11 AM ******/
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
/****** Object:  Table [dbo].[AspNetRoleClaims]    Script Date: 12-Sep-23 11:08:11 AM ******/
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
/****** Object:  Table [dbo].[AspNetRoles]    Script Date: 12-Sep-23 11:08:11 AM ******/
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
/****** Object:  Table [dbo].[AspNetUserClaims]    Script Date: 12-Sep-23 11:08:11 AM ******/
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
/****** Object:  Table [dbo].[AspNetUserLogins]    Script Date: 12-Sep-23 11:08:11 AM ******/
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
/****** Object:  Table [dbo].[AspNetUserPersonalAccessTokens]    Script Date: 12-Sep-23 11:08:11 AM ******/
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
/****** Object:  Table [dbo].[AspNetUserRoles]    Script Date: 12-Sep-23 11:08:11 AM ******/
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
/****** Object:  Table [dbo].[AspNetUsers]    Script Date: 12-Sep-23 11:08:11 AM ******/
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
/****** Object:  Table [dbo].[AspNetUserTokens]    Script Date: 12-Sep-23 11:08:11 AM ******/
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
/****** Object:  Table [dbo].[AssetLocations]    Script Date: 12-Sep-23 11:08:11 AM ******/
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
/****** Object:  Table [dbo].[Assets]    Script Date: 12-Sep-23 11:08:11 AM ******/
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
/****** Object:  Table [dbo].[BuildChannels]    Script Date: 12-Sep-23 11:08:11 AM ******/
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
/****** Object:  Table [dbo].[BuildDependencies]    Script Date: 12-Sep-23 11:08:11 AM ******/
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
/****** Object:  Table [dbo].[BuildIncoherencies]    Script Date: 12-Sep-23 11:08:11 AM ******/
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
/****** Object:  Table [dbo].[Builds]    Script Date: 12-Sep-23 11:08:11 AM ******/
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
/****** Object:  Table [dbo].[Channels]    Script Date: 12-Sep-23 11:08:11 AM ******/
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
/****** Object:  Table [dbo].[DefaultChannels]    Script Date: 12-Sep-23 11:08:11 AM ******/
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
/****** Object:  Table [dbo].[DependencyFlowEvents]    Script Date: 12-Sep-23 11:08:11 AM ******/
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
/****** Object:  Table [dbo].[GoalTime]    Script Date: 12-Sep-23 11:08:11 AM ******/
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
/****** Object:  Table [dbo].[LongestBuildPaths]    Script Date: 12-Sep-23 11:08:11 AM ******/
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
/****** Object:  Table [dbo].[Repositories]    Script Date: 12-Sep-23 11:08:11 AM ******/
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
/****** Object:  Table [dbo].[RepositoryBranches]    Script Date: 12-Sep-23 11:08:11 AM ******/
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
/****** Object:  Table [dbo].[Subscriptions]    Script Date: 12-Sep-23 11:08:11 AM ******/
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
SET IDENTITY_INSERT [dbo].[AssetLocations] ON
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (2, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 2)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (3, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 3)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (4, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 4)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (5, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 5)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (6, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 6)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (7, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 7)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (8, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 8)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (9, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 9)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (10, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 10)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (11, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 11)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (12, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 12)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (13, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 13)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (14, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 14)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (15, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 15)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (16, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 16)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (17, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 17)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (18, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 18)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (19, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 19)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (20, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 20)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (21, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 21)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (22, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 22)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (23, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 23)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (24, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 24)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (25, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 25)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (26, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 26)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (27, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 27)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (28, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 28)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (29, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 29)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (30, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 30)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (31, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 31)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (32, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 32)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (33, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 33)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (34, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 34)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (35, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 35)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (36, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 36)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (37, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 37)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (38, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 38)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (39, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 39)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (40, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 40)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (41, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 41)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (42, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 42)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (43, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 43)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (44, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 44)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (45, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 45)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (46, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 46)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (47, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 47)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (48, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 48)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (49, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 49)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (50, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 50)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (51, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 51)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (52, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 52)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1045, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1045)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1046, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1046)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1047, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1047)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1048, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1048)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1049, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1049)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1050, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1050)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1051, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1051)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1052, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1052)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1053, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1053)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1054, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1054)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1055, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1055)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1056, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1056)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1057, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1057)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1058, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1058)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1059, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1059)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1060, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1060)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1061, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1061)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1062, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1062)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1063, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1063)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1064, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1064)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1065, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1065)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1066, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1066)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1067, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1067)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1068, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1068)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1069, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1069)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1070, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1070)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1071, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1071)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1072, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1072)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1073, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1073)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1074, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1074)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1075, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1075)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1076, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1076)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1077, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1077)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1078, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1078)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1079, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1079)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1080, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1080)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1081, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1081)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1082, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1082)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1083, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1083)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1084, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1084)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1085, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1085)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1086, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1086)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1087, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1087)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1088, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1088)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1089, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1089)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1090, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1090)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1091, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1091)
GO
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1092, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1092)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1093, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1093)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1094, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1094)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1095, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1095)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1096, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1096)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1097, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1097)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1098, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1098)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1099, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1099)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1100, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1100)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1101, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1101)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1102, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1102)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1103, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1103)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1104, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1104)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1105, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1105)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1106, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1106)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1107, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1107)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1108, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1108)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1109, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1109)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1110, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1110)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1111, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1111)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1112, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1112)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1113, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1113)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1114, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1114)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1115, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1115)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1116, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1116)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1117, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1117)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1118, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1118)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1119, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1119)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1120, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1120)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1121, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1121)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1122, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1122)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1123, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1123)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1124, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1124)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1125, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1125)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1126, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1126)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1127, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1127)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1128, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1128)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1129, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1137)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1130, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1138)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1131, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1139)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1132, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1140)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1133, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1141)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1134, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1142)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1135, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1143)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1136, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1144)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1137, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1145)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1138, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1146)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1139, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1147)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1140, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1148)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1141, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1149)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1142, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1150)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1143, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1151)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1144, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1152)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1145, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1153)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1146, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1154)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1147, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1155)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1148, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1156)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1149, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1157)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1150, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1158)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1151, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1159)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1152, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1160)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1153, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1161)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1154, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1162)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1155, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1163)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1156, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1164)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1157, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1165)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1158, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1166)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1159, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1167)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1160, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1168)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1161, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1169)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1162, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1170)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1163, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1171)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1164, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1172)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1165, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1173)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1166, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1174)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1167, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1175)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1168, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1176)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1169, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1177)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1170, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1178)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1171, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1179)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1172, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1180)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1173, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1181)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1174, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1182)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1175, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1183)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1176, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1184)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1177, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1185)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1178, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1186)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1179, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1187)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1180, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1188)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1181, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1189)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1182, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1190)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1183, N'https://some-proxy.azurewebsites.net/container/some-container/sig/somesig/se/2020-02-02/darc-int-maestro-test1-bababababab-1/index.json', 1, 1191)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1184, N'https://some_org.pkgs.visualstudio.com/_packaging/darc-int-maestro-test1-aaabaababababe-1/nuget/v3/index.json', 1, 1192)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1185, N'https://some_org.pkgs.visualstudio.com/_packaging/darc-int-maestro-test1-bbbbaababababd-1/nuget/v3/index.json', 1, 1193)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1186, N'https://dotnetfeed.blob.core.windows.net/maestro-test1/index.json', 1, 1193)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1187, N'https://some_org.pkgs.visualstudio.com/_packaging/darc-int-maestro-test1-cccbaababababf-1/nuget/v3/index.json', 1, 1194)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1188, N'https://dev.azure.com/dnceng/internal/_apis/build/builds/9999999/artifacts', 2, 1194)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1189, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1195)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1190, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1196)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1191, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1197)
GO
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1192, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1198)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1193, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1199)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1194, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1200)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1195, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1201)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1196, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1202)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1197, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1203)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1198, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1204)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1199, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1205)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1200, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1206)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1201, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1207)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1202, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1208)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1203, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1209)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1204, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1210)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1205, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1211)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1206, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1212)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1207, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1213)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1208, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1214)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1209, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1215)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1210, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1216)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1211, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1217)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1212, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1218)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1213, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1219)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1214, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1220)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1215, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1221)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1216, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1222)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1217, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1223)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1218, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1224)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1219, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1225)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1220, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1226)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1221, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1227)
INSERT [dbo].[AssetLocations] ([Id], [Location], [Type], [AssetId]) VALUES (1222, N'https://pkgs.dev.azure.com/dnceng/public/_packaging/NotARealFeed/nuget/v3/index.json', 1, 1228)
SET IDENTITY_INSERT [dbo].[AssetLocations] OFF
GO
SET IDENTITY_INSERT [dbo].[Assets] ON 

INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1, N'A1', N'1.1.0', 1, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (2, N'A2', N'1.1.0', 1, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (3, N'B1', N'2.1.0', 2, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (4, N'B2', N'2.1.0', 2, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (5, N'A1', N'1.1.0', 3, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (6, N'A2', N'1.1.0', 3, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (7, N'B1', N'2.1.0', 4, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (8, N'B2', N'2.1.0', 4, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (9, N'A1', N'1.1.0', 5, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (10, N'A2', N'1.1.0', 5, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (11, N'A1', N'1.1.0', 6, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (12, N'A2', N'1.1.0', 6, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (13, N'B1', N'2.1.0', 7, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (14, N'B2', N'2.1.0', 7, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (15, N'A1', N'1.1.0', 8, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (16, N'A2', N'1.1.0', 8, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (17, N'B1', N'2.1.0', 9, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (18, N'B2', N'2.1.0', 9, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (19, N'A1', N'1.1.0', 10, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (20, N'A2', N'1.1.0', 10, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (21, N'B1', N'2.1.0', 11, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (22, N'B2', N'2.1.0', 11, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (23, N'A1', N'1.1.0', 12, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (24, N'A2', N'1.1.0', 12, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (25, N'B1', N'2.1.0', 13, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (26, N'B2', N'2.1.0', 13, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (27, N'Foo', N'1.1.0', 14, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (28, N'Bar', N'2.1.0', 14, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (29, N'Foo', N'1.1.0', 15, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (30, N'Bar', N'2.1.0', 15, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (31, N'Foo', N'1.1.0', 16, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (32, N'Bar', N'2.1.0', 16, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (33, N'A1', N'1.1.0', 17, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (34, N'A2', N'1.1.0', 17, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (35, N'B1', N'2.1.0', 18, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (36, N'B2', N'2.1.0', 18, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (37, N'A1', N'1.1.0', 19, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (38, N'A2', N'1.1.0', 19, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (39, N'B1', N'2.1.0', 20, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (40, N'B2', N'2.1.0', 20, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (41, N'A1', N'1.1.0', 21, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (42, N'A2', N'1.1.0', 21, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (43, N'B1', N'2.1.0', 22, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (44, N'B2', N'2.1.0', 22, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (45, N'A1', N'1.1.0', 23, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (46, N'A2', N'1.1.0', 23, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (47, N'B1', N'2.1.0', 24, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (48, N'B2', N'2.1.0', 24, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (49, N'A1', N'1.1.0', 25, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (50, N'A2', N'1.1.0', 25, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (51, N'B1', N'2.1.0', 26, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (52, N'B2', N'2.1.0', 26, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1045, N'A1', N'1.1.0', 1023, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1046, N'B1', N'1.1.0', 1023, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1047, N'A2', N'2.1.0', 1024, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1048, N'B2', N'2.1.0', 1024, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1049, N'A1', N'1.1.0', 1025, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1050, N'B1', N'1.1.0', 1025, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1051, N'A2', N'2.1.0', 1026, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1052, N'B2', N'2.1.0', 1026, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1053, N'A1', N'1.1.0', 1027, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1054, N'A2', N'1.1.0', 1027, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1055, N'B1', N'2.1.0', 1028, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1056, N'B2', N'2.1.0', 1028, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1057, N'A1', N'1.1.0', 1029, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1058, N'A2', N'1.1.0', 1029, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1059, N'B1', N'2.1.0', 1030, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1060, N'B2', N'2.1.0', 1030, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1061, N'A1', N'1.1.0', 1031, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1062, N'A2', N'1.1.0', 1031, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1063, N'B1', N'2.1.0', 1032, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1064, N'B2', N'2.1.0', 1032, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1065, N'A1', N'1.1.0', 1033, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1066, N'A2', N'1.1.0', 1033, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1067, N'B1', N'2.1.0', 1034, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1068, N'B2', N'2.1.0', 1034, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1069, N'A1', N'1.1.0', 1035, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1070, N'A2', N'1.1.0', 1035, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1071, N'B1', N'2.1.0', 1036, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1072, N'B2', N'2.1.0', 1036, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1073, N'A1', N'1.1.0', 1037, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1074, N'A2', N'1.1.0', 1037, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1075, N'B1', N'2.1.0', 1038, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1076, N'B2', N'2.1.0', 1038, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1077, N'A1', N'1.1.0', 1039, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1078, N'A2', N'1.1.0', 1039, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1079, N'B1', N'2.1.0', 1040, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1080, N'B2', N'2.1.0', 1040, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1081, N'A1', N'1.1.0', 1041, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1082, N'A2', N'1.1.0', 1041, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1083, N'B1', N'2.1.0', 1042, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1084, N'B2', N'2.1.0', 1042, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1085, N'A1', N'1.1.0', 1043, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1086, N'A2', N'1.1.0', 1043, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1087, N'B1', N'2.1.0', 1044, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1088, N'B2', N'2.1.0', 1044, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1089, N'A1', N'1.1.0', 1045, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1090, N'A2', N'1.1.0', 1045, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1091, N'B1', N'2.1.0', 1046, 0)
GO
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1092, N'B2', N'2.1.0', 1046, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1093, N'A1', N'1.1.0', 1047, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1094, N'A2', N'1.1.0', 1047, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1095, N'B1', N'2.1.0', 1048, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1096, N'B2', N'2.1.0', 1048, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1097, N'A1', N'1.1.0', 1049, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1098, N'A2', N'1.1.0', 1049, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1099, N'B1', N'2.1.0', 1050, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1100, N'B2', N'2.1.0', 1050, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1101, N'A1', N'1.1.0', 1051, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1102, N'A2', N'1.1.0', 1051, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1103, N'B1', N'2.1.0', 1052, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1104, N'B2', N'2.1.0', 1052, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1105, N'Foo', N'1.1.0', 1053, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1106, N'Bar', N'2.1.0', 1053, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1107, N'Pizza', N'3.1.0', 1054, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1108, N'Hamburger', N'4.1.0', 1054, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1109, N'Foo', N'1.1.0', 1055, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1110, N'Bar', N'2.1.0', 1055, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1111, N'Foo', N'1.1.0', 1056, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1112, N'Bar', N'2.1.0', 1056, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1113, N'Fzz', N'1.1.0', 1057, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1114, N'ASD', N'1.1.1', 1057, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1115, N'A1', N'1.1.0', 1058, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1116, N'A2', N'1.1.0', 1058, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1117, N'B1', N'2.1.0', 1059, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1118, N'B2', N'2.1.0', 1059, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1119, N'Foo', N'1.1.0', 1060, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1120, N'Bar', N'2.1.0', 1060, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1121, N'Foo', N'1.1.0', 1061, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1122, N'Bar', N'2.1.0', 1061, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1123, N'Foo', N'1.17.0', 1062, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1124, N'Bar', N'2.17.0', 1062, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1125, N'A1', N'1.1.0', 1063, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1126, N'A2', N'1.1.0', 1063, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1127, N'B1', N'2.1.0', 1064, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1128, N'B2', N'2.1.0', 1064, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1129, N'Foo', N'1.1.0', 1065, 1)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1130, N'Bar', N'2.1.0', 1065, 1)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1131, N'Foo', N'1.1.0', 1066, 1)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1132, N'Bar', N'2.1.0', 1066, 1)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1133, N'Foo', N'1.1.0', 1067, 1)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1134, N'Bar', N'2.1.0', 1067, 1)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1135, N'Foo', N'1.1.0', 1068, 1)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1136, N'Bar', N'2.1.0', 1068, 1)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1137, N'A1', N'1.1.0', 1069, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1138, N'A2', N'1.1.0', 1069, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1139, N'B1', N'2.1.0', 1070, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1140, N'B2', N'2.1.0', 1070, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1141, N'A1', N'1.1.0', 1071, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1142, N'A2', N'1.1.0', 1071, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1143, N'B1', N'2.1.0', 1072, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1144, N'B2', N'2.1.0', 1072, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1145, N'A1', N'1.1.0', 1073, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1146, N'A2', N'1.1.0', 1073, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1147, N'B1', N'2.1.0', 1074, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1148, N'B2', N'2.1.0', 1074, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1149, N'A1', N'1.1.0', 1075, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1150, N'A2', N'1.1.0', 1075, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1151, N'B1', N'2.1.0', 1076, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1152, N'B2', N'2.1.0', 1076, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1153, N'A1', N'1.1.0', 1077, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1154, N'A2', N'1.1.0', 1077, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1155, N'B1', N'2.1.0', 1078, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1156, N'B2', N'2.1.0', 1078, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1157, N'A1', N'1.1.0', 1079, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1158, N'A2', N'1.1.0', 1079, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1159, N'B1', N'2.1.0', 1080, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1160, N'B2', N'2.1.0', 1080, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1161, N'A1', N'1.1.0', 1081, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1162, N'A2', N'1.1.0', 1081, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1163, N'B1', N'2.1.0', 1082, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1164, N'B2', N'2.1.0', 1082, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1165, N'A1', N'1.1.0', 1083, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1166, N'A2', N'1.1.0', 1083, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1167, N'B1', N'2.1.0', 1084, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1168, N'B2', N'2.1.0', 1084, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1169, N'Foo', N'1.1.0', 1085, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1170, N'Bar', N'2.1.0', 1085, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1171, N'Pizza', N'3.1.0', 1086, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1172, N'Hamburger', N'4.1.0', 1086, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1173, N'Foo', N'1.1.0', 1087, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1174, N'Bar', N'2.1.0', 1087, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1175, N'Foo', N'1.17.0', 1088, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1176, N'Bar', N'2.17.0', 1088, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1177, N'Foo', N'1.1.0', 1089, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1178, N'Bar', N'2.1.0', 1089, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1179, N'Fzz', N'1.1.0', 1090, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1180, N'ASD', N'1.1.1', 1090, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1181, N'A1', N'1.1.0', 1091, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1182, N'A2', N'1.1.0', 1091, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1183, N'B1', N'2.1.0', 1092, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1184, N'B2', N'2.1.0', 1092, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1185, N'Foo', N'1.1.0', 1093, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1186, N'Bar', N'2.1.0', 1093, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1187, N'Foo', N'1.1.0', 1094, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1188, N'Bar', N'2.1.0', 1094, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1189, N'Pizza', N'3.1.0', 1095, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1190, N'Hamburger', N'4.1.0', 1095, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1191, N'Foo', N'1.1.0', 1096, 0)
GO
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1192, N'Bar', N'2.1.0', 1096, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1193, N'Pizza', N'3.1.0', 1096, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1194, N'Hamburger', N'4.1.0', 1096, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1195, N'Foo', N'1.1.0', 1097, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1196, N'Bar', N'2.1.0', 1097, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1197, N'Foo', N'1.17.0', 1098, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1198, N'Bar', N'2.17.0', 1098, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1199, N'Foo', N'1.1.0', 1099, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1200, N'Bar', N'2.1.0', 1099, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1201, N'Foo', N'1.1.0', 1100, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1202, N'Bar', N'2.1.0', 1100, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1203, N'Foo', N'1.1.0', 1101, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1204, N'Bar', N'2.1.0', 1101, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1205, N'Pizza', N'3.1.0', 1102, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1206, N'Hamburger', N'4.1.0', 1102, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1207, N'Source1', N'3.1.0', 1103, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1208, N'Source2', N'4.1.0', 1103, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1209, N'Source1', N'3.1.0', 1104, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1210, N'Source2', N'4.1.0', 1104, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1211, N'Foo', N'1.1.0', 1105, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1212, N'Bar', N'2.1.0', 1105, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1213, N'Pizza', N'3.1.0', 1106, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1214, N'Hamburger', N'4.1.0', 1106, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1215, N'Foo', N'1.1.0', 1107, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1216, N'Bar', N'2.1.0', 1107, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1217, N'Foo', N'1.17.0', 1108, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1218, N'Bar', N'2.17.0', 1108, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1219, N'Foo', N'1.1.0', 1109, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1220, N'Bar', N'2.1.0', 1109, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1221, N'Fzz', N'1.1.0', 1110, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1222, N'ASD', N'1.1.1', 1110, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1223, N'A1', N'1.1.0', 1111, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1224, N'A2', N'1.1.0', 1111, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1225, N'B1', N'2.1.0', 1112, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1226, N'B2', N'2.1.0', 1112, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1227, N'Foo', N'1.1.0', 1113, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1228, N'Bar', N'2.1.0', 1113, 0)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1229, N'Foo', N'1.1.0', 1114, 1)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1230, N'Bar', N'2.1.0', 1114, 1)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1231, N'Foo', N'1.1.0', 1115, 1)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1232, N'Bar', N'2.1.0', 1115, 1)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1233, N'Foo', N'1.1.0', 1116, 1)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1234, N'Bar', N'2.1.0', 1116, 1)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1235, N'Foo', N'1.1.0', 1117, 1)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1236, N'Bar', N'2.1.0', 1117, 1)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1237, N'Microsoft.DotNet.Arcade.Sdk', N'2.1.0', 1118, 1)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1238, N'Microsoft.DotNet.Arcade.Sdk', N'2.1.0', 1119, 1)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1239, N'Microsoft.DotNet.Arcade.Sdk', N'2.1.0', 1120, 1)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1240, N'Microsoft.DotNet.Arcade.Sdk', N'2.1.0', 1121, 1)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1241, N'Microsoft.DotNet.Arcade.Sdk', N'2.1.0', 1122, 1)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1242, N'Foo', N'1.1.0', 1123, 1)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1243, N'Bar', N'2.1.0', 1123, 1)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1244, N'Foo', N'1.1.0', 1124, 1)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1245, N'Bar', N'2.1.0', 1124, 1)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1246, N'Foo', N'1.1.0', 1125, 1)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1247, N'Bar', N'2.1.0', 1125, 1)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1248, N'Foo', N'1.1.0', 1126, 1)
INSERT [dbo].[Assets] ([Id], [Name], [Version], [BuildId], [NonShipping]) VALUES (1249, N'Bar', N'2.1.0', 1126, 1)
SET IDENTITY_INSERT [dbo].[Assets] OFF
GO
INSERT [dbo].[BuildChannels] ([BuildId], [ChannelId], [DateTimeAdded]) VALUES (1101, 1062, CAST(N'2023-06-12T14:24:33.7065079+00:00' AS DateTimeOffset))
INSERT [dbo].[BuildChannels] ([BuildId], [ChannelId], [DateTimeAdded]) VALUES (1102, 1062, CAST(N'2023-06-12T14:24:36.5699734+00:00' AS DateTimeOffset))
INSERT [dbo].[BuildChannels] ([BuildId], [ChannelId], [DateTimeAdded]) VALUES (1103, 1062, CAST(N'2023-06-12T14:24:39.4148002+00:00' AS DateTimeOffset))
INSERT [dbo].[BuildChannels] ([BuildId], [ChannelId], [DateTimeAdded]) VALUES (1104, 1062, CAST(N'2023-06-12T14:24:42.2214571+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[BuildDependencies] ([BuildId], [DependentBuildId], [IsProduct], [TimeToInclusionInMinutes]) VALUES (1103, 1101, 1, 0.092989618333333329)
INSERT [dbo].[BuildDependencies] ([BuildId], [DependentBuildId], [IsProduct], [TimeToInclusionInMinutes]) VALUES (1103, 1102, 1, 0.046716521666666663)
INSERT [dbo].[BuildDependencies] ([BuildId], [DependentBuildId], [IsProduct], [TimeToInclusionInMinutes]) VALUES (1104, 1101, 1, 0.092989618333333329)
INSERT [dbo].[BuildDependencies] ([BuildId], [DependentBuildId], [IsProduct], [TimeToInclusionInMinutes]) VALUES (1104, 1102, 1, 0.046716521666666663)
GO
SET IDENTITY_INSERT [dbo].[Builds] ON 

INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-01T15:29:04.3419103+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (2, N'8460158878d4b7568f55d27960d4453877523ea6', 144618, 6, N'dnceng', N'internal', N'987654', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-01T15:29:07.5319367+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (3, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-01T15:30:07.8245485+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (4, N'8460158878d4b7568f55d27960d4453877523ea6', 144618, 6, N'dnceng', N'internal', N'987654', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-01T15:30:10.5267467+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (5, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-01T15:32:19.9786165+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (6, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-01T15:33:16.5977934+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (7, N'8460158878d4b7568f55d27960d4453877523ea6', 144618, 6, N'dnceng', N'internal', N'987654', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-01T15:33:19.7946817+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (8, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-01T15:34:22.4811479+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (9, N'8460158878d4b7568f55d27960d4453877523ea6', 144618, 6, N'dnceng', N'internal', N'987654', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-01T15:34:25.2675697+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (10, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-01T15:38:21.0277526+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (11, N'8460158878d4b7568f55d27960d4453877523ea6', 144618, 6, N'dnceng', N'internal', N'987654', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-01T15:38:23.8467154+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (12, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-01T15:39:07.1879542+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (13, N'8460158878d4b7568f55d27960d4453877523ea6', 144618, 6, N'dnceng', N'internal', N'987654', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-01T15:39:09.9144632+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (14, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-01T15:50:24.4972343+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (15, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-01T15:53:45.7811150+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (16, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-01T15:54:31.9342101+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (17, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-01T16:08:12.6609599+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (18, N'8460158878d4b7568f55d27960d4453877523ea6', 144618, 6, N'dnceng', N'internal', N'987654', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-01T16:08:15.7926096+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (19, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-01T16:09:16.1117210+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (20, N'8460158878d4b7568f55d27960d4453877523ea6', 144618, 6, N'dnceng', N'internal', N'987654', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-01T16:09:19.2812123+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (21, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-01T16:13:08.2472791+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (22, N'8460158878d4b7568f55d27960d4453877523ea6', 144618, 6, N'dnceng', N'internal', N'987654', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-01T16:13:11.3483868+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (23, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-01T18:51:31.6388315+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (24, N'8460158878d4b7568f55d27960d4453877523ea6', 144618, 6, N'dnceng', N'internal', N'987654', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-01T18:51:34.5828535+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (25, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-01T18:52:19.7644704+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (26, N'8460158878d4b7568f55d27960d4453877523ea6', 144618, 6, N'dnceng', N'internal', N'987654', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-01T18:52:22.3270435+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1023, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-02T09:51:58.7447280+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1024, N'8460158878d4b7568f55d27960d4453877523ea6', 144618, 6, N'dnceng', N'internal', N'987654', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-02T09:52:01.6945579+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1025, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-02T09:52:51.3086465+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1026, N'8460158878d4b7568f55d27960d4453877523ea6', 144618, 6, N'dnceng', N'internal', N'987654', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-02T09:52:54.7354830+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1027, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-02T10:16:41.6111902+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1028, N'8460158878d4b7568f55d27960d4453877523ea6', 144618, 6, N'dnceng', N'internal', N'987654', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-02T10:16:44.3184747+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1029, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-02T10:22:33.1356556+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1030, N'8460158878d4b7568f55d27960d4453877523ea6', 144618, 6, N'dnceng', N'internal', N'987654', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-02T10:22:35.6652465+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1031, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-02T11:14:17.8915716+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1032, N'8460158878d4b7568f55d27960d4453877523ea6', 144618, 6, N'dnceng', N'internal', N'987654', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-02T11:14:20.6576090+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1033, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-02T11:58:42.0816364+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1034, N'8460158878d4b7568f55d27960d4453877523ea6', 144618, 6, N'dnceng', N'internal', N'987654', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-02T11:58:45.2292550+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1035, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-02T12:22:54.6381198+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1036, N'8460158878d4b7568f55d27960d4453877523ea6', 144618, 6, N'dnceng', N'internal', N'987654', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-02T12:22:58.0811194+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1037, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-02T12:28:15.8035288+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1038, N'8460158878d4b7568f55d27960d4453877523ea6', 144618, 6, N'dnceng', N'internal', N'987654', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-02T12:28:18.3925095+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1039, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-02T12:44:53.5270489+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1040, N'8460158878d4b7568f55d27960d4453877523ea6', 144618, 6, N'dnceng', N'internal', N'987654', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-02T12:44:56.2271295+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1041, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-02T12:51:15.0548306+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1042, N'8460158878d4b7568f55d27960d4453877523ea6', 144618, 6, N'dnceng', N'internal', N'987654', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-02T12:51:18.0303152+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1043, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-02T13:09:36.7785941+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1044, N'8460158878d4b7568f55d27960d4453877523ea6', 144618, 6, N'dnceng', N'internal', N'987654', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-02T13:09:40.2255489+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1045, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-02T14:38:52.9087100+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1046, N'8460158878d4b7568f55d27960d4453877523ea6', 144618, 6, N'dnceng', N'internal', N'987654', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-02T14:38:56.0274340+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1047, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-02T14:48:15.1541655+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1048, N'8460158878d4b7568f55d27960d4453877523ea6', 144618, 6, N'dnceng', N'internal', N'987654', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-02T14:48:18.3723874+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1049, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-02T14:56:31.1421278+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1050, N'8460158878d4b7568f55d27960d4453877523ea6', 144618, 6, N'dnceng', N'internal', N'987654', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-02T14:56:33.9571793+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1051, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-02T15:14:51.8118816+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1052, N'8460158878d4b7568f55d27960d4453877523ea6', 144618, 6, N'dnceng', N'internal', N'987654', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-02T15:14:54.6597987+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1053, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-12T08:03:59.7792815+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1054, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test3', N'master', N'https://github.com/maestro-auth-test/maestro-test3', N'master', CAST(N'2023-06-12T08:04:13.1114308+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1055, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-12T08:06:11.0571956+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1056, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-12T08:06:46.5612576+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1057, N'8460158878d4b7568f55d27960d4453877523ea6', 144618, 6, N'dnceng', N'internal', N'987654', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-12T08:06:49.7795431+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1058, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-12T08:08:37.6988772+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1059, N'8460158878d4b7568f55d27960d4453877523ea6', 144618, 6, N'dnceng', N'internal', N'987654', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-12T08:08:40.7638912+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1060, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-12T08:09:14.0783609+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1061, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-12T08:28:07.6326256+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1062, N'8460158878d4b7568f55d27960d4453877523ea6', 144618, 6, N'dnceng', N'internal', N'987654', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-12T08:29:30.7878416+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1063, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-12T08:47:01.2061095+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1064, N'8460158878d4b7568f55d27960d4453877523ea6', 144618, 6, N'dnceng', N'internal', N'987654', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-12T08:47:03.9793138+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1065, N'0b36b99e29b1751403e23cfad0a7dff585818051', 144618, 6, N'dnceng', N'internal', N'1164818285', N'https://github.com/maestro-auth-test/maestro-test1', N'dependencyflow-tests', N'https://github.com/maestro-auth-test/maestro-test1', N'dependencyflow-tests', CAST(N'2023-06-12T09:11:27.5326217+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1066, N'0b36b99e29b1751403e23cfad0a7dff585818051', 144618, 6, N'dnceng', N'internal', N'440679131', N'https://github.com/maestro-auth-test/maestro-test1', N'dependencyflow-tests', N'https://github.com/maestro-auth-test/maestro-test1', N'dependencyflow-tests', CAST(N'2023-06-12T09:18:04.9356370+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1067, N'0b36b99e29b1751403e23cfad0a7dff585818051', 144618, 6, N'dnceng', N'internal', N'1339769721', N'https://github.com/maestro-auth-test/maestro-test1', N'dependencyflow-tests', N'https://github.com/maestro-auth-test/maestro-test1', N'dependencyflow-tests', CAST(N'2023-06-12T09:24:42.8867030+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1068, N'0b36b99e29b1751403e23cfad0a7dff585818051', 144618, 6, N'dnceng', N'internal', N'1731640618', N'https://github.com/maestro-auth-test/maestro-test1', N'dependencyflow-tests', N'https://github.com/maestro-auth-test/maestro-test1', N'dependencyflow-tests', CAST(N'2023-06-12T09:31:18.9929285+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1069, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-12T09:45:06.1506876+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1070, N'8460158878d4b7568f55d27960d4453877523ea6', 144618, 6, N'dnceng', N'internal', N'987654', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-12T09:45:09.0514059+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1071, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-12T10:37:49.5736812+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1072, N'8460158878d4b7568f55d27960d4453877523ea6', 144618, 6, N'dnceng', N'internal', N'987654', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-12T10:37:52.3089138+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1073, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-12T11:12:19.2881066+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1074, N'8460158878d4b7568f55d27960d4453877523ea6', 144618, 6, N'dnceng', N'internal', N'987654', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-12T11:12:22.6490136+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1075, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-12T11:30:13.9442248+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1076, N'8460158878d4b7568f55d27960d4453877523ea6', 144618, 6, N'dnceng', N'internal', N'987654', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-12T11:30:16.6449295+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1077, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-12T11:46:49.8410515+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1078, N'8460158878d4b7568f55d27960d4453877523ea6', 144618, 6, N'dnceng', N'internal', N'987654', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-12T11:46:52.7871010+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1079, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-12T12:18:39.5347581+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1080, N'8460158878d4b7568f55d27960d4453877523ea6', 144618, 6, N'dnceng', N'internal', N'987654', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-12T12:18:42.5563695+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1081, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-12T12:38:48.0650957+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1082, N'8460158878d4b7568f55d27960d4453877523ea6', 144618, 6, N'dnceng', N'internal', N'987654', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-12T12:38:50.5918964+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1083, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-12T12:55:20.9052879+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1084, N'8460158878d4b7568f55d27960d4453877523ea6', 144618, 6, N'dnceng', N'internal', N'987654', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-12T12:55:23.7130217+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1085, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-12T13:04:38.6358752+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1086, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test3', N'master', N'https://github.com/maestro-auth-test/maestro-test3', N'master', CAST(N'2023-06-12T13:04:42.0406102+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1087, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-12T13:06:22.6350276+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1088, N'8460158878d4b7568f55d27960d4453877523ea6', 144618, 6, N'dnceng', N'internal', N'987654', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-12T13:07:44.7416445+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1089, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-12T13:09:20.6704167+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1090, N'8460158878d4b7568f55d27960d4453877523ea6', 144618, 6, N'dnceng', N'internal', N'987654', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-12T13:09:23.3412923+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1091, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-12T13:10:57.4785681+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1092, N'8460158878d4b7568f55d27960d4453877523ea6', 144618, 6, N'dnceng', N'internal', N'987654', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-12T13:10:59.8865340+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1093, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-12T13:18:45.3905843+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1094, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://dev.azure.com/dnceng/internal/_git/maestro-test1', N'master', N'https://dev.azure.com/dnceng/internal/_git/maestro-test1', N'master', CAST(N'2023-06-12T14:06:50.6884826+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1095, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://dev.azure.com/dnceng/internal/_git/maestro-test3', N'master', N'https://dev.azure.com/dnceng/internal/_git/maestro-test3', N'master', CAST(N'2023-06-12T14:06:54.5225563+00:00' AS DateTimeOffset), 0, 0)
GO
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1096, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://dev.azure.com/dnceng/internal/_git/maestro-test1', N'master', N'https://dev.azure.com/dnceng/internal/_git/maestro-test1', N'master', CAST(N'2023-06-12T14:08:45.9709740+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1097, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://dev.azure.com/dnceng/internal/_git/maestro-test1', N'master', N'https://dev.azure.com/dnceng/internal/_git/maestro-test1', N'master', CAST(N'2023-06-12T14:10:29.8731240+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1098, N'8460158878d4b7568f55d27960d4453877523ea6', 144618, 6, N'dnceng', N'internal', N'987654', N'https://dev.azure.com/dnceng/internal/_git/maestro-test1', N'master', N'https://dev.azure.com/dnceng/internal/_git/maestro-test1', N'master', CAST(N'2023-06-12T14:11:51.9015038+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1099, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://dev.azure.com/dnceng/internal/_git/maestro-test1', N'master', N'https://dev.azure.com/dnceng/internal/_git/maestro-test1', N'master', CAST(N'2023-06-12T14:14:28.0147579+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1100, N'123456', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-12T14:15:57.4039024+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1101, N'SourceCommitVar', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test1', N'DependenciesSourceBranch_DESKTOP-S9KU8GR', N'https://github.com/maestro-auth-test/maestro-test1', N'DependenciesSourceBranch_DESKTOP-S9KU8GR', CAST(N'2023-06-12T14:24:31.7164507+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1102, N'SourceCommitVar', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test3', N'DependenciesSourceBranch_DESKTOP-S9KU8GR', N'https://github.com/maestro-auth-test/maestro-test3', N'DependenciesSourceBranch_DESKTOP-S9KU8GR', CAST(N'2023-06-12T14:24:34.4928365+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1103, N'TargetCommitVar', 144618, 6, N'dnceng', N'internal', N'098765', N'https://github.com/maestro-auth-test/maestro-test2', N'DependenciesTargetBranch_DESKTOP-S9KU8GR', N'https://github.com/maestro-auth-test/maestro-test2', N'DependenciesTargetBranch_DESKTOP-S9KU8GR', CAST(N'2023-06-12T14:24:37.2958278+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1104, N'TargetCommitVar', 144618, 6, N'dnceng', N'internal', N'987654', N'https://github.com/maestro-auth-test/maestro-test2', N'DependenciesTargetBranch_DESKTOP-S9KU8GR', N'https://github.com/maestro-auth-test/maestro-test2', N'DependenciesTargetBranch_DESKTOP-S9KU8GR', CAST(N'2023-06-12T14:24:40.1482650+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1105, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-12T14:25:00.0423287+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1106, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test3', N'master', N'https://github.com/maestro-auth-test/maestro-test3', N'master', CAST(N'2023-06-12T14:25:04.2867949+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1107, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-12T14:26:47.1642925+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1108, N'8460158878d4b7568f55d27960d4453877523ea6', 144618, 6, N'dnceng', N'internal', N'987654', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-12T14:28:02.8219791+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1109, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-12T14:29:32.8301223+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1110, N'8460158878d4b7568f55d27960d4453877523ea6', 144618, 6, N'dnceng', N'internal', N'987654', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-12T14:29:35.4799044+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1111, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test2', N'master', N'https://github.com/maestro-auth-test/maestro-test2', N'master', CAST(N'2023-06-12T14:31:09.8237248+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1112, N'8460158878d4b7568f55d27960d4453877523ea6', 144618, 6, N'dnceng', N'internal', N'987654', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-12T14:31:12.3249078+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1113, N'cc1a27107a1f4c4bc5e2f796c5ef346f60abb404', 144618, 6, N'dnceng', N'internal', N'654321', N'https://github.com/maestro-auth-test/maestro-test1', N'master', N'https://github.com/maestro-auth-test/maestro-test1', N'master', CAST(N'2023-06-12T14:39:00.6705581+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1114, N'0b36b99e29b1751403e23cfad0a7dff585818051', 144618, 6, N'dnceng', N'internal', N'313550017', N'https://github.com/maestro-auth-test/maestro-test1', N'dependencyflow-tests', N'https://github.com/maestro-auth-test/maestro-test1', N'dependencyflow-tests', CAST(N'2023-06-12T14:45:35.9908793+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1115, N'0b36b99e29b1751403e23cfad0a7dff585818051', 144618, 6, N'dnceng', N'internal', N'763035125', N'https://github.com/maestro-auth-test/maestro-test1', N'dependencyflow-tests', N'https://github.com/maestro-auth-test/maestro-test1', N'dependencyflow-tests', CAST(N'2023-06-12T14:52:08.7992209+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1116, N'0b36b99e29b1751403e23cfad0a7dff585818051', 144618, 6, N'dnceng', N'internal', N'444163628', N'https://github.com/maestro-auth-test/maestro-test1', N'dependencyflow-tests', N'https://github.com/maestro-auth-test/maestro-test1', N'dependencyflow-tests', CAST(N'2023-06-12T14:58:44.0691483+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1117, N'0b36b99e29b1751403e23cfad0a7dff585818051', 144618, 6, N'dnceng', N'internal', N'1843991835', N'https://github.com/maestro-auth-test/maestro-test1', N'dependencyflow-tests', N'https://github.com/maestro-auth-test/maestro-test1', N'dependencyflow-tests', CAST(N'2023-06-12T15:05:16.9606544+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1118, N'0b36b99e29b1751403e23cfad0a7dff585818051', 144618, 6, N'dnceng', N'internal', N'1098945818', N'https://github.com/dotnet/arcade', N'dependencyflow-tests', N'https://github.com/dotnet/arcade', N'dependencyflow-tests', CAST(N'2023-06-12T15:12:01.7895119+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1119, N'0b36b99e29b1751403e23cfad0a7dff585818051', 144618, 6, N'dnceng', N'internal', N'804800999', N'https://github.com/dotnet/arcade', N'dependencyflow-tests', N'https://github.com/dotnet/arcade', N'dependencyflow-tests', CAST(N'2023-06-12T15:25:30.0936507+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1120, N'0b36b99e29b1751403e23cfad0a7dff585818051', 144618, 6, N'dnceng', N'internal', N'356486611', N'https://github.com/dotnet/arcade', N'dependencyflow-tests', N'https://github.com/dotnet/arcade', N'dependencyflow-tests', CAST(N'2023-06-13T07:58:46.3273870+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1121, N'0b36b99e29b1751403e23cfad0a7dff585818051', 144618, 6, N'dnceng', N'internal', N'231395560', N'https://github.com/dotnet/arcade', N'dependencyflow-tests', N'https://github.com/dotnet/arcade', N'dependencyflow-tests', CAST(N'2023-06-13T08:44:42.4993632+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1122, N'0b36b99e29b1751403e23cfad0a7dff585818051', 144618, 6, N'dnceng', N'internal', N'1775669499', N'https://github.com/dotnet/arcade', N'dependencyflow-tests', N'https://github.com/dotnet/arcade', N'dependencyflow-tests', CAST(N'2023-06-13T09:28:26.9300304+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1123, N'0b36b99e29b1751403e23cfad0a7dff585818051', 144618, 6, N'dnceng', N'internal', N'1057751916', N'https://github.com/maestro-auth-test/maestro-test1', N'dependencyflow-tests', N'https://github.com/maestro-auth-test/maestro-test1', N'dependencyflow-tests', CAST(N'2023-06-13T13:38:08.3054435+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1124, N'0b36b99e29b1751403e23cfad0a7dff585818051', 144618, 6, N'dnceng', N'internal', N'1621086547', N'https://github.com/maestro-auth-test/maestro-test1', N'dependencyflow-tests', N'https://github.com/maestro-auth-test/maestro-test1', N'dependencyflow-tests', CAST(N'2023-06-13T13:44:46.2224651+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1125, N'0b36b99e29b1751403e23cfad0a7dff585818051', 144618, 6, N'dnceng', N'internal', N'1476843335', N'https://github.com/maestro-auth-test/maestro-test1', N'dependencyflow-tests', N'https://github.com/maestro-auth-test/maestro-test1', N'dependencyflow-tests', CAST(N'2023-06-13T13:51:24.6033699+00:00' AS DateTimeOffset), 0, 0)
INSERT [dbo].[Builds] ([Id], [Commit], [AzureDevOpsBuildId], [AzureDevOpsBuildDefinitionId], [AzureDevOpsAccount], [AzureDevOpsProject], [AzureDevOpsBuildNumber], [AzureDevOpsRepository], [AzureDevOpsBranch], [GitHubRepository], [GitHubBranch], [DateProduced], [Released], [Stable]) VALUES (1126, N'0b36b99e29b1751403e23cfad0a7dff585818051', 144618, 6, N'dnceng', N'internal', N'94470492', N'https://github.com/maestro-auth-test/maestro-test1', N'dependencyflow-tests', N'https://github.com/maestro-auth-test/maestro-test1', N'dependencyflow-tests', CAST(N'2023-06-13T13:58:01.4380515+00:00' AS DateTimeOffset), 0, 0)
SET IDENTITY_INSERT [dbo].[Builds] OFF
GO
SET IDENTITY_INSERT [dbo].[Channels] ON 

INSERT [dbo].[Channels] ([Id], [Name], [Classification]) VALUES (1062, N'TestChannel_Dependencies_DESKTOP-S9KU8GR', N'test')
INSERT [dbo].[Channels] ([Id], [Name], [Classification]) VALUES (1, N'channel', N'product')
SET IDENTITY_INSERT [dbo].[Channels] OFF
GO
SET IDENTITY_INSERT [dbo].[DependencyFlowEvents] ON 

INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (1, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1, 2, N'Fired', N'New', N'PR', CAST(N'2023-06-01T15:29:16.7434625+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (2, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 2, 4, N'Fired', N'New', N'PR', CAST(N'2023-06-01T15:30:24.9263518+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (3, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 5, 9, N'Fired', N'New', N'PR', CAST(N'2023-06-01T15:34:37.9484513+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (4, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 7, 13, N'Fired', N'New', N'PR', CAST(N'2023-06-01T15:39:22.8711278+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (5, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 8, 14, N'Fired', N'New', N'PR', CAST(N'2023-06-01T15:50:38.0163004+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (6, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 8, 14, N'Created', N'New', N'PR', CAST(N'2023-06-01T15:50:54.3914337+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18504')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (7, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 8, 14, N'Fired', N'New', N'PR', CAST(N'2023-06-01T15:50:57.6872565+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (8, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 8, 14, N'Completed', N'AutomaticallyMerged', N'PR', CAST(N'2023-06-01T15:51:04.5250366+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18504')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (9, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 10, 16, N'Fired', N'New', N'PR', CAST(N'2023-06-01T15:54:45.1053963+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 10, 16, N'Created', N'New', N'PR', CAST(N'2023-06-01T15:54:55.0134184+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18505')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (11, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 10, 16, N'Completed', N'AutomaticallyMerged', N'PR', CAST(N'2023-06-01T16:00:01.3282279+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18505')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (12, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 12, 19, N'Fired', N'New', N'PR', CAST(N'2023-06-01T16:09:33.7988066+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (13, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 12, 19, N'Created', N'New', N'PR', CAST(N'2023-06-01T16:09:45.0478926+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2102')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (14, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 13, 21, N'Fired', N'New', N'PR', CAST(N'2023-06-01T16:13:25.7170110+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (15, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 13, 21, N'Created', N'New', N'PR', CAST(N'2023-06-01T16:13:35.9106949+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2103')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (16, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 13, 21, N'Fired', N'New', N'PR', CAST(N'2023-06-01T16:15:43.2286044+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (17, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 13, 21, N'Completed', N'ManuallyMergedNoPolicies', N'PR', CAST(N'2023-06-01T16:15:44.0915062+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2103')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (18, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 15, 26, N'Fired', N'New', N'PR', CAST(N'2023-06-01T18:52:59.6056732+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10018, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1015, 1026, N'Fired', N'New', N'PR', CAST(N'2023-06-02T09:53:13.0805852+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10019, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1015, 1026, N'Created', N'New', N'PR', CAST(N'2023-06-02T09:53:56.4370462+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2105')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10020, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1015, 1026, N'Fired', N'New', N'PR', CAST(N'2023-06-02T09:56:22.7085672+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10021, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1015, 1026, N'Completed', N'ManuallyMergedNoPolicies', N'PR', CAST(N'2023-06-02T09:56:23.5394761+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2105')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10022, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1016, 1027, N'Fired', N'New', N'PR', CAST(N'2023-06-02T10:16:56.6021046+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10023, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1016, 1027, N'Created', N'New', N'PR', CAST(N'2023-06-02T10:17:17.8452308+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2106')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10024, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1016, 1027, N'Fired', N'New', N'PR', CAST(N'2023-06-02T10:19:14.3597880+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10025, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1016, 1027, N'Completed', N'ManuallyMergedNoPolicies', N'PR', CAST(N'2023-06-02T10:19:15.1429725+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2106')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10026, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1017, 1029, N'Fired', N'New', N'PR', CAST(N'2023-06-02T10:22:47.9271748+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10027, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1017, 1029, N'Created', N'New', N'PR', CAST(N'2023-06-02T10:23:27.5045965+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2107')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10028, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1017, 1029, N'Fired', N'New', N'PR', CAST(N'2023-06-02T10:25:01.6668128+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10029, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1017, 1029, N'Completed', N'ManuallyMergedNoPolicies', N'PR', CAST(N'2023-06-02T10:25:02.4981125+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2107')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10030, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1018, 1031, N'Fired', N'New', N'PR', CAST(N'2023-06-02T11:14:33.5713467+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10031, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1018, 1031, N'Created', N'New', N'PR', CAST(N'2023-06-02T11:15:38.0769397+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2108')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10032, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1018, 1031, N'Fired', N'New', N'PR', CAST(N'2023-06-02T11:17:50.0015981+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10033, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1018, 1031, N'Completed', N'ManuallyMergedNoPolicies', N'PR', CAST(N'2023-06-02T11:17:50.8270873+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2108')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10034, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1019, 1033, N'Fired', N'New', N'PR', CAST(N'2023-06-02T11:59:04.7708463+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10035, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1019, 1033, N'Created', N'New', N'PR', CAST(N'2023-06-02T11:59:24.3918416+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2109')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10036, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1019, 1033, N'Fired', N'New', N'PR', CAST(N'2023-06-02T12:01:21.8702109+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10037, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1019, 1033, N'Completed', N'ManuallyMergedNoPolicies', N'PR', CAST(N'2023-06-02T12:01:22.7310892+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2109')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10038, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1020, 1035, N'Fired', N'New', N'PR', CAST(N'2023-06-02T12:23:16.9019783+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10039, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1020, 1035, N'Created', N'New', N'PR', CAST(N'2023-06-02T12:23:37.8091729+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2110')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10040, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1020, 1035, N'Fired', N'New', N'PR', CAST(N'2023-06-02T12:25:25.7180821+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10041, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1020, 1035, N'Completed', N'ManuallyMergedNoPolicies', N'PR', CAST(N'2023-06-02T12:25:26.6173615+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2110')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10042, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1021, 1037, N'Fired', N'New', N'PR', CAST(N'2023-06-02T12:28:32.5193926+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10043, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1021, 1037, N'Created', N'New', N'PR', CAST(N'2023-06-02T12:28:46.5339055+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2111')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10044, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1021, 1037, N'Fired', N'New', N'PR', CAST(N'2023-06-02T12:30:48.2346113+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10045, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1021, 1037, N'Completed', N'ManuallyMergedNoPolicies', N'PR', CAST(N'2023-06-02T12:30:49.1709438+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2111')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10046, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1022, 1039, N'Fired', N'New', N'PR', CAST(N'2023-06-02T12:45:14.5461305+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10047, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1022, 1039, N'Created', N'New', N'PR', CAST(N'2023-06-02T12:46:02.4054386+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2112')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10048, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1022, 1039, N'Fired', N'New', N'PR', CAST(N'2023-06-02T12:47:23.0920770+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10049, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1022, 1039, N'Completed', N'ManuallyMergedNoPolicies', N'PR', CAST(N'2023-06-02T12:47:23.9167754+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2112')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10050, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1023, 1041, N'Fired', N'New', N'PR', CAST(N'2023-06-02T12:51:30.0342836+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10051, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1023, 1041, N'Created', N'New', N'PR', CAST(N'2023-06-02T12:51:44.9107722+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2113')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10052, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1023, 1041, N'Fired', N'New', N'PR', CAST(N'2023-06-02T12:53:46.1792067+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10053, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1023, 1041, N'Completed', N'ManuallyMergedNoPolicies', N'PR', CAST(N'2023-06-02T12:53:47.0556142+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2113')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10054, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1024, 1043, N'Fired', N'New', N'PR', CAST(N'2023-06-02T13:09:59.1867134+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10055, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1024, 1043, N'Created', N'New', N'PR', CAST(N'2023-06-02T13:10:19.3659143+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2114')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10056, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1024, 1043, N'Fired', N'New', N'PR', CAST(N'2023-06-02T13:12:07.8651504+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10057, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1024, 1043, N'Completed', N'ManuallyMergedNoPolicies', N'PR', CAST(N'2023-06-02T13:12:08.6681051+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2114')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10058, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1025, 1045, N'Fired', N'New', N'PR', CAST(N'2023-06-02T14:39:05.4085353+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10059, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1025, 1045, N'Created', N'New', N'PR', CAST(N'2023-06-02T14:39:23.4427191+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2116')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10060, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1025, 1045, N'Fired', N'New', N'PR', CAST(N'2023-06-02T14:39:26.5405696+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10061, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1025, 1045, N'Fired', N'New', N'PR', CAST(N'2023-06-02T14:42:25.6875254+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10062, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1025, 1045, N'Completed', N'ManuallyMergedPendingPolicies', N'PR', CAST(N'2023-06-02T14:42:26.5325026+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2116')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10063, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1026, 1047, N'Fired', N'New', N'PR', CAST(N'2023-06-02T14:48:30.6394560+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10064, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1026, 1047, N'Created', N'New', N'PR', CAST(N'2023-06-02T14:48:40.5031006+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2118')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10065, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1026, 1047, N'Completed', N'ManuallyMergedNoPolicies', N'PR', CAST(N'2023-06-02T14:53:41.2783158+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2118')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10066, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1026, 1047, N'Fired', N'New', N'PR', CAST(N'2023-06-02T14:53:47.9874197+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10067, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1027, 1049, N'Fired', N'New', N'PR', CAST(N'2023-06-02T14:56:45.6091825+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10068, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1027, 1049, N'Created', N'New', N'PR', CAST(N'2023-06-02T14:56:55.4382124+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2120')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10069, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1028, 1051, N'Fired', N'New', N'PR', CAST(N'2023-06-02T15:15:07.0050200+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10070, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1028, 1051, N'Created', N'New', N'PR', CAST(N'2023-06-02T15:15:18.7403040+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2121')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10071, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1028, 1051, N'Fired', N'New', N'PR', CAST(N'2023-06-02T15:17:22.7201775+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10072, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1028, 1051, N'Completed', N'ManuallyMergedNoPolicies', N'PR', CAST(N'2023-06-02T15:17:23.5537159+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2121')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10073, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1029, 1053, N'Fired', N'New', N'PR', CAST(N'2023-06-12T08:04:39.8797277+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10074, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1029, 1053, N'Created', N'New', N'PR', CAST(N'2023-06-12T08:05:07.3079999+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18530')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10075, N'https://github.com/maestro-auth-test/maestro-test3', N'https://github.com/maestro-auth-test/maestro-test2', 1029, 1054, N'Fired', N'New', N'PR', CAST(N'2023-06-12T08:05:07.8422075+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10076, N'https://github.com/maestro-auth-test/maestro-test3', N'https://github.com/maestro-auth-test/maestro-test2', 1029, 1054, N'Created', N'New', N'PR', CAST(N'2023-06-12T08:05:11.7034474+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18530')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10077, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1031, 1056, N'Fired', N'New', N'PR', CAST(N'2023-06-12T08:07:06.8013722+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10078, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1031, 1056, N'Created', N'New', N'PR', CAST(N'2023-06-12T08:07:19.0662206+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2126')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10079, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1033, 1060, N'Fired', N'New', N'PR', CAST(N'2023-06-12T08:09:27.8802262+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10080, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1033, 1060, N'Created', N'New', N'PR', CAST(N'2023-06-12T08:09:38.4918404+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18531')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10081, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1033, 1060, N'Completed', N'AutomaticallyMerged', N'PR', CAST(N'2023-06-12T08:14:45.2307050+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18531')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10082, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1034, 1061, N'Fired', N'New', N'PR', CAST(N'2023-06-12T08:28:25.6844074+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10083, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1034, 1061, N'Created', N'New', N'PR', CAST(N'2023-06-12T08:28:35.5267730+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18532')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10084, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1034, 1061, N'Fired', N'New', N'PR', CAST(N'2023-06-12T08:29:31.4857546+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10085, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1034, 1061, N'Updated', N'FailedUpdateNoPolicies', N'PR', CAST(N'2023-06-12T08:29:33.7947871+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18532')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10086, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1034, 1061, N'Created', N'New', N'PR', CAST(N'2023-06-12T08:29:33.8711838+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18532')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10087, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1034, 1061, N'Fired', N'New', N'PR', CAST(N'2023-06-12T08:30:37.8699900+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10088, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1034, 1061, N'Updated', N'FailedUpdateNoPolicies', N'PR', CAST(N'2023-06-12T08:30:40.2324083+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18532')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10089, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1034, 1061, N'Created', N'New', N'PR', CAST(N'2023-06-12T08:30:40.2993470+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18532')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10090, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1035, 1063, N'Fired', N'New', N'PR', CAST(N'2023-06-12T08:47:16.3444101+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10091, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1035, 1063, N'Created', N'New', N'PR', CAST(N'2023-06-12T08:47:28.2605231+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2127')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10092, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1036, 1065, N'Fired', N'New', N'PR', CAST(N'2023-06-12T09:11:39.3387253+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10093, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1036, 1065, N'Created', N'New', N'PR', CAST(N'2023-06-12T09:11:49.6618463+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18533')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10094, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1036, 1065, N'Completed', N'AutomaticallyMerged', N'PR', CAST(N'2023-06-12T09:16:56.1495978+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18533')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10095, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1037, 1066, N'Fired', N'New', N'PR', CAST(N'2023-06-12T09:18:14.5606185+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10096, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1037, 1066, N'Created', N'New', N'PR', CAST(N'2023-06-12T09:18:25.0406220+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18534')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10097, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1037, 1066, N'Completed', N'AutomaticallyMerged', N'PR', CAST(N'2023-06-12T09:23:30.7280421+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18534')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10098, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1038, 1067, N'Fired', N'New', N'PR', CAST(N'2023-06-12T09:24:53.6548966+00:00' AS DateTimeOffset), NULL)
GO
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10099, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1038, 1067, N'Created', N'New', N'PR', CAST(N'2023-06-12T09:25:04.5405123+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18535')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10100, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1039, 1068, N'Fired', N'New', N'PR', CAST(N'2023-06-12T09:31:31.4072841+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10101, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1039, 1068, N'Created', N'New', N'PR', CAST(N'2023-06-12T09:31:41.2364578+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18536')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10102, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1039, 1068, N'Completed', N'AutomaticallyMerged', N'PR', CAST(N'2023-06-12T09:36:47.1847476+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18536')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10103, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1040, 1069, N'Fired', N'New', N'PR', CAST(N'2023-06-12T09:45:21.1342330+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10104, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1040, 1069, N'Created', N'New', N'PR', CAST(N'2023-06-12T09:45:32.1492468+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2128')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10105, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1040, 1069, N'Fired', N'New', N'PR', CAST(N'2023-06-12T09:47:34.2397269+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10106, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1040, 1069, N'Completed', N'ManuallyMergedNoPolicies', N'PR', CAST(N'2023-06-12T09:47:35.1035470+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2128')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10107, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1041, 1071, N'Fired', N'New', N'PR', CAST(N'2023-06-12T10:38:01.1327853+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10108, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1041, 1071, N'Created', N'New', N'PR', CAST(N'2023-06-12T10:38:16.7269785+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2130')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10109, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1041, 1071, N'Fired', N'New', N'PR', CAST(N'2023-06-12T10:38:19.4462902+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10110, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1042, 1073, N'Fired', N'New', N'PR', CAST(N'2023-06-12T11:12:35.6239915+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10111, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1042, 1073, N'Created', N'New', N'PR', CAST(N'2023-06-12T11:12:47.3536473+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2131')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10112, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1043, 1075, N'Fired', N'New', N'PR', CAST(N'2023-06-12T11:30:28.8802297+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10113, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1043, 1075, N'Created', N'New', N'PR', CAST(N'2023-06-12T11:30:39.2362984+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2132')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10114, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1043, 1075, N'Completed', N'ManuallyClosedPendingPolicies', N'PR', CAST(N'2023-06-12T11:41:11.5116134+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2132')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10115, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1044, 1077, N'Fired', N'New', N'PR', CAST(N'2023-06-12T11:47:02.1172831+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10116, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1044, 1077, N'Created', N'New', N'PR', CAST(N'2023-06-12T11:47:18.8992757+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2133')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10117, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1044, 1077, N'Fired', N'New', N'PR', CAST(N'2023-06-12T11:47:22.1060910+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10118, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1044, 1077, N'Completed', N'ManuallyClosedPendingPolicies', N'PR', CAST(N'2023-06-12T12:02:56.6717933+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2133')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10119, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1045, 1079, N'Fired', N'New', N'PR', CAST(N'2023-06-12T12:18:48.1678580+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10120, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1045, 1079, N'Fired', N'New', N'PR', CAST(N'2023-06-12T12:18:59.0506066+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10121, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1045, 1079, N'Created', N'New', N'PR', CAST(N'2023-06-12T12:19:10.8472298+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2134')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10122, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1045, 1079, N'Completed', N'ManuallyClosedFailedPolicies', N'PR', CAST(N'2023-06-12T12:34:46.0076201+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2134')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10123, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1046, 1081, N'Fired', N'New', N'PR', CAST(N'2023-06-12T12:39:01.5850189+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10124, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1046, 1081, N'Created', N'New', N'PR', CAST(N'2023-06-12T12:39:13.1967383+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2135')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10125, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1049, 1083, N'Fired', N'New', N'PR', CAST(N'2023-06-12T12:55:35.1921292+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10126, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1049, 1083, N'Created', N'New', N'PR', CAST(N'2023-06-12T12:55:46.1677853+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2136')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10127, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1049, 1083, N'Completed', N'AutomaticallyMerged', N'PR', CAST(N'2023-06-12T13:00:51.6966857+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2136')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10128, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1049, 1083, N'Fired', N'New', N'PR', CAST(N'2023-06-12T13:01:49.1351991+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10129, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1050, 1085, N'Fired', N'New', N'PR', CAST(N'2023-06-12T13:04:55.8652719+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10130, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1050, 1085, N'Created', N'New', N'PR', CAST(N'2023-06-12T13:05:06.4496509+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18537')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10131, N'https://github.com/maestro-auth-test/maestro-test3', N'https://github.com/maestro-auth-test/maestro-test2', 1050, 1086, N'Fired', N'New', N'PR', CAST(N'2023-06-12T13:05:06.6637512+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10132, N'https://github.com/maestro-auth-test/maestro-test3', N'https://github.com/maestro-auth-test/maestro-test2', 1050, 1086, N'Created', N'New', N'PR', CAST(N'2023-06-12T13:05:09.2726370+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18537')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10133, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1051, 1087, N'Fired', N'New', N'PR', CAST(N'2023-06-12T13:06:37.8406228+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10134, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1051, 1087, N'Created', N'New', N'PR', CAST(N'2023-06-12T13:06:52.5651450+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18538')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10135, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1051, 1087, N'Fired', N'New', N'PR', CAST(N'2023-06-12T13:07:45.4250926+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10136, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1051, 1087, N'Updated', N'FailedUpdateNoPolicies', N'PR', CAST(N'2023-06-12T13:07:47.8207500+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18538')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10137, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1051, 1087, N'Created', N'New', N'PR', CAST(N'2023-06-12T13:07:47.8855237+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18538')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10138, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1051, 1087, N'Fired', N'New', N'PR', CAST(N'2023-06-12T13:08:57.4757749+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10139, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1051, 1087, N'Updated', N'FailedUpdateNoPolicies', N'PR', CAST(N'2023-06-12T13:09:00.3850189+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18538')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10140, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1051, 1087, N'Created', N'New', N'PR', CAST(N'2023-06-12T13:09:00.4533889+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18538')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10141, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1052, 1089, N'Fired', N'New', N'PR', CAST(N'2023-06-12T13:09:36.2479982+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10142, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1052, 1089, N'Created', N'New', N'PR', CAST(N'2023-06-12T13:09:46.6133198+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2138')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10143, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1053, 1091, N'Fired', N'New', N'PR', CAST(N'2023-06-12T13:11:10.1995811+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10144, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1053, 1091, N'Created', N'New', N'PR', CAST(N'2023-06-12T13:11:21.1160776+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2139')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10145, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1053, 1091, N'Completed', N'AutomaticallyMerged', N'PR', CAST(N'2023-06-12T13:16:26.1373158+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2139')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10146, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1053, 1091, N'Fired', N'New', N'PR', CAST(N'2023-06-12T13:17:23.8435074+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10147, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1054, 1093, N'Fired', N'New', N'PR', CAST(N'2023-06-12T13:18:56.6401759+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10148, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1054, 1093, N'Created', N'New', N'PR', CAST(N'2023-06-12T13:19:08.0503164+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18539')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10149, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1054, 1093, N'Completed', N'AutomaticallyMerged', N'PR', CAST(N'2023-06-12T13:24:14.6799900+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18539')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10150, N'https://dev.azure.com/dnceng/internal/_git/maestro-test1', N'https://dev.azure.com/dnceng/internal/_git/maestro-test2', 1055, 1094, N'Fired', N'New', N'PR', CAST(N'2023-06-12T14:07:15.5383081+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10151, N'https://dev.azure.com/dnceng/internal/_git/maestro-test1', N'https://dev.azure.com/dnceng/internal/_git/maestro-test2', 1055, 1094, N'Created', N'New', N'PR', CAST(N'2023-06-12T14:07:38.6079781+00:00' AS DateTimeOffset), N'https://dev.azure.com/dnceng/7ea9116e-9fac-403d-b258-b31fcf1bb293/_apis/git/repositories/e6f2a2fb-be51-4de9-b065-0f1430bc5f46/pullRequests/31802')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10152, N'https://dev.azure.com/dnceng/internal/_git/maestro-test3', N'https://dev.azure.com/dnceng/internal/_git/maestro-test2', 1055, 1095, N'Fired', N'New', N'PR', CAST(N'2023-06-12T14:07:38.8251248+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10153, N'https://dev.azure.com/dnceng/internal/_git/maestro-test3', N'https://dev.azure.com/dnceng/internal/_git/maestro-test2', 1055, 1095, N'Created', N'New', N'PR', CAST(N'2023-06-12T14:07:41.6881608+00:00' AS DateTimeOffset), N'https://dev.azure.com/dnceng/7ea9116e-9fac-403d-b258-b31fcf1bb293/_apis/git/repositories/e6f2a2fb-be51-4de9-b065-0f1430bc5f46/pullRequests/31802')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10154, N'https://dev.azure.com/dnceng/internal/_git/maestro-test1', N'https://dev.azure.com/dnceng/internal/_git/maestro-test2', 1056, 1096, N'Fired', N'New', N'PR', CAST(N'2023-06-12T14:09:04.5676537+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10155, N'https://dev.azure.com/dnceng/internal/_git/maestro-test1', N'https://dev.azure.com/dnceng/internal/_git/maestro-test2', 1056, 1096, N'Created', N'New', N'PR', CAST(N'2023-06-12T14:09:16.7998922+00:00' AS DateTimeOffset), N'https://dev.azure.com/dnceng/7ea9116e-9fac-403d-b258-b31fcf1bb293/_apis/git/repositories/e6f2a2fb-be51-4de9-b065-0f1430bc5f46/pullRequests/31803')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10156, N'https://dev.azure.com/dnceng/internal/_git/maestro-test1', N'https://dev.azure.com/dnceng/internal/_git/maestro-test2', 1057, 1097, N'Fired', N'New', N'PR', CAST(N'2023-06-12T14:10:45.3089030+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10157, N'https://dev.azure.com/dnceng/internal/_git/maestro-test1', N'https://dev.azure.com/dnceng/internal/_git/maestro-test2', 1057, 1097, N'Created', N'New', N'PR', CAST(N'2023-06-12T14:11:14.6412339+00:00' AS DateTimeOffset), N'https://dev.azure.com/dnceng/7ea9116e-9fac-403d-b258-b31fcf1bb293/_apis/git/repositories/e6f2a2fb-be51-4de9-b065-0f1430bc5f46/pullRequests/31804')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10158, N'https://dev.azure.com/dnceng/internal/_git/maestro-test1', N'https://dev.azure.com/dnceng/internal/_git/maestro-test2', 1057, 1097, N'Fired', N'New', N'PR', CAST(N'2023-06-12T14:11:52.9448958+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10159, N'https://dev.azure.com/dnceng/internal/_git/maestro-test1', N'https://dev.azure.com/dnceng/internal/_git/maestro-test2', 1057, 1097, N'Completed', N'ManuallyClosedNoPolicies', N'PR', CAST(N'2023-06-12T14:11:53.4079865+00:00' AS DateTimeOffset), N'https://dev.azure.com/dnceng/7ea9116e-9fac-403d-b258-b31fcf1bb293/_apis/git/repositories/e6f2a2fb-be51-4de9-b065-0f1430bc5f46/pullRequests/31804')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10160, N'https://dev.azure.com/dnceng/internal/_git/maestro-test1', N'https://dev.azure.com/dnceng/internal/_git/maestro-test2', 1057, 1097, N'Created', N'New', N'PR', CAST(N'2023-06-12T14:12:09.4059171+00:00' AS DateTimeOffset), N'https://dev.azure.com/dnceng/7ea9116e-9fac-403d-b258-b31fcf1bb293/_apis/git/repositories/e6f2a2fb-be51-4de9-b065-0f1430bc5f46/pullRequests/31805')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10161, N'https://dev.azure.com/dnceng/internal/_git/maestro-test1', N'https://dev.azure.com/dnceng/internal/_git/maestro-test2', 1057, 1097, N'Fired', N'New', N'PR', CAST(N'2023-06-12T14:13:01.4293451+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10162, N'https://dev.azure.com/dnceng/internal/_git/maestro-test1', N'https://dev.azure.com/dnceng/internal/_git/maestro-test2', 1057, 1097, N'Completed', N'ManuallyClosedNoPolicies', N'PR', CAST(N'2023-06-12T14:13:02.3011802+00:00' AS DateTimeOffset), N'https://dev.azure.com/dnceng/7ea9116e-9fac-403d-b258-b31fcf1bb293/_apis/git/repositories/e6f2a2fb-be51-4de9-b065-0f1430bc5f46/pullRequests/31805')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10163, N'https://dev.azure.com/dnceng/internal/_git/maestro-test1', N'https://dev.azure.com/dnceng/internal/_git/maestro-test2', 1057, 1097, N'Created', N'New', N'PR', CAST(N'2023-06-12T14:13:16.7925119+00:00' AS DateTimeOffset), N'https://dev.azure.com/dnceng/7ea9116e-9fac-403d-b258-b31fcf1bb293/_apis/git/repositories/e6f2a2fb-be51-4de9-b065-0f1430bc5f46/pullRequests/31806')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10164, N'https://dev.azure.com/dnceng/internal/_git/maestro-test1', N'https://dev.azure.com/dnceng/internal/_git/maestro-test2', 1058, 1099, N'Fired', N'New', N'PR', CAST(N'2023-06-12T14:14:41.5730299+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10165, N'https://dev.azure.com/dnceng/internal/_git/maestro-test1', N'https://dev.azure.com/dnceng/internal/_git/maestro-test2', 1058, 1099, N'Created', N'New', N'PR', CAST(N'2023-06-12T14:14:53.9558310+00:00' AS DateTimeOffset), N'https://dev.azure.com/dnceng/7ea9116e-9fac-403d-b258-b31fcf1bb293/_apis/git/repositories/e6f2a2fb-be51-4de9-b065-0f1430bc5f46/pullRequests/31807')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10166, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1063, 1105, N'Fired', N'New', N'PR', CAST(N'2023-06-12T14:25:20.5908771+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10167, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1063, 1105, N'Created', N'New', N'PR', CAST(N'2023-06-12T14:25:31.4735147+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18540')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10168, N'https://github.com/maestro-auth-test/maestro-test3', N'https://github.com/maestro-auth-test/maestro-test2', 1063, 1106, N'Fired', N'New', N'PR', CAST(N'2023-06-12T14:25:31.7572215+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10169, N'https://github.com/maestro-auth-test/maestro-test3', N'https://github.com/maestro-auth-test/maestro-test2', 1063, 1106, N'Created', N'New', N'PR', CAST(N'2023-06-12T14:25:34.2861566+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18540')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10170, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1064, 1107, N'Fired', N'New', N'PR', CAST(N'2023-06-12T14:26:57.9039312+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10171, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1064, 1107, N'Created', N'New', N'PR', CAST(N'2023-06-12T14:27:08.8642358+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18541')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10172, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1064, 1107, N'Fired', N'New', N'PR', CAST(N'2023-06-12T14:28:03.5358862+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10173, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1064, 1107, N'Updated', N'FailedUpdateNoPolicies', N'PR', CAST(N'2023-06-12T14:28:05.9770051+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18541')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10174, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1064, 1107, N'Created', N'New', N'PR', CAST(N'2023-06-12T14:28:06.0562296+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18541')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10175, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1064, 1107, N'Fired', N'New', N'PR', CAST(N'2023-06-12T14:29:09.8429374+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10176, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1064, 1107, N'Updated', N'FailedUpdateNoPolicies', N'PR', CAST(N'2023-06-12T14:29:12.1822371+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18541')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10177, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1064, 1107, N'Created', N'New', N'PR', CAST(N'2023-06-12T14:29:12.2526758+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18541')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10178, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1065, 1109, N'Fired', N'New', N'PR', CAST(N'2023-06-12T14:29:49.0081556+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10179, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1065, 1109, N'Created', N'New', N'PR', CAST(N'2023-06-12T14:29:59.7132872+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2141')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10180, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1066, 1111, N'Fired', N'New', N'PR', CAST(N'2023-06-12T14:31:22.4523290+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10181, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1066, 1111, N'Created', N'New', N'PR', CAST(N'2023-06-12T14:31:33.5970575+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2142')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10182, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1066, 1111, N'Completed', N'AutomaticallyMerged', N'PR', CAST(N'2023-06-12T14:36:38.4839835+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2142')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10183, N'https://github.com/maestro-auth-test/maestro-test2', N'https://github.com/maestro-auth-test/maestro-test3', 1066, 1111, N'Fired', N'New', N'PR', CAST(N'2023-06-12T14:37:38.4073636+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10184, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1067, 1113, N'Fired', N'New', N'PR', CAST(N'2023-06-12T14:39:11.6948855+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10185, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1067, 1113, N'Created', N'New', N'PR', CAST(N'2023-06-12T14:39:22.0209280+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18542')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10186, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1067, 1113, N'Completed', N'AutomaticallyMerged', N'PR', CAST(N'2023-06-12T14:44:28.6959458+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18542')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10187, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1068, 1114, N'Fired', N'New', N'PR', CAST(N'2023-06-12T14:45:45.3789361+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10188, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1068, 1114, N'Created', N'New', N'PR', CAST(N'2023-06-12T14:45:55.7574683+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18543')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10189, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1068, 1114, N'Completed', N'AutomaticallyMerged', N'PR', CAST(N'2023-06-12T14:51:01.9873857+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18543')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10190, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1069, 1115, N'Fired', N'New', N'PR', CAST(N'2023-06-12T14:52:18.8602257+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10191, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1069, 1115, N'Created', N'New', N'PR', CAST(N'2023-06-12T14:52:29.1425912+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18544')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10192, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1069, 1115, N'Completed', N'AutomaticallyMerged', N'PR', CAST(N'2023-06-12T14:57:35.7437496+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18544')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10193, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1070, 1116, N'Fired', N'New', N'PR', CAST(N'2023-06-12T14:58:53.6150226+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10194, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1070, 1116, N'Created', N'New', N'PR', CAST(N'2023-06-12T14:59:04.5028340+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18545')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10195, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1071, 1117, N'Fired', N'New', N'PR', CAST(N'2023-06-12T15:05:26.9758983+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10196, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1071, 1117, N'Created', N'New', N'PR', CAST(N'2023-06-12T15:05:37.9912422+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18546')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10197, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1071, 1117, N'Completed', N'AutomaticallyMerged', N'PR', CAST(N'2023-06-12T15:10:43.6888410+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18546')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10198, N'https://github.com/dotnet/arcade', N'https://github.com/maestro-auth-test/maestro-test2', 1072, 1118, N'Fired', N'New', N'PR', CAST(N'2023-06-12T15:12:10.4063231+00:00' AS DateTimeOffset), NULL)
GO
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10199, N'https://github.com/dotnet/arcade', N'https://github.com/maestro-auth-test/maestro-test2', 1075, 1119, N'Fired', N'New', N'PR', CAST(N'2023-06-12T15:25:38.3517361+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10200, N'https://github.com/dotnet/arcade', N'https://github.com/maestro-auth-test/maestro-test2', 1076, 1120, N'Fired', N'New', N'PR', CAST(N'2023-06-13T07:59:05.9360805+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10201, N'https://github.com/dotnet/arcade', N'https://github.com/maestro-auth-test/maestro-test2', 1077, 1121, N'Fired', N'New', N'PR', CAST(N'2023-06-13T08:44:53.9335005+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10202, N'https://github.com/dotnet/arcade', N'https://github.com/maestro-auth-test/maestro-test2', 1078, 1122, N'Fired', N'New', N'PR', CAST(N'2023-06-13T09:28:48.2196012+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10203, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1079, 1123, N'Fired', N'New', N'PR', CAST(N'2023-06-13T13:38:21.1260585+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10204, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1079, 1123, N'Created', N'New', N'PR', CAST(N'2023-06-13T13:38:33.6249322+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18547')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10205, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1079, 1123, N'Completed', N'AutomaticallyMerged', N'PR', CAST(N'2023-06-13T13:43:40.3090753+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18547')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10206, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1080, 1124, N'Fired', N'New', N'PR', CAST(N'2023-06-13T13:44:56.0237629+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10207, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1080, 1124, N'Created', N'New', N'PR', CAST(N'2023-06-13T13:45:07.0267515+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18548')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10208, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1080, 1124, N'Completed', N'AutomaticallyMerged', N'PR', CAST(N'2023-06-13T13:50:12.9480904+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18548')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10209, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1081, 1125, N'Fired', N'New', N'PR', CAST(N'2023-06-13T13:51:35.7703697+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10210, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1081, 1125, N'Created', N'New', N'PR', CAST(N'2023-06-13T13:51:47.2696385+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18549')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10211, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1082, 1126, N'Fired', N'New', N'PR', CAST(N'2023-06-13T13:58:12.0741801+00:00' AS DateTimeOffset), NULL)
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10212, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1082, 1126, N'Created', N'New', N'PR', CAST(N'2023-06-13T13:58:22.6138020+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18550')
INSERT [dbo].[DependencyFlowEvents] ([Id], [SourceRepository], [TargetRepository], [ChannelId], [BuildId], [Event], [Reason], [FlowType], [Timestamp], [Url]) VALUES (10213, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', 1082, 1126, N'Completed', N'AutomaticallyMerged', N'PR', CAST(N'2023-06-13T14:03:28.0904338+00:00' AS DateTimeOffset), N'https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18550')
SET IDENTITY_INSERT [dbo].[DependencyFlowEvents] OFF
GO
INSERT [dbo].[Repositories] ([RepositoryName], [InstallationId]) VALUES (N'https://dev.azure.com/dnceng/internal/_git/maestro-test1', 0)
INSERT [dbo].[Repositories] ([RepositoryName], [InstallationId]) VALUES (N'https://dev.azure.com/dnceng/internal/_git/maestro-test2', 0)
INSERT [dbo].[Repositories] ([RepositoryName], [InstallationId]) VALUES (N'https://github.com/maestro-auth-test/maestro-test1', 289474)
INSERT [dbo].[Repositories] ([RepositoryName], [InstallationId]) VALUES (N'https://github.com/maestro-auth-test/maestro-test2', 289474)
INSERT [dbo].[Repositories] ([RepositoryName], [InstallationId]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', 289474)
GO
INSERT [dbo].[RepositoryBranches] ([RepositoryName], [BranchName], [Policy]) VALUES (N'https://dev.azure.com/dnceng/internal/_git/maestro-test2', N'AzDo_BatchedTestBranch_DESKTOP-S9KU8GR', NULL)
INSERT [dbo].[RepositoryBranches] ([RepositoryName], [BranchName], [Policy]) VALUES (N'https://dev.azure.com/dnceng/internal/_git/maestro-test2', N'AzDo_NonBatchedTestBranch_DESKTOP-S9KU8GR', NULL)
INSERT [dbo].[RepositoryBranches] ([RepositoryName], [BranchName], [Policy]) VALUES (N'https://github.com/maestro-auth-test/maestro-test2', N'1055931597', NULL)
INSERT [dbo].[RepositoryBranches] ([RepositoryName], [BranchName], [Policy]) VALUES (N'https://github.com/maestro-auth-test/maestro-test2', N'1133602618', NULL)
INSERT [dbo].[RepositoryBranches] ([RepositoryName], [BranchName], [Policy]) VALUES (N'https://github.com/maestro-auth-test/maestro-test2', N'117406261', NULL)
INSERT [dbo].[RepositoryBranches] ([RepositoryName], [BranchName], [Policy]) VALUES (N'https://github.com/maestro-auth-test/maestro-test2', N'1235284482', NULL)
INSERT [dbo].[RepositoryBranches] ([RepositoryName], [BranchName], [Policy]) VALUES (N'https://github.com/maestro-auth-test/maestro-test2', N'1727634520', NULL)
INSERT [dbo].[RepositoryBranches] ([RepositoryName], [BranchName], [Policy]) VALUES (N'https://github.com/maestro-auth-test/maestro-test2', N'1962579591', NULL)
INSERT [dbo].[RepositoryBranches] ([RepositoryName], [BranchName], [Policy]) VALUES (N'https://github.com/maestro-auth-test/maestro-test2', N'2001522093', NULL)
INSERT [dbo].[RepositoryBranches] ([RepositoryName], [BranchName], [Policy]) VALUES (N'https://github.com/maestro-auth-test/maestro-test2', N'242865921', NULL)
INSERT [dbo].[RepositoryBranches] ([RepositoryName], [BranchName], [Policy]) VALUES (N'https://github.com/maestro-auth-test/maestro-test2', N'283042555', NULL)
INSERT [dbo].[RepositoryBranches] ([RepositoryName], [BranchName], [Policy]) VALUES (N'https://github.com/maestro-auth-test/maestro-test2', N'459294462', NULL)
INSERT [dbo].[RepositoryBranches] ([RepositoryName], [BranchName], [Policy]) VALUES (N'https://github.com/maestro-auth-test/maestro-test2', N'658794139', NULL)
INSERT [dbo].[RepositoryBranches] ([RepositoryName], [BranchName], [Policy]) VALUES (N'https://github.com/maestro-auth-test/maestro-test2', N'99838997', NULL)
INSERT [dbo].[RepositoryBranches] ([RepositoryName], [BranchName], [Policy]) VALUES (N'https://github.com/maestro-auth-test/maestro-test2', N'GitHub_BatchedTestBranch_DESKTOP-S9KU8GR', NULL)
INSERT [dbo].[RepositoryBranches] ([RepositoryName], [BranchName], [Policy]) VALUES (N'https://github.com/maestro-auth-test/maestro-test2', N'GitHub_NonBatchedTestBranch_DESKTOP-S9KU8GR', NULL)
INSERT [dbo].[RepositoryBranches] ([RepositoryName], [BranchName], [Policy]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_DESKTOP-S9KU8GR', NULL)
INSERT [dbo].[RepositoryBranches] ([RepositoryName], [BranchName], [Policy]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_FailingCoherencyOnlyUpdate_DESKTOP-S9KU8GR', NULL)
GO
INSERT [dbo].[Subscriptions] ([Id], [ChannelId], [SourceRepository], [TargetRepository], [TargetBranch], [Policy], [Enabled], [LastAppliedBuildId], [PullRequestFailureNotificationTags]) VALUES (N'0bf57238-1f9d-430b-23b8-08dbb4fecd36', 1, N'https://github.com/maestro-auth-test/maestro-test1', N'https://github.com/maestro-auth-test/maestro-test2', N'1055931597', N'{"Batchable":false,"UpdateFrequency":0,"MergePolicies":[]}', 1, NULL, N'')
GO
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test2', N'GitHub_NonBatchedTestBranch_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18504''', N'Merged: PR ''https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18504'' passed policies AllChecksSuccessful, ValidateCoherency', NULL, NULL, CAST(N'2023-06-01T16:00:01.3994849' AS DateTime2), CAST(N'2023-06-01T15:51:04.6652928' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2103''', N'PR Has been manually Merged', NULL, NULL, CAST(N'2023-06-02T09:56:24.4450356' AS DateTime2), CAST(N'2023-06-01T16:15:44.9764678' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2105''', N'PR Has been manually Merged', NULL, NULL, CAST(N'2023-06-02T10:19:16.0091249' AS DateTime2), CAST(N'2023-06-02T09:56:24.4450356' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2106''', N'PR Has been manually Merged', NULL, NULL, CAST(N'2023-06-02T10:25:03.3415899' AS DateTime2), CAST(N'2023-06-02T10:19:16.0091249' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2107''', N'PR Has been manually Merged', NULL, NULL, CAST(N'2023-06-02T11:17:51.8168819' AS DateTime2), CAST(N'2023-06-02T10:25:03.3415899' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2108''', N'PR Has been manually Merged', NULL, NULL, CAST(N'2023-06-02T12:01:23.6303268' AS DateTime2), CAST(N'2023-06-02T11:17:51.8168819' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2109''', N'PR Has been manually Merged', NULL, NULL, CAST(N'2023-06-02T12:25:27.7783917' AS DateTime2), CAST(N'2023-06-02T12:01:23.6303268' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2110''', N'PR Has been manually Merged', NULL, NULL, CAST(N'2023-06-02T12:30:50.2513090' AS DateTime2), CAST(N'2023-06-02T12:25:27.7783917' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2111''', N'PR Has been manually Merged', NULL, NULL, CAST(N'2023-06-02T12:47:24.9868114' AS DateTime2), CAST(N'2023-06-02T12:30:50.2513090' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2112''', N'PR Has been manually Merged', NULL, NULL, CAST(N'2023-06-02T12:53:47.9510353' AS DateTime2), CAST(N'2023-06-02T12:47:24.9868114' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2113''', N'PR Has been manually Merged', NULL, NULL, CAST(N'2023-06-02T13:12:09.5881129' AS DateTime2), CAST(N'2023-06-02T12:53:47.9510353' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_FailingCoherencyOnlyUpdate_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2116''', N'NOT Merged: PR ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2116'' has pending policies AllChecksSuccessfulWaiting for checks.', NULL, NULL, CAST(N'2023-06-02T14:42:27.4214046' AS DateTime2), CAST(N'2023-06-02T14:39:29.5161311' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_FailingCoherencyOnlyUpdate_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2116''', N'PR Has been manually Merged', NULL, NULL, CAST(N'2023-06-02T14:44:32.6102629' AS DateTime2), CAST(N'2023-06-02T14:42:27.4214046' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_FailingCoherencyOnlyUpdate_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2117''', N'NOT Merged: PR ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2117'' has failed policies ValidateCoherencyCoherency check failed.', NULL, NULL, CAST(N'2023-06-02T14:44:41.7946229' AS DateTime2), CAST(N'2023-06-02T14:44:32.6102629' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_FailingCoherencyOnlyUpdate_DESKTOP-S9KU8GR', 1, N'Processing pending updates', N'Pending updates applied. Pull Request ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2117'' updated.', NULL, NULL, CAST(N'2023-06-02T14:53:42.1047164' AS DateTime2), CAST(N'2023-06-02T14:44:41.7946229' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_FailingCoherencyOnlyUpdate_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2118''', N'PR Has been manually Merged', NULL, NULL, CAST(N'2023-06-02T15:01:58.5247425' AS DateTime2), CAST(N'2023-06-02T14:53:42.1047164' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_FailingCoherencyOnlyUpdate_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2120''', N'NOT Merged: PR ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2120'' has pending policies AllChecksSuccessfulWaiting for checks.', NULL, NULL, CAST(N'2023-06-02T15:17:24.4440213' AS DateTime2), CAST(N'2023-06-02T15:01:58.5247425' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_FailingCoherencyOnlyUpdate_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2121''', N'PR Has been manually Merged', NULL, NULL, CAST(N'2023-06-02T15:22:38.7176775' AS DateTime2), CAST(N'2023-06-02T15:17:24.4440213' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_FailingCoherencyOnlyUpdate_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2122''', N'NOT Merged: PR ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2122'' has failed policies ValidateCoherencyCoherency check failed.', NULL, NULL, CAST(N'2023-06-02T15:27:40.1953137' AS DateTime2), CAST(N'2023-06-02T15:22:38.7176775' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test2', N'GitHub_BatchedTestBranch_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18530''', N'NOT Merged: There are no merge policies', NULL, NULL, CAST(N'2023-06-12T08:10:09.1512792' AS DateTime2), CAST(N'2023-06-12T08:05:10.6504828' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test2', N'GitHub_NonBatchedTestBranch_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18505''', N'Merged: PR ''https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18505'' passed policies AllChecksSuccessful, ValidateCoherency', NULL, NULL, CAST(N'2023-06-12T08:14:45.2760659' AS DateTime2), CAST(N'2023-06-01T16:00:01.3994849' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test2', N'GitHub_NonBatchedTestBranch_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18531''', N'Merged: PR ''https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18531'' passed policies AllChecksSuccessful, ValidateCoherency', NULL, NULL, CAST(N'2023-06-12T08:29:32.8671556' AS DateTime2), CAST(N'2023-06-12T08:14:45.2760659' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test2', N'GitHub_NonBatchedTestBranch_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18532''', N'NOT Merged: There are no merge policies', NULL, NULL, CAST(N'2023-06-12T08:30:39.3198770' AS DateTime2), CAST(N'2023-06-12T08:29:32.8671556' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_FailingCoherencyOnlyUpdate_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2122''', N'PR Has been manually Closed', NULL, NULL, CAST(N'2023-06-12T08:52:31.2905503' AS DateTime2), CAST(N'2023-06-02T15:27:40.1953137' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_FailingCoherencyOnlyUpdate_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2127''', N'NOT Merged: PR ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2127'' has pending policies AllChecksSuccessfulWaiting for checks.', NULL, NULL, CAST(N'2023-06-12T09:47:35.9888384' AS DateTime2), CAST(N'2023-06-12T08:52:31.2905503' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_FailingCoherencyOnlyUpdate_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2128''', N'PR Has been manually Merged', NULL, NULL, CAST(N'2023-06-12T10:38:22.3979831' AS DateTime2), CAST(N'2023-06-12T09:47:35.9888384' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_FailingCoherencyOnlyUpdate_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2130''', N'NOT Merged: PR ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2130'' has pending policies AllChecksSuccessfulWaiting for checks.', NULL, NULL, CAST(N'2023-06-12T10:43:19.8125083' AS DateTime2), CAST(N'2023-06-12T10:38:22.3979831' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_FailingCoherencyOnlyUpdate_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2130''', N'NOT Merged: PR ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2130'' has pending policies AllChecksSuccessfulWaiting for checks.', NULL, NULL, CAST(N'2023-06-12T10:43:25.5047313' AS DateTime2), CAST(N'2023-06-12T10:43:19.8125083' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_FailingCoherencyOnlyUpdate_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2130''', N'NOT Merged: PR ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2130'' has pending policies AllChecksSuccessfulWaiting for checks.', NULL, NULL, CAST(N'2023-06-12T10:43:25.5365926' AS DateTime2), CAST(N'2023-06-12T10:43:25.5047313' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_FailingCoherencyOnlyUpdate_DESKTOP-S9KU8GR', 1, N'Processing pending updates', N'PR cannot be updated.', NULL, NULL, CAST(N'2023-06-12T10:48:22.7052961' AS DateTime2), CAST(N'2023-06-12T10:43:25.5365926' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_FailingCoherencyOnlyUpdate_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2130''', N'NOT Merged: PR ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2130'' has pending policies AllChecksSuccessfulWaiting for checks.', NULL, NULL, CAST(N'2023-06-12T10:48:28.2386705' AS DateTime2), CAST(N'2023-06-12T10:48:22.7052961' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_FailingCoherencyOnlyUpdate_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2130''', N'NOT Merged: PR ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2130'' has pending policies AllChecksSuccessfulWaiting for checks.', NULL, NULL, CAST(N'2023-06-12T10:48:28.2719774' AS DateTime2), CAST(N'2023-06-12T10:48:28.2386705' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_FailingCoherencyOnlyUpdate_DESKTOP-S9KU8GR', 1, N'Processing pending updates', N'PR cannot be updated.', NULL, NULL, CAST(N'2023-06-12T10:53:25.4589362' AS DateTime2), CAST(N'2023-06-12T10:48:28.2719774' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_FailingCoherencyOnlyUpdate_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2130''', N'NOT Merged: PR ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2130'' has pending policies AllChecksSuccessfulWaiting for checks.', NULL, NULL, CAST(N'2023-06-12T10:53:31.0244700' AS DateTime2), CAST(N'2023-06-12T10:53:25.4589362' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_FailingCoherencyOnlyUpdate_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2130''', N'NOT Merged: PR ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2130'' has pending policies AllChecksSuccessfulWaiting for checks.', NULL, NULL, CAST(N'2023-06-12T10:53:31.0416072' AS DateTime2), CAST(N'2023-06-12T10:53:31.0244700' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_FailingCoherencyOnlyUpdate_DESKTOP-S9KU8GR', 1, N'Processing pending updates', N'PR cannot be updated.', NULL, NULL, CAST(N'2023-06-12T10:58:28.2656474' AS DateTime2), CAST(N'2023-06-12T10:53:31.0416072' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_FailingCoherencyOnlyUpdate_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2130''', N'NOT Merged: PR ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2130'' has pending policies AllChecksSuccessfulWaiting for checks.', NULL, NULL, CAST(N'2023-06-12T10:58:34.0140234' AS DateTime2), CAST(N'2023-06-12T10:58:28.2656474' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_FailingCoherencyOnlyUpdate_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2130''', N'NOT Merged: PR ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2130'' has pending policies AllChecksSuccessfulWaiting for checks.', NULL, NULL, CAST(N'2023-06-12T10:58:34.0381182' AS DateTime2), CAST(N'2023-06-12T10:58:34.0140234' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_FailingCoherencyOnlyUpdate_DESKTOP-S9KU8GR', 1, N'Processing pending updates', N'PR cannot be updated.', NULL, NULL, CAST(N'2023-06-12T11:18:04.1045167' AS DateTime2), CAST(N'2023-06-12T10:58:34.0381182' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_FailingCoherencyOnlyUpdate_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2131''', N'NOT Merged: PR ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2131'' has pending policies AllChecksSuccessfulWaiting for checks.', NULL, NULL, CAST(N'2023-06-12T11:36:11.0026579' AS DateTime2), CAST(N'2023-06-12T11:18:04.1045167' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_FailingCoherencyOnlyUpdate_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2132''', N'NOT Merged: PR ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2132'' has pending policies AllChecksSuccessfulWaiting for checks.', NULL, NULL, CAST(N'2023-06-12T11:41:12.3323275' AS DateTime2), CAST(N'2023-06-12T11:36:11.0026579' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_FailingCoherencyOnlyUpdate_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2132''', N'PR Has been manually Closed', NULL, NULL, CAST(N'2023-06-12T11:47:31.0603658' AS DateTime2), CAST(N'2023-06-12T11:41:12.3323275' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_FailingCoherencyOnlyUpdate_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2133''', N'NOT Merged: PR ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2133'' has pending policies AllChecksSuccessfulWaiting for checks.', NULL, NULL, CAST(N'2023-06-12T11:57:57.4432017' AS DateTime2), CAST(N'2023-06-12T11:47:31.0603658' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_FailingCoherencyOnlyUpdate_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2133''', N'NOT Merged: PR ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2133'' has pending policies AllChecksSuccessfulWaiting for checks.', NULL, NULL, CAST(N'2023-06-12T12:02:57.5223060' AS DateTime2), CAST(N'2023-06-12T11:57:57.4432017' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_FailingCoherencyOnlyUpdate_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2133''', N'PR Has been manually Closed', NULL, NULL, CAST(N'2023-06-12T12:02:57.8658432' AS DateTime2), CAST(N'2023-06-12T12:02:57.5223060' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_FailingCoherencyOnlyUpdate_DESKTOP-S9KU8GR', 0, N'Processing pending updates', N'Required dependency file ''eng/Version.Details.xml'' in repository ''maestro-auth-test/maestro-test3'' branch ''GitHub_NonBatchedTestBranch_FailingCoherencyOnlyUpdate_DESKTOP-S9KU8GR'' was not found.', N'ProcessPendingUpdatesAsync', N'[]', CAST(N'2023-06-12T12:07:58.2510389' AS DateTime2), CAST(N'2023-06-12T12:02:57.8658432' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_FailingCoherencyOnlyUpdate_DESKTOP-S9KU8GR', 0, N'Processing pending updates', N'Required dependency file ''eng/Version.Details.xml'' in repository ''maestro-auth-test/maestro-test3'' branch ''GitHub_NonBatchedTestBranch_FailingCoherencyOnlyUpdate_DESKTOP-S9KU8GR'' was not found.', N'ProcessPendingUpdatesAsync', N'[]', CAST(N'2023-06-12T12:24:25.3696760' AS DateTime2), CAST(N'2023-06-12T12:07:58.2510389' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_FailingCoherencyOnlyUpdate_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2134''', N'NOT Merged: PR ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2134'' has failed policies DontAutomergeDowngrades
The following dependency updates appear to be downgrades or invalid versions:  Could not parse the ''from'' version '''' of A1 as a Semantic Version string, Could not parse the ''from'' version '''' of A2 as a Semantic Version string. Aborting auto-merge.
 Note that manual commits pushed to fix up the pull request won''t cause the downgrade check to be re-evaluated, 
 you can ignore the check in this case.
 If you think this PR should merge but lack permission to override this check, consider finding an admin or recreating the pull request manually.
 If you feel you are seeing this message in error, please contact the dnceng team.', NULL, NULL, CAST(N'2023-06-12T12:29:45.4191129' AS DateTime2), CAST(N'2023-06-12T12:24:25.3696760' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_FailingCoherencyOnlyUpdate_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2134''', N'NOT Merged: PR ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2134'' has failed policies DontAutomergeDowngrades
The following dependency updates appear to be downgrades or invalid versions:  Could not parse the ''from'' version '''' of A1 as a Semantic Version string, Could not parse the ''from'' version '''' of A2 as a Semantic Version string. Aborting auto-merge.
 Note that manual commits pushed to fix up the pull request won''t cause the downgrade check to be re-evaluated, 
 you can ignore the check in this case.
 If you think this PR should merge but lack permission to override this check, consider finding an admin or recreating the pull request manually.
 If you feel you are seeing this message in error, please contact the dnceng team.', NULL, NULL, CAST(N'2023-06-12T12:34:46.8784538' AS DateTime2), CAST(N'2023-06-12T12:29:45.4191129' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_FailingCoherencyOnlyUpdate_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2134''', N'PR Has been manually Closed', NULL, NULL, CAST(N'2023-06-12T12:44:16.8712481' AS DateTime2), CAST(N'2023-06-12T12:34:46.8784538' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_FailingCoherencyOnlyUpdate_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2135''', N'NOT Merged: PR ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2135'' has pending policies AllChecksSuccessfulWaiting for checks.', NULL, NULL, CAST(N'2023-06-12T13:00:51.7577230' AS DateTime2), CAST(N'2023-06-12T12:44:16.8712481' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test2', N'GitHub_BatchedTestBranch_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18530''', N'PR Has been manually Closed', NULL, NULL, CAST(N'2023-06-12T13:05:08.3048132' AS DateTime2), CAST(N'2023-06-12T08:10:09.1512792' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test2', N'GitHub_NonBatchedTestBranch_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18532''', N'NOT Merged: There are no merge policies', NULL, NULL, CAST(N'2023-06-12T13:07:46.9075352' AS DateTime2), CAST(N'2023-06-12T08:30:39.3198770' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test2', N'GitHub_NonBatchedTestBranch_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18538''', N'NOT Merged: There are no merge policies', NULL, NULL, CAST(N'2023-06-12T13:08:59.2053948' AS DateTime2), CAST(N'2023-06-12T13:07:46.9075352' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test2', N'GitHub_BatchedTestBranch_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18537''', N'NOT Merged: There are no merge policies', NULL, NULL, CAST(N'2023-06-12T13:10:09.9449896' AS DateTime2), CAST(N'2023-06-12T13:05:08.3048132' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_FailingCoherencyOnlyUpdate_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2136''', N'Merged: PR ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2136'' passed policies ValidateCoherency', NULL, NULL, CAST(N'2023-06-12T13:16:26.1808886' AS DateTime2), CAST(N'2023-06-12T13:00:51.7577230' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test2', N'GitHub_NonBatchedTestBranch_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18538''', N'NOT Merged: There are no merge policies', NULL, NULL, CAST(N'2023-06-12T13:24:14.7293456' AS DateTime2), CAST(N'2023-06-12T13:08:59.2053948' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://dev.azure.com/dnceng/internal/_git/maestro-test2', N'AzDo_BatchedTestBranch_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://dev.azure.com/dnceng/7ea9116e-9fac-403d-b258-b31fcf1bb293/_apis/git/repositories/e6f2a2fb-be51-4de9-b065-0f1430bc5f46/pullRequests/31802''', N'NOT Merged: There are no merge policies', NULL, NULL, CAST(N'2023-06-12T14:12:40.9377604' AS DateTime2), CAST(N'2023-06-12T14:07:40.2044775' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://dev.azure.com/dnceng/internal/_git/maestro-test2', N'AzDo_NonBatchedTestBranch_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://dev.azure.com/dnceng/7ea9116e-9fac-403d-b258-b31fcf1bb293/_apis/git/repositories/e6f2a2fb-be51-4de9-b065-0f1430bc5f46/pullRequests/31804''', N'PR Has been manually Closed', NULL, NULL, CAST(N'2023-06-12T14:13:03.6498872' AS DateTime2), CAST(N'2023-06-12T14:11:55.1617058' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test2', N'GitHub_BatchedTestBranch_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18537''', N'PR Has been manually Closed', NULL, NULL, CAST(N'2023-06-12T14:25:33.2522536' AS DateTime2), CAST(N'2023-06-12T13:10:09.9449896' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test2', N'GitHub_NonBatchedTestBranch_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18539''', N'Merged: PR ''https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18539'' passed policies AllChecksSuccessful, ValidateCoherency', NULL, NULL, CAST(N'2023-06-12T14:28:04.9744974' AS DateTime2), CAST(N'2023-06-12T13:24:14.7293456' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test2', N'GitHub_NonBatchedTestBranch_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18541''', N'NOT Merged: There are no merge policies', NULL, NULL, CAST(N'2023-06-12T14:29:11.2638732' AS DateTime2), CAST(N'2023-06-12T14:28:04.9744974' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test2', N'GitHub_BatchedTestBranch_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18540''', N'NOT Merged: There are no merge policies', NULL, NULL, CAST(N'2023-06-12T14:30:33.0900254' AS DateTime2), CAST(N'2023-06-12T14:25:33.2522536' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_FailingCoherencyOnlyUpdate_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2139''', N'Merged: PR ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2139'' passed policies ValidateCoherency', NULL, NULL, CAST(N'2023-06-12T14:36:38.5604380' AS DateTime2), CAST(N'2023-06-12T13:16:26.1808886' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdateHistory] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test2', N'GitHub_NonBatchedTestBranch_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18541''', N'NOT Merged: There are no merge policies', NULL, NULL, CAST(N'2023-06-12T14:44:28.7523936' AS DateTime2), CAST(N'2023-06-12T14:29:11.2638732' AS DateTime2))
GO
INSERT [dbo].[RepositoryBranchUpdates] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://dev.azure.com/dnceng/internal/_git/maestro-test2', N'AzDo_BatchedTestBranch_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://dev.azure.com/dnceng/7ea9116e-9fac-403d-b258-b31fcf1bb293/_apis/git/repositories/e6f2a2fb-be51-4de9-b065-0f1430bc5f46/pullRequests/31802''', N'PR Has been manually Closed', NULL, NULL, CAST(N'9999-12-31T23:59:59.9999999' AS DateTime2), CAST(N'2023-06-12T14:12:40.9377604' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdates] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://dev.azure.com/dnceng/internal/_git/maestro-test2', N'AzDo_NonBatchedTestBranch_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://dev.azure.com/dnceng/7ea9116e-9fac-403d-b258-b31fcf1bb293/_apis/git/repositories/e6f2a2fb-be51-4de9-b065-0f1430bc5f46/pullRequests/31805''', N'PR Has been manually Closed', NULL, NULL, CAST(N'9999-12-31T23:59:59.9999999' AS DateTime2), CAST(N'2023-06-12T14:13:03.6498872' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdates] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test2', N'1055931597', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18545''', N'NOT Merged: PR ''https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18545'' has pending policies AllChecksSuccessfulWaiting for checks.', NULL, NULL, CAST(N'9999-12-31T23:59:59.9999999' AS DateTime2), CAST(N'2023-06-12T15:04:09.2671865' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdates] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test2', N'1133602618', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18544''', N'Merged: PR ''https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18544'' passed policies NoRequestedChanges', NULL, NULL, CAST(N'9999-12-31T23:59:59.9999999' AS DateTime2), CAST(N'2023-06-12T14:57:35.8214219' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdates] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test2', N'117406261', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18548''', N'Merged: PR ''https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18548'' passed policies NoRequestedChanges', NULL, NULL, CAST(N'9999-12-31T23:59:59.9999999' AS DateTime2), CAST(N'2023-06-13T13:50:13.0126612' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdates] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test2', N'1235284482', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18533''', N'Merged: PR ''https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18533'' passed policies AllChecksSuccessful', NULL, NULL, CAST(N'9999-12-31T23:59:59.9999999' AS DateTime2), CAST(N'2023-06-12T09:16:56.2147977' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdates] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test2', N'1727634520', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18550''', N'Merged: PR ''https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18550'' passed policies ValidateCoherency', NULL, NULL, CAST(N'9999-12-31T23:59:59.9999999' AS DateTime2), CAST(N'2023-06-13T14:03:28.1980381' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdates] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test2', N'1962579591', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18534''', N'Merged: PR ''https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18534'' passed policies NoRequestedChanges', NULL, NULL, CAST(N'9999-12-31T23:59:59.9999999' AS DateTime2), CAST(N'2023-06-12T09:23:30.7927305' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdates] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test2', N'2001522093', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18543''', N'Merged: PR ''https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18543'' passed policies AllChecksSuccessful', NULL, NULL, CAST(N'9999-12-31T23:59:59.9999999' AS DateTime2), CAST(N'2023-06-12T14:51:02.0559253' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdates] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test2', N'242865921', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18547''', N'Merged: PR ''https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18547'' passed policies AllChecksSuccessful', NULL, NULL, CAST(N'9999-12-31T23:59:59.9999999' AS DateTime2), CAST(N'2023-06-13T13:43:40.4709320' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdates] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test2', N'283042555', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18536''', N'Merged: PR ''https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18536'' passed policies ValidateCoherency', NULL, NULL, CAST(N'9999-12-31T23:59:59.9999999' AS DateTime2), CAST(N'2023-06-12T09:36:47.2520918' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdates] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test2', N'459294462', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18546''', N'Merged: PR ''https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18546'' passed policies ValidateCoherency', NULL, NULL, CAST(N'9999-12-31T23:59:59.9999999' AS DateTime2), CAST(N'2023-06-12T15:10:43.7558955' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdates] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test2', N'658794139', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18535''', N'NOT Merged: PR ''https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18535'' has pending policies AllChecksSuccessfulWaiting for checks.', NULL, NULL, CAST(N'9999-12-31T23:59:59.9999999' AS DateTime2), CAST(N'2023-06-12T09:30:08.9595252' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdates] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test2', N'99838997', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18549''', N'NOT Merged: PR ''https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18549'' has pending policies AllChecksSuccessfulWaiting for checks.', NULL, NULL, CAST(N'9999-12-31T23:59:59.9999999' AS DateTime2), CAST(N'2023-06-13T13:56:52.0876624' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdates] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test2', N'GitHub_BatchedTestBranch_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18540''', N'PR Has been manually Closed', NULL, NULL, CAST(N'9999-12-31T23:59:59.9999999' AS DateTime2), CAST(N'2023-06-12T14:30:33.0900254' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdates] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test2', N'GitHub_NonBatchedTestBranch_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18542''', N'Merged: PR ''https://api.github.com/repos/maestro-auth-test/maestro-test2/pulls/18542'' passed policies AllChecksSuccessful, ValidateCoherency', NULL, NULL, CAST(N'9999-12-31T23:59:59.9999999' AS DateTime2), CAST(N'2023-06-12T14:44:28.7523936' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdates] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2114''', N'PR Has been manually Merged', NULL, NULL, CAST(N'9999-12-31T23:59:59.9999999' AS DateTime2), CAST(N'2023-06-02T13:12:09.5881129' AS DateTime2))
INSERT [dbo].[RepositoryBranchUpdates] ([RepositoryName], [BranchName], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'https://github.com/maestro-auth-test/maestro-test3', N'GitHub_NonBatchedTestBranch_FailingCoherencyOnlyUpdate_DESKTOP-S9KU8GR', 1, N'Synchronizing Pull Request: ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2142''', N'Merged: PR ''https://api.github.com/repos/maestro-auth-test/maestro-test3/pulls/2142'' passed policies ValidateCoherency', NULL, NULL, CAST(N'9999-12-31T23:59:59.9999999' AS DateTime2), CAST(N'2023-06-12T14:36:38.5604380' AS DateTime2))
GO
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'a7e81aba-6d18-475f-4333-08db62b4ee2c', 1, N'Updating subscription for build 4', N'Update Sent', NULL, NULL, CAST(N'2023-06-01T15:32:13.6066613' AS DateTime2), CAST(N'2023-06-01T15:30:25.8518916' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'7d30b525-a4ad-4c42-4336-08db62b4ee2c', 1, N'Updating subscription for build 9', N'Update Sent', NULL, NULL, CAST(N'2023-06-01T15:38:12.2535787' AS DateTime2), CAST(N'2023-06-01T15:34:38.7312025' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'dac4a6dd-9fc4-44c2-4338-08db62b4ee2c', 1, N'Updating subscription for build 13', N'Update Sent', NULL, NULL, CAST(N'2023-06-01T15:50:16.8810365' AS DateTime2), CAST(N'2023-06-01T15:39:23.7308525' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'5459455e-11e5-439c-7459-08db62b7e94e', 1, N'Updating subscription for build 14', N'Update Sent', NULL, NULL, CAST(N'2023-06-01T15:51:05.3183242' AS DateTime2), CAST(N'2023-06-01T15:50:54.6367677' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'5459455e-11e5-439c-7459-08db62b7e94e', 1, N'Updating subscription for build 14', N'Update Sent', NULL, NULL, CAST(N'2023-06-01T15:53:39.5022376' AS DateTime2), CAST(N'2023-06-01T15:51:05.3183242' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'9b8e7a47-c558-4279-745b-08db62b7e94e', 1, N'Updating subscription for build 16', N'Update Sent', NULL, NULL, CAST(N'2023-06-01T16:08:05.4163741' AS DateTime2), CAST(N'2023-06-01T15:54:55.0938478' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'65103018-7aac-46cf-745d-08db62b7e94e', 1, N'Updating subscription for build 19', N'Update Sent', NULL, NULL, CAST(N'2023-06-01T16:10:54.8834481' AS DateTime2), CAST(N'2023-06-01T16:09:45.1706405' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'3c2c48aa-0b87-4cde-745e-08db62b7e94e', 1, N'Updating subscription for build 21', N'Update Sent', NULL, NULL, CAST(N'2023-06-01T16:15:50.9140929' AS DateTime2), CAST(N'2023-06-01T16:13:36.0178147' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'3c2c48aa-0b87-4cde-745e-08db62b7e94e', 0, N'Updating subscription for build 21', N'Unexpected error processing action: Validation Failed', N'UpdateAsync', N'[21]', CAST(N'2023-06-01T18:51:25.9758175' AS DateTime2), CAST(N'2023-06-01T16:15:50.9140929' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'bbfcb8fd-7d32-4d14-52ca-08db62d136cf', 1, N'Updating subscription for build 26', N'Update Sent', NULL, NULL, CAST(N'2023-06-02T09:51:52.2054922' AS DateTime2), CAST(N'2023-06-01T18:53:20.8260535' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'071c17f2-aeaf-45b3-3597-08db634f017d', 1, N'Updating subscription for build 1026', N'Update Sent', NULL, NULL, CAST(N'2023-06-02T09:58:13.0231603' AS DateTime2), CAST(N'2023-06-02T09:53:56.6927777' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'f9a125f5-56ff-4807-3598-08db634f017d', 1, N'Updating subscription for build 1027', N'Update Sent', NULL, NULL, CAST(N'2023-06-02T10:19:51.2247245' AS DateTime2), CAST(N'2023-06-02T10:17:17.9566174' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'f9a125f5-56ff-4807-3598-08db634f017d', 0, N'Updating subscription for build 1027', N'Unexpected error processing action: Validation Failed', N'UpdateAsync', N'[1027]', CAST(N'2023-06-02T10:22:27.3831844' AS DateTime2), CAST(N'2023-06-02T10:19:51.2247245' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'50315f62-c1f5-43af-3599-08db634f017d', 1, N'Updating subscription for build 1029', N'Update Sent', NULL, NULL, CAST(N'2023-06-02T10:26:26.0639171' AS DateTime2), CAST(N'2023-06-02T10:23:27.6135751' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'50315f62-c1f5-43af-3599-08db634f017d', 0, N'Updating subscription for build 1029', N'Unexpected error processing action: Validation Failed', N'UpdateAsync', N'[1029]', CAST(N'2023-06-02T10:35:12.7097105' AS DateTime2), CAST(N'2023-06-02T10:26:26.0639171' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'4b22fcc8-8aa0-497f-359a-08db634f017d', 1, N'Updating subscription for build 1031', N'Update Sent', NULL, NULL, CAST(N'2023-06-02T11:20:40.7128305' AS DateTime2), CAST(N'2023-06-02T11:15:38.1729321' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'4b22fcc8-8aa0-497f-359a-08db634f017d', 0, N'Updating subscription for build 1031', N'Unexpected error processing action: Validation Failed', N'UpdateAsync', N'[1031]', CAST(N'2023-06-02T11:58:34.6934275' AS DateTime2), CAST(N'2023-06-02T11:20:40.7128305' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'2a130db7-e9df-4e52-e30a-08db6360b565', 1, N'Updating subscription for build 1033', N'Update Sent', NULL, NULL, CAST(N'2023-06-02T12:03:43.0100879' AS DateTime2), CAST(N'2023-06-02T11:59:24.6246524' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'2a130db7-e9df-4e52-e30a-08db6360b565', 0, N'Updating subscription for build 1033', N'Unexpected error processing action: Validation Failed', N'UpdateAsync', N'[1033]', CAST(N'2023-06-02T12:22:48.1714569' AS DateTime2), CAST(N'2023-06-02T12:03:43.0100879' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'a04ee9d1-1d75-4503-4dc4-08db63641739', 1, N'Updating subscription for build 1035', N'Update Sent', NULL, NULL, CAST(N'2023-06-02T12:26:28.5216049' AS DateTime2), CAST(N'2023-06-02T12:23:38.0289982' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'a04ee9d1-1d75-4503-4dc4-08db63641739', 0, N'Updating subscription for build 1035', N'Unexpected error processing action: Validation Failed', N'UpdateAsync', N'[1035]', CAST(N'2023-06-02T12:28:09.9151311' AS DateTime2), CAST(N'2023-06-02T12:26:28.5216049' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'b9fd6b91-b04e-4f17-4dc5-08db63641739', 1, N'Updating subscription for build 1037', N'Update Sent', NULL, NULL, CAST(N'2023-06-02T12:31:22.4549139' AS DateTime2), CAST(N'2023-06-02T12:28:46.6271920' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'b9fd6b91-b04e-4f17-4dc5-08db63641739', 0, N'Updating subscription for build 1037', N'Unexpected error processing action: Validation Failed', N'UpdateAsync', N'[1037]', CAST(N'2023-06-02T12:44:47.1716158' AS DateTime2), CAST(N'2023-06-02T12:31:22.4549139' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'a0aad391-891a-4c2b-cd04-08db63672960', 1, N'Updating subscription for build 1039', N'Update Sent', NULL, NULL, CAST(N'2023-06-02T12:48:09.6550503' AS DateTime2), CAST(N'2023-06-02T12:46:02.6470798' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'a0aad391-891a-4c2b-cd04-08db63672960', 0, N'Updating subscription for build 1039', N'Unexpected error processing action: Validation Failed', N'UpdateAsync', N'[1039]', CAST(N'2023-06-02T12:51:08.8533928' AS DateTime2), CAST(N'2023-06-02T12:48:09.6550503' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'4f827ae0-18ad-447c-cd05-08db63672960', 1, N'Updating subscription for build 1041', N'Update Sent', NULL, NULL, CAST(N'2023-06-02T12:56:15.6543309' AS DateTime2), CAST(N'2023-06-02T12:51:45.0715806' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'4f827ae0-18ad-447c-cd05-08db63672960', 0, N'Updating subscription for build 1041', N'Unexpected error processing action: Validation Failed', N'UpdateAsync', N'[1041]', CAST(N'2023-06-02T13:09:30.8568198' AS DateTime2), CAST(N'2023-06-02T12:56:15.6543309' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'6a24c0a4-7d8f-48f1-f0c3-08db636a9d6f', 1, N'Updating subscription for build 1043', N'Update Sent', NULL, NULL, CAST(N'2023-06-02T13:12:27.9581141' AS DateTime2), CAST(N'2023-06-02T13:10:19.6101378' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'6a24c0a4-7d8f-48f1-f0c3-08db636a9d6f', 1, N'Updating subscription for build 1043', N'Update Sent', NULL, NULL, CAST(N'2023-06-02T13:13:16.9912466' AS DateTime2), CAST(N'2023-06-02T13:12:27.9581141' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'772b116b-dad7-469f-6c78-08db637715a8', 1, N'Updating subscription for build 1045', N'Update Sent', NULL, NULL, CAST(N'2023-06-02T14:39:29.6822403' AS DateTime2), CAST(N'2023-06-02T14:39:23.7046777' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'772b116b-dad7-469f-6c78-08db637715a8', 1, N'Updating subscription for build 1045', N'Update Sent', NULL, NULL, CAST(N'2023-06-02T14:42:37.8097700' AS DateTime2), CAST(N'2023-06-02T14:39:29.6822403' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'772b116b-dad7-469f-6c78-08db637715a8', 1, N'Updating subscription for build 1045', N'Update Sent', NULL, NULL, CAST(N'2023-06-02T14:45:03.0385847' AS DateTime2), CAST(N'2023-06-02T14:42:37.8097700' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'059a5e6b-752a-4cca-6c79-08db637715a8', 1, N'Updating subscription for build 1047', N'Update Sent', NULL, NULL, CAST(N'2023-06-02T14:53:59.8206302' AS DateTime2), CAST(N'2023-06-02T14:48:40.6068326' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'059a5e6b-752a-4cca-6c79-08db637715a8', 1, N'Updating subscription for build 1047', N'Update Sent', NULL, NULL, CAST(N'2023-06-02T14:55:00.6443569' AS DateTime2), CAST(N'2023-06-02T14:53:59.8206302' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'fd36395d-83ed-4b4f-6c7a-08db637715a8', 1, N'Updating subscription for build 1049', N'Update Sent', NULL, NULL, CAST(N'2023-06-02T15:05:01.8603195' AS DateTime2), CAST(N'2023-06-02T14:56:55.5309163' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'3e97e524-0e35-466e-6c7b-08db637715a8', 1, N'Updating subscription for build 1051', N'Update Sent', NULL, NULL, CAST(N'2023-06-02T15:17:35.7901771' AS DateTime2), CAST(N'2023-06-02T15:15:18.8901209' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'7ae27c70-de53-4d9a-fd00-08db6b1b917a', 1, N'Updating subscription for build 1054', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T08:05:49.8805437' AS DateTime2), CAST(N'2023-06-12T08:05:22.2471516' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'76a88df4-1b80-496f-fcff-08db6b1b917a', 1, N'Updating subscription for build 1053', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T08:05:52.1533570' AS DateTime2), CAST(N'2023-06-12T08:05:07.6560168' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'4409d0ff-1964-419c-fd02-08db6b1b917a', 1, N'Updating subscription for build 1056', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T08:08:16.6156142' AS DateTime2), CAST(N'2023-06-12T08:07:19.1714010' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'3e97e524-0e35-466e-6c7b-08db637715a8', 1, N'Updating subscription for build 1051', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T08:08:29.4366006' AS DateTime2), CAST(N'2023-06-02T15:17:35.7901771' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'32aa6eb5-bccc-43e2-fd04-08db6b1b917a', 1, N'Updating subscription for build 1060', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T08:15:41.8012131' AS DateTime2), CAST(N'2023-06-12T08:09:38.5985866' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'37988229-556a-4d4d-fd05-08db6b1b917a', 1, N'Updating subscription for build 1061', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T08:29:41.6828557' AS DateTime2), CAST(N'2023-06-12T08:28:35.6211587' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'37988229-556a-4d4d-fd05-08db6b1b917a', 1, N'Updating subscription for build 1061', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T08:30:45.8742781' AS DateTime2), CAST(N'2023-06-12T08:29:41.6828557' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'9a3c7702-e65b-4455-fd06-08db6b1b917a', 1, N'Updating subscription for build 1063', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T08:55:30.3966994' AS DateTime2), CAST(N'2023-06-12T08:47:28.3646629' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'8f564635-2c86-4b13-fd07-08db6b1b917a', 1, N'Updating subscription for build 1065', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T09:17:51.7783617' AS DateTime2), CAST(N'2023-06-12T09:11:49.7499281' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'26b66517-46ff-41ab-fd08-08db6b1b917a', 1, N'Updating subscription for build 1066', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T09:24:28.9770406' AS DateTime2), CAST(N'2023-06-12T09:18:25.1353780' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'024c68fa-62a4-4d99-fd09-08db6b1b917a', 1, N'Updating subscription for build 1067', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T09:31:05.3833369' AS DateTime2), CAST(N'2023-06-12T09:25:04.6524762' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'e141950a-6085-4886-fd0a-08db6b1b917a', 1, N'Updating subscription for build 1068', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T09:37:46.3683836' AS DateTime2), CAST(N'2023-06-12T09:31:41.3443611' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'50db5477-671a-4f45-fd0b-08db6b1b917a', 1, N'Updating subscription for build 1069', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T09:47:46.4487222' AS DateTime2), CAST(N'2023-06-12T09:45:32.2471456' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'50db5477-671a-4f45-fd0b-08db6b1b917a', 1, N'Updating subscription for build 1069', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T09:48:44.3940897' AS DateTime2), CAST(N'2023-06-12T09:47:46.4487222' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'6384d1fb-be88-4612-b037-08db6b31110c', 1, N'Updating subscription for build 1071', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T10:38:22.5439882' AS DateTime2), CAST(N'2023-06-12T10:38:16.9477012' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'6384d1fb-be88-4612-b037-08db6b31110c', 1, N'Updating subscription for build 1071', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T10:59:22.5584133' AS DateTime2), CAST(N'2023-06-12T10:38:22.5439882' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'295f3a3e-c130-457e-b038-08db6b31110c', 1, N'Updating subscription for build 1073', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T11:20:47.6007203' AS DateTime2), CAST(N'2023-06-12T11:12:47.4395675' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'fe9fe327-15a1-45c6-b039-08db6b31110c', 1, N'Updating subscription for build 1075', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T11:46:42.9250364' AS DateTime2), CAST(N'2023-06-12T11:30:39.3266679' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'4944a614-0278-464f-b81f-08db6b3ab4e3', 1, N'Updating subscription for build 1077', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T11:47:31.2196911' AS DateTime2), CAST(N'2023-06-12T11:47:19.1771120' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'4944a614-0278-464f-b81f-08db6b3ab4e3', 1, N'Updating subscription for build 1077', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T12:08:24.7337371' AS DateTime2), CAST(N'2023-06-12T11:47:31.2196911' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'9a3b7053-90d6-484a-9ec7-08db6b3f271c', 1, N'Updating subscription for build 1079', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T12:38:41.1028884' AS DateTime2), CAST(N'2023-06-12T12:19:10.9934901' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'6a99ca68-36be-4418-9ec8-08db6b3f271c', 1, N'Updating subscription for build 1081', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T12:45:58.1168470' AS DateTime2), CAST(N'2023-06-12T12:39:13.3032534' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'a09c834b-02da-4526-9ec9-08db6b3f271c', 1, N'Updating subscription for build 1083', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T13:01:59.7747312' AS DateTime2), CAST(N'2023-06-12T12:55:46.2597688' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'a09c834b-02da-4526-9ec9-08db6b3f271c', 1, N'Updating subscription for build 1083', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T13:02:57.8110379' AS DateTime2), CAST(N'2023-06-12T13:01:59.7747312' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'a83988ad-0a68-4f6a-9ecb-08db6b3f271c', 1, N'Updating subscription for build 1086', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T13:06:07.4225934' AS DateTime2), CAST(N'2023-06-12T13:05:17.9262897' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'ef2fd86e-e4e1-4442-9eca-08db6b3f271c', 1, N'Updating subscription for build 1085', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T13:06:09.1148031' AS DateTime2), CAST(N'2023-06-12T13:05:06.5380684' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'021ebaec-95d7-4755-9ecc-08db6b3f271c', 1, N'Updating subscription for build 1087', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T13:07:56.7536717' AS DateTime2), CAST(N'2023-06-12T13:06:52.6713001' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'021ebaec-95d7-4755-9ecc-08db6b3f271c', 1, N'Updating subscription for build 1087', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T13:09:08.1189779' AS DateTime2), CAST(N'2023-06-12T13:07:56.7536717' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'bd49d3d8-422b-4e6e-9ecd-08db6b3f271c', 1, N'Updating subscription for build 1089', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T13:10:44.9431966' AS DateTime2), CAST(N'2023-06-12T13:09:46.6990348' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'af23f89f-4707-45e7-9ece-08db6b3f271c', 1, N'Updating subscription for build 1091', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T13:17:34.4962041' AS DateTime2), CAST(N'2023-06-12T13:11:21.2242348' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'af23f89f-4707-45e7-9ece-08db6b3f271c', 1, N'Updating subscription for build 1091', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T13:18:33.3179867' AS DateTime2), CAST(N'2023-06-12T13:17:34.4962041' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'e2b24ed3-4197-4a85-9ecf-08db6b3f271c', 1, N'Updating subscription for build 1093', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T13:25:11.1791615' AS DateTime2), CAST(N'2023-06-12T13:19:08.1468558' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'c0188f03-9d3b-4e8a-9ed1-08db6b3f271c', 1, N'Updating subscription for build 1095', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T14:08:29.8184354' AS DateTime2), CAST(N'2023-06-12T14:07:52.2621262' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'7c585540-2a99-4b00-9ed0-08db6b3f271c', 1, N'Updating subscription for build 1094', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T14:08:31.5741250' AS DateTime2), CAST(N'2023-06-12T14:07:38.6894639' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'6c0283bb-93af-4764-9ed2-08db6b3f271c', 1, N'Updating subscription for build 1096', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T14:10:15.6802546' AS DateTime2), CAST(N'2023-06-12T14:09:16.8907914' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'768c85f1-1d37-4dac-9ed3-08db6b3f271c', 1, N'Updating subscription for build 1097', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T14:12:09.5019487' AS DateTime2), CAST(N'2023-06-12T14:11:14.7379636' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'768c85f1-1d37-4dac-9ed3-08db6b3f271c', 1, N'Updating subscription for build 1097', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T14:13:16.8712449' AS DateTime2), CAST(N'2023-06-12T14:12:09.5019487' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'768c85f1-1d37-4dac-9ed3-08db6b3f271c', 1, N'Updating subscription for build 1097', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T14:14:12.7301983' AS DateTime2), CAST(N'2023-06-12T14:13:16.8712449' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'd36bfbcf-249b-42a8-9ed4-08db6b3f271c', 1, N'Updating subscription for build 1099', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T14:15:52.8038507' AS DateTime2), CAST(N'2023-06-12T14:14:54.0508395' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'18080fe8-21aa-4646-9ed6-08db6b3f271c', 1, N'Updating subscription for build 1106', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T14:26:30.6808905' AS DateTime2), CAST(N'2023-06-12T14:25:42.8714816' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'bbfebb80-81c3-41d3-9ed5-08db6b3f271c', 1, N'Updating subscription for build 1105', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T14:26:32.5265430' AS DateTime2), CAST(N'2023-06-12T14:25:31.5888924' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'101a101d-42c2-42f3-9ed7-08db6b3f271c', 1, N'Updating subscription for build 1107', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T14:28:15.6782117' AS DateTime2), CAST(N'2023-06-12T14:27:08.9745561' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'101a101d-42c2-42f3-9ed7-08db6b3f271c', 1, N'Updating subscription for build 1107', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T14:29:18.5364103' AS DateTime2), CAST(N'2023-06-12T14:28:15.6782117' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'01374832-b01c-43bd-9ed8-08db6b3f271c', 1, N'Updating subscription for build 1109', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T14:30:57.0961396' AS DateTime2), CAST(N'2023-06-12T14:29:59.8045090' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'6994a51a-f725-40b9-9ed9-08db6b3f271c', 1, N'Updating subscription for build 1111', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T14:37:48.9380388' AS DateTime2), CAST(N'2023-06-12T14:31:33.6842634' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'6994a51a-f725-40b9-9ed9-08db6b3f271c', 1, N'Updating subscription for build 1111', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T14:38:47.9361305' AS DateTime2), CAST(N'2023-06-12T14:37:48.9380388' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'fe1b8ac5-67ff-4569-9eda-08db6b3f271c', 1, N'Updating subscription for build 1113', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T14:45:23.2886046' AS DateTime2), CAST(N'2023-06-12T14:39:22.0947036' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'98b4996c-78e0-4cef-9edb-08db6b3f271c', 1, N'Updating subscription for build 1114', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T14:51:56.6380126' AS DateTime2), CAST(N'2023-06-12T14:45:55.8381469' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'16845ec2-e18a-4179-9edc-08db6b3f271c', 1, N'Updating subscription for build 1115', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T14:58:31.8754064' AS DateTime2), CAST(N'2023-06-12T14:52:29.2303503' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'3e796b96-2d02-4e05-9edd-08db6b3f271c', 1, N'Updating subscription for build 1116', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T15:05:04.9675164' AS DateTime2), CAST(N'2023-06-12T14:59:04.5984752' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'3b5d9fb6-b858-4d69-9ede-08db6b3f271c', 1, N'Updating subscription for build 1117', N'Update Sent', NULL, NULL, CAST(N'2023-06-12T15:11:41.5547133' AS DateTime2), CAST(N'2023-06-12T15:05:38.0987458' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'164a7ed6-12bc-4f5a-9edf-08db6b3f271c', 0, N'Updating subscription for build 1118', N'No installation is available for repository ''https://github.com/dotnet/arcade''', N'UpdateAsync', N'[1118]', CAST(N'2023-06-12T15:22:22.7437064' AS DateTime2), CAST(N'2023-06-12T15:12:15.5711393' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'd1c78998-127e-4803-9ee7-08db6b3f271c', 0, N'Updating subscription for build 1119', N'No installation is available for repository ''https://github.com/dotnet/arcade''', N'UpdateAsync', N'[1119]', CAST(N'2023-06-12T15:35:52.0013214' AS DateTime2), CAST(N'2023-06-12T15:25:43.1834788' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'58228094-897c-4fbc-9918-08db6be40302', 0, N'Updating subscription for build 1120', N'No installation is available for repository ''https://github.com/dotnet/arcade''', N'UpdateAsync', N'[1120]', CAST(N'2023-06-13T08:09:13.7262720' AS DateTime2), CAST(N'2023-06-13T07:59:15.3912418' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'58e8cd1b-f453-4cf8-9919-08db6be40302', 0, N'Updating subscription for build 1121', N'No installation is available for repository ''https://github.com/dotnet/arcade''', N'UpdateAsync', N'[1121]', CAST(N'2023-06-13T08:55:10.3271175' AS DateTime2), CAST(N'2023-06-13T08:45:03.7932966' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'152b5bd2-f903-417e-8a1b-08db6bf08a85', 0, N'Updating subscription for build 1122', N'No installation is available for repository ''https://github.com/dotnet/arcade''', N'UpdateAsync', N'[1122]', CAST(N'2023-06-13T09:38:51.7667550' AS DateTime2), CAST(N'2023-06-13T09:28:57.9837775' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'950e5854-2d41-453b-8a1c-08db6bf08a85', 1, N'Updating subscription for build 1123', N'Update Sent', NULL, NULL, CAST(N'2023-06-13T13:44:33.3169290' AS DateTime2), CAST(N'2023-06-13T13:38:33.7668714' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'3186cfcc-42bf-4671-8a1d-08db6bf08a85', 1, N'Updating subscription for build 1124', N'Update Sent', NULL, NULL, CAST(N'2023-06-13T13:51:10.5566211' AS DateTime2), CAST(N'2023-06-13T13:45:07.1204882' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'0cd599ef-1db9-4e3c-8a1e-08db6bf08a85', 1, N'Updating subscription for build 1125', N'Update Sent', NULL, NULL, CAST(N'2023-06-13T13:57:47.4576296' AS DateTime2), CAST(N'2023-06-13T13:51:47.3626238' AS DateTime2))
INSERT [dbo].[SubscriptionUpdateHistory] ([SubscriptionId], [Success], [Action], [ErrorMessage], [Method], [Arguments], [SysEndTime], [SysStartTime]) VALUES (N'fece2ad7-14c9-46ab-8a1f-08db6bf08a85', 1, N'Updating subscription for build 1126', N'Update Sent', NULL, NULL, CAST(N'2023-06-13T14:04:23.8613606' AS DateTime2), CAST(N'2023-06-13T13:58:22.7035714' AS DateTime2))
GO
/****** Object:  Index [IX_AspNetRoleClaims_RoleId]    Script Date: 12-Sep-23 11:08:11 AM ******/
CREATE NONCLUSTERED INDEX [IX_AspNetRoleClaims_RoleId] ON [dbo].[AspNetRoleClaims]
(
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [RoleNameIndex]    Script Date: 12-Sep-23 11:08:11 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [RoleNameIndex] ON [dbo].[AspNetRoles]
(
	[NormalizedName] ASC
)
WHERE ([NormalizedName] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_AspNetUserClaims_UserId]    Script Date: 12-Sep-23 11:08:11 AM ******/
CREATE NONCLUSTERED INDEX [IX_AspNetUserClaims_UserId] ON [dbo].[AspNetUserClaims]
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_AspNetUserLogins_UserId]    Script Date: 12-Sep-23 11:08:11 AM ******/
CREATE NONCLUSTERED INDEX [IX_AspNetUserLogins_UserId] ON [dbo].[AspNetUserLogins]
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_AspNetUserPersonalAccessTokens_ApplicationUserId_Name]    Script Date: 12-Sep-23 11:08:11 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_AspNetUserPersonalAccessTokens_ApplicationUserId_Name] ON [dbo].[AspNetUserPersonalAccessTokens]
(
	[ApplicationUserId] ASC,
	[Name] ASC
)
WHERE ([Name] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_AspNetUserRoles_RoleId]    Script Date: 12-Sep-23 11:08:11 AM ******/
CREATE NONCLUSTERED INDEX [IX_AspNetUserRoles_RoleId] ON [dbo].[AspNetUserRoles]
(
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [EmailIndex]    Script Date: 12-Sep-23 11:08:11 AM ******/
CREATE NONCLUSTERED INDEX [EmailIndex] ON [dbo].[AspNetUsers]
(
	[NormalizedEmail] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UserNameIndex]    Script Date: 12-Sep-23 11:08:11 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [UserNameIndex] ON [dbo].[AspNetUsers]
(
	[NormalizedUserName] ASC
)
WHERE ([NormalizedUserName] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_AssetLocations_AssetId]    Script Date: 12-Sep-23 11:08:11 AM ******/
CREATE NONCLUSTERED INDEX [IX_AssetLocations_AssetId] ON [dbo].[AssetLocations]
(
	[AssetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Assets_BuildId]    Script Date: 12-Sep-23 11:08:11 AM ******/
CREATE NONCLUSTERED INDEX [IX_Assets_BuildId] ON [dbo].[Assets]
(
	[BuildId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Assets_Name_Version]    Script Date: 12-Sep-23 11:08:11 AM ******/
CREATE NONCLUSTERED INDEX [IX_Assets_Name_Version] ON [dbo].[Assets]
(
	[Name] ASC,
	[Version] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_BuildChannels_ChannelId]    Script Date: 12-Sep-23 11:08:11 AM ******/
CREATE NONCLUSTERED INDEX [IX_BuildChannels_ChannelId] ON [dbo].[BuildChannels]
(
	[ChannelId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_BuildDependencies_DependentBuildId]    Script Date: 12-Sep-23 11:08:11 AM ******/
CREATE NONCLUSTERED INDEX [IX_BuildDependencies_DependentBuildId] ON [dbo].[BuildDependencies]
(
	[DependentBuildId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_BuildIncoherencies_BuildId]    Script Date: 12-Sep-23 11:08:11 AM ******/
CREATE NONCLUSTERED INDEX [IX_BuildIncoherencies_BuildId] ON [dbo].[BuildIncoherencies]
(
	[BuildId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Channels_Name]    Script Date: 12-Sep-23 11:08:11 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Channels_Name] ON [dbo].[Channels]
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_DefaultChannels_ChannelId]    Script Date: 12-Sep-23 11:08:11 AM ******/
CREATE NONCLUSTERED INDEX [IX_DefaultChannels_ChannelId] ON [dbo].[DefaultChannels]
(
	[ChannelId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_DefaultChannels_Repository_Branch_ChannelId]    Script Date: 12-Sep-23 11:08:11 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_DefaultChannels_Repository_Branch_ChannelId] ON [dbo].[DefaultChannels]
(
	[Repository] ASC,
	[Branch] ASC,
	[ChannelId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_DependencyFlowEvents_BuildId]    Script Date: 12-Sep-23 11:08:11 AM ******/
CREATE NONCLUSTERED INDEX [IX_DependencyFlowEvents_BuildId] ON [dbo].[DependencyFlowEvents]
(
	[BuildId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_GoalTime_ChannelId]    Script Date: 12-Sep-23 11:08:11 AM ******/
CREATE NONCLUSTERED INDEX [IX_GoalTime_ChannelId] ON [dbo].[GoalTime]
(
	[ChannelId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_LongestBuildPaths_ChannelId]    Script Date: 12-Sep-23 11:08:11 AM ******/
CREATE NONCLUSTERED INDEX [IX_LongestBuildPaths_ChannelId] ON [dbo].[LongestBuildPaths]
(
	[ChannelId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_RepositoryBranchUpdateHistory_RepositoryName_BranchName_SysEndTime_SysStartTime]    Script Date: 12-Sep-23 11:08:11 AM ******/
CREATE NONCLUSTERED INDEX [IX_RepositoryBranchUpdateHistory_RepositoryName_BranchName_SysEndTime_SysStartTime] ON [dbo].[RepositoryBranchUpdateHistory]
(
	[RepositoryName] ASC,
	[BranchName] ASC,
	[SysEndTime] ASC,
	[SysStartTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Subscriptions_ChannelId]    Script Date: 12-Sep-23 11:08:11 AM ******/
CREATE NONCLUSTERED INDEX [IX_Subscriptions_ChannelId] ON [dbo].[Subscriptions]
(
	[ChannelId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Subscriptions_LastAppliedBuildId]    Script Date: 12-Sep-23 11:08:11 AM ******/
CREATE NONCLUSTERED INDEX [IX_Subscriptions_LastAppliedBuildId] ON [dbo].[Subscriptions]
(
	[LastAppliedBuildId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_SubscriptionUpdateHistory_SubscriptionId_SysEndTime_SysStartTime]    Script Date: 12-Sep-23 11:08:11 AM ******/
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
