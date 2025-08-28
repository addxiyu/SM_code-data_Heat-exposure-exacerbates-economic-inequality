# -*- coding: utf-8 -*-
# @author: Alvin
# @file: scatter_chart.py
# @time: 2024/8/14 22:19
# This scripts is for :  散点图
"""
TODO:
1. 设置一个色彩的 dict，可以从dict 中直接选取 色彩以及对应的 RGB 颜色，
2. 散落在函数中的不同参数，需要尽量集中再一个函数中去定义，方便画图者使用
3。能否生成 app，或者再terminal中对应 输入想要的参数来直接修改代码参数
4. 画左右对称的效果，类似 test.py 中的实例
"""
from matplotlib.font_manager import FontProperties
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import os
import time



class ScatterChart:
    def __init__(self):
        self.input_folder = 'input'
        self.output_folder = 'output'
        self.fig_name = ''
        self.save_path = ''
        self.color1_name = 'Crimson'
        self.color1_rgb = (0.27, 0.51, 0.71, 1)  # R,G,B,(normalized to 1, xxx/255) alpha 0~1
        self.color2_name = 'SteelBlue'
        self.color2_rgb = (0.86, 0.08, 0.24, 1)
        self.font = FontProperties()
        self.font.set_family('Arial')
        self.font.set_size(10)
        # reds = ['Red', 'Crimson', 'Firebrick', 'Tomato', 'Salmon', 'LightCoral', 'IndianRed']
        # blues = ['Blue', 'SkyBlue', 'SteelBlue', 'DodgerBlue', 'LightSteelBlue', 'RoyalBlue', 'PowderBlue']

    def fig_plot_parameters(self):
        self.color1_name = 'Crimson'
        self.color1_rgb = (0.27, 0.51, 0.71, 0.7)  # R,G,B,(normalized to 1, xxx/255) alpha 0~1
        self.color2_name = 'SteelBlue'
        self.color2_rgb = (0.86, 0.08, 0.24, 0.7)
        # reds = ['Red', 'Crimson', 'Firebrick', 'Tomato', 'Salmon', 'LightCoral', 'IndianRed']
        # blues = ['Blue', 'SkyBlue', 'SteelBlue', 'DodgerBlue', 'LightSteelBlue', 'RoyalBlue', 'PowderBlue']

    def get_file(self):
        file_list = [f for f in os.listdir(self.input_folder) if f.endswith('.xlsx') and not f.startswith('~')]
        file_path = []
        if file_list is None:
            raise Exception("-0- .xlsx file found in input folder.")
        else:
            print(f"-{len(file_list)}- .xlsx file found in input folder.")
            for file_name in file_list:
                self.fig_name, _ = os.path.splitext(file_name)
                file_path.append(os.path.join(self.input_folder, file_name))
        return file_path

    def read_data_excel(self, file_path, row):
        df = pd.read_excel(file_path, sheet_name=0, nrows=row)
        return df

    def plot_arrow_annotate(self, ax, y, x1, x2):
        # 绘制箭头连接 x1 和 x2
        for yi, xi1, xi2 in zip(y, x1, x2):
            # 设置箭头的颜色与散点颜色接近，透明度为 50%, x2 > x1 时为红色
            color = self.color1_rgb if xi2 > xi1 else self.color2_rgb
            ax.annotate('', xy=(xi1, yi), xytext=(xi2, yi),
                        arrowprops=dict(
                            arrowstyle='wedge',  # 使用 'wedge' 箭头样式
                            color=color,  # 箭头颜色
                            linewidth=0.05,  # 箭头线条宽度
                            mutation_scale=15,  # 缩放因子，越大三角形面积越大需要和 Scatter 大小对应
                            )
                        )

    def plot_scatter(self, data):
        # 提取数据, y 是国家的代号，countries 是纵坐标的label，x1 是第一年的数据，x2 是第二年的数据, x3 是左图第一年数据， x4 是左图第二年数据
        y = np.arange(len(data))
        x1 = data.iloc[:, 1].to_numpy()
        x2 = data.iloc[:, 2].to_numpy()
        x3 = data.iloc[:, 3].to_numpy()
        x4 = data.iloc[:, 4].to_numpy()

        # 计算散点颜色, 散点大小
        colors_l = np.where(x2 - x1 < 0, self.color1_name, self.color2_name)
        colors_r = np.where(x4 - x3 < 0, self.color1_name, self.color2_name)

        label_1 = '1990-1999'    # 设置 散点的label名称
        label_2 = '2013-2022'    # 设置 散点的label名称
        label_3 = '1990-1999'    # 设置 散点的label名称
        label_4 = '2013-2022'    # 设置 散点的label名称

        # 创建图形和坐标轴
        fig, (ax_l, ax_r) = plt.subplots(1, 2, figsize=(12, 17), sharey=True)  # 设置宽高
        # 绘制左侧散点图
        ax_l.scatter(x1, y, color=colors_l, s=2, label=label_1, alpha=1, zorder=5)  # 画出散点图 (y, x1)
        ax_l.scatter(x2, y, color=colors_l, s=20, label=label_2, alpha=1, zorder=5)  # 画出散点图 (y, x2)
        # 绘制右侧散点图
        ax_r.scatter(x3, y, color=colors_r, s=2, label=label_3, alpha=1, zorder=5)  # 画出散点图 (y, x3)
        ax_r.scatter(x4, y, color=colors_r, s=20, label=label_4, alpha=1, zorder=5)  # 画出散点图 (y, x4)
        # 画出 散点与纵坐标轴 国家标签的连线, 画出更小值和 y 轴的连线
        for yi, xi1, xi2 in zip(y, x1, x2):
            x_value = xi2 if xi2 < xi1 else xi1
            ax_l.plot([0, x_value], [yi, yi], color='grey', linestyle='--', linewidth=0.5)
        for yi, xi1, xi2 in zip(y, x3, x4):
            x_value = xi2 if xi2 < xi1 else xi1
            ax_r.plot([10, x_value], [yi, yi], color='grey', linestyle='--', linewidth=0.5)
        # 绘制散点连线
        self.plot_arrow_annotate(ax=ax_l, y=y, x1=x1, x2=x2)  # 画出 散点 x1 和 x2 之间的连线
        self.plot_arrow_annotate(ax=ax_r, y=y, x1=x3, x2=x4)  # 画出 散点 x3 和 x4 之间的连线
        return fig, ax_l, ax_r

    def set_ax_properties(self, ax_l, ax_r, data):
        # 调整两个子图之间的水平间距，方便显示标签
        plt.subplots_adjust(wspace=0.45)
        # 设置标签和标题
        y = np.arange(len(data))               # show how many countries y label
        countries = data.iloc[:, 0].to_list()  # y label list get from excel

        ax_l.set_xlabel('log(EVA)  (2015 US$)')  # 设置横坐标标题
        ax_l.set_ylim(max(y)+2, -2)   # 设置纵坐标的显示的范围，国家名字清晰可见
        # ax_l.set_ylim(-2, max(y) + 2)   # 设置纵坐标的显示的范围，国家名字清晰可见
        # ax_l.set_ylabel('Countries')  # 设置纵坐标标题
        ax_l.set_yticks(y)  # 设置纵坐标显示的大小
        ax_l.set_yticklabels(countries, fontsize=8, horizontalalignment='left')  # 设置纵坐标 label 为国家的名字, 左对齐
        # ax_l.set_title('Comparison of x1 and x2 with Arrow Connections')  # 设置图片的标题
        ax_l.xaxis.grid(True, which='major', linestyle='-', linewidth=0.5, color='grey', alpha=0.5)  # 设置垂直网格线
        ax_l.yaxis.grid(False)  # 设置水平网格线
        ax_l.set_xlim(11, 0)  # 将左图的恒左边反转
        for spine in ax_l.spines.values():  # 设置子图边框不可见
            spine.set_visible(False)

        # 调整 y 轴标签在两个子图的正中间显示
        ax_l.yaxis.set_ticks_position('right')

        ax_r.set_xlabel('% change of EVA growth')  # 设置横坐标标题
        # ax_r.set_ylabel('Countries')                       # 设置纵坐标标题
        # ax_r.set_yticks(y)                                 # 设置纵坐标显示的大小
        # ax_r.set_yticklabels(countries)                    # 设置纵坐标 label
        # ax_r.set_title('Comparison of x1 and x2 with Arrow Connections')  # 设置图片的标题
        ax_r.xaxis.grid(True, which='major', linestyle='-', linewidth=0.5, color='grey', alpha=0.5)   # 设置垂直网格线
        ax_r.yaxis.grid(False)  # 设置水平网格线
        ax_r.set_xlim(0, -30)
        # ax_r.set_xscale('log')   # 设置对数坐标
        for spine in ax_r.spines.values():  # 设置子图边框不可见
            spine.set_visible(False)

    def main(self):
        # 获取 excel 文件
        files = self.get_file()
        i = len(files)
        for file_path in files:
            file_name, _ = os.path.splitext(os.path.basename(file_path))
            print(f"start handling file: {file_name}")
            # 组成tif 文件保存路径，用于图片保存
            self.save_path = os.path.join(self.output_folder, (file_name + '.tif'))
            # 数据处理
            data = self.read_data_excel(file_path, row=100)
            # 定义所需要的画图参数如标题等
            self.fig_plot_parameters()
            # 绘图，散点图
            fig, ax_l, ax_r = self.plot_scatter(data)
            # 设置图片基础属性
            self.set_ax_properties(ax_l, ax_r, data)
            # 显示并保存图形
            # plt.show()
            os.makedirs(os.path.dirname(self.save_path), exist_ok=True)
            plt.savefig(self.save_path, bbox_inches='tight', dpi=300)
            print(f'save {file_name}.tif finish, {i-1} files left')
            i -= 1
        print('Finished, Thanks for using!')


if __name__ == "__main__":
    obj = ScatterChart()
    obj.main()