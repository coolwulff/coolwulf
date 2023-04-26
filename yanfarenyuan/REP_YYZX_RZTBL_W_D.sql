/*
* CREATE BY: MYY
* CREATE DATE: 2022-11-02
* 业务逻辑说明：运营中心-日志填报率-周报-明细
* UPDATE BY : MYY
* UPDATE DATE: 2023/1/12
* UPDATE COMMENT: 排除西南交付部的人员逻辑
* UPDATE BY: MYY
* UPDATE DATE: 2023-3-23
* UPDATE COMMENT: 根据组织机构表改装脚本，修改关联
*                 新增字段center_role_id,group_role_id
*                 中心事业群名称不做特殊处理，按原有值。
* UPDATE BY: MYY
* UPDATE DATE: 2023-4-10
* UPDATE COMMENT: 特殊工时项目算做项管工时
* 频度：周更
* UPDATE BY: MYY
* UPDATE DATE: 2023-4-25
* UPDATE COMMENT: 项目工时占比修改为：在项目上工时/（应填报总工时-休假工时）
* 频度：周更
*/

delete
from ads.REP_YYZX_RZTBL_W_D
where yearinfo = year('{{params.SCHEDULE_DATE}}')
  and weekinfo = week('{{params.SCHEDULE_DATE}}');
# truncate ads.REP_YYZX_RZTBL_W_D;


/* set @rcbgs :=
    (select count(IS_WORKDAY) * 8 as rcbgs
               from dw_bll.cdw_calendar
               where IS_WORKDAY = '工作日'
                 and WEEK_ID=(select distinct WEEK_ID from dw_bll.cdw_calendar where DAY_SHORT_DESC='{{params.SCHEDULE_DATE}}'));
				  */
				 
-- 因用户提供的【统计工时人员清单】表中无机构编码，故需要通过机构名称获取数据权限信息；
-- 通过名称构建机构权限基础数据
DROP TABLE IF EXISTS dwh.TEMP_REP_YYZX_SSYFRYRZ_W_D ;
CREATE TEMPORARY TABLE dwh.TEMP_REP_YYZX_SSYFRYRZ_W_D
SELECT *
FROM (
      SELECT 
	   CONCAT(LEVELTWOGROUP,LEVELTHREEGROUP) AS CENTER_GROUP
	   ,LEVELTWOGROUP
	   ,LEVELTHREEGROUP
	   ,COALESCE(LEVEL_OLD_CODE2,LEVEL_OLD_CODE1) AS ROLE_ID
       ,LEVEL_OLD_CODE1 AS CENTER_ROLE_ID
      FROM dwh.SHR_ORGADMIN_MAPPING
      WHERE LEVEL_OLD_CODE1 IS NOT NULL OR LEVEL_OLD_CODE2 IS NOT NULL
      GROUP BY CONCAT(LEVELTWOGROUP,LEVELTHREEGROUP),LEVELTWOGROUP,LEVELTHREEGROUP,COALESCE(LEVEL_OLD_CODE2,LEVEL_OLD_CODE1),LEVEL_OLD_CODE1
	  
      UNION
	  
      SELECT CONCAT(LEVEL_OLD_NAME1,LEVEL_OLD_NAME2) AS CENTER_GROUP
	  ,LEVEL_OLD_NAME1
	  ,LEVEL_OLD_NAME2
	  ,COALESCE(LEVEL_OLD_CODE2,LEVEL_OLD_CODE1) AS ROLE_ID
      ,LEVEL_OLD_CODE1 AS CENTER_ROLE_ID
      FROM dwh.SHR_ORGADMIN_MAPPING
      WHERE LEVEL_OLD_CODE1 IS NOT NULL OR LEVEL_OLD_CODE2 IS NOT NULL
      GROUP BY CONCAT(LEVEL_OLD_NAME1,LEVEL_OLD_NAME2),LEVEL_OLD_NAME1,LEVEL_OLD_NAME2,COALESCE(LEVEL_OLD_CODE2,LEVEL_OLD_CODE1),LEVEL_OLD_CODE1
) A
WHERE CENTER_GROUP IS NOT NULL
;		 
-- 员工工时统计信息				 
INSERT INTO ads.REP_YYZX_RZTBL_W_D(role_id,center_role_id,group_role_id,lb, ywzx, ejbm, sjbm, gh, xm, gs, xggs, rzgs, xjgs, rztbl, xmgszb, yearinfo,weekinfo, rcbgs,center_order_id,SFFRCRY)

