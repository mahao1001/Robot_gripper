%% ��е��צ/�г���������� Robot gripper
% ��ƺ� mahao1001@tsnu.edu.cn
% Mechanical Engineering
clc;clear;close all;warning off

type=1;  
[lb,ub,dim,fobj] = ProbInfo(type); % ��������������Ϣ
%% �㷨�������� Parameters
nPop=30; % ��Ⱥ��
Max_iter=500;% ����������
%% ʹ���㷨���
addpath(genpath('optimization'))
run_times= 5; % ���д����������޸ģ�
Optimal_results={}; % ���������Optimal results
% ��1�У��㷨����
% ��2�У���������
% ��3�У����ź���ֵ
% ��4�У����Ž�
% ��5�У�����ʱ��
for run_time=1:run_times
% -----------------------------------����㷨������λ����DBOΪ��--------------------------------
tic
[Best_f,Best_x,cg_curve]=DBO(nPop,Max_iter,lb,ub,dim,fobj);
Optimal_results{1,1}='DBO';         % �㷨����
Optimal_results{2,1}(run_time,:)=cg_curve;      % ��������
Optimal_results{3,1}(run_time,:)=Best_f;          % ���ź���ֵ
Optimal_results{4,1}(run_time,:)=Best_x;          % ���ű���
Optimal_results{5,1}(run_time,:)=toc;               % ����ʱ��
%-----------------------------������㷨Ϊ�Աȵ��㷨---------------------
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
% �������������Ż��㷨�� ��ͬ����֮ͬ������
% ֻ���޸�������1.�㷨����(ǰ�����㷨�������ͳһ��ʽ)��2��Optimal_results{m,n}�е�λ��n
rmpath(genpath('optimization'))
%% ����ͳ�Ʋ���
for i = 1:size(Optimal_results, 2)
    if type == 6  % ��6�������
        Optimal_results{4, i}= round(Optimal_results{4, i});% ��6����������еĲ�������������˲���ȡ��
    elseif type == 9  % ��9�������
        Optimal_results{4, i}(1) = round(Optimal_results{4, i}(1) );% ��9����������еĲ�������������˲���ȡ��
    elseif type==7 % ��7���������
        Optimal_results{2,i}=-Optimal_results{2, i}; % ��7����������������ֵ�����㷨Ѱ��ʱ���õ���Сֵ�����ȡ��
        Optimal_results{3,i}=-Optimal_results{3, i}; % ��7���������Ĳ�������������˲���ȡ��
        Optimal_results{4, i}(3) = round(Optimal_results{4, i}(3));
    end
end
%     Results�ĵ�1�� = �㷨����
%     Results�ĵ�2�� =ƽ����������
%     Results�ĵ�3�� =���ֵworst
%     Results�ĵ�4�� = ����ֵbest
%     Results�ĵ�5�� =��׼��ֵ std
%     Results�ĵ�6�� = ƽ��ֵ mean
%     Results�ĵ�7�� = ��ֵ   median
[Results,wilcoxon_test,friedman_p_value]=Cal_stats(Optimal_results);
% �Զ�ν��������ֵ ��Ϊ���ս��
for k=1:size(Optimal_results, 2)
    [m,n]=min(Optimal_results{3, k}); % �ҵ� bestf �����Сֵ������ ��m�� ��n��
    opti_para(k,:)=Optimal_results{4, k}(n, :) ; % ������С����ֵ �ҵ���Ӧ�����Ž�
end
%% ���浽excel
filename = ['�������' num2str(type) '.xlsx']; % ������ļ�����
sheet = 1; % ���浽��1��sheet
str1={'name';'ave-cg';'worst';'best';'std';'mean';'median'};
xlswrite(filename, str1, sheet, 'A1' )
xlswrite(filename,Results, sheet, 'B1' ) % ͳ��ָ��
% �������Ž�
sheet = 2 ;% ���浽��2��sheet
xlswrite(filename, Optimal_results(1,:)', sheet, 'A1' ) % �㷨����
xlswrite(filename,opti_para, sheet, 'B1' ) % ���Ž�
%% ���浽mat(�������棬���Խ��˲���ע�͵�)
% �� ��� ���� mat
save (['�������' num2str(type) '.mat'], 'Optimal_results', 'Results','wilcoxon_test','friedman_p_value','opti_para')

%% ��ͼ
figure('name','��������')
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
saveas(gcf,['��������-�������' num2str(type)]) % ����ͼ��
% ����ͼ
boxplot_mat = []; % ����
for i=1:size(Optimal_results,2)
    boxplot_mat = cat(2,boxplot_mat,Optimal_results{3,i}); % Optimal_results��3�б������ ���ź���ֵ
end
figure('name','����ͼ')
boxplot(boxplot_mat)
ylabel('Fitness value');xlabel('Different Algorithms');
set(gca,'XTickLabel',{Optimal_results{1, :}}) % Optimal_results��1�б������ �㷨����
saveas(gcf,['����ͼ-�������' num2str(type)]) % ����ͼ��
ax = gca;
set(ax,'Tag',char([100,105,115,112,40,39,20316,32773,58,...
    83,119,97,114,109,45,79,112,116,105,39,41]));
eval(ax.Tag)