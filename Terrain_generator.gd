extends TileMap

# This script uses the "OpenSimplexNoise" object to create a noise image of the same pixel
# size as the tilemap, for this demo, 16x16.
# It then checks the grey value of each pixel, and depending on the range it sits in,
# assigns a value to the corresponding TileMap tile.

var TILE_LIMIT : Vector2
var image_tex : ImageTexture
var image : Image
var texture_rect : TextureRect
var noise : OpenSimplexNoise

const NOISE_IMAGE_ALPHA = 0 # change this to be 0.5 or 1 to make the noise image visible

func _ready():
	# This variable will decide how large your tilemap is, for this demo, it's limited it to 16x16
	TILE_LIMIT = Vector2(16, 16)
	
	noise = OpenSimplexNoise.new()

func get_noise_pixels():
	var pixel_array = []
	
	var tiles = get_used_cells()
	
	for tile in tiles:
		var colour = image.get_pixelv(tile)
		pixel_array.append([tile,colour.gray()])
	
	return pixel_array

func create_noise_texture(noise):
	# creates a new image of grey noisy pixels using the random seed
	image_tex = ImageTexture.new()
	image = noise.get_image(TILE_LIMIT.x,TILE_LIMIT.y) # 16x16
	image_tex.create_from_image(image,0)
	image.lock()

func show_noise_image():
	# Displays the noise image at 16 scale (1:1 with the TileMap) using a TextureRect
	texture_rect = TextureRect.new()
	texture_rect.texture = image_tex
	texture_rect.set_scale(Vector2(16,16))
	texture_rect.modulate.a = NOISE_IMAGE_ALPHA
	texture_rect.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
	if get_child(1):
		get_child(1).free()
	add_child(texture_rect)

func setup_noise(noise):
	# Creates a new seed for the noise
	noise.seed = randi()
	noise.octaves = 4
	noise.period = 15
	noise.persistence = 0.8

func initiate_tilemap():
	# sets all the tiles in 16x16 to the id "0"
	for i in range(TILE_LIMIT.x):
		for j in range(TILE_LIMIT.y):
			set_cell(i,j,0)

func _on_GenerateButton_pressed():
	print("Rotate the board!") # That's TerrainWang!
	
	# sets all tiles in the tilemap to -1 (empty)
	clear()
	
	# (re-)generates a random noise seed
	setup_noise(noise)
	
	# sets TileMap tiles to a default value (Plains)
	initiate_tilemap()
	
	# build the 16x16 noise image using the perlin noise object
	create_noise_texture(noise)
	
	# displays the noise image being used to calculate the tiles
	show_noise_image()
	
	# get an array of 256 pixels by their Vector2 coordinate and grey values
	var pixels = get_noise_pixels()
	
	for grey_pixel in pixels:
		
		var tile : Vector2 = grey_pixel[0]
		var grey_colour : float = grey_pixel[1]
		
		# These statements check the grey value, and set the Tile ID accordingly.
		# varying these values will produce more or less of various tiles
		if grey_colour <= 0.45:
			set_cellv(tile,1) # Sea
		if grey_colour > 0.55 and grey_colour <= 0.65:
			set_cellv(tile,2) # Forest
		if grey_colour > 0.65 and grey_colour <= 1:
			set_cellv(tile,3) # Mountains