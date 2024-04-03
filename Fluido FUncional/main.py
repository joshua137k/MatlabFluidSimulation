import pygame
import numpy as np
import random
from pygame.locals import *
from Fluid import Fluid,N

# Pygame setup
pygame.init()
SCALE = 12
WIDTH, HEIGHT = N*SCALE, N*SCALE
screen = pygame.display.set_mode((WIDTH, HEIGHT))
clock = pygame.time.Clock()
t = 0

# Simulation setup
fluid = Fluid(N,SCALE,10, 0, 0)


def DrawCircle(t):
    cx = int((0.5 * N))
    cy = int((0.5 * N))

    for i in range(-1, 2):
        for j in range(-1, 2):
            fluid.addDensity(cx + i, cy + j, random.randint(50, 150))
            
    for i in range(2):
        angle = np.random.rand() * np.pi * 2
        v = np.array([np.cos(angle), np.sin(angle)]) * 0.2
        t += 0.01
        fluid.addVelocity(cx, cy, v[0], v[1])
    return t
        



# Main loop
running = True
while running:
    for event in pygame.event.get():
        if event.type == QUIT:
            running = False
            
    screen.fill((55, 55, 55))
    print(t)
    if t <2:
        t = DrawCircle(t)

    fluid.step()
    fluid.renderD(screen)

    pygame.display.flip()
    clock.tick(22)

pygame.quit()
