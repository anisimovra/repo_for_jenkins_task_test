/*
 *  $HeadURL: http://hades.ftc.ru:7382/svn/pltm2/PO/modified_locals_pck.sql $
 *  $Author: anatoly $
 *  $Revision: 159687 $
 *  $Date:: 2018-09-07 10:48:56 #$
*/

/*
  —писок локальных объектов модифицированных с определеной даты в виде pck-файла modified_locals.pck
*/

set pagesize 10000
set echo off
set feedback off
set heading off
set termout off
set verify off
set trimspool on
set trimout on
set linesize 300
set serveroutput on
set serveroutput on size unlimited

spool D:\Work\Stuff\AutoSync\modified_locals.pck
exec stdio.put_line_buf('REM DATE: &1');

var from_date varchar2(100)
exec :from_date:='&1'

exec stdio.put_line_buf('VER2');
exec stdio.put_line_buf('REM Ћокальные объекты модифицированные после ' || :from_date);

    select 'REM SYSDATE ' || to_char(sysdate, 'DD/MM/YYYY') from dual;
    select 'REM ' || id || ' ' || version from system_options where parent_id is null;
    select 'REM ' || id || ' ' || limit from license_params where id in ('INSTALLATION_ID', 'SYS_NAME');
    select 'REM FILE.' || TYPE || '.' || id || ' valid from ' || to_char(date_begin, 'DD/MM/YYYY') || ' to ' ||  nvl(to_char(date_end, 'DD/MM/YYYY'),  'unlimited') || ' ' || description  from license_data d where d.status = 'VALID';


select  decode(obj_type,
                            'CLASSES', chr(10) || 'TYPE '|| rpad(class_id, 32+16+1, ' ') ||''''||name,
                            'CRITERIA', 'CRIT '|| rpad(class_id, 16, ' ') ||' '|| rpad(short_name, 32, ' ') ||''''||name,
                            'METHODS', 'METH '|| rpad(class_id, 16, ' ') ||' '||rpad(short_name, 32, ' ') ||''''||name,
                            'CLASS_ATTRIBUTES', 'ATTR ' || rpad(class_id, 16, ' ') || rpad(short_name, 32, ' ') ||''''||name
           )  
