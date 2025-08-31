extends Control

### -------------------- Variables --------------------
## Scene Animations
@onready var SceneChangeAnimation = $MISC/SceneChangeAnimation/AnimationPlayer
@onready var SceneChangeAnimationParent = $MISC/SceneChangeAnimation

## Sounds
@onready var click = $"MISC/ClickSound"
@onready var bg_music = $MISC/bg_music
@onready var fire_crackle = $MISC/fire_crackle
@onready var page_flip = $MISC/page_flip

## Page Refrences
@onready var MainMenu = $"Main Menu"
@onready var H2P = $HowToPlay
@onready var Credits = $Credits
#@onready var Settings = 
@onready var Characters = $Characters
@onready var Journal = $Characters/JournalMenu

## Editable Book Parts
@onready var FloatTitle = $Framework/FloatingTitleCover
@onready var ConnectTitle = $"Main Menu/ConnectedTitleCover"
@onready var Tabs = $Framework/Tabs
@onready var ActiveTabs = $Framework/ActiveTabs
@onready var Home = $MISC/HomeParent
@onready var Next = $MISC/NextParent

@onready var Tab1 = $Framework/ActiveTabs/Tab1Active
@onready var Tab2 = $Framework/ActiveTabs/Tab2Active
@onready var Tab3 = $Framework/ActiveTabs/Tab3Active
@onready var Tab4 = $Framework/ActiveTabs/Tab4Active

## Creature List
@onready var Creatures := {
	"Werewolf": $Characters/Werewolf,
	"Ogre": $Characters/Ogre,
	"Leshy": $Characters/Leshy,
	"Slime": $Characters/Slime,
	"Golem": $Characters/Golem
}
@onready var creature_names := ["Werewolf", "Ogre", "Leshy", "Slime", "Golem"]
var current_creature_index := 0


### -------------------- On Run --------------------
func _ready() -> void:
	## Sounds
	bg_music.play() # play bg music
	fire_crackle.play() # play fire crackle sound
	
	## Hide Everything
	MainMenu.hide()
	Credits.hide()
	H2P.hide()
	Home.hide()
	Next.hide()
	FloatTitle.hide()
	Tabs.hide()
	Characters.hide()
	Tab1.hide()
	Tab2.hide()
	Tab3.hide()
	Tab4.hide()
	
	for i in Creatures.values(): # hide creature subpages
		i.hide()
	
	## Show main menu book parts
	ConnectTitle.show() # show main menu title bg
	MainMenu.show() # show main menu page
	
	## Scene Animation
	SceneChangeAnimationParent.show() # cos _ready doesn't have a page_flip_start which does this
	await page_flip_end()


### -------------------- Play --------------------
func _on_play_button_pressed() -> void:
	click.play()
	
	## Scene Animation
	SceneChangeAnimationParent.show() # show animation player node
	SceneChangeAnimation.play("fade_in") # play animation
	await SceneChangeAnimation.animation_finished # pause everything until animation is finished
	
	## Change Scene
	get_tree().change_scene_to_file("res://Goblin's_Path/scenes/tutorial.tscn") # change to tutorial scene


### -------------------- Quit --------------------
func _on_quit_button_pressed() -> void:
	click.play()
	
	## Scene Animation
	SceneChangeAnimationParent.show()
	SceneChangeAnimation.play("fade_in")
	await SceneChangeAnimation.animation_finished
	
	## Quit
	get_tree().quit()


## -------------------- Settings --------------------
func _on_tab1_button_pressed() -> void:
	pass # Replace with function body.


### -------------------- Credits --------------------
func _on_tab4_button_pressed() -> void:
	await page_flip_start() # hide everything & play animations
	
	# rebuild everything
	Credits.show() # show credits page
	
	Home.show() # show back to main menu button
	Tabs.show() # show tabs
	Tab1.hide()
	Tab2.hide()
	Tab3.hide()
	Tab4.show()
	ActiveTabs.show() # show active tabs
	FloatTitle.show() # show title floating title bg
	
	await page_flip_end()


