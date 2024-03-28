import pygame
import sys
import numpy as np

# Initialize pygame
pygame.init()


cell_size = 32
rows = 10
columns = 10

window_width = columns*cell_size
window_height = rows*cell_size

# Define colors
WHITE = (255, 255, 255)
BLACK = (0, 0, 0)

window = pygame.display.set_mode((window_width, window_height))
pygame.display.set_caption("Water")

def draw_grid():
    for row in range(rows):
        for column in range(columns):
            rect = pygame.Rect(column * cell_size, row * cell_size, cell_size, cell_size)
            pygame.draw.rect(window, BLACK, rect, 1)

def drawBlock(x,y,density):

    y = y*cell_size
    if density>1:
        color=(0,0,0)
    elif density>0:
        color = 255 - int(clamp(255*density,150))
        color = (0,0,color)
        
    elif density<0:
        color=(0,255,0)

    pygame.draw.rect(window, color, (x*cell_size,y, cell_size,cell_size))

def clamp(value,Vmax):
    return max(0, min(value, Vmax))


def drawSeta(x, y, dir):
    arrow_size = cell_size // 3  
    color = (255,200,0)
    if dir == "u":
        pygame.draw.polygon(window, color, [(x * cell_size + cell_size // 2, y * cell_size),
                                             (x * cell_size + cell_size - arrow_size, y * cell_size + arrow_size),
                                             (x * cell_size + arrow_size, y * cell_size + arrow_size)])
    elif dir == "d":
        pygame.draw.polygon(window, color, [(x * cell_size + arrow_size, y * cell_size),
                                             (x * cell_size + cell_size - arrow_size, y * cell_size),
                                             (x * cell_size + cell_size // 2, y * cell_size + cell_size - arrow_size)])
    elif dir == "l":
        pygame.draw.polygon(window, color, [(x * cell_size + cell_size - arrow_size, y * cell_size + cell_size // 2),
                                             (x * cell_size + arrow_size, y * cell_size),
                                             (x * cell_size + arrow_size, y * cell_size + cell_size)])
    elif dir == "r":
        pygame.draw.polygon(window, color, [(x * cell_size + cell_size - arrow_size, y * cell_size),
                                             (x * cell_size + cell_size - arrow_size, y * cell_size + cell_size),
                                             (x * cell_size + arrow_size, y * cell_size + cell_size // 2)])





def draw(grid,grid_direction):
    draw_grid()
    for y in range(grid.shape[0]):
        for x in range(grid.shape[1]):
            if grid[y,x]!=0:
                drawBlock(x,y,grid[y,x])
                drawSeta(x,y,grid_direction[y,x])
                



def update(grid,grid_direction):
    div = 0.5

    for y in range(grid.shape[0], -1, -1):
        for x in range(grid.shape[1]):
            if y < grid.shape[0] - 1 and grid[y, x] > 0 and grid[y+1, x] < 1 and grid[y+1, x] != -1:
                if grid[y, x] == grid[y+1, x]:
                    value = grid[y, x]
                else:
                    value = min(grid[y, x] - grid[y+1, x], div)
                grid[y+1, x] += value
                grid[y, x] -= value
                grid_direction[y+1,x]="d"




    for y in range(grid.shape[0]):
        for x in range(grid.shape[1]-1):
            a = np.random.uniform(-1, 1)
            a = int(a/abs(a))
            if (grid[y, x+a] < 1 and grid[y, x+a] >= 0 and grid[y, x] > 0 
                and ((y < grid.shape[0]-1 and grid[y+1, x] !=0) or y == grid.shape[0]-1) 
                and grid[y, x+a] != -1):
                value = min((grid[y, x] - grid[y, x+a]), div)
                grid[y, x+a] += value
                grid[y, x] -= value
                if a>0:
                    grid_direction[y,x+a]="r"
                else:
                    grid_direction[y,x+a]="l"
            elif (grid[y, x+a] >= 0 and grid[y, x] > 1 
                and ((y < grid.shape[0]-1 and grid[y+1, x] !=0) or y == grid.shape[0]-1) 
                and grid[y, x+a] != -1):
                value = min((grid[y, x] - grid[y, x+a]), div)
                grid[y, x+a] += value
                grid[y, x] -= value
                if a>0:
                    grid_direction[y,x+a]="r"
                else:
                    grid_direction[y,x+a]="l"


    for y in range(grid.shape[0]):
        for x in range(grid.shape[1]):
            if grid[y,x]<=0:
                grid_direction[y,x]=""

    for y in range(grid.shape[0]-1):
        for x in range(grid.shape[1]-1):

            if ((grid[y+1, x-1] >= 0 or grid[y+1,x-1]<0) and (grid[y+1, x+1] >= 0 or grid[y+1,x+1]<0) and grid[y+1, x] > 1) and grid[y,x]>=0:
                value = min((grid[y, x] - grid[y+1, x]), div)
                grid[y+1, x] += value
                grid[y, x] -= value
                grid_direction[y+1,x]="u"

def set_cell_value(grid, x, y, value):
    grid[y // cell_size, x // cell_size] = value


def handle_mouse_events(grid,mouseR,mouseL,mouse_x,mouse_y):
   

    if mouseL:  # Botão esquerdo do mouse pressionado
        set_cell_value(grid, mouse_x, mouse_y, grid[mouse_y // cell_size, mouse_x // cell_size] + 1)
    if mouseR:  # Botão direito do mouse pressionado
        set_cell_value(grid, mouse_x, mouse_y, -1)

grid = np.zeros((rows, columns))
grid_direction = np.empty((rows, columns), dtype='U2')
grid_direction.fill('') 

clock = pygame.time.Clock()


mouseR= False
mouseL = False



while True:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            pygame.quit()
            sys.exit()
        elif event.type == pygame.MOUSEBUTTONDOWN:
            if event.button == 1:  # Left mouse button
                mouseL = True
            elif event.button == 3:  # Right mouse button
                mouseR = True
        elif event.type == pygame.MOUSEBUTTONUP:
            if event.button == 1:  # Left mouse button
                mouseL = False
            elif event.button == 3:  # Right mouse button
                mouseR = False
            
    mouse_x, mouse_y = pygame.mouse.get_pos()
    handle_mouse_events(grid,mouseR,mouseL,mouse_x,mouse_y)
    print(grid)
    window.fill(WHITE)
    draw(grid,grid_direction)
    update(grid,grid_direction)
    clock.tick(10)
    pygame.display.update()