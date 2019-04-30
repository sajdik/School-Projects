#IPK-proj1 
#author: xsajdi01
#varianta: 2 - Klient pro OpenWeatherMap API


import sys
import socket
import json

host = "api.openweathermap.org"
port =  80

def main():
    CheckArgumentCount()
    scket = CreateSocket()
    ConnectSocketToServer(scket)
    weatherData = LoadData(scket)
    PrintWeatherInfo(weatherData)


def CheckArgumentCount():
    if(len(sys.argv) != 3):
        print("Usage: make run api_key=<API klíč> city=<Město>")
        exit(1)


def CreateSocket():
    return socket.socket(family=socket.AF_INET, type=socket.SOCK_STREAM)


def ConnectSocketToServer(scket):
        try:
                scket.connect((host,port))
        except:
                print("Could not connect to server",file=sys.stderr)
                exit(1)

def LoadData(scket):
    request = CreateRequest()
    scket.send(request.encode())
    data = scket.recv(4096).decode()
    return json.loads(data.split('\r\n\r\n')[1])


def CreateRequest():
    return "GET /data/2.5/weather?q=" + GetCityName() + "&APPID=" + GetApiKey()  + "&units=metric" + " HTTP/1.0\r\n\r\n"


def GetApiKey():
    return sys.argv[1]


def GetCityName():
    return sys.argv[2]


def PrintWeatherInfo(data):
    if(not DataIsValid(data)):
        print(data["message"], file=sys.stderr)
        exit(1)
    print(GetCityName())
    print("overcast " + data["weather"][0]["main"])
    print("temp:" + str(data["main"]["temp"]) + "°C")
    print("humidity:" + str(data["main"]["humidity"]) + "%")
    print("pressure:" + str(data["main"]["pressure"]) + " hPa")
    print("wind-speed: " + str(data["wind"]["speed"]*3.6) + "km/h")
    print("wind-deg: " + str(data["wind"]["speed"]))


def DataIsValid(data):
    return data["cod"] == 200


main()
