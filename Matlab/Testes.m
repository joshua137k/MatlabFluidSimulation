close all
clear all
clc

N = 32;
Matrix = zeros(N);
Size = 10; % Modifique aqui para o tamanho desejado do quadrado
Angle = 0; % Ângulo de rotação em graus
Position = [16, 16]; % Centro do quadrado

% Define os vértices do quadrado antes da rotação
halfSize = Size / 2;
x = [-halfSize, halfSize, halfSize, -halfSize, -halfSize] + Position(1);
y = [-halfSize, -halfSize, halfSize, halfSize, -halfSize] + Position(2);

% Aplica a rotação
R = [cosd(Angle), -sind(Angle); sind(Angle), cosd(Angle)];
vertices = R * [x - Position(1); y - Position(2)] + repmat(Position', 1, 5);

% Desenha as linhas do quadrado na matriz
for i = 1:4 % Existem 4 lados no quadrado
    % Calcula as coordenadas da linha usando interpolação
    x_line = linspace(vertices(1, i), vertices(1, i + 1), max(N, Size*2));
    y_line = linspace(vertices(2, i), vertices(2, i + 1), max(N, Size*2));
    
    % Arredonda as coordenadas para os índices mais próximos e desenha na matriz
    for j = 1:length(x_line)
        u = round(y_line(j)); % Note a troca aqui para corresponder aos índices da matriz
        v = round(x_line(j));
        if u >= 1 && u <= N && v >= 1 && v <= N
            Matrix(u, v) = 1;
        end
    end
end

% Preenche o quadrado
% Para um preenchimento simples, podemos pintar entre as linhas verticais do quadrado.
for x_fill = min(vertices(1, :)):max(vertices(1, :))
    for y_fill = min(vertices(2, :)):max(vertices(2, :))
        u = round(y_fill);
        v = round(x_fill);
        if u >= 1 && u <= N && v >= 1 && v <= N
            Matrix(u, v) = 1;
        end
    end
end

% Mostra a matriz
imagesc(Matrix);
axis equal;
axis tight;
colormap('gray'); % Use uma paleta de cores em escala de cinza para melhor visualização
