drop table if exists ads.REP_YYZX_RZMXSJ_W_D;
-- auto-generated definition
create table ads.REP_YYZX_RZMXSJ_W_D
(
    id int   auto_increment primary key ,
    role_id int,
    syq      mediumtext null comment '事业群',
    syb      text       null comment '事业部',
    xmbh     text       null comment '项目编号',
    xmmc     text       null comment '项目名称',
    gh       mediumtext null comment '工号',
    xm       mediumtext null comment '员工姓名',
    ygbm     text       null comment '员工部门',
    gs       int        null comment '工时',
    jbgs     int        null comment '加班工时',
    xmly     text       null comment '项目来源',
    xmlx     text       null comment '项目类型',
    yglx     text       null comment '员工类型',
    yearinfo int        null,
    weekinfo int        null
);

