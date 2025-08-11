-- **1 What range of years for baseball games played does the provided database cover? 1871-2016
-- select min(yearid), max(yearid)
-- from teams


--**2 Find the name and height of the shortest player in the database. Edward Carl 43, 1 game, SLA
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


-- **3 Find all players in the database who played at Vanderbilt University. 
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



-- **5 Find the average number of strikeouts per game by decade since 1920. 
-- Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
-- use  batting
-- with avg_strikeouts as (
-- 	select avg(So)
-- 	from batting)
-- SELECT (FLOOR(yearid/10) * 10) AS decade
-- 		,COALESCE(ROUND(SUM(so::numeric)/SUM(g::numeric), 2), 0) AS avg_so
-- 		,COALESCE(ROUND(SUM(hr::numeric)/SUM(g::numeric), 2), 0) AS avg_hr
-- FROM batting
-- GROUP BY decade;


--'**'6  Find the player who had the most success stealing bases in 2016,
--where success is measured as the percentage of stolen base attempts which are successful. 
--(A stolen base attempt results either in a stolen base or being caught stealing.)
--Consider only players who attempted at least 20 stolen bases.
-- select --my answer
--   CONCAT (namefirst, '_', namelast) AS name, -- full name,
--   SB as stolen_bases, -- raw for success
--   CS as caught_stealing,--raw nums for fails
--   (CS+SB) as attempts,
-- 	CONCAT(
-- 		ROUND(
-- 			SUM(sb) * 100.0 / (SUM(cs + sb)), 2),
-- 			'%') AS success_percent
-- from
--   people
--   inner join batting using (playerid)
-- where
--   (SB + cs) >= '20'
--   and yearid = '2016'
--   and CS is not Null
-- group by
--   Name,
--   stolen_bases,
--   caught_stealing
-- order by
--   success_percent desc

-- SELECT
-- --SUM's so we can check our math and/or for accuracy
-- 	CONCAT(
-- 	p.namefirst, '_', p.namelast
-- 	) AS player,
-- 	SUM(cs) AS caught_stealing,
-- 	SUM(sb) AS stolen_bases,
-- 	SUM(cs+sb) AS attempts,
-- --CONCAT to add % SUM and ROUND * 100.0 to ensure we get a decimal and it remains readable
-- 	CONCAT(
-- 	ROUND(
-- 		SUM(sb) * 100.0 / (SUM(cs + sb)), 2),
-- 		'%') AS success_percent
-- FROM
-- 	batting AS fp
-- 	RIGHT JOIN people AS p
-- 	ON fp.playerid = p.playerid
-- WHERE 
-- 	yearid= '2016'
-- 	-- ENSURE only players with 20+ attempts are counted
-- 	and (cs+sb) >=20

-- GROUP BY
-- 	p.playerid
-- ORDER BY
-- 	success_percent DESC
-- ;


--**7 From 1970 – 2016, what is the largest number of wins for a team that did not win the world series?
--What is the smallest number of wins for a team that did win the world series? 
-- Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case.
-- Then redo your query, excluding the problem year. 
-- How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

-- SELECT
-- 	teamID,
-- 	yearID,
-- 	SUM(CASE
-- 			WHEN WSWin = 'N' THEN W ELSE 0 END
-- 			) AS wins_with_noWS,
-- 	SUM(CASE
-- 			WHEN WSWin = 'Y' THEN W ELSE 0 END
-- 			) AS wins_with_WSwin,
-- 	WSWin
-- FROM
-- 	teams AS t
-- WHERE yearID BETWEEN 1970 AND 2016
-- GROUP BY yearID, teamID, WSWin

-- --			*****Many wins with no WS*****

-- --ORDER BY wins_with_nows DESC
-- 			--Few wins with a WS

-- --          *****FEW WINS WITH A WS*****

