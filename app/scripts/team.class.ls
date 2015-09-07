class Team
	(@name) ->
		this

	slug: null
	name: null


class OffensiveTeam extends Team
	(@name) ->
		super ...

	linemen: []
	runningBacks: []


class DefensiveTeam extends Team
	(@name) ->
		super ...
	
	linemen: []