SELECT
 role_id                       -- 数据权限ID
 ,center_role_id               -- 中心权限ID
 ,group_role_id                -- 事业群权限ID
 ,lb                           -- 类别（员工类型=外包则外包，万达）
 ,ywzx                         -- 业务中心
 ,ejbm                         -- 二级部门
 ,sjbm                         -- 三级部门
 ,gh                           -- 工号
 ,xm                           -- 姓名
 ,SUM(GS)           AS GS      -- 工时
 ,SUM(XGGS)         AS XGGS    -- 项管工时
 ,SUM(RZGS)         AS RZGS    -- 日志工时
 ,SUM(XJGS)         AS XJGS    -- 休假工时
 ,IF(ejbm = '政企服务事业群' AND FK_SHKD_IS_DAY = '是' AND IF(WEEK_GZ_TOTAL.rcbgs = 0 , 0, coalesce(SUM(GS) / WEEK_GZ_TOTAL.rcbgs,0)) > 1 ,1,
     IF(WEEK_GZ_TOTAL.rcbgs = 0 , 0, coalesce(SUM(GS) / WEEK_GZ_TOTAL.rcbgs,0)))                          AS rztbl  -- 企服的人日志填报率>1则修正为1，日志填报率=填报日志工时/应填报总工时

 ,IF(ejbm = '政企服务事业群' AND FK_SHKD_IS_DAY = '是' AND IF(WEEK_GZ_TOTAL.rcbgs = 0 or sum(GS)-sum(XJGS)=0, 0,sum(XGGS)/(sum(GS)-sum(XJGS))) > 1 , 1
     ,IF(WEEK_GZ_TOTAL.rcbgs = 0 or WEEK_GZ_TOTAL.rcbgs-sum(XJGS)=0, 0,sum(XGGS)/(WEEK_GZ_TOTAL.rcbgs-sum(XJGS))))                          as xmgszb  -- 项目工时占比：在项目上工时/（应填报总工时-休假工时）
  , year('{{params.SCHEDULE_DATE}}')
  , week('{{params.SCHEDULE_DATE}}')
  , WEEK_GZ_TOTAL.rcbgs        -- 当周累计工作日工时
  , center_order_id            -- 中心排序ID
  , FK_SHKD_IS_DAY     AS SFFRCRY --	是否非日常人员
