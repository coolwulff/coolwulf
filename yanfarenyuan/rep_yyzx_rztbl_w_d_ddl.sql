drop table if exists ads.REP_YYZX_RZTBL_W_D;
-- auto-generated definition
create table ads.REP_YYZX_RZTBL_W_D
(
    id       int auto_increment primary key,
    role_id  int,
    lb       varchar(2)     default ''     not null comment '类别',
    ywzx     mediumtext                    null comment '业务中心',
    ejbm     mediumtext                    null comment '二级部门',
    sjbm     mediumtext                    null comment '三级部门',
    gh       longtext                      null comment '工号',
    xm       longtext                      null comment '姓名',
    gs       decimal(33)                   null comment '工时',
    xggs     decimal(32)                   null comment '项管工时',
    rzgs     decimal(32)                   null comment '日志工时',
    xjgs     decimal(32)                   null comment '休假工时',
    rztbl    decimal(39, 4) default 0.0000   comment '日志填报率',
    xmgszb   decimal(36, 4) default 0.0000   comment '项目工时占比',
    yearinfo bigint                        null,
    weekinfo bigint                        null,
    rcbgs      int
);

