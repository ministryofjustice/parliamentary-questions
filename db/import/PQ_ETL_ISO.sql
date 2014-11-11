-- Table: stageing

DROP TABLE IF EXISTS stageing;

CREATE TABLE stageing
(
  stageingid serial NOT NULL,
  "Author" text,
  "Record Classification" text,
  "Creator" text,
  "Action Officer" text,
  "Title (Free Text Part)" text,
  "(If appl - PS Respon) Date resubmitted to Minister" text,
  "Date Accepted by Action Officer" text,
  "Date Answered by Parliamentary Branch" text,
  "Date Correction Circulated to Action Officer" text,
  "Date Due Back to Parliamentary Branch" text,
  "Date First Appeared in Parliament" text,
  "Date for Answer in Parliament" text,
  "Date Guidance Received" text,
  "Date of Hansard" text,
  "Date of Perm Sec Clearance (If applicable)" text,
  "Date PQ Withdrawn" text,
  "Date resubmitted to Minister (if appl - PS Respon)" text,
  "Date Returned" text,
  "Date returned by AO (if applicable)" text,
  "Date Returned to Parliamentary Branch" text,
  "Date RR Circulated to Action Officer" text,
  "Date sent back to AO (if applicable)" text,
  "Date Sent to Minister" text,
  "Date Sent to Perm Sec for Clearance(If applicable)" text,
  "Date Sent to Policy Minister" text,
  "Date signed off" text,
  "Date Transferred" text,
  "Date transferred to MoJ" text,
  "Deputy Director" text,
  "Directorate" text,
  "Division of Action Officer" text,
  "Final Response - Information Released" text,
  "Final Response Notes:" text,
  "Full question" text,
  "Hansard Hyperlink" text,
  "Holding Reply - date follow up response sent" text,
  "I Will Write - date follow up response sent" text,
  "I Will Write - response estimated date" text,
  "If applicable Date returned by AO" text,
  "If applicable Date sent back to AO" text,
  "If applicable Ministerial Query?" text,
  "If Out of Time - Reason Why" text,
  "InTime?" text,
  "Library Deposit" text,
  "Minister Responsible for signing off Question" text,
  "Ministerial Query? (if applicable)" text,
  "Name of Policy Minister" text,
  "Originator Department" text,
  "Parliaments Identifying Number" text,
  "POD Clearance" text,
  "POD Query?" text,
  "PQ Correction Received" text,
  "PQ Status Information" text,
  "PQ Withdrawn" text,
  "Prorogation Answer" text,
  "Reference to Answer in Hansard" text,
  "Requested by Finance?" text,
  "Requested by HR?" text,
  "Requested by Press?" text,
  "Round Robin" text,
  "Tracking Notes: e.g redraft comments from AO" text,
  "Transfer to MoJ from other Government Department" text,
  "Transfer to Other Government Department" text,
  "Type of Question" text,
  "Action Officer-Internet E-Mail Address" text,
  CONSTRAINT stageing_pkey PRIMARY KEY (stageingid)
)
WITH (
  OIDS=FALSE
);

