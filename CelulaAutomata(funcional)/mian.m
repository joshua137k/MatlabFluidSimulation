close all;
clear all;
clc

rows = 32;
columns = 32;

grid = zeros(rows, columns);
grid_direction = cell(rows, columns);
grid(31,2)=100;
thresholds = linspace(0,1,10);
A= size(thresholds);

numTones = A(2);
COLOR_SCALE = uint8([zeros(numTones, 2), linspace(255, 160, numTones)']);
COLOR_SCALE(1, :) = [255, 255, 255];
COLOR_SCALE = reshape(COLOR_SCALE, [numTones, 1, 3]);
coloredImage = uint8(zeros(rows, columns, 3));

for i=1:5
    grid(32,i)=-1;
end
for i=1:5
    grid(32-i,1)=-1;
end
for i=1:5
    grid(32-i,5)=-1;
end

for y = 1:rows
    for x = 1:columns
        grid_direction{y, x} = [0, 0]; % Sem direção inicial
    end
end


% set(gcf, 'WindowButtonDownFcn', @(src, event)mouseClickCallback(src, event));
% setappdata(gcf,"MouseClicado", false);
time = 1;
timeStart=false;

for i=0:1000
    % MouseClicado = getappdata(gcf, 'MouseClicado');
    % 
    % 
    % if MouseClicado==1
    %     mousePos = get(gca,"CurrentPoint");
    %     MouseX = mousePos(1,1);
    %     MouseY = mousePos(1,2);
    %     grid(floor(MouseY),floor(MouseX))=grid(floor(MouseY),floor(MouseX))+1;
    %     timeStart=true;
    % end
    % 
    % if time<=0
    %     setappdata(gcf,"MouseClicado", false);
    %     time=1;
    %     timeStart=false;
    % end
    % 
    % if timeStart==true
    %     time=time-0.2;
    % end
    % 
    hold off;
    [grid,grid_direction]=update(grid,grid_direction);

    for i = 1:rows
        for j = 1:columns
            color = shade_of_white(grid(i, j), COLOR_SCALE,thresholds);
            coloredImage(i, j, :) = color;
        end
    end
        
    imagesc(coloredImage);
    hold on
    U = zeros(size(grid)); % Componente vertical das setas
    V = zeros(size(grid)); % Componente horizontal das setas
    for y = 1:rows
        for x = 1:columns
            U(y, x) = grid_direction{y, x}(1);
            V(y, x) = grid_direction{y, x}(2);
        end
    end
    quiver(1:columns, 1:rows, V, U, 'AutoScale', 'off');
    drawnow;
end

function mouseClickCallback(src, event)
    setappdata( gcf,"MouseClicado", true);
    disp("click")

end


function color = shade_of_white(value, GRAY_SCALE,thresholds)
    
    color = GRAY_SCALE(end, :);
    for i = 1:length(thresholds)
        if value ==0
            color=[255,255,255];
        elseif value ==-1
            color = [0,255,0];
        elseif value >1
            color = [0,0,0];
        elseif value < thresholds(i)
            color = GRAY_SCALE(i, :);
            break;
        end
    end
end

function [grid, grid_direction] = update(grid, grid_direction)
    div = 0.25;
    [rows, cols] = size(grid);
    
    %Limpeza
    for y = 1:rows
        for x = 1:cols
            if grid(y, x) <= 0
                grid_direction{y, x} = [0,0];
            end
        end
    end

    %Gravidade
    for y = rows:-1:1
        for x = 1:cols
            if y < rows && grid(y, x) > 0 && grid(y+1, x) < 1 && grid(y+1, x) ~= -1
                if grid(y, x) == grid(y+1, x)
                    value = grid(y, x);
                else
                    value = min(grid(y, x) - grid(y+1, x), div);
                end
                grid(y+1, x) = grid(y+1, x) + value;
                grid(y, x) = grid(y, x) - value;
                grid_direction{y+1, x} = [1, 0]; % Para baixo
            end
        end
    end
    
    %Divisao esq/dir
    for y = 1:rows
        for x = 1:cols-1

            a = randi([-1, 1]);
            if x==1
                a=1;
            end
            if grid(y, x+a) < 1 && grid(y, x+a) >= 0 && grid(y, x) > 0 && ((y < rows && grid(y+1, x) ~= 0) || y == rows) && grid(y, x+a) ~= -1
                value = min((grid(y, x) - grid(y, x+a)), div);
                grid(y, x+a) = grid(y, x+a) + value;
                grid(y, x) = grid(y, x) - value;
                if a > 0
                    grid_direction{y, x} = [0, 1]; % Para direita

                else
                    grid_direction{y, x} = [0, -1]; % Para esquerda

                end
            elseif grid(y, x+a) >= 0 && grid(y, x) > 1 && ((y < rows && grid(y+1, x) ~= 0) || y == rows) && grid(y, x+a) ~= -1
                value = min((grid(y, x) - grid(y, x+a)), div);
                grid(y, x+a) = grid(y, x+a) + value;
                grid(y, x) = grid(y, x) - value;
                if a > 0
                    grid_direction{y, x} = [0, 1]; % Para direita
                else
                    grid_direction{y, x} = [0, -1]; % Para esquerda
                end
            end
        end
    end

    %Pressao
    for y = 1:rows-1
        for x = 2:cols-1
            if (grid(y+1, x-1) >= 0 || grid(y+1, x-1) < 0) && (grid(y+1, x+1) >= 0 || grid(y+1, x+1) < 0) && grid(y+1, x) > 1 && grid(y, x) >= 0
                value = min((grid(y, x) - grid(y+1, x)), div);
                grid(y+1, x) = grid(y+1, x) + value;
                grid(y, x) = grid(y, x) - value;
                grid_direction{y+1, x} = [-1, 0]; % Para cima;
            end
        end
    end



end
