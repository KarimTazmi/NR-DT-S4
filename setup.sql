--4.1. Wat is de meest voorkomende voornaam per decennium van geboortejaar?
select 
    birthyear,
    first_name,
    freq
    from (
        select *,
        count(1) as freq
            -- Totale selectie + counter op freq
        from (
            select floor(cast(n.birthyear as int)/10*10) as birthyear,
            -- birthyear casten als integer
            split_part(primaryname,' ',1) as first_name
            from names as n
            where n.birthyear !='\N'
            -- Negeren van lege kolommen
        ) as my_list
        group by birthyear, first_name
        -- Groupen
        order by freq desc
        -- Freq direct ordenen
        fetch first 10 row only
        -- 10 eerste resultaten weergeven
        ) as my_table

--4.2. Wie is de oudste nog levende regiseur, die na 2010 nog een film heeft gemaakt?
select
    n.primaryname,
    n.birthyear,
    n.deathyear,
    m.primarytitle,
    m.startyear
from principals p
left join names n on p.nconst = n.nconst
left join movies m on p.tconst = m.tconst
-- Joinen kolommen
where
    p.category = 'director'
    and startyear > 2010
	and n.deathyear = '\N'
    -- Uitsluiten van overleden regisseurs
	and n.birthyear <> '\N'
    -- Filter op missende informatie
order by birthyear asc
    -- Ordenen op geboortejaar
fetch first 10 row only
    -- 10 eerste resultaten weergeven


--4.3. Wie is de beste acteur(m/v)?
select
    n.primaryname,
    avg(r.averagerating)
from
    principals p 
join 
    names n on p.nconst = n.nconst
join 
    movies m on p.tconst = m.tconst
join 
    ratings r on m.tconst = r.tconst
where 
    p.category like '%actress%'
    or p.category like '%actor%'
group by
    n.primaryname,
    r.averagerating,
    r.numvotes
order by 
    r.numvotes desc
fetch first 10 row only

-- 4.4 Welk duo van een acteur en een actrice speelden samen in de meeste films
select
    one.category,
    two.category,
    one.primaryname,
    two.primaryname,
    count(1) as doublefeature
    -- Counter toegevoegd
from 
(
    select
        m.tconst, 
        n.primaryname, 
        p.category
    from
        principals p
    left join 
        names n on p.nconst = n.nconst
    left join 
        movies m on p.tconst = m.tconst
    where p.category = 'actor'
) one -- Subquery for one
inner join (
    select
        m.tconst, 
        n.primaryname, 
        p.category
    from
        principals p
    left join 
        names n on p.nconst = n.nconst
    left join 
        movies m on p.tconst = m.tconst
    where p.category = 'actress'
) two -- Subquery for two
on 
    one.tconst = two.tconst
    -- Matching on tconst
where
    one.primaryname < two.primaryname
    and one.category != two.category
group by
    one.category,
    two.category,
    one.primaryname,
    two.primaryname
order by doublefeature desc
fetch first 10 row only

-- 4.5 Wat is de meest voorkomende achternaam per decenium onder acteurs (m/v) van de top 250 films uit dat decenium.
select 
    birthyear,
    last_name2,
    last_name3,
    freq
    -- Selectie kolommen + frequentie
    from (
        select *,
        count(1) as freq
            -- Totale selectie + counter op freq
        from (
            select floor(cast(n.birthyear as int)/10*10) as birthyear,
            -- birthyear casten als integer
            split_part(primaryname, ' ', 2) as last_name2,
            split_part(primaryname, ' ', 3) as last_name3
            from names as n
            where n.birthyear !='\N'
            -- Negeren van lege kolommen
        ) as my_list
        group by birthyear, last_name2, last_name3
        -- Groupen
        order by freq desc
        -- Freq direct ordenen
        --fetch first 10 row only
        -- 10 eerste resultaten weergeven
        ) as my_table