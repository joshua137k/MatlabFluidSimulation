import pygame
import numpy as np

# Inicialização do Pygame
pygame.init()
size = 128
N = 5
width, height = size * N, size * N
screen = pygame.display.set_mode((width, height))
clock = pygame.time.Clock()

dt = 10
diff = 0.001
scale = width // size
v_x = np.zeros((size, size))
v_y = np.zeros((size, size))
Ink = np.zeros((size, size))
obj = np.zeros((size, size))


def difuse(grid, dt, diff):
    size = grid.shape[0]
    a = dt * diff * (size-2)**2
    c = 1 / (1 + 4*a)
    for k in range(20):
        for x in range(1, size - 1):
            for y in range(1, size - 1):
                    grid[x, y] = (grid[x, y] + a * (grid[x-1, y] + grid[x+1, y] + grid[x, y-1] + grid[x, y+1]))  * c
        return set_bnd(grid,size)


def draw_grid(t,screen, grid, scale):
    for y in range(grid.shape[0]):
        for x in range(grid.shape[1]):
            if t==0:
                value = max(0, min(grid[y, x], 255))
                color = (value, value, value)
                pygame.draw.rect(screen, color, (x * scale, y * scale, scale, scale))
            else:
                if grid[y, x]!=0:
                    pygame.draw.rect(screen, (255,0,0), (x * scale, y * scale, scale, scale))


def create_spiral_velocity_field(size):
    v_x = np.zeros((size, size))
    v_y = np.zeros((size, size))

    center_x = size // 2
    center_y = size // 2

    for y in range(size):
        for x in range(size):
            dx = x - center_x
            dy = y - center_y

            # Distância do ponto ao centro
            distance = np.sqrt(dx ** 2 + dy ** 2)

            angular_velocity = 0.001

            v_x[y, x] = -angular_velocity * dy
            v_y[y, x] = angular_velocity * dx

    return v_x, v_y


def set_bnd(grid, size):
    for i in range(size):
        for j in range(size):
            if obj[i,j]!=0:
                grid[i,j]=0

    grid[:, 0] = grid[:, 1]  # Left boundary
    grid[:, -1] = grid[:, -2]  # Right boundary
    grid[0, :] = grid[1, :]  # Top boundary
    grid[-1, :] = grid[-2, :]  # Bottom boundary

    return grid


def advect(grid, v_x, v_y, dt):
    size = grid.shape[0]
    new_grid = np.zeros_like(grid)
    for x in range(size):
        for y in range(size):
            x0 = x - dt * v_x[x, y]
            y0 = y - dt * v_y[x, y]

            x0 = max(0, min(size - 1, x0))
            y0 = max(0, min(size - 1, y0))

            i0 = int(x0)
            i1 = i0 + 1
            j0 = int(y0)
            j1 = j0 + 1

            s1 = x0 - i0
            s0 = 1 - s1
            t1 = y0 - j0
            t0 = 1 - t1

            i0 = min(size - 1, max(0, i0))
            i1 = min(size - 1, max(0, i1))
            j0 = min(size - 1, max(0, j0))
            j1 = min(size - 1, max(0, j1))
            new_grid[x, y] = s0 * (t0 * grid[i0, j0] + t1 * grid[i0, j1]) + \
                             s1 * (t0 * grid[i1, j0] + t1 * grid[i1, j1])
    set_bnd(new_grid,size)

    return new_grid  


# Loop principal
running = True

Ink[0,0]=-1
    
a = size//2

for i in range(1,size-1):
    for j in range(1,size-1):
        Ink[i, j] = np.random.uniform(1,255)
        v_y[i, j] = np.random.uniform(-1,1)
        v_x[i, j] = np.random.uniform(-1,1)


t=0
while running:
    screen.fill((0, 0, 0))
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False



    v_x=difuse(v_x,dt,diff)
    v_y=difuse(v_y,dt,diff)


    Ink = advect(Ink,v_x,v_y,size)

    draw_grid(0,screen, Ink, scale)
    draw_grid(1,screen, obj, scale)
    
    pygame.display.flip()
    clock.tick(10)

pygame.quit()
