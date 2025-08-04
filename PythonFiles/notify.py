import socket
import json
import time
import sys
import tkinter as tk
from tkinter import messagebox


opened_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
UDP_IP = "127.0.0.1"
UDP_PORT = 4247

def main():
    args = sys.argv
    #root = tk.Tk()
    #root.withdraw()
    #messagebox.showwarning(args[2], args[3])
    time.sleep(5)
    #print("hello world")
    notify(args)
    



def notify(args=["1","2","3","4"]):  
    byte_message = bytes("Base Enemies stats: "+args[1]+" Tower Investment: "+args[2] + " intensity: " + args[3] + " rank: " +args[4], "utf-8")
    opened_socket.sendto(byte_message, (UDP_IP, UDP_PORT))


if __name__ == "__main__":
    main()