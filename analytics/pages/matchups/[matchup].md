---
queries:
   - matchups: matchups.sql
---

```sql matchups_filtered
select * from ${matchups}
where matchup = '${params.matchup}' 
```

```sql home_matchup_players_filtered
select 
    player_name, 
    case when slot_position = 'BE' then False else True end as starter,
    points, 
    projected_points,
    position,
    case 
        when slot_position = 'QB' then 0
        when slot_position = 'RB' then 1
        when slot_position = 'WR' then 2
        when slot_position = 'TE' then 3
        when slot_position = 'RB/WR/TE' then 4
        when slot_position = 'D/ST' then 5
        when slot_position = 'K' then 6
    else 7 end as sortorder


from nfl.box_players bp
join ${matchups_filtered} mf
on bp.team = mf.home_team
and bp.week = mf.week
join nfl.players p
on bp.player_id = p.player_id
order by starter desc, points desc
```

```sql away_matchup_players_filtered
select 
    player_name, 
    slot_position,
    position,
    case when slot_position = 'BE' then False else True end as starter,
    points, 
    projected_points,
    position,
    case 
        when slot_position = 'QB' then 0
        when slot_position = 'RB' then 1
        when slot_position = 'WR' then 2
        when slot_position = 'TE' then 3
        when slot_position = 'RB/WR/TE' then 4
        when slot_position = 'D/ST' then 5
        when slot_position = 'K' then 6
    else 7 end as sortorder

from nfl.box_players bp
join ${matchups_filtered} mf
on bp.team = mf.away_team
and bp.week = mf.week
join nfl.players p
on bp.player_id = p.player_id
```

```sql optimized_starters_home
with qbs as (
    select 
        position,
        player_name,
        points,
        1 as sortorder

    from ${home_matchup_players_filtered}
    where position = 'QB'
    order by points desc
    limit 1 
),
rbs as (
    select 
        position,
        player_name,
        points,
        2 as sortorder

    from ${home_matchup_players_filtered}
    where position = 'RB'
    order by points desc
    limit 2
),
wrs as (
    select 
        position,
        player_name,
        points,
        3 as sortorder

    from ${home_matchup_players_filtered}
    where position = 'WR'
    order by points desc
    limit 2
),
tes as (
    select 
        position,
        player_name,
        points,
        4 as sortorder

    from ${home_matchup_players_filtered}
    where position = 'TE'
    order by points desc
    limit 1
),
flex as (
    select 
        'FLEX' as position,
        player_name,
        points,
        5 as sortorder

    from ${home_matchup_players_filtered}
    where position in ('RB', 'WR', 'TE')
        and player_name not in (select player_name from rbs)
        and player_name not in (select player_name from wrs)
        and player_name not in (select player_name from tes)
    order by points desc
    limit 1
),
ks as (
    select 
        position,
        player_name,
        points,
        6 as sortorder

    from ${home_matchup_players_filtered}
    where position = 'K'
    order by points desc
    limit 1
),
dsts as (
    select 
        position,
        player_name,
        points,
        7 as sortorder

    from ${home_matchup_players_filtered}
    where position = 'D/ST'
    order by points desc
    limit 1
)
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
```

```sql optimized_starters_away
with qbs as (
    select 
        position,
        player_name,
        points,
        1 as sortorder

    from ${away_matchup_players_filtered}
    where position = 'QB'
    order by points desc
    limit 1 
),
rbs as (
    select 
        position,
        player_name,
        points,
        2 as sortorder

    from ${away_matchup_players_filtered}
    where position = 'RB'
    order by points desc
    limit 2
),
wrs as (
    select 
        position,
        player_name,
        points,
        3 as sortorder

    from ${away_matchup_players_filtered}
    where position = 'WR'
    order by points desc
    limit 2
),
tes as (
    select 
        position,
        player_name,
        points,
        4 as sortorder

    from ${away_matchup_players_filtered}
    where position = 'TE'
    order by points desc
    limit 1
),
flex as (
    select 
        'FLEX' as position,
        player_name,
        points,
        5 as sortorder

    from ${away_matchup_players_filtered}
    where position in ('RB', 'WR', 'TE')
        and player_name not in (select player_name from rbs)
        and player_name not in (select player_name from wrs)
        and player_name not in (select player_name from tes)
    order by points desc
    limit 1
),
ks as (
    select 
        position,
        player_name,
        points,
        6 as sortorder

    from ${away_matchup_players_filtered}
    where position = 'K'
    order by points desc
    limit 1
),
dsts as (
    select 
        position,
        player_name,
        points,
        7 as sortorder

    from ${away_matchup_players_filtered}
    where position = 'D/ST'
    order by points desc
    limit 1
)
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
```


# Week <Value data={matchups_filtered} column=week row=0/>: <Value data={matchups_filtered} column=home_team_name row=0/>  (<Value data={matchups_filtered} column=home_score row=0/>) vs <Value data={matchups_filtered} column=away_team_name row=0/> (<Value data={matchups_filtered} column=away_score row=0/>)

Home Team Optimized Points: <Value data={optimized_starters_home} column=points agg="sum"/>

Home Team Actual Points: <Value data={matchups_filtered} column=home_score/>

Away Team Optimized Points: <Value data={optimized_starters_away} column=points agg="sum"/>

Away Team Actual Points: <Value data={matchups_filtered} column=away_score/>


