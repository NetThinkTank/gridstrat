# CUSTOMIZATION VALUES

fieldWidth = 7
fieldLength = 15

lineOfScrimmage = 2

downsPerSeries = 3
firstDownLength = 9

# END OF CUSTOMIZATION VALUES


down = 1
firstDownLine = lineOfScrimmage + firstDownLength

field = null
offense = null
defense = null

renderer = null
scene = null
camera = null
controls = null

status = 'OK'
input = null

# rbTest = [5, 5, 5]


onWindowResize = ->
	width = window.innerWidth 
	height = window.innerHeight

	camera.aspect = width / height
	camera.updateProjectionMatrix!

	renderer.setSize width, height


animate = ->
	requestAnimationFrame animate

	TWEEN.update!

	renderer.render scene, camera
	controls.update!


ordinal = (n) ->
	list = ['1st', '2nd', '3rd']

	if n < 4
		return list[n-1]
	else
		return n + 'th'


addMessage = (message) ->
	messages = page '#messages'

	messages.append message
	messages.scrollTop messages.prop 'scrollHeight'


enableInput = (fn) ->
	input := null

	Mousetrap.bind '1', -> input := 1; fn!
	Mousetrap.bind '2', -> input := 2; fn!
	Mousetrap.bind '3', -> input := 3; fn!
	Mousetrap.bind '4', -> input := 4; fn!
	Mousetrap.bind '5', -> input := 5; fn!
	Mousetrap.bind '6', -> input := 6; fn!
	Mousetrap.bind '7', -> input := 7; fn!
	Mousetrap.bind '8', -> input := 8; fn!
	Mousetrap.bind '9', -> input := 9; fn!


disableInput = ->
	Mousetrap.bind '1', -> return
	Mousetrap.bind '2', -> return
	Mousetrap.bind '3', -> return
	Mousetrap.bind '4', -> return
	Mousetrap.bind '5', -> return
	Mousetrap.bind '6', -> return
	Mousetrap.bind '7', -> return
	Mousetrap.bind '8', -> return
	Mousetrap.bind '9', -> return


runPlay1 = ->
	if status != 'OK'
		return

	o = ordinal down
	
	if down == 1
		firstDownLine := lineOfScrimmage + firstDownLength
	
	if firstDownLine >= fieldLength
		firstDownLine := fieldLength - 1

	addMessage(
		"#{o} down of #{downsPerSeries} at the #{lineOfScrimmage}, " +
		"must get past the #{firstDownLine}.<br/>" +
		"Place your running back by typing a number from " +
		"1 to #{fieldWidth}.<br/>"
	)

	enableInput runPlay2


runPlay2 = ->
	disableInput!
	
	if input > fieldWidth
		input := fieldWidth

	addMessage "Position #{input} selected.<br/>"
	addMessage "Running play...<br/>"
	
	rb = offense.runningBacks[0]
	field.run rb, input, rb.y, false, runPlay3
	

runPlay3 = ->
	newMessage = ''

	for player, i in offense.linemen
		r = Math.random!
		# console.log 'RANDOM: ', r, , ' SKILL: ', player.skill
	
		if r < player.skill
			newMessage += "#{player.name} (skill #{player.skill.toFixed(3)}) won, "
			field.removeSlot i + 1
		else
			newMessage += "#{player.name} (skill #{player.skill.toFixed(3)}) lost, "

	newMessage = newMessage.substring 0, newMessage.length - 2
	addMessage newMessage + ".<br/>"

	rb = offense.runningBacks[0]
	ccx = field.findClosestClearX rb.x
	
	if ccx
		addMessage "Nearest open gap is #{ccx}.<br/>"
		
		if Math.abs(ccx - rb.x) > rb.stepsRemaining
			addMessage "Runner can't make it to the gap!<br/>"
			runPlay5!
		else
			field.run rb, ccx, rb.y, true, runPlay4
	else
		addMessage "No open gap!<br/>"
		runPlay5!


runPlay4 = ->
	rb = offense.runningBacks[0]
	
	if (typeof rbTest != 'undefined') and rbTest.length
		steps = rbTest.shift!
		field.run rb, rb.x, rb.y + steps, false, runPlay5
	else if rb.stepsRemaining
		field.run rb, rb.x, rb.y + rb.stepsRemaining, true, runPlay5
	else
		runPlay5!


runPlay5 = ->
	down++
	
	rb = offense.runningBacks[0]
	
	rb.stepsTaken = 0
	rb.stepsRemaining = rb.stepsMax
	
	if rb.y <= lineOfScrimmage
		rb.y = lineOfScrimmage
	
	if rb.y >= fieldLength
		status := 'TOUCHDOWN'
		addMessage 'Touchdown!'
	else if rb.y > firstDownLine
		lineOfScrimmage := rb.y
		down := 1
		
		addMessage 'First down!<br/>'
		field.fadeOut runPlay6
	else if down > downsPerSeries
		status := 'FAIL'
		addMessage 'Fail!'
	else
		lineOfScrimmage := rb.y
		field.fadeOut runPlay6


runPlay6 = ->
	rb = offense.runningBacks[0]

	field.moveLines lineOfScrimmage, offense, defense
	field.place rb, Math.ceil(fieldWidth / 2), lineOfScrimmage - 1
	
	# field.debug!

	field.fadeIn runPlay1


page = jQuery

page ->

	fieldLength += 1

	if fieldWidth > 9
		fieldWidth := 9
		addMessage "Field width maximum is 9 due to keyboard input.<br/>"

	if fieldWidth % 2 == 0
		fieldWidth -= 1
		addMessage "Field width set to #{fieldWidth} to make it odd.<br/>"

	window.addEventListener 'resize', onWindowResize, false	

	width = window.innerWidth
	height = window.innerHeight

	container = document.createElement 'div'
	document.body.appendChild container

	renderer := new THREE.WebGLRenderer
	renderer.setClearColor 0x000000, 1
	renderer.setSize width, height

	container.appendChild renderer.domElement

	scene := new THREE.Scene
	
	camera := new THREE.PerspectiveCamera(
		35
		width / height
		0.1
		10000
	)
	
	camera.aspect = width / height
	camera.updateProjectionMatrix!
	
	camera.position.set 0, -2000, 500
	camera.lookAt 0, 0, 0
	
	controls := new THREE.OrbitControls camera, renderer.domElement
	
	directionalLight = new THREE.DirectionalLight 0xffffff
	directionalLight.position.set(0, -1500, 500).normalize!
	scene.add directionalLight

	field := new Field fieldWidth, fieldLength, lineOfScrimmage
	scene.add field.mesh

	offense := new OffensiveTeam 'Offense'
	defense := new DefensiveTeam 'Defense'

	addMessage "Your team from right to left:<br/>"

	for i in [1 to fieldWidth]
		player = new OffensiveLineman "OL #{i}"
		offense.linemen ++= player

		addMessage "#{player.name} - skill #{player.skill.toFixed(3)}<br/>"

		scene.add player.mesh

	for i in [1 to fieldWidth]
		player = new DefensiveLineman "DL #{i}"
		defense.linemen ++= player
	
		scene.add player.mesh

	player = new RunningBack 'RB'
	offense.runningBacks ++= player
	scene.add player.mesh

	field.moveLines lineOfScrimmage, offense, defense
	field.place player, Math.ceil(fieldWidth / 2), 1

	animate!

	runPlay1!
