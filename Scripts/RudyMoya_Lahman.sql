/*SELECT Column_list
FROM TABLE1
INNER JOIN TABLE2
ON Table1.ColName = Table2.ColName*/

---------------------------------------------------------------------------------------------------------------------------------------------------	

--1. What range of years for baseball games played does the provided database cover?
--Answer: 1871 - 2016

select distinct(min((yearid)))
From people as p
Inner Join appearances as a
on p.playerid = a.playerid
group by a.playerid
order by min

---------------------------------------------------------------------------------------------------------------------------------------------------	

--2.Find the name and height of the shortest player in the database.
	--Answer: Eddie Gaedel
--2a. How many games did he play in?
	--Answer: Only 1951
--2b. What is the name of the team for which he played?
	--Answer: St. Louis Browns

SELECT namelast, namefirst, height
FROM people
Where height = 
	(Select min(height)
	 from people)
order by height asc; 


SELECT min(yearid), max(yearid)
FROM people as p
INNER JOIN appearances as a
ON a.playerid = p.playerid
Where namelast = 'Gaedel' and namefirst = 'Eddie'


Select distinct(t.name), p.namelast, p.namefirst, a.yearid
from people as p
	INNER JOIN 
	appearances as a
	ON p.playerid = a.playerid
	INNER JOIN 
	teams as t
	on a.teamid = t.teamid
Where p.namelast = 'Gaedel' and p.namefirst = 'Eddie'

---------------------------------------------------------------------------------------------------------------------------------------------------	

/* 3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first 
and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. 
Which Vanderbilt player earned the most money in the majors?*/
--Answer:  15 players. 
--Answer: David Price - 245,553,888.00


Select distinct(p.namelast), p.namefirst, sum(salary.salary) as overall_amt
from people as p
	INNER JOIN 
	collegeplaying as c
	ON p.playerid = c.playerid
	INNER JOIN 
	schools as s
	on c.schoolid = s.schoolid
	INNER JOIN 
	salaries as salary
	on p.playerid = salary.playerid
where s.schoolname = 'Vanderbilt University'
Group by p.namelast, p.namefirst
order by overall_amt desc;

---------------------------------------------------------------------------------------------------------------------------------------------------	

/* 4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", 
those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of 
putouts made by each of these three groups in 2016.*/

Select
	CASE WHEN f.pos = 'OF' THEN 'Outfield'
	WHEN f.pos in ('SS','1B','2B','3B') THEN 'Infield'
	WHEN f.pos in ('P','C') THEN 'Battery'
	END AS position,
	sum(f.po) as totalputouts
FROM
	people as p
	INNER JOIN 
	fielding as f
	on p.playerid = f.playerid
Where f.yearid = '2016'
group by position
ORDER BY totalputouts desc;

---------------------------------------------------------------------------------------------------------------------------------------------------	

--5. Find the average number of strikeouts per game by decade since 1920. 
--Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
--5a. Stike outs and home runs have gone up.


Select
	CAST(AVG(SOA+SO) AS DECIMAL(10,2)) / sum(g) AS Strike_outs,
	CAST(AVG(HRA+SO) AS DECIMAL(10,2)) / sum(g) AS Home_runs,
	CASE 
		WHEN yearid between '1920' and '1929' then '1920s'
		WHEN yearid between '1930' and '1939' then '1930s'
		WHEN yearid between '1940' and '1949' then '1940s'
		WHEN yearid between '1950' and '1959' then '1950s'
		WHEN yearid between '1960' and '1969' then '1960s'
		WHEN yearid between '1970' and '1979' then '1970s'
		WHEN yearid between '1980' and '1989' then '1980s'
		WHEN yearid between '1990' and '1999' then '1990s'
		WHEN yearid between '2000' and '2009' then '2000s'
		WHEN yearid between '2010' and '2019' then '2010s'		
		END AS Decades
From teams
Where teams.yearid >= 1920
group by decades
order by decades desc

--ROUND(avg(COALESCE(so,0)),2)

---------------------------------------------------------------------------------------------------------------------------------------------------	

