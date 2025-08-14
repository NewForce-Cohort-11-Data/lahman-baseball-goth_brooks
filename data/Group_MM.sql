/*

1. What range of years for baseball games played does the provided database cover?

*/

/*
SELECT
	MIN(year), MAX(year)
FROM teams
;
*/

/*


2. Find the name and height of the shortest player in the database. How many games did he play
in? What is the name of the team for which he played?

*/

/*

SELECT 
    namefirst,
    namelast,
    height,
    name AS team_name,
	appearances.g_all AS total_games
FROM 
	people 
	INNER JOIN 
	appearances USING (playerID)
	inner JOIN 
	teams using (teamID)
WHERE 
	height = (SELECT 
				MIN(height) 
			   FROM people)
limit 1;
;

*/

/*

3. Find all players in the database who played at Vanderbilt University. Create a list 
showing each player’s first and last names as well as the total salary they earned 
in the major leagues. Sort this list in descending order by the total salary earned. Which 
Vanderbilt player earned the most money in the majors?

*/

/*
SELECT
  CONCAT(namefirst, '_', namelast) AS name, -- full name
  SUM(salary::NUMERIC::MONEY) AS total_salary -- salary
FROM
  people
  INNER JOIN collegeplaying USING (playerid)
  INNER JOIN schools USING (schoolid)
  LEFT JOIN salaries ON people.playerid = salaries.playerid
WHERE
  schoolid = 'vandy' -- vandy is schoolid for vanderbilt
  AND salary IS NOT NULL
 GROUP BY name
ORDER BY
  total_salary desc;

*/

/*

4. Using the fielding table, group players into three groups based on their 
position: label players with position OF as "Outfield", those with position "SS", 
"1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery".
Determine the number of putouts made by each of these three groups in 2016.

*/

/*
SELECT SUM(PO) AS sum_position,
	CASE
		WHEN pos = 'OF' THEN 'Outfield'
		WHEN pos = 'SS' OR pos='1B' OR pos='2B' OR pos='3B' THEN 'Infield'
		WHEN pos = 'P' OR pos='C' THEN 'Battery' 
		ELSE 'NA'
		END AS position_group
FROM fielding
GROUP BY position_group
;
*/
/*

5. Find the average number of strikeouts per game by decade since 1920.
Round the numbers you report to 2 decimal places. Do the same for home runs per game. 
Do you see any trends?

*/

/*

select 
	CONCAT(namefirst, '_', namelast) AS name, -- full name,
	SB as stolen_bases,
	CS as failed_steals, --raw nums for success

round(SB*100/sum(SB+CS))
-- SB*100/(sum(CS+SB)) 

as successful_percent
from people 
inner join batting using (playerid)
where (SB+cs) >= '20' and yearid = '2016' and CS is not Null
group by Name,stolen_bases, failed_steals
order by successful_percent desc
;

*/

/*

6. Find the player who had the most success stealing bases in 2016, where success is 
measured as the percentage of stolen base attempts which are successful. (A stolen base 
attempt results either in a stolen base or being caught stealing.) Consider only players
who attempted at least 20 stolen bases.
*/


/*

SELECT
-- We can change the player ID to a name if we need
	b.playerid, 
	CONCAT(p.namefirst, '_', p.namelast) AS name,
--SUM's so we can check our math and/or for accuracy
	SUM(cs) AS caught_stealing,
	SUM(sb) AS stolen_bases,
	SUM(cs+sb) AS attempts,
--CONCAT to add % SUM and ROUND * 100.0 to ensure we get a decimal and it remains readable
	CONCAT(
	ROUND(
		SUM(sb) * 100.0 / (SUM(cs + sb)), 2),
		'%') AS success_percent
FROM
	Batting AS b
LEFT JOIN
	people AS p
		ON b.playerid = p.playerid
GROUP BY
	b.playerid, name
HAVING
-- ENSURE only players with 20+ attempts are counted
	SUM(cs+sb) >=20
ORDER BY
	success_percent DESC
;


*/

/*
select --my answer
  CONCAT (namefirst, '_', namelast) AS name, -- full name,
  SB as stolen_bases,
  CS as caught_stealing,--raw nums for success
  (CS+SB) as attempts,
	CONCAT(
		ROUND(
			SUM(sb) * 100.0 / (SUM(cs + sb)), 2),
			'%') AS success_percent
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
  caught_stealing
order by
  success_percent desc

 */
/*


7. From 1970 – 2016, what is the largest number of wins for a team that did not win 
the world series? What is the smallest number of wins for a 
team that did win the world series? Doing this will probably result in an unusually 
small number of wins for a world series champion – determine why this is the case. Then redo 
your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team 
with the most wins also won the world series? What percentage of the time?

*/

