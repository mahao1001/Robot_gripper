%% 基于Tent混沌映射、自适应ｔ分布和动态选择策略的改进粒子群优化算法主程序
clc;
clear all;
close all
%% 算法基本参数设置
c1=2; %学习因子1
c2=2;%学习因子2
w=0.7;%惯性权重
MaxDT=500;%最大迭代次数
D=3;%搜索空间维数（未知数个数）
N=30;%初始化群体个体数目
Lb=[-100,-100,-100];%种群解的下限
Ub=[100,100,100];%种群解的上限
Vmax=[1,1,1];%速度上限
Vmin=[-1,-1,-1];%速度下限
w1=0.5;%动态选择概率的上限
w2=0.1;%动态选择概率的变化幅度
a=0.5;%Tent混沌系数，0~1之间
Best_f=[];pop=[];
%% 基于Tent混沌映射的种群初始化
for L=1:N    
    pop(L,:) = Tent_int(D,a,Lb,Ub);
    Best_f(1,L)=fitness_obl(pop(L,:));
end
V=rand(N,D);
%计算各个粒子的适应度值并初始化Pi和Pg
[fitnessgbest bestindex]=min(Best_f);
gbest=pop(bestindex,:);
pbest=pop;
fitnesspbest=Best_f;
 
%% 粒子群算法更新迭代部分
for iter=1:MaxDT
    %动态选择策略
    p=w1-w2*(MaxDT-iter)/MaxDT;%自适应ｔ分布变异算子
    %进入种群更新
    for j=1:N
        %种群更新
        V(j,:)=w*V(j,:)+c1*rand*(pbest(j,:)-pop(j,:))+c2*rand*(gbest-pop(j,:));
        %更新速度边界检查
        I=V(j,:)<Vmin;
        V(j,I)=Vmin(I);
        U=V(j,:)>Vmax;
        V(j,U)=Vmax(U);
        pop(j,:)=pop(j,:)+V(j,:);
        %基于自适应t分布变异策略位置更新
        pop(j,:)=mult_t_random(pop(j,:),iter,Lb,Ub,p);
        %粒子边界检查
        PI=pop(j,:)<Lb;
        pop(j,PI)=Lb(PI);
        PU=pop(j,:)>Ub;
        pop(j,PU)=Ub(PU);
        %计算更新后种群的适应度函数值     
        Best_f(j)=fitness_obl(pop(j,:));
  
       %个体极值更新
       if Best_f(j)<fitnesspbest(j)
            pbest(j,:)=pop(j,:);
            fitnesspbest(j)=Best_f(j);
       end
 
       %全局极值更新
       if Best_f(j)<fitnessgbest
           gbest=pop(j,:);
           fitnessgbest=Best_f(j);  
       end
       
    end
   %记录粒子全局最优解
   Fgbest(iter)=fitnessgbest;
   
end
%% 结果可视化
figure
plot(Fgbest)
title(['适应度曲线 ' '终止次数=' num2str(MaxDT)]);
xlabel('进化代数');
ylabel('适应度')