copy stageing
(
  "Author",
  "Record Classification",
  "Creator",
  "Action Officer",
  "Title (Free Text Part)",
  "(If appl - PS Respon) Date resubmitted to Minister",
  "Date Accepted by Action Officer",
  "Date Answered by Parliamentary Branch",
  "Date Correction Circulated to Action Officer",
  "Date Due Back to Parliamentary Branch",
  "Date First Appeared in Parliament",
  "Date for Answer in Parliament",
  "Date Guidance Received",
  "Date of Hansard",
  "Date of Perm Sec Clearance (If applicable)",
  "Date PQ Withdrawn",
  "Date resubmitted to Minister (if appl - PS Respon)",
  "Date Returned",
  "Date returned by AO (if applicable)",
  "Date Returned to Parliamentary Branch",
  "Date RR Circulated to Action Officer",
  "Date sent back to AO (if applicable)",
  "Date Sent to Minister",
  "Date Sent to Perm Sec for Clearance(If applicable)",
  "Date Sent to Policy Minister",
  "Date signed off",
  "Date Transferred",
  "Date transferred to MoJ",
  "Deputy Director",
  "Directorate",
  "Division of Action Officer",
  "Final Response - Information Released",
  "Final Response Notes:",
  "Full question",
  "Hansard Hyperlink",
  "Holding Reply - date follow up response sent",
  "I Will Write - date follow up response sent",
  "I Will Write - response estimated date",
  "If applicable Date returned by AO",
  "If applicable Date sent back to AO",
  "If applicable Ministerial Query?",
  "If Out of Time - Reason Why",
  "InTime?",
  "Library Deposit",
  "Minister Responsible for signing off Question",
  "Ministerial Query? (if applicable)",
  "Name of Policy Minister",
  "Originator Department",
  "Parliaments Identifying Number",
  "POD Clearance",
  "POD Query?",
  "PQ Correction Received",
  "PQ Status Information",
  "PQ Withdrawn",
  "Prorogation Answer",
  "Reference to Answer in Hansard",
  "Requested by Finance?",
  "Requested by HR?",
  "Requested by Press?",
  "Round Robin",
  "Tracking Notes: e.g redraft comments from AO",
  "Transfer to MoJ from other Government Department",
  "Transfer to Other Government Department",
  "Type of Question",
  "Action Officer-Internet E-Mail Address"
)
from STDIN CSV DELIMITER '~' HEADER encoding 'windows-1251';

update stageing set "Deputy Director" = 'Not in Trim' where "Deputy Director" is null;
update stageing set "Directorate" = 'Not in Trim' where "Directorate" is null;
update stageing set "Division of Action Officer" = 'Not in Trim' where "Division of Action Officer" is null;

insert into directorates(name, deleted)
  SELECT distinct "Directorate" as name, FALSE
  from Stageing
  where "Directorate"  is not null
  and not exists (select name from Directorates where name = "Directorate");

insert into divisions(name, deleted)
  SELECT distinct "Division of Action Officer" as name, FALSE
  from Stageing
  where "Division of Action Officer"  is not null
and not exists (select name from divisions where name = "Division of Action Officer");

insert into deputy_directors(name, deleted)
  SELECT distinct "Deputy Director" as name, FALSE
  from Stageing
  where "Deputy Director"  is not null
  and not exists (select name from deputy_directors where name = "Deputy Director");

insert into press_desks(name,deleted,created_at,updated_at)
select 'Not in TRIM', false, now(), now()
where not exists (select name from press_desks where name = 'Not in TRIM');

insert into press_officers(
name,email,press_desk_id,deleted,
  created_at,
  updated_at)
select    'No Press Officer Assigned',
  'no_reply@pq',
  (select id from press_desks p where p.name = 'Not in TRIM') ,
  FALSE,
  now() ,
  now()
  where not exists (select name from press_officers where name = 'No Press Officer Assigned');

insert into action_officers(name, email, deleted, press_desk_id)
  SELECT distinct "Action Officer" as name,"Action Officer-Internet E-Mail Address" as email, FALSE, (select id from press_desks p where p.name = 'Not in TRIM')
  from Stageing
  where "Action Officer"  is not null
  and not exists (select name from action_officers where name = "Action Officer");


update action_officers set deputy_director_id = (select deputy_directors.id
                                                 from deputy_directors, stageing
                                                 where deputy_directors.name = stageing."Deputy Director"
                                                       and action_officers.name = stageing."Action Officer"
and stageingid = (select max(stageingid)
                                                 from stageing, deputy_directors
                                                 where deputy_directors.name = stageing."Deputy Director"
                                                       and action_officers.name = stageing."Action Officer")
												   )
where deputy_director_id is null;


update deputy_directors set division_id = ( select max (dv.id) from divisions dv, stageing s
where s."Division of Action Officer" = dv.name
  and deputy_directors.name = s."Deputy Director"
)
where division_id is null;

update divisions set directorate_id = (select max(d.id) from directorates d, stageing
where d.name = stageing."Directorate"
      and divisions.name = stageing."Division of Action Officer")
where directorate_id is null;

insert into ministers(name, deleted)
	    SELECT "Minister Responsible for signing off Question" as name, FALSE
	    from Stageing
	    where "Minister Responsible for signing off Question"  is not null
	    and not exists (select name from ministers where name = "Minister Responsible for signing off Question")
	    union
	    SELECT "Name of Policy Minister" as name, FALSE
	    from Stageing
	    where "Name of Policy Minister"  is not null
	    and not exists (select name from ministers where name = "Name of Policy Minister");


