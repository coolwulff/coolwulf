/*
* CREATE BY: MYY
* CREATE DATE: 2022-11-01
* UPDATE TIME:2023-1-12
* UPDATE BY:MYY
* UPDATE COMMENT:智慧城市市民云中心更改为市民云中心
* UPDATE TIME:2023-2-7
* UPDATE BY:MYY
* UPDATE COMMENT:1、智慧政务中心更改为智慧城市中心 2、由于企业服务事业群存在非常日班，计算总工时时，总工时为常日班人员个数*8*实际工作天数+非常日班填报工时
* UPDATE TIME:2023-3-20
* UPDATE BY:MYY
* UPDATE COMMENT:1、按照机构表重新构建组织架构，新增一张临时表
* UPDATE TIME:2023-3-27
* UPDATE BY:MYY
* UPDATE COMMENT:1、从明细表出汇总数据
* 频度：周更
*/



-- 构建临时表，获取开发人员信息，关联配置表
/* drop table if exists kfryxxjc;
create temporary table kfryxxjc
as
select
     a. ywzx                                                   as zxmc
     -- ICT,智慧城市中心,智慧医疗——医疗保障,上海万达信息展示所有研发部门
     -- 智慧医卫中心——卫健和交付联立起来
     , if(a.center_role_id in (106,104),a.ejbm
         ,if(coalesce(a.group_role_id,c.except_code) in (10301,10306),'卫生健康事业群和交付资源部'
             ,if(coalesce(a.group_role_id,c.except_code)=10304,'医疗保障事业群'
                 ,a.ywzx)))                                     as syqmc
     , a.gh -- 工号
     , a.xm -- 姓名
#      , a.sjbm -- 三级部门
     , p.FK_SHKD_IS_DAY -- 是否常日班
     , p.YGLB
     ,a.center_role_id
     ,if(a.center_role_id in (106,104),coalesce(a.group_role_id,c.except_code)
         ,if(coalesce(a.group_role_id,c.except_code) in (10301,10306),'103301_306'
             ,if(coalesce(a.group_role_id,c.except_code)=10304,coalesce(a.group_role_id,c.except_code)
                 ,a.center_role_id)))                                    as role_id
     -- 智城、智医展开，智慧医卫中心——卫健和交付联立起来（取中间值25）
     ,if(
         a.group_role_id in (10301,10306)
            ,25
                ,if(
                    a.center_role_id in (103,104)
                        ,coalesce(c.subject_code,d.subject_code+10)
                            ,coalesce(d.subject_code,999)
                    )
         )                                                                  as rank_id
#      ,if(a.center_role_id in (103,104),coalesce(c.subject_code,d.subject_code),if(a.group_role_id in (10301,10306),25,coalesce(d.subject_code,c.subject_code,d.subject_code+10,999)))
#      ,coalesce(d.subject_code,c.subject_code,d.subject_code+10,999)                       as rank_id
#      ,a.group_role_id
from
     ads.REP_YYZX_RZTBL_W_D a
join dwh.PRO_WORK_HOUR_PERSON p on a.gh=p.FK_SHKD_NUMBER
left join (select * from dw_bll.cdw_subject where subject_type_code='YYZX_ZZJGXX' )  c on (a.group_role_id =c.subject_logic)
left join (select * from dw_bll.cdw_subject where subject_type_code='YYZX_ZZJGXX' ) d on left(coalesce(a.group_role_id,c.except_code),3)=d.except_code
where
      a.yearinfo=year('{{params.SCHEDULE_DATE}}') and a.weekinfo=week('{{params.SCHEDULE_DATE}}')
;
 */


delete
from ads.REP_YYZX_RZQKTJ_W_S
where yearinfo = year('{{params.SCHEDULE_DATE}}')
  and weekinfo = week('{{params.SCHEDULE_DATE}}');

set @rcbgs :=
    (select count(IS_WORKDAY) * 8 as rcbgs
               from dw_bll.cdw_calendar
               where IS_WORKDAY = '工作日'
                 and WEEK_ID=(select distinct WEEK_ID from dw_bll.cdw_calendar where DAY_SHORT_DESC='{{params.SCHEDULE_DATE}}'));

SET @rownum := 0;

