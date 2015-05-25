-- This show the division assigned on creation and the current division of all PQs
-- where they do not match


copy (

    select
      pq.id as PQ_Id,
      pq.uin as UIN,
      ao.id as AO_id,
      ao.name as AO_name,
      pq.division_id as PQ_Div_Id,
      pq_div.name as Original_Division,
      dd_div.id as AO_Div_Id,
      dd_div.name as AO_Div_Name
    from pqs pq
    inner join action_officers_pqs aopq on (aopq.pq_id = pq.id)
    inner join action_officers ao on (aopq.action_officer_id = ao.id)
    inner join deputy_directors dd on (ao.deputy_director_id = dd.id)
    inner join divisions pq_div on (pq.division_id = pq_div.id)
    inner join divisions dd_div on (dd.division_id = dd_div.id)

    where pq.division_id != dd.division_id
    and ao.deleted = 'f'
    and aopq.response = 'accepted'
    order by pq.id, ao.id
) to '/Users/stephen/src/pq/pq/bugfix/results/divisions.csv' With CSV HEADER;
