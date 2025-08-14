-- What range of years for baseball games played does the provided database cover? 1871-2016

SELECT MAX(year) AS latest_year
	,MIN(year) AS earliest_year
FROM homegames;

-- Find the name and height of the shortest player in the database.
-- How many games did he play in? What is the name of the team for which he played?

SELECT namefirst
		,namelast
		,namegiven
		,height
FROM people
WHERE height IN 
			(SELECT MIN(height) AS shorty
				FROM people);
				
-- Draft for second part: 

SELECT namefirst
		,namelast
		,namegiven
		,height
		,g_all
		,teamid
		,name AS team_name
FROM people
	INNER JOIN appearances
		USING (playerid)
	LEFT JOIN teams
		USING (teamid)
WHERE height IN 
			(SELECT MIN(height) AS shorty
				FROM people)
				LIMIT 1;

-- This returns the team name:

SELECT namefirst
		,namelast
		,namegiven
		,height
		,g_all
		,name as team_name
FROM people
	INNER JOIN appearances
	USING (playerid)
	INNER JOIN teams
	USING (teamid)
WHERE height IN 
			(SELECT MIN(height) AS shorty
				FROM people)
LIMIT 1;

-- Group Code:


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

-- Find all players in the database who played at Vanderbilt University. 
-- Create a list showing each player’s first and last names as well as the total salary
-- they earned in the major leagues. 
-- Sort this list in descending order by the total salary earned. 
-- Which Vanderbilt player earned the most money in the majors? David Taylor


SELECT namefirst
		,namelast
		,SUM(salary::NUMERIC::MONEY) AS total_salary
FROM people
INNER JOIN collegeplaying
	USING (playerid)
INNER JOIN schools
	USING (schoolid)
LEFT JOIN salaries
	USING (playerid)
WHERE schoolid = 'vandy'
AND salary IS NOT NULL
GROUP BY namefirst
		,namelast
ORDER BY total_salary DESC;


-- Using the fielding table, group players into three groups based on their position: 
-- label players with position OF as "Outfield", those with position "SS", "1B", "2B", 
-- and "3B" as "Infield", and those with position "P" or "C" as "Battery". 
-- Determine the number of putouts made by each of these three groups in 2016.


SELECT SUM(po) AS sum_po
		,CASE 
			WHEN pos = 'OF' THEN 'Outfield'
			WHEN pos = 'SS' OR pos = '1B' OR pos = '2B' OR pos ='3B' THEN 'Infield'
			WHEN pos = 'P' OR pos ='C' THEN 'Battery'
			ELSE 'N/A'
			END AS position
FROM fielding
WHERE yearid = 2016
GROUP BY position;


-- Find the average number of strikeouts per game by decade since 1920. 
-- Round the numbers you report to 2 decimal places. 
-- Do the same for home runs per game. Do you see any trends?


SELECT (FLOOR(yearid/10) * 10) AS decade
		,COALESCE(ROUND(SUM(so::numeric)/SUM(g::numeric), 2), 0) AS avg_so
		,COALESCE(ROUND(SUM(hr::numeric)/SUM(g::numeric), 2), 0) AS avg_hr
FROM batting
GROUP BY decade;


-- Find the player who had the most success stealing bases in 2016, 
-- where success is measured as the percentage of stolen base attempts which are successful.
-- (A stolen base attempt results either in a stolen base or being caught stealing.) 
-- Consider only players who attempted at least 20 stolen bases.

--My version

SELECT namegiven
		,CONCAT(
			ROUND((sb::NUMERIC/(sb::NUMERIC + cs::NUMERIC))* 100, 2), '%') 
				AS sb_percent
FROM batting
	INNER JOIN people
		USING(playerid)
WHERE yearid = 2016
AND (sb + cs) >= 20
ORDER BY sb_percent DESC;


--Michael's
SELECT
--SUM's so we can check our math and/or for accuracy
	CONCAT(
	p.namefirst, '_', p.namelast
	) AS player,
	SUM(cs) AS caught_stealing,
	SUM(sb) AS stolen_bases,
	SUM(cs+sb) AS attempts,
--CONCAT to add % SUM and ROUND * 100.0 to ensure we get a decimal and it remains readable
	CONCAT(
	ROUND(
		SUM(sb) * 100.0 / (SUM(cs + sb)), 2),
		'%') AS success_percent
FROM
	batting AS fp
	RIGHT JOIN people AS p
	ON fp.playerid = p.playerid
WHERE 
	yearid= '2016'
	-- ENSURE only players with 20+ attempts are counted
	and (cs+sb) >=20

GROUP BY
	p.playerid
