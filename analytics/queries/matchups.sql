with cte as (
    select distinct week || '-' || ht.team_id || '-' || awt.team_id as matchup, week, home_team, ht.team_name as home_team_name, away_team, awt.team_name as away_team_name, bs.home_score, bs.away_score

    from nfl.box_scores bs
    join nfl.teams ht
        on bs.home_team = ht.box_scores_team_name
    join nfl.teams awt
        on bs.away_team = awt.box_scores_team_name
)
select *
from cte