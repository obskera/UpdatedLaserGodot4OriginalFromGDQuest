extends Node2D

@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var line_2d: Line2D = $RayCast2D/Line2D
@onready var casting_particles_2d: CPUParticles2D = $RayCast2D/CastingParticles2D
@onready var collission_particles_2d: CPUParticles2D = $RayCast2D/CollissionParticles2D
@onready var beam_particles_2d: CPUParticles2D = $RayCast2D/BeamParticles2D

var minLineWidth: float = 0.0
var maxLineWidth: float = 10.0

#uses newer get and set
var is_casting: bool = false:
	get: return is_casting
	set(casting): 
		#check to make sure value is a bool, or return
		if typeof(casting) != TYPE_BOOL: 
			print("invalid value; catch error here how you'd like.")
			return
		if casting:
			is_casting = casting
			ray_cast_2d.set_physics_process(casting)
			casting_particles_2d.emitting = casting
			beam_particles_2d.emitting = casting
			appear()
		else:
			disappear()
			is_casting = casting
			ray_cast_2d.set_physics_process(casting)
			casting_particles_2d.emitting = casting
			collission_particles_2d.emitting = casting
			beam_particles_2d.emitting = casting

#delete and replace if/when player control added in project, this allows you to quickly demo it
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		is_casting = event.pressed

func appear(duration: float = 0.2) -> void:
	var tween = create_tween()
	tween.tween_property(line_2d, "width", maxLineWidth, duration)
	
func disappear(duration: float  = 0.1) -> void:
	var tween = create_tween()
	tween.tween_property(line_2d, "width", minLineWidth, duration)

func _ready() -> void:
	ray_cast_2d.set_physics_process(false)
	line_2d.points = [Vector2.ZERO, Vector2.ZERO]
	line_2d.width = minLineWidth
	collission_particles_2d.emitting = false

func _physics_process(delta: float) -> void:
	var cast_point: Vector2 = ray_cast_2d.target_position
	ray_cast_2d.force_raycast_update()
	
	if is_casting:
		collission_particles_2d.emitting = ray_cast_2d.is_colliding()

	if ray_cast_2d.is_colliding():
		var collPoint: Vector2 = ray_cast_2d.get_collision_point()
		cast_point = to_local(ray_cast_2d.get_collision_point())
		var distance: float = line_2d.points[0].distance_to(collPoint)
		collission_particles_2d.global_rotation = ray_cast_2d.get_collision_normal().angle()
		collission_particles_2d.global_position = collPoint
		line_2d.points = [Vector2.ZERO, Vector2(cast_point.x + distance, cast_point.y)]
	
	beam_particles_2d.position = cast_point * 0.5
	beam_particles_2d.emission_rect_extents.x = (cast_point.length() + 1) * 0.5
	
