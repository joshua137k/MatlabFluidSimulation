import numpy as np
import pygame
import sys
from fluid import *

# Defina as dimensões da tela
CELL_SIZE = 14
WIDTH = N*CELL_SIZE
HEIGHT = N*CELL_SIZE

# Defina o tamanho do tabuleiro


cube = FluidCube(3, 3.14, 0)

WHITE = (255, 255, 255)
BLACK = (0, 0, 0)
GRAY_SCALE = [
	(0,0,i*10) for i in range(0,20)
]




def shade_of_white(value):
	thresholds = [10**(-i) for i in range(15,0,-1)]

	for i, threshold in enumerate(thresholds):
		if value < threshold:

			return GRAY_SCALE[i]
	return GRAY_SCALE[len(GRAY_SCALE)-1]

def constrain(value, min_val, max_val):
    return min(max(value, min_val), max_val)

def draw_board(screen):
	for row in range(N):
		for col in range(N):
			d = cube.density[row, col]
			h = d-(1e-3)
			cube.density[row, col] = constrain(h,0,1)
			color = shade_of_white(d)
			pygame.draw.rect(screen, color, (col * CELL_SIZE, row * CELL_SIZE, CELL_SIZE, CELL_SIZE))

	#cube.fadeD()

def main():
	pygame.init()
	screen = pygame.display.set_mode((WIDTH, HEIGHT))
	pygame.display.set_caption("Fluid Simulation")

	clock = pygame.time.Clock()

	running = True
	click=False
	while running:
		pos = pygame.mouse.get_pos()
		x = np.floor(pos[0] / CELL_SIZE)
		y = np.floor(pos[1] / CELL_SIZE)
		for event in pygame.event.get():
			if event.type == pygame.QUIT:
				running = False
			elif event.type == pygame.MOUSEBUTTONDOWN:
				if event.button == 1:
					click=True
			elif event.type == pygame.MOUSEBUTTONUP:
				if event.button == 1:
					click=False
		if click:
			x = int(x)
			y = int(y)
			cube.FluidCubeAddDensity(y, x, 1)
			x_prev = x-(x + -2)
			y_prev = y-(y + -2)
			cube.FluidCubeAddVelocity(y, x, x_prev*10 ,y_prev*10 )

		screen.fill((0, 0, 0))
		draw_board(screen)

		pygame.display.flip()
		cube.FluidCubeStep()

	pygame.quit()
	sys.exit()

if __name__ == "__main__":
	main()
