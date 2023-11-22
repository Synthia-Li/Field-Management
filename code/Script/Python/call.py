'''
Author       : LuHeQiu
Date         : 2022-10-07 17:44:20
LastEditTime : 2022-10-07 19:24:21
LastEditors  : LuHeQiu
Description  : 
FilePath     : \Python\call.py
HomePage     : https://www.luheqiu.com
'''

import sys
import os

if __name__ == "__main__":

    argc = len(sys.argv)

    for i in range(0,argc):
        print(str(i)+": "+str(sys.argv[i]))

    print(os.getcwd())
    print("arg feedback over!")