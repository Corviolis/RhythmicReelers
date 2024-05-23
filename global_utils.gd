extends Node

static func equal_approx(a: float, b: float) -> bool:
	return abs(a - b) < 1
