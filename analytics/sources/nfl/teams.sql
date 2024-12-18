select *, 'Team(' || team_name || ')' as box_scores_team_name
from nfl.espn_api.stg__teams