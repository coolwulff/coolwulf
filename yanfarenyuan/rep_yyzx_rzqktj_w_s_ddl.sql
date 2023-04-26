drop table if exists ads.REP_YYZX_RZQKTJ_W_S;
-- auto-generated definition
create table ads.REP_YYZX_RZQKTJ_W_S
(
    id           int  ,
    role_id      int,
    ywzx1        longtext              null comment '业务中心',
    ssyfbm       longtext              null comment '实施研发部门',
    ssyfrygs     bigint      default 0 not null comment '部门提供实施/研发人员个数',
    wbrygs       bigint      default 0 not null comment '外包人员个数',
    ssyfryzgs    bigint                null comment '实施/研发人员总工时（人时）',
    ssyfryrztbgs decimal(32) default 0 not null comment '实施/研发人员日志填报工时(人时)',
    ssyfrywtbrz  decimal(42) default 0 not null comment '实施/研发人员未填报日志（人时）',
    xjsj         decimal(32)           null comment '实施/研发人员休假时间（人时）',
    zxmsgs       decimal(32)           null comment '实施/研发人员在项目上工时（人时）',
    ysrxmgs      decimal(32)           null comment '实施研发人员在有收入项目上工时（人时）',
    yfxmgs       decimal(32)           null comment '实施研发人员在研发项目上工时（人时）',
    tsgsxmgs     decimal(32)           null comment '实施研发人员在特殊项目上工时（人时）',
    xxxmgs       decimal(32)           null comment '实施研发人员在先行项目上工时（人时）',
    zfxmsgs      decimal(32)           null comment '实施/研发人员在非项目上工时(人时)',
    wbryzgs      decimal(32)           null comment '外包人员总工时',
    rztbl1       decimal(43, 8)        null comment '日志填报率',
    xmgszb1      decimal(40, 8)        null comment '项目工时占比',
    yearinfo     int                   null comment '年',
    weekinfo     int                   null comment '周次'
);

