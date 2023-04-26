#-*- coding:utf-8 -*-
from airflow import DAG
from airflow.operators.dagrun_operator import TriggerDagRunOperator
from airflow.operators.dummy_operator import DummyOperator
from airflow.operators.bash_operator import BashOperator
from datetime import datetime, timedelta, date
from airflow.operators.mysql_operator import MySqlOperator
import MySQLdb
# 打开MYSQL数据库连接
db = MySQLdb.connect("10.18.32.111", "sys_tool_user", "sys_tool_User@,1", "sys_tool", charset='utf8' )
# 使用cursor()方法获取操作游标 
cursor = db.cursor()
# 使用execute方法执行SQL语句
cursor.execute("SELECT CURRENTDT,START_DATE,END_DATE,BEFOR1DY,BEFOR2DY,BEFOR3DY,BEFOR4DY,BEFOR5DY,BEFOR6DY,BEFOR7DY,CURRENT_MON,BEFOR1MON,CURRENT_YEAR,BEFOR1YEAR FROM sys_tool.COMM_CONTROL_DATE")
# 使用fetchone()方法获取一条数据
data = cursor.fetchone()
# 初始化变量的值 
befor1dy =  data[3] # 当前系统日期-前1天  
# 关闭数据库连接
db.close() 



default_args = {
	'owner': 'Admin',
	'depends_on_past': False,
	'start_date': datetime(2021, 10, 24),
	#'email': ['zmsgz@qq.com'],
	#'email_on_failure': True, 
	#'email_on_retry': True,
	'retries': 1,
	'retry_delay': timedelta(minutes = 3),
    'params': {'BEFOR1DY': befor1dy}  # 此处传递参数仅写本DAG所用到的参数，参数名使用大写
}

dag = DAG(
    dag_id='REPORT_YXZX_XQDK_D',  # dag_id
    default_args=default_args,  # 指定默认参数
    catchup = False,
    schedule_interval = '05 7 * * *'  # 执行周期，依次是分，时，天，月，周，此处表示每个整点执行 每天7点05分开始执行
)

begin = DummyOperator(
	task_id = 'BEGIN',
	dag = dag
)

end = DummyOperator(
	task_id = 'END',
	dag = dag
) 
 

rep_yxzx_dk_d_d = MySqlOperator(
    task_id='REP_YXZX_DK_D_D',
    mysql_conn_id = 'mysql_etl',
	sql = './ADS/REP_YXZX_XQDK_D/REP_YXZX_DK_D_D.sql',
	database = 'dwh',
	dag = dag
)

rep_yxzx_dk_d_s = MySqlOperator(
    task_id='REP_YXZX_DK_D_S',
    mysql_conn_id = 'mysql_etl',
	sql = './ADS/REP_YXZX_XQDK_D/REP_YXZX_DK_D_S.sql',
	database = 'dwh',
	dag = dag
)

rep_yxzx_xq_d_d = MySqlOperator(
    task_id='REP_YXZX_XQ_D_D',
    mysql_conn_id = 'mysql_etl',
	sql = './ADS/REP_YXZX_XQDK_D/REP_YXZX_XQ_D_D.sql',
	database = 'dwh',
	dag = dag
)

rep_yxzx_xq_m_s = MySqlOperator(
    task_id='REP_YXZX_XQ_M_S',
    mysql_conn_id = 'mysql_etl',
	sql = './ADS/REP_YXZX_XQDK_D/REP_YXZX_XQ_M_S.sql',
	database = 'dwh',
	dag = dag
)

# 触发DAG SCREEN_YXZX_YJJZDK_D 执行
trigger_screen_yxzx_yjjzdk_d = TriggerDagRunOperator(
    task_id='TRIGGER_SCREEN_YXZX_YJJZDK_D',
    trigger_dag_id='SCREEN_YXZX_YJJZDK_D',
    dag=dag
)

# 触发DAG SCREEN_YXZX_JZ_Y 执行
trigger_screen_yxzx_jz_y = TriggerDagRunOperator(
    task_id='TRIGGER_SCREEN_YXZX_JZ_Y',
    trigger_dag_id='SCREEN_YXZX_JZ_Y',
    dag=dag
)


begin >> rep_yxzx_dk_d_d >> rep_yxzx_dk_d_s >> end >> trigger_screen_yxzx_yjjzdk_d
begin >> rep_yxzx_xq_d_d >> rep_yxzx_xq_m_s >> end >> trigger_screen_yxzx_jz_y
