USE [master]
GO
/****** Object:  Database [blogPost]    Script Date: 1/7/2021 10:42:59 AM ******/
CREATE DATABASE [blogPost]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'blogPost', FILENAME = N'c:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\blogPost.mdf' , SIZE = 3136KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'blogPost_log', FILENAME = N'c:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\blogPost_log.ldf' , SIZE = 832KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [blogPost] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [blogPost].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [blogPost] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [blogPost] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [blogPost] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [blogPost] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [blogPost] SET ARITHABORT OFF 
GO
ALTER DATABASE [blogPost] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [blogPost] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [blogPost] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [blogPost] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [blogPost] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [blogPost] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [blogPost] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [blogPost] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [blogPost] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [blogPost] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [blogPost] SET  ENABLE_BROKER 
GO
ALTER DATABASE [blogPost] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [blogPost] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [blogPost] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [blogPost] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [blogPost] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [blogPost] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [blogPost] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [blogPost] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [blogPost] SET  MULTI_USER 
GO
ALTER DATABASE [blogPost] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [blogPost] SET DB_CHAINING OFF 
GO
ALTER DATABASE [blogPost] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [blogPost] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
USE [blogPost]
GO
/****** Object:  StoredProcedure [dbo].[blogManage]    Script Date: 1/7/2021 10:42:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[blogManage](


@userCode nvarchar(50),
@blogText text,

@commentText text,
@blogCode varchar(36),

@likeDeslikeCode varchar(36),
@likeDeslike varchar(5),
@commentCode varchar(36),

@Flag varchar(36)
)

AS
BEGIN
	
	 if(@Flag='AllBlogs')
	 begin
	 select * from Blogs;
	 end

	 if(@Flag='Report')
	 begin
		
		select Blogs.blogCode,Blogs.blogText,Blogs.userCode,userName as bloger
		,Comments.commentCode,Comments.commentText,Comments.userCode as commenterCode

		,(select users.userName from Users where Comments.userCode=Users.userCode) as commenter
		,(select COUNT(LikeDeslikes.id) from LikeDeslikes where LikeDeslikes.commentCode = Comments.commentCode and LikeDeslikes.likeDeslike='L' ) as liked,
		(select COUNT(LikeDeslikes.id) from LikeDeslikes where LikeDeslikes.commentCode = Comments.commentCode and LikeDeslikes.likeDeslike='d' ) as disLiked
		,Blogs.timestamp,Comments.timestamp, isnull((select LikeDeslikes.likeDeslike from LikeDeslikes where likeDeslikes.userCode=@userCode and likeDeslikes.commentCode=Comments.commentCode),'N') as myStaus
		from Blogs
		inner join users on Blogs.userCode = users.userCode
		inner join Comments on Comments.blogCode=Blogs.blogCode
		


	 end

	 if(@Flag='BlogWiseComment')
	 begin
	  select * from Comments where blogCode=@blogCode order by (timestamp) desc;
	 end


	if(@Flag='insertBlogs')
	begin
	 insert into Blogs(userCode,blogText)
	 values(@userCode,@blogText) 
	end

	if(@Flag='insertComments')
	begin 
		 insert into Comments(commentText,userCode,blogCode)
	 values(@commentText,@userCode,@blogCode) 
	end
	
   if(@Flag='likeDeslike')
	begin
		declare @isAvialble int; 
		 set @isAvialble=ISNULL((select 1 from LikeDeslikes where userCode=@userCode and commentCode=@commentCode),-1);
		 if(@isAvialble=1)
			 begin
			 update LikeDeslikes
			 set likeDeslike=@likeDeslike
			 where userCode=@userCode and commentCode=@commentCode
		 end
		else
		 begin
			 insert into LikeDeslikes(userCode,commentCode,likeDeslike)
			 values(@userCode,@commentCode,@likeDeslike)
		 end
	end

END


GO
/****** Object:  StoredProcedure [dbo].[userInfo]    Script Date: 1/7/2021 10:42:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[userInfo](

@name nvarchar(50),
@Flag varchar(36)
)

AS
BEGIN
	
	if(@Flag='insert')
	begin
	 insert into Users(userName)
	 values(@name) 
	end

	if(@Flag='isAvailable')
	begin
	select * from users where userName=@name;
	end

END


GO
/****** Object:  Table [dbo].[Blogs]    Script Date: 1/7/2021 10:42:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Blogs](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[blogCode] [varchar](36) NOT NULL,
	[userCode] [varchar](36) NOT NULL,
	[blogText] [text] NULL,
	[timestamp] [datetime] NOT NULL,
 CONSTRAINT [PK_blogs] PRIMARY KEY CLUSTERED 
(
	[blogCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Comments]    Script Date: 1/7/2021 10:42:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Comments](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[commentCode] [varchar](36) NOT NULL,
	[commentText] [text] NULL,
	[blogCode] [varchar](36) NOT NULL,
	[userCode] [varchar](36) NOT NULL,
	[timestamp] [datetime] NOT NULL,
 CONSTRAINT [PK_comments] PRIMARY KEY CLUSTERED 
(
	[commentCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LikeDeslikes]    Script Date: 1/7/2021 10:42:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LikeDeslikes](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[likeDeslikeCode] [varchar](36) NOT NULL,
	[likeDeslike] [varchar](5) NOT NULL,
	[timestamp] [datetime] NOT NULL,
	[userCode] [varchar](36) NOT NULL,
	[commentCode] [varchar](36) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Users]    Script Date: 1/7/2021 10:42:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Users](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[userCode] [varchar](36) NOT NULL,
	[userName] [nvarchar](50) NOT NULL,
	[timestamp] [datetime] NOT NULL,
 CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED 
(
	[userCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET IDENTITY_INSERT [dbo].[Blogs] ON 

INSERT [dbo].[Blogs] ([id], [blogCode], [userCode], [blogText], [timestamp]) VALUES (1, N'464DB6CF-6CB8-4CED-87CA-60ABC16645C7', N'4108A820-0443-493D-81D9-CF90B26CACC5', NULL, CAST(0x0000ACA9001AE5EF AS DateTime))
INSERT [dbo].[Blogs] ([id], [blogCode], [userCode], [blogText], [timestamp]) VALUES (3, N'6807E21E-81B8-4212-95B6-CA17901A5404', N'4108A820-0443-493D-81D9-CF90B26CACC5', N'Ul_oppid', CAST(0x0000ACA9001C85E6 AS DateTime))
INSERT [dbo].[Blogs] ([id], [blogCode], [userCode], [blogText], [timestamp]) VALUES (2, N'EFCD1409-506D-4080-8A29-05FC6FD7C4F3', N'4108A820-0443-493D-81D9-CF90B26CACC5', N'Hello', CAST(0x0000ACA9001B5697 AS DateTime))
SET IDENTITY_INSERT [dbo].[Blogs] OFF
SET IDENTITY_INSERT [dbo].[Comments] ON 

INSERT [dbo].[Comments] ([id], [commentCode], [commentText], [blogCode], [userCode], [timestamp]) VALUES (7, N'031EB076-0CC2-4B95-B1EB-2BCDD4BBF652', N'akjs', N'6807E21E-81B8-4212-95B6-CA17901A5404', N'4108A820-0443-493D-81D9-CF90B26CACC5', CAST(0x0000ACA90035CB88 AS DateTime))
INSERT [dbo].[Comments] ([id], [commentCode], [commentText], [blogCode], [userCode], [timestamp]) VALUES (8, N'81A34124-9C8F-4610-8F5B-767E494068D0', N'hjha', N'EFCD1409-506D-4080-8A29-05FC6FD7C4F3', N'4108A820-0443-493D-81D9-CF90B26CACC5', CAST(0x0000ACA90035F99E AS DateTime))
INSERT [dbo].[Comments] ([id], [commentCode], [commentText], [blogCode], [userCode], [timestamp]) VALUES (5, N'A41E896D-FD7F-4819-8CF3-F4D8B12C307E', N'sas', N'6807E21E-81B8-4212-95B6-CA17901A5404', N'4108A820-0443-493D-81D9-CF90B26CACC5', CAST(0x0000ACA9003433A2 AS DateTime))
INSERT [dbo].[Comments] ([id], [commentCode], [commentText], [blogCode], [userCode], [timestamp]) VALUES (3, N'DAFD38A7-8F0A-4664-B630-284F223793E0', N'Good', N'6807E21E-81B8-4212-95B6-CA17901A5404', N'4108A820-0443-493D-81D9-CF90B26CACC5', CAST(0x0000ACA9003361EC AS DateTime))
INSERT [dbo].[Comments] ([id], [commentCode], [commentText], [blogCode], [userCode], [timestamp]) VALUES (6, N'E2B1187A-6F5E-4403-995F-516C3D23EDF4', N'weew', N'6807E21E-81B8-4212-95B6-CA17901A5404', N'4108A820-0443-493D-81D9-CF90B26CACC5', CAST(0x0000ACA900353692 AS DateTime))
INSERT [dbo].[Comments] ([id], [commentCode], [commentText], [blogCode], [userCode], [timestamp]) VALUES (4, N'E4DEC610-BFA8-427B-9043-05E32D15E9E3', N'Good', N'6807E21E-81B8-4212-95B6-CA17901A5404', N'4108A820-0443-493D-81D9-CF90B26CACC5', CAST(0x0000ACA9003372AA AS DateTime))
SET IDENTITY_INSERT [dbo].[Comments] OFF
SET IDENTITY_INSERT [dbo].[LikeDeslikes] ON 

INSERT [dbo].[LikeDeslikes] ([id], [likeDeslikeCode], [likeDeslike], [timestamp], [userCode], [commentCode]) VALUES (1, N'2E0AFAED-54FC-46EE-9883-528E2C02285E', N'L', CAST(0x0000ACA900ABCF72 AS DateTime), N'4108A820-0443-493D-81D9-CF90B26CACC5', N'DAFD38A7-8F0A-4664-B630-284F223793E0')
INSERT [dbo].[LikeDeslikes] ([id], [likeDeslikeCode], [likeDeslike], [timestamp], [userCode], [commentCode]) VALUES (2, N'ABB34FBE-6284-4290-AE65-E52486A6D712', N'L', CAST(0x0000ACA900AC25EB AS DateTime), N'4108A820-0443-493D-81D9-CF90B26CACC5', N'A41E896D-FD7F-4819-8CF3-F4D8B12C307E')
SET IDENTITY_INSERT [dbo].[LikeDeslikes] OFF
SET IDENTITY_INSERT [dbo].[Users] ON 

INSERT [dbo].[Users] ([id], [userCode], [userName], [timestamp]) VALUES (1, N'073098D0-FCB0-47C9-9DB1-4CB2B2A4C27A', N'ss', CAST(0x0000ACA80182A495 AS DateTime))
INSERT [dbo].[Users] ([id], [userCode], [userName], [timestamp]) VALUES (5, N'1D73A2F7-2506-44F0-9E57-722EA4CDC50B', N'SO', CAST(0x0000ACA8018411F6 AS DateTime))
INSERT [dbo].[Users] ([id], [userCode], [userName], [timestamp]) VALUES (2, N'3D3314D8-2488-4B65-8348-16DC712E5DE0', N'Ep', CAST(0x0000ACA80183048C AS DateTime))
INSERT [dbo].[Users] ([id], [userCode], [userName], [timestamp]) VALUES (6, N'4108A820-0443-493D-81D9-CF90B26CACC5', N'Emdad', CAST(0x0000ACA90012491A AS DateTime))
INSERT [dbo].[Users] ([id], [userCode], [userName], [timestamp]) VALUES (4, N'6F0B900A-9655-4DC4-9FFD-00D16545B6C7', N'aakj', CAST(0x0000ACA801837D9F AS DateTime))
INSERT [dbo].[Users] ([id], [userCode], [userName], [timestamp]) VALUES (7, N'AF285A3E-1FB7-4A46-8C48-4DDB63C4213D', N'Emdad2', CAST(0x0000ACA900136F09 AS DateTime))
INSERT [dbo].[Users] ([id], [userCode], [userName], [timestamp]) VALUES (3, N'EBB4511F-D287-4C5F-BB7B-252191CB8906', N'Ep', CAST(0x0000ACA80183452A AS DateTime))
SET IDENTITY_INSERT [dbo].[Users] OFF
ALTER TABLE [dbo].[Blogs] ADD  CONSTRAINT [DF_blogs_blogCode]  DEFAULT (newid()) FOR [blogCode]
GO
ALTER TABLE [dbo].[Blogs] ADD  CONSTRAINT [DF_blogs_timestamp]  DEFAULT (getdate()) FOR [timestamp]
GO
ALTER TABLE [dbo].[Comments] ADD  CONSTRAINT [DF_comments_commentCode]  DEFAULT (newid()) FOR [commentCode]
GO
ALTER TABLE [dbo].[Comments] ADD  CONSTRAINT [DF_comments_timestamp]  DEFAULT (getdate()) FOR [timestamp]
GO
ALTER TABLE [dbo].[LikeDeslikes] ADD  CONSTRAINT [DF_likeDeslikes_likeDeslikeCode]  DEFAULT (newid()) FOR [likeDeslikeCode]
GO
ALTER TABLE [dbo].[LikeDeslikes] ADD  CONSTRAINT [DF_LikeDeslikes_likeDeslike]  DEFAULT ('N') FOR [likeDeslike]
GO
ALTER TABLE [dbo].[LikeDeslikes] ADD  CONSTRAINT [DF_likeDeslikes_timestamp]  DEFAULT (getdate()) FOR [timestamp]
GO
ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [DF_Users_userCode]  DEFAULT (newid()) FOR [userCode]
GO
ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [DF_Users_timestamp]  DEFAULT (getdate()) FOR [timestamp]
GO
ALTER TABLE [dbo].[LikeDeslikes]  WITH CHECK ADD  CONSTRAINT [CK__likeDesli__likeD__36B12243] CHECK  (([likeDeslike]='D' OR [likeDeslike]='N' OR [likeDeslike]='L'))
GO
ALTER TABLE [dbo].[LikeDeslikes] CHECK CONSTRAINT [CK__likeDesli__likeD__36B12243]
GO
USE [master]
GO
ALTER DATABASE [blogPost] SET  READ_WRITE 
GO
