classdef LiquidCube < handle
    %LIQUIDCUBE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        size = 0;
        dt = 0;
        diff = 0;
        visc = 0;
        s = [];
        density = [];
        Vx = [];
        Vy = [];
        Vx0 = [];
        Vy0 = [];
        blockMatrix = [];
    end
    
    methods
        function obj = LiquidCube(N,dt,diff,visc)
            obj.size = N;
            obj.dt = dt;
            obj.diff = diff;
            obj.visc = visc;
            obj.s = zeros(N);
            obj.density = zeros(N);
            obj.Vx = zeros(N);
            obj.Vy = zeros(N);
            obj.Vx0 = zeros(N);
            obj.Vy0 = zeros(N);
            obj.blockMatrix = zeros(N);
            obj.blockMatrix(1, :) = 1;
            obj.blockMatrix(N, :) = 1;
            obj.blockMatrix(:, 1) = 1;
            obj.blockMatrix(:, N) = 1;
        end

        function step(obj)
            obj.Vx0 = obj.diffuse(1,obj.Vx0,obj.Vx,obj.visc,obj.dt);
            obj.Vy0 = obj.diffuse(1,obj.Vy0,obj.Vy,obj.visc,obj.dt);
            [obj.Vx0,obj.Vy0,obj.Vx,obj.Vy] = obj.project(obj.Vx0,obj.Vy0,obj.Vx,obj.Vy);
            
            obj.Vx = obj.advect(1,obj.Vx,obj.Vx0,obj.Vx0,obj.Vy0,obj.dt);
            obj.Vy = obj.advect(2,obj.Vy,obj.Vy0,obj.Vx0,obj.Vy0,obj.dt);


            [obj.Vx,obj.Vy,obj.Vx0,obj.Vy0] = obj.project(obj.Vx,obj.Vy,obj.Vx0,obj.Vy0);
            obj.s = obj.diffuse(0,obj.s,obj.density,obj.diff,obj.dt);
            obj.density = obj.advect(0, obj.density, obj.s, obj.Vx, obj.Vy, obj.dt);
            obj.density = obj.fadeON(obj.density);
        end
        
        function addDensity(obj,x,y,ammount)
            obj.density(x,y) = obj.density(x,y)+ammount;
        end

        function addVelocity(obj,x, y, amountX, amountY)
            obj.Vx(x,y) = obj.Vx(x,y)+amountX;
            obj.Vy(x,y) = obj.Vy(x,y)+amountY;
        end

        function x = diffuse(obj,b,x,x0,diff,dt)
            a = dt * diff * (obj.size);
            x=obj.lin_solve(b,x,x0,a,1+6*a);

        end

        function x = lin_solve(obj, b, x, x0, a, c)
            cRecip = 1.0 / c;
            [row, col] = size(x);
            for k = 1:4
                for i = 2:row-1
                    for j = 2:col-1
                        x(i, j) = (x0(i, j) + a * (x(i-1, j) + x(i+1, j) + x(i, j-1) + x(i, j+1))) * cRecip;
                    end
                end
                
                x = obj.set_bnd(b, x);
            end
        end

        function x = set_bnd(obj, b, x)
            [row, col] = size(x);
            x_copy = x;
            if b == 1
                x_copy(1, :) = -x_copy(2, :);
                x_copy(row, :) = -x_copy(row-1, :);
            else
                x_copy(1, :) = x_copy(2, :);
                x_copy(row, :) = x_copy(row-1, :);
            end
        
            if b == 2
                x_copy(:, 1) = -x_copy(:, 2);
                x_copy(:, col) = -x_copy(:, col-1);
            else
                x_copy(:, 1) = x_copy(:, 2);
                x_copy(:, col) = x_copy(:, col-1);
            end
        
            for i = 1:row
                for j = 1:col
                    if obj.blockMatrix(i, j) == 1
                        x_copy(i, j) = x(i, j);
                    end
                end
            end        
            x = x_copy;
        end


        function d = advect(obj, b, d, d0, velocX, velocY, dt)
            N=obj.size;
            dtx = dt * (N - 2);
            dty = dt * (N - 2);
        
            for j = 2:N-1
                for i = 2:N-1
                    tmp1 = dtx * velocX(i, j);
                    tmp2 = dty * velocY(i, j);
                    x = i - tmp1;
                    y = j - tmp2;
        
                    x = max(0.5, min(x, N + 0.5));
                    y = max(0.5, min(y, N + 0.5));
                    i0 = floor(x);
                    i1 = i0 + 1;
                    j0 = floor(y);
                    j1 = j0 + 1;
        
                    s1 = x - i0;
                    s0 = 1.0 - s1;
                    t1 = y - j0;
                    t0 = 1.0 - t1;
                    if (i0 >= 1 && i1 <= N && j0 >= 1 && j1 <= N)
                        d(i, j) = (s0 * (t0 * d0(i0, j0) + t1 * d0(i0, j1)) + ...
                                   s1 * (t0 * d0(i1, j0) + t1 * d0(i1, j1)));
                    end
                end
            end
        
            d = obj.set_bnd(b, d);
        end

        function [velocX, velocY, p, div] = project(obj, velocX, velocY, p, div)
            N=obj.size;
            div(2:end-1, 2:end-1) = -0.5 * ((velocX(3:end, 2:end-1) - velocX(1:end-2, 2:end-1)) + ...
                                            (velocY(2:end-1, 3:end) - velocY(2:end-1, 1:end-2))) / (N - 2);
            p(:) = 0;
            p = obj.set_bnd(0, p);
            div = obj.set_bnd(0, div);
            p = obj.lin_solve(0, p, div, 1, 6);
        
            velocX(2:end-1, 2:end-1) = velocX(2:end-1, 2:end-1) - 0.5 * (p(3:end, 2:end-1) - p(1:end-2, 2:end-1)) * N;
            velocY(2:end-1, 2:end-1) = velocY(2:end-1, 2:end-1) - 0.5 * (p(2:end-1, 3:end) - p(2:end-1, 1:end-2)) * N;
            
            velocX = obj.set_bnd(1, velocX);
            velocY = obj.set_bnd(2, velocY);
        
        end
    
        function density = fadeON(obj, density)
            N=obj.size;
            for row = 1:N
                for col = 1:N
                    d = density(row, col);
                    h = d - (1e-10);
                    density(row, col) = max(0, min(h, 1));
                end
            end
        end



    end
end

