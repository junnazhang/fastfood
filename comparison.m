%% Generate/load data
ntimes = 10;
y_func = @(X,r) (X*r + randn(size(X,1),1)*.1);

n_values = [1000,10000];%,100000];
d_values = [150,300];%,600,1000,10000];
timing_data = {};

rng(1);

for k = 1:length(n_values)
    n = n_values(k);
    for z = 1:length(d_values)
        d = d_values(z);
        
        tlasso = [];
        tsven = [];
        tphi = [];
        tffen = [];
        for i = 1:ntimes
            X = randn(n,d);
            r = zeros(size(X,2),1);
            inxs = randperm(d);
            frac_nonzero = 0.1;
            num_nonzero = round(frac_nonzero*d);
            ugly = [-1,1];
            s = [];
            for j = 1:num_nonzero
                ugly_inxs = randperm(2);
                s(j) = ugly(ugly_inxs(1));
            end
            r(inxs(1:num_nonzero)) = s.*(3 + 2*rand(1,num_nonzero));
            y = y_func(X,r); % small added noise
            % mean center and unit variance
            X = zscore(X);
            
            %% Hyper params
            lambda2 = 0.1;
            alpha = 0.5;
            t = lambda2*alpha;
            
            %% Built-in lasso
            tic;
            B = lasso(X,y,'alpha',alpha,'lambda',lambda2);
            tlasso(i) = toc;
            %find(B(:,1) ~= 0);
            
            %% SVEN
            tic;
            beta = SVEN(X',y',t,lambda2);
            tsven(i) = toc;
            %find(beta ~= 0)
            
            %     %% FFEN
            %     try
            %         % test whether we can use Spiral package
            %         fwht_spiral([1; 1]);
            %         use_spiral = 1;
            %     catch
            %         display('Cannot perform Walsh-Hadamard transform using Spiral WHT package.');
            %         display('Use Matlab function fwht instead, which is slow for large-scale data.')
            %         use_spiral = 0;
            %     end
            %     N = d*20; % number of basis functions to use for approximation
            %     para = FastfoodPara(N,d);
            %     sigma = 10; % band-width of Gaussian kernel
            %     tic;
            %     phi = FastfoodForKernel(X',para,sigma,use_spiral)';
            %     tphi(i) = toc;
            %     tic;
            %     B = lasso(phi,y);
            %     tffen(i) = toc;
        end
        
        timing_data{k,z} = {};
        timing_data{k,z}.tlasso = tlasso;
        timing_data{k,z}.tsven = tsven;
        
    end
end

for k = 1:length(n_values)
    n = n_values(k);
    for z = 1:length(d_values)
        d = d_values(z);
        tlasso = timing_data{k,z}.tlasso;
        tsven = timing_data{k,z}.tsven;
        fprintf('ntimes = %d, n = %d, d = %d\n',ntimes,n,d);
        fprintf('tlasso: %f, %f\n',mean(tlasso),std(tlasso));
        fprintf('tsven: %f, %f\n',mean(tsven),std(tsven));
    end
end