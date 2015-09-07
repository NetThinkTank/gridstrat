class Player
	(@name) ->
		this.mesh.position.z = 30

	x: null
	y: null
	
	stepsMax: 5
	stepsTaken: 0
	stepsRemaining: 5

	mesh: null
	opacity: null

	place: (xPos, yPos) ->
		x =
			(-100 * fieldWidth / 2) +
			(100 * (xPos - 1)) +
			50
	
		y =
			(-100 * fieldLength / 2) +
			(100 * (yPos - 1)) +
			50

		this.mesh.position.x = x
		this.mesh.position.y = y
		
		this.x = xPos
		this.y = yPos

	run: (xPos, yPos, subtract = false, fn = null) ->
		position = { x: this.mesh.position.x, y: this.mesh.position.y }
		
		target = {
			x:
				(-100 * fieldWidth / 2) +
				(100 * (xPos - 1)) +
				50
	
			y:
				(-100 * fieldLength / 2) +
				(100 * (yPos - 1)) +
				50
		}
		
		tween = new TWEEN.Tween(position).to(target, 1000)
		
		tween.onUpdate ->
			offense.runningBacks[0].mesh.position.x = this.x
			offense.runningBacks[0].mesh.position.y = this.y
			
		tween.onComplete ->
			if fn
				fn!
			
		tween.start!

		if subtract		
			steps = 0
			steps += Math.abs this.x - xPos
			steps += Math.abs this.y - yPos
			
			this.stepsTaken += steps
			this.stepsRemaining -= steps

			# console.log 'TAKEN: ', this.stepsTaken, 'REMAINING: ', this.stepsRemaining

		this.x = xPos
		this.y = yPos


class OffensiveLineman extends Player
	(@name) ->
		geometry = new THREE.SphereGeometry 25, 100, 100

		this.mesh = new THREE.Mesh(
			geometry
			new THREE.MeshLambertMaterial { color: 0x0000FF }	
		)

		this.skill = Math.random! * 0.75
		
		this.mesh.material.transparent = true
		this.opacity = 0.6 + (this.skill / 0.75 * 0.4)
		this.mesh.material.opacity = this.opacity

		super ...
	
	skill: null


class RunningBack extends Player
	(@name) ->
		geometry = new THREE.SphereGeometry 25, 100, 100

		this.mesh = new THREE.Mesh(
			geometry
			new THREE.MeshLambertMaterial { color: 0x00FF00 }
		)

		this.mesh.material.transparent = true
		this.opacity = 1.0
		this.mesh.material.opacity = this.opacity
		
		super ...


class DefensiveLineman extends Player
	(@name) ->
		geometry = new THREE.BoxGeometry 50, 50, 50, 1, 1, 1

		this.mesh = new THREE.Mesh(
			geometry
			new THREE.MeshLambertMaterial { color: 0xFF0000 }	
		)

		this.mesh.material.transparent = true
		this.opacity = 1.0
		this.mesh.material.opacity = this.opacity

		super ...
