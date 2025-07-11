-- Displayed Below is the Code I used to Query My Grafana Dashboard. 
-- Note That it Includes Variables Which are Not Shown Below


-- Stats Over Last 5 Games --
SELECT *
FROM (
  SELECT game_date,
         team,
         opp_team,
         player_name,
         min,
         position,
         CASE 
          WHEN '$stat' = 'PRA' THEN pts+reb+ast
          WHEN '$stat' = 'Points' THEN pts 
          WHEN '$stat' = 'Assists' THEN ast
          WHEN '$stat' = 'Rebounds' THEN reb
        END
  FROM player_stats
  WHERE player_name = '$player_name'
  ORDER BY game_date DESC
  LIMIT 5
) AS recent_games
ORDER BY game_date ASC;



-- Average PRA Allowed By Position --
SELECT 
  opp_position, 
  AVG(total_pra) AS avg_total_pra
FROM opp_total_pra
WHERE 
  team = '$team' AND 
  opp_position IN ('PG', 'SG', 'SF', 'PF', 'C')
GROUP BY opp_position
ORDER BY 
  CASE opp_position
    WHEN 'PG' THEN 1
    WHEN 'SG' THEN 2
    WHEN 'SF' THEN 3
    WHEN 'PF' THEN 4
    WHEN 'C'  THEN 5
  END;



-- Team Points For and Against --
SELECT
  game_date::date AS time,
  team || ' Points For' AS metric,
  points_for AS value
FROM points
WHERE team = '$team'

UNION ALL

SELECT
  game_date::date AS time,
  team || ' Points Against' AS metric,
  points_against AS value
FROM points
WHERE team = '$team'
ORDER BY time;




