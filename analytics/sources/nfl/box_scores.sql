with cte as (
    select *,

    from nfl.espn_api.stg__box_scores
)
select *
from cte