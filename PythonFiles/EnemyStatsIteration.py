import socket
import json
import time
import sys
from nsga2.problem import Problem
from nsga2.evolution import Evolution
import random

maxIntensity = 6
playerInv = []
enemyStats = []
opened_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
UDP_IP = "127.0.0.1"
UDP_PORT = 4247

def main():
    global enemyStats
    global playerInv
    #print("Hello World")
    args = sys.argv
    enemyStats = json.loads(args[1])
    playerInv = json.loads(args[2])
    intensityMod = int(args[3])
    playerRanking = int(args[4])
    time.sleep(1)
    

    statRanges = obtainRanges(enemyStats,intensityMod)
    print()
    print()
    print()
    print("Stat ranges: " + str(statRanges))
    #print(args)
    problem = Problem(num_of_variables=5, objectives=[GeneralTowerEval, StatSquishEval], variables_range=statRanges)
    evo =  Evolution(problem, mutation_param=2,num_of_generations=30,num_of_individuals=100)
    evol = evo.evolve()

    #func = [i.features for i in evol]
    #obj = [i.objectives for i in evol]
    #print(obj)
    nList = orderIndividuals(evol)
    #print(nList)
    newStats = chooseCandidate(nList,playerRanking,intensityMod)
    for i in range(len(newStats)):
        newStats[i] = round(newStats[i],2)

    print(newStats)
    notify(newStats)
    
def obtainRanges(enemyStats,i):
    res= []
    for x in enemyStats:

        res.append(( x-(0.1*(maxIntensity-i)) , x + (x*0.2*i)))
    
    if(res[2][1] > 95 ):
       res[2][1] = 95

    return res   
 
def Coef(x,maxX):
    if maxX==0:
        return 1.0
    return x/maxX

def orderIndividuals(evol):
    listScore =[]
    for i in evol:
        listScore.append((i.features,i.objectives[0]))
    
    return sorted(listScore, key = lambda x: x[1], reverse=True)

def chooseCandidate(nList,pR,iV):
    
    modifier= [-1,0,1]
    a = (6-pR)*(6-iV)
    c = pR*(iV-1)
    mod= random.choices(modifier, weights=(a, 100-(a+c) ,c))[0]
    print(str(a) + " " + str(c) + " " + str(mod))
    if(pR + mod <= 0  or pR+mod >= 6):
        mod=0
    
    StartSection = (len(nList)//5)*(pR+mod-1)
    EndSection = (len(nList)//5)*(pR + mod)
    
    return nList[random.randrange(StartSection,EndSection,1)][0]

def notify(newStats):  
    byte_message = bytes(str(newStats), "utf-8")
    opened_socket.sendto(byte_message, (UDP_IP, UDP_PORT))


def GeneralTowerEval(Hp,Bd,Sr,Atk,Spd):
    #print(enemyStats)
    #print(playerInv)
    stats=[Bd,Sr,Atk,Spd]
    fitness=0
    for i in range(len(stats)):
        fitness += (playerInv[i]*Coef(enemyStats[i+1],stats[i]))
    return fitness    

def StatSquishEval(Hp,Bd,Sr,Atk,Spd):
    stats=[Hp,Bd,Sr,Atk,Spd]
    fitness = 0
    for i in range(len(stats)):
        fitness += (Coef(stats[i],enemyStats[i]))
    return fitness

if __name__ == "__main__":
    main()      