-- HAVING SUM(CASE WHEN WSWin = 'Y' AND W >=1 THEN W ELSE 0 END) > 0
-- ORDER BY wins_with_WSwin ASC
-- --part2
-- -- May God have mercy on me for newforce is not
-- WITH big_filter AS(
-- 	WITH yw_filter AS (
-- 		SELECT yearid
-- 		,MAX(w) AS most_wins
-- 	FROM teams
-- 	GROUP BY yearid
-- 	) SELECT DISTINCT yearid
-- 			,name
-- 			,w
-- 	FROM teams
-- 		INNER JOIN yw_filter
-- 			USING (yearid)
-- 	WHERE wswin = 'Y'
-- 		AND yearid BETWEEN 1970 AND 2016
-- 		AND yearid <> 1981
-- 		AND w = most_wins
-- 	GROUP BY name, yearid, w
-- 	ORDER BY yearid
-- 	) SELECT TO_CHAR(((COUNT(*)::NUMERIC)/(2016-1971) * 100), 'FM990.00%')
-- 		AS percent_maxw_and_ws
-- 	FROM big_filter;

--**8 Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 
--(where average attendance is defined as total attendance divided by number of games). 
--Only consider parks where there were at least 10 games played. 
-- --Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.
-- select
--   park,
--   team,
--   games,
--   (attendance / games) as average_attendance
-- from
--   homegames
-- where
--   year = '2016'
--   and games >= 10
-- order by
--   average_attendance asc --desc
-- limit
--   5

--**9 Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? 
--Give their full name and the teams that they were managing when they won the award.
-- select -- my attmept
-- 	CONCAT(
-- 	namefirst, '_', namelast
-- 	) AS manager, 
-- 	name, 
-- 	awardid, 
-- 	awardsmanagers.lgID
-- from managers

-- left join people using (playerid)
-- left join awardsmanagers using (yearid)
-- left join teams using (teamid)
-- where awardid LIKE '%TSN%'
-- 	and awardsmanagers.lgid in ('AL','NL')


-- WITH double_awarded AS (
--     SELECT 
-- 		playerid
--     FROM 
-- 		awardsmanagers
--     WHERE awardid LIKE '%TSN%'
--         AND lgid IN ('AL', 'NL')
--     GROUP BY playerid
--     HAVING COUNT(DISTINCT lgid) = 2
-- )
-- SELECT 
-- 	DISTINCT CONCAT(p.namefirst, '_', p.namelast) AS manager,
-- 	t.name, 
-- 	am.yearid, 
-- 	am.awardid, 
-- 	am.lgid
-- FROM 
-- 	awardsmanagers AS am
-- INNER JOIN double_awarded AS da
--     ON am.playerid = da.playerid
-- LEFT JOIN people AS p
-- 	ON am.playerid = p.playerid
-- LEFT JOIN managers AS m
-- 	ON am.playerid = m.playerid
-- 	AND am.yearid = m.yearid
-- LEFT JOIN teams AS t
-- 	ON m.teamid = t.teamid
-- WHERE am.awardid LIKE '%TSN%'
--     AND am.lgid IN ('AL', 'NL')
-- ORDER BY manager, am.yearid;


--10 Find all players who hit their career highest number of home runs in 2016. 
--Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. 
--Report the players' first and last names and the number of home runs they hit in 2016.
--debut-final_game
-- years of debut from final game, filter to only be those who meet that criteria. Filter command?
select 
		CONCAT(
	namefirst, '_', namelast
	) AS player, 
	HR
from people
left join batting using (playerid)
where  HR >=1  and yearid ='2016' 






-- 12  Does there appear to be any correlation between attendance at home games and number of wins?
-- Do teams that win the world series see a boost in attendance the following year?
--What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.
select 
yearid, 
teamid, 
divwin,
wcwin,
attendance
from teams
where wcwin is not null and divwin is not null

order by teamid, yearid

select * 
from teams

--- teams 
--DivWin         Division Winner (Y or N)
--WCWin          Wild Card Winner (Y or N)
-- case( 
-- when DivWin or WCWin is Y, post year and attendance of and before