from ( 
select OBJ_TYPE, CLASS_ID, SHORT_NAME, NAME,  
       decode(OBJ_TYPE,  
                       'CLASSES', 1,
                       'METHODS', 6,
                       'CRITERIA', 4
       ) as ord
from (
select * from (
      select * from  (
                    select /*b1.ID ID,*/ 'CLASSES' OBJ_TYPE, b1.ID CLASS_ID, b1.id SHORT_NAME
                    --,1 ord
                    , b1.name
                    from CLASSES b1
                    union
                    select  /*d1.ID ID,*/ 'METHODS' OBJ_TYPE, d1.CLASS_ID CLASS_ID, d1.short_name
                    --, decode(d1.FLAGS,'R',5,6) ord
                    , d1.name
                    from METHODS d1 where d1.FLAGS not in ('Z','A') -- функциональные реквизиты обрабатываем отдельно, т.к. провер€тьс€ по описанию их надо как ATTR, а в PCK они должны быть METH
                    union
                    select  /*e1.ID ID,*/ 'METHODS' OBJ_TYPE, e1.CLASS_ID CLASS_ID, e1.short_name
                    --, 3 ord
                    , e1.name
                    from METHODS e1
                    where e1.FLAGS = 'Z' and not  exists (
                        select  1 A$1 from CRITERIA f1 where f1.ID = e1.ID
                    )
                    union
                    select  /*g1.ID ID,*/ 'CRITERIA' OBJ_TYPE, g1.CLASS_ID CLASS_ID, g1.short_name
                    --,4 ord
                    , g1.name
                    from CRITERIA g1 left outer join CRITERIA src on (src.id = g1.src_id)
                    where g1.src_id is null or (
                      g1.src_id is not null and instr(src.properties, '|PlPlus') != 0 -- расширени€ простых представлений не поддерживаютс€ (пока)
                    )
        ) a1 where not exists ( 
          select  1 A$1 from OBJECTS_OPTIONS h1 where h1.OBJ_TYPE = a1.OBJ_TYPE and h1.CLASS_ID = a1.CLASS_ID and (h1.SHORT_NAME = a1.SHORT_NAME or a1.SHORT_NAME like h1.SHORT_NAME)
        ) 
        union all
        --  локальные ‘”Ќ ÷»ќЌјЋ№Ќџ≈ реквизиты
        select distinct /*a1.id as ID,*/ 'METHODS' OBJ_TYPE, a1.CLASS_ID CLASS_ID, a1.short_name as short_name /*, 3 ord*/, a1.name as name from methods a1 where flags = 'A' -- функциональные реквизиты должны идти как METH
        and not  exists (
                   select 1 from OBJECTS_OPTIONS h1
                    where h1.OBJ_TYPE  in ( 'CLASS_ATTRIBUTES', 'METHODS') and h1.CLASS_ID = a1.CLASS_ID and (h1.SHORT_NAME = a1.short_name or a1.short_name like h1.SHORT_NAME) -- в R2 функциональные реквизиты идут как METHODS, а не CLASS_ATTRIBUTES как в IBSO
                ) and exists (
                      select  1 A$1
                      from OBJECTS_OPTIONS h1
                      where h1.OBJ_TYPE = 'CLASSES' and h1.CLASS_ID = a1.CLASS_ID and (h1.option_id not like '1R%' and h1.option_id != 'CFT_R2') -- реквизиты типов R2 в описании не значат€, почему-то                
                )
 ) 
 where class_id not in ('CONV_57', 'UNIVERS_IMP') and class_id not like 'CONV\_%' escape '\'and class_id not like 'VND%' and class_id not like 'CONV_ARC%'
 and (obj_type !=  'CLASSES' or (obj_type =  'CLASSES' and class_id  not like 'R2\_' escape '\')) -- с  типами R2 беспор€док
intersect
select * from (
with
  period as (
    select to_date(:from_date, 'DD/MM/YYYY HH24:MI:SS') as start_date,  sysdate as end_date from dual
  ),
  changes as (
    select dm.audsid, dm.user_id, 'METH' as object_type, 'METH' as object_part, dm.method_id as object, trunc(dm.time) as day, count(*) as commits
    from diary_methods dm
    where
      dm.time between (select start_date from period) and sysdate and
      dm.action in ('UPDATED', 'DROP', 'INSERTED') and
      (
        dm.sname like '%SOURCES%' or
        dm.sname like '%SHORT_NAME(%' or
        dm.sname like '%PROPERTIES%' or
        dm.sname like '%NAME(%' or
        dm.sname like '%ACCESS(%' or
        dm.sname like '%FLAGS(%' or
        dm.sname like '%%RESULT_CLASS_ID(%%'
      ) and
      not (dm.sname like '%VBSCRIPT%')
    group by dm.audsid, dm.user_id, dm.method_id, trunc(dm.time)
    union all
    select dm.audsid, dm.user_id, 'METH' as object_type, 'VBSCRIPT' as object_part, dm.method_id as object, trunc(dm.time) as day, count(*) as commits
    from diary_methods dm
    where
      dm.time between (select start_date from period) and sysdate and
      dm.action in ('UPDATED', 'DROP', 'INSERTED') and
      dm.sname like '%VBSCRIPT%'
    group by dm.audsid, dm.user_id, dm.method_id, trunc(dm.time)
    union all
    select da.audsid, da.user_id, 'TYPE' as object_type, 'ATTR' as object_part, da.class_id as object, trunc(da.time) as day, count(*) as commits
    from diary_attributes da
    where
      da.time between (select start_date from period) and sysdate
    group by da.audsid, da.user_id, da.class_id, trunc(da.time)
    union all
    select dc.audsid, dc.user_id, 'CRIT' as object_type, 'CRIT' as object_part, criteria_id as object, trunc(dc.time) as day, count(*) as commits
    from diary_criteria dc
    where
      dc.time between (select start_date from period) and sysdate and
      dc.action not in ('COMPILE', 'ERROR')
    group by dc.audsid, dc.user_id, dc.criteria_id, trunc(dc.time)
    union all
    select df.audsid, df.user_id, 'METH' as object_type, 'FORM' as object_part, df.method_id as object, trunc(df.time) as day, count(*) as commits
    from diary_forms df
    where
      df.time between (select start_date from period) and sysdate and
      df.action = 'CREATE'
    group by df.audsid, df.user_id, df.method_id, trunc(df.time)
    union all
    select ds.audsid, ds.user_id, 'TYPE' as object_type, 'TYPE' as object_part, ds.class_id as object, trunc(ds.time) as day, count(*) as commits
    from diary_storage ds
    where
      ds.time between (select start_date from period) and sysdate and
      (ds.action != 'UPDATED' or (ds.action = 'UPDATED' and name like '%(%' /* не хранение*/))
    group by ds.audsid, ds.user_id, ds.class_id, trunc(ds.time)
    union all
    select dpv.audsid, dpv.user_id, 'METH' as object_type, 'PARAM_VAR' as object_part, dpv.method_id as object, trunc(dpv.time) as day, count(*) as commits
    from diary_param_vars dpv
    where
      dpv.time between (select start_date from period) and sysdate and
      dpv.action in ('UPDATED', 'INSERTED')
    group by dpv.audsid, dpv.user_id, dpv.method_id, trunc(dpv.time)
  ), base_objects as (
  select
  object_type, object_class, object_sn,  day, os_user, object_name
  from (
    select 
    substr(user_id, instr(user_id, '.') + 1)  as os_user,
    day, 
    case 
      when object_type = 'METH' and cr.id is not null then 'CRIT'
       else object_type 
    end as object_type,
    object,  
    nvl(nvl(m.class_id, cr.class_id), cs.id) as object_class, 
    nvl(nvl(m.short_name, cr.short_name), cs.id) as object_sn,
    nvl(nvl(m.name, cr.name), cs.name) as object_name
    from changes c, methods m, criteria cr, classes cs
    where 
      m.id(+) = c.object 
      and m.flags(+) not in ('Z', 'A') -- атрибуты и фильры не должны дублироватьс€ методами
      and cr.id(+) = c.object
      and cs.id(+) = c.object
  )
  where object_class is not null
)  select decode(object_type, 
          'METH', 'METHODS',
          'TYPE', 'CLASSES',
          'CRIT', 'CRITERIA',
          'ATTR', 'CLASS_ATTRIBUTES'
   ) as obj_type, object_class as class_id, object_sn as short_name, object_name as name
    from base_objects
    group by object_type, object_class, object_sn, object_name
)
)
) order by class_id, ord, short_name
/
  
spool off
/

exit
/
