import tkinter as tk
import pymysql

class StaffManagementSystem:
    def __init__(self):
        self.window = tk.Tk()
        self.window.title('员工管理系统')
        self.window.geometry('500x300')

        # 姓名
        tk.Label(self.window, text='姓名：').place(x=50, y=50)
        self.name_entry = tk.Entry(self.window)
        self.name_entry.place(x=100, y=50)

        # 年龄
        tk.Label(self.window, text='年龄：').place(x=50, y=100)
        self.age_entry = tk.Entry(self.window)
        self.age_entry.place(x=100, y=100)

        # 性别
        tk.Label(self.window, text='性别：').place(x=50, y=150)
        self.sex_entry = tk.Entry(self.window)
        self.sex_entry.place(x=100, y=150)

        # 电话
        tk.Label(self.window, text='电话：').place(x=50, y=200)
        self.phone_entry = tk.Entry(self.window)
        self.phone_entry.place(x=100, y=200)

        # 添加按钮
        add_button = tk.Button(self.window, text='添加', command=self.add_staff)
        add_button.place(x=300, y=50)

        # 删除按钮
        del_button = tk.Button(self.window, text='删除', command=self.del_staff)
        del_button.place(x=300, y=100)

        # 修改按钮
        modify_button = tk.Button(self.window, text='修改', command=self.modify_staff)
        modify_button.place(x=300, y=150)

        # 查找按钮
        find_button = tk.Button(self.window, text='查找', command=self.find_staff)
        find_button.place(x=300, y=200)

    def add_staff(self):
        name = self.name_entry.get()
        age = self.age_entry.get()
        sex = self.sex_entry.get()
        phone = self.phone_entry.get()

        if name and age and sex and phone:
            db = pymysql.connect(host='localhost', user='root', password='123456', database='test')
            cursor = db.cursor()
            sql = f"INSERT INTO staff(name, age, sex, phone) VALUES('{name}', '{age}', '{sex}', '{phone}')"
            try:
                cursor.execute(sql)
                db.commit()
                print('添加成功！')
            except Exception as e:
                print(f'添加失败！{e}')
                db.rollback()
            finally:
                db.close()
                self.clear_entries()
                return True
        else:
            print('请填写完整信息！')
            return False

    def del_staff(self):
        name = self.name_entry.get()

        if name:
            db = pymysql.connect(host='localhost', user='root', password='123456', database='test')
            cursor = db.cursor()
            sql = f"DELETE FROM staff WHERE name='{name}'"
            try:
                cursor.execute(sql)
                db.commit()
                print('删除成功！')
            except Exception as e:
                print(f'删除失败！{e}')
                db.rollback()
            finally:
                db.close()
                self.clear_entries()
                return True
        else:
            print('请输入要删除的员工姓名！')
            return False

    def modify_staff(self):
        name = self.name_entry.get()
        age = self.age_entry.get()
        sex = self.sex_entry.get()
        phone = self.phone_entry.get()

        if name and age and sex and phone:
            db = pymysql.connect(host='localhost', user='root', password='123456', database='test')
            cursor = db.cursor()
            sql = f"UPDATE staff SET age='{age}', sex='{sex}', phone='{phone}' WHERE name='{name}'"
            try:
                cursor.execute(sql)
                db.commit()
                print('修改成功！')
            except Exception as e:
                print(f'修改失败！{e}')
                db.rollback()
            finally:
                db.close()
                self.clear_entries()
                return True
        else:
            print('请填写完整信息！')
            return False