with cte as (
    select distinct *

    from nfl.espn_api.stg__box_players
)
select *
from cte