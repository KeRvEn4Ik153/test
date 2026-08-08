extends Player_State

var subject: Interactable

func enter(data: Dictionary = {}) -> void:
	if data.has("subject"):
		subject = data["subject"]
	CR.color = Color(0.884, 0.093, 0.583, 1.0)
		
func update(_delta: float) -> void:
	subject.interact(character)
