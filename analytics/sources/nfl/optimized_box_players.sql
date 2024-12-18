with distinct_players as (
  select distinct 
    p.player_name,
    p.player_id,
    p.position,
    bp.week,
    bp.team, 
    bp.slot_position,
    bp.points,
    bp.projected_points
    
  from espn_api.stg__box_players bp
  join espn_api.stg__players p
  using (player_id)
),
sorted as (
  select *,
    row_number() over (
      partition by week, team, position
      order by points desc
    ) rn
    
  from distinct_players
),
qbs as (
    select 
        week, 
        team,
        position,
        player_name,
        player_id,
        points,
        1 as sortorder

    from sorted
    where position = 'QB'
    and rn <= 1
),
rbs as (
    select 
        week, 
        team,
        position,
        player_name,
        player_id,
        points,
        2 as sortorder

    from sorted
    where position = 'RB'
    and rn <= 2
),
wrs as (
    select 
        week, 
        team,
        position,
        player_name,
        player_id,
        points,
        3 as sortorder

    from sorted
    where position = 'WR'
    and rn <= 2
),
tes as (
    select 
        week, 
        team,
        position,
        player_name,
        player_id,
        points,
        4 as sortorder

    from sorted
    where position = 'TE'
    and rn <= 1
),
flex_max as (
    select week, team, max(points) points
    from sorted
    anti join rbs
    using (week, team, player_id)
    anti join wrs
    using (week, team, player_id)
    anti join tes
    using (week, team, player_id)
    where position in ('RB', 'WR', 'TE')
    group by all
),
flex as (
    select 
        week, 
        team,
        'FLEX' as position,
        player_name,
        player_id,
        points,
        5 as sortorder

    from sorted
    join flex_max
    using (week, team, points)
),
ks as (
    select 
        week, 
        team,
        position,
        player_name,
        player_id,
        points,
        6 as sortorder

    from sorted
    where position = 'K'
    and rn <= 1
),
dsts as (
    select 
        week, 
        team,
        position,
        player_name,
        player_id,
        points,
        7 as sortorder

    from sorted
    where position = 'D/ST'
    and rn <= 1
),
unioned as (
  
select *
from qbs 
union
select *
from rbs
union 
select *
from wrs
union 
select *
from tes
union 
select *
from flex
union 
select *
from ks
union 
select *
from dsts
)
select *
from unioned
where week < 15
  
