close all
clear all
clc
N = 64;
x = N / 2;
y = N / 2;
L = LiquidCube(N, 0.5,0.001, 0);


C = Square([x+5, y+8], 15,2, 0);
thresholds = 10.^(-(5:-1:0));
A= size(thresholds);

numTones = A(2);
COLOR_SCALE = uint8([zeros(numTones, 2), linspace(255, 160, numTones)']);
COLOR_SCALE(1, :) = [255, 255, 255];
COLOR_SCALE = reshape(COLOR_SCALE, [numTones, 1, 3]);

coloredImage = uint8(zeros(N, N, 3));

vx = 1;
vy = 1;
t = 0;




filename = 'simulation.gif'; 
delayTime = 0.1; 

maxIterations = 500;




for t=0:maxIterations
    C.rotate(10*pi);
    R = C.draw(N);
    L.modifyBlock(R);
    L.step();


    L.addDensity(x,y, 3);
    L.addVelocity(x,y,sin(t),cos(t)*3);
    
    
        
    for i = 1:N - 1
        for j = 1:N - 1
            color = shade_of_white(L.density(i, j), COLOR_SCALE,thresholds);
            coloredImage(i, j, :) = color;
        end
    end
    
    coloredImage(:,:,1) = L.blockMatrix * 255;
    imagesc(coloredImage);
    drawnow
    [imind,cm] = rgb2ind(coloredImage,256); 
    
    if t == 0
        imwrite(imind,cm,filename,'gif', 'Loopcount',inf, 'DelayTime',delayTime);
    else
        imwrite(imind,cm,filename,'gif','WriteMode','append', 'DelayTime',delayTime);
    end
end





function color = shade_of_white(value, GRAY_SCALE,thresholds)
    
    color = GRAY_SCALE(end, :);
    for i = 1:length(thresholds)
        if value < thresholds(i)
            color = GRAY_SCALE(i, :);
            break;
        end
    end
end