## Roster

<Grid>
<Group>
<p style="text-align: center">
<b>Home</b>
</p> 
<DataTable data={home_matchup_players_filtered.where(`starter = true`)} sort=sortorder totalRow=true title="Home Roster"> 
    <Column id=position/>
    <Column id=player_name/>
    <Column id=points contentType=colorscale/>
</DataTable >
</Group>
<Group>
<p style="text-align: center">
<b>Away</b>
</p> 
<DataTable data={away_matchup_players_filtered.where(`starter = true`)} sort=sortorder totalRow=true>
    <Column id=points contentType=colorscale/>
    <Column id=player_name/>
    <Column id=position/>
</DataTable >
</Group>
</Grid>

## Optimized Roster

<Grid>
<Group>
<p style="text-align: center">
<b>Home</b>
</p> 
<DataTable data={optimized_starters_home} sort=sortorder totalRow=true>
    <Column id=position/>
    <Column id=player_name/>
    <Column id=points contentType=colorscale/>
</DataTable >
</Group>
<Group>
<p style="text-align: center">
<b>Away</b>
</p> 
<DataTable data={optimized_starters_away} sort=sortorder totalRow=true>
    <Column id=points contentType=colorscale/>
    <Column id=player_name/>
    <Column id=position/>
</DataTable >
</Group>
</Grid>

<Tabs id='matchup_tabs'>

<Tab label='Home Team'>

## Team - <Value data={matchups_filtered} column=home_team_name row=0/>

<ScatterPlot 
    data={home_matchup_players_filtered}
    x=position
    y=points
    series=starter
    title='Points by position'
    legend=true
/>

### QBs

<DataTable data={home_matchup_players_filtered.where("position = 'QB'")} sort='starter desc'>
    <Column id=player_name/> 
    <Column id=starter/> 
    <Column id=points contentType=colorscale />
    <Column id=projected_points contentType=colorscale />
</DataTable>

### RBs

<DataTable data={home_matchup_players_filtered.where("position = 'RB'")} sort='starter desc'>
    <Column id=player_name/> 
    <Column id=starter/> 
    <Column id=points contentType=colorscale />
    <Column id=projected_points contentType=colorscale />
</DataTable>

### WRs

<DataTable data={home_matchup_players_filtered.where("position = 'WR'")} sort='starter desc'>
    <Column id=player_name/> 
    <Column id=starter/> 
    <Column id=points contentType=colorscale />
    <Column id=projected_points contentType=colorscale />
</DataTable>

### TEs

<DataTable data={home_matchup_players_filtered.where("position = 'TE'")} sort='starter desc'>
    <Column id=player_name/> 
    <Column id=starter/> 
    <Column id=points contentType=colorscale />
    <Column id=projected_points contentType=colorscale />
</DataTable>

### D/STs

<DataTable data={home_matchup_players_filtered.where("position = 'D/ST'")} sort='starter desc'>
    <Column id=player_name/> 
    <Column id=starter/> 
    <Column id=points contentType=colorscale />
    <Column id=projected_points contentType=colorscale />
</DataTable>

### Ks

<DataTable data={home_matchup_players_filtered.where("position = 'K'")} sort='starter desc'>
    <Column id=player_name/> 
    <Column id=starter/> 
    <Column id=points contentType=colorscale />
    <Column id=projected_points contentType=colorscale />
</DataTable>

</Tab>



<Tab label='Away Team'>

## Team - <Value data={matchups_filtered} column=away_team_name row=0/>

<ScatterPlot 
    data={away_matchup_players_filtered}
    x=position
    y=points
    series=starter
    title='Points by position'
    legend=true
/>

### QBs

<DataTable data={away_matchup_players_filtered.where("position = 'QB'")} sort='starter desc'>
	<Column id=player_name/> 
	<Column id=starter/>
    <Column id=points contentType=colorscale />
    <Column id=projected_points contentType=colorscale />
</DataTable>

### RBs

<DataTable data={away_matchup_players_filtered.where("position = 'RB'")} sort='starter desc'>
	<Column id=player_name/> 
	<Column id=starter/> 
    <Column id=points contentType=colorscale />
    <Column id=projected_points contentType=colorscale />
</DataTable>

### WRs

<DataTable data={away_matchup_players_filtered.where("position = 'WR'")} sort='starter desc'>
	<Column id=player_name/> 
	<Column id=starter/> 
    <Column id=points contentType=colorscale />
    <Column id=projected_points contentType=colorscale />
</DataTable>

### TEs

<DataTable data={away_matchup_players_filtered.where("position = 'TE'")} sort='starter desc'>
	<Column id=player_name/> 
	<Column id=starter/> 
    <Column id=points contentType=colorscale />
    <Column id=projected_points contentType=colorscale />
</DataTable>

### D/STs

<DataTable data={away_matchup_players_filtered.where("position = 'D/ST'")} sort='starter desc'>
	<Column id=player_name/> 
	<Column id=starter/> 
    <Column id=points contentType=colorscale />
    <Column id=projected_points contentType=colorscale />
</DataTable>

### Ks

<DataTable data={away_matchup_players_filtered.where("position = 'K'")} sort='starter desc'>
	<Column id=player_name/> 
	<Column id=starter/> 
    <Column id=points contentType=colorscale />
    <Column id=projected_points contentType=colorscale />
</DataTable>

</Tab>
</Tabs>
