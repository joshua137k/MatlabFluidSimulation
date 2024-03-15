classdef Square < handle
    properties
        Position
        Size
        Angle
    end
    
    methods
        function obj = Square(pos, size, angle)
            if nargin > 0
                obj.Position = pos;
                obj.Size = size;
                obj.Angle = angle;
            else
                obj.Position = [0, 0];
                obj.Size = 1;          % Tamanho padrão
                obj.Angle = 0;         % Ângulo padrão
            end
        end
        
        function obj = scale(obj, factor)
            % Escala o tamanho do quadrado por um fator
            obj.Size = obj.Size * factor;
        end
        
        function obj = rotate(obj, dAngle)
            % Rotaciona o quadrado por um ângulo em graus
            obj.Angle = mod(obj.Angle + dAngle, 360);
        end
        
        function obj = translate(obj, dPos)
            % Move o quadrado para uma nova posição
            obj.Position = obj.Position + dPos;
        end
        
        function matrix = draw(obj, N)
            % Cria uma matriz de zeros do tamanho especificado
            matrix = zeros(N);
            
            % Determina os vértices do quadrado dentro da matriz
            % Aqui assumimos que o quadrado não está rotacionado para simplificar
            halfSize = round(obj.Size / 2); % Meio tamanho do quadrado para cálculos
            centerX = round(obj.Position(1)); % Centro x do quadrado
            centerY = round(obj.Position(2)); % Centro y do quadrado
            
            % Calcula as coordenadas dos vértices do quadrado na matriz
            left = max(centerX - halfSize, 1);
            right = min(centerX + halfSize, N);
            top = max(centerY - halfSize, 1);
            bottom = min(centerY + halfSize, N);
            
            % Marca os pixels dentro do quadrado
            for x = left:right
                for y = top:bottom
                    if x > 0 && x <= N && y > 0 && y <= N
                        matrix(y, x) = 1; % Nota: em matrizes, a primeira coordenada é 'y' e a segunda é 'x'
                    end
                end
            end
        end

    end
end
