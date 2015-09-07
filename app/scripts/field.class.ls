class Field
	# field creation code modified from
	# stackoverflow.com/questions/12438674/three-js-multiple-material-plane

	(@width, @length) ->
		this.squares = new Array width

		for i in [0 til width]
			this.squares[i] = new Array length

		geometry = new THREE.PlaneGeometry(
			width * 100
			length * 100
			width
			length
		)

		materials = []
		materials.push new THREE.MeshBasicMaterial { color: 0x999999, side: THREE.DoubleSide }
		materials.push new THREE.MeshBasicMaterial { color: 0xCCCCCC, side: THREE.DoubleSide }

		faceCount = geometry.faces.length / 2;
		materialCount = materials.length

		for i in [0 til faceCount]
			j = 2 * i

			geometry.faces[ j ].materialIndex = i % materialCount
			geometry.faces[ j + 1 ].materialIndex = i % materialCount

		materials.push new THREE.MeshBasicMaterial { color: 0x333333, side: THREE.DoubleSide }

		for i in [0 til fieldWidth]
			j = 2 * i
			
			geometry.faces[ j].materialIndex = 2
			geometry.faces[ j + 1 ].materialIndex = 2

		this.mesh = new THREE.Mesh geometry, new THREE.MeshFaceMaterial materials


	squares: []


	debug: ->
		for i in [0 til this.width]
			output = (i + 1) + ' '
			
			for j in [0 til this.length]
				if not this.squares[i][j]
					output += 'X '
				else
					# output += 'O '
					output += this.squares[i][j] + ' '

			console.log output

	
	clear: ->
		for i in [0 til this.width]
			for j in [0 til this.length]
				this.squares[i][j] = null


	place: (player, xPos, yPos) ->
		# console.log 'PLACING ', xPos, yPos
		
		this.squares[xPos - 1][yPos - 1] = player
		player.place xPos, yPos
	
	
	run: (player, xPos, yPos, subtract = false, fn = null) ->
		# console.log 'RUN FROM ', player.x, player.y, 'TO ', xPos, yPos
		
		# console.log 'BEFORE RUN'
		# this.debug!
		
		if xPos < 1
			xPos = 1
			
		if xPos > fieldWidth
			xPos = fieldWidth
			
		if yPos < 1
			yPos = 1
			
		if yPos > fieldLength
			yPos = fieldLength

		this.squares[player.x - 1][player.y - 1] = null
		this.squares[xPos - 1][yPos - 1] = player	
	
		# console.log 'AFTER RUN'
		# this.debug!
	
		player.run xPos, yPos, subtract, fn


	removeSlot: (xPos) ->
		# console.log 'REMOVE SLOT ', xPos, lineOfScrimmage
		
		# console.log 'BEFORE REMOVAL'
		# this.debug!
		
		this.squares[xPos - 1][lineOfScrimmage].mesh.visible = false
		this.squares[xPos - 1][lineOfScrimmage - 1].mesh.visible = false

		this.squares[xPos - 1][lineOfScrimmage] = null
		this.squares[xPos - 1][lineOfScrimmage - 1] = null

		# console.log 'AFTER REMOVAL'
		# this.debug!


	fadeOut: (fn = null) ->
		tween = new TWEEN.Tween({o: 1.0}).to({o: 0.0}, 1000)
		
		tween.onUpdate ->
			offense.runningBacks[0].mesh.material.opacity = this.o
			
			for team in [offense, defense]
				if 'linemen' of team
					for player in team.linemen
						if player.mesh.visible
							player.mesh.material.opacity = this.o * player.opacity

		tween.onComplete ->
			if fn
				fn!

		tween.start!
		

	fadeIn: (fn = null) ->
		tween = new TWEEN.Tween({o: 0.0}).to({o: 1.0}, 1000)
		
		tween.onUpdate ->
			offense.runningBacks[0].mesh.visible = true
			offense.runningBacks[0].mesh.material.opacity = this.o
			
			for team in [offense, defense]
				if 'linemen' of team
					for player in team.linemen
						player.mesh.visible = true
						player.mesh.material.opacity = this.o * player.opacity

		tween.onComplete ->
			if fn
				fn!

		tween.start!


	moveLines: (lineOfScrimmage, ...teams) ->
		this.clear!
		
		# console.log 'LINE OF SCRIMMAGE: ', lineOfScrimmage
		
		# console.log 'AFTER CLEAR'
		# this.debug!
	
		for team, i in teams
			if 'linemen' of team
				for player, j in team.linemen
					this.place player, (j + 1), (lineOfScrimmage + i)

		# console.log 'AFTER MOVE'
		# this.debug!


	findClosestClearX: (currentX) ->
		if not this.squares[currentX - 1][lineOfScrimmage - 1]
			return currentX
	
		spacesLeft = currentX - 1
		spacesRight = fieldWidth - currentX
		
		if spacesLeft >= spacesRight
			spaces = spacesLeft
		else
			spaces = spacesRight
		
		for i in [1 to spaces]
			if (currentX - i >= 1) and (not this.squares[currentX - i - 1][lineOfScrimmage - 1])
				return currentX - i

			if (currentX + i <= fieldWidth) and (not this.squares[currentX + i - 1][lineOfScrimmage - 1])
				return currentX + i

		return 0
