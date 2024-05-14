
%% Read the GIF file
clc
N=64;
gifFilename = 'vid.gif';
numFrames = 3;
gifData = imread(gifFilename, 'Frames', "all");




for i = 1:size(gifData,4)
    a = imresize(gifData(:, :, :, i), [N, N]);
    resizedFrames{i} = double(im2gray(a));
end

%% Start
close all

frame1= resizedFrames{1};
frame2 =resizedFrames{2};

fluid = Fluid(N,0.8, 0, 0.000000000000000001);
fluid.setDens(frame1);






vel = (frame2-frame1)*0.0001;

vx = vel*cos(pi/4);
vy = vel*sin(pi/4);

fluid.setVxVy(vx,vy);

cx = floor((0.5 * N))-10;
cy = floor((0.5 * N));
maxIterations = size(gifData,4);

for t=1:maxIterations
    
    figure(1)
	fluid.step();
    contourf(fluid.density);
    colormap(gray);
    
    figure(2)
    rez = resizedFrames{t};
    contourf(rez)
    colormap(gray);

    drawnow
    
end