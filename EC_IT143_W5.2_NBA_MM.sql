/*****************************************************************************************************************
NAME:    EC_IT143_W5.2_NBA_xx
PURPOSE: Final Project - My Communities Analysis - Create Answers (NBA)

MODIFICATION LOG:
Ver      Date        Author        Description
-----   ----------   -----------   -------------------------------------------------------------------------------
1.0     10/10/2026   [INITIALES]   1. Built this script for EC IT143


RUNTIME: 
0m 1s

NOTES: 
This script answers four questions about the NBA data set (tables: dbo.NBA, dbo.tbl_NBA_TotalPoints).
One row of dbo.NBA = one team in one game. Each question lists its original author.
Question 4 unpivots Player_1..Player_5 with CROSS APPLY.
 
******************************************************************************************************************/

USE [MY communuties];
GO

-- Q1: Which team scored the most points in total?
-- Author of the question: [Votre nom]
-- A1: Read the pre-aggregated table tbl_NBA_TotalPoints and keep the top row.

SELECT TOP 1
       Team,
       TotalPoints
FROM   dbo.tbl_NBA_TotalPoints
ORDER BY TotalPoints DESC;
GO

-- Q2: Do teams win more often at home than away?
-- Author of the question: [Nom de l'autre étudiant]
-- A2: Group by Home_Away and compute the win percentage (check values first: SELECT DISTINCT Home_Away FROM dbo.NBA;).

SELECT Home_Away,
       COUNT(*)                       AS Games,
       SUM(CAST(Won AS INT))          AS Wins,
       CAST(100.0 * SUM(CAST(Won AS INT)) / COUNT(*)
            AS DECIMAL(5,2))          AS WinPct
FROM   dbo.NBA
GROUP BY Home_Away
ORDER BY WinPct DESC;
GO

-- Q3: Which 10 teams have the highest average points per game?
-- Author of the question: [Votre nom]
-- A3: Group by team, average the Total column, keep teams with at least 20 games.

SELECT TOP 10
       Team,
       COUNT(*)                            AS Games,
       CAST(AVG(1.0 * Total) AS DECIMAL(5,2)) AS AvgPointsPerGame
FROM   dbo.NBA
GROUP BY Team
HAVING COUNT(*) >= 20
ORDER BY AvgPointsPerGame DESC;
GO

-- Q4: Which 10 players scored the most points in total (across the 5 players listed per row)?
-- Author of the question: [Votre nom ou autre étudiant]
-- A4: Unpivot Player_1..Player_5 with CROSS APPLY (VALUES ...), then sum points per player.

SELECT TOP 10
       p.PlayerName,
       SUM(CAST(p.Pts AS INT)) AS TotalPoints,
       COUNT(*)                AS GamesListed
FROM   dbo.NBA AS n
CROSS APPLY (VALUES
        (n.Player_1, n.PTS_player1),
        (n.Player_2, n.PTS_player2),
        (n.Player_3, n.PTS_player3),
        (n.Player_4, n.PTS_player4),
        (n.Player_5, n.PTS_player5)
      ) AS p (PlayerName, Pts)
WHERE  p.PlayerName IS NOT NULL
GROUP BY p.PlayerName
ORDER BY TotalPoints DESC;
GO
