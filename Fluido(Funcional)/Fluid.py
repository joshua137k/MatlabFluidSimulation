import numpy as np
import pygame


N = 56
iter = 8

class Fluid:
    def __init__(self, N,scale ,dt, diffusion, viscosity):
        self.size = N
        self.TileScale=scale
        self.dt = dt
        self.diffusion = diffusion
        self.viscosity = viscosity
        
        self.s = np.zeros( (self.size,self.size))
        self.density = np.zeros((self.size,self.size))
        
        self.Vx = np.zeros((self.size,self.size))
        self.Vy = np.zeros((self.size,self.size))
        self.Vx0 = np.zeros((self.size,self.size))
        self.Vy0 = np.zeros((self.size,self.size))
        
    def addDensity(self, x, y, amount):
        self.density[x, y] += amount
        
    def addVelocity(self, x, y, amountX, amountY):
        self.Vx[x, y] += amountX
        self.Vy[x, y] += amountY
        
    def step(self):
        N = self.size;
        visc = self.viscosity;
        diff = self.diffusion;
        dt = self.dt;
        Vx = self.Vx;
        Vy = self.Vy;
        Vx0 = self.Vx0;
        Vy0 = self.Vy0;
        s = self.s;
        density = self.density;

        diffuse(1, Vx0, Vx, visc, dt);
        diffuse(2, Vy0, Vy, visc, dt);

        project(Vx0, Vy0, Vx, Vy);

        advect(1, Vx, Vx0, Vx0, Vy0, dt);
        advect(2, Vy, Vy0, Vx0, Vy0, dt);

        project(Vx, Vy, Vx0, Vy0);
        diffuse(0, s, density, diff, dt);
        advect(0, density, s, Vx, Vy, dt);
  
        
    def renderD(self,screen):
        for i in range(self.size):
            for j in range(self.size):
                intensity = np.clip(self.density[i, j], 0, 255)
                pygame.draw.rect(screen, (intensity, intensity, intensity), (i * self.TileScale, j * self.TileScale, self.TileScale, self.TileScale))





def diffuse(b, x, x0, diff, dt):
    a = dt * diff * (N - 2) * (N - 2)
    lin_solve(b, x, x0, a, 1 + 6 * a)

def lin_solve(b, x, x0, a, c):
    cRecip = 1.0 / c
    for t in range(iter):
        for j in range(1, N - 1):
            for i in range(1, N - 1):
                x[i, j] = (x0[i, j] + a * (x[i + 1, j] + x[i - 1, j] +
                                                   x[i, j + 1] + x[i, j - 1])) * cRecip
        set_bnd(b, x)

def project(velocX, velocY, p, div):
    for j in range(1, N - 1):
        for i in range(1, N - 1):
            div[i, j] = (-0.5 * (velocX[i + 1, j] - velocX[i - 1, j] +
                                     velocY[i, j + 1] - velocY[i, j - 1])) / N
            p[i, j] = 0

    set_bnd(0, div)
    set_bnd(0, p)
    lin_solve(0, p, div, 1, 6)

    for j in range(1, N - 1):
        for i in range(1, N - 1):
            velocX[i, j] -= 0.5 * (p[i + 1, j] - p[i - 1, j]) * N
            velocY[i, j] -= 0.5 * (p[i, j + 1] - p[i, j - 1]) * N

    set_bnd(1, velocX)
    set_bnd(2, velocY)

def advect(b, d, d0, velocX, velocY, dt):
    dtx = dt * (N - 2)
    dty = dt * (N - 2)

    for j in range(1, N - 1):
        for i in range(1, N - 1):
            tmp1 = dtx * velocX[i, j]
            tmp2 = dty * velocY[i, j]
            x = i - tmp1
            y = j - tmp2

            if x < 0.5: x = 0.5
            if x > N - 2 + 0.5: x = N - 2 + 0.5
            i0 = int(x)
            i1 = i0 + 1
            if y < 0.5: y = 0.5
            if y > N - 2 + 0.5: y = N - 2 + 0.5
            j0 = int(y)
            j1 = j0 + 1

            s1 = x - i0
            s0 = 1 - s1
            t1 = y - j0
            t0 = 1 - t1

            d[i, j] = s0 * (t0 * d0[i0, j0] + t1 * d0[i0, j1]) + \
                          s1 * (t0 * d0[i1, j0] + t1 * d0[i1, j1])

    set_bnd(b, d)
    

def set_bnd(b, x):
    for i in range(1, N - 1):
        x[i, 0] = -x[i, 1] if b == 2 else x[i, 1]
        x[i, N - 1] = -x[i, N - 2] if b == 2 else x[i, N - 2]
    for j in range(1, N - 1):
        x[0, j] = -x[1, j] if b == 1 else x[1, j]
        x[N - 1, j] = -x[N - 2, j] if b == 1 else x[N - 2, j]

    x[0, 0] = 0.5 * (x[1, 0] + x[0, 1])
    x[0, N - 1] = 0.5 * (x[1, N - 1] + x[0, N - 2])
    x[N - 1, 0] = 0.5 * (x[N - 2, 0] + x[N - 1, 1])
    x[N - 1, N - 1] = 0.5 * (x[N - 2, N - 1] + x[N - 1, N - 2])
