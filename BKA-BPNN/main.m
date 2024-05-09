% BKA_BPNN
%%  ��ջ�������
warning off             % �رձ�����Ϣ
close all               % �رտ�����ͼ��
clear                   % ��ձ���
clc                     % ���������

%%  ��������
% res = xlsread('���ݼ�.xlsx');   % �ο����ݼ���7����1���
% res = xlsread('���ݼ�1.xlsx');  % �׹��������ݼ�4����1���
res = xlsread('robot_gripper.xlsx');  % robot gripper
res = [res;res;res;res;res];
%%  ���ݷ���
num_size = 0.7;                              % ѵ����ռ���ݼ�����
outdim = 1;                                  % ���һ��Ϊ���
num_samples = size(res, 1);                  % ��������
res = res(randperm(num_samples), :);         % �������ݼ�����ϣ������ʱ��ע�͸��У�
num_train_s = round(num_size * num_samples); % ѵ������������
f_ = size(res, 2) - outdim;                  % ��������ά��

%%  ����ѵ�����Ͳ��Լ�
P_train = res(1: num_train_s, 1: f_)';
T_train = res(1: num_train_s, f_ + 1: end)';
M = size(P_train, 2);

P_test = res(num_train_s + 1: end, 1: f_)';
T_test = res(num_train_s + 1: end, f_ + 1: end)';
N = size(P_test, 2);

%%  ���ݹ�һ��
[p_train, ps_input] = mapminmax(P_train, 0, 1);
p_test = mapminmax('apply', P_test, ps_input);

[t_train, ps_output] = mapminmax(T_train, 0, 1);
t_test = mapminmax('apply', T_test, ps_output);

%%  �ڵ����
inputnum  = size(p_train, 1);  % �����ڵ���
hiddennum = 5;                 % ���ز�ڵ���
outputnum = size(t_train,1);   % �����ڵ���

%%  ��������
net = newff(p_train, t_train, hiddennum);

%%  ����ѵ������
net.trainParam.epochs     = 1000;      % ѵ������
net.trainParam.goal       = 1e-6;      % Ŀ�����
net.trainParam.lr         = 0.01;      % ѧϰ��
net.trainParam.showWindow = 0;         % �رմ���
%% DBO�㷨
% % numsum = inputnum * hiddennum + hiddennum + hiddennum * outputnum + outputnum;%�ڵ�����
% % Max_iteration = 50; %����������
% % SearchAgents_no=5; %��Ⱥ��
% % dim = numsum;  %ά��
% % lb = -2; %����
% % ub = 2; %����
% % fobj = fun(SearchAgents_no,hiddennum,net,p_train, t_train);
% % [fMin,zbest,DBO_curve]=DBO(SearchAgents_no,Max_iteration,lb,ub,dim,fobj);


%% BKA�㷨
%%  ������ʼ��
c1      = 4.494;       % ѧϰ����
c2      = 4.494;       % ѧϰ����
maxgen  =   30;        % ��Ⱥ���´���  
sizepop =    5;        % ��Ⱥ��ģ
Vmax    =  1.0;        % ����ٶ�
Vmin    = -1.0;        % ��С�ٶ�
popmax  =  1.0;        % ���߽�
popmin  = -1.0;        % ��С�߽�

%%  �ڵ�����
numsum = inputnum * hiddennum + hiddennum + hiddennum * outputnum + outputnum;

for i = 1 : sizepop
    pop(i, :) = rands(1, numsum);  % ��ʼ����Ⱥ
    V(i, :) = rands(1, numsum);    % ��ʼ���ٶ�
    fitness(i) = fun(pop(i, :), hiddennum, net, p_train, t_train);
end

%%  ���弫ֵ��Ⱥ�弫ֵ
[fitnesszbest, bestindex] = min(fitness);
zbest = pop(bestindex, :);     % ȫ�����
gbest = pop;                   % �������
fitnessgbest = fitness;        % ���������Ӧ��ֵ
BestFit = fitnesszbest;        % ȫ�������Ӧ��ֵ

%%  ����Ѱ��
for i = 1 : maxgen
    for j = 1 : sizepop

        % �ٶȸ���
        V(j, :) = V(j, :) + c1 * rand * (gbest(j, :) - pop(j, :)) + c2 * rand * (zbest - pop(j, :));
        V(j, (V(j, :) > Vmax)) = Vmax;
        V(j, (V(j, :) < Vmin)) = Vmin;

        % ��Ⱥ����
        pop(j, :) = pop(j, :) + 0.2 * V(j, :);
        pop(j, (pop(j, :) > popmax)) = popmax;
        pop(j, (pop(j, :) < popmin)) = popmin;

        % ����Ӧ����
        pos = unidrnd(numsum);
        if rand > 0.85
            pop(j, pos) = rands(1, 1);
        end

        % ��Ӧ��ֵ
        fitness(j) = fun(pop(j, :), hiddennum, net, p_train, t_train);

    end

    for j = 1 : sizepop

        % �������Ÿ���
        if fitness(j) < fitnessgbest(j)
            gbest(j, :) = pop(j, :);
            fitnessgbest(j) = fitness(j);
        end

        % Ⱥ�����Ÿ��� 
        if fitness(j) < fitnesszbest
            zbest = pop(j, :);
            fitnesszbest = fitness(j);
        end

    end

    BestFit = [BestFit, fitnesszbest];    