/*#6. Find the player who had the most success stealing bases in 2016, where success is measured as the percentage 
of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being 
caught stealing.) Consider only players who attempted at least 20 stolen bases.*/

SELECT 
	p.playerid,
	p.namefirst, 
	p.namelast, 
	b.yearid, 
	SUM(b.sb) AS total_stolen,
	SUM(b.sb + b.cs) AS total_attempts,
	SUM(b.sb) * 100.00 / NULLIF(SUM(b.sb + b.cs),0) AS percent_successful
FROM 
	people AS p
LEFT JOIN 
	batting AS b
ON 
	p.playerid = b.playerid
GROUP BY
	p.namefirst,
	p.namelast,
	p.playerid,
	b.yearid,
	b.sb,
	b.cs
HAVING SUM(b.sb + b.cs) >= 20 and b.yearid = '2016'
ORDER BY percent_successful desc;

---------------------------------------------------------------------------------------------------------------------------------------------------	

--7a. From 1970 – 2016, what is the largest number of wins for a team that did not win the world series?  
--Answer: Most wins without a world series win: 2001 Seattle Mariners.
--7b. What is the smallest number of wins for a team that did win the world series?
--Answer: My boys the LA Dodgers
--7c. Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case.
--Answer: Averaging a random year compared to 1981 for the dodgers shows that there's approx 50 games less.  There was a strike that year that caused the drop.
--7d. Then redo your query, excluding the problem year
--Answer: 2006 St. Louis Cardinals.
--7e. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?
--Answer: 12 YEARS WHERE THE MOST WINS HAD THE WORLD SERIES WIN.  47 YEARS TOTAL.  12/47 = 25.5%


Select   ---From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? 
	yearid, name, max(W), L, WSWin
FROM 
	teams
WHERE 
	yearid between '1970' and '2016' 
	and WSWin = 'N'
group by 
	yearid, name, w, l, wswin
order by 
	w desc;
	
---------------------------------------------------------------------------------------------------------------------------------------------------	

Select   ---What is the smallest number of wins for a team that did win the world series
	yearid, name, min(W) as min_wins, L, WSWin
FROM 
	teams
WHERE 
	yearid between '1970' and '2016' 
	and WSWin = 'Y'
group by 
	yearid, name, w, l, wswin
order by 
	w asc;

---------------------------------------------------------------------------------------------------------------------------------------------------	

Select yearid, name, avg(g) --Determine why this year (1981) has an unusually low amount of wins.
From teams
Where yearid in ('1981','1991') and name = 'Los Angeles Dodgers'
group by  yearid, name

---------------------------------------------------------------------------------------------------------------------------------------------------	

Select   ---Then redo your query, excluding the problem year
	yearid, name, min(W) as min_wins, L, WSWin
FROM 
	teams
WHERE 
	yearid between '1970' and '2016' 
	and WSWin = 'Y'
	and not yearid = '1981'
group by 
	yearid, name, w, l, wswin
order by 
	w asc;

---------------------------------------------------------------------------------------------------------------------------------------------------	

Select   ---How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time
	yearid, 
	name, 
	max(w),
	wswin
FROM 
	teams
WHERE 
	yearid between '1970' and '2016' 
group by 
	name, yearid, wswin, w
order by 
	w desc;

---------------------------------------------------------------------------------------------------------------------------------------------------
--JASMIN A7:

SELECT
	DISTINCT yearid,
	name,
	wswin,
	wins,
	mostwins
FROM(
	SELECT  ---this statement tells you if they won the world series or not, and their record.
		DISTINCT yearid,
		name,
		wswin,
		w AS wins,
		MAX(w) OVER(PARTITION BY yearid) AS mostwins
	FROM teams
	WHERE yearid >= 1970
	ORDER BY yearid DESC) AS subquery
WHERE wswin LIKE 'Y'
	AND wins = mostwins
ORDER BY yearid DESC;



---------------------------------------------------------------------------------------------------------------------------------------------------

/*8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 
(where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. 
Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.*/
--Answer: 

/*homegames table
teams
parks table
top 5 average attendance (limit 5)
per game 2016
total attendance divided by number of games
parks with at least 10 games played
park name, team name, average attendance */