ORDER BY
	success_percent DESC
;

-- From 1970 – 2016, what is the largest number of wins for a team 
-- that did not win the world series? Seattle Mariners 116
-- What is the smallest number of wins for a team that did win the world series? 
-- Doing this will probably result in an unusually small number of wins for 
-- a world series champion – determine why this is the case. 
-- Then redo your query, excluding the problem year. How often from 1970 – 2016 
-- was it the case that a team with the most wins also won the world series? 
-- What percentage of the time?

-- Most Wins
SELECT name
		,MAX(w) AS most_wins
FROM teams
WHERE wswin = 'N'
AND yearid BETWEEN 1970 AND 2016
GROUP BY name
ORDER BY most_wins DESC;


-- Least Wins
SELECT name
		,MIN(w) AS least_wins
		,yearid
FROM teams
WHERE wswin = 'Y'
AND yearid BETWEEN 1970 AND 2016
GROUP BY name, yearid
ORDER BY least_wins;


-- May God have mercy on me for NewForce has not
WITH big_filter AS(
	WITH yw_filter AS (
		SELECT yearid
		,MAX(w) AS most_wins
	FROM teams
	GROUP BY yearid
	) SELECT DISTINCT yearid
			,name
			,w
	FROM teams
		INNER JOIN yw_filter
			USING (yearid)
	WHERE wswin = 'Y'
		AND yearid BETWEEN 1970 AND 2016
		AND yearid <> 1981
		AND w = most_wins
	GROUP BY name, yearid, w
	ORDER BY yearid
	) SELECT TO_CHAR(((COUNT(*)::NUMERIC)/(2016-1971) * 100), 'FM990.00%')
		AS percent_maxw_and_ws
	FROM big_filter;



-- Using the attendance figures from the homegames table, find the teams 
-- and parks which had the top 5 average attendance per game in 2016 
-- (where average attendance is defined as total attendance divided by number of games). 
-- Only consider parks where there were at least 10 games played. Report the park name, 
-- team name, and average attendance. Repeat for the lowest 5 average attendance.


SELECT park
		,attendance
FROM homegames
WHERE games >=10
AND year = 2016;

SELECT *
FROM homegames
WHERE games >=10;

-- Highest average attendance
SELECT DISTINCT park
		,team
		,ROUND(SUM(attendance::NUMERIC)/SUM(games::NUMERIC), 0) AS avg_attendance
FROM homegames
WHERE games >= 10
	AND year = 2016
GROUP BY team
		,park
ORDER BY avg_attendance DESC
LIMIT 5;


-- Lowest average attendance
SELECT DISTINCT park
		,team
		,ROUND(SUM(attendance::NUMERIC)/SUM(games::NUMERIC), 0) AS avg_attendance
FROM homegames
WHERE games >= 10
	AND year = 2016
GROUP BY team
		,park
ORDER BY avg_attendance
LIMIT 5;

-- Which managers have won the TSN Manager of the Year award in both the 
-- National League (NL) and the American League (AL)? 
-- Give their full name and the 
-- teams that they were managing when they won the award.

WITH award_filter AS(
	SELECT DISTINCT playerid
	FROM awardsmanagers
	WHERE awardid = 'TSN Manager of the Year'
		AND lgid = 'AL'
) SELECT DISTINCT(CONCAT(namefirst, ' ', namelast)) AS manager
		,teamid
FROM awardsmanagers
	INNER JOIN award_filter
		USING (playerid)
	INNER JOIN people
		USING (playerid)
	INNER JOIN managers
		USING (playerid)
WHERE awardsmanagers.lgid = 'NL'
ORDER BY manager;





WITH double_awarded AS (
    SELECT 
		playerid
    FROM 
		awardsmanagers
    WHERE awardid LIKE '%TSN%'
        AND lgid IN ('AL', 'NL')
    GROUP BY playerid
    HAVING COUNT(DISTINCT lgid) = 2
)
SELECT 
	DISTINCT CONCAT(p.namefirst, '_', p.namelast) AS manager,
	t.name, 
	am.yearid, 
	am.awardid, 
	am.lgid
FROM 
	awardsmanagers AS am
INNER JOIN double_awarded AS da
    ON am.playerid = da.playerid
LEFT JOIN people AS p
	ON am.playerid = p.playerid
LEFT JOIN managers AS m
	ON am.playerid = m.playerid
	AND am.yearid = m.yearid
LEFT JOIN teams AS t
	ON m.teamid = t.teamid
WHERE am.awardid LIKE '%TSN%'
    AND am.lgid IN ('AL', 'NL')
ORDER BY manager, am.yearid;





