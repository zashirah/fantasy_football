---
title: Welcome to Evidence
---

```sql team_data
with actual as (
    select team, sum(points) as actual_points
    from nfl.box_players
    where slot_position not in ['BE', 'IR']
    and week < 15
    group by all
),
optimized as (
    select team, sum(points) as optimized_points
    from nfl.optimized_box_players
    where week < 15
    group by all
)

select team, actual_points, optimized_points, optimized_points - actual_points as points_left_on_the_bench
from actual
join optimized
using (team)
group by all
```


<DataTable data={team_data} rows=all sort='actual_points desc'>
    <Column id=team/>
    <Column id=actual_points/>
    <Column id=optimized_points/>
    <Column id=points_left_on_the_bench contentType=colorscale/>
</DataTable>
