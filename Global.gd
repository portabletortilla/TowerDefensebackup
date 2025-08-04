extends Node

var currLevel=1
var health = 20
var currency = 25
var dropRateStagnant = 0.6
var dropRate = dropRateStagnant
var presentMult = 1
var currentRound = 0
var nRounds = 5

var enemySpeedMultiplier = 1
var enemyDmgMultiplier = 1
var enemyHpMultiplier = 1
var shieldAddition=0
var reviveAddition=0
var rpsMultplier=1

#TODO alter with intensity value later on
var eventChance = 0.01
#lock for when events are active
var eventLock = 0

var sellRatio = 1.0

var srDict = {1:1.0,
			  2:0.9,
			  3:0.75}
		
var srDegradation = {1:0,
			 		 2:0.05,
			  		 3:0.125}

var intensityDict=[[0,1,1],
				   [0,3,3,4],
				   [0,5,5,6,6]]

var baseEventChanceDict = {1:0.,
			 		 	   2:0.01,
			 			   3:0.125}
var playerScoreP = 0
var leftoverResMult = 1.2
var hPMult= 10

var intensityValue = 3
var eventNotificationWarningDuration = 10
#totalPlayerScore = P + leftover currency* Mr + Tower Development + 10*remaining HealthPoints
var totalPlayerScore = 0

#evaluation value that operates over the game, initiated at 3 for round 1
var PlayerRank = 3

#base enemy stats that are iterated on during each round, initiated with this value at the start of a level
var baseEnemyTemplatesStats = [9.61, 1.17, 6.0, 2.03, 120.9]
var baseEnemyTemplatesStatsAux = baseEnemyTemplatesStats
# enemy line up [G,R,Y,B]

var waveLineUp =  [ 
				  [ [1,10], [2,5] ] ,
				  [ [1,25], [2,10], [3,2], [4,0] ],
				  [ [1,30], [2,25], [4,1] ],
				  [ [1,45], [2,45], [3,5], [4,1] ],
				  [ [1,100], [2,30], [3,20], [4,5] ]
				  ]
				
var waveLineUpAux = waveLineUp

#initiallized on scene handler
var ExpectedScorePerLevel= {}
