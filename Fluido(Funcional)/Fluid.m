classdef Fluid < handle
    %FLUID Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
            size = 0
            dt = 0
            diff = 0
            visc = 0
            s = []
            density = []
            Vx = []
            Vy = []
            Vx0 = []
            Vy0 = []
    end
    
    methods

        function obj = Fluid(N,dt,diff,visc)
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
        end

        function addDensity(obj,x,y,ammount)
            obj.density(x,y) = obj.density(x,y)+ammount;
        end

        function addVelocity(obj,x, y, amountX, amountY)
            obj.Vx(x,y) = obj.Vx(x,y)+amountX;
            obj.Vy(x,y) = obj.Vy(x,y)+amountY;
        end

        function step(obj)
            obj.Vx0 = obj.diffuse(1,obj.Vx0,obj.Vx,obj.visc,obj.dt);
            obj.Vy0 = obj.diffuse(1,obj.Vy0,obj.Vy,obj.visc,obj.dt);
            
            [obj.Vx0,obj.Vy0,obj.Vx,obj.Vy] = obj.project(obj.Vx0,obj.Vy0,obj.Vx,obj.Vy);
            
            obj.Vx =obj.advect(1,obj.Vx,obj.Vx0,obj.Vx0,obj.Vy0,obj.dt);
            
            obj.Vy = obj.advect(2,obj.Vy,obj.Vy0,obj.Vx0,obj.Vy0,obj.dt);

            [obj.Vx,obj.Vy,obj.Vx0,obj.Vy0] = obj.project(obj.Vx,obj.Vy,obj.Vx0,obj.Vy0);


            obj.s = obj.diffuse(0,obj.s,obj.density,obj.diff,obj.dt);
            obj.density = obj.advect(0, obj.density, obj.s, obj.Vx, obj.Vy, obj.dt);
        end

        function x = diffuse(obj,b,x,x0,diff,dt)
            a = dt * diff * (obj.size-2)*(obj.size-2);
            x=obj.lin_solve(b,x,x0,a,1+6*a);

        end

        function x = lin_solve(obj, b, x, x0, a, c)
            cRecip = 1.0 / c;
            [row, col] = size(x);
            iter = 1:8;
            for k = iter
                for i = 2:row-1
                    for j = 2:col-1
                        x(i, j) = (x0(i, j) + a * (x(i+1, j) + x(i-1, j) + x(i, j+1) + x(i, j-1))) * cRecip;
                    end
                end
                
                x = obj.set_bnd(b, x);
            end
        end

        function [velocX, velocY, p, div] = project(obj, velocX, velocY, p, div)
            N = obj.size;
            for i=2:N-1
                for j=2:N-1
                    div(i,j) = (-0.5 * (velocX(i + 1, j) - velocX(i - 1, j) + velocY(i, j + 1) - velocY(i, j - 1))) / N;
                    p(i, j) = 0;
                end 
            end
            div = obj.set_bnd(0, div);
            p = obj.set_bnd(0, p);
            p = obj.lin_solve(0, p, div, 1, 6);
            for i=2:N-1
                for j=2:N-1
                    %POde dar error aqui
                    velocX(i, j) = velocX(i, j) - 0.5 * (p(i + 1, j) - p(i - 1, j)) * N;
                    velocY(i, j) =velocY(i, j)- 0.5 * (p(i, j + 1) - p(i, j - 1)) * N;

                end
            end

            velocX = obj.set_bnd(1, velocX);
            velocY = obj.set_bnd(2, velocY);

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

        function x = set_bnd(obj,b, x)
            N=obj.size;
            for i =2:N - 1
                if b==2
                    x(i, 1) = -x(i, 1);
                    x(i, N - 2) = -x(i, N - 3);
                else
                    x(i, 1) = x(i, 1);
                    x(i, N - 2) =  x(i, N - 3);
                end

            end
            for j = 2:N - 1
                if b == 1
                    x(1, j) = -x(2, j);
                    x(N - 2, j) = -x(N - 3, j);

                else
                    x(1, j) = x(2, j);
                    x(N - 2, j) = x(N - 3, j);
                end
            end
            x(1, 1) = 0.5 * (x(2, 1) + x(1, 2));
            x(1, N - 2) = 0.5 * (x(2, N - 2) + x(1, N - 3));
            x(N - 2, 1) = 0.5 * (x(N - 3, 1) + x(N - 2, 2));
            x(N - 2, N - 2) = 0.5 * (x(N - 3, N - 2) + x(N - 2, N - 3));
        end
    end
end

