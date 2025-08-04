extends Node


#total damage taken in level,
var hAScore 
 
#total currency invested in towers 
var towerValues 
# Spread of types of towers
var numberTowers

 

#the expected score for comparission and use in evaluation
var expectedScore 

#Score for current stage 
var stageScore

#Evaluation for perfomance of current player, obtained by comparing with expected and previous stage, this value influences events and enemy stats
#Value varies between 1 and 5

var playerRank = 3

# Class in charge of making an evaluation of the current round performance of the player

# Called when the node enters the scene tree for the first time.
func _ready():

	numberTowers = []
	stageScore = 0
	playerRank = 3
	hAScore=0
	numberTowers = 0
	
func updateExpectations(expectations , levelScore ,scoreIndex):
	expectedScore = (expectations* 9 + levelScore)/10
	Global.ExpectedScorePerLevel[scoreIndex] = expectedScore
	
func reset():
	Global.playerScoreP = 0
	hAScore=0
	numberTowers = 0
	playerRank = 3

func obtainScore(leftover,remainingHp,Towers):
	var towerScore = obtainTowerScore(Towers)
	var leftoverScore = (Global.leftoverResMult)*leftover
	var endScore = Global.playerScoreP + towerScore + (Global.hPMult)*remainingHp + leftoverScore
	Global.totalPlayerScore = endScore
	#print("PlayerScored " + str(roundEndScore) )
	return endScore

func obtainTowerScore(Towers):
	var aux = 0
	for x in Towers:
		aux += x.getValue()
	return aux
	
func obtainRank(coef):
	if coef <= 0.75 :
		return 1
	if range(0.76, 0.91).has(coef):
		return 2
	if range(0.91, 1.1).has(coef):
		return 3
	if range(1.11, 1.25).has(coef):
		return 4
	if coef >= 1.25:
		return 5
	
	return 3	
				
func calcPerformance(leftover,remainingHp,Towers,ExpectedScoreData):
	print("obtaining data from: " + ExpectedScoreData)
	var ExpectedScore = Global.ExpectedScorePerLevel[ExpectedScoreData]
	var obtainedScore = obtainScore(leftover,remainingHp,Towers)
	print("Score Obtained : " + str(obtainedScore))
	var scoreCoef = obtainedScore / ExpectedScore
	if abs(scoreCoef-1) <= 0.33:
		updateExpectations(ExpectedScore,obtainedScore, ExpectedScoreData)
	playerRank = obtainRank(scoreCoef)
	print("player rank obtained : " + str(playerRank))	
	return playerRank

func updateScore(leftover,remainingHp,Towers):
	obtainScore(leftover,remainingHp,Towers)
