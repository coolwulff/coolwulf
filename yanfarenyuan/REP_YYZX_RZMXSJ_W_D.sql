/*
* CREATE BY: MYY
* CREATE DATE: 2022-11-02
* 业务逻辑说明：运营中心-日志工时明细表-周报-明细
* UPDATE BY : MYY
* UPDATE DATE: 2023/1/12
* UPDATE COMMENT: 排除智政/西南/交付二部的人员逻辑
* UPDATE DATE: 2023-3-23
* UPDATE COMMENT: 根据组织机构表获取role_id
* 频度：周更
*/

delete
from ads.REP_YYZX_RZMXSJ_W_D
where yearinfo = year('{{params.SCHEDULE_DATE}}')
  and weekinfo = week('{{params.SCHEDULE_DATE}}');
# truncate ads.REP_YYZX_RZMXSJ_W_D;
insert into ads.REP_YYZX_RZMXSJ_W_D(role_id, center_role_id,group_role_id
     ,ywzx                                -- 业务中心(员工)
     ,ejbm                                -- 二级部门(员工)
     ,sjbm                                -- 三级部门(员工)
	 ,SFFRCRY                             -- 是否非日常人员
	 ,center_order_id                     -- 中心排序ID
,syq, syb, xmbh, xmmc, gh, xm, ygbm, gs, jbgs, xmly, xmlx, yglx, yearinfo,
                                    weekinfo)
select /* coalesce(person.LEVEL_OLD_CODE2, person.LEVEL_OLD_CODE1) as role_id
     ,coalesce(sub.subject_logic,person.LEVEL_OLD_CODE1)
     ,coalesce(person.LEVEL_OLD_CODE2, person.LEVEL_OLD_CODE1) */
	 
	 person.role_id                        -- 数据权限ID
     , person.center_role_id               -- 中心权限ID
     , person.group_role_id                -- 事业群权限ID
	 , person.ywzx                         -- 业务中心(员工)
     , person.ejbm                         -- 二级部门(员工)
     , person.sjbm                         -- 三级部门(员工)
	 , person.SFFRCRY                      -- 是否非日常人员
	 , person.center_order_id              -- 中心排序ID
     , v.FK_SHKD_GROUP                                          as syq
     , v.FK_SHKD_DEPT                                           as syb
     , v.FK_SHKD_PROJECT_CODE                                   as xmbh
     , v.FK_SHKD_PROJECT_NAME                                   as xmmc
     , v.FK_SHKD_JOB_NUMBER                                     as gh
     , v.FK_SHKD_STAFF_NAME                                     as ygxm
     , v.FK_SHKD_STAFF_DEPT                                     as ygbm
     , v.FK_SHKD_WORK_HOUR                                      as gs
     , v.FK_SHKD_WORK_HOUR_OVER                                 as jbgs
     , v.FK_SHKD_PROJECT_SOURCE                                 as xmly
     , v.FK_SHKD_PROJECT_TYPE                                   as xmlx
     , person.lb                                                as yglx
     , year('{{params.SCHEDULE_DATE}}')
     , week('{{params.SCHEDULE_DATE}}')
from dwh.V_PRO_WORK_HOUR_PROPORTION v
LEFT JOIN ads.REP_YYZX_RZTBL_W_D person on person.gh = v.FK_SHKD_JOB_NUMBER
where person.yearinfo = year('{{params.SCHEDULE_DATE}}')and person.weekinfo = week('{{params.SCHEDULE_DATE}}')
;



/*          left join dwh.PRO_WORK_HOUR_PERSON p on v.FK_SHKD_JOB_NUMBER = p.FK_SHKD_NUMBER
         left join dm.V_EMP_PERSON_D_BAS person on person.YGBH = v.FK_SHKD_JOB_NUMBER
         left join dw_bll.cdw_subject sub on find_in_set(person.LEVEL_OLD_CODE1,sub.subject_logic)
            and sub.subject_type_code = 'YYZX_ZZJGXX'
            AND sub.subject_show_name1 = '1'
            AND sub.subject_desc = '中心'
where v.FK_SHKD_STAFF_DEPT!='智政/西南/交付二部'
; */




--  以下代码全部要注释 

-- 市民云中心未更新的情况下执行
# update ads.REP_YYZX_RZMXSJ_W_D set role_id=101 where weekinfo=week('{{params.SCHEDULE_DATE}}') and ygbm rlike '市民云';
# update ads.REP_YYZX_RZMXSJ_W_D set role_id=10403 where weekinfo=week('{{params.SCHEDULE_DATE}}') and gh='W809';


# -- 将表里的id列，取消自增，取消主键
# alter table ads.REP_YYZX_RZMXSJ_W_D
#     modify id INT(11) not null first,
#     drop primary key;
#
# -- 新增id2列，自增，主键。名字可以自定义。
# alter table ads.REP_YYZX_RZMXSJ_W_D
#     add id2 INT(11) not null auto_increment first,
#     add primary key (id2);
#
# -- 删除id列
# alter table ads.REP_YYZX_RZMXSJ_W_D
#     drop id;
#
# -- 把id2改为id
# alter table ads.REP_YYZX_RZMXSJ_W_D
#     change id2 id INT(11) not null auto_increment first;

