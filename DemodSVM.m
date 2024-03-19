function [Y_test] = DemodSVM(X_train, Y_train, X_test)
%     trainNum = size(X_train, 1);
    testNum =size(X_test, 1);
    
    if size(unique(Y_train))~=2
        Y_test = Y_train(1) * ones(testNum, 1);
    else
        X_train_2 = [real(X_train) imag(X_train)];
        cl = fitcsvm(X_train_2, Y_train, 'KernelFunction', 'rbf', 'BoxConstraint', Inf, 'ClassNames', unique(Y_train));
        X_test_2 = [real(X_test) imag(X_test)];
        [Y_test, ~] = predict(cl, X_test_2);
    end
end