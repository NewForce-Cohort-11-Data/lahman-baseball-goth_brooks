SELECT *
FROM 

-- **Initial Questions**

-- 1. What range of years for baseball games played does the provided database cover? 

SELECT
	MIN(yearid),
	MAX(yearid)
FROM
	teams;
	

-- 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?

SELECT 
    namefirst,
    namelast,
    height,
    name AS team_name,
	g_all AS total_games
FROM 
	people 
	INNER JOIN 
	appearances USING (playerid)
	INNER JOIN
	teams USING (teamid)
WHERE 
	height = (SELECT 
				MIN(height) 
			   FROM people)
LIMIT
	1;


-- 3. Find all players in the database who played at Vanderbilt University. 
-- Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. 
-- Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

SELECT
	CONCAT(namefirst, ' ', namelast) AS player_name,
	COALESCE(SUM(salary), 0)::NUMERIC::MONEY AS total_salary
FROM
	schools
	INNER JOIN
		collegeplaying USING (schoolid)
	INNER JOIN
		people USING (playerid)
	LEFT JOIN
		salaries USING (playerid)
WHERE 
	schoolname ILIKE '%vanderbilt%'
GROUP BY
	namefirst,
	namelast
ORDER BY 
	total_salary DESC;



-- 4. Using the fielding table, group players into three groups based on their position: 
-- label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", 
-- and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

SELECT
	CASE 
		WHEN pos = 'OF' THEN 'Outfield'
		WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
		WHEN pos IN ('P', 'C') THEN 'Battery'
	END as position_group,
	SUM(po) AS total_putouts
FROM
	fielding
WHERE
	yearid = 2016
GROUP BY
	position_group
ORDER BY 
	total_putouts DESC;


SELECT
	CASE 
		WHEN pos = 'OF' THEN 'Outfield'
		WHEN pos = 'SS' OR pos = '1B' OR pos = '2B' OR pos = '3B' THEN 'Infield'
		WHEN pos = 'P' OR pos = 'C' THEN 'Battery'
	END as position_group,
	SUM(po) AS total_putouts
FROM
	fielding
WHERE
	yearid = 2016
GROUP BY
	position_group
ORDER BY 
	total_putouts DESC;

-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places.
-- Do the same for home runs per game. Do you see any trends?

SELECT
	(FLOOR(yearid / 10) * 10) AS decade,
	ROUND(SUM(so)::DECIMAL / SUM(g), 2) AS so_per_game,
	ROUND(SUM(hr)::DECIMAL / SUM(g), 2) AS hr_per_game
FROM
	teams
WHERE yearid >= 1920
GROUP BY
	decade
ORDER BY
	decade;


-- 6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. 
-- (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.

-- sb = stolen bases ; cs = caught stealing 	

SELECT
	CONCAT(namefirst, ' ', namelast) AS player_name,
	sb AS stolen_bases,
	cs AS caught_stealing,
-- this format is more common in baseball
	ROUND(sb::DECIMAL / (sb +cs), 3) AS success_rate
FROM
	batting
	INNER JOIN
		people USING (playerid)
WHERE 
	yearid = 2016
	AND (sb + cs) >= 20
ORDER BY
	success_rate DESC;
	
	
-- 7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? 
-- What is the smallest number of wins for a team that did win the world series? 
-- Doing this will probably result in an unusually small number of wins for a world series champion
-- – determine why this is the case. Then redo your query, excluding the problem year. 
-- How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? 
-- What percentage of the time?

-- Largest wins w/o WS title
SELECT 
	yearid
	franchid,
	w AS wins
FROM
	teams
WHERE 
	yearid BETWEEN 1970 AND 2016
	AND wswin = 'N'
ORDER BY
	w DESC;

--Smallest wins w/ WS title
--Unusual low wins 63 in 1981 likely d/t a strike-shortened sease ; Dodgers ~110 games played
SELECT 
	yearid,
	franchid,
	w AS wins
FROM
	teams
WHERE 
	yearid BETWEEN 1970 AND 2016
	AND wswin = 'Y'
ORDER BY
	w ASC;

--Smallest WS winner excluding 1981	
SELECT 
	yearid,
	franchid,
	w AS wins
FROM
	teams
WHERE 
	yearid BETWEEN 1970 AND 2016
	AND wswin = 'Y'
	AND yearid <> 1981
ORDER BY
	w ASC;

-- Top win totals per year 1970-2016
WITH max_wins AS (
	SELECT
		yearid,
		MAX(w) AS max_wins
	FROM
		teams
	WHERE 
		yearid BETWEEN 1970 AND 2016
	GROUP BY
		yearid
)
SELECT
	COUNT(*) AS total_seasons,
	SUM(CASE WHEN t.wswin = 'Y' THEN 1 ELSE 0 END) AS top_win_ws_champ
FROM
	max_wins mw
INNER JOIN
	teams t
	ON mw.yearid = t.yearid AND mw.max_wins = t.w;

-- Percentage of the time
WITH max_wins AS (
	SELECT
		yearid,
		MAX(w) AS max_wins
	FROM
		teams
	WHERE 
		yearid BETWEEN 1970 AND 2016
	GROUP BY
		yearid
)
SELECT
	COUNT(*) AS total_seasons,
	(SUM(CASE WHEN t.wswin = 'Y' THEN 1 ELSE 0 END) * 100) / COUNT(*) AS pct
FROM
	max_wins mw
INNER JOIN
	teams t
	ON mw.yearid = t.yearid AND mw.max_wins = t.w;


-- 8. Using the attendance figures from the homegames table, find the teams and parks which had the
-- top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by 
-- number of games). Only consider parks where there were at least 10 games played. 
-- Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

--Top 5 
SELECT
	t.name AS team_name,
	p. park_name,
	ROUND((h.attendance::DECIMAL / h.games), 0) AS average_attendance 
FROM
	homegames h
	INNER JOIN
		parks p USING (park)
	INNER JOIN
		teams t ON h.team = t.teamid AND h.year = t.yearid
WHERE
	games >= 10
	AND year = 2016
ORDER BY
	average_attendance DESC
LIMIT 
	5;

--Lowest 5
SELECT
	t.name AS team_name,
	p. park_name,
	ROUND((h.attendance::DECIMAL / h.games), 0) AS average_attendance
FROM
	homegames h
	INNER JOIN
		parks p USING (park)
	INNER JOIN
		teams t ON h.team = t.teamid AND h.year = t.yearid
WHERE
	games >= 10
	AND year = 2016
ORDER BY
	average_attendance ASC
LIMIT 
	5;
	
-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

-- 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. 
-- Report the players' first and last names and the number of home runs they hit in 2016.
