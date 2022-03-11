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
--Answer: David Price - 245553888


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
	sum(g) as games,
	CAST(AVG(SOA) AS DECIMAL(10,2)) / sum(g) * 100 AS Strike_outs,
	CAST(AVG(HRA) AS DECIMAL(10,2)) / sum(g) * 100 AS Home_runs,
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
--Answer: 


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


