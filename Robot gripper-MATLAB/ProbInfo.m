%% 工程设计相关函数信息


%% -----------------------------------------------------------------------------------
function [lb,ub,dim,fobj] = ProbInfo(F)

switch F         
    case 1 % Robot gripper problem: 10.1016/j.cad.2010.12.015
        fobj=@Design1;
        %变量 a,  b,   c,  e,  f,  l,  delta
        lb=[ 20, 30, 100, 10, 10, 50,0.5*pi];
        ub=[100,100, 200,100, 30,200,0.8*pi];
        dim=length(lb);
end
end
% Design1 % 机械手爪设计

function y =Design1(x)
punishment_factor = 10^3; %惩罚因子
a = x(1); b = x(2); c = x(3); e = x(4); ff = x(5); l = x(6); delta = x(7);
Ymin = 50; Ymax = 100; YG = 150; Zmax = 100;

% 目标函数
fhd1 = @(z) F1(x,z,2);
fhd2 = @(z) -F1(x,z,2);
options = optimset('Display','off');
[~,fit1]= fminbnd(fhd1,0,Zmax,options);
[~,fit2]= fminbnd(fhd2,0,Zmax,options);
f = -fit2-fit1;
% 约束
g(1) = -Ymin+F1(x, Zmax,1);
g(2) = -F1(x, Zmax,1);
g(3) = Ymax-F1(x, 0,1);
g(4) = F1(x, 0,1)-YG;
g(5) = l^2+e^2-(a+b)^2;
g(6) = b^2-(a-e)^2-(l-Zmax)^2;
g(7) = Zmax-l;
% 罚函数
punishment=punishment_factor*sum(g(g>0).^2);

y=f+punishment;

end

function out = F1(x,z,flag)
a = x(1); b = x(2); c = x(3); e = x(4); ff = x(5); l = x(6); delta = x(7);
P=50;
g = sqrt(e^2+(z-l)^2);
phio = atan(e/(l-z));
alpha = acos((a^2+g^2-b^2)/(2*a*g))+phio;
beta = acos((b^2+g^2-a^2)/(2*b*g))-phio;
if flag == 1
    y = 2*(ff+e+c*sin(beta+delta));
    out = real(y);
elseif flag == 2
    Fk = P*b*sin(alpha+beta)/(2*c*cos(alpha));
    out = real(Fk);
end

end
