
close all
N = 32; % Tamanho da matriz
n = 15; % Tamanho do quadrado

% Criar a matriz NxN com zeros
matriz = zeros(N);

% Preencher as bordas da matriz com -1
matriz(1, :) = -1;
matriz(end, :) = -1;
matriz(:, 1) = -1;
matriz(:, end) = -1;

startRow = floor((N - n) / 2) +3;
endRow = startRow + n +5;
startCol = floor((N - n) / 2) + 1;
endCol = startCol + n - 1;

matriz(endRow, startCol:endCol) = -1;   % Borda inferior
matriz(startRow:endRow, startCol) = -1; % Borda esquerda
matriz(startRow:endRow, endCol) = -1;   % Borda direita


matriz(3,2:9)=-1;
matriz(4,2)=10;
matriz(5,2:9)=-1;


% Exibir a matriz
imshow(matriz, []);
title('Matriz com Quadrado Central');