FROM (
 SELECT
   IF(LENGTH(tmp.ROLE_ID) = 3,SUBJECT.EXCEPT_CODE,tmp.ROLE_ID)                               AS role_id            -- 数据权限ID
  , COALESCE(SUBJECT.EXCEPT_CODE,tmp.CENTER_ROLE_ID)                                         AS center_role_id     -- 中心权限ID
  , IF(LENGTH(tmp.ROLE_ID) = 3,SUBJECT.EXCEPT_CODE,tmp.ROLE_ID)                              AS group_role_id      -- 事业群权限ID
  , p.YGLB                                                                                   AS lb                 -- 类别（员工类型=外包则外包，万达）
  , p.FK_SHKD_CENTER                                                                         AS ywzx               -- 业务中心
  , p.FK_SHKD_ND_DEP                                                                         AS ejbm               -- 二级部门
  , p.FK_SHKD_REMARKS                                                                        AS sjbm               -- 三级部门
  , p.FK_SHKD_NUMBER                                                                         AS gh                 -- 工号
  , p.FK_SHKD_NAME                                                                           AS xm                 -- 姓名
  , p.FK_SHKD_IS_DAY
  , IF(p.FK_SHKD_ND_DEP = '政企服务事业群' and p.FK_SHKD_IS_DAY = '是', COALESCE(PROPORTION.FK_SHKD_WORK_HOUR_OVER,0),0)  -- 特殊事业群需追加【加班工时】
    + COALESCE(PROPORTION.FK_SHKD_WORK_HOUR,0)                                              AS GS                 -- 工时

  , IF(PROPORTION.FK_SHKD_PROJECT_SOURCE = '项目管理系统' OR (PROPORTION.FK_SHKD_PROJECT_SOURCE = '项目管理系统' and PROPORTION.FK_SHKD_PROJECT_TYPE = '特殊工时项目')
      or (PROPORTION.FK_SHKD_PROJECT_SOURCE = '日志系统' and PROPORTION.FK_SHKD_PROJECT_TYPE = '特殊工时项目'),COALESCE(PROPORTION.FK_SHKD_WORK_HOUR,0),0)
    + IF(p.FK_SHKD_ND_DEP = '政企服务事业群' AND p.FK_SHKD_IS_DAY = '是'
         AND (PROPORTION.FK_SHKD_PROJECT_SOURCE = '项目管理系统' OR (PROPORTION.FK_SHKD_PROJECT_SOURCE = '项目管理系统' and PROPORTION.FK_SHKD_PROJECT_TYPE = '特殊工时项目')
             or (PROPORTION.FK_SHKD_PROJECT_SOURCE = '日志系统' and PROPORTION.FK_SHKD_PROJECT_TYPE = '特殊工时项目')),
 		COALESCE(PROPORTION.FK_SHKD_WORK_HOUR_OVER,0),0)                                   AS XGGS               -- 项管工时

   , IF(PROPORTION.FK_SHKD_PROJECT_SOURCE = '日志系统' and PROPORTION.FK_SHKD_PROJECT_TYPE is null ,COALESCE(PROPORTION.FK_SHKD_WORK_HOUR,0),0)
    + IF(p.FK_SHKD_ND_DEP = '政企服务事业群' AND p.FK_SHKD_IS_DAY = '是' and (PROPORTION.FK_SHKD_PROJECT_SOURCE = '日志系统' and PROPORTION.FK_SHKD_PROJECT_TYPE is null )
 		,COALESCE(PROPORTION.FK_SHKD_WORK_HOUR_OVER,0)
            ,0)                                                                             AS RZGS               -- 日志工时
  , IF(FK_SHKD_PROJECT_SOURCE = '智通', COALESCE(PROPORTION.FK_SHKD_WORK_HOUR,0), 0)        AS XJGS               -- 休假工时
  , COALESCE(SUBJECT.SUBJECT_CODE,333)                                                      AS center_order_id    -- 中心排序ID
 FROM dwh.PRO_WORK_HOUR_PERSON p
 LEFT JOIN dwh.TEMP_REP_YYZX_SSYFRYRZ_W_D tmp           -- 机构权限基础数据
        ON CONCAT(p.FK_SHKD_CENTER,p.FK_SHKD_ND_DEP) = tmp.CENTER_GROUP
 LEFT JOIN dw_bll.cdw_subject SUBJECT ON FIND_IN_SET(tmp.CENTER_ROLE_ID,SUBJECT.subject_logic)
       AND SUBJECT.subject_type_code = 'YYZX_ZZJGXX'
       AND SUBJECT.SUBJECT_DESC = '中心'
       AND subject_show_name1 = '1'
 LEFT JOIN dwh.V_PRO_WORK_HOUR_PROPORTION PROPORTION    -- 项目工时信息
        ON PROPORTION.FK_SHKD_JOB_NUMBER = p.FK_SHKD_NUMBER
 WHERE  (SUBJECT.subject_type_code IS NULL AND tmp.CENTER_ROLE_ID = '106') OR  SUBJECT.subject_type_code IS NOT NULL
) DETAIL
,(SELECT COALESCE(COUNT(1) * 8,0)  AS rcbgs
   FROM dw_bll.cdw_calendar
   WHERE WEEK_ID = YEARWEEK('{{params.SCHEDULE_DATE}}',1) AND IS_WORKDAY = '工作日') WEEK_GZ_TOTAL -- 本周实际累计工时
GROUP BY 1,2,3,4,5,6,7,8,9,FK_SHKD_IS_DAY,WEEK_GZ_TOTAL.rcbgs,center_order_id
 ;
 
 
--  以下全部要注释 
 
