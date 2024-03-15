close all
clear all
clc
N=128;
L = LiquidCube(N,0.4,0.1,0);
x =N/2;
y=N/2;

numTones = 25;
COLOR_SCALE = uint8([zeros(numTones, 2), linspace(255, 100, numTones)']);
COLOR_SCALE(1, :) = [255, 255, 255];
COLOR_SCALE = reshape(COLOR_SCALE, [numTones, 1, 3]);


coloredImage = uint8(zeros(N-1, N-1, 3));

vx=1;
vy=1;
t = 0;
fig = figure;
while(true)
    hold on
    L.step();
    t=t+0.1;
    L.addDensity(x,y,0.5);
    L.addVelocity(x,y,cos(t)*10,sin(t)*10);

    
    for i = 1:N-1
        for j = 1: N-1
            color = shade_of_white(L.density(i, j),COLOR_SCALE);
            coloredImage(i, j, :) = color;
        end
    end
    
    imagesc(coloredImage);
    
    drawnow;

end






function color = shade_of_white(value,GRAY_SCALE)
    thresholds = 10.^(-(25:-1:1));
    color = GRAY_SCALE(end, :);
    for i = 1:length(thresholds)
        if value < thresholds(i)
            color = GRAY_SCALE(i, :);
            break;
        end
    end
end