end

%%  ��ȡ���ų�ʼȨֵ����ֵ
w1 = zbest(1 : inputnum * hiddennum);
B1 = zbest(inputnum * hiddennum + 1 : inputnum * hiddennum + hiddennum);
w2 = zbest(inputnum * hiddennum + hiddennum + 1 : inputnum * hiddennum ...
    + hiddennum + hiddennum * outputnum);
B2 = zbest(inputnum * hiddennum + hiddennum + hiddennum * outputnum + 1 : ...
    inputnum * hiddennum + hiddennum + hiddennum * outputnum + outputnum);

%%  ����ֵ��ֵ
net.Iw{1, 1} = reshape(w1, hiddennum, inputnum);
net.Lw{2, 1} = reshape(w2, outputnum, hiddennum);
net.b{1}     = reshape(B1, hiddennum, 1);
net.b{2}     = B2';

%%  ��ѵ������ 
net.trainParam.showWindow = 1;        % �򿪴���

%%  ����ѵ��
net = train(net, p_train, t_train);

%%  ����Ԥ��
t_sim1 = sim(net, p_train);
t_sim2 = sim(net, p_test );

%%  ���ݷ���һ��
T_sim1 = mapminmax('reverse', t_sim1, ps_output);
T_sim2 = mapminmax('reverse', t_sim2, ps_output);

%%  ���������
error1 = sqrt(sum((T_sim1 - T_train).^2, 2)' ./ M);
error2 = sqrt(sum((T_sim2 - T_test) .^2, 2)' ./ N);

%%  ��ͼ
figure
plot(1: M, T_train, 'r-*', 1: M, T_sim1, 'b-o', 'LineWidth', 1)
legend('Actual value', 'Predicted value')
xlabel('Prediction sample')
ylabel('Prediction result')
string = {'Comparison of Training Set Prediction Results'; ['RMSE=' num2str(error1)]};
title(string)
xlim([1, M])
grid

figure
plot(1: N, T_test, 'r-*', 1: N, T_sim2, 'b-o', 'LineWidth', 1)
legend('Actual value', 'Predicted value')
xlabel('Prediction sample')
ylabel('Prediction result')
string = {'Comparison of Test Set Prediction Results'; ['RMSE=' num2str(error2)]};
title(string)
xlim([1, N])
grid

%%  ������ߵ���ͼ
figure;
plot(1 : length(BestFit), BestFit, 'LineWidth', 1.5);
xlabel('Iterations');
ylabel('Fitness Value');
xlim([1, length(BestFit)])
string = {'Model Iterative Error Changes'};
title(string)
grid on

%%  ���ָ�����
% R2
R1 = 1 - norm(T_train - T_sim1)^2 / norm(T_train - mean(T_train))^2;
R2 = 1 - norm(T_test  - T_sim2)^2 / norm(T_test  - mean(T_test ))^2;

disp(['The R-squared value for the training set data is��', num2str(R1)])
disp(['The R-squared value for the test set data is��', num2str(R2)])

% MAE
mae1 = sum(abs(T_sim1 - T_train), 2)' ./ M ;
mae2 = sum(abs(T_sim2 - T_test ), 2)' ./ N ;

disp(['The MAE for the training set data is��', num2str(mae1)])
disp(['The MAE for the test set data is��', num2str(mae2)])

% MBE
mbe1 = sum(T_sim1 - T_train, 2)' ./ M ;
mbe2 = sum(T_sim2 - T_test , 2)' ./ N ;

disp(['The MBE for the training set data is��', num2str(mbe1)])
disp(['The MBE for the test set data is��', num2str(mbe2)])

%%  ����ɢ��ͼ
sz = 25;
c = 'b';

figure
scatter(T_train, T_sim1, sz, c)
hold on
plot(xlim, ylim, '--k')
xlabel('The real values of the training set');
ylabel('Predicted value of training set');
xlim([min(T_train) max(T_train)])
ylim([min(T_sim1) max(T_sim1)])
% title('Training set prediction value vs. Training set real value')
legend('Training set prediction value','Training set real value')

figure
scatter(T_test, T_sim2, sz, c)
hold on
plot(xlim, ylim, '--k')
xlabel('Real value of the test set');
ylabel('Predicted value of test set');
xlim([min(T_test) max(T_test)])
ylim([min(T_sim2) max(T_sim2)])
% title('���Լ�Ԥ��ֵ vs. ���Լ���ʵֵ')
legend('Training set prediction value','Training set real value')