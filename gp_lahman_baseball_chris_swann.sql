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

--
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
	ROUND(SUM(so)::DECIMAL / SUM(g) / 2.0, 2) AS so_per_game,
	ROUND(SUM(hr)::DECIMAL / SUM(g) / 2.0, 2) AS hr_per_game
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
	(sb + cs) AS total_attempts,
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

WITH no_ws AS (
  SELECT yearid, teamid, w
  FROM teams
  WHERE yearid BETWEEN 1970 AND 2016
    AND (wswin IS DISTINCT FROM 'Y')
)
SELECT yearid, teamid, w
FROM no_ws
WHERE w = (SELECT MAX(w) FROM no_ws)
ORDER BY yearid, teamid;

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


SELECT
	yearid,
	MAX(w) AS max_wins
FROM 
	teams
WHERE 
	yearid BETWEEN 1970 AND 2016
	AND yearid <> 1981
GROUP BY yearid;


WITH max_wins AS ( -- Returns max wins by year, 46 rows representing number of seasons, excluding 1981
	SELECT
		yearid,
		MAX(w) AS max_wins
	FROM 
		teams
	WHERE 
		yearid BETWEEN 1970 AND 2016
		AND yearid <> 1981
	GROUP BY yearid
),
top_win_ws_champ AS ( -- Returns years where the team(s) with the most wins also won the WS
	SELECT 
		DISTINCT mw.yearid
	FROM 
		max_wins mw
	JOIN 
		teams t ON mw.yearid = t.yearid 
		AND mw.max_wins = t.w
	WHERE 
		t.wswin = 'Y'
),
season_info AS ( -- Not absolutely necessary but provides clarification for the calculation below
	SELECT 
		47 AS total_seasons -- Should 1981 be excluded, if not 47
) 
SELECT
	si.total_seasons,
	COUNT(*) AS seasons_team_with_most_wins_won_ws,
	ROUND(COUNT(*)::NUMERIC / si.total_seasons * 100, 2) || '%' AS pct
FROM 
	top_win_ws_champ,
	season_info AS si
GROUP BY
	si.total_seasons;


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
	
-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? 
-- Give their full name and the teams that they were managing when they won the award.

WITH tsn_awards AS ( -- extracting all the awards with needed info
	SELECT
		am.playerid,
		am.yearid,
		am.lgid,
		m.teamid
	FROM
		awardsmanagers am
	INNER JOIN
		managers m ON am.playerid = m.playerid 
		AND am.yearid = m.yearid
		AND am.lgid = m.lgid
	WHERE
		am.awardid = 'TSN Manager of the Year'
),
dual_league_managers AS ( --filter for managers appearing in both AL and NL
	SELECT
		playerid
	FROM 
		tsn_awards
	WHERE lgid IN ('AL', 'NL')
	GROUP BY
		playerid
	HAVING
		COUNT(DISTINCT lgid) = 2
)
SELECT -- filtering for names and team names
	CONCAT(p.namefirst, ' ', p.namelast) AS manager_name,
	t.name AS team_name,
	ta.lgid AS league
FROM 
	tsn_awards ta
	INNER JOIN
		dual_league_managers dlm USING (playerid)
	INNER JOIN
		people p USING (playerid)
	INNER JOIN
		teams t ON ta.teamid = t.teamid 
		AND ta.yearid = t.yearid
ORDER BY
	manager_name, league;

--Querying w/o CTE
SELECT 
	CONCAT(namefirst, ' ', namelast) AS manager_name,
	t.name AS team_name,
	aw.lgid AS league,
	aw.yearid
FROM 
	awardsmanagers aw
	INNER JOIN
		people p USING (playerid)
	INNER JOIN
		managers m ON aw.playerid = m.playerid
		AND aw.yearid = m.yearid
	INNER JOIN
		teams t ON m.teamid = t.teamid
		AND m.yearid = t.yearid
WHERE 
	aw.awardid = 'TSN Manager of the Year'
	AND aw.lgid IN ('AL', 'NL')
	AND aw.playerid IN (
      SELECT 
	  	playerid
      FROM 
	  	awardsmanagers
      WHERE 
	  	awardID = 'TSN Manager of the Year'
        AND lgID IN ('AL', 'NL')
      GROUP BY
	  	playerid
      HAVING 
	  	COUNT(DISTINCT lgid) = 2
  )
ORDER BY	
	manager_name,
	league;

-- 10. Find all players who hit their career highest number of home runs in 2016. 
--Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. 
-- Report the players' first and last names and the number of home runs they hit in 2016.

-- Using correlated subqueries

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

--Using CTE for efficiency
	
WITH player_career_stats AS (
	SELECT
		playerid,
		COUNT(DISTINCT yearid) AS seasons_played,
		MAX(hr) AS career_high_hr
	FROM 
		batting
	GROUP BY
		playerid
	HAVING
		COUNT(DISTINCT yearid) >= 10
)
SELECT
	CONCAT(p.namefirst, ' ', p.namelast) AS player_name,
	b.hr AS hr_2016
FROM
	people p 
	INNER JOIN
		batting b USING (playerid)
	INNER JOIN
		player_career_stats pcs USING (playerid)
WHERE
	b.yearid = 2016
	AND b.hr >= 1
	AND b.hr = pcs.career_high_hr
ORDER BY
	b.hr DESC;




-- 12. In this question, you will explore the connection between number of wins and attendance.

--       Does there appear to be any correlation between attendance at home games and number of wins? 
--       Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.


-- Use teams table for both wins w and total attendance (attendance). extract year-by-year to avoid historical inflation effects

-- 12a.

SELECT
	CORR(t.w::numeric, h.attendance::numeric) AS attendance_w_corr
FROM
	teams t
	INNER JOIN
		homegames h ON h.year = t.yearid
		AND h.team = t.teamid
WHERE 
	h.attendance IS NOT NULL;


-- 12b.

SELECT 
    t1.yearID as year,
    t1.teamID as team,
    t1.name as team_name, 
    -- What happened this year?
    CASE 
        WHEN t1.WSWin = 'Y' THEN 'Won World Series'
        WHEN t1.DivWin = 'Y' OR t1.WCWin = 'Y' THEN 'Made Playoffs'
        ELSE 'No Playoffs'
    END as playoff_result,
    -- Attendance numbers
    t1.attendance as this_year_attendance,
    t2.attendance as next_year_attendance,  
    -- Calculate percent change
    ROUND(
        ((t2.attendance - t1.attendance) * 100.0 / t1.attendance), 2
    ) as percent_change    
FROM Teams t1
JOIN Teams t2 ON t1.teamID = t2.teamID 
             AND t2.yearID = t1.yearID + 1  -- Next year for same team
ORDER BY t1.yearID DESC, playoff_result, percent_change DESC;


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