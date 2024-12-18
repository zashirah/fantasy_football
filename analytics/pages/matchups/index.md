---
title: Matchups
queries:
   - matchups: matchups.sql
---

```sql matchups_with_link
select *, '/matchups/' || matchup as link
from ${matchups}
where week = ${inputs.week_selector.value}
```

```sql distinct_weeks
select distinct week
from ${matchups}
```


<Dropdown data={distinct_weeks} name=week_selector value=week title="Week"/>

<DataTable data={matchups_with_link} link=link>
    <Column id=home_team/> 
    <Column id=home_score/> 
    <Column id=away_score/> 
    <Column id=away_team/> 
</DataTable>