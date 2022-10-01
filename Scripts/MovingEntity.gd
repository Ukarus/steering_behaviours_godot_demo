extends Node2D

class_name MovingEntity

export var m_vVelocity: Vector2
# a normalized vector pointing in the direction the entity is heading
export var m_vHeading: Vector2
# a perpendicular to the heading vector
export var m_vSide: Vector2

export var m_vPosition: Vector2

export var m_dMass: float
# the maximum speed at which this entity will travel
export var m_dMaxSpeed: float
# the maximum force this entity can produce to power itself
export var m_dMaxForce: float
# the maximum rate (radians per second) at which this vehicle can rotate
export var m_dMaxTurnRate: float

func _init(v, h, s, p, mass, ms, mf, mt):
	self.m_vVelocity = v
	self.m_vHeading = h
	self.m_vSide = s
	self.m_vPosition = p
	self.m_dMass = mass
	self.m_dMaxSpeed = ms
	self.m_dMaxForce = mf
	self.m_dMaxTurnRate = mt
