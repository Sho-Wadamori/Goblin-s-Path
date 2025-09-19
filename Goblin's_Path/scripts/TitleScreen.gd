"""
Script for title screen.
Includes:
	- Play and quit
	- tutorial/h2p (how to play)
		- 4 pages with looping videos
	- settings
		- full screen
		- touch controls
		- hide/show timer
		- music volume
		- sound effect volume
		- keybinds
	- journal
		- 8 creatures
	- credits
The changing of pages was done by fading into black, hiding/showing necessary nodes, then fading out.
Fade in/out makes game super laggy on low-end devices when exported to HTML
"""

extends Control

### -------------------- Variables --------------------
## Scene Animations
@onready var SceneChangeAnimationParent = $MISC/SceneChangeAnimation
@onready var box = $MISC/SceneChangeAnimation/Control/ColorRect

## Sounds
@onready var click = $"MISC/ClickSound"
@onready var page_flip = $MISC/page_flip
@onready var bg_music = $MISC/bg_music

## Page Refrences
@onready var MainMenu = $"Main Menu"
@onready var H2P = $HowToPlay
@onready var Credits = $Credits
@onready var Settings = $Settings
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

var current_page = null

## Creature List
@onready var Creatures := {
	"Goblin": $Characters/Goblin,
	"Werewolf": $Characters/Werewolf,
	"Ogre": $Characters/Ogre,
	"Leshy": $Characters/Leshy,
	"Centaur": $Characters/Centaur,
	"Slime": $Characters/Slime,
	"Elf": $Characters/Elf,
	"Golem": $Characters/Golem
}
@onready var creature_names := ["Goblin", "Werewolf", "Ogre", "Leshy", "Centaur", "Slime", "Elf", "Golem"]
var current_creature_index := 0

@onready var H2P_pages := [$HowToPlay/Page1, $HowToPlay/Page2, $HowToPlay/Page3]
var current_H2P_index := 0

### -------------------- On Run --------------------
func _ready() -> void:
	## Sounds
	$Settings/MusicSlider.value = 50
	$Settings/SFXSlider.value = 50
	_on_music_slider_value_changed($Settings/MusicSlider.value)
	_on_sfx_slider_value_changed($Settings/SFXSlider.value)
	
	## Hide Everything
	Settings.hide()
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
	
	# touch screen detection
	if DisplayServer.is_touchscreen_available():
		SettingsGlobal.touchscreen = true
	else:
		SettingsGlobal.touchscreen = false
	
	## Show main menu book parts
	ConnectTitle.show() # show main menu title bg
	MainMenu.show() # show main menu page
	
	## Reset settings
	SettingsGlobal.checkpoint = null
	SettingsGlobal.change_health(3)
	
	## Scene Animation
	await page_flip_end()


### -------------------- Play --------------------
func _on_play_button_pressed() -> void:
	click.play()
	
	## Scene Animation
	var tween = create_tween()
	tween.tween_property(bg_music, "volume_db", -80, 1.0)   

	await fade_in(0.5)
	bg_music.stop()
	
	## Change Scene
	get_tree().change_scene_to_file("res://Goblin's_Path/scenes/tutorial.tscn") # change to tutorial scene


### -------------------- Quit --------------------
func _on_quit_button_pressed() -> void:
	click.play()
	
	## Scene Animation
	await fade_in(0.5)
	
	## Quit
	get_tree().quit()


## -------------------- Settings --------------------
func _on_tab1_button_pressed() -> void:
	await page_flip_start() # hide everything & play animations
	
	# rebuild everything
	Settings.show() # show credits page
	
	Home.show() # show back to main menu button
	Tabs.show() # show tabs
	Tab1.show()
	Tab2.hide()
	Tab3.hide()
	Tab4.hide()
	ActiveTabs.show() # show active tabs
	FloatTitle.show() # show title floating title bg
	
	await page_flip_end()

func _on_feedback_pressed() -> void:
	OS.shell_open("https://sho-w.itch.io/goblins-path")

func _on_full_screen_pressed() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		# Already fullscreen → go back to windowed
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		SettingsGlobal.fullscreen = false
	else:
		# Not fullscreen → make it fullscreen
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		SettingsGlobal.fullscreen = true

# turn 0 - 100 scale to db
func slider_to_db(value: float) -> float:
	var normalized = float(value) / 100.0
	if normalized <= 0.001:
		return -80.0  # silence
	return lerp(-40.0, 0.0, normalized)

# music volume slider
func _on_music_slider_value_changed(value: float) -> void:
	var db = slider_to_db(value)
	var bus = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(bus, db)
	SettingsGlobal.music_volume = value

# SFX volume slider
func _on_sfx_slider_value_changed(value: float) -> void:
	var db = slider_to_db(value)
	var bus = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(bus, db)
	SettingsGlobal.sfx_volume = value

func _on_timer_pressed() -> void:
	if SettingsGlobal.enable_timer:
		SettingsGlobal.enable_timer = false
	else:
		SettingsGlobal.enable_timer = true

func _on_touch_controls_pressed() -> void:
	if SettingsGlobal.touchscreen:
		SettingsGlobal.touchscreen = false
	else:
		SettingsGlobal.touchscreen = true


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
	
	for i in H2P_pages:
		i.hide()
	
	current_H2P_index = 0
	H2P_pages[current_H2P_index].show()
	
	Home.show() # show back to main menu button
	Next.show() # show next page button
	Tabs.show() # show tabs
	Tab1.hide()
	Tab2.show()
	Tab3.hide()
	Tab4.hide()
	ActiveTabs.show() # show active tabs
	FloatTitle.show() # show title floating title bg
	
	current_page = "h2p"
	
	await page_flip_end()


### -------------------- Page Flip Start --------------------
func page_flip_start():
	click.play() # play click sound
	
	## Scene Animation
	await fade_in(0.5)
	
	page_flip.play() # play page flipping sound 
	
	## Hide Everything
	Settings.hide()
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
	await fade_out(0.5)


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
	
	current_page = "journal"
	
	await page_flip_end()

### Journal Sub-Pages 
func _on_table_of_contents_meta_clicked(meta: Variant) -> void:
	print_debug(meta) # DEBUG PRINT
	
	# Show the clicked one (if it exists)
	if Creatures.has(meta):
		# hide everything and play animation
		await page_flip_start()
		
		show_creature(creature_names.find(meta))
		
		await page_flip_end()
	
	print_debug("Has Not Been Added Yet") # DEBUG PRINT

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


### -------------------- Return Home --------------------
func _on_home_pressed() -> void:
	await page_flip_start() # hide everything & play animations
	
	MainMenu.show() # show main menu page
	ConnectTitle.show() # show main menu title bg
	
	await page_flip_end()


### -------------------- Next Page Button --------------------
func _on_next_pressed() -> void:
	await page_flip_start()
	if current_page == "journal":
		show_creature(current_creature_index + 1)
	
	elif current_page == "h2p":
		# Hide current page
		H2P_pages[current_H2P_index].hide()
		
		current_H2P_index = (current_H2P_index + 1) % H2P_pages.size()
		
		# Show next page
		H2P_pages[current_H2P_index].show()
		
		H2P.show()
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


func fade_in(time = 0.5) -> void:
	SceneChangeAnimationParent.show()
	box.color = Color(0, 0, 0, 0)
	var tween = create_tween()
	tween.tween_property(box, "color:a", 1.0, time)
	await tween.finished

func fade_out(time = 0.5) -> void:
	SceneChangeAnimationParent.show()
	box.color = Color(0, 0, 0, 1)
	var tween = create_tween()
	tween.tween_property(box, "color:a", 0.0, time)
	await tween.finished
	SceneChangeAnimationParent.hide()
