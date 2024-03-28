import numpy as np

N = 60
iter = 4


class FluidCube:
	def __init__(self, dt, diff, visc):
		self.size = N
		self.dt = dt
		self.diff = diff
		self.visc = visc

		self.s = np.zeros((N, N))
		self.density = np.zeros((N, N))
		self.Vx = np.zeros((N, N))
		self.Vy = np.zeros((N, N))
		self.Vx0 = np.zeros((N, N))
		self.Vy0 = np.zeros((N, N))


	def FluidCubeAddDensity(self, x, y, amount):
		self.density[x, y] += amount

	def FluidCubeAddVelocity(self, x, y, amountX, amountY):
		self.Vx[x, y] += amountX
		self.Vy[x, y] += amountY

	def FluidCubeStep(self):
		self.diffuse(1, self.Vx0, self.Vx, self.visc, self.dt);
		self.diffuse(2, self.Vy0, self.Vy, self.visc, self.dt);
		self.project(self.Vx0, self.Vy0, self.Vx, self.Vy);
		self.advect(1, self.Vx, self.Vx0, self.Vx0, self.Vy0, self.dt);
		self.advect(2, self.Vy, self.Vy0, self.Vx0, self.Vy0, self.dt);
		self.project(self.Vx, self.Vy, self.Vx0, self.Vy0);
		self.diffuse(0, self.s, self.density, self.diff, self.dt)
		self.advect(0, self.density, self.s, self.Vx, self.Vy, self.dt)


	def set_bnd(self, b, x):
		x[0, :] = -x[1, :] if b == 1 else x[1, :]
		x[-1, :] = -x[-2, :] if b == 1 else x[-2, :]
		x[:, 0] = -x[:, 1] if b == 2 else x[:, 1]
		x[:, -1] = -x[:, -2] if b == 2 else x[:, -2]

		x[0, 0] = 0.33 * (x[1, 0] + x[0, 1] + x[0, 0])
		x[0, -1] = 0.33 * (x[1, -1] + x[0, -2] + x[0, -1])
		x[-1, 0] = 0.33 * (x[-2, 0] + x[-1, 1] + x[-1, 0])
		x[-1, -1] = 0.33 * (x[-2, -1] + x[-1, -2] + x[-1, -1])

	def lin_solve(self, b, x, x0, a, c):
		cRecip = 1.0 / c
		for k in range(iter):
			x[1:-1, 1:-1] = (x0[1:-1, 1:-1] + a * (x[:-2, 1:-1] + x[2:, 1:-1] + x[1:-1, :-2] + x[1:-1, 2:])) * cRecip
			self.set_bnd(b, x)

	def diffuse(self, b, x, x0, diff, dt):
		a = dt * diff * (N**2)
		self.lin_solve(b, x, x0, a, 1 + 6 * a)

	def project(self, velocX, velocY, p, div):
		div[1:-1, 1:-1] = -0.5 * ((velocX[2:, 1:-1] - velocX[:-2, 1:-1]) + (velocY[1:-1, 2:] - velocY[1:-1, :-2]))/(N-2)
		p[:] = 0
		self.set_bnd(0, div)
		self.set_bnd(0, p)
		self.lin_solve(0, p, div, 1, 6)

		velocX[1:-1, 1:-1] -= 0.5 * (p[2:, 1:-1] - p[:-2, 1:-1]) * N
		velocY[1:-1, 1:-1] -= 0.5 * (p[1:-1, 2:] - p[1:-1, :-2]) * N
		self.set_bnd(1, velocX)
		self.set_bnd(2, velocY)

	def advect(self, b, d, d0, velocX, velocY, dt):
		dtx = dt * (N - 2)
		dty = dt * (N - 2)

		Nfloat = N
		for j in range(1, N - 1):
			for i in range(1, N - 1):
				tmp1 = dtx * velocX[i, j]
				tmp2 = dty * velocY[i, j]
				x = i - tmp1
				y = j - tmp2

				x = np.maximum(0.5, np.minimum(x, Nfloat + 0.5))
				y = np.maximum(0.5, np.minimum(y, Nfloat + 0.5))
				i0 = int(x)
				i1 = i0 + 1
				j0 = int(y)
				j1 = j0 + 1

				s1 = x - i0
				s0 = 1.0 - s1
				t1 = y - j0
				t0 = 1.0 - t1
				try:
					d[i, j] = (s0 * (t0 * d0[i0, j0] + t1 * d0[i0, j1]) +
							   s1 * (t0 * d0[i1, j0] + t1 * d0[i1, j1]))
				except:
					pass

		self.set_bnd(b, d)


