close all
clear all
clc
N=128;

fluid = Fluid(N,1.5, 0, 0);
cube = Square([0.5*N,0.5*N+20],20,5,0);
MatrixCube = 500*cube.draw(N); 
fluid.setBlock(MatrixCube)
maxIterations = 500;
k=0;
for t=0:maxIterations

	cx = floor((0.5 * N))-10;
    cy = floor((0.5 * N));

    for i =-1: 2
        for j = -1:2
            fluid.addDensity(cx + i, cy + j, floor(50+rand*100));
        end
    end
    for i =0:2
        angle = rand * pi * 2;
        v = [cos(angle), sin(angle)] * 0.2;
        k = k + 0.01;
        fluid.addVelocity(cx, cy, v(1), v(2));
    end
    cube.rotate(pi/3);
    MatrixCube = 500*cube.draw(N); 
    fluid.setBlock(MatrixCube)
	fluid.step();
    image = fluid.density+MatrixCube;
    contourf(image);
    colormap(gray);
    drawnow

end