insert into ogds(name, deleted)
  SELECT distinct "Transfer to Other Government Department" as name, FALSE
  from Stageing
  where "Transfer to Other Government Department"  is not null
    and not exists (select name from ogds where name = "Transfer to Other Government Department")
  union
  SELECT distinct "Transfer to MoJ from other Government Department" as name, FALSE
  from Stageing
  where "Transfer to MoJ from other Government Department"  is not null
  and not exists (select name from ogds where name = "Transfer to MoJ from other Government Department");

UPDATE ogds SET Acronym=Name;

insert into pqs(
  tabled_date,
  question,
  created_at,
  updated_at,
  seen_by_finance,
  finance_interest,
  uin,
  member_name,
  house_name,
  date_for_answer,
  internal_deadline,
  question_type,
  minister_id,
  policy_minister_id,
  progress_id,
  draft_answer_received,
  i_will_write_estimate,
  holding_reply,
  pod_clearance,
  transferred,
  round_robin,
  round_robin_date,
  i_will_write,
  pq_correction_received,
  correction_circulated_to_action_officer,
  pod_query_flag,
  sent_to_policy_minister,
  cleared_by_policy_minister,
  sent_to_answering_minister,
  answering_minister_query,
  answering_minister_to_action_officer,
  answering_minister_returned_by_action_officer,
  resubmitted_to_answering_minister,
  policy_minister_to_action_officer,
  policy_minister_returned_by_action_officer,
  cleared_by_answering_minister,
  answer_submitted,
  library_deposit,
  pq_withdrawn,
  holding_reply_flag,
  final_response_info_released,
  round_robin_guidance_received,
  transfer_out_ogd_id,
  transfer_out_date,
  at_acceptance_directorate_id,
  at_acceptance_division_id,
  transfer_in_ogd_id,
  transfer_in_date)
  SELECT to_date(s."Date First Appeared in Parliament",'DD/MM/YYYY'),
s."Full question",
now(),
to_date(s."Date Answered by Parliamentary Branch",'DD/MM/YYYY'),
true,
CASE WHEN s."Requested by Finance?" like 'Y%' THEN TRUE ELSE FALSE END,
s."Parliaments Identifying Number",
s."Author",
CASE WHEN left(s."Type of Question",1) = 'C' THEN 'House of Commons' ELSE 'House of Lords' END,
to_date(s."Date for Answer in Parliament",'DD/MM/YYYY'),
to_timestamp(s."Date Due Back to Parliamentary Branch",'DD/MM/YYYY at HH24:MI'),
CASE WHEN position('Name' IN s."Type of Question") > 0 THEN 'NamedDay' ELSE 'Ordinary' END,
(SELECT id from ministers where name = s."Minister Responsible for signing off Question"),
(SELECT id from ministers where name = s."Name of Policy Minister"),
12,
to_timestamp(s."Date Returned to Parliamentary Branch",'DD/MM/YYYY at HH24:MI'),
to_timestamp(s."I Will Write - response estimated date",'DD/MM/YYYY at HH24:MI'),
to_timestamp(s."Holding Reply - date follow up response sent",'DD/MM/YYYY at HH24:MI'),
to_timestamp(s."POD Clearance",'DD/MM/YYYY at HH24:MI'),
CASE WHEN s."Date transferred to MoJ" is null THEN FALSE ELSE TRUE END,
CASE WHEN s."Round Robin" = 'No' THEN FALSE ELSE TRUE END,
to_timestamp(s."Date RR Circulated to Action Officer",'DD/MM/YYYY at HH24:MI'),
CASE WHEN s."I Will Write - response estimated date" is null THEN FALSE ELSE TRUE END,
CASE WHEN s."PQ Correction Received" = 'No' THEN FALSE ELSE TRUE END,
to_timestamp(s."Date Correction Circulated to Action Officer",'DD/MM/YYYY at HH24:MI'),
CASE WHEN s."POD Query?" like 'Y%' THEN TRUE ELSE FALSE END,
to_timestamp(s."Date Sent to Policy Minister",'DD/MM/YYYY at HH24:MI'),
to_timestamp(s."Date Returned",'DD/MM/YYYY at HH24:MI'),
to_timestamp(s."Date Sent to Minister",'DD/MM/YYYY at HH24:MI'),
CASE WHEN s."Ministerial Query? (if applicable)" like 'Y%' THEN TRUE ELSE FALSE END,
to_timestamp(s."Date sent back to AO (if applicable)",'DD/MM/YYYY at HH24:MI'),
to_timestamp(s."Date returned by AO (if applicable)",'DD/MM/YYYY at HH24:MI'),
to_timestamp(s."Date resubmitted to Minister (if appl - PS Respon)",'DD/MM/YYYY at HH24:MI'),
to_timestamp(s."If applicable Date sent back to AO",'DD/MM/YYYY at HH24:MI'),
to_timestamp(s."If applicable Date returned by AO",'DD/MM/YYYY at HH24:MI'),
to_timestamp(s."Date signed off",'DD/MM/YYYY at HH24:MI'),
to_timestamp(s."Date Answered by Parliamentary Branch",'DD/MM/YYYY at HH24:MI'),
CASE WHEN s."Library Deposit" like 'Y%' THEN TRUE ELSE FALSE END,
to_timestamp(s."Date PQ Withdrawn",'DD/MM/YYYY at HH24:MI'),
CASE WHEN s."Holding Reply - date follow up response sent" is null THEN FALSE ELSE TRUE END,
s."Final Response - Information Released",
to_timestamp(s."Date Guidance Received",'DD/MM/YYYY at HH24:MI'),
(SELECT id from ogds where name = s."Transfer to Other Government Department"),
to_timestamp(s."Date Transferred",'DD/MM/YYYY at HH24:MI'),
    (select max(dr.id) from action_officers ao, deputy_directors dd, divisions d, directorates dr
    where ao.name = s."Action Officer"
          and ao.deputy_director_id = dd.id
          and dd.division_id = d.id
          and d.directorate_id = dr.id),
    (select max(d.id) from action_officers ao, deputy_directors dd, divisions d
    where ao.name = s."Action Officer"
    and ao.deputy_director_id = dd.id
    and dd.division_id = d.id),
    (SELECT id from ogds where name = s."Transfer to MoJ from other Government Department"),