/*
SELECT
	teamID,
	yearID,
	SUM(CASE
			WHEN WSWin = 'N' THEN W ELSE 0 END
			) AS wins_with_noWS,
	SUM(CASE
			WHEN WSWin = 'Y' THEN W ELSE 0 END
			) AS wins_with_WSwin,
	WSWin
FROM
	teams AS t
WHERE yearID BETWEEN 1970 AND 2016
GROUP BY yearID, teamID, WSWin

--			*****Many wins with no WS*****

--ORDER BY wins_with_nows DESC
			--Few wins with a WS

--          *****FEW WINS WITH A WS*****

HAVING SUM(CASE WHEN WSWin = 'Y' AND W >=1 THEN W ELSE 0 END) > 0
ORDER BY wins_with_WSwin ASC
;

*/

/*
8. Using the attendance figures from the homegames table, find the teams and parks which
had the top 5 average attendance per game in 2016 (where average attendance 
is defined as total attendance divided by number of games). Only consider
parks where there were at least 10 games played. Report the park name,
team name, and average attendance. Repeat for the lowest 5 average attendance.

*/
/*
SELECT
	p.park_name,
	SUM(hg.games) AS total_games,
	SUM(hg.attendance) AS total_attendance,
	SUM(hg.attendance) / SUM(hg.games) AS avg_attendance
FROM
	homegames AS hg
LEFT JOIN parks AS p
	ON hg.park = p.park
GROUP BY p.park_name
HAVING SUM(hg.games) >=10
ORDER BY avg_attendance DESC
;


*/
/*

9. Which managers have won the TSN Manager of the Year award in both 
the National League (NL) and the American League (AL)? Give their full 
name and the teams that they were managing when they won the award.

*/


/*

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
ORDER BY manager, am.yearid
;


*/

/*

10. Find all players who hit their career highest number of home runs
in 2016. Consider only players who have played in the league for at
least 10 years, and who hit at least one home run in 2016. Report the 
players' first and last names and the number of home runs they hit in 2016.

*/

/*

-- record CTE to establish both max HR AND veteran status (veteran status exludes Mark Trumbo)
WITH record AS (
	SELECT
		MAX(hr) AS career_high, playerid, COUNT(DISTINCT yearid) AS years_played
	FROM
		batting
	GROUP BY playerid
	HAVING COUNT(DISTINCT yearid) >= 10
)
SELECT
--CONCAT to bring in first and last names as column
	CONCAT(p.namefirst, '_', p.namelast),
	b.hr AS "2016_homeruns"
FROM 
	batting AS b
LEFT JOIN people AS p
	ON b.playerid = p.playerid
INNER JOIN record AS r
	ON b.playerid = r.playerid
	AND b.hr = r.career_high
WHERE b.hr > 1 AND b.yearid = 2016
ORDER BY b.hr DESC
;

*/

/*





11. Open-ended questions

12. Is there any correlation between number of wins and team salary?
Use data from 2000 and later to answer this question. As you do this 
analysis, keep in mind that salaries across the whole league tend to
increase together, so you may want to look on a year-by-year basis.

*/

/*
SELECT
	t.name AS team,
	s.yearid AS year,
	t.w AS wins,
	SUM(salary) AS salary
FROM salaries AS s
INNER JOIN teams AS t
	ON s.teamid = t.teamid AND s.yearid = t.yearid
WHERE s.yearid >= 2000
GROUP BY t.name, wins, s.yearid
ORDER BY team ASC, year ASC
;

*/

/*

*/
/*
SELECT  
	name,
	yearid,
	attendance,
	attendance - (LEAD(attendance) 
		OVER(ORDER BY teamid, yearid) 
			) AS change_attendace,
	wswin,
	divwin,
	wcwin
FROM teams
WHERE wcwin IS NOT NULL OR divwin IS NOT NULL

order by teamid, yearid
;
*/


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

order by playoffs DESC, teamid, yearid
;
/*



14. Does there appear to be any correlation between attendance at home games and number of wins?

15. Do teams that win the world series see a boost in attendance 
the following year? What about teams that made the playoffs? Making the
playoffs means either being a division winner or a wild card winner.

16.It is thought that since left-handed pitchers are more rare, causing 
batters to face them less often, that they are more effective. Investigate 
this claim and present evidence to either support or dispute this claim.
First, determine just how rare left-handed pitchers are compared with 
right-handed pitchers. Are left-handed pitchers more likely to win the 
Cy Young Award? Are they more likely to make it into the hall of fame?

*/