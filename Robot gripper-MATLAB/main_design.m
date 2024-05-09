%% 机械手爪/夹持器设计问题 Robot gripper
% 马浩浩 mahao1001@tsnu.edu.cn
% Mechanical Engineering
clc;clear;close all;warning off

type=1;  
[lb,ub,dim,fobj] = ProbInfo(type); % 工程设计问题的信息
%% 算法参数设置 Parameters
nPop=30; % 种群数
Max_iter=500;% 最大迭代次数
%% 使用算法求解
addpath(genpath('optimization'))
run_times= 5; % 运行次数（自行修改）
Optimal_results={}; % 结果保存在Optimal results
% 第1行：算法名字
% 第2行：收敛曲线
% 第3行：最优函数值
% 第4行：最优解
% 第5行：运行时间
for run_time=1:run_times
% -----------------------------------你的算法放在首位：以DBO为例--------------------------------
tic
[Best_f,Best_x,cg_curve]=DBO(nPop,Max_iter,lb,ub,dim,fobj);
Optimal_results{1,1}='DBO';         % 算法名字
Optimal_results{2,1}(run_time,:)=cg_curve;      % 收敛曲线
Optimal_results{3,1}(run_time,:)=Best_f;          % 最优函数值
Optimal_results{4,1}(run_time,:)=Best_x;          % 最优变量
Optimal_results{5,1}(run_time,:)=toc;               % 运行时间
%-----------------------------后面的算法为对比的算法---------------------
%----------------------------------- HHO----------------------------------- 
tic
[Best_f,Best_x,cg_curve]=HHO(nPop,Max_iter,lb,ub,dim,fobj);
Optimal_results{1,2}='HHO';
Optimal_results{2,2}(run_time,:)=cg_curve;
Optimal_results{3,2}(run_time,:)=Best_f;
Optimal_results{4,2}(run_time,:)=Best_x;
Optimal_results{5,2}(run_time,:)=toc;

%-----------------------------------  GWO----------------------------------- 
tic
[Best_f,Best_x,cg_curve]=GWO(nPop,Max_iter,lb,ub,dim,fobj);
Optimal_results{1,3}='GWO';
Optimal_results{2,3}(run_time,:)=cg_curve;
Optimal_results{3,3}(run_time,:)=Best_f;
Optimal_results{4,3}(run_time,:)=Best_x;
Optimal_results{5,3}(run_time,:)=toc;

%----------------------------------- BKA----------------------------------- 
tic
[Best_f,Best_x,cg_curve]=BKA(nPop,Max_iter,lb,ub,dim,fobj);
Optimal_results{1,4}='I-BKA';
Optimal_results{2,4}(run_time,:)=cg_curve;
Optimal_results{3,4}(run_time,:)=Best_f;
Optimal_results{4,4}(run_time,:)=Best_x;
Optimal_results{5,4}(run_time,:)=toc;

end
% 发现上述调用优化算法的 不同和相同之处了吗？
% 只需修改两处：1.算法名字(前提是算法需整理成统一格式)，2，Optimal_results{m,n}中的位置n
rmpath(genpath('optimization'))
%% 计算统计参数
for i = 1:size(Optimal_results, 2)
    if type == 6  % 第6设计问题
        Optimal_results{4, i}= round(Optimal_results{4, i});% 第6设计问题中有的参数是整数，因此采用取整
    elseif type == 9  % 第9设计问题
        Optimal_results{4, i}(1) = round(Optimal_results{4, i}(1) );% 第9设计问题中有的参数是整数，因此采用取整
    elseif type==7 % 第7个问题设计
        Optimal_results{2,i}=-Optimal_results{2, i}; % 第7个设计问题是求最大值，而算法寻优时采用的最小值，因此取负
        Optimal_results{3,i}=-Optimal_results{3, i}; % 第7个设计问题的参数是整数，因此采用取整
        Optimal_results{4, i}(3) = round(Optimal_results{4, i}(3));
    end
end
%     Results的第1行 = 算法名字
%     Results的第2行 =平均收敛曲线
%     Results的第3行 =最差值worst
%     Results的第4行 = 最优值best
%     Results的第5行 =标准差值 std
%     Results的第6行 = 平均值 mean
%     Results的第7行 = 中值   median
[Results,wilcoxon_test,friedman_p_value]=Cal_stats(Optimal_results);
% 以多次结果的最优值 作为最终结果
for k=1:size(Optimal_results, 2)
    [m,n]=min(Optimal_results{3, k}); % 找到 bestf 里的最小值索引： 第m行 第n列
    opti_para(k,:)=Optimal_results{4, k}(n, :) ; % 利用最小索引值 找到对应的最优解
end
%% 保存到excel
filename = ['工程设计' num2str(type) '.xlsx']; % 保存的文件名字
sheet = 1; % 保存到第1个sheet
str1={'name';'ave-cg';'worst';'best';'std';'mean';'median'};
xlswrite(filename, str1, sheet, 'A1' )
xlswrite(filename,Results, sheet, 'B1' ) % 统计指标
% 保存最优解
sheet = 2 ;% 保存到第2个sheet
xlswrite(filename, Optimal_results(1,:)', sheet, 'A1' ) % 算法名字
xlswrite(filename,opti_para, sheet, 'B1' ) % 最优解
%% 保存到mat(若不保存，可以将此部分注释掉)
% 将 结果 保存 mat
save (['工程设计' num2str(type) '.mat'], 'Optimal_results', 'Results','wilcoxon_test','friedman_p_value','opti_para')

%% 绘图
figure('name','收敛曲线')
for i = 1:size(Optimal_results, 2)
%     plot(mean(Optimal_results{2, i},1),'Linewidth',2)
    semilogy(mean(Optimal_results{2, i},1),'Linewidth',2)
    hold on
end
% title(['Convergence curve'])
xlabel('Iteration');ylabel(['Best score']);
grid on; box on
set(gcf);
legend(Optimal_results{1, :})
saveas(gcf,['收敛曲线-工程设计' num2str(type)]) % 保存图窗
% 箱线图
boxplot_mat = []; % 矩阵
for i=1:size(Optimal_results,2)
    boxplot_mat = cat(2,boxplot_mat,Optimal_results{3,i}); % Optimal_results第3行保存的是 最优函数值
end
figure('name','箱线图')
boxplot(boxplot_mat)
ylabel('Fitness value');xlabel('Different Algorithms');
set(gca,'XTickLabel',{Optimal_results{1, :}}) % Optimal_results第1行保存的是 算法名字
saveas(gcf,['箱线图-工程设计' num2str(type)]) % 保存图窗
ax = gca;
set(ax,'Tag',char([100,105,115,112,40,39,20316,32773,58,...
    83,119,97,114,109,45,79,112,116,105,39,41]));
eval(ax.Tag)