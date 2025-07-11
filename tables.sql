-- Through this code I create and populate the tables through JSON data that is pulled from my scraper. 

-- Getting Box Score Data --
CREATE TABLE json_nba (
  raw_json jsonb
  );

CREATE TABLE player (
  player_id TEXT,
  player_name TEXT,
  team_abbreviation TEXT
);



-- Creating Player Table --
INSERT INTO player (player_id, player_name, team_abbreviation)
SELECT DISTINCT
  raw_json->>'PLAYER_ID' AS player_id,
  raw_json->>'PLAYER_NAME' AS player_name,
  raw_json->>'TEAM_ABBREVIATION' AS team_abbreviation
FROM json_nba;
  


-- Creating Stats Table --
CREATE TABLE stats (
  game_id TEXT,
  player_id TEXT,
  min INTERVAL,
  fga FLOAT,
  fg_pct NUMERIC,
  oreb FLOAT,
  reb FLOAT,
  ast FLOAT,
  stl FLOAT,
  blk FLOAT,
  tos FLOAT,
  pts FLOAT,
  PRIMARY KEY (game_id, player_id)
);

INSERT INTO stats (
  game_id, player_id, min, fga, fg_pct, oreb, reb, ast, stl, blk, tos, pts
)
SELECT
  raw_json->>'GAME_ID',
  raw_json->>'PLAYER_ID',
  make_interval(
    mins := COALESCE(NULLIF(split_part(raw_json->>'MIN', ':', 1), '')::int, 0),
    secs := COALESCE(NULLIF(split_part(raw_json->>'MIN', ':', 2), '')::int, 0)
  ),
  (raw_json->>'FGA')::float,
  (raw_json->>'FG_PCT')::numeric,
  (raw_json->>'OREB')::float,
  (raw_json->>'REB')::float,
  (raw_json->>'AST')::float,
  (raw_json->>'STL')::float,
  (raw_json->>'BLK')::float,
  (raw_json->>'TO')::float,
  (raw_json->>'PTS')::float
FROM json_nba
WHERE raw_json->>'PLAYER_ID' IS NOT NULL
ON CONFLICT (game_id, player_id) DO NOTHING;



-- Creating Games Table --
CREATE TABLE games (
  game_id TEXT PRIMARY KEY,
  game_date DATE
);

INSERT INTO games (game_id, game_date)
SELECT DISTINCT
  raw_json->>'GAME_ID' AS game_id,
  (raw_json->>'GAME_DATE')::date AS game_date
FROM json_nba
WHERE raw_json->>'GAME_ID' IS NOT NULL
ON CONFLICT (game_id) DO NOTHING;



-- Creating Players Table (Adding in Positions) --
CREATE TABLE players AS
SELECT t1.*, t2.position
FROM player AS t1
JOIN positions AS t2 ON t1.player_name = t2.player;