insert into ads.REP_YYZX_RZQKTJ_W_S(id,role_id,center_role_id,group_role_id, ywzx1, ssyfbm, ssyfrygs, wbrygs, ssyfryzgs, ssyfryrztbgs, ssyfrywtbrz,
                                    xjsj, zxmsgs, ysrxmgs, yfxmgs, tsgsxmgs, xxxmgs, zfxmsgs, wbryzgs,rztbl1, xmgszb1, yearinfo,
                                    weekinfo)
select  @rownum := @rownum + 1                                                                          as id
       ,main.* from
(
SELECT 
 ROLE_ID                       -- 数据权限ID
 ,CENTER_ROLE_ID               -- 中心权限ID
 ,GROUP_ROLE_ID                -- 事业群权限ID
 ,YWZX1                        -- 业务中心
 ,SSYFBM                       -- 实施研发部门        
 ,COUNT(distinct GH) - count(distinct if(YGLX = '外包', GH, null)) AS ssyfrygs     -- 实施研发人员个数
 ,COUNT(distinct if(YGLX = '外包', GH, null))                      AS wbrygs       -- 外包人员个数
 ,count(distinct if(SFFRCRY <> '是', GH, null)) * @rcbgs + sum(
            if(SFFRCRY = '是', GS + JBGS,0))                       AS ssyfryzgs    -- 实施研发人员总工时
 ,sum(if(XMLY = '智通', GS, 0))
        + sum(if(XMLX is null and XMLY != '智通', GS, 0))
        + sum(if(SSYFBM = '政企服务事业群' and SFFRCRY = '是' and XMLX = '有收入项目',
                 (GS + JBGS),
                 if(XMLX = '有收入项目', GS, 0)))
        + sum(if(SSYFBM = '政企服务事业群' and SFFRCRY = '是' and XMLX = '研发项目',
                 (GS + JBGS),
                 if(XMLX = '研发项目', GS, 0)))
        + sum(if(SSYFBM = '政企服务事业群' and SFFRCRY = '是' and XMLX = '特殊工时项目',
                 (GS + JBGS),
                 if(XMLX = '特殊工时项目', GS, 0)))
        + sum(if(SSYFBM = '政企服务事业群' and SFFRCRY = '是' and XMLX = '先行项目',
                 (GS + JBGS),
                 if(XMLX = '先行项目', GS, 0)))                               as ssyfryrztbgs #实施研发人员总填报工时(填报工时=休假工时+在项目上工时+非项目工时)
      , count(distinct GH) * @rcbgs
        - (
                sum(if(XMLY = '智通', GS, 0))
                + sum(if(XMLX is null and XMLY != '智通', GS, 0))
                + sum(if(SSYFBM = '政企服务事业群' and SFFRCRY = '是' and XMLX = '有收入项目',
                         (GS + JBGS),
                         if(XMLX = '有收入项目', GS, 0)))
                + sum(if(SSYFBM = '政企服务事业群' and SFFRCRY = '是' and XMLX = '研发项目',
                         (GS + JBGS),
                         if(XMLX = '研发项目', GS, 0)))
                + sum(if(SSYFBM = '政企服务事业群' and SFFRCRY = '是' and XMLX = '特殊工时项目',
                         (GS + JBGS),
                         if(XMLX = '特殊工时项目', GS, 0)))
                + sum(if(SSYFBM = '政企服务事业群' and SFFRCRY = '是' and XMLX = '先行项目',
                         (GS + JBGS),
                         if(XMLX = '先行项目', GS, 0)))
            )                                                                                                as ssyfrywtbrz  #实施研发人员未填报工时
      , sum(if(XMLY = '智通', GS, 0))                                     as xjsj         #休假工时
      , sum(if(SSYFBM = '政企服务事业群' and SFFRCRY = '是' and XMLX = '有收入项目',
               (GS + JBGS),
               if(XMLX = '有收入项目', GS, 0)))
        + sum(if(SSYFBM = '政企服务事业群' and SFFRCRY = '是' and XMLX = '研发项目',
                 (GS + JBGS),
                 if(XMLX = '研发项目', GS, 0)))
        + sum(if(SSYFBM = '政企服务事业群' and SFFRCRY = '是' and XMLX = '特殊工时项目',
                 (GS + JBGS),
                 if(XMLX = '特殊工时项目', GS, 0)))
        + sum(if(SSYFBM = '政企服务事业群' and SFFRCRY = '是' and XMLX = '先行项目',
                 (GS + JBGS),
                 if(XMLX = '先行项目', GS, 0)))                               as zxmsgs       #在项目上工时
      , sum(if(SSYFBM = '政企服务事业群' and SFFRCRY = '是' and XMLX = '有收入项目',
               (GS + JBGS),
               if(XMLX = '有收入项目', GS, 0)))                                as ysrxmgs      #有收入项目工时
      , sum(if(SSYFBM = '政企服务事业群' and SFFRCRY = '是' and XMLX = '研发项目',
               (GS + JBGS),
               if(XMLX = '研发项目', GS, 0)))                                 as yfxmgs       #研发项目工时
      , sum(if(SSYFBM = '政企服务事业群' and SFFRCRY = '是' and XMLX = '特殊工时项目',
               (GS + JBGS),
               if(XMLX = '特殊工时项目', GS, 0)))                               as tsgsxmgs     #特殊工时项目工时
      , sum(if(SSYFBM = '政企服务事业群' and SFFRCRY = '是' and XMLX = '先行项目',
               (GS + JBGS),
               if(XMLX = '先行项目', GS, 0)))                                 as xxxmgs       #先行项目工时
      , sum(if(XMLX is null and XMLY != '智通', GS,
               0))                                                                                           as zfxmsgs      #在非项目上工时
      , count(distinct if(YGLX = '外包', GH, null)) * @rcbgs                                   as wbryzgs      #外包人员工时
      , if(@rcbgs = 0, 0
        , (sum(if(XMLY = '智通', GS, 0))
                + sum(if(XMLX is null and XMLY != '智通', GS, 0))
                + sum(if(SSYFBM = '政企服务事业群' and SFFRCRY = '是' and XMLX = '有收入项目',
                         (GS + JBGS),
                         if(XMLX = '有收入项目', GS, 0)))
                + sum(if(SSYFBM = '政企服务事业群' and SFFRCRY = '是' and XMLX = '研发项目',
                         (GS + JBGS),
                         if(XMLX = '研发项目', GS, 0)))
                + sum(if(SSYFBM = '政企服务事业群' and SFFRCRY = '是' and XMLX = '特殊工时项目',
                         (GS + JBGS),
                         if(XMLX = '特殊工时项目', GS, 0)))
                + sum(if(SSYFBM = '政企服务事业群' and SFFRCRY = '是' and XMLX = '先行项目',
                         (GS + JBGS),
                         if(XMLX = '先行项目', GS, 0)))) /
          (count(distinct GH) * @rcbgs))                                                       as rztbl1       #日志填报率
      , coalesce((sum(if(SSYFBM = '政企服务事业群' and SFFRCRY = '是' and XMLX = '有收入项目',
                         (GS + JBGS),
                         if(XMLX = '有收入项目', GS, 0)))
        + sum(if(SSYFBM = '政企服务事业群' and SFFRCRY = '是' and XMLX = '研发项目',
                 (GS + JBGS),
                 if(XMLX = '研发项目', GS, 0)))
        + sum(if(SSYFBM = '政企服务事业群' and SFFRCRY = '是' and XMLX = '特殊工时项目',
                 (GS + JBGS),
                 if(XMLX = '特殊工时项目', GS, 0)))
        + sum(if(SSYFBM = '政企服务事业群' and SFFRCRY = '是' and XMLX = '先行项目',
                 (GS + JBGS),
                 if(XMLX = '先行项目', GS, 0)))) /
                 (count(distinct GH) * @rcbgs -
                  sum(if(XMLY = '智通', GS, 0))),
                 0)                                                                                          as xmgszb1      #项目工时占比
      , YEAR('{{params.SCHEDULE_DATE}}')
      , WEEK('{{params.SCHEDULE_DATE}}')


FROM 
(
   -- 中心级的明细
   SELECT 
    A.CENTER_ROLE_ID                                         AS role_id                      -- 数据权限ID
    ,A.CENTER_ROLE_ID                                        AS CENTER_ROLE_ID               -- 中心权限ID
    ,A.CENTER_ROLE_ID                                        AS group_role_id                -- 事业群权限ID
    ,A.YWZX                                                  AS ywzx1                        -- 业务中心
    ,A.YWZX                                                  AS ssyfbm                       -- 实施研发部门
    ,A.GH                                                    AS GH                           -- 员工工号
    ,A.lb                                                    AS YGLX                         -- 员工类型
    ,A.SFFRCRY                                               AS SFFRCRY                      -- 是否非日常人员
    ,B.GS                                                    AS GS                           -- 工时
    ,B.JBGS                                                  AS JBGS                         -- 加班工时
    ,B.XMLX                                                  AS XMLX                         -- 项目类型
	,B.XMLY                                                  AS XMLY                         -- 项目来源
    ,A.CENTER_ORDER_ID                                       AS rank_id                      -- 排序ID
   FROM ads.REP_YYZX_RZTBL_W_D A 
   LEFT JOIN ads.REP_YYZX_RZMXSJ_W_D B ON A.GH = B.GH 
         AND B.yearinfo = YEAR('{{params.SCHEDULE_DATE}}')
         AND B.weekinfo = WEEK('{{params.SCHEDULE_DATE}}')
		 AND B.CENTER_ROLE_ID NOT IN ('106','104','103')
   WHERE A.yearinfo = YEAR('{{params.SCHEDULE_DATE}}')
     AND A.weekinfo = WEEK('{{params.SCHEDULE_DATE}}')
     AND A.CENTER_ROLE_ID NOT IN ('106','104','103')
     
   -- 事业群级的明细
   UNION ALL 
   
   SELECT 
    IF(C.role_id IN (10301,10306),'103301_306',C.role_id)                       AS ROLE_ID                      -- 数据权限ID
    ,C.CENTER_ROLE_ID                                                             AS CENTER_ROLE_ID               -- 中心权限ID
    ,IF(C.GROUP_ROLE_ID IN (10301,10306),'103301_306',C.GROUP_ROLE_ID)          AS GROUP_ROLE_ID                -- 事业群权限ID
    ,C.YWZX                                                                       AS ywzx1                        -- 业务中心
    ,IF(C.GROUP_ROLE_ID IN (10301,10306),'卫生健康事业群和交付资源部',C.EJBM)   AS ssyfbm                       -- 实施研发部门
    ,C.GH                                                    AS GH                           -- 员工工号
    ,C.LB                                                    AS YGLX                         -- 员工类型
    ,C.SFFRCRY                                               AS SFFRCRY                      -- 是否非日常人员
    ,A.GS                                                    AS GS                           -- 工时
    ,A.JBGS                                                  AS JBGS                         -- 加班工时
    ,A.XMLX                                                  AS XMLX                         -- 项目类型
	,A.XMLY                                                    AS XMLY                         -- 项目来源
    ,COALESCE(KEMU.subject_code,IF(C.GROUP_ROLE_ID IN (10301,10306),21,
	IF(LENGTH(C.CENTER_ORDER_ID) = 2,CONCAT(LEFT(C.CENTER_ORDER_ID,1),'9'),CONCAT(LEFT(C.CENTER_ORDER_ID,2),'9'))))  AS rank_id   -- 排序ID
   FROM ads.REP_YYZX_RZTBL_W_D C
   LEFT JOIN ads.REP_YYZX_RZMXSJ_W_D A ON A.GH = C.GH 
         AND A.yearinfo = YEAR('{{params.SCHEDULE_DATE}}')
         AND A.weekinfo = WEEK('{{params.SCHEDULE_DATE}}')
		 AND A.CENTER_ROLE_ID IN ('106','104','103')
   LEFT JOIN (
               SELECT * 
   			FROM dw_bll.cdw_subject KEMU
   			WHERE KEMU.subject_type_code = 'YYZX_ZZJGXX' 
   			  AND KEMU.subject_desc = '事业群' AND KEMU.subject_show_name1 = 1
   ) KEMU ON C.GROUP_ROLE_ID = KEMU.EXCEPT_CODE 
   WHERE C.YEARINFO = YEAR('{{params.SCHEDULE_DATE}}')
     AND C.WEEKINFO = WEEK('{{params.SCHEDULE_DATE}}')
     AND C.CENTER_ROLE_ID IN ('106','104','103')  
) detail    
GROUP BY 1,2,3,4,5,RANK_ID
ORDER BY cast(RANK_ID as signed)
) main