Select 
	park_name, 
	team, 
	p.park, 
	round((cast(h.attendance as numeric) / cast(h.games as numeric))) as avg_attendance
From homegames as h
join parks as p
on h.park = p.park
Where h.year = '2016'
group by p.park_name, h.team, p.park, h.attendance, h.games
order by h.attendance desc
limit 5;

--------------------------------------------------------------------------------------------------------------------------
--9. Maggie

/*9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? 
Give their full name and the teams that they were managing when they won the award.*/

/*9. Select namegiven, results.yearid,results.lgid from people
JOIN
(Select playerid, yearid,lgid,awardid from awardsmanagers where playerid in
	(Select playerid
from awardsmanagers
where playerid IN
(select playerid where awardid LIKE 'TSN%' AND lgid IN ('AL'))
intersect 
Select playerid
from awardsmanagers
where playerid IN
(select playerid where awardid LIKE 'TSN%' AND lgid IN ('NL')))
AND awardid LIKE 'TSN%') AS results
ON people.playerid=results.playerid
order by results.playerid*/



-------------------------------------------------------------------------

--10. Jasmin's Query:

/* WITH maxhr AS ( -- 1st CTE: Max hr of each player's annual hr
	SELECT
		playerid,
		yearid,
		MAX(maxhrppby) OVER(PARTITION BY playerid) AS maxmaxhrppby -- Does yearid even matter?
	FROM(
		SELECT DISTINCT
			playerid,
			yearid,
			SUM(hr) OVER(PARTITION BY playerid, yearid) AS maxhrppby -- Gimme each player's annual hr (dup years removed w DISTINCT)
		FROM batting
		GROUP BY playerid, yearid, hr
		ORDER BY playerid) AS subquery
	GROUP BY
		playerid,
		yearid,
		maxhrppby
	ORDER BY playerid, yearid DESC),
--NO: If their maxmaxhrppby (not 2016) > 2016 hr, then they did NOT hit their career highest hr in 2016.
--YES: If their maxmaxhrppby (2016) <= 2016 hr, then they DID hit their career highest hr in 2016.

sixteenhr AS ( -- 2nd CTE: Number of homeruns for each player in 2016 with at least 1 hr
	SELECT
		DISTINCT playerid,
		SUM(hr) OVER(PARTITION BY playerid) AS totalhrppinsixteen
	FROM batting
	WHERE yearid = 2016
		AND hr >= 1
	GROUP BY playerid, hr),

decade AS ( -- 3rd CTE: Players with at least 10 yrs in the league
	SELECT
		b.playerid,
		p.debut,
		p.finalgame,
		CAST(p.finalgame AS date) - CAST (p.debut AS date) AS daysinlg
	FROM batting AS b
	JOIN people AS p
	ON b.playerid = p.playerid
	WHERE CAST(p.finalgame AS date) - CAST (p.debut AS date) >= 3650 -- Played for at least 10 years
	GROUP BY
		b.playerid,
		p.finalgame,
		p.debut)
-- Note: The only nulls for p.debut and p.finalgame are when both are null (195 rows) so don't worry about them

SELECT
	DISTINCT mh.playerid,
	p.namefirst,
	p.namelast,
	mh.yearid,
	mh.maxmaxhrppby,
	sh.totalhrppinsixteen,
	ROUND((CAST(d.daysinlg AS numeric) / 365), 2) AS yrsinlg,
	d.daysinlg
FROM maxhr AS mh
JOIN sixteenhr AS sh
ON mh.playerid = sh.playerid
JOIN decade AS d
ON sh.playerid = d.playerid
JOIN people AS p
ON d.playerid = p.playerid
WHERE yearid = 2016 -- Show me their hr for 2016 only
	AND mh.maxmaxhrppby = sh.totalhrppinsixteen -- Show me that their career high matches 2016
-- A10: 8 players hit their career highest number of home runs in 2016 (verified playerids thru the query below)
-- Note: Some ppl's career high is in 2016 and another year: Edwin Encarnacion (2012), Francisco Liriano (2015), Adam Wainwright (2009)








