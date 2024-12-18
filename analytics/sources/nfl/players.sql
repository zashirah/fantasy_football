with cte as (
    select distinct
        player_id,
        player_name,
        eligible_slots,
        position

    from nfl.espn_api.stg__players
)
select *
from cte