to_timestamp(s."Date transferred to MoJ",'DD/MM/YYYY at HH24:MI')
from stageing s
  where not exists (select uin from pqs where uin = s."Parliaments Identifying Number")
  and s."Parliaments Identifying Number" is not null;


insert into action_officers_pqs(action_officer_id,pq_id,accept,reject,reason,reason_option, created_at, updated_at)
select ao.id, p.id,
  case when s."Date Accepted by Action Officer" is null THEN FALSE ELSE TRUE END as Accept,
  case when s."Date Accepted by Action Officer" is null THEN TRUE ELSE FALSE END as Reject,
  case when s."Date Accepted by Action Officer" is null THEN 'Is for other Government department' ELSE '' END as Reason,
  case when s."Date Accepted by Action Officer" is null THEN 2 ELSE null END as reason_option,
  case when s."Date Accepted by Action Officer" is not null THEN to_timestamp(s."Date Accepted by Action Officer",'DD/MM/YYYY at HH24:MI') else
  to_timestamp(s."Date First Appeared in Parliament",'DD/MM/YYYY at HH24:MI')  END,
  case when s."Date Accepted by Action Officer" is not null THEN to_timestamp(s."Date Accepted by Action Officer",'DD/MM/YYYY at HH24:MI') else
  to_timestamp(s."Date First Appeared in Parliament",'DD/MM/YYYY at HH24:MI')  END
from action_officers ao, pqs p, stageing s
where ao.name = s."Action Officer"
  and s."Parliaments Identifying Number" = p.uin
  and not exists (select  aop2.id
		from action_officers_pqs aop2, action_officers ao2, pqs p2
		where s."Action Officer" = ao2.name
		and p2.uin= s."Parliaments Identifying Number"
		and aop2.pq_id = p2.id
		and aop2.action_officer_id = ao2.id);

  UPDATE action_officers SET name=replace(name, ' (Action Officer)','');

  update pqs set progress_id = (select id from progresses where name='Answered');

  UPDATE pqs SET progress_id = (select id from progresses where name='Transferred out') WHERE transfer_out_ogd_id IS NOT NULL;
