-- **What range of years for baseball games played does the provided database cover? 1871-2016
-- select min(yearid), max(yearid)
-- from teams


--** Find the name and height of the shortest player in the database. Edward Carl 43, 1 game, SLA
-- How many games did he play in? What is the name of the team for which he played? 
-- SELECT playerid,namefirst   --other version
-- 		,namelast
-- 		,namegiven
-- 		,height
-- 		,g_all
-- 		,teamid
-- FROM people				
-- 	INNER JOIN appearances
-- 	USING (playerid)
-- WHERE height IN 
-- 			(SELECT MIN(height) AS shorty
-- 				FROM people);

-- SELECT   --- michael version
-- 	CONCAT(namefirst, '_', namelast) AS name, height, g_all AS games, t.name AS team

-- FROM
-- 	people AS p

-- inner JOIN appearances AS a
-- 	ON p.playerid = a.playerid
-- inner JOIN 
-- 	teams AS t
-- 	ON a.teamID = t.teamID
-- where height  =
-- 			(SELECT MIN(height)
-- 			FROM people)

-- LIMIT 1;
-- SELECT 
--     namefirst,
--     namelast,
--     height,
--     name AS team_name,
-- 	appearances.g_all AS total_games
-- FROM 
-- 	people 
-- 	INNER JOIN 
-- 	appearances USING (playerID)
-- 	inner JOIN 
-- 	teams using (teamID)
-- WHERE 
-- 	height = (SELECT 
-- 				MIN(height) 
-- 			   FROM people)
-- limit 1;
-- **Find all players in the database who played at Vanderbilt University. 
--Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. 
--Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors? david price
-- select
--   CONCAT(namefirst, '_', namelast) AS name, -- full name
--   SUM(salary::NUMERIC::MONEY) AS total_salary -- salary
-- from
--   people
--   inner join collegeplaying using (playerid)
--   inner join schools using (schoolid)
--   left join salaries on people.playerid = salaries.playerid
-- where
--   schoolid = 'vandy' -- vandy is schoolid for vanderbilt
--   and salary is not null
--  group by name
-- order by
--   total_salary desc;


-- **4 Using the fielding table, group players into three groups based on their position: 
--label players with position OF as "Outfield", 
--those with position "SS", "1B", "2B", and "3B" as "Infield", 
--and those with position "P" or "C" as "Battery". 
-- Determine the number of putouts made by each of these three groups in 2016.
-- 41424	"Battery"
-- 58934	"Infield"
-- 29560	"Outfield"

-- select sum(PO) as sum_position, -- total for each position
-- 	CASE
-- 		WHEN pos = 'OF' then 'Outfield'
-- 		WHEN pos = 'SS' or pos='1B' or pos='2B' or pos='3B' then 'Infield'
-- 		WHEN pos = 'P' or pos='C' then 'Battery' 
-- 		else 'NA'
-- 		end as position_group
-- from fielding
-- where yearid = '2016'
-- group by position_group



-- 5 Find the average number of strikeouts per game by decade since 1920. 
-- Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
-- use batters




--'**' Find the player who had the most success stealing bases in 2016,
--where success is measured as the percentage of stolen base attempts which are successful. 
--(A stolen base attempt results either in a stolen base or being caught stealing.)
--Consider only players who attempted at least 20 stolen bases.
select
  CONCAT (namefirst, '_', namelast) AS name, -- full name,
  SB as stolen_bases,
  CS as failed_steals, --raw nums for success
  round(SB * 100 / sum(SB + CS))
  -- SB*100/(sum(CS+SB)) 
  as successful_percent
from
  people
  inner join batting using (playerid)
where
  (SB + cs) >= '20'
  and yearid = '2016'
  and CS is not Null
group by
  Name,
  stolen_bases,
  failed_steals
order by
  successful_percent desc



-- From 1970 – 2016, what is the largest number of wins for a team that did not win the world series?
--What is the smallest number of wins for a team that did win the world series? 
-- Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case.
-- Then redo your query, excluding the problem year. 
-- How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?





-- Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 
--(where average attendance is defined as total attendance divided by number of games). 
--Only consider parks where there were at least 10 games played. 
--Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.
select park, team, games, attendance
from homegames
where yearid='2016'
order by attendance desc
limit 5

-- Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? 
--Give their full name and the teams that they were managing when they won the award.





-- Find all players who hit their career highest number of home runs in 2016. 
--Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. 
--Report the players' first and last names and the number of home runs they hit in 2016.







-- Is there any correlation between number of wins and team salary? 
--Use data from 2000 and later to answer this question. 
--As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.

-- In this question, you will explore the connection between number of wins and attendance.

-- Does there appear to be any correlation between attendance at home games and number of wins?
-- Do teams that win the world series see a boost in attendance the following year?
--What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.
-- It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective.
--Investigate this claim and present evidence to either support or dispute this claim.
-- First, determine just how rare left-handed pitchers are compared with right-handed pitchers.
-- Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?