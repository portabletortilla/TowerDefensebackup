extends Node

#TODO implement map/tower coverage and closest an enemy got

#total damage taken in level,
var damageTaken 
 
#total currency invested in towers 
var towerValues 

# Spread of types of towers
var numberTowers 

#the score on each stage 
var levelScore 

#the expected score for comparission and use in evaluation
var expectedScore 

#Score for current stage 
var stageScore

#Evaluation for perfomance of current player,obtained by comparing with expected and previous stage,this value influences events and enemy stats
#Value varies between -2 and 2
var playerPerformance = 0

# Class in charge of making an evaluation of the current round performance of the player

# Called when the node enters the scene tree for the first time.
func _ready():
	damageTaken = 0
	towerValues = 0
	levelScore = []
	numberTowers = []
	stageScore = 0
	playerPerformance = 0
	
func insertExpectations(expectations):
	expectedScore = expectations

func reset():
	levelScore=[]
	damageTaken = 0
	numberTowers = 0
	playerPerformance = 0
	
func updateDamageTaken(damage):
	damageTaken += damage
	
func updateAndCalculate(nTowerValues,nNumberTowers) :
	towerValues=nTowerValues
	numberTowers=nNumberTowers
	
	return calcPerformance()

func calcPerformance():
	
	#TODO reset stage only vars
	damageTaken=0
	return 0