-- Find all players who hit their career highest number of home runs in 2016. 
-- Consider only players who have played in the league for at least 10 years,
-- and who hit at least one home run in 2016. 
-- Report the players' first and last names and the number of home runs they hit in 2016.


--Try to use a subquery filtering the career high of home runs, then select all players with
--10 or more years in the league and hr >= 1

SELECT
	CONCAT(namefirst, ' ', namelast) AS player_name,
	b.hr AS hr_2016
FROM
	people p
	INNER JOIN
		batting b USING (playerid)
WHERE
	b.yearid = 2016
	AND b.hr >= 1
	AND (
		SELECT
			COUNT(DISTINCT yearid)
		FROM
			batting
		WHERE
			playerid = b.playerid
	) >= 10 -- subquery to include players w/ at least 10 seasons
	AND b.hr = (
		SELECT
			MAX(hr)
		FROM
			batting
		WHERE
			playerid = b.playerid
	) -- subquery to include players w/ max career HR total occurring in 2016
ORDER BY
	b.hr DESC;



-- In this question, you will explore the connection between number of wins and attendance.

-- Does there appear to be any correlation between attendance at home games and number of wins?
-- Do teams that win the world series see a boost in attendance the following year? 
-- What about teams that made the playoffs? 
-- Making the playoffs means either being a division winner or a wild card winner.

select 
	yearid, 
	teamid, 
	divwin,
	wcwin,
	attendance,
	lag(attendance) 
		over(order by teamid, yearid) 
			as last_year_attendance
from teams
where wcwin is not null or divwin is not null

order by teamid, yearid


SELECT  
	name,
	yearid,
	attendance,
	attendance - (LEAD(attendance) 
		OVER(ORDER BY teamid, yearid) 
			) AS change_attendace,
	wswin,
	case 
	when divwin = 'Y' or wcwin = 'Y' then 'Playoffs made'
	else 'No playoffs'
	end as playoffs
FROM teams
WHERE wcwin IS NOT NULL OR divwin IS NOT NULL

order by teamid, yearid
;

SELECT
    CASE
        WHEN t1.wswin = 'Y' THEN 'WS Winner'
        WHEN t1.divwin = 'Y' OR t1.wcwin = 'Y' THEN 'Playoff Team'
        ELSE 'Non-Playoff'
    END AS team_type,
    ROUND(AVG((t2.attendance - t1.attendance) * 100.0 / t1.attendance), 2) AS avg_pct_change,
    COUNT(*) AS seasons_count
FROM
	teams t1
	INNER JOIN teams t2
   		ON t1.teamid = t2.teamid
   		AND t2.yearid = t1.yearid + 1
WHERE
	t1.attendance IS NOT NULL
  	AND t2.attendance IS NOT NULL
GROUP BY team_type
ORDER BY avg_pct_change DESC;






-- In this question, you will explore the connection between number of wins and attendance.

-- Does there appear to be any correlation between attendance at home games and number of wins?
-- Do teams that win the world series see a boost in attendance the following year? 
-- What about teams that made the playoffs? 
-- Making the playoffs means either being a division winner or a wild card winner.

select 
	yearid, 
	teamid, 
	divwin,
	wcwin,
	attendance,
	lag(attendance) 
		over(order by teamid, yearid) 
			as last_year_attendance
from teams
where wcwin is not null or divwin is not null

order by teamid, yearid


SELECT  
	name,
	yearid,
	attendance,
	attendance - (LEAD(attendance) 
		OVER(ORDER BY teamid, yearid) 
			) AS change_attendace,
	wswin,
	case 
	when divwin = 'Y' or wcwin = 'Y' then 'Playoffs made'
	else 'No playoffs'
	end as playoffs
FROM teams
WHERE wcwin IS NOT NULL OR divwin IS NOT NULL

order by teamid, yearid
;

SELECT
    CASE
        WHEN t1.wswin = 'Y' THEN 'WS Winner'
        WHEN t1.divwin = 'Y' OR t1.wcwin = 'Y' THEN 'Playoff Team'
        ELSE 'Non-Playoff'
    END AS team_type,
    ROUND(AVG((t2.attendance - t1.attendance) * 100.0 / t1.attendance), 2) AS avg_pct_change,
    COUNT(*) AS seasons_count
FROM
	teams t1
	INNER JOIN teams t2
   		ON t1.teamid = t2.teamid
   		AND t2.yearid = t1.yearid + 1
WHERE
	t1.attendance IS NOT NULL
  	AND t2.attendance IS NOT NULL
GROUP BY team_type
ORDER BY avg_pct_change DESC;

