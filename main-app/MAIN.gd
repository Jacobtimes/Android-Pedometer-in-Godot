extends Node2D

#1080x2388

#line offset
var offset_x = 25
var offset_y = 1200

var steps = 0

#Debugger + graphs
#This whole _process function can be deleted as its not involved in tracking steps
func _process(_delta: float) -> void:
	
	ALPHA = $HSlider.value
	$HSlider/Label.text = "ALPHA VALUE" + str(ALPHA)
	
	#debugger code
	$Debug.text = "DEBUGGER\n" + str(Input.get_accelerometer()) + "\nMagnitude: " + str(filtered_magnitude)
	
	$STEPS.text = "Steps:" + str(steps)
	
	#line stuff
	#Filtered line
	$Line2D.add_point(Vector2(0+offset_x,filtered_magnitude+offset_y))
	if $Line2D.get_point_count() >= 105:
		$Line2D.remove_point(0)
	
	for i in range($Line2D.get_point_count()):
		var current_pos = $Line2D.get_point_position(i)
		current_pos.x = i * 10
		$Line2D.set_point_position(i,current_pos)
		
	#Unfiltered line
	$Line2D2.add_point(Vector2(0+offset_x,raw_magnitude+offset_y-300))
	if $Line2D2.get_point_count() >= 105:
		$Line2D2.remove_point(0)
	
	for i in range($Line2D2.get_point_count()):
		var current_pos = $Line2D2.get_point_position(i)
		current_pos.x = i * 10
		$Line2D2.set_point_position(i,current_pos)
	
#magnitude variables
#APLHA controls how rough the filtering is
var ALPHA: float = 0.08
var filtered_magnitude: float = 0.0
var raw_magnitude: float = 0.0
var is_first_frame: bool = true

#calculates filtered magnitude
func _physics_process(delta: float) -> void:
	var raw_acceleration: Vector3 = Input.get_accelerometer()
	raw_magnitude = raw_acceleration.length()
	
	if is_first_frame:
		filtered_magnitude = raw_magnitude
		is_first_frame = false
	else:
		filtered_magnitude = (ALPHA * raw_magnitude) + ((1.0 - ALPHA) * filtered_magnitude)
	
	if cooldown_timer > 0.0:
		cooldown_timer -= delta
	
	process_step_detection()
	
#step counter variables
#magnitude for the step to be counted
const STEP_THRESHOLD = 11.0

#time between steps
const COOLDOWN_TIME: float = 0.25 
var cooldown_timer: float = 0.0

#Ensures the step is being counted at the peak of the magnitude
var prev_magnitude: float = 9.8
var older_magnitude: float = 9.8

#detect steps
func process_step_detection() -> void:
	if cooldown_timer <= 0.0:
		if prev_magnitude > STEP_THRESHOLD:
			if prev_magnitude > older_magnitude and prev_magnitude > filtered_magnitude:
				register_step()
				
	older_magnitude = prev_magnitude
	prev_magnitude = filtered_magnitude

#What to do after registering a step
func register_step():
	steps += 1
	
	#Important for the step delay
	cooldown_timer = COOLDOWN_TIME
