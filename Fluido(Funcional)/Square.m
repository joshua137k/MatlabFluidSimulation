classdef Square < handle
    properties
        Position
        SizeX
        SizeY
        Angle
    end
    
    methods
        function obj = Square(pos, sizeX,sizeY, angle)
            if nargin > 0
                obj.Position = pos;
                obj.SizeX = sizeX;
                obj.SizeY= sizeY;
                obj.Angle = angle;
            else
                obj.Position = [0, 0];
                obj.SizeX = 1;
                obj.SizeY = 1;% Tamanho padrão
                obj.Angle = 0;         % Ângulo padrão
            end
        end
        
        function obj = scale(obj, factorX,factorY)
            % Escala o tamanho do quadrado por um fator
            obj.SizeX = obj.SizeX * factorX;
            obj.SizeY = obj.SizeY * factorY;
        end
        
        function obj = rotate(obj, dAngle)
            % Rotaciona o quadrado por um ângulo em graus
            obj.Angle = mod(obj.Angle + dAngle, 360);
        end
        
        function obj = translate(obj, dPos)
            % Move o quadrado para uma nova posição
            obj.Position = obj.Position + dPos;
        end
        
        function RotatedMatrix = draw(obj, N)
            % Cria um quadrado preenchido antes da rotação
            SizeX = obj.SizeX;
            SizeY = obj.SizeY;
            Position = obj.Position;
            Angle = obj.Angle;


            halfSizeX = SizeX / 2;
            halfSizeY = SizeY / 2;
            Matrix = zeros(N);
            [x_grid, y_grid] = meshgrid(1:N, 1:N); % Cria uma grade para a matriz
            % Calcula uma matriz lógica para um quadrado não rotacionado
            square_mask = abs(x_grid - Position(1)) <= halfSizeX & abs(y_grid - Position(2)) <= halfSizeY;
            Matrix(square_mask) = 1; % Aplica a máscara ao quadrado
            
            % Rotaciona a matriz inteira (isso inclui o quadrado preenchido)
            [X, Y] = meshgrid(1:N);
            X_centered = X - Position(1);
            Y_centered = Y - Position(2);
            R = [cosd(Angle), -sind(Angle); sind(Angle), cosd(Angle)]; % Matriz de rotação
            rot_coords = R * [X_centered(:)'; Y_centered(:)'];
            rotated_X = reshape(rot_coords(1, :) + Position(1), N, N);
            rotated_Y = reshape(rot_coords(2, :) + Position(2), N, N);
            RotatedMatrix = interp2(x_grid, y_grid, Matrix, rotated_X, rotated_Y, 'nearest', 0);

        end

    end
end