### -------------------- How To Play --------------------
func _on_tab2_button_pressed() -> void:
	await page_flip_start() # hide everything & play animations
	
	# rebuild everything
	H2P.show() # show tutorial page
	
	Home.show() # show back to main menu button
	Next.show() # show next page button
	Tabs.show() # show tabs
	Tab1.hide()
	Tab2.show()
	Tab3.hide()
	Tab4.hide()
	ActiveTabs.show() # show active tabs
	FloatTitle.show() # show title floating title bg
	
	await page_flip_end()


### -------------------- Return Home --------------------
func _on_home_pressed() -> void:
	await page_flip_start() # hide everything & play animations
	
	MainMenu.show() # show main menu page
	ConnectTitle.show() # show main menu title bg
	
	await page_flip_end()


### -------------------- Page Flip Start --------------------
func page_flip_start():
	click.play() # play click sound
	
	## Scene Animation
	SceneChangeAnimationParent.show() # show the node
	SceneChangeAnimation.play("fade_in") # play the animation
	await SceneChangeAnimation.animation_finished # pause everything until animation is finished
	
	page_flip.play() # play page flipping sound 
	
	## Hide Everything
	MainMenu.hide()
	Credits.hide()
	H2P.hide()
	Home.hide()
	Next.hide()
	FloatTitle.hide()
	ConnectTitle.hide()
	Tabs.hide()
	Tab1.hide()
	Tab2.hide()
	Tab3.hide()
	Tab4.hide()
	Characters.hide()
	for i in Creatures.values():
		i.hide()


### -------------------- Page Flip End --------------------
func page_flip_end():
	## Scene Animation
	SceneChangeAnimation.get_parent().get_node("ColorRect").color.a = 255 # ensure rect is transparent 
	SceneChangeAnimation.play("fade_out") # play animation
	await SceneChangeAnimation.animation_finished # pause everything until animation is finished
	SceneChangeAnimationParent.hide() # hide animationplayer node to allow user to click


### -------------------- Journal Sub-Pages --------------------
func _on_table_of_contents_meta_clicked(meta: Variant) -> void:
	print(meta) # DEBUG PRINT
	
	# Show the clicked one (if it exists)
	if Creatures.has(meta):
		# hide everything and play animation
		await page_flip_start()
		
		show_creature(creature_names.find(meta))
		
		await page_flip_end()
	
	print("Has Not Been Added Yet") # DEBUG PRINT


func show_creature(index: int) -> void:
	Characters.show() # show characters page
	Journal.hide() # hide table of contents
	
	# Hide all creatures
	for i in Creatures.values():
		i.hide()
	
	# Wrap around the index if out of bounds
	index = index % creature_names.size()
	current_creature_index = index
	
	# Show the current creature
	Creatures[creature_names[index]].show()
	
	# Show journal UI bits
	Home.show()
	Next.show()
	Tabs.show()
	Tab1.hide()
	Tab2.hide()
	Tab3.show()
	Tab4.hide()
	ActiveTabs.show()
	FloatTitle.show()


### -------------------- Dev Mode --------------------
func _on_dev_button_pressed() -> void:
	click.play()
	pass # Replace with function body.


### -------------------- Next Page Button --------------------
func _on_next_pressed() -> void:
	await page_flip_start()
	show_creature(current_creature_index + 1)
	await page_flip_end()


### -------------------- Journal --------------------
func _on_tab3_button_pressed() -> void:
	await page_flip_start() # hide everything & play animations
	
	
	# rebuild everything
	Characters.show() # show characters/creatures main page
	Journal.show() # show creature list/table of contents
	
	Home.show() # show back to main menu button
	Tabs.show() # show tabs
	Tab1.hide()
	Tab2.hide()
	Tab3.show()
	Tab4.hide()
	ActiveTabs.show() # show active tabs
	FloatTitle.show() # show title floating title bg
	
	await page_flip_end()
