/*****************************************************************************************************************
NAME:    EC_IT143_W5.2_EPL_xx
PURPOSE: Final Project - My Communities Analysis - Create Answers (EPL 2022-23)

MODIFICATION LOG:
Ver      Date        Author        Description
-----   ----------   -----------   -------------------------------------------------------------------------------
1.0     10/10/2026   [INITIALES]   1. Built this script for EC IT143


RUNTIME: 
0m 1s

NOTES: 
This script answers four questions about the English Premier League 2022-23 data set
(tables: dbo.[epl_results_2022-23], dbo.[epl_clubs_info_2022-23], dbo.tbl_EPL_TotalHomeGoals).
Each question lists its original author. Question 4 uses a view and a CTE.
 
******************************************************************************************************************/

USE [MY communuties];
GO

-- Q1: Which team scored the most goals at home?
-- Author of the question: [Votre nom]
-- A1: Read the pre-aggregated table tbl_EPL_TotalHomeGoals and keep the top row.

SELECT TOP 1
       HomeTeam,
       TotalHomeGoals
FROM   dbo.tbl_EPL_TotalHomeGoals
ORDER BY TotalHomeGoals DESC;
GO

-- Q2: For each home team, what is the average number of goals scored at home (FTHG) and the average number of shots on target (HST) during the 2022-23 season?
-- Author of the question: [Nom de l'étudiant]
-- A2: Group epl_results_2022-23 by HomeTeam and average FTHG and HST (1.0 * forces decimal averages, not integer ones).

SELECT HomeTeam,
       COUNT(*)                                AS HomeMatches,
       CAST(AVG(1.0 * FTHG) AS DECIMAL(4,2))   AS AvgHomeGoals,
       CAST(AVG(1.0 * HST)  AS DECIMAL(4,2))   AS AvgHomeShotsOnTarget
FROM   dbo.[epl_results_2022-23]
GROUP BY HomeTeam
ORDER BY AvgHomeGoals DESC;
GO

-- Q3: Which referee officiated the most matches, and how many yellow cards does he give per match on average?
-- Author of the question: [Votre nom]
-- A3: Group by referee, count matches, average HY + AY, keep referees with at least 10 matches.

SELECT Referee,
       COUNT(*) AS MatchesRefereed,
       CAST(AVG(1.0 * (HY + AY)) AS DECIMAL(4,2)) AS AvgYellowPerMatch
FROM   dbo.[epl_results_2022-23]
GROUP BY Referee
HAVING COUNT(*) >= 10
ORDER BY MatchesRefereed DESC, AvgYellowPerMatch DESC;
GO

-- Q4: What is the final league table (points) of each club?
-- Author of the question: [Votre nom ou autre étudiant]
-- A4: Build a view that stacks home and away rows (CTE + UNION ALL), then sum points (win = 3, draw = 1).

CREATE OR ALTER VIEW dbo.v_EPL_LeagueTable
AS
WITH TeamMatches AS
(
    SELECT HomeTeam AS Team,
           CASE FTR WHEN 'H' THEN 3 WHEN 'D' THEN 1 ELSE 0 END AS Pts,
           FTHG AS GoalsFor,
           FTAG AS GoalsAgainst
    FROM   dbo.[epl_results_2022-23]
    UNION ALL
    SELECT AwayTeam,
           CASE FTR WHEN 'A' THEN 3 WHEN 'D' THEN 1 ELSE 0 END,
           FTAG,
           FTHG
    FROM   dbo.[epl_results_2022-23]
)
SELECT Team,
       COUNT(*)                      AS Played,
       SUM(Pts)                      AS Points,
       SUM(GoalsFor)                 AS GoalsFor,
       SUM(GoalsAgainst)             AS GoalsAgainst,
       SUM(GoalsFor - GoalsAgainst)  AS GoalDiff
FROM   TeamMatches
GROUP BY Team;
GO

SELECT *
FROM   dbo.v_EPL_LeagueTable
ORDER BY Points DESC, GoalDiff DESC;
GO
